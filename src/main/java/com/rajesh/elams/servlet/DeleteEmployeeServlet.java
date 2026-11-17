package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/deleteEmployee")
public class DeleteEmployeeServlet extends HttpServlet {

	private EmployeeDao employeeDao;

	@Override
	public void init() {
		employeeDao = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {

		int employeeId = Integer.parseInt(req.getParameter("id"));

		jakarta.servlet.http.HttpSession session = req.getSession(false);
		com.rajesh.elams.model.User actorUser = session != null ? (com.rajesh.elams.model.User) session.getAttribute("loggedUser") : null;
		String actor = actorUser != null ? actorUser.getEmail() : "Admin";
		com.rajesh.elams.service.AuditService.logAction(actor, "DEACTIVATE_EMPLOYEE", "Employee Management", "EMP-" + employeeId, "Deactivated/deleted employee record", req.getRemoteAddr());
		com.rajesh.elams.service.AuditService.logAction(actor, "DEACTIVATE_USER", "User Management", "EMP-" + employeeId, "Deactivated user account", req.getRemoteAddr());

		employeeDao.deleteEmployee(employeeId);

		res.sendRedirect("viewEmployeesServlet");
	}

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		doGet(req, res);
	}
}