package com.rajesh.elams.servlet;

import java.io.IOException;


import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/cancelLeave")
public class CancelLeaveServlet extends HttpServlet {

	private LeaveDao leaveDAO;

	@Override
	public void init() {

		leaveDAO = new LeaveDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

		String leaveIdStr = request.getParameter("leaveId");
		if (leaveIdStr != null && !leaveIdStr.trim().isEmpty()) {
			try {
				int leaveId = Integer.parseInt(leaveIdStr.trim());
				leaveDAO.cancelLeave(leaveId);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		String empIdStr = request.getParameter("employeeId");
		if (empIdStr != null && !empIdStr.trim().isEmpty()) {
			response.sendRedirect("leaveHistory?employeeId=" + empIdStr.trim());
		} else {
			response.sendRedirect("leaveHistory");
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws jakarta.servlet.ServletException, IOException {
		doGet(request, response);
	}
}