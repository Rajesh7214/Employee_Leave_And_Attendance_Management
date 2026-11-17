package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingMode;
import com.rajesh.elams.model.MeetingStatus;
import com.rajesh.elams.util.DbUtil;

public class MeetingDaoImpl implements MeetingDao {

	public MeetingDaoImpl() {
		ensureTableExists();
	}

	private void ensureTableExists() {
		String ddl1 = "CREATE TABLE IF NOT EXISTS meetings ("
				+ "meeting_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "title VARCHAR(255) NOT NULL, "
				+ "description TEXT, "
				+ "agenda TEXT, "
				+ "organizer_id INT NOT NULL, "
				+ "meeting_date DATE NOT NULL, "
				+ "start_time TIME NOT NULL, "
				+ "end_time TIME NOT NULL, "
				+ "meeting_type VARCHAR(50), "
				+ "meeting_mode VARCHAR(50), "
				+ "room VARCHAR(100), "
				+ "meeting_link VARCHAR(255), "
				+ "priority VARCHAR(20) DEFAULT 'MEDIUM', "
				+ "status VARCHAR(30) DEFAULT 'SCHEDULED', "
				+ "meeting_notes TEXT"
				+ ")";
		String ddl2 = "CREATE TABLE IF NOT EXISTS meeting_participants ("
				+ "id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "meeting_id INT NOT NULL, "
				+ "employee_id INT NOT NULL, "
				+ "status VARCHAR(30) DEFAULT 'INVITED', "
				+ "attendance_status VARCHAR(30) DEFAULT 'NOT_MARKED', "
				+ "check_in_time TIME"
				+ ")";
		try (Connection conn = DbUtil.getConnection(); java.sql.Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(ddl1);
			stmt.executeUpdate(ddl2);
		} catch (Exception ignored) {}
	}

