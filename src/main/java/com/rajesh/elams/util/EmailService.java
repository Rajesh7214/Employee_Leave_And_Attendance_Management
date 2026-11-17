package com.rajesh.elams.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Properties;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

public class EmailService {

	private static String host = "smtp.gmail.com";
	private static int port = 587;
	private static String username = "";
	private static String password = "";
	private static String fromName = "ELAMS Management System";
	private static boolean enabled = true;

	static {
		loadConfig();
	}

	public static synchronized void loadConfig() {
		try (InputStream is = EmailService.class.getClassLoader().getResourceAsStream("notification.properties")) {
			if (is != null) {
				Properties props = new Properties();
				props.load(is);
				enabled = Boolean.parseBoolean(props.getProperty("email.enabled", "true"));
				host = resolve(props.getProperty("email.smtp.host", "smtp.gmail.com"));
				port = Integer.parseInt(resolve(props.getProperty("email.smtp.port", "587")));
				username = resolve(props.getProperty("email.username", ""));
				password = resolve(props.getProperty("email.password", ""));
				fromName = resolve(props.getProperty("email.from.name", "ELAMS Management System"));
			}
		} catch (Exception e) {
			System.err.println("[EmailService] Note: Using default configuration settings.");
		}
	}

	private static String resolve(String value) {
		if (value == null)
			return "";
		value = value.trim();
		if (value.startsWith("${") && value.endsWith("}")) {
			String varName = value.substring(2, value.length() - 1).trim();
			String envVal = System.getenv(varName);
			if (envVal != null && !envVal.isBlank()) {
				return envVal.trim();
			}
			String sysVal = System.getProperty(varName);
			if (sysVal != null && !sysVal.isBlank()) {
				return sysVal.trim();
			}
			return "";
		}
		return value;
	}

	public static boolean sendEmail(String toEmail, String subject, String bodyHtml) {
		if (!enabled) {
			System.out.println("[EmailService] Email notifications disabled in configuration.");
			return false;
		}

		if (toEmail == null || toEmail.trim().isEmpty() || !toEmail.contains("@")) {
			System.err.println("[EmailService] Invalid recipient email address: " + toEmail);
			return false;
		}

		if (username.isEmpty() || password.isEmpty() || username.contains("your-gmail")) {
			System.out.println("[EmailService SIMULATOR] Email to <" + toEmail + "> | Subject: " + subject);
			System.out.println("[EmailService SIMULATOR] Body:\n" + bodyHtml.replaceAll("<[^>]*>", ""));
			System.out.println(
					"[EmailService SIMULATOR] (To send real Gmail emails, set valid email.username and email.password in notification.properties)");
			return true;
		}

		try {
			if (port == 465) {
				return sendSmtpSsl(toEmail, subject, bodyHtml);
			} else {
				return sendSmtpStartTls(toEmail, subject, bodyHtml);
			}
		} catch (Exception e) {
			System.err.println("[EmailService Error] Failed to send email to " + toEmail + ": " + e.getMessage());
			return false;
		}
	}

