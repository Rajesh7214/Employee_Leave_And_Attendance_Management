package com.rajesh.elams.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.model.Meeting;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/exportMeetingReport")
public class ExportMeetingReportServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingDao meetingDao;

	@Override
	public void init() {
		meetingDao = new MeetingDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		List<Meeting> meetings = meetingDao.getAllMeetings();

		response.setContentType("text/csv");
		response.setHeader("Content-Disposition", "attachment; filename=\"Meeting_Report_" + LocalDate.now() + ".csv\"");

		try (PrintWriter writer = response.getWriter()) {
			writer.println("Meeting ID,Title,Type,Mode,Room/Link,Date,Start Time,End Time,Organizer ID,Priority,Status");

			if (meetings != null) {
				for (Meeting m : meetings) {
					String locationOrLink = m.getRoom() != null ? m.getRoom() : (m.getMeetingLink() != null ? m.getMeetingLink() : "");
					String modeStr = m.getMeetingMode() != null ? m.getMeetingMode().name() : "";
					String statusStr = m.getStatus() != null ? m.getStatus().name() : "";

					writer.printf("%d,\"%s\",\"%s\",\"%s\",\"%s\",%s,%s,%s,%d,\"%s\",\"%s\"\n",
							m.getMeetingId(),
							escapeCsv(m.getTitle()),
							escapeCsv(m.getMeetingType()),
							escapeCsv(modeStr),
							escapeCsv(locationOrLink),
							m.getMeetingDate(),
							m.getStartTime(),
							m.getEndTime(),
							m.getOrganizerId(),
							escapeCsv(m.getPriority()),
							escapeCsv(statusStr)
					);
				}
			}
			writer.flush();
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

	private String escapeCsv(String input) {
		if (input == null) return "";
		return input.replace("\"", "\"\"");
	}
}
