package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.UserDao;
import com.rajesh.elams.dao.UserDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

	private UserDao userDAO;
	private EmployeeDao employeeDAO;

	@Override
	public void init() {
		userDAO = new UserDaoImpl();
		employeeDAO = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.getRequestDispatcher("register.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String phone = request.getParameter("phone");
		String department = request.getParameter("department");
		String designation = request.getParameter("designation");
		String password = request.getParameter("password");
		String confirmPassword = request.getParameter("confirmPassword");

		if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty() || password == null
				|| password.isEmpty()) {

			request.setAttribute("errorMessage", "Please fill in all required fields.");
			request.getRequestDispatcher("register.jsp").forward(request, response);
			return;
		}

		if (!password.equals(confirmPassword)) {
			request.setAttribute("errorMessage", "Passwords do not match.");
			request.getRequestDispatcher("register.jsp").forward(request, response);
			return;
		}

		if (password.length() < 6) {
			request.setAttribute("errorMessage", "Password must be at least 6 characters long.");
			request.getRequestDispatcher("register.jsp").forward(request, response);
			return;
		}

		if (employeeDAO.getEmployeeByEmail(email) != null || userDAO.isEmailExists(email)) {
			request.setAttribute("errorMessage", "An account with this email already exists. Please sign in instead.");
			request.getRequestDispatcher("register.jsp").forward(request, response);
			return;
		}

		Employee employee = new Employee();
		employee.setEmployee_name(name.trim());
		employee.setEmail(email.trim());

		long phoneNum = 9999999999L;
		if (phone != null && !phone.trim().isEmpty()) {
			try {
				String cleanPhone = phone.replaceAll("[^0-9]", "");
				if (!cleanPhone.isEmpty()) {
					phoneNum = Long.parseLong(cleanPhone);
				}
			} catch (Exception ignored) {}
		}
		employee.setPhone(phoneNum);

		employee.setDepartment(department != null && !department.isBlank() ? department : "General");
		employee.setDesignation(designation != null && !designation.isBlank() ? designation : "Employee");

		employee = employeeDAO.addEmployee(employee);

		if (employee.getEmployee_id() <= 0) {
			
			request.setAttribute("errorMessage",
					"We couldn't save your details right now (database error). Please try again shortly.");
			request.getRequestDispatcher("register.jsp").forward(request, response);
			return;
		}

		User user = new User();
		user.setEmail(employee.getEmail());
		user.setPwd(password);
		user.setRole("employee");

		boolean userSaved = userDAO.addUser(user);

		if (!userSaved) {
			
			employeeDAO.deleteEmployee(employee.getEmployee_id());
			request.setAttribute("errorMessage",
					"We couldn't finish creating your login credentials (database error). Please try again.");
			request.getRequestDispatcher("register.jsp").forward(request, response);
			return;
		}

		com.rajesh.elams.service.AuditService.logAction(employee.getEmail(), "CREATE_EMPLOYEE", "Employee Management", "EMP-" + employee.getEmployee_id(), "Self-registered new employee: " + employee.getEmployee_name(), request.getRemoteAddr());
		com.rajesh.elams.service.AuditService.logAction(employee.getEmail(), "CREATE_USER", "User Management", "EMP-" + employee.getEmployee_id(), "Created user account for role: employee", request.getRemoteAddr());

		request.setAttribute("successMessage", "Account created successfully! Your Employee ID is #"
				+ employee.getEmployee_id() + " - please save it, then sign in below.");
		request.getRequestDispatcher("login.jsp").forward(request, response);
	}
}