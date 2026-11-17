package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.Employee;
import com.rajesh.elams.util.DbUtil;

public class EmployeeDaoImpl implements EmployeeDao {

	public EmployeeDaoImpl() {
		ensureEmployeesTableExists();
		checkAndAddProfilePhotoColumn();
		ensureAllUsersHaveEmployeeRecords();
	}

	private void ensureEmployeesTableExists() {
		String sql = "CREATE TABLE IF NOT EXISTS employees ("
				+ "employee_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "employee_name VARCHAR(100) NOT NULL, "
				+ "email VARCHAR(100) NOT NULL UNIQUE, "
				+ "phone BIGINT NULL, "
				+ "department VARCHAR(50) NULL, "
				+ "designation VARCHAR(50) NULL, "
				+ "profile_photo VARCHAR(255) NULL"
				+ ")";
		try (Connection conn = DbUtil.getConnection(); Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(sql);
		} catch (Exception e) {
			System.err.println("ensureEmployeesTableExists notice: " + e.getMessage());
		}
	}

	public void ensureAllUsersHaveEmployeeRecords() {
		String sql = "INSERT INTO employees (employee_name, email, phone, department, designation) "
				+ "SELECT "
				+ "  CASE WHEN u.email='admin@elams.com' THEN 'System Administrator' "
				+ "       WHEN u.email='hr@elams.com' THEN 'Sneha Sharma' "
				+ "       WHEN u.email='manager@elams.com' THEN 'Project Manager' "
				+ "       WHEN u.email='rajesh@elams.com' THEN 'Rajesh Kumar' "
				+ "       ELSE CONCAT(UPPER(SUBSTRING(SUBSTRING_INDEX(u.email, '@', 1), 1, 1)), LOWER(SUBSTRING(SUBSTRING_INDEX(u.email, '@', 1), 2))) END, "
				+ "  u.email, 9876543210, "
				+ "  CASE WHEN LOWER(u.role)='hr' THEN 'Human Resources' "
				+ "       WHEN LOWER(u.role)='admin' THEN 'Administration' "
				+ "       WHEN LOWER(u.role)='manager' THEN 'Engineering' "
				+ "       ELSE 'General' END, "
				+ "  CASE WHEN LOWER(u.role)='hr' THEN 'HR Manager' "
				+ "       WHEN LOWER(u.role)='admin' THEN 'System Admin' "
				+ "       WHEN LOWER(u.role)='manager' THEN 'Technical Manager' "
				+ "       ELSE 'Software Engineer' END "
				+ "FROM user u "
				+ "LEFT JOIN employees e ON u.email = e.email "
				+ "WHERE e.email IS NULL";
		try (Connection conn = DbUtil.getConnection(); Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(sql);
		} catch (Exception e) {
			System.err.println("ensureAllUsersHaveEmployeeRecords notice: " + e.getMessage());
		}
	}

	private void checkAndAddProfilePhotoColumn() {
		try (Connection conn = DbUtil.getConnection(); Statement stmt = conn.createStatement()) {
			try {
				stmt.executeUpdate("ALTER TABLE employees ADD COLUMN profile_photo VARCHAR(255) NULL");
			} catch (Exception ignored) {}
		} catch (Exception ignored) {}
	}

	@Override
	public Employee addEmployee(Employee employee) {

		String sql = "INSERT INTO employees(employee_name, email, phone, department, designation, profile_photo) VALUES(?,?,?,?,?,?)";

		try (Connection connection = DbUtil.getConnection();
				PreparedStatement ps = connection.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

			ps.setString(1, employee.getEmployee_name());
			ps.setString(2, employee.getEmail());
			ps.setLong(3, employee.getPhone());
			ps.setString(4, employee.getDepartment());
			ps.setString(5, employee.getDesignation());
			ps.setString(6, employee.getProfile_photo());

			int count = ps.executeUpdate();

			if (count > 0) {

				try (ResultSet keys = ps.getGeneratedKeys()) {
					if (keys.next()) {
						employee.setEmployee_id(keys.getInt(1));
					}
				}

				System.out.println("Employee added successfully with id=" + employee.getEmployee_id());
			}

		} catch (Exception e) {
			System.err.println("addEmployee FAILED for email=" + employee.getEmail() + " : " + e.getMessage());
			e.printStackTrace();
			employee.setEmployee_id(0);
		}

		return employee;
	}

