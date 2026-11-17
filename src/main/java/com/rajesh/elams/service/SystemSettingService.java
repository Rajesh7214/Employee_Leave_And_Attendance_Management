package com.rajesh.elams.service;

import java.util.List;
import java.util.Map;
import com.rajesh.elams.dao.SystemSettingDao;
import com.rajesh.elams.dao.SystemSettingDaoImpl;
import com.rajesh.elams.model.SystemSetting;

public class SystemSettingService {

	private final SystemSettingDao settingDao;

	public SystemSettingService() {
		this.settingDao = new SystemSettingDaoImpl();
	}

	public List<SystemSetting> getAllSettings() {
		return settingDao.getAllSettings();
	}

	public Map<String, String> getAllSettingsMap() {
		return settingDao.getAllSettingsMap();
	}

	public String getSetting(String key, String defaultValue) {
		return settingDao.getSettingValue(key, defaultValue);
	}

	public boolean updateSetting(String key, String value) {
		return settingDao.updateSetting(key, value);
	}

	public boolean updateSettings(Map<String, String> settingsMap) {
		return settingDao.saveOrUpdateSettings(settingsMap);
	}
}
