package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.UserDao;
import com.rajesh.elams.dao.UserDaoImpl;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private UserDao userDao = new UserDaoImpl();
	private NotificationService notificationService = new NotificationService();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("email") == null) {
			response.sendRedirect("login.jsp");
			return;
		}
		request.getRequestDispatcher("/changePassword.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("email") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String email = (String) session.getAttribute("email");
		String currentPassword = request.getParameter("currentPassword");
		String newPassword = request.getParameter("newPassword");
		String confirmPassword = request.getParameter("confirmPassword");

		if (currentPassword == null || currentPassword.trim().isEmpty() ||
			newPassword == null || newPassword.trim().isEmpty() ||
			confirmPassword == null || confirmPassword.trim().isEmpty()) {
			request.setAttribute("errorMessage", "All password fields are required.");
			request.getRequestDispatcher("/changePassword.jsp").forward(request, response);
			return;
		}

		if (!newPassword.equals(confirmPassword)) {
			request.setAttribute("errorMessage", "New password and confirmation do not match.");
			request.getRequestDispatcher("/changePassword.jsp").forward(request, response);
			return;
		}

		if (newPassword.length() < 6) {
			request.setAttribute("errorMessage", "New password must be at least 6 characters long.");
			request.getRequestDispatcher("/changePassword.jsp").forward(request, response);
			return;
		}

		User user = userDao.login(email, currentPassword);
		if (user == null) {
			request.setAttribute("errorMessage", "Incorrect current password. Please try again.");
			request.getRequestDispatcher("/changePassword.jsp").forward(request, response);
			return;
		}

		boolean updated = userDao.updatePassword(email, newPassword);

		if (updated) {
			notificationService.notifyPasswordChanged(user.getId());
			request.setAttribute("successMessage", "Your password has been changed successfully!");
		} else {
			request.setAttribute("errorMessage", "Database update error. Please try again shortly.");
		}

		request.getRequestDispatcher("/changePassword.jsp").forward(request, response);
	}
}
