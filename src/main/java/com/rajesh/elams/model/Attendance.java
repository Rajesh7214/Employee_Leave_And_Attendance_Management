package com.rajesh.elams.model;

import java.sql.Date;
import java.sql.Time;

public class Attendance {

	private int attendance_id;
	private Date attendance_date;
	private Time check_in_time;
	private Time check_out_time;
	private Time break_start_time;
	private Time break_end_time;
	private int total_break_minutes;
	private String status;
	private String location;
	private String checkout_location;
	private int employee_id;

	public Attendance() {
	}

	public Attendance(int attendance_id, Date attendance_date, Time check_in_time, Time check_out_time, String status,
			int employee_id) {
		this.attendance_id = attendance_id;
		this.attendance_date = attendance_date;
		this.check_in_time = check_in_time;
		this.check_out_time = check_out_time;
		this.status = status;
		this.employee_id = employee_id;
	}

	public int getAttendance_id() {
		return attendance_id;
	}

	public void setAttendance_id(int attendance_id) {
		this.attendance_id = attendance_id;
	}

	public Date getAttendance_date() {
		return attendance_date;
	}

	public void setAttendance_date(Date attendance_date) {
		this.attendance_date = attendance_date;
	}

	public Time getCheck_in_time() {
		return check_in_time;
	}

	public void setCheck_in_time(Time check_in_time) {
		this.check_in_time = check_in_time;
	}

	public Time getCheck_out_time() {
		return check_out_time;
	}

	public void setCheck_out_time(Time check_out_time) {
		this.check_out_time = check_out_time;
	}

	public Time getBreak_start_time() {
		return break_start_time;
	}

	public void setBreak_start_time(Time break_start_time) {
		this.break_start_time = break_start_time;
	}

	public Time getBreak_end_time() {
		return break_end_time;
	}

	public void setBreak_end_time(Time break_end_time) {
		this.break_end_time = break_end_time;
	}

	public int getTotal_break_minutes() {
		return total_break_minutes;
	}

	public void setTotal_break_minutes(int total_break_minutes) {
		this.total_break_minutes = total_break_minutes;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getCheckout_location() {
		return checkout_location;
	}

	public void setCheckout_location(String checkout_location) {
		this.checkout_location = checkout_location;
	}

	public int getEmployee_id() {
		return employee_id;
	}

	public void setEmployee_id(int employee_id) {
		this.employee_id = employee_id;
	}

	@Override
	public String toString() {
		return "Attendance [attendance_id=" + attendance_id + ", attendance_date=" + attendance_date
				+ ", check_in_time=" + check_in_time + ", check_out_time=" + check_out_time + ", break_start_time="
				+ break_start_time + ", break_end_time=" + break_end_time + ", total_break_minutes="
				+ total_break_minutes + ", status=" + status + ", location=" + location + ", checkout_location="
				+ checkout_location + ", employee_id=" + employee_id + "]";
	}
}