package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;

import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.model.Leave;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/applyLeave")
public class LeaveServlet extends HttpServlet {

	private LeaveDao leaveDAO;

	@Override
	public void init() {
		leaveDAO = new LeaveDaoImpl();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		jakarta.servlet.http.HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String empIdStr = request.getParameter("employeeId");
		int employeeId = 0;
		if (empIdStr != null && !empIdStr.trim().isEmpty()) {
			try {
				employeeId = Integer.parseInt(empIdStr.trim());
			} catch (NumberFormatException ignored) {}
		}

		if (employeeId <= 0) {
			com.rajesh.elams.model.Employee emp = (com.rajesh.elams.model.Employee) session.getAttribute("employee");
			if (emp != null) {
				employeeId = emp.getEmployee_id();
			} else if (session.getAttribute("employeeId") != null) {
				employeeId = (Integer) session.getAttribute("employeeId");
			}
		}

		String startDateStr = request.getParameter("startDate");
		String endDateStr = request.getParameter("endDate");
		String leaveType = request.getParameter("leaveType");
		String reason = request.getParameter("reason");

		if (startDateStr == null || startDateStr.isBlank() || endDateStr == null || endDateStr.isBlank()) {
			session.setAttribute("errorMessage", "Start Date and End Date are required.");
			response.sendRedirect("applyLeave.jsp");
			return;
		}

		Date startDate;
		Date endDate;
		try {
			startDate = Date.valueOf(startDateStr);
			endDate = Date.valueOf(endDateStr);
		} catch (Exception e) {
			session.setAttribute("errorMessage", "Invalid date format provided.");
			response.sendRedirect("applyLeave.jsp");
			return;
		}

		if (endDate.before(startDate)) {
			session.setAttribute("errorMessage", "End Date cannot be before Start Date.");
			response.sendRedirect("applyLeave.jsp");
			return;
		}

		Leave leave = new Leave();
		leave.setEmployeeId(employeeId);
		leave.setLeaveType(leaveType != null ? leaveType : "Casual Leave");
		leave.setStartdate(startDate);
		leave.setEndDate(endDate);
		leave.setReason(reason);
		leave.setStatus("Pending");

		boolean applied = leaveDAO.applyLeave(leave);
		if (applied) {
			session.setAttribute("successMessage", "Leave Application Submitted Successfully.");

			com.rajesh.elams.model.User actorUser = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
			String actor = actorUser != null ? actorUser.getEmail() : "Employee";
			com.rajesh.elams.service.AuditService.logAction(actor, "APPLY_LEAVE", "Leave Management", "LV-EMP-" + employeeId, "Applied " + leaveType + " from " + startDateStr + " to " + endDateStr, request.getRemoteAddr());

			// Dispatch Leave Application Notification (Scenario 10.2)
			try {
				com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
				com.rajesh.elams.model.Employee emp = empDao.getEmployeeById(employeeId);
				String empName = emp != null ? emp.getEmployee_name() : "Employee #" + employeeId;
				long daysCount = java.time.temporal.ChronoUnit.DAYS.between(startDate.toLocalDate(), endDate.toLocalDate()) + 1;
				com.rajesh.elams.service.NotificationService notifService = new com.rajesh.elams.service.NotificationService();
				notifService.notifyLeaveApplication(employeeId, empName, 1L, (int) daysCount, reason != null && !reason.isBlank() ? reason : leaveType);
			} catch (Exception ignored) {}
		} else {
			session.setAttribute("errorMessage", "Failed to submit leave application. Please try again.");
		}

		response.sendRedirect("leaveHistory?employeeId=" + employeeId);
	}
}