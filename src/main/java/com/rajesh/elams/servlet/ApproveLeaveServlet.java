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

@WebServlet("/approveLeave")
public class ApproveLeaveServlet extends HttpServlet {

	private LeaveDao leaveDAO;
	private com.rajesh.elams.service.LeaveService leaveService;
	private NotificationService notificationService;

	@Override
	public void init() {
		leaveDAO = new LeaveDaoImpl();
		leaveService = new com.rajesh.elams.service.LeaveService();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

		int leaveId = ValidationUtil.parsePositiveInt(request.getParameter("leaveId"), 0);
		if (leaveId == 0) {
			leaveId = ValidationUtil.parsePositiveInt(request.getParameter("id"), 0);
		}

		boolean forceLop = "true".equalsIgnoreCase(request.getParameter("asLop"))
				|| "1".equals(request.getParameter("asLop"))
				|| "true".equalsIgnoreCase(request.getParameter("lop"));

		if (leaveId > 0) {
			Leave leave = leaveDAO.getLeaveById(leaveId);
			boolean success = false;

			if (forceLop) {
				success = leaveService.approveLeaveAsLop(leaveId);
			} else {
				// Auto-check balance (default 12 paid days/year quota)
				success = leaveService.approveLeaveWithAutoLopCheck(leaveId, 12);
			}

			HttpSession session = request.getSession();
			Leave updatedLeave = leaveDAO.getLeaveById(leaveId);

			if (success && updatedLeave != null) {
				boolean isLopNow = updatedLeave.getLeaveType() != null && updatedLeave.getLeaveType().toUpperCase().contains("LOP");
				String alertMsg = isLopNow
						? "Leave Request #" + leaveId + " has been Approved as Loss of Pay (LOP)."
						: "Leave Request #" + leaveId + " has been Approved successfully as Paid Leave.";
				session.setAttribute("flashSuccess", alertMsg);

				com.rajesh.elams.model.User actorUser = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
				String actor = actorUser != null ? actorUser.getEmail() : "Manager/HR";
				com.rajesh.elams.service.AuditService.logAction(actor, "APPROVE_LEAVE", "Leave Management", "LV-" + leaveId, "Approved leave request #" + leaveId + (isLopNow ? " (LOP)" : ""), request.getRemoteAddr());

				Employee manager = (Employee) session.getAttribute("employee");
				long managerId = manager != null ? manager.getEmployee_id() : 1;
				String managerName = manager != null ? manager.getEmployee_name() : "HR / Manager";
				String noteMsg = isLopNow ? "Leave Approved as Loss of Pay (LOP)" : "Leave Approved";
				notificationService.notifyLeaveApproval(managerId, managerName, updatedLeave.getEmployeeId(), true, noteMsg);
			} else if (success) {
				session.setAttribute("flashSuccess", "Leave Request #" + leaveId + " has been Approved.");
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