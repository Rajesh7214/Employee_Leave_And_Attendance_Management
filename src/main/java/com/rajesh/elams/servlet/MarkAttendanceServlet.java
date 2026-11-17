package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.Enumeration;

import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.model.MeetingParticipant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/markMeetingAttendance")
public class MarkAttendanceServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingParticipantDao participantDao;

	@Override
	public void init() {
		participantDao = new MeetingParticipantDaoImpl();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String role = session == null ? null : (String) session.getAttribute("role");

		if (session == null || !("admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
			response.sendRedirect("employeeDashboard.jsp");
			return;
		}

		String meetingIdParam = request.getParameter("meetingId");
		int meetingId = 0;
		if (meetingIdParam != null && !meetingIdParam.isBlank()) {
			try {
				meetingId = Integer.parseInt(meetingIdParam.trim());
			} catch (NumberFormatException ignored) {
			}
		}

		// 1. Single participant update mode
		String singlePartIdParam = request.getParameter("participantId");
		String singleAttendance = request.getParameter("attendance");

		if (singlePartIdParam != null && !singlePartIdParam.isBlank()) {
			try {
				int participantId = Integer.parseInt(singlePartIdParam.trim());
				if (singleAttendance != null && !singleAttendance.isBlank()) {
					participantDao.updateAttendance(participantId, singleAttendance.trim());
				}
			} catch (NumberFormatException ignored) {
			}
		}

		// 2. Batch participant update mode (parameters like attendance_123)
		if (meetingId > 0) {
			Enumeration<String> paramNames = request.getParameterNames();
			while (paramNames.hasMoreElements()) {
				String paramName = paramNames.nextElement();
				if (paramName.startsWith("attendance_")) {
					String empIdStr = paramName.substring("attendance_".length());
					try {
						int empId = Integer.parseInt(empIdStr);
						String attVal = request.getParameter(paramName);
						if (attVal != null && !attVal.isBlank()) {
							MeetingParticipant p = participantDao.getParticipant(meetingId, empId);
							if (p != null) {
								participantDao.updateAttendance(p.getParticipantId(), attVal.trim());
							}
						}
					} catch (NumberFormatException ignored) {
					}
				}
			}
		}

		if (meetingId > 0) {
			response.sendRedirect("meetingDetail?meetingId=" + meetingId);
		} else {
			response.sendRedirect("viewMeetings");
		}
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}
}
