package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;
import com.rajesh.elams.service.NotificationService;
import com.rajesh.elams.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/rejectLeave")
public class RejectLeaveServlet extends HttpServlet {

	private LeaveDao leaveDAO;
	private NotificationService notificationService;

	@Override
	public void init() {
		leaveDAO = new LeaveDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

		int leaveId = ValidationUtil.parsePositiveInt(request.getParameter("leaveId"), 0);
		if (leaveId == 0) {
			leaveId = ValidationUtil.parsePositiveInt(request.getParameter("id"), 0);
		}

		if (leaveId > 0) {
			Leave leave = leaveDAO.getLeaveById(leaveId);
			leaveDAO.updateLeaveStatus(leaveId, "Rejected");
			HttpSession session = request.getSession();
			session.setAttribute("flashSuccess", "Leave Request #" + leaveId + " has been Rejected.");

			com.rajesh.elams.model.User actorUser = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
			String actor = actorUser != null ? actorUser.getEmail() : "Manager/HR";
			com.rajesh.elams.service.AuditService.logAction(actor, "REJECT_LEAVE", "Leave Management", "LV-" + leaveId, "Rejected leave request #" + leaveId, request.getRemoteAddr());

			if (leave != null) {
				Employee manager = (Employee) session.getAttribute("employee");
				long managerId = manager != null ? manager.getEmployee_id() : 1;
				String managerName = manager != null ? manager.getEmployee_name() : "Manager";
				notificationService.notifyLeaveApproval(managerId, managerName, leave.getEmployeeId(), false, "Leave Rejected");
			}
		}

		response.sendRedirect("leaveRequests");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}