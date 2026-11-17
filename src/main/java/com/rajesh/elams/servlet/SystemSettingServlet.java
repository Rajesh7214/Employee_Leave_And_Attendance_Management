package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.rajesh.elams.model.User;
import com.rajesh.elams.service.AuditService;
import com.rajesh.elams.service.SystemSettingService;

@WebServlet(urlPatterns = {"/admin/settings", "/systemSettings"})
public class SystemSettingServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private final SystemSettingService settingService = new SystemSettingService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
		String role = session != null ? (String) session.getAttribute("role") : null;

		if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		Map<String, String> settings = settingService.getAllSettingsMap();
		request.setAttribute("settings", settings);

		request.getRequestDispatcher("/systemSettings.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
		String role = session != null ? (String) session.getAttribute("role") : null;

		if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		String companyName = request.getParameter("company_name");
		String workingStartTime = request.getParameter("working_start_time");
		String workingEndTime = request.getParameter("working_end_time");
		String maxBreaks = request.getParameter("max_breaks");
		String sessionTimeout = request.getParameter("session_timeout");

		Map<String, String> updatedSettings = new HashMap<>();
		if (companyName != null) updatedSettings.put("company_name", companyName.trim());
		if (workingStartTime != null) updatedSettings.put("working_start_time", workingStartTime.trim());
		if (workingEndTime != null) updatedSettings.put("working_end_time", workingEndTime.trim());
		if (maxBreaks != null) updatedSettings.put("max_breaks", maxBreaks.trim());
		if (sessionTimeout != null) updatedSettings.put("session_timeout", sessionTimeout.trim());

		boolean success = settingService.updateSettings(updatedSettings);

		String adminEmail = loggedUser.getEmail();
		String clientIp = request.getRemoteAddr();
		AuditService.logAction(adminEmail, "UPDATE_SETTINGS", "System Settings", "CFG-SYS", "Updated application settings", clientIp);

		if (success) {
			response.sendRedirect(request.getContextPath() + "/systemSettings?msg=success");
		} else {
			response.sendRedirect(request.getContextPath() + "/systemSettings?msg=error");
		}
	}
}
