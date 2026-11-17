package com.rajesh.elams.util;

import java.sql.Date;
import java.sql.Time;
import java.util.regex.Pattern;

public class ValidationUtil {

	private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");

	public static boolean isValidEmail(String email) {
		if (email == null || email.isBlank()) return false;
		return EMAIL_PATTERN.matcher(email.trim()).matches();
	}

	public static boolean isNotEmpty(String value) {
		return value != null && !value.trim().isEmpty();
	}

	public static int parsePositiveInt(String val, int defaultValue) {
		if (val == null || val.isBlank()) return defaultValue;
		try {
			int parsed = Integer.parseInt(val.trim());
			return parsed > 0 ? parsed : defaultValue;
		} catch (NumberFormatException e) {
			return defaultValue;
		}
	}

	public static Date parseSqlDate(String dateStr) {
		if (dateStr == null || dateStr.isBlank()) return null;
		try {
			return Date.valueOf(dateStr.trim());
		} catch (Exception e) {
			return null;
		}
	}

	public static Time parseSqlTime(String timeStr) {
		if (timeStr == null || timeStr.isBlank()) return null;
		try {
			String t = timeStr.trim();
			if (t.length() == 5) {
				t += ":00";
			}
			return Time.valueOf(t);
		} catch (Exception e) {
			return null;
		}
	}
}