	@Override
	public int createMeeting(Meeting meeting) {

		String sql = "INSERT INTO meetings(title,description,agenda,organizer_id,meeting_date,start_time,end_time,"
				+ "meeting_type,meeting_mode,room,meeting_link,priority,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

			ps.setString(1, meeting.getTitle());
			ps.setString(2, meeting.getDescription());
			ps.setString(3, meeting.getAgenda());
			ps.setInt(4, meeting.getOrganizerId());
			ps.setDate(5, meeting.getMeetingDate());
			ps.setTime(6, meeting.getStartTime());
			ps.setTime(7, meeting.getEndTime());
			ps.setString(8, meeting.getMeetingType());
			ps.setString(9, meeting.getMeetingMode().name());
			ps.setString(10, meeting.getRoom());
			ps.setString(11, meeting.getMeetingLink());
			ps.setString(12, meeting.getPriority());
			ps.setString(13, meeting.getStatus().name());

			int affected = ps.executeUpdate();

			if (affected > 0) {
				ResultSet keys = ps.getGeneratedKeys();
				if (keys.next()) {
					return keys.getInt(1);
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return -1;
	}

	@Override
	public boolean updateMeeting(Meeting meeting) {

		String sql = "UPDATE meetings SET title=?, description=?, agenda=?, meeting_date=?, start_time=?, end_time=?,"
				+ " meeting_type=?, meeting_mode=?, room=?, meeting_link=?, priority=?, status=? WHERE meeting_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, meeting.getTitle());
			ps.setString(2, meeting.getDescription());
			ps.setString(3, meeting.getAgenda());
			ps.setDate(4, meeting.getMeetingDate());
			ps.setTime(5, meeting.getStartTime());
			ps.setTime(6, meeting.getEndTime());
			ps.setString(7, meeting.getMeetingType());
			ps.setString(8, meeting.getMeetingMode().name());
			ps.setString(9, meeting.getRoom());
			ps.setString(10, meeting.getMeetingLink());
			ps.setString(11, meeting.getPriority());
			ps.setString(12, meeting.getStatus().name());
			ps.setInt(13, meeting.getMeetingId());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean deleteMeeting(int meetingId) {

		String sql = "DELETE FROM meetings WHERE meeting_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, meetingId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public Meeting getMeetingById(int meetingId) {

		Meeting meeting = null;

		String sql = "SELECT m.*, e.employee_name AS organizer_name FROM meetings m "
				+ "JOIN employees e ON e.employee_id = m.organizer_id WHERE m.meeting_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, meetingId);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				meeting = mapRow(rs);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return meeting;
	}

	@Override
	public List<Meeting> getAllMeetings() {

		List<Meeting> list = new ArrayList<>();

		String sql = "SELECT m.*, e.employee_name AS organizer_name FROM meetings m "
				+ "JOIN employees e ON e.employee_id = m.organizer_id ORDER BY m.meeting_date DESC, m.start_time";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				list.add(mapRow(rs));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public List<Meeting> searchMeetings(String search, String status, String meetingType, String priority,
			String date) {

		List<Meeting> list = new ArrayList<>();

		StringBuilder sql = new StringBuilder("SELECT m.*, e.employee_name AS organizer_name FROM meetings m "
				+ "JOIN employees e ON e.employee_id = m.organizer_id WHERE 1=1");

		List<Object> params = new ArrayList<>();

		if (search != null && !search.isBlank()) {
			sql.append(" AND (m.title LIKE ? OR e.employee_name LIKE ?)");
			params.add("%" + search + "%");
			params.add("%" + search + "%");
		}
		if (status != null && !status.isBlank()) {
			sql.append(" AND m.status = ?");
			params.add(status);
		}
		if (meetingType != null && !meetingType.isBlank()) {
			sql.append(" AND m.meeting_type = ?");
			params.add(meetingType);
		}
		if (priority != null && !priority.isBlank()) {
			sql.append(" AND m.priority = ?");
			params.add(priority);
		}
		if (date != null && !date.isBlank()) {
			sql.append(" AND m.meeting_date = ?");
			params.add(date);
		}

		sql.append(" ORDER BY m.meeting_date DESC, m.start_time");

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {

			for (int i = 0; i < params.size(); i++) {
				ps.setObject(i + 1, params.get(i));
			}

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
	public List<Meeting> getMeetingsByEmployee(int employeeId) {

		List<Meeting> list = new ArrayList<>();

		String sql = "SELECT DISTINCT m.*, e.employee_name AS organizer_name FROM meetings m "
				+ "JOIN employees e ON e.employee_id = m.organizer_id "
				+ "LEFT JOIN meeting_participants p ON p.meeting_id = m.meeting_id "
				+ "WHERE m.organizer_id = ? OR p.employee_id = ? ORDER BY m.meeting_date DESC, m.start_time";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, employeeId);
			ps.setInt(2, employeeId);

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
	public List<Meeting> getMeetingsByOrganizer(int organizerId) {

		List<Meeting> list = new ArrayList<>();

		String sql = "SELECT m.*, e.employee_name AS organizer_name FROM meetings m "
				+ "JOIN employees e ON e.employee_id = m.organizer_id "
				+ "WHERE m.organizer_id = ? ORDER BY m.meeting_date DESC, m.start_time";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, organizerId);

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
	public boolean updateMeetingStatus(int meetingId, String status) {

		String sql = "UPDATE meetings SET status=? WHERE meeting_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, status);
			ps.setInt(2, meetingId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean hasRoomConflict(String room, String meetingDate, String startTime, String endTime,
			Integer excludeMeetingId) {

		String sql = "SELECT COUNT(*) FROM meetings WHERE meeting_date=? AND room=? "
				+ "AND status NOT IN ('CANCELLED','POSTPONED') AND start_time < ? AND end_time > ?"
				+ (excludeMeetingId != null ? " AND meeting_id <> ?" : "");

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, meetingDate);
			ps.setString(2, room);
			ps.setString(3, endTime);
			ps.setString(4, startTime);

			if (excludeMeetingId != null) {
				ps.setInt(5, excludeMeetingId);
			}

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
	public int totalMeetings() {

		String sql = "SELECT COUNT(*) FROM meetings";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int upcomingMeetingsCount() {

		String sql = "SELECT COUNT(*) FROM meetings WHERE meeting_date >= CURDATE() AND status='SCHEDULED'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int completedMeetingsCount() {

		String sql = "SELECT COUNT(*) FROM meetings WHERE status='COMPLETED'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int cancelledMeetingsCount() {

		String sql = "SELECT COUNT(*) FROM meetings WHERE status='CANCELLED'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public List<Meeting> getMeetingsBetweenDates(String fromDate, String toDate) {
		List<Meeting> list = new ArrayList<>();
		String sql = "SELECT m.*, e.employee_name AS organizer_name FROM meetings m JOIN employees e ON e.employee_id = m.organizer_id WHERE m.meeting_date BETWEEN ? AND ? ORDER BY m.meeting_date DESC";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, fromDate);
			ps.setString(2, toDate);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapRow(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Meeting> getMissedMeetings() {
		List<Meeting> list = new ArrayList<>();
		String sql = "SELECT m.*, e.employee_name AS organizer_name FROM meetings m JOIN employees e ON e.employee_id = m.organizer_id WHERE m.meeting_date < CURDATE() AND m.status = 'SCHEDULED' ORDER BY m.meeting_date DESC";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				list.add(mapRow(rs));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<com.rajesh.elams.model.MeetingTypeDuration> getDurationAnalysis() {
		List<com.rajesh.elams.model.MeetingTypeDuration> list = new ArrayList<>();
		String sql = "SELECT meeting_type, COUNT(*) as count, AVG(TIMESTAMPDIFF(MINUTE, start_time, end_time)) as avg_duration FROM meetings GROUP BY meeting_type";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				com.rajesh.elams.model.MeetingTypeDuration d = new com.rajesh.elams.model.MeetingTypeDuration();
				d.setMeetingType(rs.getString("meeting_type"));
				d.setMeetingCount(rs.getInt("count"));
				d.setAvgDurationMinutes(rs.getDouble("avg_duration"));
				list.add(d);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	private Meeting mapRow(ResultSet rs) throws Exception {

		Meeting meeting = new Meeting();

		meeting.setMeetingId(rs.getInt("meeting_id"));
		meeting.setTitle(rs.getString("title"));
		meeting.setDescription(rs.getString("description"));
		meeting.setAgenda(rs.getString("agenda"));
		meeting.setOrganizerId(rs.getInt("organizer_id"));
		meeting.setMeetingDate(rs.getDate("meeting_date"));
		meeting.setStartTime(rs.getTime("start_time"));
		meeting.setEndTime(rs.getTime("end_time"));
		meeting.setMeetingType(rs.getString("meeting_type"));
		
		String modeStr = rs.getString("meeting_mode");
		MeetingMode mode = MeetingMode.OFFLINE;
		if (modeStr != null) {
			try {
				mode = MeetingMode.valueOf(modeStr.trim().toUpperCase());
			} catch (Exception ignored) {}
		}
		meeting.setMeetingMode(mode);
		meeting.setRoom(rs.getString("room"));
		meeting.setMeetingLink(rs.getString("meeting_link"));
		meeting.setPriority(rs.getString("priority"));

		String statusStr = rs.getString("status");
		MeetingStatus status = MeetingStatus.SCHEDULED;
		if (statusStr != null) {
			try {
				status = MeetingStatus.valueOf(statusStr.trim().toUpperCase());
			} catch (Exception ignored) {}
		}
		meeting.setStatus(status);
		meeting.setCreatedAt(rs.getTimestamp("created_at"));
		meeting.setOrganizerName(rs.getString("organizer_name"));

		return meeting;
	}

}
