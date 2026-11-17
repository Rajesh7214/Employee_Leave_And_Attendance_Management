package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.AuditLog;

public interface AuditLogDao {
	boolean insertAuditLog(AuditLog log);
	List<AuditLog> getAllAuditLogs();
	List<AuditLog> searchAuditLogs(String keyword, String module, String action, String dateStr);
	List<AuditLog> searchAuditLogsAdvanced(String keyword, String module, String action, String severity, String startDate, String endDate);
	AuditLog getAuditLogById(int logId);
	int purgeAuditLogsOlderThan(int days);
	int getTotalAuditLogsCount();
	int getTodayAuditLogsCount();
}
