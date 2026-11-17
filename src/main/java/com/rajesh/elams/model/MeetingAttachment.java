package com.rajesh.elams.model;

import java.sql.Timestamp;

public class MeetingAttachment {
	private int attachmentId;
	private int meetingId;
	private String fileName;
	private String filePath;
	private String fileType;
	private String description;
	private int uploadedBy;
	private String uploadedByName;
	private Timestamp uploadedAt;

	public MeetingAttachment() {
	}

	public MeetingAttachment(int attachmentId, int meetingId, String fileName, String filePath, String fileType,
			String description, int uploadedBy, String uploadedByName, Timestamp uploadedAt) {
		this.attachmentId = attachmentId;
		this.meetingId = meetingId;
		this.fileName = fileName;
		this.filePath = filePath;
		this.fileType = fileType;
		this.description = description;
		this.uploadedBy = uploadedBy;
		this.uploadedByName = uploadedByName;
		this.uploadedAt = uploadedAt;
	}

	public int getAttachmentId() {
		return attachmentId;
	}

	public void setAttachmentId(int attachmentId) {
		this.attachmentId = attachmentId;
	}

	public int getMeetingId() {
		return meetingId;
	}

	public void setMeetingId(int meetingId) {
		this.meetingId = meetingId;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFilePath() {
		return filePath;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}

	public String getFileType() {
		return fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public int getUploadedBy() {
		return uploadedBy;
	}

	public void setUploadedBy(int uploadedBy) {
		this.uploadedBy = uploadedBy;
	}

	public String getUploadedByName() {
		return uploadedByName;
	}

	public void setUploadedByName(String uploadedByName) {
		this.uploadedByName = uploadedByName;
	}

	public Timestamp getUploadedAt() {
		return uploadedAt;
	}

	public void setUploadedAt(Timestamp uploadedAt) {
		this.uploadedAt = uploadedAt;
	}
}
