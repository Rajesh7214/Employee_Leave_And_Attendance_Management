package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.MeetingNoteDao;
import com.rajesh.elams.dao.MeetingNoteDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.MeetingNote;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/uploadMeetingNotes")
public class UploadMeetingNotesServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingNoteDao noteDao;

	@Override
	public void init() {
		noteDao = new MeetingNoteDaoImpl();
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

		int meetingId = Integer.parseInt(request.getParameter("meetingId"));
		String summary = request.getParameter("summary");
		String actionItems = request.getParameter("actionItems");

		Employee employee = (Employee) session.getAttribute("employee");
		int uploadedBy = employee != null ? employee.getEmployee_id() : 0;

		MeetingNote note = new MeetingNote();
		note.setMeetingId(meetingId);
		note.setSummary(summary);
		note.setActionItems(actionItems);
		note.setUploadedBy(uploadedBy);

		noteDao.addNote(note);

		response.sendRedirect("meetingDetail?meetingId=" + meetingId);
	}
}
