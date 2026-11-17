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

@WebServlet(urlPatterns = {"/manageMeetingRooms", "/managerMeetingRooms"})
public class ManagerMeetingRoomsServlets extends HttpServlet {

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

		request.setAttribute("rooms", roomDao.getAllRooms());

		request.getRequestDispatcher("managerMeetingRooms.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAuthorized(session)) {
			response.sendRedirect(session == null ? "login.jsp" : "employeeDashboardServlet");
			return;
		}

		String roomName = request.getParameter("roomName");
		String location = request.getParameter("location");
		String capacityParam = request.getParameter("capacity");

		String error = null;

		if (roomName == null || roomName.trim().isEmpty()) {
			error = "Room name cannot be empty.";
		} else if (roomDao.isDuplicateRoomName(roomName.trim(), null)) {
			error = "A meeting room named \"" + roomName.trim() + "\" already exists.";
		}

		if (error != null) {
			request.setAttribute("errorMessage", error);
			request.setAttribute("rooms", roomDao.getAllRooms());
			request.getRequestDispatcher("managerMeetingRooms.jsp").forward(request, response);
			return;
		}

		MeetingRoom room = new MeetingRoom();
		room.setRoomName(roomName.trim());
		room.setLocation(location == null || location.isBlank() ? null : location.trim());
		room.setCapacity(capacityParam == null || capacityParam.isBlank() ? null : Integer.valueOf(capacityParam));
		room.setStatus("ACTIVE");

		roomDao.createRoom(room);

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
