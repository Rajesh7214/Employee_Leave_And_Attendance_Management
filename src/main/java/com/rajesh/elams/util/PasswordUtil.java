package com.rajesh.elams.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

	private static final int WORK_FACTOR = 12;

	public static String hashPassword(String plainPassword) {
		return BCrypt.hashpw(plainPassword, BCrypt.gensalt(WORK_FACTOR));
	}

	public static boolean checkPassword(String plainPassword, String storedHash) {
		if (plainPassword == null || storedHash == null) {
			return false;
		}
		if (!isBcryptHash(storedHash)) {
			return plainPassword.equals(storedHash);
		}
		try {
			return BCrypt.checkpw(plainPassword, storedHash);
		} catch (IllegalArgumentException e) {
			return plainPassword.equals(storedHash);
		}
	}

	private static boolean isBcryptHash(String value) {
		return value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$");
	}
}
