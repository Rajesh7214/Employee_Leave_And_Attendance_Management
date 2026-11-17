package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.MeetingParticipant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Employee actor: "Accept/Reject Invitation" (section 4).
 */
@WebServlet(urlPatterns = { "/respondInvitation", "/respondMeeting" })
public class RespondInvitationServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingParticipantDao participantDao;

	@Override
	public void init() {
		participantDao = new MeetingParticipantDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		processRequest(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		processRequest(request, response);
	}

	private void processRequest(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String meetingIdParam = request.getParameter("meetingId");
		String decision = request.getParameter("decision");

		if (meetingIdParam == null || meetingIdParam.isBlank()) {
			response.sendRedirect("viewMeetings");
			return;
		}

		int meetingId = Integer.parseInt(meetingIdParam.trim());
		Employee employee = (Employee) session.getAttribute("employee");

		if (employee != null && decision != null && !decision.isBlank()) {
			String normalizedDecision = decision.trim().toUpperCase();
			if ("ACCEPTED".equals(normalizedDecision) || "ACCEPT".equals(normalizedDecision)) {
				normalizedDecision = "ACCEPTED";
			} else if ("REJECTED".equals(normalizedDecision) || "REJECT".equals(normalizedDecision)) {
				normalizedDecision = "REJECTED";
			}

			MeetingParticipant participant = participantDao.getParticipant(meetingId, employee.getEmployee_id());

			if (participant != null) {
				participantDao.updateInvitationStatus(participant.getParticipantId(), normalizedDecision);
			}
		}

		response.sendRedirect("meetingDetail?meetingId=" + meetingId);
	}
}
