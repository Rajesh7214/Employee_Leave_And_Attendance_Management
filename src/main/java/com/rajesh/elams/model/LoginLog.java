package com.rajesh.elams.model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class LoginLog {
	private int loginId;
	private String username;
	private String action;
	private Timestamp loginTime;
	private Timestamp logoutTime;
	private String status;
	private String ipAddress;
	private String userAgent;

	public LoginLog() {}

	public LoginLog(int loginId, String username, String action, Timestamp loginTime, Timestamp logoutTime, String status, String ipAddress, String userAgent) {
		this.loginId = loginId;
		this.username = username;
		this.action = action;
		this.loginTime = loginTime;
		this.logoutTime = logoutTime;
		this.status = status;
		this.ipAddress = ipAddress;
		this.userAgent = userAgent;
	}

	public LoginLog(String username, String action, String status, String ipAddress, String userAgent) {
		this.username = username;
		this.action = action;
		this.status = status;
		this.ipAddress = ipAddress;
		this.userAgent = userAgent;
	}

	public int getLoginId() {
		return loginId;
	}

	public void setLoginId(int loginId) {
		this.loginId = loginId;
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

	public Timestamp getLoginTime() {
		return loginTime;
	}

	public void setLoginTime(Timestamp loginTime) {
		this.loginTime = loginTime;
	}

	public Timestamp getLogoutTime() {
		return logoutTime;
	}

	public void setLogoutTime(Timestamp logoutTime) {
		this.logoutTime = logoutTime;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public String getUserAgent() {
		return userAgent;
	}

	public void setUserAgent(String userAgent) {
		this.userAgent = userAgent;
	}

	public String getFormattedLoginTime() {
		if (loginTime == null) return "-";
		return new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(loginTime);
	}

	public String getFormattedLogoutTime() {
		if (logoutTime == null) return "Active Session";
		return new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(logoutTime);
	}
}
