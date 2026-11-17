package com.rajesh.elams.util;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import com.rajesh.elams.dao.AuditLogDao;
import com.rajesh.elams.dao.AuditLogDaoImpl;
import com.rajesh.elams.model.AuditLog;

public class AuditEventPublisher {

	private static final ExecutorService executor = Executors.newFixedThreadPool(4);
	private static final AuditLogDao auditDao = new AuditLogDaoImpl();

	public static void publishEvent(String username, String action, String module, String recordId, String description, String severity, String details, String ipAddress) {
		executor.submit(() -> {
			try {
				AuditLog log = new AuditLog(
					username != null && !username.isBlank() ? username : "System",
					action != null ? action : "UNKNOWN",
					module != null ? module : "General",
					recordId != null ? recordId : "-",
					description != null ? description : "",
					severity != null ? severity : "INFO",
					details != null ? details : "{}",
					ipAddress != null ? ipAddress : "127.0.0.1"
				);
				auditDao.insertAuditLog(log);
			} catch (Exception e) {
				System.err.println("AuditEventPublisher async log error: " + e.getMessage());
			}
		});
	}

	public static void publishSecurityEvent(String username, String action, String module, String recordId, String description, String ipAddress) {
		publishEvent(username, action, module, recordId, description, "SECURITY", "{\"securityAlert\":true}", ipAddress);
	}

	public static void shutdown() {
		executor.shutdown();
	}
}
