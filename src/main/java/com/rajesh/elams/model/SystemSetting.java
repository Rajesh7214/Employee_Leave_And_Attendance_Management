package com.rajesh.elams.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class SystemSetting {
	private int settingId;
	private String settingKey;
	private String settingValue;
	private String description;
	private Timestamp updatedAt;

	public SystemSetting() {}

	public SystemSetting(int settingId, String settingKey, String settingValue, String description, Timestamp updatedAt) {
		this.settingId = settingId;
		this.settingKey = settingKey;
		this.settingValue = settingValue;
		this.description = description;
		this.updatedAt = updatedAt;
	}

	public SystemSetting(String settingKey, String settingValue, String description) {
		this.settingKey = settingKey;
		this.settingValue = settingValue;
		this.description = description;
	}

	public int getSettingId() {
		return settingId;
	}

	public void setSettingId(int settingId) {
		this.settingId = settingId;
	}

	public String getSettingKey() {
		return settingKey;
	}

	public void setSettingKey(String settingKey) {
		this.settingKey = settingKey;
	}

	public String getSettingValue() {
		return settingValue;
	}

	public void setSettingValue(String settingValue) {
		this.settingValue = settingValue;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}

	public String getFormattedUpdatedAt() {
		if (updatedAt == null) return "-";
		return new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(updatedAt);
	}
}
