package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
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

@WebServlet("/calendarView")
public class CalendarViewServlet extends HttpServlet {
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

		String view = request.getParameter("view");
		if (view == null || view.isBlank()) {
			view = "weekly";
		}

		String dateStr = request.getParameter("date");
		LocalDate selectedDate;
		try {
			selectedDate = (dateStr != null && !dateStr.isBlank()) ? LocalDate.parse(dateStr) : LocalDate.now();
		} catch (Exception e) {
			selectedDate = LocalDate.now();
		}

		LocalDate startDate = selectedDate;
		LocalDate endDate = selectedDate;

		if ("daily".equalsIgnoreCase(view)) {
			startDate = selectedDate;
			endDate = selectedDate;
		} else if ("weekly".equalsIgnoreCase(view)) {
			startDate = selectedDate.minusDays(selectedDate.getDayOfWeek().getValue() - 1);
			endDate = startDate.plusDays(6);
		} else if ("monthly".equalsIgnoreCase(view)) {
			startDate = selectedDate.withDayOfMonth(1);
			endDate = selectedDate.withDayOfMonth(selectedDate.lengthOfMonth());
		}

		List<Meeting> meetings = meetingDao.getAllMeetings(); // Or get range

		request.setAttribute("view", view.toLowerCase());
		request.setAttribute("selectedDate", selectedDate.toString());
		request.setAttribute("startDate", startDate.toString());
		request.setAttribute("endDate", endDate.toString());
		request.setAttribute("meetings", meetings);

		request.getRequestDispatcher("calendarView.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
