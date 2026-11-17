package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;

import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/meetingReports")
public class MeetingReportsServlet extends HttpServlet {

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

		HttpSession session = request.getSession(false);
		if (!isAuthorized(session)) {
			response.sendRedirect(session == null ? "login.jsp" : "employeeDashboardServlet");
			return;
		}

		String range = request.getParameter("range");
		if (range == null || range.isBlank()) {
			range = "monthly";
		}

		LocalDate today = LocalDate.now();
		LocalDate from;
		LocalDate to = today;

		switch (range) {
		case "daily":
			from = today;
			break;
		case "weekly":
			from = today.minusDays(6);
			break;
		default:
			range = "monthly";
			from = today.minusDays(29);
			break;
		}

		String fromParam = request.getParameter("fromDate");
		String toParam = request.getParameter("toDate");

		if (fromParam != null && !fromParam.isBlank() && toParam != null && !toParam.isBlank()) {
			from = LocalDate.parse(fromParam);
			to = LocalDate.parse(toParam);
			range = "custom";
		}

		request.setAttribute("range", range);
		request.setAttribute("fromDate", from.toString());
		request.setAttribute("toDate", to.toString());

		request.setAttribute("rangeMeetings", meetingDao.getMeetingsBetweenDates(from.toString(), to.toString()));
		request.setAttribute("totalMeetings", meetingDao.totalMeetings());
		request.setAttribute("upcomingMeetings", meetingDao.upcomingMeetingsCount());
		request.setAttribute("completedMeetings", meetingDao.completedMeetingsCount());
		request.setAttribute("cancelledMeetings", meetingDao.cancelledMeetingsCount());

		request.setAttribute("missedMeetings", meetingDao.getMissedMeetings());
		request.setAttribute("durationAnalysis", meetingDao.getDurationAnalysis());

		request.setAttribute("employeeWiseCounts", participantDao.getEmployeeWiseMeetingCounts());
		request.setAttribute("departmentWiseCounts", participantDao.getDepartmentWiseMeetingCounts());
		request.setAttribute("attendanceSummary", participantDao.getAttendanceSummary());

		request.getRequestDispatcher("meetingReports.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

	private boolean isAuthorized(HttpSession session) {

		if (session == null) {
			return false;
		}

		String role = (String) session.getAttribute("role");

		return "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);
	}
}
