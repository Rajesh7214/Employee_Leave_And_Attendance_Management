package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/myMeetings")
public class MyMeetingsServlet extends HttpServlet {

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

		if (session == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		Employee employee = (Employee) session.getAttribute("employee");

		if (employee == null) {
			request.setAttribute("errorMessage", "No employee profile is linked to this account.");
			request.setAttribute("meetings", java.util.Collections.emptyList());
			request.getRequestDispatcher("myMeetings.jsp").forward(request, response);
			return;
		}

		request.setAttribute("meetings", meetingDao.getMeetingsByEmployee(employee.getEmployee_id()));
		request.setAttribute("currentEmployeeId", employee.getEmployee_id());

		request.getRequestDispatcher("myMeetings.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
