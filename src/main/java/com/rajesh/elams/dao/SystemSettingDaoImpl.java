package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.rajesh.elams.model.SystemSetting;
import com.rajesh.elams.util.DbUtil;

public class SystemSettingDaoImpl implements SystemSettingDao {

	public SystemSettingDaoImpl() {
		ensureSystemSettingsTableExists();
		ensureDefaultSettingsExist();
	}

	private void ensureSystemSettingsTableExists() {
		String sql = "CREATE TABLE IF NOT EXISTS system_settings ("
				+ "setting_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "setting_key VARCHAR(100) NOT NULL UNIQUE, "
				+ "setting_value VARCHAR(255) NOT NULL, "
				+ "description VARCHAR(255) NULL, "
				+ "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP"
				+ ")";
		try (Connection con = DbUtil.getConnection(); java.sql.Statement stmt = con.createStatement()) {
			stmt.executeUpdate(sql);
		} catch (Exception e) {
			System.err.println("ensureSystemSettingsTableExists notice: " + e.getMessage());
		}
	}

	private void ensureDefaultSettingsExist() {
		String[] defaults = {
			"INSERT INTO system_settings (setting_key, setting_value, description) VALUES ('company_name', 'SmartOffice Pvt Ltd', 'Primary corporate organization name') ON DUPLICATE KEY UPDATE setting_key=setting_key",
			"INSERT INTO system_settings (setting_key, setting_value, description) VALUES ('working_start_time', '09:00 AM', 'Standard business office check-in time') ON DUPLICATE KEY UPDATE setting_key=setting_key",
			"INSERT INTO system_settings (setting_key, setting_value, description) VALUES ('working_end_time', '06:00 PM', 'Standard business office check-out time') ON DUPLICATE KEY UPDATE setting_key=setting_key",
			"INSERT INTO system_settings (setting_key, setting_value, description) VALUES ('max_breaks', '2', 'Maximum permitted break sessions per employee daily') ON DUPLICATE KEY UPDATE setting_key=setting_key",
			"INSERT INTO system_settings (setting_key, setting_value, description) VALUES ('session_timeout', '30', 'Session inactivity timeout limit in minutes') ON DUPLICATE KEY UPDATE setting_key=setting_key"
		};

		try (Connection con = DbUtil.getConnection(); java.sql.Statement stmt = con.createStatement()) {
			for (String sql : defaults) {
				try {
					stmt.executeUpdate(sql);
				} catch (Exception ignored) {}
			}
		} catch (Exception e) {
			System.err.println("ensureDefaultSettingsExist notice: " + e.getMessage());
		}
	}

	@Override
	public List<SystemSetting> getAllSettings() {
		List<SystemSetting> list = new ArrayList<>();
		String sql = "SELECT * FROM system_settings ORDER BY setting_id ASC";
		try (Connection con = DbUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				SystemSetting setting = new SystemSetting(
					rs.getInt("setting_id"),
					rs.getString("setting_key"),
					rs.getString("setting_value"),
					rs.getString("description"),
					rs.getTimestamp("updated_at")
				);
				list.add(setting);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public Map<String, String> getAllSettingsMap() {
		Map<String, String> map = new HashMap<>();
		String sql = "SELECT setting_key, setting_value FROM system_settings";
		try (Connection con = DbUtil.getConnection();
			 PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				map.put(rs.getString("setting_key"), rs.getString("setting_value"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return map;
	}

	@Override
	public String getSettingValue(String key, String defaultValue) {
		if (key == null || key.isBlank()) return defaultValue;
		String sql = "SELECT setting_value FROM system_settings WHERE setting_key = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, key.trim());
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String val = rs.getString("setting_value");
					return val != null ? val : defaultValue;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return defaultValue;
	}

	@Override
	public boolean updateSetting(String key, String value) {
		if (key == null || key.isBlank()) return false;
		String sql = "INSERT INTO system_settings (setting_key, setting_value) VALUES (?, ?) "
				+ "ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = CURRENT_TIMESTAMP";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, key.trim());
			ps.setString(2, value != null ? value.trim() : "");
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean saveOrUpdateSettings(Map<String, String> settingsMap) {
		if (settingsMap == null || settingsMap.isEmpty()) return false;
		boolean success = true;
		for (Map.Entry<String, String> entry : settingsMap.entrySet()) {
			boolean res = updateSetting(entry.getKey(), entry.getValue());
			if (!res) success = false;
		}
		return success;
	}
}
