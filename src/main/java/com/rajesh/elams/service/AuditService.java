package com.rajesh.elams.service;

import java.util.List;
import com.rajesh.elams.dao.AuditLogDao;
import com.rajesh.elams.dao.AuditLogDaoImpl;
import com.rajesh.elams.dao.LoginLogDao;
import com.rajesh.elams.dao.LoginLogDaoImpl;
import com.rajesh.elams.model.AuditLog;
import com.rajesh.elams.model.LoginLog;
import com.rajesh.elams.util.AuditEventPublisher;

public class AuditService {

	private static final AuditLogDao auditDao = new AuditLogDaoImpl();
	private static final LoginLogDao loginDao = new LoginLogDaoImpl();

	public static boolean logAction(String username, String action, String module, String recordId, String description, String ipAddress) {
		return logAction(username, action, module, recordId, description, "INFO", "{}", ipAddress);
	}

	public static boolean logAction(String username, String action, String module, String recordId, String description, String severity, String details, String ipAddress) {
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
		return auditDao.insertAuditLog(log);
	}

	public static void logActionAsync(String username, String action, String module, String recordId, String description, String severity, String details, String ipAddress) {
		AuditEventPublisher.publishEvent(username, action, module, recordId, description, severity, details, ipAddress);
	}

	public static int logLogin(String username, String status, String ipAddress, String userAgent) {
		LoginLog log = new LoginLog(
			username != null && !username.isBlank() ? username : "Guest",
			"LOGIN",
			status != null ? status : "SUCCESS",
			ipAddress != null ? ipAddress : "127.0.0.1",
			userAgent != null ? userAgent : "Browser"
		);
		int id = loginDao.insertLoginLog(log);

		String severity = "SUCCESS".equalsIgnoreCase(status) ? "INFO" : "SECURITY";
		String details = "{\"userAgent\":\"" + (userAgent != null ? userAgent.replace("\"", "'") : "Browser") + "\"}";
		logAction(username, "LOGIN", "Authentication", "-", "User login attempt: " + status, severity, details, ipAddress);

		return id;
	}

	public static boolean logLogout(String username, String ipAddress) {
		boolean updated = loginDao.updateLogoutTimeForUser(username);
		logAction(username, "LOGOUT", "Authentication", "-", "User session logged out", "INFO", "{}", ipAddress);
		return updated;
	}

	public static boolean logLogoutById(int loginId, String username, String ipAddress) {
		boolean updated = loginDao.updateLogoutTime(loginId);
		logAction(username, "LOGOUT", "Authentication", "-", "User session terminated", "INFO", "{\"loginId\":" + loginId + "}", ipAddress);
		return updated;
	}

	public List<AuditLog> getAuditLogs(String keyword, String module, String action, String dateStr) {
		return auditDao.searchAuditLogs(keyword, module, action, dateStr);
	}

	public List<AuditLog> getAuditLogsAdvanced(String keyword, String module, String action, String severity, String startDate, String endDate) {
		return auditDao.searchAuditLogsAdvanced(keyword, module, action, severity, startDate, endDate);
	}

	public AuditLog getAuditLogById(int logId) {
		return auditDao.getAuditLogById(logId);
	}

	public int purgeAuditLogsOlderThan(int days) {
		return auditDao.purgeAuditLogsOlderThan(days);
	}

	public List<AuditLog> getAllAuditLogs() {
		return auditDao.getAllAuditLogs();
	}

	public List<LoginLog> getRecentLoginLogs(int limit) {
		return loginDao.getRecentLoginLogs(limit);
	}

	public int getTotalAuditLogsCount() {
		return auditDao.getTotalAuditLogsCount();
	}

	public int getTodayAuditLogsCount() {
		return auditDao.getTodayAuditLogsCount();
	}

	public int getTotalLoginCount() {
		return loginDao.getTotalLoginCount();
	}

	public int getTodayLoginCount() {
		return loginDao.getTodayLoginCount();
	}
}
