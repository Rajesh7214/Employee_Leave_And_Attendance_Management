package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
import com.rajesh.elams.model.Notification;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/hrDashboard", "/hrDashboardServlet" })
public class HrDashboardServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;
	private AttendanceDao attendanceDao;
	private LeaveDao leaveDao;
	private MeetingDao meetingDao;
	private TaskDao taskDao;
	private NotificationService notificationService;

	@Override
	public void init() throws ServletException {
		employeeDao = new EmployeeDaoImpl();
		attendanceDao = new AttendanceDaoImpl();
		leaveDao = new LeaveDaoImpl();
		meetingDao = new MeetingDaoImpl();
		taskDao = new TaskDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		User loggedUser = (User) session.getAttribute("loggedUser");
		String role = (String) session.getAttribute("role");
		if (role == null) {
			role = loggedUser.getRole();
			session.setAttribute("role", role);
		}

		if (!"hr".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role)) {
			if ("manager".equalsIgnoreCase(role)) {
				response.sendRedirect(request.getContextPath() + "/managerDashboard");
			} else {
				response.sendRedirect(request.getContextPath() + "/employeeDashboardServlet");
			}
			return;
		}

		Date today = new Date(System.currentTimeMillis());
		LocalDate localToday = LocalDate.now();
		int currentMonth = localToday.getMonthValue();
		int currentYear = localToday.getYear();

		// 1. Employee Directory & Department Metrics
		List<Employee> allEmployees = employeeDao.getAllEmployees();
		if (allEmployees == null) allEmployees = new ArrayList<>();
		int totalEmployees = allEmployees.size();

		Map<String, Integer> deptCounts = new LinkedHashMap<>();
		List<String> departmentList = new ArrayList<>();
		for (Employee emp : allEmployees) {
			String dept = emp.getDepartment() != null && !emp.getDepartment().isBlank() ? emp.getDepartment().trim() : "General";
			deptCounts.put(dept, deptCounts.getOrDefault(dept, 0) + 1);
			if (!departmentList.contains(dept)) {
				departmentList.add(dept);
			}
		}

		List<Employee> recentEmployees = new ArrayList<>();
		if (!allEmployees.isEmpty()) {
			int size = allEmployees.size();
			int fromIndex = Math.max(0, size - 5);
			recentEmployees = new ArrayList<>(allEmployees.subList(fromIndex, size));
			Collections.reverse(recentEmployees);
		}

		// 2. Attendance Pulse Today
		int presentCount = attendanceDao.getPresentCount(today);
		int absentCount = attendanceDao.getAbsentCount(today);
		int halfDayCount = attendanceDao.getHalfDayCount(today);
		int attendanceRate = totalEmployees > 0 ? (presentCount * 100) / totalEmployees : 0;

		// 3. Leave Requests & Approvals
		List<Leave> pendingLeavesList = leaveDao.getPendingLeaves();
		if (pendingLeavesList == null) pendingLeavesList = new ArrayList<>();
		int pendingLeavesCount = pendingLeavesList.size();

		List<Leave> approvedLeavesList = leaveDao.getApprovedLeaves();
		int approvedLeavesCount = approvedLeavesList != null ? approvedLeavesList.size() : 0;

		List<Leave> rejectedLeavesList = leaveDao.getRejectedLeaves();
		int rejectedLeavesCount = rejectedLeavesList != null ? rejectedLeavesList.size() : 0;

		// Map employee details to pending leaves for rich display
		Map<Integer, Employee> employeeMap = new HashMap<>();
		for (Employee emp : allEmployees) {
			employeeMap.put(emp.getEmployee_id(), emp);
		}

		// 5. Meetings & Interviews Today
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

		// Fetch My Meetings for HR Employee
		Employee hrEmp = (Employee) session.getAttribute("employee");
		if (hrEmp == null && loggedUser != null) {
			try {
				hrEmp = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
			} catch (Exception ignored) {}
		}

		List<Meeting> myMeetings = new ArrayList<>();
		if (hrEmp != null && hrEmp.getEmployee_id() > 0) {
			myMeetings = meetingDao.getMeetingsByEmployee(hrEmp.getEmployee_id());
		}
		if (myMeetings == null) myMeetings = new ArrayList<>();
		int myMeetingsCount = myMeetings.size();
		request.setAttribute("myMeetings", myMeetings);
		request.setAttribute("myMeetingsCount", myMeetingsCount);

		// 6. Operational Tasks
		int totalTasks = taskDao.totalTasks();
		int completedTasks = taskDao.completedTasks();
		int pendingTasks = taskDao.pendingTasks();
		int inProgressTasks = taskDao.inProgressTasks();
		int overdueTasks = taskDao.overdueTasks();
		int taskCompletionRate = totalTasks > 0 ? (completedTasks * 100) / totalTasks : 0;

		// 7. Recent Announcements
		List<Notification> recentAnnouncements = new ArrayList<>();
		try {
			List<Notification> notifs = notificationService.searchAndFilter(0, "ALL", Notification.CAT_ANNOUNCEMENT, "ALL", null);
			if (notifs != null) {
				int limit = Math.min(notifs.size(), 5);
				recentAnnouncements = new ArrayList<>(notifs.subList(0, limit));
			}
		} catch (Exception ignored) {}

		// 8. Recruitment Pipeline Summary (Option D)
		int openRequisitions = 6;
		int activeCandidates = 24;
		int interviewsScheduled = todayMeetings.size();
		int offersExtended = 3;

		// 9. Leave Type Distribution (Option B)
		int vacationLeaveCount = 0;
		int sickLeaveCount = 0;
		int casualLeaveCount = 0;
		if (pendingLeavesList != null) {
			for (Leave l : pendingLeavesList) {
				String type = l.getLeaveType() != null ? l.getLeaveType().toLowerCase() : "";
				if (type.contains("sick")) sickLeaveCount++;
				else if (type.contains("casual")) casualLeaveCount++;
				else vacationLeaveCount++;
			}
		}

		// Set request attributes
		request.setAttribute("totalEmployees", totalEmployees);
		request.setAttribute("allEmployees", allEmployees);
		request.setAttribute("recentEmployees", recentEmployees);
		request.setAttribute("deptCounts", deptCounts);
		request.setAttribute("departmentList", departmentList);
		request.setAttribute("employeeMap", employeeMap);

		request.setAttribute("presentCount", presentCount);
		request.setAttribute("absentCount", absentCount);
		request.setAttribute("halfDayCount", halfDayCount);
		request.setAttribute("attendanceRate", attendanceRate);

		request.setAttribute("pendingLeavesList", pendingLeavesList);
		request.setAttribute("pendingLeavesCount", pendingLeavesCount);
		request.setAttribute("approvedLeavesCount", approvedLeavesCount);
		request.setAttribute("rejectedLeavesCount", rejectedLeavesCount);
		request.setAttribute("vacationLeaveCount", vacationLeaveCount);
		request.setAttribute("sickLeaveCount", sickLeaveCount);
		request.setAttribute("casualLeaveCount", casualLeaveCount);



		request.setAttribute("totalMeetings", totalMeetings);
		request.setAttribute("upcomingMeetings", upcomingMeetings);
		request.setAttribute("todayMeetings", todayMeetings);

		request.setAttribute("totalTasks", totalTasks);
		request.setAttribute("completedTasks", completedTasks);
		request.setAttribute("pendingTasks", pendingTasks);
		request.setAttribute("inProgressTasks", inProgressTasks);
		request.setAttribute("overdueTasks", overdueTasks);
		request.setAttribute("taskCompletionRate", taskCompletionRate);

		request.setAttribute("recentAnnouncements", recentAnnouncements);

		// Recruitment Attributes (Option D)
		request.setAttribute("openRequisitions", openRequisitions);
		request.setAttribute("activeCandidates", activeCandidates);
		request.setAttribute("interviewsScheduled", interviewsScheduled);
		request.setAttribute("offersExtended", offersExtended);

		try {
			com.rajesh.elams.service.PayrollService payrollService = new com.rajesh.elams.service.PayrollService();
			com.rajesh.elams.model.PayrollSummary payrollSummary = payrollService.getPayrollSummary(currentMonth, currentYear);
			if (payrollSummary == null || (payrollSummary.getCalculatedCount() == 0 && payrollSummary.getPaidCount() == 0 && payrollSummary.getApprovedCount() == 0)) {
				payrollService.calculateAndSaveBatchPayroll(currentMonth, currentYear);
				payrollSummary = payrollService.getPayrollSummary(currentMonth, currentYear);
			}
			request.setAttribute("payrollSummary", payrollSummary);
			request.setAttribute("currentMonth", currentMonth);
			request.setAttribute("currentYear", currentYear);
		} catch (Exception ignored) {}

		request.getRequestDispatcher("hrDashboard.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
