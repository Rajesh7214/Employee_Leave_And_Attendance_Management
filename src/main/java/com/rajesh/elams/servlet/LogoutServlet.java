package com.rajesh.elams.servlet;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session != null) {
			com.rajesh.elams.model.User user = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
			if (user != null) {
				com.rajesh.elams.service.AuditService.logLogout(user.getEmail(), request.getRemoteAddr());
			}
			session.invalidate();
		}

		response.sendRedirect("login.jsp");
	}
}