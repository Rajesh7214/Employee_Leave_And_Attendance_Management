package com.rajesh.elams.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Dedicated Fast2SMS Gateway Service for RChips Solutions ELAMS.
 * Exclusively implements Fast2SMS Cloud API (bulkV2 Quick/Transactional SMS).
 */
public class SmsService {

    private static boolean enabled = true;
    private static String fast2smsApiKey = "";
    private static String fast2smsRoute = "q"; // Default: Quick SMS ('q')

    private static final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(12))
            .build();

    private static final List<SmsLog> auditLogs = new CopyOnWriteArrayList<>();
    private static final AtomicLong logIdCounter = new AtomicLong(1);
    private static final int MAX_AUDIT_LOGS = 200;

    static {
        loadConfig();
    }

    /**
     * Load Fast2SMS settings from notification.properties
     */
    public static synchronized void loadConfig() {
        try (InputStream is = SmsService.class.getClassLoader().getResourceAsStream("notification.properties")) {
            if (is != null) {
                Properties props = new Properties();
                props.load(is);
                enabled = Boolean.parseBoolean(props.getProperty("sms.enabled", "true"));
                fast2smsApiKey = resolve(props.getProperty("sms.fast2sms.api.key", ""));
                fast2smsRoute = resolve(props.getProperty("sms.fast2sms.route", "q"));
            }
        } catch (Exception e) {
            System.err.println("[Fast2SMS] Note: Loading default configuration: " + e.getMessage());
        }
    }

    /**
     * Save Fast2SMS configuration persistently to notification.properties file
     */
    public static synchronized boolean saveConfigToFile(boolean isEnabled, String apiKey, String route) {
        enabled = isEnabled;
        if (apiKey != null) fast2smsApiKey = apiKey.trim();
        if (route != null && !route.isBlank()) fast2smsRoute = route.trim();

        try {
            Properties props = new Properties();
            URL resUrl = SmsService.class.getClassLoader().getResource("notification.properties");
            File propFile = null;
            if (resUrl != null) {
                try {
                    propFile = new File(resUrl.toURI());
                } catch (Exception ignored) {
                    propFile = new File(resUrl.getPath());
                }
            }

            if (propFile != null && propFile.exists()) {
                try (InputStream fis = new FileInputStream(propFile)) {
                    props.load(fis);
                }
            }

            props.setProperty("sms.enabled", String.valueOf(isEnabled));
            props.setProperty("sms.provider", "FAST2SMS");
            if (apiKey != null) props.setProperty("sms.fast2sms.api.key", apiKey.trim());
            if (route != null && !route.isBlank()) props.setProperty("sms.fast2sms.route", route.trim());

            if (propFile != null && propFile.canWrite()) {
                try (OutputStream fos = new FileOutputStream(propFile)) {
                    props.store(fos, "Updated by ELAMS Fast2SMS Gateway");
                }
            }
            return true;
        } catch (Exception e) {
            System.err.println("[Fast2SMS] Could not persist properties to disk: " + e.getMessage());
            return false;
        }
    }

    private static String resolve(String value) {
        if (value == null) return "";
        value = value.trim();
        if (value.startsWith("${") && value.endsWith("}")) {
            String varName = value.substring(2, value.length() - 1).trim();
            String envVal = System.getenv(varName);
            if (envVal != null && !envVal.isBlank()) return envVal.trim();
            String sysVal = System.getProperty(varName);
            if (sysVal != null && !sysVal.isBlank()) return sysVal.trim();
            return "";
        }
        return value;
    }

    /**
     * Send SMS to recipient phone number using Fast2SMS API
     */
    public static boolean sendSms(long toPhone, String messageText) {
        if (toPhone <= 0) return false;
        return sendSms(String.valueOf(toPhone), messageText);
    }

    public static boolean sendSms(String toPhoneStr, String messageText) {
        if (fast2smsApiKey == null || fast2smsApiKey.isBlank()) {
            loadConfig();
        }

        if (!enabled) {
            System.out.println("[Fast2SMS] SMS notifications disabled in configuration.");
            recordLog(toPhoneStr, messageText, "DISABLED", "SMS notifications disabled in settings.");
            return false;
        }

        String cleanNumber = formatPhoneNumber(toPhoneStr);
        if (cleanNumber == null || cleanNumber.isEmpty()) {
            System.err.println("[Fast2SMS] Invalid mobile number: " + toPhoneStr);
            recordLog(toPhoneStr, messageText, "FAILED", "Invalid mobile number (must be 10 digits).");
            return false;
        }

        boolean isPlaceholder = "9999999999".equals(cleanNumber) || "1234567890".equals(cleanNumber)
                || "0000000000".equals(cleanNumber);

        if (isPlaceholder) {
            System.out.println("[SmsService SIMULATOR] Placeholder number (" + cleanNumber + ") detected. Simulating SMS:");
            System.out.println("[SmsService SIMULATOR] Mobile: +91 " + cleanNumber + " | Text: " + messageText);
            recordLog("+91" + cleanNumber, messageText, "SIMULATED", "Placeholder number (" + cleanNumber + ") - simulated SMS.");
            return true;
        }

        if (fast2smsApiKey == null || fast2smsApiKey.isBlank() || fast2smsApiKey.startsWith("YOUR_")) {
            System.out.println("[SmsService SIMULATOR] Fast2SMS API Key missing or default. Simulating SMS:");
            System.out.println("[SmsService SIMULATOR] Mobile: +91 " + cleanNumber + " | Text: " + messageText);
            recordLog("+91" + cleanNumber, messageText, "SIMULATED", "API Key missing - simulated SMS delivery.");
            return true;
        }

        String routeToUse = (fast2smsRoute != null && !fast2smsRoute.isBlank()) ? fast2smsRoute.trim() : "q";

        // Method 1: POST JSON to Fast2SMS bulkV2
        try {
            String jsonPayload = "{"
                    + "\"route\":\"" + escapeJson(routeToUse) + "\","
                    + "\"message\":\"" + escapeJson(messageText) + "\","
                    + "\"language\":\"english\","
                    + "\"flash\":0,"
                    + "\"numbers\":\"" + cleanNumber + "\""
                    + "}";

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.fast2sms.com/dev/bulkV2"))
                    .header("authorization", fast2smsApiKey)
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                    .timeout(Duration.ofSeconds(10))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            String body = response.body() != null ? response.body().trim() : "";

            if (response.statusCode() >= 200 && response.statusCode() < 300 && body.contains("\"return\":true")) {
                System.out.println("[Fast2SMS] Live SMS successfully delivered to +91 " + cleanNumber + " (" + body + ")");
                recordLog("+91" + cleanNumber, messageText, "DELIVERED", "Fast2SMS Success: " + body);
                return true;
            } else if (response.statusCode() >= 200 && response.statusCode() < 300 && body.contains("\"return\":false")) {
                System.err.println("[Fast2SMS Error Response] " + body);
                System.out.println("[SmsService SIMULATOR] Mobile: +91 " + cleanNumber + " | Text: " + messageText);
                recordLog("+91" + cleanNumber, messageText, "FAILED", "Fast2SMS Error: " + body);
                return false;
            }
        } catch (Exception e) {
            System.err.println("[Fast2SMS] Note on JSON POST: " + e.getMessage());
        }

        // Method 2: GET URL parameters fallback
        try {
            String apiUrl = "https://www.fast2sms.com/dev/bulkV2"
                    + "?authorization=" + URLEncoder.encode(fast2smsApiKey, StandardCharsets.UTF_8)
                    + "&route=" + URLEncoder.encode(routeToUse, StandardCharsets.UTF_8)
                    + "&message=" + URLEncoder.encode(messageText, StandardCharsets.UTF_8)
                    + "&language=english"
                    + "&flash=0"
                    + "&numbers=" + URLEncoder.encode(cleanNumber, StandardCharsets.UTF_8);

            HttpRequest getRequest = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .GET()
                    .timeout(Duration.ofSeconds(10))
                    .build();

            HttpResponse<String> getResponse = httpClient.send(getRequest, HttpResponse.BodyHandlers.ofString());
            String body = getResponse.body() != null ? getResponse.body().trim() : "";

            if (getResponse.statusCode() >= 200 && getResponse.statusCode() < 300 && body.contains("\"return\":true")) {
                System.out.println("[Fast2SMS] Live SMS delivered via GET fallback to +91 " + cleanNumber);
                recordLog("+91" + cleanNumber, messageText, "DELIVERED", "Fast2SMS GET Success: " + body);
                return true;
            } else {
                String err = "Fast2SMS GET Error: " + body;
                System.err.println("[Fast2SMS Error] " + err);
                System.out.println("[SmsService SIMULATOR] Mobile: +91 " + cleanNumber + " | Text: " + messageText);
                recordLog("+91" + cleanNumber, messageText, "FAILED", err);
                return false;
            }
        } catch (Exception e) {
            String err = "Fast2SMS Exception: " + e.getMessage();
            System.err.println("[Fast2SMS Error] " + err);
            System.out.println("[SmsService SIMULATOR] Mobile: +91 " + cleanNumber + " | Text: " + messageText);
            recordLog("+91" + cleanNumber, messageText, "FAILED", err);
            return false;
        }
    }

    /**
     * Check live wallet balance on Fast2SMS
     */
    public static String getLiveFast2SmsBalance() {
        if (fast2smsApiKey == null || fast2smsApiKey.isBlank()) {
            return "API Key Not Set";
        }
        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.fast2sms.com/dev/wallet"))
                    .header("authorization", fast2smsApiKey)
                    .GET()
                    .timeout(Duration.ofSeconds(8))
                    .build();

            HttpResponse<String> resp = httpClient.send(req, HttpResponse.BodyHandlers.ofString());
            String body = resp.body() != null ? resp.body().trim() : "";
            if (resp.statusCode() >= 200 && resp.statusCode() < 300 && body.contains("\"wallet\"")) {
                return body;
            }
            return body;
        } catch (Exception e) {
            return "Error checking balance: " + e.getMessage();
        }
    }

    private static void recordLog(String recipient, String message, String status, String details) {
        String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        SmsLog log = new SmsLog(logIdCounter.getAndIncrement(), now, recipient, message, "FAST2SMS", status, details);
        auditLogs.add(0, log);
        while (auditLogs.size() > MAX_AUDIT_LOGS) {
            auditLogs.remove(auditLogs.size() - 1);
        }
    }

    public static List<SmsLog> getAuditLogs() {
        return new ArrayList<>(auditLogs);
    }

    /**
     * Clean and validate phone number into a standard 10-digit Indian mobile number
     */
    public static String formatPhoneNumber(String phoneStr) {
        if (phoneStr == null) return null;
        String digits = phoneStr.replaceAll("[^0-9]", "");
        if (digits.isEmpty()) return null;
        if (digits.length() > 10) {
            digits = digits.substring(digits.length() - 10);
        }
        return digits.length() == 10 ? digits : null;
    }

    public static String formatPhoneNumber(long phoneLong) {
        if (phoneLong <= 0) return null;
        return formatPhoneNumber(String.valueOf(phoneLong));
    }

    private static String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    // Getters for Configuration Properties
    public static boolean isEnabled() { return enabled; }
    public static String getProvider() { return "FAST2SMS"; }
    public static String getFast2smsApiKey() { return fast2smsApiKey; }
    public static String getFast2smsRoute() { return fast2smsRoute; }

    // Inner class for SMS audit trail
    public static class SmsLog {
        private final long id;
        private final String timestamp;
        private final String recipient;
        private final String message;
        private final String provider;
        private final String status;
        private final String details;

        public SmsLog(long id, String timestamp, String recipient, String message, String provider, String status, String details) {
            this.id = id;
            this.timestamp = timestamp;
            this.recipient = recipient;
            this.message = message;
            this.provider = provider;
            this.status = status;
            this.details = details;
        }

        public long getId() { return id; }
        public String getTimestamp() { return timestamp; }
        public String getRecipient() { return recipient; }
        public String getMessage() { return message; }
        public String getProvider() { return provider; }
        public String getStatus() { return status; }
        public String getDetails() { return details; }
    }
}
