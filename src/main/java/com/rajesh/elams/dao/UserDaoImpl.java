package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.User;
import com.rajesh.elams.util.DbUtil;
import com.rajesh.elams.util.PasswordUtil;

public class UserDaoImpl implements UserDao {

	public UserDaoImpl() {
		ensureUserTableExists();
		ensureDefaultUsersExist();
	}

	private void ensureUserTableExists() {
		String sql = "CREATE TABLE IF NOT EXISTS user ("
				+ "id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "email VARCHAR(100) NOT NULL UNIQUE, "
				+ "password VARCHAR(255) NOT NULL, "
				+ "role VARCHAR(20) NOT NULL"
				+ ")";
		try (Connection con = DbUtil.getConnection(); java.sql.Statement stmt = con.createStatement()) {
			stmt.executeUpdate(sql);
		} catch (Exception e) {
			System.err.println("ensureUserTableExists notice: " + e.getMessage());
		}
	}

	private void ensureDefaultUsersExist() {
		String[] defaultUsers = {
			"INSERT INTO user (email, password, role) VALUES ('admin@elams.com', 'admin123', 'Admin') ON DUPLICATE KEY UPDATE role='Admin'",
			"INSERT INTO user (email, password, role) VALUES ('hr@elams.com', 'hr123', 'HR') ON DUPLICATE KEY UPDATE role='HR'",
			"INSERT INTO user (email, password, role) VALUES ('manager@elams.com', 'manager123', 'Manager') ON DUPLICATE KEY UPDATE role='Manager'",
			"INSERT INTO user (email, password, role) VALUES ('rajesh@elams.com', 'emp123', 'Employee') ON DUPLICATE KEY UPDATE role='Employee'"
		};

		try (Connection con = DbUtil.getConnection(); java.sql.Statement stmt = con.createStatement()) {
			for (String sql : defaultUsers) {
				try {
					stmt.executeUpdate(sql);
				} catch (Exception ignored) {}
			}
		} catch (Exception e) {
			System.err.println("ensureDefaultUsersExist notice: " + e.getMessage());
		}
	}

	@Override
	public boolean addUser(User user) {

		String sql = "INSERT INTO user(email,password,role) VALUES(?,?,?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, user.getEmail() != null ? user.getEmail().trim() : "");
			ps.setString(2, PasswordUtil.hashPassword(user.getPwd()));
			ps.setString(3, user.getRole());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			System.err.println("addUser FAILED for email=" + user.getEmail() + " : " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public User login(String email, String password) {

		User user = null;

		if (email == null || password == null) {
			return null;
		}

		String cleanEmail = email.trim();
		String cleanPassword = password.trim();

		String sql = "SELECT * FROM user WHERE LOWER(email)=LOWER(?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, cleanEmail);

			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					String storedHash = rs.getString("password");
					if (PasswordUtil.checkPassword(cleanPassword, storedHash)) {
						user = new User();
						user.setId(rs.getInt("id"));
						user.setEmail(rs.getString("email"));
						user.setPwd(storedHash);
						user.setRole(rs.getString("role"));
					}
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return user;
	}

	@Override
	public List<User> getAllUsers() {

		List<User> users = new ArrayList<>();

		String sql = "SELECT * FROM user";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				User user = new User(rs.getInt("id"), rs.getString("email"), rs.getString("password"),
						rs.getString("role"));

				users.add(user);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return users;
	}

	@Override
	public boolean deleteUser(int id) {

		String sql = "DELETE FROM user WHERE id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, id);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean updatePassword(String email, String newPassword) {
		String sql = "UPDATE user SET password=? WHERE email=?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, PasswordUtil.hashPassword(newPassword));
			ps.setString(2, email);

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("updatePassword FAILED for email=" + email + " : " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public User getUserByEmail(String email) {
		String sql = "SELECT * FROM user WHERE email=?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, email);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return new User(rs.getInt("id"), rs.getString("email"), rs.getString("password"), rs.getString("role"));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public boolean updateUserAccount(String oldEmail, String newEmail, String newRole) {
		if (oldEmail == null || oldEmail.isBlank()) return false;
		StringBuilder sql = new StringBuilder("UPDATE user SET ");
		List<Object> params = new ArrayList<>();

		boolean hasNewEmail = newEmail != null && !newEmail.isBlank();
		boolean hasNewRole = newRole != null && !newRole.isBlank();

		if (hasNewEmail && hasNewRole) {
			sql.append("email=?, role=? ");
			params.add(newEmail.trim());
			params.add(newRole.trim());
		} else if (hasNewEmail) {
			sql.append("email=? ");
			params.add(newEmail.trim());
		} else if (hasNewRole) {
			sql.append("role=? ");
			params.add(newRole.trim());
		} else {
			return true;
		}

		sql.append("WHERE email=?");
		params.add(oldEmail.trim());

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++) {
				ps.setObject(i + 1, params.get(i));
			}
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("updateUserAccount error: " + e.getMessage());
			e.printStackTrace();
			return false;
		}
	}

	@Override
	public boolean isEmailExists(String email) {
		String sql = "SELECT id FROM user WHERE email=?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, email);

			try (ResultSet rs = ps.executeQuery()) {
				return rs.next();
			}
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}