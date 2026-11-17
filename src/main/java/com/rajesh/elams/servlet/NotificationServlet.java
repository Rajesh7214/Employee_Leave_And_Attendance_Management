package com.rajesh.elams.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Notification;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/getNotifications", "/notification", "/notificationServlet" })
public class NotificationServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private NotificationService notificationService;

	@Override
	public void init() {
		this.notificationService = new NotificationService();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");

		HttpSession session = request.getSession(false);
		long employeeId = 0;
		if (session != null) {
			Employee emp = (Employee) session.getAttribute("employee");
			if (emp != null && emp.getEmployee_id() > 0) {
				employeeId = emp.getEmployee_id();
			} else if (session.getAttribute("employeeId") != null) {
				Object obj = session.getAttribute("employeeId");
				if (obj instanceof Integer) employeeId = (Integer) obj;
				else if (obj instanceof Long) employeeId = (Long) obj;
			} else {
				User user = (User) session.getAttribute("loggedUser");
				if (user != null) employeeId = user.getId();
			}
		}

		String action = request.getParameter("action");
		PrintWriter out = response.getWriter();

		if ("markRead".equalsIgnoreCase(action)) {
			String idStr = request.getParameter("id");
			if (idStr != null && !idStr.trim().isEmpty()) {
				try {
					long notifId = Long.parseLong(idStr.trim());
					notificationService.markAsRead(notifId);
					out.print("{\"success\":true,\"id\":" + notifId + "}");
					out.flush();
					return;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			out.print("{\"success\":false}");
			out.flush();
			return;
		}

		if ("archive".equalsIgnoreCase(action)) {
			String idStr = request.getParameter("id");
			if (idStr != null && !idStr.trim().isEmpty()) {
				try {
					long notifId = Long.parseLong(idStr.trim());
					notificationService.archiveNotification(notifId);
					out.print("{\"success\":true,\"id\":" + notifId + "}");
					out.flush();
					return;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			out.print("{\"success\":false}");
			out.flush();
			return;
		}

		if ("markAllRead".equalsIgnoreCase(action)) {
			List<Notification> unreads = notificationService.getUnreadNotifications(employeeId);
			if (unreads != null) {
				for (Notification n : unreads) {
					notificationService.markAsRead(n.getNotificationId());
				}
			}
			out.print("{\"success\":true}");
			out.flush();
			return;
		}

		if ("getDetail".equalsIgnoreCase(action)) {
			String idStr = request.getParameter("id");
			if (idStr != null && !idStr.trim().isEmpty()) {
				try {
					long notifId = Long.parseLong(idStr.trim());
					notificationService.markAsRead(notifId);
					List<Notification> list = notificationService.getNotificationsByUser(employeeId);
					Notification n = null;
					if (list != null) {
						for (Notification item : list) {
							if (item.getNotificationId() == notifId) {
								n = item;
								break;
							}
						}
					}
					if (n != null) {
						String timeStr = n.getCreatedAt() != null ? n.getCreatedAt().toString() : "Recently";
						String icon = getCategoryIcon(n.getCategory());
						out.print(createNotificationJson(n, timeStr, "", icon));
						out.flush();
						return;
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			out.print("{\"error\":\"Notification not found\"}");
			out.flush();
			return;
		}

		String categoryFilter = request.getParameter("category");
		String priorityFilter = request.getParameter("priority");
		String statusFilter = request.getParameter("status");
		String keywordFilter = request.getParameter("q");

		List<Notification> notifList;
		if (categoryFilter != null || priorityFilter != null || statusFilter != null || keywordFilter != null) {
			notifList = notificationService.searchAndFilter(employeeId, categoryFilter, priorityFilter, statusFilter, keywordFilter);
		} else {
			notifList = notificationService.getNotificationsByUser(employeeId);
		}

		if (notifList == null) {
			notifList = java.util.Collections.emptyList();
		}

		int unreadCount = notificationService.getUnreadCount(employeeId);
		StringBuilder sb = new StringBuilder();
		sb.append("{\"unreadCount\":");

		StringBuilder itemsJson = new StringBuilder("[");
		for (int i = 0; i < notifList.size(); i++) {
			Notification n = notifList.get(i);
			if (i > 0) itemsJson.append(",");
			String icon = getCategoryIcon(n.getCategory());
			String timeStr = formatRelativeTime(n.getCreatedAt());

			itemsJson.append(createNotificationJson(n, timeStr, "", icon));
		}
		itemsJson.append("]");

		sb.append(unreadCount);
		sb.append(",\"notifications\":");
		sb.append(itemsJson.toString());
		sb.append("}");

		out.print(sb.toString());
		out.flush();
	}

	private String formatRelativeTime(java.sql.Timestamp ts) {
		if (ts == null) return "Just now";
		long diffMs = System.currentTimeMillis() - ts.getTime();
		if (diffMs < 0) diffMs = 0;
		long seconds = diffMs / 1000;
		long minutes = seconds / 60;
		long hours = minutes / 60;
		long days = hours / 24;

		if (seconds < 60) return "Just now";
		if (minutes < 60) return minutes + " mins ago";
		if (hours < 24) return hours + (hours == 1 ? " hour ago" : " hours ago");
		if (days < 7) return days + (days == 1 ? " day ago" : " days ago");
		return new java.text.SimpleDateFormat("MMM dd, yyyy").format(ts);
	}

	private String getCategoryIcon(String category) {
		if (category == null) return "fa-solid fa-bell";
		switch (category) {
			case Notification.CAT_TASK: return "fa-solid fa-list-check";
			case Notification.CAT_LEAVE: return "fa-solid fa-calendar-minus";
			case Notification.CAT_MEETING: return "fa-solid fa-users";
			case Notification.CAT_ATTENDANCE: return "fa-solid fa-user-clock";
			case Notification.CAT_PAYROLL: return "fa-solid fa-file-invoice-dollar";
			case Notification.CAT_ANNOUNCEMENT: return "fa-solid fa-bullhorn";
			case Notification.CAT_PROJECT: return "fa-solid fa-diagram-project";
			case Notification.CAT_REMINDER: return "fa-solid fa-clock";
			case Notification.CAT_HOLIDAY: return "fa-solid fa-umbrella-beach";
			case Notification.CAT_SECURITY: return "fa-solid fa-shield-halved";
			case Notification.CAT_DOCUMENTS: return "fa-solid fa-file-lines";
			case Notification.CAT_PERFORMANCE: return "fa-solid fa-chart-line";
			default: return "fa-solid fa-bell";
		}
	}

	private String createNotificationJson(Notification n, String time, String link, String icon) {
		String senderName = n.getSenderName() != null ? n.getSenderName() : "System";
		String recipientType = n.getRecipientType() != null ? n.getRecipientType() : "ALL";
		String category = n.getCategory() != null ? n.getCategory() : Notification.CAT_ANNOUNCEMENT;
		String priority = n.getPriority() != null ? n.getPriority() : Notification.PRIORITY_MEDIUM;
		String status = n.getStatus() != null ? n.getStatus() : Notification.STATUS_UNREAD;

		return "{\"id\":\"" + escapeJson(String.valueOf(n.getNotificationId())) + "\""
				+ ",\"title\":\"" + escapeJson(n.getTitle()) + "\""
				+ ",\"message\":\"" + escapeJson(n.getMessage()) + "\""
				+ ",\"senderName\":\"" + escapeJson(senderName) + "\""
				+ ",\"recipientType\":\"" + escapeJson(recipientType) + "\""
				+ ",\"category\":\"" + escapeJson(category) + "\""
				+ ",\"priority\":\"" + escapeJson(priority) + "\""
				+ ",\"status\":\"" + escapeJson(status) + "\""
				+ ",\"time\":\"" + escapeJson(time) + "\""
				+ ",\"isRead\":" + n.isRead()
				+ ",\"link\":\"" + escapeJson(link) + "\""
				+ ",\"icon\":\"" + escapeJson(icon) + "\"}";
	}

	private String escapeJson(String str) {
		if (str == null) return "";
		return str.replace("\\", "\\\\")
				.replace("\"", "\\\"")
				.replace("\b", "\\b")
				.replace("\f", "\\f")
				.replace("\n", "\\n")
				.replace("\r", "\\r")
				.replace("\t", "\\t");
	}
}
