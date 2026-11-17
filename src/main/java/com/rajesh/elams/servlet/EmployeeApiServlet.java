package com.rajesh.elams.servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.UserDao;
import com.rajesh.elams.dao.UserDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.AuditService;

@WebServlet(urlPatterns = {"/api/employee/get", "/api/employee/update"})
public class EmployeeApiServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private final EmployeeDao employeeDao = new EmployeeDaoImpl();
	private final UserDao userDao = new UserDaoImpl();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
		String role = session != null ? (String) session.getAttribute("role") : null;

		if (loggedUser == null || role == null || (!"admin".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role))) {
			response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Unauthorized access\"}");
			return;
		}

		String idStr = request.getParameter("id");
		if (idStr == null || idStr.isBlank()) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Employee ID is required\"}");
			return;
		}

		try {
			int empId = Integer.parseInt(idStr.trim());
			Employee emp = employeeDao.getEmployeeById(empId);
			if (emp == null) {
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				response.setContentType("application/json");
				response.getWriter().write("{\"error\":\"Employee not found\"}");
				return;
			}

			User userAccount = userDao.getUserByEmail(emp.getEmail());
			String accountRole = userAccount != null ? userAccount.getRole() : "Employee";

			response.setContentType("application/json; charset=UTF-8");
			PrintWriter out = response.getWriter();
			out.write("{");
			out.write("\"employee_id\":" + emp.getEmployee_id() + ",");
			out.write("\"employee_name\":\"" + escapeJson(emp.getEmployee_name()) + "\",");
			out.write("\"email\":\"" + escapeJson(emp.getEmail()) + "\",");
			out.write("\"phone\":" + emp.getPhone() + ",");
			out.write("\"department\":\"" + escapeJson(emp.getDepartment()) + "\",");
			out.write("\"designation\":\"" + escapeJson(emp.getDesignation()) + "\",");
			out.write("\"profile_photo\":\"" + escapeJson(emp.getProfile_photo()) + "\",");
			out.write("\"account_role\":\"" + escapeJson(accountRole) + "\"");
			out.write("}");
			out.flush();
		} catch (NumberFormatException e) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Invalid Employee ID\"}");
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
		String role = session != null ? (String) session.getAttribute("role") : null;

		if (loggedUser == null || role == null || (!"admin".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role))) {
			response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Unauthorized access\"}");
			return;
		}

		String idStr = request.getParameter("id");
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String phoneStr = request.getParameter("phone");
		String department = request.getParameter("department");
		String designation = request.getParameter("designation");
		String profilePhoto = request.getParameter("profilePhoto");
		String userRole = request.getParameter("userRole");

		if (idStr == null || idStr.isBlank()) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Missing Employee ID\"}");
			return;
		}

		try {
			int empId = Integer.parseInt(idStr.trim());
			Employee emp = employeeDao.getEmployeeById(empId);

			if (emp == null) {
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				response.setContentType("application/json");
				response.getWriter().write("{\"error\":\"Employee record not found\"}");
				return;
			}

			String oldEmail = emp.getEmail();
			String oldName = emp.getEmployee_name();
			String oldDept = emp.getDepartment();
			String oldDesig = emp.getDesignation();

			List<String> changedFields = new ArrayList<>();
			if (name != null && !name.isBlank() && !name.equals(oldName)) {
				emp.setEmployee_name(name.trim());
				changedFields.add("name");
			}
			if (email != null && !email.isBlank() && !email.equals(oldEmail)) {
				emp.setEmail(email.trim());
				changedFields.add("email");
			}
			if (phoneStr != null && !phoneStr.isBlank()) {
				String cleanPhone = phoneStr.replaceAll("[^0-9]", "");
				if (!cleanPhone.isEmpty()) {
					emp.setPhone(Long.parseLong(cleanPhone));
					changedFields.add("phone");
				}
			}
			if (department != null && !department.isBlank() && !department.equals(oldDept)) {
				emp.setDepartment(department.trim());
				changedFields.add("department");
			}
			if (designation != null && !designation.isBlank() && !designation.equals(oldDesig)) {
				emp.setDesignation(designation.trim());
				changedFields.add("designation");
			}
			if (profilePhoto != null) {
				emp.setProfile_photo(profilePhoto.trim());
				changedFields.add("profilePhoto");
			}

			boolean updated = employeeDao.updateEmployee(emp);

			if (updated) {
				if (userRole != null && !userRole.isBlank() || changedFields.contains("email")) {
					userDao.updateUserAccount(oldEmail, emp.getEmail(), userRole);
				}

				String actor = loggedUser != null ? loggedUser.getEmail() : "Admin";
				String detailsJson = "{\"empId\":" + empId + ",\"changedFields\":[" + toArrayJson(changedFields) + "],\"oldEmail\":\"" + escapeJson(oldEmail) + "\",\"newEmail\":\"" + escapeJson(emp.getEmail()) + "\"}";
				AuditService.logActionAsync(actor, "UPDATE_EMPLOYEE", "Employee Management", "EMP-" + empId, "Updated employee details for " + emp.getEmployee_name(), "INFO", detailsJson, request.getRemoteAddr());

				response.setContentType("application/json; charset=UTF-8");
				response.getWriter().write("{\"success\":true,\"message\":\"Employee updated successfully\"}");
			} else {
				response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
				response.setContentType("application/json");
				response.getWriter().write("{\"error\":\"Database update failed\"}");
			}

		} catch (Exception e) {
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Server error: " + escapeJson(e.getMessage()) + "\"}");
		}
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
