package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.MeetingAttachment;
import com.rajesh.elams.util.DbUtil;

public class MeetingAttachmentDaoImpl implements MeetingAttachmentDao {

	public MeetingAttachmentDaoImpl() {
		createTableIfNotExists();
	}

	private void createTableIfNotExists() {
		String sql = "CREATE TABLE IF NOT EXISTS meeting_attachments ("
				+ "attachment_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "meeting_id INT NOT NULL, "
				+ "file_name VARCHAR(255) NOT NULL, "
				+ "file_path VARCHAR(500) NOT NULL, "
				+ "file_type VARCHAR(100), "
				+ "description VARCHAR(500), "
				+ "uploaded_by INT NOT NULL, "
				+ "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
				+ ")";
		try (Connection con = DbUtil.getConnection(); Statement stmt = con.createStatement()) {
			stmt.execute(sql);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public boolean addAttachment(MeetingAttachment attachment) {
		String sql = "INSERT INTO meeting_attachments(meeting_id, file_name, file_path, file_type, description, uploaded_by) "
				+ "VALUES(?, ?, ?, ?, ?, ?)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, attachment.getMeetingId());
			ps.setString(2, attachment.getFileName());
			ps.setString(3, attachment.getFilePath());
			ps.setString(4, attachment.getFileType() != null ? attachment.getFileType() : "DOCUMENT");
			ps.setString(5, attachment.getDescription());
			ps.setInt(6, attachment.getUploadedBy());
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public List<MeetingAttachment> getAttachmentsByMeeting(int meetingId) {
		List<MeetingAttachment> list = new ArrayList<>();
		String sql = "SELECT a.*, COALESCE(e.employee_name, 'System Admin') AS uploaded_by_name "
				+ "FROM meeting_attachments a "
				+ "LEFT JOIN employees e ON e.employee_id = a.uploaded_by "
				+ "WHERE a.meeting_id = ? ORDER BY a.uploaded_at DESC";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, meetingId);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				MeetingAttachment att = new MeetingAttachment();
				att.setAttachmentId(rs.getInt("attachment_id"));
				att.setMeetingId(rs.getInt("meeting_id"));
				att.setFileName(rs.getString("file_name"));
				att.setFilePath(rs.getString("file_path"));
				att.setFileType(rs.getString("file_type"));
				att.setDescription(rs.getString("description"));
				att.setUploadedBy(rs.getInt("uploaded_by"));
				att.setUploadedByName(rs.getString("uploaded_by_name"));
				att.setUploadedAt(rs.getTimestamp("uploaded_at"));
				list.add(att);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public boolean deleteAttachment(int attachmentId) {
		String sql = "DELETE FROM meeting_attachments WHERE attachment_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, attachmentId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}
}
