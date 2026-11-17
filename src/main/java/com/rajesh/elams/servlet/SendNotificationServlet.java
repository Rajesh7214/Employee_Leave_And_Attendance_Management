package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
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

@WebServlet("/sendNotification")
public class SendNotificationServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;
	private NotificationService notificationService;

	@Override
	public void init() {
		this.employeeDao = new EmployeeDaoImpl();
		this.notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String role = (String) session.getAttribute("role");
		User loggedUser = (User) session.getAttribute("loggedUser");

		boolean isAuthorized = "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role) || "hr".equalsIgnoreCase(role);
		if (!isAuthorized && loggedUser != null) {
			isAuthorized = "admin".equalsIgnoreCase(loggedUser.getRole()) || "manager".equalsIgnoreCase(loggedUser.getRole()) || "hr".equalsIgnoreCase(loggedUser.getRole());
		}

		if (!isAuthorized) {
			response.sendRedirect("login.jsp");
			return;
		}

		String action = request.getParameter("action");
		if ("delete".equalsIgnoreCase(action)) {
			String idStr = request.getParameter("id");
			if (idStr != null && !idStr.trim().isEmpty()) {
				try {
					long id = Long.parseLong(idStr.trim());
					notificationService.deleteNotification(id);
					session.setAttribute("flashSuccess", "Notification deleted successfully.");
					response.sendRedirect(request.getContextPath() + "/sendNotification");
					return;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

		if ("archive".equalsIgnoreCase(action)) {
			String idStr = request.getParameter("id");
			if (idStr != null && !idStr.trim().isEmpty()) {
				try {
					long id = Long.parseLong(idStr.trim());
					notificationService.archiveNotification(id);
					session.setAttribute("flashSuccess", "Notification archived successfully.");
					response.sendRedirect(request.getContextPath() + "/sendNotification");
					return;
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}

		List<Employee> employeeList = employeeDao.getAllEmployees();
		request.setAttribute("employeeList", employeeList);

		long senderId = 1;
		if (loggedUser != null) {
			senderId = loggedUser.getId();
		}

		List<Notification> sentList = notificationService.getNotificationsByUser(senderId);
		if (sentList == null || sentList.isEmpty()) {
			sentList = notificationService.searchAndFilter(0, "ALL", "ALL", "ALL", null);
		}
		request.setAttribute("sentNotifications", sentList);

		request.getRequestDispatcher("sendNotification.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		User loggedUser = (User) session.getAttribute("loggedUser");
		Employee employee = (Employee) session.getAttribute("employee");

		long senderId = 1;
		String senderName = "Admin";

		if (loggedUser != null) {
			senderId = loggedUser.getId();
			if (loggedUser.getEmail() != null) {
				senderName = loggedUser.getEmail().split("@")[0];
			}
		}
		if (employee != null) {
			if (employee.getEmployee_id() > 0) {
				senderId = employee.getEmployee_id();
			}
			if (employee.getEmployee_name() != null && !employee.getEmployee_name().isBlank()) {
				senderName = employee.getEmployee_name();
			}
		}

		String formAction = request.getParameter("formAction");
		if ("sendSmsOnly".equalsIgnoreCase(formAction) || "directSms".equalsIgnoreCase(formAction)) {
			String targetEmpStr = request.getParameter("targetEmployeeId");
			String customPhone = request.getParameter("customPhone");
			String smsMessage = request.getParameter("smsMessage");

			if (smsMessage == null || smsMessage.isBlank()) {
				smsMessage = request.getParameter("directMessage");
			}

			String phoneToUse = customPhone;
			if ((phoneToUse == null || phoneToUse.isBlank()) && targetEmpStr != null && !targetEmpStr.isBlank()) {
				try {
					int empId = Integer.parseInt(targetEmpStr.trim());
					Employee emp = employeeDao.getEmployeeById(empId);
					if (emp != null && emp.getPhone() > 0) {
						phoneToUse = String.valueOf(emp.getPhone());
					}
				} catch (Exception ignored) {}
			}
			if ((phoneToUse == null || phoneToUse.isBlank())) {
				phoneToUse = request.getParameter("directPhone");
			}

			if (phoneToUse != null && !phoneToUse.isBlank() && smsMessage != null && !smsMessage.isBlank()) {
				String formattedMsg = "SmartOffice Alert from " + senderName + ": " + smsMessage.trim();
				if (formattedMsg.length() > 155) formattedMsg = formattedMsg.substring(0, 152) + "...";
				boolean sent = com.rajesh.elams.util.SmsService.sendSms(phoneToUse.trim(), formattedMsg);
				session.setAttribute("flashSuccess", "📱 Mobile SMS dispatched to phone: " + phoneToUse.trim() + "!");
			} else {
				session.setAttribute("flashSuccess", "❌ Mobile SMS Dispatch failed: No valid phone number provided.");
			}
			response.sendRedirect(request.getContextPath() + "/sendNotification");
			return;
		}

		if ("sendEmailOnly".equalsIgnoreCase(formAction)) {
			String targetEmpStr = request.getParameter("targetEmployeeId");
			String customEmail = request.getParameter("customEmail");
			String emailSubject = request.getParameter("emailSubject");
			String emailBodyText = request.getParameter("emailBody");

			String emailToUse = customEmail;
			String recipientName = "Employee";
			if ((emailToUse == null || emailToUse.isBlank()) && targetEmpStr != null && !targetEmpStr.isBlank()) {
				try {
					int empId = Integer.parseInt(targetEmpStr.trim());
					Employee emp = employeeDao.getEmployeeById(empId);
					if (emp != null && emp.getEmail() != null) {
						emailToUse = emp.getEmail().trim();
						recipientName = emp.getEmployee_name();
					}
				} catch (Exception ignored) {}
			}

			if (emailToUse != null && !emailToUse.isBlank() && emailSubject != null && !emailSubject.isBlank() && emailBodyText != null && !emailBodyText.isBlank()) {
				String fullHtmlBody = "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
						+ "<h2 style='color: #2b6cb0;'>" + emailSubject + "</h2>"
						+ "<p>Hello <b>" + recipientName + "</b>,</p>"
						+ "<p style='font-size: 15px; white-space: pre-line;'>" + emailBodyText.trim() + "</p>"
						+ "<hr style='border: 0; border-top: 1px solid #eee; margin: 20px 0;'/>"
						+ "<p style='font-size: 12px; color: #777;'>SmartOffice Official Email Notice | Sender: " + senderName + "</p>"
						+ "</div>";
				com.rajesh.elams.util.EmailService.sendEmail(emailToUse.trim(), emailSubject.trim(), fullHtmlBody);
				session.setAttribute("flashSuccess", "📧 Gmail Email dispatched to address: " + emailToUse.trim() + "!");
			} else {
				session.setAttribute("flashSuccess", "❌ Email Dispatch failed: Missing email address, subject, or message content.");
			}
			response.sendRedirect(request.getContextPath() + "/sendNotification");
			return;
		}

		String recipientType = request.getParameter("recipientType");
		String targetEmpStr = request.getParameter("targetEmployeeId");
		String title = request.getParameter("title");
		String message = request.getParameter("message");
		String category = request.getParameter("category");
		String priority = request.getParameter("priority");
		String customPhone = request.getParameter("customPhone");
		boolean sendSmsAlert = "true".equalsIgnoreCase(request.getParameter("sendSms")) || "on".equalsIgnoreCase(request.getParameter("sendSms")) || request.getParameter("sendSms") == null;
		boolean sendEmailAlert = "true".equalsIgnoreCase(request.getParameter("sendEmail")) || "on".equalsIgnoreCase(request.getParameter("sendEmail")) || request.getParameter("sendEmail") == null;

		if (recipientType == null || recipientType.isBlank()) {
			recipientType = "ALL";
		}
		if (category == null || category.isBlank()) {
			category = Notification.CAT_ANNOUNCEMENT;
		}
		if (priority == null || priority.isBlank()) {
			priority = Notification.PRIORITY_MEDIUM;
		}

		long receiverId = 0;
		if ("EMPLOYEE".equalsIgnoreCase(recipientType) && targetEmpStr != null && !targetEmpStr.isBlank()) {
			try {
				receiverId = Long.parseLong(targetEmpStr.trim());
			} catch (Exception ignored) {}
		}

		if (title != null && !title.isBlank() && message != null && !message.isBlank()) {
			Notification notif = new Notification(senderId, receiverId, title.trim(), message.trim(), category, priority);
			notif.setSenderName(senderName);
			notif.setRecipientType(recipientType);
			if (receiverId > 0) {
				notif.setTargetEmployeeId((int) receiverId);
			}

			notificationService.createNotification(notif, sendEmailAlert, sendSmsAlert, customPhone);
			String channelsStr = (sendSmsAlert ? "SMS, " : "") + (sendEmailAlert ? "Gmail, " : "") + "In-App";
			session.setAttribute("flashSuccess", "Notification dispatched successfully via " + channelsStr + "!");
		}

		response.sendRedirect(request.getContextPath() + "/sendNotification");
	}
}
