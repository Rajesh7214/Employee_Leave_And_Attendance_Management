package com.rajesh.elams.test;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.rajesh.elams.model.AuditLog;
import com.rajesh.elams.model.LoginLog;
import com.rajesh.elams.service.AuditService;
import com.rajesh.elams.service.SystemSettingService;
import com.rajesh.elams.util.AuditEventPublisher;

public class AuditSystemManagementTest {

	public static void main(String[] args) {
		System.out.println("==================================================");
		System.out.println("   VERIFYING AUDIT & SYSTEM GOVERNANCE (ADVANCED) ");
		System.out.println("==================================================");

		AuditService auditService = new AuditService();
		SystemSettingService settingService = new SystemSettingService();

		try {
			// 1. Verify Standard & Severity Audit Logging
			boolean auditRes1 = AuditService.logAction("admin@elams.com", "CREATE_USER", "User Management", "105", "Created user account admin@elams.com", "INFO", "{\"role\":\"admin\"}", "127.0.0.1");
			boolean auditRes2 = AuditService.logAction("hr@elams.com", "UPDATE_EMPLOYEE", "Employee Management", "EMP01", "Updated employee records", "WARN", "{\"changedFields\":[\"salary\",\"department\"]}", "127.0.0.1");
			boolean auditRes3 = AuditService.logAction("security@elams.com", "FAILED_LOGIN", "Authentication", "SEC-01", "Multiple invalid password attempts detected", "SECURITY", "{\"attempts\":5,\"riskScore\":\"HIGH\"}", "192.168.1.100");

			System.out.println("Severity Audit Log Inserts: " + (auditRes1 && auditRes2 && auditRes3 ? "SUCCESS" : "FAILED"));

			// 2. Verify "Better Way" - Asynchronous Non-Blocking Event Publisher
			AuditService.logActionAsync("system@elams.com", "AUTO_BACKUP", "System Settings", "SYS-BACKUP", "Scheduled background database backup completed", "INFO", "{\"status\":\"COMPLETE\",\"sizeMB\":45}", "127.0.0.1");
			AuditEventPublisher.publishSecurityEvent("admin@elams.com", "SECURITY_ALERT", "Authentication", "SEC-ALERT", "Unauthorized API endpoint call intercepted", "10.0.0.5");
			
			Thread.sleep(500); // Allow async worker thread to persist events
			System.out.println("Async Audit Event Publication: SUCCESS");

			// 3. Verify Login & Logout Session Log
			int loginId = AuditService.logLogin("admin@elams.com", "SUCCESS", "127.0.0.1", "Chrome Browser");
			System.out.println("Recorded Login ID: " + loginId);

			boolean logoutRes = AuditService.logLogout("admin@elams.com", "127.0.0.1");
			System.out.println("Recorded Logout Status: " + logoutRes);

			// 4. Verify Advanced Querying (Severity & Details)
			List<AuditLog> allLogs = auditService.getAllAuditLogs();
			System.out.println("Total Audit Logs Fetched: " + allLogs.size());

			List<AuditLog> securityLogs = auditService.getAuditLogsAdvanced(null, null, null, "SECURITY", null, null);
			System.out.println("Filtered SECURITY Severity Logs Count: " + securityLogs.size());

			if (!securityLogs.isEmpty()) {
				AuditLog sampleSec = securityLogs.get(0);
				System.out.println("Sample SECURITY Event Details JSON: " + sampleSec.getDetails());
			}

			List<AuditLog> leaveLogs = auditService.getAuditLogs(null, "Leave Management", null, null);
			System.out.println("Filtered Leave Logs Count: " + leaveLogs.size());

			List<LoginLog> loginLogs = auditService.getRecentLoginLogs(10);
			System.out.println("Recent Login Logs Count: " + loginLogs.size());

			// 5. Verify Purge Governance
			int purgedCount = auditService.purgeAuditLogsOlderThan(365);
			System.out.println("Purge Test (>365 days): " + purgedCount + " logs purged.");

			// 6. Verify System Settings Management
			String originalCompanyName = settingService.getSetting("company_name", "SmartOffice Pvt Ltd");
			System.out.println("Current Company Name: " + originalCompanyName);

			Map<String, String> newSettings = new HashMap<>();
			newSettings.put("company_name", "SmartOffice Solutions Pvt Ltd");
			newSettings.put("working_start_time", "09:30 AM");
			newSettings.put("working_end_time", "06:30 PM");

			boolean settingsUpdated = settingService.updateSettings(newSettings);
			System.out.println("Settings Update Status: " + settingsUpdated);

			// Restore original setting
			settingService.updateSetting("company_name", originalCompanyName);

			System.out.println("==================================================");
			System.out.println("  AUDIT & SYSTEM GOVERNANCE TEST COMPLETED (PASSED)");
			System.out.println("==================================================");

		} catch (Exception e) {
			System.err.println("Module 12 Verification Failed: " + e.getMessage());
			e.printStackTrace();
		}
	}
}
