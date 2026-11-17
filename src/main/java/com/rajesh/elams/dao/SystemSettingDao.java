package com.rajesh.elams.dao;

import java.util.List;
import java.util.Map;
import com.rajesh.elams.model.SystemSetting;

public interface SystemSettingDao {
	List<SystemSetting> getAllSettings();
	Map<String, String> getAllSettingsMap();
	String getSettingValue(String key, String defaultValue);
	boolean updateSetting(String key, String value);
	boolean saveOrUpdateSettings(Map<String, String> settingsMap);
}