	@Override
	public Employee getEmployeeById(int id) {

		Employee emp = null;

		String sql = "SELECT * FROM employees WHERE employee_id=?";

		try (Connection connection = DbUtil.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

			ps.setInt(1, id);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				emp = extractEmployee(rs);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return emp;
	}

	@Override
	public Employee getEmployeeByEmail(String email) {

		Employee emp = null;

		String sql = "SELECT * FROM employees WHERE email=?";

		try (Connection connection = DbUtil.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {

			ps.setString(1, email);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				emp = extractEmployee(rs);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return emp;
	}

	@Override
	public List<Employee> getAllEmployees() {
		ensureAllUsersHaveEmployeeRecords();
		List<Employee> list = new ArrayList<>();
		String sql = "SELECT * FROM employees ORDER BY employee_id DESC";

		try (Connection connection = DbUtil.getConnection();
				PreparedStatement ps = connection.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				list.add(extractEmployee(rs));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public boolean updateEmployee(Employee employee) {

		String sql = "UPDATE employees SET employee_name=?, email=?, phone=?, department=?, designation=?, profile_photo=? WHERE employee_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, employee.getEmployee_name());
			ps.setString(2, employee.getEmail());
			ps.setLong(3, employee.getPhone());
			ps.setString(4, employee.getDepartment());
			ps.setString(5, employee.getDesignation());
			ps.setString(6, employee.getProfile_photo());
			ps.setInt(7, employee.getEmployee_id());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	private Employee extractEmployee(ResultSet rs) throws Exception {
		Employee emp = new Employee();
		emp.setEmployee_id(rs.getInt("employee_id"));
		emp.setEmployee_name(rs.getString("employee_name"));
		emp.setEmail(rs.getString("email"));
		emp.setPhone(rs.getLong("phone"));
		emp.setDepartment(rs.getString("department"));
		emp.setDesignation(rs.getString("designation"));
		try {
			emp.setProfile_photo(rs.getString("profile_photo"));
		} catch (Exception ignored) {}
		return emp;
	}

	@Override
	public boolean deleteEmployee(int id) {

		String sql = "DELETE FROM employees WHERE employee_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, id);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public List<Employee> getAdminsOnly() {
		List<Employee> list = new ArrayList<>();
		String sql = "SELECT e.* FROM employees e JOIN user u ON e.email = u.email WHERE u.role = 'admin'";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Employee emp = new Employee();
				emp.setEmployee_id(rs.getInt("employee_id"));
				emp.setEmployee_name(rs.getString("employee_name"));
				emp.setEmail(rs.getString("email"));
				emp.setPhone(rs.getLong("phone"));
				emp.setDepartment(rs.getString("department"));
				emp.setDesignation(rs.getString("designation"));
				list.add(emp);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list.isEmpty() ? getAllEmployees() : list;
	}

	@Override
	public List<Employee> getManagersOnly() {
		List<Employee> list = new ArrayList<>();
		String sql = "SELECT e.* FROM employees e JOIN user u ON e.email = u.email WHERE u.role = 'manager'";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				Employee emp = new Employee();
				emp.setEmployee_id(rs.getInt("employee_id"));
				emp.setEmployee_name(rs.getString("employee_name"));
				emp.setEmail(rs.getString("email"));
				emp.setPhone(rs.getLong("phone"));
				emp.setDepartment(rs.getString("department"));
				emp.setDesignation(rs.getString("designation"));
				list.add(emp);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list.isEmpty() ? getAllEmployees() : list;
	}

	@Override
	public List<Employee> getManagers() {
		return getManagersOnly();
	}

}