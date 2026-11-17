package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.User;

public interface UserDao {
	public boolean addUser(User user);
	public User login(String email, String password);
	public List<User> getAllUsers();
	public User getUserByEmail(String email);
	public boolean deleteUser(int id);
	public boolean updatePassword(String email, String newPassword);
	public boolean updateUserAccount(String oldEmail, String newEmail, String newRole);
	public boolean isEmailExists(String email);
}