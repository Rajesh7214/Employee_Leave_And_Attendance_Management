package com.rajesh.elams.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class AuditLog {
	private int logId;
	private String username;
	private String action;
	private String module;
	private String recordId;
	private String description;
	private String severity; // INFO, WARN, SECURITY, CRITICAL
	private String details;  // JSON or additional structured metadata
	private String ipAddress;
	private Timestamp createdAt;

	public AuditLog() {
		this.severity = "INFO";
		this.details = "{}";
	}

	public AuditLog(int logId, String username, String action, String module, String recordId, String description, String severity, String details, String ipAddress, Timestamp createdAt) {
		this.logId = logId;
		this.username = username;
		this.action = action;
		this.module = module;
		this.recordId = recordId;
		this.description = description;
		this.severity = severity != null && !severity.isBlank() ? severity : "INFO";
		this.details = details != null ? details : "{}";
		this.ipAddress = ipAddress;
		this.createdAt = createdAt;
	}

	public AuditLog(int logId, String username, String action, String module, String recordId, String description, String ipAddress, Timestamp createdAt) {
		this(logId, username, action, module, recordId, description, "INFO", "{}", ipAddress, createdAt);
	}

	public AuditLog(String username, String action, String module, String recordId, String description, String severity, String details, String ipAddress) {
		this.username = username;
		this.action = action;
		this.module = module;
		this.recordId = recordId;
		this.description = description;
		this.severity = severity != null && !severity.isBlank() ? severity : "INFO";
		this.details = details != null ? details : "{}";
		this.ipAddress = ipAddress;
	}

	public AuditLog(String username, String action, String module, String recordId, String description, String ipAddress) {
		this(username, action, module, recordId, description, "INFO", "{}", ipAddress);
	}

	public int getLogId() {
		return logId;
	}

	public void setLogId(int logId) {
		this.logId = logId;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public String getRecordId() {
		return recordId;
	}

	public void setRecordId(String recordId) {
		this.recordId = recordId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getSeverity() {
		return severity;
	}

	public void setSeverity(String severity) {
		this.severity = severity;
	}

	public String getDetails() {
		return details;
	}

	public void setDetails(String details) {
		this.details = details;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public String getFormattedDate() {
		if (createdAt == null) return "-";
		return new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(createdAt);
	}
}
