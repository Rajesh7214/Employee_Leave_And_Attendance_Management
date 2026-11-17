package com.rajesh.elams.dao;

import java.sql.Date;
import java.sql.Time;
import java.util.List;

import com.rajesh.elams.model.Attendance;

public interface AttendanceDao {

	public boolean markAttendance(Attendance attendance);

	public boolean updateAttendance(Attendance attendance);

	public boolean deleteAttendance(int attendanceId);

	public Attendance getAttendanceById(int attendanceId);

	public List<Attendance> getAttendanceByEmployee(int employeeId);

	public List<Attendance> getAttendanceByDate(Date attendanceDate);

	public List<Attendance> getAllAttendance();

	public int getPresentCount(Date date);

	public int getAbsentCount(Date date);

	public int getHalfDayCount(Date date);

	boolean markCheckout(int employeeId, Date attendanceDate, Time checkOutTime);

	boolean markCheckout(int employeeId, Date attendanceDate, Time checkOutTime, String checkoutLocation);

	boolean startBreak(int employeeId, Date attendanceDate, Time breakStartTime);

	boolean endBreak(int employeeId, Date attendanceDate, Time breakEndTime);

	Attendance getAttendanceByEmployeeAndDate(int employeeId, Date attendanceDate);
}
