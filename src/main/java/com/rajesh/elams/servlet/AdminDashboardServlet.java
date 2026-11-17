package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.rajesh.elams.dao.AttendanceDao;
import com.rajesh.elams.dao.AttendanceDaoImpl;
import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.dao.MeetingDao;
import com.rajesh.elams.dao.MeetingDaoImpl;
import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;
import com.rajesh.elams.model.Meeting;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/adminDashboardServlet", "/adminDashboard" })
public class AdminDashboardServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDAO;
	private AttendanceDao attendanceDAO;
	private LeaveDao leaveDAO;
	private TaskDao taskDAO;
	private MeetingDao meetingDAO;

	@Override
	public void init() {
		employeeDAO = new EmployeeDaoImpl();
		attendanceDAO = new AttendanceDaoImpl();
		leaveDAO = new LeaveDaoImpl();
		taskDAO = new TaskDaoImpl();
		meetingDAO = new MeetingDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		Date today = new Date(System.currentTimeMillis());

		// 1. Employee Directory Stats
		List<Employee> allEmployees = employeeDAO.getAllEmployees();
		int employeeCount = allEmployees != null ? allEmployees.size() : 0;
		List<Employee> recentEmployees = new ArrayList<>();
		if (allEmployees != null && !allEmployees.isEmpty()) {
			int size = allEmployees.size();
			int fromIndex = Math.max(0, size - 5);
			recentEmployees = new ArrayList<>(allEmployees.subList(fromIndex, size));
			Collections.reverse(recentEmployees);
		}

		// 2. Attendance Stats
		int presentCount = attendanceDAO.getPresentCount(today);
		int absentCount = attendanceDAO.getAbsentCount(today);
		int halfDayCount = attendanceDAO.getHalfDayCount(today);

		// 3. Leave Requests
		List<Leave> pendingLeavesList = leaveDAO.getPendingLeaves();
		int pendingLeaves = pendingLeavesList != null ? pendingLeavesList.size() : 0;

		// 4. Task Metrics
		int totalTasks = taskDAO.totalTasks();
		int completedTasks = taskDAO.completedTasks();
		int pendingTasks = taskDAO.pendingTasks();
		int inProgressTasks = taskDAO.inProgressTasks();
		int overdueTasks = taskDAO.overdueTasks();
		int completionRate = totalTasks > 0 ? (completedTasks * 100) / totalTasks : 0;

		// 5. Meeting Metrics & Today's Schedule
		int totalMeetings = meetingDAO.totalMeetings();
		int upcomingMeetings = meetingDAO.upcomingMeetingsCount();
		List<Meeting> allMeetings = meetingDAO.getAllMeetings();
		List<Meeting> todayMeetings = new ArrayList<>();
		if (allMeetings != null) {
			for (Meeting m : allMeetings) {
				if (m.getMeetingDate() != null && m.getMeetingDate().toString().equals(today.toString())) {
					todayMeetings.add(m);
				}
			}
		}

		// Set request attributes
		request.setAttribute("employeeCount", employeeCount);
		request.setAttribute("allEmployees", allEmployees);
		request.setAttribute("recentEmployees", recentEmployees);

		request.setAttribute("presentCount", presentCount);
		request.setAttribute("absentCount", absentCount);
		request.setAttribute("halfDayCount", halfDayCount);

		request.setAttribute("pendingLeaves", pendingLeaves);
		request.setAttribute("pendingLeavesList", pendingLeavesList);

		request.setAttribute("totalTasks", totalTasks);
		request.setAttribute("completedTasks", completedTasks);
		request.setAttribute("pendingTasks", pendingTasks);
		request.setAttribute("inProgressTasks", inProgressTasks);
		request.setAttribute("overdueTasks", overdueTasks);
		request.setAttribute("completionRate", completionRate);

		request.setAttribute("totalMeetings", totalMeetings);
		request.setAttribute("upcomingMeetings", upcomingMeetings);
		request.setAttribute("todayMeetings", todayMeetings);

		try {
			com.rajesh.elams.service.PayrollService payrollService = new com.rajesh.elams.service.PayrollService();
			java.time.LocalDate now = java.time.LocalDate.now();
			com.rajesh.elams.model.PayrollSummary payrollSummary = payrollService.getPayrollSummary(now.getMonthValue(), now.getYear());
			request.setAttribute("payrollSummary", payrollSummary);
		} catch (Exception ignored) {}

		request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}