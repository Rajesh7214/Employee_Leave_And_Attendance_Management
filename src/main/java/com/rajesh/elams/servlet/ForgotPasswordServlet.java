package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.UserDao;
import com.rajesh.elams.dao.UserDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private UserDao userDao = new UserDaoImpl();

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String email = request.getParameter("email");
		String newPassword = request.getParameter("newPassword");
		String confirmPassword = request.getParameter("confirmPassword");

		if (email == null || email.trim().isEmpty() ||
			newPassword == null || newPassword.trim().isEmpty() ||
			confirmPassword == null || confirmPassword.trim().isEmpty()) {
			request.setAttribute("errorMessage", "All fields are required.");
			request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
			return;
		}

		email = email.trim();

		if (!newPassword.equals(confirmPassword)) {
			request.setAttribute("errorMessage", "Passwords do not match. Please try again.");
			request.setAttribute("email", email);
			request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
			return;
		}

		if (newPassword.length() < 4) {
			request.setAttribute("errorMessage", "Password must be at least 4 characters long.");
			request.setAttribute("email", email);
			request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
			return;
		}

		if (!userDao.isEmailExists(email)) {
			request.setAttribute("errorMessage", "No registered account found with email: " + email);
			request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
			return;
		}

		boolean updated = userDao.updatePassword(email, newPassword);

		if (updated) {
			request.setAttribute("successMessage", "Password updated successfully! Please sign in with your new password.");
			request.getRequestDispatcher("/login.jsp").forward(request, response);
		} else {
			request.setAttribute("errorMessage", "Failed to update password due to a system error. Please try again.");
			request.setAttribute("email", email);
			request.getRequestDispatcher("/forgotPassword.jsp").forward(request, response);
		}
	}
}
