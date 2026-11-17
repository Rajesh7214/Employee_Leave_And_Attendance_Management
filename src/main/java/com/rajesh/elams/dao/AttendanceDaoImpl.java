package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.Attendance;
import com.rajesh.elams.util.DbUtil;

public class AttendanceDaoImpl implements AttendanceDao {

	public AttendanceDaoImpl() {
		ensureTableExists();
		checkAndAddBreakColumns();
	}

	private void ensureTableExists() {
		String ddl = "CREATE TABLE IF NOT EXISTS attendance ("
				+ "attendance_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "employee_id INT NOT NULL, "
				+ "attendance_date DATE NOT NULL, "
				+ "check_in TIME, "
				+ "check_out TIME, "
				+ "status VARCHAR(50), "
				+ "break_start TIME NULL, "
				+ "break_end TIME NULL, "
				+ "total_break_minutes INT DEFAULT 0, "
				+ "location VARCHAR(255) NULL, "
				+ "checkout_location VARCHAR(255) NULL"
				+ ")";
		try (Connection conn = DbUtil.getConnection(); Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(ddl);
		} catch (Exception ignored) {}
	}

	private void checkAndAddBreakColumns() {
		try (Connection conn = DbUtil.getConnection(); Statement stmt = conn.createStatement()) {
			try {
				stmt.executeUpdate("ALTER TABLE attendance ADD COLUMN break_start TIME NULL");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE attendance ADD COLUMN break_end TIME NULL");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE attendance ADD COLUMN total_break_minutes INT DEFAULT 0");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE attendance ADD COLUMN location VARCHAR(255) NULL");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE attendance ADD COLUMN checkout_location VARCHAR(255) NULL");
			} catch (Exception ignored) {}
		} catch (Exception ignored) {}
	}

	@Override
	public boolean markAttendance(Attendance attendance) {
		if (attendance == null || attendance.getEmployee_id() <= 0 || attendance.getAttendance_date() == null) {
			return false;
		}

		// Check if attendance already exists for this employee and date to prevent duplicate records
		List<Attendance> records = getAttendanceByEmployee(attendance.getEmployee_id());
		if (records != null) {
			for (Attendance a : records) {
				if (a.getAttendance_date() != null && a.getAttendance_date().toString().equals(attendance.getAttendance_date().toString())) {
					return true;
				}
			}
		}

		String sql = "INSERT INTO attendance(employee_id, attendance_date, check_in, check_out, status, location) VALUES(?,?,?,?,?,?)";

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, attendance.getEmployee_id());
			ps.setDate(2, attendance.getAttendance_date());

			if (attendance.getCheck_in_time() != null) {
				ps.setTime(3, attendance.getCheck_in_time());
			} else {
				ps.setNull(3, java.sql.Types.TIME);
			}

			if (attendance.getCheck_out_time() != null) {
				ps.setTime(4, attendance.getCheck_out_time());
			} else {
				ps.setNull(4, java.sql.Types.TIME);
			}

			String status = attendance.getStatus();
			if (status == null || status.isBlank()) {
				status = "Present";
			}
			if (attendance.getCheck_in_time() != null) {
				LocalTime checkin = attendance.getCheck_in_time().toLocalTime();
				if (checkin.isAfter(LocalTime.of(10, 0))) {
					status = "Late";
				}
			}
			ps.setString(5, status);
			ps.setString(6, attendance.getLocation() != null ? attendance.getLocation() : "Office / Remote");

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean updateAttendance(Attendance attendance) {
		String sql = "UPDATE attendance SET employee_id=?, attendance_date=?, check_in=?, check_out=?, status=?, location=?, checkout_location=? WHERE attendance_id=?";

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, attendance.getEmployee_id());
			ps.setDate(2, attendance.getAttendance_date());
			ps.setTime(3, attendance.getCheck_in_time());
			ps.setTime(4, attendance.getCheck_out_time());
			ps.setString(5, attendance.getStatus());
			ps.setString(6, attendance.getLocation());
			ps.setString(7, attendance.getCheckout_location());
			ps.setInt(8, attendance.getAttendance_id());

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean deleteAttendance(int attendanceId) {
		String sql = "DELETE FROM attendance WHERE attendance_id=?";

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, attendanceId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean markCheckout(int employeeId, Date attendanceDate, Time checkOutTime) {
		return markCheckout(employeeId, attendanceDate, checkOutTime, "Office / Remote");
	}

	@Override
	public boolean markCheckout(int employeeId, Date attendanceDate, Time checkOutTime, String checkoutLocation) {
		String checkSql = "SELECT check_out, break_start, break_end, COALESCE(total_break_minutes, 0) AS cur_mins, status FROM attendance WHERE employee_id=? AND attendance_date=?";
		int totalBreakMins = 0;
		boolean hadOpenBreak = false;
		String existingStatus = "Present";

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(checkSql)) {
			ps.setInt(1, employeeId);
			ps.setDate(2, attendanceDate);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				Time existingCheckOut = rs.getTime("check_out");
				if (existingCheckOut != null) {
					// Already checked out today
					return true;
				}
				Time bStart = rs.getTime("break_start");
				Time bEnd = rs.getTime("break_end");
				totalBreakMins = rs.getInt("cur_mins");
				String st = rs.getString("status");
				if (st != null && !st.isBlank()) {
					existingStatus = st;
				}
				if (bStart != null && bEnd == null) {
					hadOpenBreak = true;
					if (checkOutTime != null) {
						long diffMs = checkOutTime.getTime() - bStart.getTime();
						if (diffMs < 0) diffMs += 24 * 60 * 60 * 1000;
						totalBreakMins += Math.max(1, (int) (diffMs / 60000));
					}
				}
			} else {
				return false;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		String status = "Present";
		if (checkOutTime != null) {
			LocalTime checkout = checkOutTime.toLocalTime();
			if (checkout.isBefore(LocalTime.of(18, 0))) {
				status = "Early Leave";
			} else if (checkout.isAfter(LocalTime.of(18, 0))) {
				status = "Overtime";
			} else if ("Late".equalsIgnoreCase(existingStatus)) {
				status = "Late";
			}
		}

		String sql;
		if (hadOpenBreak) {
			sql = "UPDATE attendance SET check_out=?, status=?, checkout_location=?, break_end=?, total_break_minutes=? WHERE employee_id=? AND attendance_date=?";
		} else {
			sql = "UPDATE attendance SET check_out=?, status=?, checkout_location=? WHERE employee_id=? AND attendance_date=?";
		}

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setTime(1, checkOutTime);
			ps.setString(2, status);
			ps.setString(3, checkoutLocation != null ? checkoutLocation : "Office / Remote");
			if (hadOpenBreak) {
				ps.setTime(4, checkOutTime);
				ps.setInt(5, totalBreakMins);
				ps.setInt(6, employeeId);
				ps.setDate(7, attendanceDate);
			} else {
				ps.setInt(4, employeeId);
				ps.setDate(5, attendanceDate);
			}

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean startBreak(int employeeId, Date attendanceDate, Time breakStartTime) {
		String sql = "UPDATE attendance SET break_start=?, break_end=NULL WHERE employee_id=? AND attendance_date=?";

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setTime(1, breakStartTime);
			ps.setInt(2, employeeId);
			ps.setDate(3, attendanceDate);

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean endBreak(int employeeId, Date attendanceDate, Time breakEndTime) {
		String selectSql = "SELECT break_start, COALESCE(total_break_minutes, 0) AS cur_mins FROM attendance WHERE employee_id=? AND attendance_date=?";
		int addedMins = 0;
		int existingMins = 0;

		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(selectSql)) {
			ps.setInt(1, employeeId);
			ps.setDate(2, attendanceDate);
			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				Time bStart = rs.getTime("break_start");
				existingMins = rs.getInt("cur_mins");
				if (bStart != null && breakEndTime != null) {
					long diffMs = breakEndTime.getTime() - bStart.getTime();
					if (diffMs < 0) diffMs += 24 * 60 * 60 * 1000;
					addedMins = Math.max(1, (int) (diffMs / 60000));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		int totalMins = existingMins + addedMins;

		String updateSql = "UPDATE attendance SET break_end=?, total_break_minutes=? WHERE employee_id=? AND attendance_date=?";
		try (Connection conn = DbUtil.getConnection(); PreparedStatement ps = conn.prepareStatement(updateSql)) {
			ps.setTime(1, breakEndTime);
			ps.setInt(2, totalMins);
			ps.setInt(3, employeeId);
			ps.setDate(4, attendanceDate);

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public Attendance getAttendanceById(int attendanceId) {
		Attendance attendance = null;
		String sql = "SELECT * FROM attendance WHERE attendance_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, attendanceId);
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				attendance = extractAttendance(rs);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return attendance;
	}

	@Override
	public List<Attendance> getAttendanceByEmployee(int employeeId) {
		List<Attendance> attendanceList = new ArrayList<>();
		String sql = "SELECT * FROM attendance WHERE employee_id=? ORDER BY attendance_date DESC";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, employeeId);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				attendanceList.add(extractAttendance(rs));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return attendanceList;
	}

	@Override
	public List<Attendance> getAttendanceByDate(Date attendanceDate) {
		List<Attendance> attendanceList = new ArrayList<>();
		String sql = "SELECT * FROM attendance WHERE attendance_date=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setDate(1, attendanceDate);
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				attendanceList.add(extractAttendance(rs));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return attendanceList;
	}

	@Override
	public List<Attendance> getAllAttendance() {
		List<Attendance> attendanceList = new ArrayList<>();
		String sql = "SELECT * FROM attendance ORDER BY attendance_date DESC";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				attendanceList.add(extractAttendance(rs));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return attendanceList;
	}

	@Override
	public Attendance getAttendanceByEmployeeAndDate(int employeeId, Date attendanceDate) {
		Attendance attendance = null;
		String sql = "SELECT * FROM attendance WHERE employee_id=? AND attendance_date=? LIMIT 1";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, employeeId);
			ps.setDate(2, attendanceDate);
			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				attendance = extractAttendance(rs);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return attendance;
	}

	@Override
	public int getPresentCount(Date date) {
		int count = 0;
		String sql = "SELECT COUNT(DISTINCT employee_id) FROM attendance WHERE attendance_date=? AND (check_in IS NOT NULL OR LOWER(status) IN ('present', 'late', 'early leave', 'overtime', 'on duty', 'in office')) AND LOWER(status) NOT IN ('absent', 'half day', 'half-day')";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setDate(1, date);

			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return count;
	}

	@Override
	public int getHalfDayCount(Date date) {
		int count = 0;
		String sql = "SELECT COUNT(DISTINCT employee_id) FROM attendance WHERE attendance_date=? AND (LOWER(status) LIKE '%half%' OR LOWER(status) = 'half day')";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setDate(1, date);

			ResultSet rs = ps.executeQuery();
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return count;
	}

	@Override
	public int getAbsentCount(Date date) {
		int totalEmps = getTotalEmployeeCount();
		int present = getPresentCount(date);
		int halfDay = getHalfDayCount(date);
		return Math.max(0, totalEmps - present - halfDay);
	}

	private int getTotalEmployeeCount() {
		int count = 0;
		String sql = "SELECT COUNT(*) FROM employees";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			if (rs.next()) {
				count = rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return count;
	}

	private Attendance extractAttendance(ResultSet rs) throws Exception {
		Attendance attendance = new Attendance();
		attendance.setAttendance_id(rs.getInt("attendance_id"));
		attendance.setEmployee_id(rs.getInt("employee_id"));
		attendance.setAttendance_date(rs.getDate("attendance_date"));
		attendance.setCheck_in_time(rs.getTime("check_in"));
		attendance.setCheck_out_time(rs.getTime("check_out"));

		try {
			attendance.setBreak_start_time(rs.getTime("break_start"));
		} catch (Exception ignored) {}
		try {
			attendance.setBreak_end_time(rs.getTime("break_end"));
		} catch (Exception ignored) {}
		try {
			attendance.setTotal_break_minutes(rs.getInt("total_break_minutes"));
		} catch (Exception ignored) {}
		try {
			attendance.setLocation(rs.getString("location"));
		} catch (Exception ignored) {}
		try {
			attendance.setCheckout_location(rs.getString("checkout_location"));
		} catch (Exception ignored) {}

		attendance.setStatus(rs.getString("status"));
		return attendance;
	}
}