	private static boolean sendSmtpStartTls(String toEmail, String subject, String bodyHtml) throws Exception {
		try (Socket socket = new Socket(host, port)) {
			BufferedReader reader = new BufferedReader(
					new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
			OutputStream out = socket.getOutputStream();

			readResponse(reader); // 220

			sendCommand(out, "EHLO localhost");
			readMultiLineResponse(reader);

			sendCommand(out, "STARTTLS");
			readResponse(reader); // 220

			SSLSocketFactory sslFactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
			SSLSocket sslSocket = (SSLSocket) sslFactory.createSocket(socket, host, port, true);
			sslSocket.startHandshake();

			BufferedReader sslReader = new BufferedReader(
					new InputStreamReader(sslSocket.getInputStream(), StandardCharsets.UTF_8));
			OutputStream sslOut = sslSocket.getOutputStream();

			sendCommand(sslOut, "EHLO localhost");
			readMultiLineResponse(sslReader);

			// AUTH LOGIN
			sendCommand(sslOut, "AUTH LOGIN");
			readResponse(sslReader); // 334

			sendCommand(sslOut, Base64.getEncoder().encodeToString(username.getBytes(StandardCharsets.UTF_8)));
			readResponse(sslReader); // 334

			sendCommand(sslOut, Base64.getEncoder().encodeToString(password.getBytes(StandardCharsets.UTF_8)));
			String authResp = readResponse(sslReader);
			if (!authResp.startsWith("235")) {
				System.err.println("[EmailService Error] SMTP Auth Failed: " + authResp);
				return false;
			}

			sendCommand(sslOut, "MAIL FROM:<" + username + ">");
			readResponse(sslReader);

			sendCommand(sslOut, "RCPT TO:<" + toEmail + ">");
			readResponse(sslReader);

			sendCommand(sslOut, "DATA");
			readResponse(sslReader); // 354

			sendCommand(sslOut, "From: " + fromName + " <" + username + ">");
			sendCommand(sslOut, "To: <" + toEmail + ">");
			sendCommand(sslOut, "Subject: " + subject);
			sendCommand(sslOut, "MIME-Version: 1.0");
			sendCommand(sslOut, "Content-Type: text/html; charset=UTF-8");
			sendCommand(sslOut, "");
			sendCommand(sslOut, bodyHtml);
			sendCommand(sslOut, ".");
			readResponse(sslReader); // 250

			sendCommand(sslOut, "QUIT");
			System.out.println("[EmailService] Successfully sent email to " + toEmail);
			return true;
		}
	}

	private static boolean sendSmtpSsl(String toEmail, String subject, String bodyHtml) throws Exception {
		SSLSocketFactory sslFactory = (SSLSocketFactory) SSLSocketFactory.getDefault();
		try (SSLSocket sslSocket = (SSLSocket) sslFactory.createSocket(host, port)) {
			sslSocket.startHandshake();
			BufferedReader sslReader = new BufferedReader(
					new InputStreamReader(sslSocket.getInputStream(), StandardCharsets.UTF_8));
			OutputStream sslOut = sslSocket.getOutputStream();

			readResponse(sslReader);

			sendCommand(sslOut, "EHLO localhost");
			readMultiLineResponse(sslReader);

			sendCommand(sslOut, "AUTH LOGIN");
			readResponse(sslReader);

			sendCommand(sslOut, Base64.getEncoder().encodeToString(username.getBytes(StandardCharsets.UTF_8)));
			readResponse(sslReader);

			sendCommand(sslOut, Base64.getEncoder().encodeToString(password.getBytes(StandardCharsets.UTF_8)));
			String authResp = readResponse(sslReader);
			if (!authResp.startsWith("235")) {
				System.err.println("[EmailService Error] SMTP Auth Failed: " + authResp);
				return false;
			}

			sendCommand(sslOut, "MAIL FROM:<" + username + ">");
			readResponse(sslReader);

			sendCommand(sslOut, "RCPT TO:<" + toEmail + ">");
			readResponse(sslReader);

			sendCommand(sslOut, "DATA");
			readResponse(sslReader);

			sendCommand(sslOut, "From: " + fromName + " <" + username + ">");
			sendCommand(sslOut, "To: <" + toEmail + ">");
			sendCommand(sslOut, "Subject: " + subject);
			sendCommand(sslOut, "MIME-Version: 1.0");
			sendCommand(sslOut, "Content-Type: text/html; charset=UTF-8");
			sendCommand(sslOut, "");
			sendCommand(sslOut, bodyHtml);
			sendCommand(sslOut, ".");
			readResponse(sslReader);

			sendCommand(sslOut, "QUIT");
			System.out.println("[EmailService] Successfully sent email via SSL to " + toEmail);
			return true;
		}
	}

	private static void sendCommand(OutputStream out, String cmd) throws Exception {
		byte[] bytes = (cmd + "\r\n").getBytes(StandardCharsets.UTF_8);
		out.write(bytes);
		out.flush();
	}

	private static String readResponse(BufferedReader reader) throws Exception {
		String line = reader.readLine();
		if (line == null) {
			throw new Exception("Unexpected end of stream from SMTP server");
		}
		return line;
	}

	private static void readMultiLineResponse(BufferedReader reader) throws Exception {
		String line;
		while ((line = reader.readLine()) != null) {
			if (line.length() >= 4 && line.charAt(3) == ' ') {
				break;
			}
		}
	}
}
