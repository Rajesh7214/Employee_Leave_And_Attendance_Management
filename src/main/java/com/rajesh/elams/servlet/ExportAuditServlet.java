package com.rajesh.elams.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
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

@WebServlet("/exportAudit")
public class ExportAuditServlet extends HttpServlet {

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

		String searchKeyword = request.getParameter("search");
		String selectedModule = request.getParameter("module");
		String selectedAction = request.getParameter("action");
		String severity = request.getParameter("severity");
		String dateStr = request.getParameter("date");
		String startDate = request.getParameter("startDate");
		String endDate = request.getParameter("endDate");
		String format = request.getParameter("format");

		if (startDate == null || startDate.isBlank()) startDate = dateStr;
		if (endDate == null || endDate.isBlank()) endDate = dateStr;

		List<AuditLog> auditLogs = auditService.getAuditLogsAdvanced(searchKeyword, selectedModule, selectedAction, severity, startDate, endDate);

		String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());

		if ("json".equalsIgnoreCase(format)) {
			String fileName = "Audit_Logs_" + timeStamp + ".json";
			response.setContentType("application/json; charset=UTF-8");
			response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

			try (PrintWriter writer = response.getWriter()) {
				writer.write("[\n");
				if (auditLogs != null) {
					for (int i = 0; i < auditLogs.size(); i++) {
						AuditLog log = auditLogs.get(i);
						writer.write("  {\n");
						writer.write("    \"logId\": " + log.getLogId() + ",\n");
						writer.write("    \"username\": \"" + escapeJson(log.getUsername()) + "\",\n");
						writer.write("    \"action\": \"" + escapeJson(log.getAction()) + "\",\n");
						writer.write("    \"module\": \"" + escapeJson(log.getModule()) + "\",\n");
						writer.write("    \"recordId\": \"" + escapeJson(log.getRecordId()) + "\",\n");
						writer.write("    \"description\": \"" + escapeJson(log.getDescription()) + "\",\n");
						writer.write("    \"severity\": \"" + escapeJson(log.getSeverity()) + "\",\n");
						writer.write("    \"details\": " + (log.getDetails() != null && !log.getDetails().isBlank() ? log.getDetails() : "{}") + ",\n");
						writer.write("    \"ipAddress\": \"" + escapeJson(log.getIpAddress()) + "\",\n");
						writer.write("    \"timestamp\": \"" + escapeJson(log.getFormattedDate()) + "\"\n");
						writer.write("  }" + (i < auditLogs.size() - 1 ? "," : "") + "\n");
					}
				}
				writer.write("]\n");
				writer.flush();
			}
			AuditService.logAction(loggedUser.getEmail(), "EXPORT_AUDIT_LOGS", "System Settings", "CFG-AUDIT", "Exported audit logs to JSON (" + (auditLogs != null ? auditLogs.size() : 0) + " records)", request.getRemoteAddr());
		} else {
			String fileName = "Audit_Logs_" + timeStamp + ".csv";
			response.setContentType("text/csv; charset=UTF-8");
			response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

			try (PrintWriter writer = response.getWriter()) {
				writer.println("Log ID,Username,Action,Module,Record ID,Description,Severity,Details,IP Address,Timestamp");

				if (auditLogs != null) {
					for (AuditLog log : auditLogs) {
						StringBuilder sb = new StringBuilder();
						sb.append(log.getLogId()).append(",");
						sb.append(escapeCsv(log.getUsername())).append(",");
						sb.append(escapeCsv(log.getAction())).append(",");
						sb.append(escapeCsv(log.getModule())).append(",");
						sb.append(escapeCsv(log.getRecordId())).append(",");
						sb.append(escapeCsv(log.getDescription())).append(",");
						sb.append(escapeCsv(log.getSeverity())).append(",");
						sb.append(escapeCsv(log.getDetails())).append(",");
						sb.append(escapeCsv(log.getIpAddress())).append(",");
						sb.append(escapeCsv(log.getFormattedDate()));
						writer.println(sb.toString());
					}
				}
				writer.flush();
			}
			AuditService.logAction(loggedUser.getEmail(), "EXPORT_AUDIT_LOGS", "System Settings", "CFG-AUDIT", "Exported audit logs to CSV (" + (auditLogs != null ? auditLogs.size() : 0) + " records)", request.getRemoteAddr());
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

	private String escapeCsv(String input) {
		if (input == null) return "\"\"";
		String clean = input.replace("\"", "\"\"");
		return "\"" + clean + "\"";
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
