package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.InvitationStatus;
import com.rajesh.elams.model.MeetingAttendanceStatus;
import com.rajesh.elams.model.MeetingParticipant;
import com.rajesh.elams.util.DbUtil;

public class MeetingParticipantDaoImpl implements MeetingParticipantDao {

	@Override
	public boolean addParticipant(int meetingId, int employeeId) {

		String sql = "INSERT INTO meeting_participants(meeting_id,employee_id,invitation_status) VALUES(?,?,'PENDING')";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, meetingId);
			ps.setInt(2, employeeId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public List<MeetingParticipant> getParticipantsByMeeting(int meetingId) {

		List<MeetingParticipant> list = new ArrayList<>();

		String sql = "SELECT p.*, e.employee_name, e.email FROM meeting_participants p "
				+ "JOIN employees e ON e.employee_id = p.employee_id WHERE p.meeting_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, meetingId);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {
				list.add(mapRow(rs));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public MeetingParticipant getParticipant(int meetingId, int employeeId) {

		MeetingParticipant participant = null;

		String sql = "SELECT p.*, e.employee_name, e.email FROM meeting_participants p "
				+ "JOIN employees e ON e.employee_id = p.employee_id WHERE p.meeting_id=? AND p.employee_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, meetingId);
			ps.setInt(2, employeeId);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				participant = mapRow(rs);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return participant;
	}

	@Override
	public boolean updateInvitationStatus(int participantId, String invitationStatus) {

		String sql = "UPDATE meeting_participants SET invitation_status=? WHERE participant_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, invitationStatus);
			ps.setInt(2, participantId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean updateAttendance(int participantId, String attendance) {

		String sql = "UPDATE meeting_participants SET attendance=? WHERE participant_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, attendance);
			ps.setInt(2, participantId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean isDuplicateParticipant(int meetingId, int employeeId) {

		String sql = "SELECT COUNT(*) FROM meeting_participants WHERE meeting_id=? AND employee_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, meetingId);
			ps.setInt(2, employeeId);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				return rs.getInt(1) > 0;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public List<com.rajesh.elams.model.EmployeeMeetingCount> getEmployeeWiseMeetingCounts() {
		List<com.rajesh.elams.model.EmployeeMeetingCount> list = new ArrayList<>();
		String sql = "SELECT e.employee_id, e.employee_name, COUNT(p.meeting_id) as total_meetings FROM employees e LEFT JOIN meeting_participants p ON e.employee_id = p.employee_id GROUP BY e.employee_id, e.employee_name";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				com.rajesh.elams.model.EmployeeMeetingCount c = new com.rajesh.elams.model.EmployeeMeetingCount();
				c.setEmployeeId(rs.getInt("employee_id"));
				c.setEmployeeName(rs.getString("employee_name"));
				c.setMeetingCount(rs.getInt("total_meetings"));
				list.add(c);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<com.rajesh.elams.model.DepartmentMeetingCount> getDepartmentWiseMeetingCounts() {
		List<com.rajesh.elams.model.DepartmentMeetingCount> list = new ArrayList<>();
		String sql = "SELECT e.department, COUNT(DISTINCT p.meeting_id) as total_meetings FROM employees e JOIN meeting_participants p ON e.employee_id = p.employee_id GROUP BY e.department";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				com.rajesh.elams.model.DepartmentMeetingCount d = new com.rajesh.elams.model.DepartmentMeetingCount();
				d.setDepartment(rs.getString("department"));
				d.setMeetingCount(rs.getInt("total_meetings"));
				list.add(d);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public com.rajesh.elams.model.MeetingAttendanceSummary getAttendanceSummary() {
		com.rajesh.elams.model.MeetingAttendanceSummary s = new com.rajesh.elams.model.MeetingAttendanceSummary();
		String sql = "SELECT "
				+ "SUM(CASE WHEN attendance = 'PRESENT' THEN 1 ELSE 0 END) as present_count, "
				+ "SUM(CASE WHEN attendance = 'ABSENT' THEN 1 ELSE 0 END) as absent_count, "
				+ "SUM(CASE WHEN attendance = 'LATE' THEN 1 ELSE 0 END) as late_count, "
				+ "SUM(CASE WHEN attendance = 'EXCUSED' THEN 1 ELSE 0 END) as excused_count "
				+ "FROM meeting_participants";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			if (rs.next()) {
				s.setPresent(rs.getInt("present_count"));
				s.setAbsent(rs.getInt("absent_count"));
				s.setLate(rs.getInt("late_count"));
				s.setExcused(rs.getInt("excused_count"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return s;
	}

	private MeetingParticipant mapRow(ResultSet rs) throws Exception {

		MeetingParticipant p = new MeetingParticipant();

		p.setParticipantId(rs.getInt("participant_id"));
		p.setMeetingId(rs.getInt("meeting_id"));
		p.setEmployeeId(rs.getInt("employee_id"));
		
		String invStr = rs.getString("invitation_status");
		InvitationStatus invStatus = InvitationStatus.PENDING;
		if (invStr != null) {
			try {
				invStatus = InvitationStatus.valueOf(invStr.trim().toUpperCase());
			} catch (Exception ignored) {}
		}
		p.setInvitationStatus(invStatus);

		String attendance = rs.getString("attendance");
		MeetingAttendanceStatus attStatus = null;
		if (attendance != null && !attendance.isBlank()) {
			try {
				attStatus = MeetingAttendanceStatus.valueOf(attendance.trim().toUpperCase());
			} catch (Exception ignored) {}
		}
		p.setAttendance(attStatus);

		p.setEmployeeName(rs.getString("employee_name"));
		p.setEmployeeEmail(rs.getString("email"));

		return p;
	}

}
