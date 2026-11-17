package com.rajesh.elams.model;

/**
 * Report row for the Admin "Employee-wise Meetings" report (section 11).
 */
public class EmployeeMeetingCount {

	private int employeeId;
	private String employeeName;
	private String department;
	private int meetingCount;

	public EmployeeMeetingCount() {
	}

	public EmployeeMeetingCount(int employeeId, String employeeName, String department, int meetingCount) {
		this.employeeId = employeeId;
		this.employeeName = employeeName;
		this.department = department;
		this.meetingCount = meetingCount;
	}

	public int getEmployeeId() {
		return employeeId;
	}

	public void setEmployeeId(int employeeId) {
		this.employeeId = employeeId;
	}

	public String getEmployeeName() {
		return employeeName;
	}

	public void setEmployeeName(String employeeName) {
		this.employeeName = employeeName;
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
