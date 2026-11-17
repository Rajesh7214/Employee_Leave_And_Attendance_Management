package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.LoginLog;

public interface LoginLogDao {
	int insertLoginLog(LoginLog log);
	boolean updateLogoutTime(int loginId);
	boolean updateLogoutTimeForUser(String username);
	List<LoginLog> getAllLoginLogs();
	List<LoginLog> getRecentLoginLogs(int limit);
	int getTotalLoginCount();
	int getTodayLoginCount();
}
