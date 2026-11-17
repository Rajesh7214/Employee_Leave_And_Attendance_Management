package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingParticipant;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/deleteMeeting")
public class DeleteMeetingServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingDao meetingDao;
	private MeetingParticipantDao participantDao;
	private EmployeeDao employeeDao;
	private NotificationService notificationService;

	@Override
	public void init() {
		meetingDao = new MeetingDaoImpl();
		participantDao = new MeetingParticipantDaoImpl();
		employeeDao = new EmployeeDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		String role = session == null ? null : (String) session.getAttribute("role");

		if (session == null || !("admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
			response.sendRedirect("viewMeetings");
			return;
		}

		int meetingId = Integer.parseInt(request.getParameter("meetingId"));

		Meeting meeting = meetingDao.getMeetingById(meetingId);
		if (meeting != null) {
			List<MeetingParticipant> participants = participantDao.getParticipantsByMeeting(meetingId);
			Employee currentEmp = (Employee) session.getAttribute("employee");
			String senderName = currentEmp != null ? currentEmp.getEmployee_name() : "Management";

			if (participants != null && !participants.isEmpty()) {
				List<Employee> participantEmps = new java.util.ArrayList<>();
				for (MeetingParticipant p : participants) {
					Employee emp = employeeDao.getEmployeeById(p.getEmployeeId());
					if (emp != null) {
						participantEmps.add(emp);
					}
				}
				if (!participantEmps.isEmpty()) {
					notificationService.notifyMeetingCancelled(meeting, senderName, participantEmps);
				}
			}

			meetingDao.deleteMeeting(meetingId);
			session.setAttribute("flashSuccess", "Meeting cancelled successfully.");
		}

		response.sendRedirect("viewMeetings");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
