package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.rajesh.elams.model.AuditLog;
import com.rajesh.elams.model.LoginLog;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.AuditService;

@WebServlet(urlPatterns = {"/admin/audit", "/auditLogs"})
public class AuditServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private final AuditService auditService = new AuditService();

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

		String purgeDaysStr = request.getParameter("purgeDays");
		if (purgeDaysStr != null && !purgeDaysStr.isBlank()) {
			try {
				int days = Integer.parseInt(purgeDaysStr);
				int purged = auditService.purgeAuditLogsOlderThan(days);
				AuditService.logAction(loggedUser.getEmail(), "PURGE_AUDIT_LOGS", "System Settings", "CFG-AUDIT", "Purged audit logs older than " + days + " days (" + purged + " records removed)", "SECURITY", "{\"days\":" + days + ",\"purged\":" + purged + "}", request.getRemoteAddr());
				request.setAttribute("purgeMessage", "Successfully purged " + purged + " audit log entries older than " + days + " days.");
			} catch (Exception e) {
				request.setAttribute("purgeError", "Failed to purge audit logs: " + e.getMessage());
			}
		}

		String searchKeyword = request.getParameter("search");
		String selectedModule = request.getParameter("module");
		String selectedAction = request.getParameter("action");
		String selectedSeverity = request.getParameter("severity");
		String dateStr = request.getParameter("date");
		String startDate = request.getParameter("startDate");
		String endDate = request.getParameter("endDate");
		String tab = request.getParameter("tab");

		if (selectedModule == null) selectedModule = "All";
		if (selectedAction == null) selectedAction = "All";
		if (selectedSeverity == null) selectedSeverity = "All";
		if (tab == null || tab.isBlank()) tab = "audit";

		if ((startDate == null || startDate.isBlank()) && dateStr != null) startDate = dateStr;
		if ((endDate == null || endDate.isBlank()) && dateStr != null) endDate = dateStr;

		List<AuditLog> auditLogs = auditService.getAuditLogsAdvanced(searchKeyword, selectedModule, selectedAction, selectedSeverity, startDate, endDate);
		List<LoginLog> loginLogs = auditService.getRecentLoginLogs(150);

		int totalAuditCount = auditService.getTotalAuditLogsCount();
		int todayAuditCount = auditService.getTodayAuditLogsCount();
		int totalLoginCount = auditService.getTotalLoginCount();
		int todayLoginCount = auditService.getTodayLoginCount();

		request.setAttribute("auditLogs", auditLogs);
		request.setAttribute("loginLogs", loginLogs);
		request.setAttribute("searchKeyword", searchKeyword != null ? searchKeyword : "");
		request.setAttribute("selectedModule", selectedModule);
		request.setAttribute("selectedAction", selectedAction);
		request.setAttribute("selectedSeverity", selectedSeverity);
		request.setAttribute("selectedDate", dateStr != null ? dateStr : "");
		request.setAttribute("startDate", startDate != null ? startDate : "");
		request.setAttribute("endDate", endDate != null ? endDate : "");
		request.setAttribute("activeTab", tab);

		request.setAttribute("totalAuditCount", totalAuditCount);
		request.setAttribute("todayAuditCount", todayAuditCount);
		request.setAttribute("totalLoginCount", totalLoginCount);
		request.setAttribute("todayLoginCount", todayLoginCount);

		request.getRequestDispatcher("/auditLogs.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
