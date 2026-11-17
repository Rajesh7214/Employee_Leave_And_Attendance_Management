package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/leaveHistory")
public class LeaveHistoryServlet extends HttpServlet {

	private LeaveDao leaveDAO;

	@Override
	public void init() {

		leaveDAO = new LeaveDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		int employeeId = 0;
		String empIdParam = request.getParameter("employeeId");
		if (empIdParam != null && !empIdParam.trim().isEmpty()) {
			try {
				employeeId = Integer.parseInt(empIdParam.trim());
			} catch (Exception ignored) {}
		}

		if (employeeId <= 0 && session != null) {
			Employee emp = (Employee) session.getAttribute("employee");
			if (emp != null && emp.getEmployee_id() > 0) {
				employeeId = emp.getEmployee_id();
			} else if (session.getAttribute("employeeId") != null) {
				try {
					employeeId = (Integer) session.getAttribute("employeeId");
				} catch (Exception ignored) {}
			}
		}

		List<Leave> leaves = leaveDAO.getLeavesByEmployee(employeeId);

		request.setAttribute("leaves", leaves);

		request.getRequestDispatcher("leaveHistory.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}