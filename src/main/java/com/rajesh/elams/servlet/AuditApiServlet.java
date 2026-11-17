package com.rajesh.elams.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.rajesh.elams.model.AuditLog;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.AuditService;

@WebServlet("/api/auditLogs")
public class AuditApiServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private final AuditService auditService = new AuditService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		User loggedUser = session != null ? (User) session.getAttribute("loggedUser") : null;
		String role = session != null ? (String) session.getAttribute("role") : null;

		if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
			response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			response.setContentType("application/json");
			response.getWriter().write("{\"error\":\"Unauthorized access\"}");
			return;
		}

		String idStr = request.getParameter("id");
		if (idStr != null && !idStr.isBlank()) {
			try {
				int logId = Integer.parseInt(idStr);
				AuditLog log = auditService.getAuditLogById(logId);
				response.setContentType("application/json; charset=UTF-8");
				if (log != null) {
					response.getWriter().write(toJsonObject(log));
				} else {
					response.setStatus(HttpServletResponse.SC_NOT_FOUND);
					response.getWriter().write("{\"error\":\"Log entry not found\"}");
				}
				return;
			} catch (NumberFormatException ignored) {}
		}

		String keyword = request.getParameter("search");
		String module = request.getParameter("module");
		String action = request.getParameter("action");
		String severity = request.getParameter("severity");
		String startDate = request.getParameter("startDate");
		String endDate = request.getParameter("endDate");

		List<AuditLog> logs = auditService.getAuditLogsAdvanced(keyword, module, action, severity, startDate, endDate);

		response.setContentType("application/json; charset=UTF-8");
		PrintWriter out = response.getWriter();
		out.write("[");
		for (int i = 0; i < logs.size(); i++) {
			out.write(toJsonObject(logs.get(i)));
			if (i < logs.size() - 1) {
				out.write(",");
			}
		}
		out.write("]");
		out.flush();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

	private String toJsonObject(AuditLog log) {
		StringBuilder sb = new StringBuilder();
		sb.append("{");
		sb.append("\"logId\":").append(log.getLogId()).append(",");
		sb.append("\"username\":\"").append(escapeJson(log.getUsername())).append("\",");
		sb.append("\"action\":\"").append(escapeJson(log.getAction())).append("\",");
		sb.append("\"module\":\"").append(escapeJson(log.getModule())).append("\",");
		sb.append("\"recordId\":\"").append(escapeJson(log.getRecordId())).append("\",");
		sb.append("\"description\":\"").append(escapeJson(log.getDescription())).append("\",");
		sb.append("\"severity\":\"").append(escapeJson(log.getSeverity())).append("\",");
		sb.append("\"details\":").append(log.getDetails() != null && !log.getDetails().isBlank() ? log.getDetails() : "{}").append(",");
		sb.append("\"ipAddress\":\"").append(escapeJson(log.getIpAddress())).append("\",");
		sb.append("\"formattedDate\":\"").append(escapeJson(log.getFormattedDate())).append("\"");
		sb.append("}");
		return sb.toString();
	}

	private String escapeJson(String input) {
		if (input == null) return "";
		return input.replace("\\", "\\\\")
		            .replace("\"", "\\\"")
		            .replace("\b", "\\b")
		            .replace("\f", "\\f")
		            .replace("\n", "\\n")
		            .replace("\r", "\\r")
		            .replace("\t", "\\t");
	}
}
