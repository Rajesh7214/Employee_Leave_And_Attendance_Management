package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.Employee;

public interface EmployeeDao {
	public Employee addEmployee(Employee employee);

	public Employee getEmployeeById(int id);

	public List<Employee> getAllEmployees();

	public boolean updateEmployee(Employee employee);

	public boolean deleteEmployee(int id);

	public Employee getEmployeeByEmail(String email);

	public List<Employee> getAdminsOnly();

	public List<Employee> getManagersOnly();

	public List<Employee> getManagers();

	public void ensureAllUsersHaveEmployeeRecords();
}