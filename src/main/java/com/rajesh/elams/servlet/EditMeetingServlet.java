package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingMode;
import com.rajesh.elams.model.MeetingParticipant;
import com.rajesh.elams.model.MeetingStatus;
import com.rajesh.elams.service.NotificationService;
import com.rajesh.elams.util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/editMeeting", "/editMeetingServlet", "/updateMeeting" })
public class EditMeetingServlet extends HttpServlet {

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
		if (!isAdminOrManager(session)) {
			response.sendRedirect("viewMeetings");
			return;
		}

		int meetingId = parseMeetingId(request);

		if (meetingId <= 0) {
			response.sendRedirect("viewMeetings");
			return;
		}

		Meeting meeting = meetingDao.getMeetingById(meetingId);

		if (meeting == null) {
			session.setAttribute("flashError", "Meeting not found.");
			response.sendRedirect("viewMeetings");
			return;
		}

		request.setAttribute("meeting", meeting);
		request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAdminOrManager(session)) {
			response.sendRedirect("viewMeetings");
			return;
		}

		int meetingId = parseMeetingId(request);
		if (meetingId <= 0) {
			response.sendRedirect("viewMeetings");
			return;
		}

		Meeting existingMeeting = meetingDao.getMeetingById(meetingId);
		if (existingMeeting == null) {
			session.setAttribute("flashError", "Meeting not found.");
			response.sendRedirect("viewMeetings");
			return;
		}

		String title = request.getParameter("title");
		String description = request.getParameter("description");
		String agenda = request.getParameter("agenda");
		String dateStr = request.getParameter("meetingDate");
		String startTimeStr = request.getParameter("startTime");
		String endTimeStr = request.getParameter("endTime");
		String meetingType = request.getParameter("meetingType");
		String modeStr = request.getParameter("meetingMode");
		String room = request.getParameter("room");
		String meetingLink = request.getParameter("meetingLink");
		String priority = request.getParameter("priority");
		String statusStr = request.getParameter("status");

		if (title == null || title.isBlank()) {
			request.setAttribute("errorMessage", "Meeting title is required.");
			request.setAttribute("meeting", existingMeeting);
			request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
			return;
		}

		if (dateStr == null || dateStr.isBlank() || startTimeStr == null || startTimeStr.isBlank()
				|| endTimeStr == null || endTimeStr.isBlank()) {
			request.setAttribute("errorMessage", "Meeting date, start time, and end time are required.");
			request.setAttribute("meeting", existingMeeting);
			request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
			return;
		}

		Time startTime = parseTime(startTimeStr);
		Time endTime = parseTime(endTimeStr);

		if (startTime == null || endTime == null) {
			request.setAttribute("errorMessage", "Invalid start or end time format.");
			request.setAttribute("meeting", existingMeeting);
			request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
			return;
		}

		if (!endTime.after(startTime)) {
			request.setAttribute("errorMessage", "End time must be strictly after start time.");
			request.setAttribute("meeting", existingMeeting);
			request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
			return;
		}

		MeetingMode mode = MeetingMode.OFFLINE;
		if (modeStr != null && !modeStr.isBlank()) {
			try {
				mode = MeetingMode.valueOf(modeStr.toUpperCase().trim());
			} catch (Exception ignored) {
			}
		}

		MeetingStatus status = existingMeeting.getStatus() != null ? existingMeeting.getStatus() : MeetingStatus.SCHEDULED;
		if (statusStr != null && !statusStr.isBlank()) {
			try {
				status = MeetingStatus.valueOf(statusStr.toUpperCase().trim());
			} catch (Exception ignored) {
			}
		}

		// Check for room conflict if room is specified and mode is OFFLINE or HYBRID
		if (mode != MeetingMode.ONLINE && room != null && !room.isBlank()) {
			if (meetingDao.hasRoomConflict(room, dateStr, startTimeStr, endTimeStr, meetingId)) {
				request.setAttribute("errorMessage", "Room \"" + room + "\" is already booked during this time slot.");
				request.setAttribute("meeting", existingMeeting);
				request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
				return;
			}
		}

		// Update fields
		existingMeeting.setTitle(title.trim());
		existingMeeting.setDescription(description != null ? description.trim() : "");
		existingMeeting.setAgenda(agenda != null ? agenda.trim() : "");
		existingMeeting.setMeetingDate(Date.valueOf(dateStr.trim()));
		existingMeeting.setStartTime(startTime);
		existingMeeting.setEndTime(endTime);
		existingMeeting.setMeetingType(meetingType != null ? meetingType.trim() : "Team Meeting");
		existingMeeting.setMeetingMode(mode);
		existingMeeting.setRoom(room != null ? room.trim() : "");
		existingMeeting.setMeetingLink(meetingLink != null ? meetingLink.trim() : "");
		existingMeeting.setPriority(priority != null ? priority.trim() : "Medium");
		existingMeeting.setStatus(status);

		boolean updated = meetingDao.updateMeeting(existingMeeting);

		if (updated) {
			// Notify participants about the update via In-App, Email, and Mobile SMS
			try {
				Employee loggedEmp = (Employee) session.getAttribute("employee");
				String senderName = loggedEmp != null ? loggedEmp.getEmployee_name() : "Management";

				List<MeetingParticipant> participants = participantDao.getParticipantsByMeeting(meetingId);
				if (participants != null && !participants.isEmpty()) {
					List<Employee> participantEmps = new java.util.ArrayList<>();
					for (MeetingParticipant p : participants) {
						Employee emp = employeeDao.getEmployeeById(p.getEmployeeId());
						if (emp != null) {
							participantEmps.add(emp);
						}
					}
					if (!participantEmps.isEmpty()) {
						notificationService.notifyMeetingUpdated(existingMeeting, senderName, participantEmps);
					}
				}
			} catch (Exception e) {
				System.err.println("[EditMeetingServlet] Error dispatching update notifications: " + e.getMessage());
			}

			session.setAttribute("flashSuccess", "Meeting details updated successfully.");
			response.sendRedirect("meetingDetail?meetingId=" + meetingId);
		} else {
			request.setAttribute("errorMessage", "Failed to update meeting details. Please try again.");
			request.setAttribute("meeting", existingMeeting);
			request.getRequestDispatcher("editMeeting.jsp").forward(request, response);
		}
	}

	private int parseMeetingId(HttpServletRequest request) {
		int id = ValidationUtil.parsePositiveInt(request.getParameter("meetingId"), 0);
		if (id <= 0) {
			id = ValidationUtil.parsePositiveInt(request.getParameter("id"), 0);
		}
		return id;
	}

	private Time parseTime(String timeStr) {
		if (timeStr == null || timeStr.isBlank()) {
			return null;
		}
		try {
			String t = timeStr.trim();
			if (t.length() == 5) {
				t += ":00";
			}
			return Time.valueOf(t);
		} catch (Exception e) {
			return null;
		}
	}

	private boolean isAdminOrManager(HttpSession session) {
		if (session == null) {
			return false;
		}
		String role = (String) session.getAttribute("role");
		return "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);
	}
}
