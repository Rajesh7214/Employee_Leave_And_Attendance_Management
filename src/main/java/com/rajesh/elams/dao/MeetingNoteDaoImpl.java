package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.MeetingNote;
import com.rajesh.elams.util.DbUtil;

public class MeetingNoteDaoImpl implements MeetingNoteDao {

	public MeetingNoteDaoImpl() {
		checkAndMigrateColumns();
	}

	private void checkAndMigrateColumns() {
		try (Connection conn = DbUtil.getConnection(); Statement stmt = conn.createStatement()) {
			try {
				stmt.executeUpdate("ALTER TABLE meeting_notes ADD COLUMN uploaded_by INT NULL");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE meeting_notes ADD COLUMN uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE meeting_notes ADD COLUMN summary TEXT NULL");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE meeting_notes ADD COLUMN action_items TEXT NULL");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("UPDATE meeting_notes SET uploaded_by = author_id WHERE uploaded_by IS NULL AND author_id IS NOT NULL");
			} catch (Exception ignored) {}
		} catch (Exception ignored) {}
	}

	@Override
	public boolean addNote(MeetingNote note) {
		checkAndMigrateColumns();
		String sql = "INSERT INTO meeting_notes(meeting_id, summary, action_items, uploaded_by, author_id, note_content) VALUES(?,?,?,?,?,?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, note.getMeetingId());
			ps.setString(2, note.getSummary() != null ? note.getSummary() : "");
			ps.setString(3, note.getActionItems() != null ? note.getActionItems() : "");
			ps.setInt(4, note.getUploadedBy());
			ps.setInt(5, note.getUploadedBy());
			String fullContent = (note.getSummary() != null ? note.getSummary() : "")
					+ (note.getActionItems() != null ? "\nAction Items: " + note.getActionItems() : "");
			ps.setString(6, fullContent);

			boolean inserted = ps.executeUpdate() > 0;

			if (inserted) {
				try (PreparedStatement update = con.prepareStatement(
						"UPDATE meetings SET status='COMPLETED' WHERE meeting_id=? AND status<>'CANCELLED'")) {
					update.setInt(1, note.getMeetingId());
					update.executeUpdate();
				}
			}

			return inserted;

		} catch (Exception e) {
			// Fallback simple insert if table schema is original
			String fallbackSql = "INSERT INTO meeting_notes(meeting_id, author_id, note_content) VALUES(?,?,?)";
			try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(fallbackSql)) {
				ps.setInt(1, note.getMeetingId());
				ps.setInt(2, note.getUploadedBy());
				String fullContent = (note.getSummary() != null ? note.getSummary() : "")
						+ (note.getActionItems() != null ? "\nAction Items: " + note.getActionItems() : "");
				ps.setString(3, fullContent);

				boolean inserted = ps.executeUpdate() > 0;
				if (inserted) {
					try (PreparedStatement update = con.prepareStatement(
							"UPDATE meetings SET status='COMPLETED' WHERE meeting_id=? AND status<>'CANCELLED'")) {
						update.setInt(1, note.getMeetingId());
						update.executeUpdate();
					}
				}
				return inserted;
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}

		return false;
	}

	@Override
	public List<MeetingNote> getNotesByMeeting(int meetingId) {
		checkAndMigrateColumns();
		List<MeetingNote> list = new ArrayList<>();

		String sql = "SELECT n.*, COALESCE(e1.employee_name, e2.employee_name, 'Organizer') AS uploaded_by_name "
				+ "FROM meeting_notes n "
				+ "LEFT JOIN employees e1 ON e1.employee_id = n.uploaded_by "
				+ "LEFT JOIN employees e2 ON e2.employee_id = n.author_id "
				+ "WHERE n.meeting_id=? ORDER BY n.note_id DESC";

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

	private MeetingNote mapRow(ResultSet rs) throws Exception {
		MeetingNote note = new MeetingNote();

		note.setNoteId(rs.getInt("note_id"));
		note.setMeetingId(rs.getInt("meeting_id"));

		String summary = null;
		try { summary = rs.getString("summary"); } catch (Exception ignored) {}
		if (summary == null || summary.isBlank()) {
			try { summary = rs.getString("note_content"); } catch (Exception ignored) {}
		}
		note.setSummary(summary != null ? summary : "");

		String actionItems = null;
		try { actionItems = rs.getString("action_items"); } catch (Exception ignored) {}
		note.setActionItems(actionItems != null ? actionItems : "");

		int uploadedBy = 0;
		try { uploadedBy = rs.getInt("uploaded_by"); } catch (Exception ignored) {}
		if (uploadedBy == 0) {
			try { uploadedBy = rs.getInt("author_id"); } catch (Exception ignored) {}
		}
		note.setUploadedBy(uploadedBy);

		Timestamp uploadedAt = null;
		try { uploadedAt = rs.getTimestamp("uploaded_at"); } catch (Exception ignored) {}
		if (uploadedAt == null) {
			try { uploadedAt = rs.getTimestamp("created_at"); } catch (Exception ignored) {}
		}
		note.setUploadedAt(uploadedAt);

		try {
			note.setUploadedByName(rs.getString("uploaded_by_name"));
		} catch (Exception ignored) {
			note.setUploadedByName("Organizer");
		}

		return note;
	}
}
