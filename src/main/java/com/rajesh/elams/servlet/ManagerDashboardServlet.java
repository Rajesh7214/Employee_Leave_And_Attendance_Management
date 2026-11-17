package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
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
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.Priority;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.model.TaskStatus;
import com.rajesh.elams.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/managerDashboard", "/managerDashboardServlet" })
public class ManagerDashboardServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;
	private EmployeeDao employeeDao;
	private LeaveDao leaveDao;
	private AttendanceDao attendanceDao;
	private MeetingDao meetingDao;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
		employeeDao = new EmployeeDaoImpl();
		leaveDao = new LeaveDaoImpl();
		attendanceDao = new AttendanceDaoImpl();
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

		User manager = (User) session.getAttribute("loggedUser");
		String role = (String) session.getAttribute("role");
		if (manager == null || role == null || (!"manager".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role))) {
			response.sendRedirect("login.jsp");
			return;
		}

		Date today = new Date(System.currentTimeMillis());

		// 1. Task Operations
		int totalTasks = taskDao.totalTasks();
		int pendingTasks = taskDao.pendingTasks();
		int inProgressTasks = taskDao.inProgressTasks();
		int completedTasks = taskDao.completedTasks();
		int overdueTasks = taskDao.overdueTasks();
		int completionRate = totalTasks > 0 ? (completedTasks * 100) / totalTasks : 0;

		List<Task> allTasks = taskDao.getAllTasks();
		List<Task> highPriorityTasks = new ArrayList<>();
		if (allTasks != null) {
			for (Task t : allTasks) {
				if (t.getPriority() == Priority.HIGH && t.getStatus() != TaskStatus.COMPLETED) {
					highPriorityTasks.add(t);
				}
			}
		}

		// 2. Team Members
		List<Employee> teamMembers = employeeDao.getAllEmployees();

		// 3. Pending Leaves
		List<Leave> pendingLeaves = leaveDao.getPendingLeaves();

		// 4. Today's Attendance Pulse
		int todayPresent = attendanceDao.getPresentCount(today);
		int todayAbsent = attendanceDao.getAbsentCount(today);
		int todayHalfDay = attendanceDao.getHalfDayCount(today);

		// 5. Meetings
		int totalMeetings = meetingDao.totalMeetings();
		int upcomingMeetings = meetingDao.upcomingMeetingsCount();
		List<Meeting> allMeetings = meetingDao.getAllMeetings();
		List<Meeting> todayMeetings = new ArrayList<>();
		if (allMeetings != null) {
			for (Meeting m : allMeetings) {
				if (m.getMeetingDate() != null && m.getMeetingDate().toString().equals(today.toString())) {
					todayMeetings.add(m);
				}
			}
		}

		request.setAttribute("totalTasks", totalTasks);
		request.setAttribute("pendingTasks", pendingTasks);
		request.setAttribute("inProgressTasks", inProgressTasks);
		request.setAttribute("completedTasks", completedTasks);
		request.setAttribute("overdueTasks", overdueTasks);
		request.setAttribute("completionRate", completionRate);
		request.setAttribute("highPriorityTasks", highPriorityTasks);

		request.setAttribute("teamMembers", teamMembers);
		request.setAttribute("totalEmployees", teamMembers != null ? teamMembers.size() : 0);

		request.setAttribute("pendingLeaves", pendingLeaves);
		request.setAttribute("pendingLeavesCount", pendingLeaves != null ? pendingLeaves.size() : 0);

		request.setAttribute("todayPresent", todayPresent);
		request.setAttribute("todayAbsent", todayAbsent);
		request.setAttribute("todayHalfDay", todayHalfDay);

		request.setAttribute("totalMeetings", totalMeetings);
		request.setAttribute("upcomingMeetings", upcomingMeetings);
		request.setAttribute("todayMeetings", todayMeetings);

		// 6. Team Salary & Payroll Summary
		com.rajesh.elams.service.PayrollService payrollService = new com.rajesh.elams.service.PayrollService();
		int curMonth = java.time.LocalDate.now().getMonthValue();
		int curYear = java.time.LocalDate.now().getYear();
		com.rajesh.elams.model.PayrollSummary teamPayrollSummary = payrollService.getPayrollSummary(curMonth, curYear);
		List<com.rajesh.elams.model.Payroll> teamPayrolls = payrollService.getPayrollsByMonth(curMonth, curYear);

		request.setAttribute("teamPayrollSummary", teamPayrollSummary);
		request.setAttribute("teamPayrolls", teamPayrolls);
		request.setAttribute("curMonthName", java.time.Month.of(curMonth).getDisplayName(java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH));
		request.setAttribute("curYear", curYear);

		request.getRequestDispatcher("managerDashboard.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
