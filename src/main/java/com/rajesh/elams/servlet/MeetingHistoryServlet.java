package com.rajesh.elams.servlet;

import java.io.IOException;
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

@WebServlet("/meetingHistory")
public class MeetingHistoryServlet extends HttpServlet {
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

		String search = request.getParameter("search");
		String status = request.getParameter("status");
		String meetingType = request.getParameter("meetingType");
		String priority = request.getParameter("priority");
		String date = request.getParameter("date");

		List<Meeting> historyList;
		if (search != null || status != null || meetingType != null || priority != null || date != null) {
			historyList = meetingDao.searchMeetings(search, status, meetingType, priority, date);
		} else {
			historyList = meetingDao.getAllMeetings();
		}

		request.setAttribute("historyList", historyList);
		request.setAttribute("search", search);
		request.setAttribute("status", status);
		request.setAttribute("meetingType", meetingType);
		request.setAttribute("priority", priority);
		request.setAttribute("date", date);

		request.getRequestDispatcher("meetingHistory.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
