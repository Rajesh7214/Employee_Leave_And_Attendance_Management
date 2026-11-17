package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.UserDao;
import com.rajesh.elams.dao.UserDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.AuditService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/updateEmployee")
public class UpdateEmployeeServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;
	private UserDao userDao;

	@Override
	public void init() throws ServletException {
		employeeDao = new EmployeeDaoImpl();
		userDao = new UserDaoImpl();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int employeeId;
		try {
			employeeId = Integer.parseInt(request.getParameter("id"));
		} catch (NumberFormatException e) {
			response.sendRedirect("viewEmployees");
			return;
		}

		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String phone = request.getParameter("phone");
		String department = request.getParameter("department");
		String designation = request.getParameter("designation");
		String profilePhoto = request.getParameter("profilePhoto");
		String userRole = request.getParameter("userRole");

		Employee employee = employeeDao.getEmployeeById(employeeId);

		if (employee == null) {
			response.sendRedirect("viewEmployees");
			return;
		}

		String oldEmail = employee.getEmail();
		String oldName = employee.getEmployee_name();
		String oldDept = employee.getDepartment();
		String oldDesig = employee.getDesignation();

		List<String> changedFields = new ArrayList<>();

		if (name != null && !name.isBlank() && !name.equals(oldName)) {
			employee.setEmployee_name(name.trim());
			changedFields.add("name");
		}
		if (email != null && !email.isBlank() && !email.equals(oldEmail)) {
			employee.setEmail(email.trim());
			changedFields.add("email");
		}

		try {
			String cleanPhone = phone != null ? phone.trim().replaceAll("[^0-9]", "") : "";
			if (!cleanPhone.isEmpty() && Long.parseLong(cleanPhone) != employee.getPhone()) {
				employee.setPhone(Long.parseLong(cleanPhone));
				changedFields.add("phone");
			}
		} catch (Exception e) {
			request.setAttribute("errorMessage", "Please enter a valid phone number.");
			request.setAttribute("employee", employee);
			request.getRequestDispatcher("editEmployee.jsp").forward(request, response);
			return;
		}

		if (profilePhoto != null) {
			employee.setProfile_photo(profilePhoto.trim());
			changedFields.add("profilePhoto");
		}

		if (department != null && !department.isBlank() && !department.equals(oldDept)) {
			employee.setDepartment(department.trim());
			changedFields.add("department");
		}
		if (designation != null && !designation.isBlank() && !designation.equals(oldDesig)) {
			employee.setDesignation(designation.trim());
			changedFields.add("designation");
		}

		boolean updated = employeeDao.updateEmployee(employee);

		if (!updated) {
			request.setAttribute("errorMessage", "We couldn't save your changes right now (database error).");
			request.setAttribute("employee", employee);
			request.getRequestDispatcher("editEmployee.jsp").forward(request, response);
			return;
		}

		// Synchronize corresponding User account email and role
		if ((userRole != null && !userRole.isBlank()) || changedFields.contains("email")) {
			userDao.updateUserAccount(oldEmail, employee.getEmail(), userRole);
		}

		HttpSession session = request.getSession(false);
		User actorUser = session != null ? (User) session.getAttribute("loggedUser") : null;
		String actor = actorUser != null ? actorUser.getEmail() : "Admin";

		String detailsJson = "{\"empId\":" + employeeId + ",\"changedFields\":[" + toArrayJson(changedFields) + "],\"oldEmail\":\"" + escapeJson(oldEmail) + "\",\"newEmail\":\"" + escapeJson(employee.getEmail()) + "\"}";
		AuditService.logActionAsync(actor, "UPDATE_EMPLOYEE", "Employee Management", "EMP-" + employeeId, "Updated employee details for: " + name, "INFO", detailsJson, request.getRemoteAddr());

		Employee refreshed = employeeDao.getEmployeeById(employeeId);

		request.setAttribute("employee", refreshed);
		request.setAttribute("successMessage", "Employee details & account role updated successfully!");
		request.getRequestDispatcher("editEmployee.jsp").forward(request, response);
	}

	private String escapeJson(String input) {
		if (input == null) return "";
		return input.replace("\\", "\\\\")
		            .replace("\"", "\\\"")
		            .replace("\n", "\\n")
		            .replace("\r", "\\r");
	}

	private String toArrayJson(List<String> items) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < items.size(); i++) {
			sb.append("\"").append(escapeJson(items.get(i))).append("\"");
			if (i < items.size() - 1) sb.append(",");
		}
		return sb.toString();
	}
}