package com.rajesh.elams.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class AuthFilter implements Filter {

	private static final String[] PUBLIC_PATHS = {
			"/", "/index.jsp", "/login", "/login.jsp", "/register",
			"/register.jsp", "/forgotPassword", "/forgotPassword.jsp", "/css/", "/js/", "/images/", "/assets/", "/404.jsp", "/500.jsp"
	};

	private static final String[] ADMIN_ONLY_PATHS = {
			"/adminDashboard", "/adminDashboardServlet", "/addEmployee", "/addEmployee.jsp",
			"/admin/audit", "/auditLogs", "/auditLogs.jsp", "/exportAudit", "/admin/settings", "/systemSettings", "/systemSettings.jsp"
	};

	private static final String[] ADMIN_HR_PATHS = {
			"/hrDashboard", "/hrDashboardServlet",
			"/updateEmployee", "/deleteEmployee", "/editEmployee",
			"/viewEmployeesServlet", "/viewEmployees", "/employeeListServlet", "/employeeList",
			"/payrollDashboard", "/manageSalary", "/processPayroll", "/payrollReport", "/exportPayroll"
	};

	private static final String[] MANAGER_ADMIN_PATHS = {
			"/managerDashboard", "/managerDashboardServlet", "/leaveRequests", "/approveLeave", "/rejectLeave",
			"/sendNotification", "/manageMeetingRooms", "/editMeetingRooms", "/taskReport", "/meetingReports", "/teamPayroll"
	};

	private static final String[] ADMIN_MANAGER_CREATE_EDIT_PATHS = {
			"/createTask", "/editTask", "/deleteTask", "/assignTask", "/updateTask",
			"/scheduleMeeting", "/editMeeting", "/deleteMeeting", "/updateMeeting"
	};

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {}

	@Override
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) res;

		String path = request.getRequestURI().substring(request.getContextPath().length());

		if (isPublic(path)) {
			chain.doFilter(req, res);
			return;
		}

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		String role = (String) session.getAttribute("role");
		if (role == null) role = "employee";

		// Restrict Admin-only paths
		if (isAdminOnly(path) && !"admin".equalsIgnoreCase(role)) {
			if ("hr".equalsIgnoreCase(role)) {
				response.sendRedirect(request.getContextPath() + "/hrDashboard");
			} else if ("manager".equalsIgnoreCase(role)) {
				response.sendRedirect(request.getContextPath() + "/managerDashboard");
			} else {
				response.sendRedirect(request.getContextPath() + "/employeeDashboardServlet");
			}
			return;
		}

		// Restrict Admin / HR paths
		if (isAdminOrHrOnly(path) && !"admin".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/employeeDashboardServlet");
			return;
		}

		// Restrict Task & Meeting Creation/Editing/Deletion to Admin & Manager ONLY (Excluding HR)
		if (isAdminManagerCreateEditOnly(path) && !"admin".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role)) {
			if ("hr".equalsIgnoreCase(role)) {
				if (path.toLowerCase().contains("task")) {
					response.sendRedirect(request.getContextPath() + "/viewTasksServlet");
				} else {
					response.sendRedirect(request.getContextPath() + "/viewMeetings");
				}
			} else {
				response.sendRedirect(request.getContextPath() + "/employeeDashboardServlet");
			}
			return;
		}

		// Restrict Manager / Admin / HR paths
		if (isManagerOrAdminOnly(path) && !"admin".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/employeeDashboardServlet");
			return;
		}

		chain.doFilter(req, res);
	}

	private boolean isPublic(String path) {
		if (path == null || path.isEmpty() || "/".equals(path)) {
			return true;
		}
		for (String p : PUBLIC_PATHS) {
			if ("/".equals(p)) continue;
			if (p.endsWith("/")) {
				if (path.startsWith(p)) {
					return true;
				}
			} else {
				if (path.equalsIgnoreCase(p)) {
					return true;
				}
			}
		}
		return false;
	}

	private boolean isAdminOnly(String path) {
		for (String p : ADMIN_ONLY_PATHS) {
			if (path.startsWith(p)) {
				return true;
			}
		}
		return false;
	}

	private boolean isAdminOrHrOnly(String path) {
		for (String p : ADMIN_HR_PATHS) {
			if (path.startsWith(p)) {
				return true;
			}
		}
		return false;
	}

	private boolean isAdminManagerCreateEditOnly(String path) {
		if (path == null) return false;
		if (path.equalsIgnoreCase("/updateTaskStatus") || path.equalsIgnoreCase("/updateTaskStatusServlet")) {
			return false;
		}
		for (String p : ADMIN_MANAGER_CREATE_EDIT_PATHS) {
			if (path.equalsIgnoreCase(p) || path.equalsIgnoreCase(p + ".jsp") || path.equalsIgnoreCase(p + "Servlet")) {
				return true;
			}
		}
		return false;
	}

	private boolean isManagerOrAdminOnly(String path) {
		for (String p : MANAGER_ADMIN_PATHS) {
			if (path.startsWith(p)) {
				return true;
			}
		}
		return false;
	}

	@Override
	public void destroy() {}
}