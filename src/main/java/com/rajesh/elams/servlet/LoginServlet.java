package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import com.rajesh.elams.dao.AttendanceDao;
import com.rajesh.elams.dao.AttendanceDaoImpl;
import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.UserDao;
import com.rajesh.elams.dao.UserDaoImpl;
import com.rajesh.elams.model.Attendance;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private UserDao userDao;
	private EmployeeDao employeeDao;
	private AttendanceDao attendanceDao;

	@Override
	public void init() throws ServletException {
		userDao = new UserDaoImpl();
		employeeDao = new EmployeeDaoImpl();
		attendanceDao = new AttendanceDaoImpl();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String email = request.getParameter("email");
		String password = request.getParameter("password");

		User user = userDao.login(email, password);

		if (user == null) {
			com.rajesh.elams.service.AuditService.logLogin(email, "FAILED", request.getRemoteAddr(), request.getHeader("User-Agent"));
			request.setAttribute("errorMessage", "Invalid Email or Password");
			request.getRequestDispatcher("login.jsp").forward(request, response);
			return;
		}

		// Log successful login
		int loginLogId = com.rajesh.elams.service.AuditService.logLogin(user.getEmail(), "SUCCESS", request.getRemoteAddr(), request.getHeader("User-Agent"));

		HttpSession oldSession = request.getSession(false);
		if (oldSession != null) {
			oldSession.invalidate();
		}

		HttpSession session = request.getSession(true);

		session.setAttribute("loggedUser", user);
		session.setAttribute("role", user.getRole());

		// Store employee details
		Employee employee = null;
		try {
			employee = employeeDao.getEmployeeByEmail(user.getEmail());

			if (employee == null) {
				employee = new Employee();
				String name = user.getEmail() != null ? user.getEmail().split("@")[0] : "User";
				name = Character.toUpperCase(name.charAt(0)) + name.substring(1);
				employee.setEmployee_name(name);
				employee.setEmail(user.getEmail());
				employee.setPhone(9999999999L);
				String userRole = user.getRole() != null ? user.getRole() : "employee";
				employee.setDesignation(Character.toUpperCase(userRole.charAt(0)) + userRole.substring(1));
				employee.setDepartment("general".equalsIgnoreCase(userRole) || "employee".equalsIgnoreCase(userRole) ? "General" : "Management");
				employee = employeeDao.addEmployee(employee);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (employee != null && employee.getEmployee_id() > 0) {
			session.setAttribute("employee", employee);
			session.setAttribute("employeeId", employee.getEmployee_id());
		}

		// Dispatch Security Login Alert Notification (Scenario 10.14)
		try {
			String userAgent = request.getHeader("User-Agent");
			String browser = "Browser";
			if (userAgent != null) {
				if (userAgent.contains("Edg")) browser = "Microsoft Edge";
				else if (userAgent.contains("Chrome")) browser = "Google Chrome";
				else if (userAgent.contains("Safari")) browser = "Safari";
				else if (userAgent.contains("Firefox")) browser = "Mozilla Firefox";

				if (userAgent.contains("Windows")) browser += " on Windows";
				else if (userAgent.contains("Mac")) browser += " on macOS";
				else if (userAgent.contains("Android")) browser += " on Android";
				else if (userAgent.contains("iPhone")) browser += " on iOS";
			}
			String location = request.getRemoteAddr();
			if (location == null || "0:0:0:0:0:0:0:1".equals(location) || "127.0.0.1".equals(location)) {
				location = "Office Network";
			}
			com.rajesh.elams.service.NotificationService notifService = new com.rajesh.elams.service.NotificationService();
			notifService.notifyLoginAlert(user.getId(), browser, location);
		} catch (Exception ignored) {}

		// Redirect based on role
		if ("admin".equalsIgnoreCase(user.getRole())) {

			response.sendRedirect("adminDashboardServlet");

		} else if ("hr".equalsIgnoreCase(user.getRole())) {

			response.sendRedirect("hrDashboard");

		} else if ("manager".equalsIgnoreCase(user.getRole())) {

			response.sendRedirect("managerDashboard");

		} else if ("employee".equalsIgnoreCase(user.getRole())) {

			response.sendRedirect("employeeDashboardServlet");

		} else {

			session.invalidate();

			request.setAttribute("errorMessage", "Invalid User Role");
			request.getRequestDispatcher("login.jsp").forward(request, response);
		}
	}

	private void markCheckInIfNeeded(Employee employee) {

		Date today = Date.valueOf(LocalDate.now());

		List<Attendance> records = attendanceDao.getAttendanceByEmployee(employee.getEmployee_id());

		boolean alreadyMarked = false;
		for (Attendance a : records) {
			if (a.getAttendance_date() != null && a.getAttendance_date().toString().equals(today.toString())) {
				alreadyMarked = true;
				break;
			}
		}

		if (!alreadyMarked) {

			Attendance attendance = new Attendance();
			attendance.setEmployee_id(employee.getEmployee_id());
			attendance.setAttendance_date(today);
			attendance.setCheck_in_time(Time.valueOf(LocalTime.now()));
			attendance.setCheck_out_time(null);
			// status is recalculated by AttendanceDaoImpl.markAttendance() based on time
			attendance.setStatus("Present");

			attendanceDao.markAttendance(attendance);
		}
	}
}