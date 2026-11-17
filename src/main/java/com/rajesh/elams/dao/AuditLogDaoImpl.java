package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.AuditLog;
import com.rajesh.elams.util.DbUtil;

public class AuditLogDaoImpl implements AuditLogDao {

	public AuditLogDaoImpl() {
		ensureAuditLogsTableExists();
	}

	private void ensureAuditLogsTableExists() {
		String sql = "CREATE TABLE IF NOT EXISTS audit_logs ("
				+ "log_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "username VARCHAR(100) NOT NULL, "
				+ "action VARCHAR(50) NOT NULL, "
				+ "module VARCHAR(50) NOT NULL, "
				+ "record_id VARCHAR(50) NULL, "
				+ "description TEXT NULL, "
				+ "severity VARCHAR(20) DEFAULT 'INFO', "
				+ "details TEXT NULL, "
				+ "ip_address VARCHAR(50) NULL, "
				+ "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
				+ ")";
		try (Connection con = DbUtil.getConnection(); java.sql.Statement stmt = con.createStatement()) {
			stmt.executeUpdate(sql);

			// Dynamic Column Migration for severity & details
			try {
				stmt.executeUpdate("ALTER TABLE audit_logs ADD COLUMN severity VARCHAR(20) DEFAULT 'INFO'");
			} catch (Exception ignored) {}
			try {
				stmt.executeUpdate("ALTER TABLE audit_logs ADD COLUMN details TEXT NULL");
			} catch (Exception ignored) {}
		} catch (Exception e) {
			System.err.println("ensureAuditLogsTableExists notice: " + e.getMessage());
		}
	}

	@Override
	public boolean insertAuditLog(AuditLog log) {
		if (log == null) return false;
		String sql = "INSERT INTO audit_logs (username, action, module, record_id, description, severity, details, ip_address) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, log.getUsername() != null ? log.getUsername() : "System");
			ps.setString(2, log.getAction() != null ? log.getAction() : "UNKNOWN");
			ps.setString(3, log.getModule() != null ? log.getModule() : "General");
			ps.setString(4, log.getRecordId() != null ? log.getRecordId() : "-");
			ps.setString(5, log.getDescription() != null ? log.getDescription() : "");
			ps.setString(6, log.getSeverity() != null ? log.getSeverity() : "INFO");
			ps.setString(7, log.getDetails() != null ? log.getDetails() : "{}");
			ps.setString(8, log.getIpAddress() != null ? log.getIpAddress() : "127.0.0.1");
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("insertAuditLog failed: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public List<AuditLog> getAllAuditLogs() {
		return searchAuditLogs(null, null, null, null);
	}

	@Override
	public List<AuditLog> searchAuditLogs(String keyword, String module, String action, String dateStr) {
		return searchAuditLogsAdvanced(keyword, module, action, "All", dateStr, dateStr);
	}

	@Override
	public List<AuditLog> searchAuditLogsAdvanced(String keyword, String module, String action, String severity, String startDate, String endDate) {
		List<AuditLog> list = new ArrayList<>();
		StringBuilder sql = new StringBuilder("SELECT * FROM audit_logs WHERE 1=1 ");
		List<Object> params = new ArrayList<>();

		if (module != null && !module.isBlank() && !"All".equalsIgnoreCase(module)) {
			sql.append(" AND LOWER(module) = LOWER(?)");
			params.add(module.trim());
		}

		if (action != null && !action.isBlank() && !"All".equalsIgnoreCase(action)) {
			sql.append(" AND LOWER(action) = LOWER(?)");
			params.add(action.trim());
		}

		if (severity != null && !severity.isBlank() && !"All".equalsIgnoreCase(severity)) {
			sql.append(" AND LOWER(severity) = LOWER(?)");
			params.add(severity.trim());
		}

		if (keyword != null && !keyword.isBlank()) {
			sql.append(" AND (LOWER(username) LIKE ? OR LOWER(description) LIKE ? OR LOWER(record_id) LIKE ? OR LOWER(action) LIKE ? OR LOWER(module) LIKE ?)");
			String term = "%" + keyword.trim().toLowerCase() + "%";
			params.add(term);
			params.add(term);
			params.add(term);
			params.add(term);
			params.add(term);
		}

		if (startDate != null && !startDate.isBlank() && endDate != null && !endDate.isBlank() && startDate.equals(endDate)) {
			sql.append(" AND DATE(created_at) = ?");
			params.add(startDate.trim());
		} else {
			if (startDate != null && !startDate.isBlank()) {
				sql.append(" AND DATE(created_at) >= ?");
				params.add(startDate.trim());
			}
			if (endDate != null && !endDate.isBlank()) {
				sql.append(" AND DATE(created_at) <= ?");
				params.add(endDate.trim());
			}
		}

		sql.append(" ORDER BY created_at DESC LIMIT 500");

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++) {
				ps.setObject(i + 1, params.get(i));
			}
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					String sev = "INFO";
					String det = "{}";
					try { sev = rs.getString("severity"); } catch (Exception ignored) {}
					try { det = rs.getString("details"); } catch (Exception ignored) {}

					AuditLog log = new AuditLog(
						rs.getInt("log_id"),
						rs.getString("username"),
						rs.getString("action"),
						rs.getString("module"),
						rs.getString("record_id"),
						rs.getString("description"),
						sev != null ? sev : "INFO",
						det != null ? det : "{}",
						rs.getString("ip_address"),
						rs.getTimestamp("created_at")
					);
					list.add(log);
				}
			}
		} catch (Exception e) {
			System.err.println("searchAuditLogs error: " + e.getMessage());
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public AuditLog getAuditLogById(int logId) {
		String sql = "SELECT * FROM audit_logs WHERE log_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, logId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String sev = "INFO";
					String det = "{}";
					try { sev = rs.getString("severity"); } catch (Exception ignored) {}
					try { det = rs.getString("details"); } catch (Exception ignored) {}

					return new AuditLog(
						rs.getInt("log_id"),
						rs.getString("username"),
						rs.getString("action"),
						rs.getString("module"),
						rs.getString("record_id"),
						rs.getString("description"),
						sev != null ? sev : "INFO",
						det != null ? det : "{}",
						rs.getString("ip_address"),
						rs.getTimestamp("created_at")
					);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public int purgeAuditLogsOlderThan(int days) {
		String sql = "DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL ? DAY)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, days);
			return ps.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	@Override
	public int getTotalAuditLogsCount() {
		String sql = "SELECT COUNT(*) FROM audit_logs";
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
	public int getTodayAuditLogsCount() {
		String sql = "SELECT COUNT(*) FROM audit_logs WHERE DATE(created_at) = CURRENT_DATE()";
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
}
