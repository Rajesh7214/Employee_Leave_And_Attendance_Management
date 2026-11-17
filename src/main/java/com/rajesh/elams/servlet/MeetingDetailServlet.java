package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.MeetingAttachmentDao;
import com.rajesh.elams.dao.MeetingAttachmentDaoImpl;
import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.MeetingNoteDao;
import com.rajesh.elams.dao.MeetingNoteDaoImpl;
import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingAttachment;
import com.rajesh.elams.model.MeetingNote;
import com.rajesh.elams.model.MeetingParticipant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


@WebServlet(urlPatterns = { "/meetingDetail", "/meetingDetails", "/meetingDetailServlet", "/meetingDetailsServlet" })
public class MeetingDetailServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingDao meetingDao;
	private MeetingParticipantDao participantDao;
	private MeetingNoteDao noteDao;
	private MeetingAttachmentDao attachmentDao;

	@Override
	public void init() {
		meetingDao = new MeetingDaoImpl();
		participantDao = new MeetingParticipantDaoImpl();
		noteDao = new MeetingNoteDaoImpl();
		attachmentDao = new MeetingAttachmentDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String idParam = request.getParameter("meetingId");
		if (idParam == null || idParam.trim().isEmpty()) {
			idParam = request.getParameter("id");
		}

		if (idParam == null || idParam.trim().isEmpty()) {
			response.sendRedirect("viewMeetings");
			return;
		}

		int meetingId;
		try {
			meetingId = Integer.parseInt(idParam.trim());
		} catch (NumberFormatException e) {
			response.sendRedirect("viewMeetings");
			return;
		}

		Meeting meeting = meetingDao.getMeetingById(meetingId);

		if (meeting == null) {
			response.sendRedirect("viewMeetings");
			return;
		}

		List<MeetingParticipant> participants = participantDao.getParticipantsByMeeting(meetingId);
		List<MeetingNote> notesList = noteDao.getNotesByMeeting(meetingId);
		MeetingNote singleNote = (notesList != null && !notesList.isEmpty()) ? notesList.get(0) : null;
		List<MeetingAttachment> attachments = attachmentDao.getAttachmentsByMeeting(meetingId);

		String role = (String) session.getAttribute("role");
		Employee loggedEmp = (Employee) session.getAttribute("employee");
		int currentEmpId = loggedEmp != null ? loggedEmp.getEmployee_id() : -1;

		boolean isOrganizerOrAdmin = "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role)
				|| (meeting.getOrganizerId() == currentEmpId);

		String myInvitationStatus = "Pending";
		if (participants != null) {
			for (MeetingParticipant p : participants) {
				if (p.getEmployeeId() == currentEmpId) {
					myInvitationStatus = p.getInvitationStatus() != null ? p.getInvitationStatus().name() : "Pending";
					break;
				}
			}
		}

		request.setAttribute("meeting", meeting);
		request.setAttribute("participants", participants);
		request.setAttribute("notes", notesList);
		request.setAttribute("meetingNote", singleNote);
		request.setAttribute("attachments", attachments);
		request.setAttribute("role", role);
		request.setAttribute("isOrganizerOrAdmin", Boolean.valueOf(isOrganizerOrAdmin));
		request.setAttribute("myInvitationStatus", myInvitationStatus);

		request.getRequestDispatcher("meetingDetails.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
