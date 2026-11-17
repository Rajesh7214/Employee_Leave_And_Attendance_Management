package com.rajesh.elams.servlet;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/updateProfile")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 5,
		maxFileSize = 1024 * 1024 * 10, 
		maxRequestSize = 1024 * 1024 * 50) 
public class UpdateProfileServlet extends HttpServlet {

	private EmployeeDao employeeDao;

	@Override
	public void init() {
		employeeDao = new EmployeeDaoImpl();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		Employee employee = (Employee) session.getAttribute("employee");
		User user = (User) session.getAttribute("loggedUser");

		if (employee == null && user != null) {
			employee = employeeDao.getEmployeeByEmail(user.getEmail());
		}

		if (employee == null) {
			response.sendRedirect("profile.jsp?error=not_found");
			return;
		}

		String name = request.getParameter("employee_name");
		String phoneStr = request.getParameter("phone");
		String department = request.getParameter("department");
		String designation = request.getParameter("designation");

		if (name != null && !name.trim().isEmpty()) {
			employee.setEmployee_name(name.trim());
		}

		if (phoneStr != null && !phoneStr.trim().isEmpty()) {
			try {
				long phone = Long.parseLong(phoneStr.trim().replaceAll("[^0-9]", ""));
				employee.setPhone(phone);
			} catch (NumberFormatException ignored) {}
		}

		if (department != null && !department.trim().isEmpty()) {
			employee.setDepartment(department.trim());
		}

		if (designation != null && !designation.trim().isEmpty()) {
			employee.setDesignation(designation.trim());
		}

		String removePhoto = request.getParameter("remove_photo");
		if ("true".equalsIgnoreCase(removePhoto)) {
			employee.setProfile_photo(null);
		} else {
			// Handle File Upload if provided
			try {
				Part filePart = request.getPart("profile_photo_file");
				if (filePart != null && filePart.getSize() > 0) {
					String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
					String uploadDir = getServletContext().getRealPath("") + File.separator + "uploads";
					File uploadFolder = new File(uploadDir);
					if (!uploadFolder.exists()) {
						uploadFolder.mkdirs();
					}
					String newFileName = "profile_" + employee.getEmployee_id() + "_" + System.currentTimeMillis()
							+ getExtension(fileName);
					String savePath = uploadDir + File.separator + newFileName;
					filePart.write(savePath);
					employee.setProfile_photo("uploads/" + newFileName);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		boolean updated = employeeDao.updateEmployee(employee);
		if (updated) {
			session.setAttribute("employee", employee);
			String actorEmail = user != null ? user.getEmail() : employee.getEmail();
			com.rajesh.elams.service.AuditService.logAction(actorEmail, "UPDATE_EMPLOYEE", "Employee Management", "EMP-" + employee.getEmployee_id(), "Updated profile information for: " + employee.getEmployee_name(), request.getRemoteAddr());
			com.rajesh.elams.service.AuditService.logAction(actorEmail, "UPDATE_USER", "User Management", "EMP-" + employee.getEmployee_id(), "Updated user account profile details", request.getRemoteAddr());
			response.sendRedirect("profile.jsp?updated=true");
		} else {
			response.sendRedirect("profile.jsp?error=update_failed");
		}
	}

	private String getExtension(String fileName) {
		int i = fileName.lastIndexOf('.');
		return i > 0 ? fileName.substring(i) : ".jpg";
	}
}
