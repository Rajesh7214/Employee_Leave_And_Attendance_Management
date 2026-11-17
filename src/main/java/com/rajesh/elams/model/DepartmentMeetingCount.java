package com.rajesh.elams.model;

public class DepartmentMeetingCount {

	private String department;
	private int meetingCount;

	public DepartmentMeetingCount() {
	}

	public DepartmentMeetingCount(String department, int meetingCount) {
		this.department = department;
		this.meetingCount = meetingCount;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public int getMeetingCount() {
		return meetingCount;
	}

	public void setMeetingCount(int meetingCount) {
		this.meetingCount = meetingCount;
	}
}
