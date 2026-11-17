package com.rajesh.elams.servlet;

import java.io.BufferedReader;

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


@WebServlet("/notifications/*")
public class NotificationApiServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private NotificationService notificationService;

	@Override
	public void init() throws ServletException {
		this.notificationService = new NotificationService();
	}

	private long getAuthenticatedUserId(HttpServletRequest request) {
		HttpSession session = request.getSession(false);
		if (session == null) return 0;

		Employee emp = (Employee) session.getAttribute("employee");
		if (emp != null && emp.getEmployee_id() > 0) {
			return emp.getEmployee_id();
		}
		User user = (User) session.getAttribute("loggedUser");
		if (user != null && user.getId() > 0) {
			return user.getId();
		}
		Object empIdObj = session.getAttribute("employeeId");
		if (empIdObj instanceof Integer) {
			return (Integer) empIdObj;
		} else if (empIdObj instanceof Long) {
			return (Long) empIdObj;
		}
		return 0;
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();

		long userId = getAuthenticatedUserId(request);
		if (userId == 0) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			out.print("{\"error\":\"Unauthorized. Session missing.\"}");
			out.flush();
			return;
		}

		String pathInfo = request.getPathInfo();
		if (pathInfo == null) pathInfo = "/";

		if ("/count".equalsIgnoreCase(pathInfo)) {
			int count = notificationService.getUnreadCount(userId);
			out.print("{\"unreadCount\":" + count + "}");
			out.flush();
			return;
		}

		if ("/unread".equalsIgnoreCase(pathInfo)) {
			List<Notification> list = notificationService.getUnreadNotifications(userId);
			out.print(buildJsonListResponse(list));
			out.flush();
			return;
		}

		// Support search and filter query parameters: ?category=...&priority=...&status=...&q=...
		String category = request.getParameter("category");
		String priority = request.getParameter("priority");
		String status = request.getParameter("status");
		String keyword = request.getParameter("q");

		List<Notification> list;
		if (category != null || priority != null || status != null || keyword != null) {
			list = notificationService.searchAndFilter(userId, category, priority, status, keyword);
		} else {
			list = notificationService.getNotificationsByUser(userId);
		}

		out.print(buildJsonListResponse(list));
		out.flush();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();

		long senderId = getAuthenticatedUserId(request);
		if (senderId == 0) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			out.print("{\"error\":\"Unauthorized\"}");
			out.flush();
			return;
		}

		String receiverIdStr = request.getParameter("receiverId");
		String title = request.getParameter("title");
		String message = request.getParameter("message");
		String category = request.getParameter("category");
		String priority = request.getParameter("priority");

		long receiverId = 0;
		if (receiverIdStr != null && !receiverIdStr.isBlank()) {
			try { receiverId = Long.parseLong(receiverIdStr.trim()); } catch (Exception ignored) {}
		}

		if (title == null || title.isBlank() || message == null || message.isBlank()) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			out.print("{\"error\":\"Title and message are required\"}");
			out.flush();
			return;
		}

		Notification n = new Notification(senderId, receiverId, title, message, category, priority);
		boolean success = notificationService.createNotification(n);

		if (success) {
			response.setStatus(HttpServletResponse.SC_CREATED);
			out.print("{\"success\":true,\"notificationId\":" + n.getNotificationId() + "}");
		} else {
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			out.print("{\"success\":false,\"error\":\"Failed to create notification\"}");
		}
		out.flush();
	}

	@Override
	protected void doPut(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();

		long userId = getAuthenticatedUserId(request);
		if (userId == 0) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			out.print("{\"error\":\"Unauthorized\"}");
			out.flush();
			return;
		}

		String pathInfo = request.getPathInfo();
		if (pathInfo == null) pathInfo = "";

		if (pathInfo.startsWith("/read/")) {
			String idStr = pathInfo.substring("/read/".length());
			try {
				long id = Long.parseLong(idStr.trim());
				boolean ok = notificationService.markAsRead(id);
				out.print("{\"success\":" + ok + ",\"id\":" + id + "}");
				out.flush();
				return;
			} catch (Exception e) {
				response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				out.print("{\"error\":\"Invalid Notification ID\"}");
				out.flush();
				return;
			}
		}

		if (pathInfo.startsWith("/archive/")) {
			String idStr = pathInfo.substring("/archive/".length());
			try {
				long id = Long.parseLong(idStr.trim());
				boolean ok = notificationService.archiveNotification(id);
				out.print("{\"success\":" + ok + ",\"id\":" + id + "}");
				out.flush();
				return;
			} catch (Exception e) {
				response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				out.print("{\"error\":\"Invalid Notification ID\"}");
				out.flush();
				return;
			}
		}

		response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		out.print("{\"error\":\"Endpoint not found\"}");
		out.flush();
	}

	@Override
	protected void doDelete(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();

		long userId = getAuthenticatedUserId(request);
		if (userId == 0) {
			response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
			out.print("{\"error\":\"Unauthorized\"}");
			out.flush();
			return;
		}

		String pathInfo = request.getPathInfo();
		if (pathInfo == null) pathInfo = "";

		if ("/all".equalsIgnoreCase(pathInfo)) {
			boolean ok = notificationService.deleteAllNotifications(userId);
			out.print("{\"success\":" + ok + "}");
			out.flush();
			return;
		}

		if (pathInfo.length() > 1) {
			String idStr = pathInfo.substring(1);
			try {
				long id = Long.parseLong(idStr.trim());
				boolean ok = notificationService.deleteNotification(id);
				out.print("{\"success\":" + ok + ",\"id\":" + id + "}");
				out.flush();
				return;
			} catch (Exception e) {
				response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
				out.print("{\"error\":\"Invalid Notification ID\"}");
				out.flush();
				return;
			}
		}

		response.setStatus(HttpServletResponse.SC_NOT_FOUND);
		out.print("{\"error\":\"Endpoint not found\"}");
		out.flush();
	}

	private String buildJsonListResponse(List<Notification> list) {
		if (list == null || list.isEmpty()) {
			return "[]";
		}
		StringBuilder sb = new StringBuilder("[");
		for (int i = 0; i < list.size(); i++) {
			if (i > 0) sb.append(",");
			Notification n = list.get(i);
			sb.append("{")
					.append("\"notificationId\":").append(n.getNotificationId()).append(",")
					.append("\"senderId\":").append(n.getSenderId()).append(",")
					.append("\"receiverId\":").append(n.getReceiverId()).append(",")
					.append("\"senderName\":\"").append(escapeJson(n.getSenderName())).append("\",")
					.append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
					.append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
					.append("\"category\":\"").append(escapeJson(n.getCategory())).append("\",")
					.append("\"priority\":\"").append(escapeJson(n.getPriority())).append("\",")
					.append("\"status\":\"").append(escapeJson(n.getStatus())).append("\",")
					.append("\"createdAt\":\"").append(n.getCreatedAt() != null ? n.getCreatedAt().toString() : "").append("\",")
					.append("\"readAt\":\"").append(n.getReadAt() != null ? n.getReadAt().toString() : "").append("\",")
					.append("\"isRead\":").append(n.isRead())
					.append("}");
		}
		sb.append("]");
		return sb.toString();
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
