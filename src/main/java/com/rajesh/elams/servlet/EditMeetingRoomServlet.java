package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.MeetingRoomDao;
import com.rajesh.elams.dao.MeetingRoomDaoImpl;
import com.rajesh.elams.model.MeetingRoom;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/editMeetingRoom", "/editMeetingRooms"})
public class EditMeetingRoomServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private MeetingRoomDao roomDao;

	@Override
	public void init() {
		roomDao = new MeetingRoomDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAuthorized(session)) {
			response.sendRedirect(session == null ? "login.jsp" : "employeeDashboardServlet");
			return;
		}

		String roomIdParam = request.getParameter("roomId");
		if (roomIdParam == null || roomIdParam.isBlank()) {
			response.sendRedirect("manageMeetingRooms");
			return;
		}

		try {
			int roomId = Integer.parseInt(roomIdParam.trim());
			MeetingRoom room = roomDao.getRoomById(roomId);
			if (room == null) {
				response.sendRedirect("manageMeetingRooms");
				return;
			}
			request.setAttribute("room", room);
			request.getRequestDispatcher("editMeetingRooms.jsp").forward(request, response);
		} catch (NumberFormatException e) {
			response.sendRedirect("manageMeetingRooms");
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAuthorized(session)) {
			response.sendRedirect(session == null ? "login.jsp" : "employeeDashboardServlet");
			return;
		}

		String roomIdParam = request.getParameter("roomId");
		String roomName = request.getParameter("roomName");
		String location = request.getParameter("location");
		String capacityParam = request.getParameter("capacity");
		String status = request.getParameter("status");

		if (roomIdParam == null || roomIdParam.isBlank()) {
			response.sendRedirect("manageMeetingRooms");
			return;
		}

		int roomId;
		try {
			roomId = Integer.parseInt(roomIdParam.trim());
		} catch (NumberFormatException e) {
			response.sendRedirect("manageMeetingRooms");
			return;
		}

		String error = null;
		if (roomName == null || roomName.trim().isEmpty()) {
			error = "Room name cannot be empty.";
		} else if (roomDao.isDuplicateRoomName(roomName.trim(), roomId)) {
			error = "A meeting room named \"" + roomName.trim() + "\" already exists.";
		}

		if (error != null) {
			MeetingRoom existing = roomDao.getRoomById(roomId);
			if (existing == null) {
				existing = new MeetingRoom();
				existing.setRoomId(roomId);
			}
			existing.setRoomName(roomName != null ? roomName.trim() : "");
			existing.setLocation(location != null ? location.trim() : "");
			try {
				existing.setCapacity(capacityParam != null && !capacityParam.isBlank() ? Integer.parseInt(capacityParam.trim()) : null);
			} catch (Exception ignored) {}
			existing.setStatus(status != null ? status.trim() : "ACTIVE");

			request.setAttribute("errorMessage", error);
			request.setAttribute("room", existing);
			request.getRequestDispatcher("editMeetingRooms.jsp").forward(request, response);
			return;
		}

		MeetingRoom room = new MeetingRoom();
		room.setRoomId(roomId);
		room.setRoomName(roomName.trim());
		room.setLocation(location == null || location.isBlank() ? null : location.trim());
		room.setCapacity(capacityParam == null || capacityParam.isBlank() ? null : Integer.valueOf(capacityParam.trim()));
		room.setStatus(status == null || status.isBlank() ? "ACTIVE" : status.trim());

		roomDao.updateRoom(room);

		response.sendRedirect("manageMeetingRooms");
	}

	private boolean isAuthorized(HttpSession session) {
		if (session == null) {
			return false;
		}
		String role = (String) session.getAttribute("role");
		return "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);
	}
}
