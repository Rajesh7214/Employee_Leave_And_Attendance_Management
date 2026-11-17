package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.LoginLog;
import com.rajesh.elams.util.DbUtil;

public class LoginLogDaoImpl implements LoginLogDao {

	public LoginLogDaoImpl() {
		ensureLoginLogsTableExists();
	}

	private void ensureLoginLogsTableExists() {
		String sql = "CREATE TABLE IF NOT EXISTS login_logs ("
				+ "login_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "username VARCHAR(100) NOT NULL, "
				+ "action VARCHAR(20) NOT NULL DEFAULT 'LOGIN', "
				+ "login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
				+ "logout_time TIMESTAMP NULL, "
				+ "status VARCHAR(20) DEFAULT 'SUCCESS', "
				+ "ip_address VARCHAR(50) NULL, "
				+ "user_agent VARCHAR(255) NULL"
				+ ")";
		try (Connection con = DbUtil.getConnection(); java.sql.Statement stmt = con.createStatement()) {
			stmt.executeUpdate(sql);
		} catch (Exception e) {
			System.err.println("ensureLoginLogsTableExists notice: " + e.getMessage());
		}
	}

	@Override
	public int insertLoginLog(LoginLog log) {
		if (log == null) return -1;
		String sql = "INSERT INTO login_logs (username, action, status, ip_address, user_agent) VALUES (?, ?, ?, ?, ?)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			ps.setString(1, log.getUsername() != null ? log.getUsername() : "Guest");
			ps.setString(2, log.getAction() != null ? log.getAction() : "LOGIN");
			ps.setString(3, log.getStatus() != null ? log.getStatus() : "SUCCESS");
			ps.setString(4, log.getIpAddress() != null ? log.getIpAddress() : "127.0.0.1");
			ps.setString(5, log.getUserAgent() != null ? log.getUserAgent() : "Unknown");
			
			int affected = ps.executeUpdate();
			if (affected > 0) {
				try (ResultSet keys = ps.getGeneratedKeys()) {
					if (keys.next()) {
						return keys.getInt(1);
					}
				}
			}
		} catch (Exception e) {
			System.err.println("insertLoginLog failed: " + e.getMessage());
			e.printStackTrace();
		}
		return -1;
	}

	@Override
	public boolean updateLogoutTime(int loginId) {
		if (loginId <= 0) return false;
		String sql = "UPDATE login_logs SET logout_time = CURRENT_TIMESTAMP WHERE login_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, loginId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean updateLogoutTimeForUser(String username) {
		if (username == null || username.isBlank()) return false;
		String sql = "UPDATE login_logs SET logout_time = CURRENT_TIMESTAMP WHERE LOWER(username) = LOWER(?) AND logout_time IS NULL ORDER BY login_time DESC LIMIT 1";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, username.trim());
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public List<LoginLog> getAllLoginLogs() {
		return getRecentLoginLogs(200);
	}

	@Override
	public List<LoginLog> getRecentLoginLogs(int limit) {
		List<LoginLog> list = new ArrayList<>();
		String sql = "SELECT * FROM login_logs ORDER BY login_time DESC LIMIT ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setInt(1, limit > 0 ? limit : 100);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					LoginLog log = new LoginLog(
						rs.getInt("login_id"),
						rs.getString("username"),
						rs.getString("action"),
						rs.getTimestamp("login_time"),
						rs.getTimestamp("logout_time"),
						rs.getString("status"),
						rs.getString("ip_address"),
						rs.getString("user_agent")
					);
					list.add(log);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public int getTotalLoginCount() {
		String sql = "SELECT COUNT(*) FROM login_logs WHERE status = 'SUCCESS'";
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
	public int getTodayLoginCount() {
		String sql = "SELECT COUNT(*) FROM login_logs WHERE status = 'SUCCESS' AND DATE(login_time) = CURRENT_DATE()";
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
