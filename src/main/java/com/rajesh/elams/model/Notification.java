package com.rajesh.elams.model;

import java.sql.Timestamp;

public class Notification {
	private long notificationId;
	private long senderId;
	private long receiverId;

	private String senderName;
	private String recipientType = "ALL"; // "ALL" or "EMPLOYEE"
	private Integer targetEmployeeId;

	private String title;
	private String message;
	private String category; // Task, Leave, Meeting, Attendance, Payroll, Announcement, Project, Reminder, Holiday, Security, Documents, Performance
	private String priority; // Low, Medium, High, Critical
	private String status;   // Unread, Read, Archived

	private Timestamp createdAt;
	private Timestamp readAt;

	// Category constants
	public static final String CAT_TASK = "Task";
	public static final String CAT_LEAVE = "Leave";
	public static final String CAT_MEETING = "Meeting";
	public static final String CAT_ATTENDANCE = "Attendance";
	public static final String CAT_PAYROLL = "Payroll";
	public static final String CAT_ANNOUNCEMENT = "Announcement";
	public static final String CAT_PROJECT = "Project";
	public static final String CAT_REMINDER = "Reminder";
	public static final String CAT_HOLIDAY = "Holiday";
	public static final String CAT_SECURITY = "Security";
	public static final String CAT_DOCUMENTS = "Documents";
	public static final String CAT_PERFORMANCE = "Performance";

	// Priority constants
	public static final String PRIORITY_LOW = "Low";
	public static final String PRIORITY_MEDIUM = "Medium";
	public static final String PRIORITY_HIGH = "High";
	public static final String PRIORITY_CRITICAL = "Critical";

	// Status constants
	public static final String STATUS_UNREAD = "Unread";
	public static final String STATUS_READ = "Read";
	public static final String STATUS_ARCHIVED = "Archived";

	public Notification() {
		this.status = STATUS_UNREAD;
		this.priority = PRIORITY_MEDIUM;
		this.category = CAT_ANNOUNCEMENT;
	}

	public Notification(long senderId, long receiverId, String title, String message, String category, String priority) {
		this();
		this.senderId = senderId;
		this.receiverId = receiverId;
		this.title = title;
		this.message = message;
		this.category = category != null ? category : CAT_ANNOUNCEMENT;
		this.priority = priority != null ? priority : PRIORITY_MEDIUM;
		this.status = STATUS_UNREAD;
		if (receiverId > 0) {
			this.recipientType = "EMPLOYEE";
			this.targetEmployeeId = (int) receiverId;
		}
	}

	// Constructor compatible with legacy instantiation
	public Notification(int senderId, String senderName, String recipientType, Integer targetEmployeeId, String title,
			String message, String priority) {
		this();
		this.senderId = senderId;
		this.senderName = senderName;
		this.recipientType = recipientType != null ? recipientType : "ALL";
		this.targetEmployeeId = targetEmployeeId;
		if (targetEmployeeId != null && targetEmployeeId > 0) {
			this.receiverId = targetEmployeeId;
		}
		this.title = title;
		this.message = message;
		this.priority = mapLegacyPriority(priority);
	}

	private String mapLegacyPriority(String prio) {
		if (prio == null) return PRIORITY_MEDIUM;
		if ("URGENT".equalsIgnoreCase(prio) || "CRITICAL".equalsIgnoreCase(prio)) return PRIORITY_CRITICAL;
		if ("HIGH".equalsIgnoreCase(prio)) return PRIORITY_HIGH;
		if ("NORMAL".equalsIgnoreCase(prio) || "MEDIUM".equalsIgnoreCase(prio)) return PRIORITY_MEDIUM;
		if ("LOW".equalsIgnoreCase(prio)) return PRIORITY_LOW;
		return prio;
	}

	// Legacy getter & setter for 'id'
	public int getId() {
		return (int) notificationId;
	}

	public void setId(int id) {
		this.notificationId = id;
	}

	public long getNotificationId() {
		return notificationId;
	}

	public void setNotificationId(long notificationId) {
		this.notificationId = notificationId;
	}

	public long getSenderId() {
		return senderId;
	}

	public void setSenderId(long senderId) {
		this.senderId = senderId;
	}

	public void setSenderId(int senderId) {
		this.senderId = senderId;
	}

	public long getReceiverId() {
		return receiverId;
	}

	public void setReceiverId(long receiverId) {
		this.receiverId = receiverId;
		if (receiverId > 0) {
			this.targetEmployeeId = (int) receiverId;
		}
	}

	public void setReceiverId(int receiverId) {
		setReceiverId((long) receiverId);
	}

	public String getSenderName() {
		return senderName;
	}

	public void setSenderName(String senderName) {
		this.senderName = senderName;
	}

	public String getRecipientType() {
		return recipientType;
	}

	public void setRecipientType(String recipientType) {
		this.recipientType = recipientType;
	}

	public Integer getTargetEmployeeId() {
		return targetEmployeeId;
	}

	public void setTargetEmployeeId(Integer targetEmployeeId) {
		this.targetEmployeeId = targetEmployeeId;
		if (targetEmployeeId != null && targetEmployeeId > 0) {
			this.receiverId = targetEmployeeId;
		}
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public Timestamp getReadAt() {
		return readAt;
	}

	public void setReadAt(Timestamp readAt) {
		this.readAt = readAt;
	}

	// Legacy getter & setter for isRead
	public boolean isRead() {
		return STATUS_READ.equalsIgnoreCase(status) || (readAt != null);
	}

	public void setRead(boolean read) {
		if (read) {
			this.status = STATUS_READ;
			if (this.readAt == null) {
				this.readAt = new Timestamp(System.currentTimeMillis());
			}
		} else {
			this.status = STATUS_UNREAD;
			this.readAt = null;
		}
	}

	// Legacy aliases for createdDate & recipientId
	public Timestamp getCreatedDate() {
		return createdAt;
	}

	public void setCreatedDate(Timestamp createdDate) {
		this.createdAt = createdDate;
	}

	public long getRecipientId() {
		if (targetEmployeeId != null && targetEmployeeId > 0) {
			return targetEmployeeId;
		}
		return receiverId;
	}

	public void setRecipientId(long recipientId) {
		this.receiverId = recipientId;
		this.targetEmployeeId = (int) recipientId;
	}
}
