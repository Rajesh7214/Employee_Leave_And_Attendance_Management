package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.MeetingParticipantDao;
import com.rajesh.elams.dao.MeetingParticipantDaoImpl;
import com.rajesh.elams.dao.MeetingRoomDao;
import com.rajesh.elams.dao.MeetingRoomDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingMode;
import com.rajesh.elams.model.MeetingStatus;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/scheduleMeeting")
public class ScheduleMeetingServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingDao meetingDao;
	private MeetingParticipantDao participantDao;
	private EmployeeDao employeeDao;
	private MeetingRoomDao roomDao;
	private NotificationService notificationService;

	@Override
	public void init() {
		meetingDao = new MeetingDaoImpl();
		participantDao = new MeetingParticipantDaoImpl();
		employeeDao = new EmployeeDaoImpl();
		roomDao = new MeetingRoomDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAdminOrManager(session)) {
			if (session != null && session.getAttribute("loggedUser") != null) {
				response.sendRedirect("viewMeetings");
			} else {
				response.sendRedirect("login.jsp");
			}
			return;
		}

		User loggedUser = (User) session.getAttribute("loggedUser");
		String role = (String) session.getAttribute("role");

		Employee currentEmp = (Employee) session.getAttribute("employee");
		if (currentEmp == null && session.getAttribute("employeeId") != null) {
			currentEmp = employeeDao.getEmployeeById((Integer) session.getAttribute("employeeId"));
		}
		if (currentEmp == null && loggedUser != null && loggedUser.getEmail() != null) {
			currentEmp = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
		}
		if (currentEmp == null && loggedUser != null) {
			currentEmp = new Employee();
			String name = loggedUser.getEmail().split("@")[0];
			name = Character.toUpperCase(name.charAt(0)) + name.substring(1);
			currentEmp.setEmployee_name(name);
			currentEmp.setEmail(loggedUser.getEmail());
			currentEmp.setPhone(9999999999L);
			currentEmp.setDesignation(role != null ? role.toUpperCase() : "MANAGER");
			currentEmp.setDepartment("Management");
			currentEmp = employeeDao.addEmployee(currentEmp);
		}

		if (currentEmp != null) {
			session.setAttribute("employee", currentEmp);
			session.setAttribute("employeeId", currentEmp.getEmployee_id());
		}

		List<Employee> employees = employeeDao.getAllEmployees();

		request.setAttribute("employees", employees);
		request.setAttribute("rooms", roomDao.getAllRooms());
		request.setAttribute("organizer", currentEmp);
		request.setAttribute("userRole", role != null ? role.toUpperCase() : "MANAGER");

		request.getRequestDispatcher("scheduleMeeting.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAdminOrManager(session)) {
			if (session != null && session.getAttribute("loggedUser") != null) {
				response.sendRedirect("viewMeetings");
			} else {
				response.sendRedirect("login.jsp");
			}
			return;
		}

		User loggedUser = (User) session.getAttribute("loggedUser");
		String role = (String) session.getAttribute("role");
		String title = request.getParameter("title");
		String description = request.getParameter("description");
		String agenda = request.getParameter("agenda");
		String organizerIdParam = request.getParameter("organizerId");
		String meetingDateParam = request.getParameter("meetingDate");
		String startTimeParam = request.getParameter("startTime");
		String endTimeParam = request.getParameter("endTime");
		String meetingType = request.getParameter("meetingType");
		String meetingModeParam = request.getParameter("meetingMode");
		String room = request.getParameter("room");
		String meetingLink = request.getParameter("meetingLink");
		String priority = request.getParameter("priority");
		String[] participantIds = request.getParameterValues("participants");

		if (organizerIdParam == null || organizerIdParam.isBlank()) {
			Employee emp = (Employee) session.getAttribute("employee");
			if (emp != null) {
				organizerIdParam = String.valueOf(emp.getEmployee_id());
			} else if (session.getAttribute("employeeId") != null) {
				organizerIdParam = String.valueOf(session.getAttribute("employeeId"));
			} else {
				List<Employee> mgrs = "admin".equalsIgnoreCase(role) ? employeeDao.getAdminsOnly()
						: employeeDao.getManagersOnly();
				if (mgrs != null && !mgrs.isEmpty()) {
					organizerIdParam = String.valueOf(mgrs.get(0).getEmployee_id());
				} else {
					List<Employee> all = employeeDao.getAllEmployees();
					if (all != null && !all.isEmpty()) {
						organizerIdParam = String.valueOf(all.get(0).getEmployee_id());
					}
				}
			}
		}

		String error = validate(title, organizerIdParam, meetingDateParam, startTimeParam, endTimeParam,
				meetingModeParam, room, meetingLink);

		// Room conflict check
		if (error == null && ("OFFLINE".equals(meetingModeParam) || "HYBRID".equals(meetingModeParam))) {
			if (room != null && !room.isBlank()
					&& meetingDao.hasRoomConflict(room, meetingDateParam, startTimeParam, endTimeParam, null)) {
				error = "Room \"" + room + "\" is already booked for an overlapping time slot.";
			}
		}

		if (error != null) {
			List<Employee> employees = employeeDao.getAllEmployees();

			request.setAttribute("errorMessage", error);
			request.setAttribute("employees", employees);
			request.setAttribute("rooms", roomDao.getAllRooms());
			request.setAttribute("userRole", role != null ? role.toUpperCase() : "MANAGER");

			Employee currentEmp = (Employee) session.getAttribute("employee");
			if (currentEmp == null && loggedUser != null && loggedUser.getEmail() != null) {
				currentEmp = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
			}
			request.setAttribute("organizer", currentEmp);

			request.getRequestDispatcher("scheduleMeeting.jsp").forward(request, response);
			return;
		}

		Meeting meeting = new Meeting();
		meeting.setTitle(title);
		meeting.setDescription(description);
		meeting.setAgenda(agenda);
		meeting.setOrganizerId(Integer.parseInt(organizerIdParam));
		meeting.setMeetingDate(Date.valueOf(meetingDateParam));
		meeting.setStartTime(Time.valueOf(startTimeParam + (startTimeParam.length() == 5 ? ":00" : "")));
		meeting.setEndTime(Time.valueOf(endTimeParam + (endTimeParam.length() == 5 ? ":00" : "")));
		meeting.setMeetingType(meetingType);
		meeting.setMeetingMode(MeetingMode.valueOf(meetingModeParam));
		meeting.setRoom(room == null || room.isBlank() ? null : room);
		meeting.setMeetingLink(meetingLink == null || meetingLink.isBlank() ? null : meetingLink);
		meeting.setPriority(priority == null || priority.isBlank() ? "Normal" : priority);
		meeting.setStatus(MeetingStatus.SCHEDULED);

		int meetingId = meetingDao.createMeeting(meeting);

		if (meetingId > 0) {
			int orgId = meeting.getOrganizerId();
			boolean orgAdded = false;

			Employee organizer = employeeDao.getEmployeeById(orgId);
			String senderName = organizer != null ? organizer.getEmployee_name() : "Management";

			List<Employee> invitedParticipants = new java.util.ArrayList<>();
			if (participantIds != null) {
				for (String empId : participantIds) {
					try {
						int pId = Integer.parseInt(empId);
						participantDao.addParticipant(meetingId, pId);
						if (pId == orgId) {
							orgAdded = true;
						}

						Employee pEmp = employeeDao.getEmployeeById(pId);
						if (pEmp != null) {
							invitedParticipants.add(pEmp);
						}
					} catch (NumberFormatException ignored) {
					}
				}
			}

			if (!orgAdded) {
				participantDao.addParticipant(meetingId, orgId);
			}

			// Dispatch in-app notification, email and SMS notifications asynchronously to participants
			notificationService.notifyMeetingScheduled(meeting, senderName, invitedParticipants);

			String actor = loggedUser != null ? loggedUser.getEmail() : "Organizer";
			com.rajesh.elams.service.AuditService.logAction(actor, "SCHEDULE_MEETING", "Meetings", "MTG-" + meetingId, "Scheduled meeting: " + title, request.getRemoteAddr());
		}

		response.sendRedirect("viewMeetings");
	}

	private String validate(String title, String organizerId, String meetingDate, String startTime, String endTime,
			String meetingMode, String room, String meetingLink) {

		if (title == null || title.trim().isEmpty()) {
			return "Meeting title cannot be empty.";
		}
		if (organizerId == null || organizerId.isBlank()) {
			return "Organizer is mandatory.";
		}
		if (meetingDate == null || meetingDate.isBlank()) {
			return "Meeting date is required.";
		}
		if (LocalDate.parse(meetingDate).isBefore(LocalDate.now())) {
			return "Meeting date cannot be in the past.";
		}
		if (startTime == null || endTime == null || startTime.isBlank() || endTime.isBlank()) {
			return "Start time and end time are required.";
		}

		LocalTime start = LocalTime.parse(startTime);
		LocalTime end = LocalTime.parse(endTime);

		if (!start.isBefore(end)) {
			return "Start time must be before end time.";
		}
		if (ChronoUnit.MINUTES.between(start, end) <= 15) {
			return "Meeting duration must be greater than 15 minutes.";
		}
		if ("ONLINE".equals(meetingMode) && (meetingLink == null || meetingLink.isBlank())) {
			return "Online meetings require a meeting link.";
		}
		if ("OFFLINE".equals(meetingMode) && (room == null || room.isBlank())) {
			return "Offline meetings require a room.";
		}
		if ("HYBRID".equals(meetingMode)
				&& ((room == null || room.isBlank()) || (meetingLink == null || meetingLink.isBlank()))) {
			return "Hybrid meetings require both a room and a meeting link.";
		}

		return null;
	}

	private boolean isAdminOrManager(HttpSession session) {
		if (session == null) {
			return false;
		}
		String role = (String) session.getAttribute("role");
		return "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);
	}
}
