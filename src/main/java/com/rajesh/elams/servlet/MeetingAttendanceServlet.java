package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingParticipant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/meetingAttendance")
public class MeetingAttendanceServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private MeetingDao meetingDao;
	private MeetingParticipantDao participantDao;

	@Override
	public void init() {
		meetingDao = new MeetingDaoImpl();
		participantDao = new MeetingParticipantDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String meetingIdParam = request.getParameter("meetingId");
		if (meetingIdParam == null || meetingIdParam.isBlank()) {
			response.sendRedirect("viewMeetings");
			return;
		}

		try {
			int meetingId = Integer.parseInt(meetingIdParam);
			Meeting meeting = meetingDao.getMeetingById(meetingId);
			List<MeetingParticipant> participants = participantDao.getParticipantsByMeeting(meetingId);

			request.setAttribute("meeting", meeting);
			request.setAttribute("participants", participants);

			request.getRequestDispatcher("meetingAttendance.jsp").forward(request, response);
		} catch (Exception e) {
			response.sendRedirect("viewMeetings");
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String meetingIdParam = request.getParameter("meetingId");
		String participantIdParam = request.getParameter("participantId");
		String attendance = request.getParameter("attendance"); // PRESENT, ABSENT, LATE, EXCUSED

		if (participantIdParam != null && attendance != null) {
			try {
				int participantId = Integer.parseInt(participantIdParam);
				participantDao.updateAttendance(participantId, attendance.toUpperCase());
			} catch (Exception ignored) {}
		}

		response.sendRedirect("meetingAttendance?meetingId=" + meetingIdParam);
	}
}
