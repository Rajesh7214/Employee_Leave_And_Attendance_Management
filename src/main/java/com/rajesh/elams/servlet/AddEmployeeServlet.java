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
import jakarta.servlet.http.HttpSession;

@WebServlet("/addEmployee")
public class AddEmployeeServlet extends HttpServlet {

	private static final String DEFAULT_PASSWORD = "Welcome@123";

	private EmployeeDao employeeDAO;
	private UserDao userDAO;

	public void init() {
		employeeDAO = new EmployeeDaoImpl();
		userDAO = new UserDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		String loggedRole = session != null ? (String) session.getAttribute("role") : null;
		if (loggedRole == null && session != null) {
			User user = (User) session.getAttribute("loggedUser");
			if (user != null) {
				loggedRole = user.getRole();
			}
		}

		if (!"admin".equalsIgnoreCase(loggedRole)) {
			response.sendRedirect(request.getContextPath() + "/viewEmployeesServlet");
			return;
		}

		response.sendRedirect(request.getContextPath() + "/addEmployee.jsp");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String loggedRole = session != null ? (String) session.getAttribute("role") : null;
		if (loggedRole == null && session != null) {
			User user = (User) session.getAttribute("loggedUser");
			if (user != null) {
				loggedRole = user.getRole();
			}
		}

		if (!"admin".equalsIgnoreCase(loggedRole)) {
			response.sendRedirect(request.getContextPath() + "/viewEmployeesServlet");
			return;
		}

		Employee employee = new Employee();

		employee.setEmployee_name(request.getParameter("name"));

		String email = request.getParameter("email");
		employee.setEmail(email != null ? email.trim() : "");
		employee.setPhone(Long.parseLong(request.getParameter("phone").trim()));
		employee.setDepartment(request.getParameter("department"));
		employee.setDesignation(request.getParameter("designation"));

		String profilePhoto = request.getParameter("profilePhoto");
		if (profilePhoto != null && !profilePhoto.isBlank()) {
			employee.setProfile_photo(profilePhoto.trim());
		}

		if (employeeDAO.getEmployeeByEmail(employee.getEmail()) == null) {
			employeeDAO.addEmployee(employee);
		}

		String role = request.getParameter("role");
		if (role == null || role.isBlank()) {
			role = "employee";
		}

		Employee newlyAdded = employeeDAO.getEmployeeByEmail(employee.getEmail());

		if (!userDAO.isEmailExists(employee.getEmail())) {
			User user = new User();
			user.setEmail(employee.getEmail());
			user.setPwd(DEFAULT_PASSWORD);
			user.setRole(role.toLowerCase().trim());
			userDAO.addUser(user);
			System.out.println("New login created for " + employee.getEmail() + " [Role: " + role + "] with default password: " + DEFAULT_PASSWORD);
			
			String actor = session != null && session.getAttribute("loggedUser") != null ? ((User) session.getAttribute("loggedUser")).getEmail() : "Admin";
			String clientIp = request.getRemoteAddr();
			String recId = newlyAdded != null ? "EMP-" + newlyAdded.getEmployee_id() : employee.getEmail();
			
			com.rajesh.elams.service.AuditService.logAction(actor, "CREATE_EMPLOYEE", "Employee Management", recId, "Added new employee: " + employee.getEmployee_name() + " (" + employee.getEmail() + ")", clientIp);
			com.rajesh.elams.service.AuditService.logAction(actor, "CREATE_USER", "User Management", recId, "Created user account for role: " + role, clientIp);

			// Automated Welcome Notification (In-App + Email + SMS)
			try {
				if (newlyAdded != null) {
					// Auto-provision default SalaryStructure package
					com.rajesh.elams.dao.SalaryStructureDao ssDao = new com.rajesh.elams.dao.SalaryStructureDaoImpl();
					if (ssDao.getSalaryStructureByEmployeeId(newlyAdded.getEmployee_id()) == null) {
						com.rajesh.elams.model.SalaryStructure defaultSs = new com.rajesh.elams.model.SalaryStructure();
						defaultSs.setEmployeeId(newlyAdded.getEmployee_id());
						ssDao.saveSalaryStructure(defaultSs);
					}

					com.rajesh.elams.service.NotificationService notificationService = new com.rajesh.elams.service.NotificationService();
					com.rajesh.elams.model.Notification welcomeNotif = new com.rajesh.elams.model.Notification(
						1, 
						newlyAdded.getEmployee_id(), 
						"🎉 Welcome to SmartOffice ELAMS!", 
						"Hello " + newlyAdded.getEmployee_name() + ",\nYour SmartOffice employee account has been created successfully.\n\nLogin Email:\n" + newlyAdded.getEmail() + "\n\nDefault Password:\n" + DEFAULT_PASSWORD + "\n\nPlease login and update your password.", 
						com.rajesh.elams.model.Notification.CAT_ANNOUNCEMENT, 
						com.rajesh.elams.model.Notification.PRIORITY_HIGH
					);
					notificationService.createNotification(welcomeNotif);
				}
			} catch (Exception e) {
				System.err.println("Error sending welcome notification or salary provisioning: " + e.getMessage());
			}
		}

		response.sendRedirect("viewEmployeesServlet");
	}
}