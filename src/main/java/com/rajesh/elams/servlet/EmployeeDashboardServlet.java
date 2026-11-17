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
import com.rajesh.elams.model.Attendance;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.model.TaskStatus;
import com.rajesh.elams.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/employeeDashboardServlet", "/employeeDashboard" })
public class EmployeeDashboardServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;
	private AttendanceDao attendanceDao;
	private LeaveDao leaveDao;
	private TaskDao taskDao;
	private MeetingDao meetingDao;

	@Override
	public void init() throws ServletException {
		employeeDao = new EmployeeDaoImpl();
		attendanceDao = new AttendanceDaoImpl();
		leaveDao = new LeaveDaoImpl();
		taskDao = new TaskDaoImpl();
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

		User loggedUser = (User) session.getAttribute("loggedUser");
		if (loggedUser == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String role = (String) session.getAttribute("role");
		if (role == null) {
			role = loggedUser.getRole();
			session.setAttribute("role", role);
		}

		if ("manager".equalsIgnoreCase(role)) {
			response.sendRedirect("managerDashboard");
			return;
		} else if ("admin".equalsIgnoreCase(role)) {
			response.sendRedirect("adminDashboardServlet");
			return;
		} else if ("hr".equalsIgnoreCase(role)) {
			response.sendRedirect("hrDashboard");
			return;
		}

		// 1. Resolve Employee Profile
		Employee employee = (Employee) session.getAttribute("employee");
		if (employee == null) {
			try {
				employee = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
				if (employee != null) {
					session.setAttribute("employee", employee);
					session.setAttribute("employeeId", employee.getEmployee_id());
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		int empId = employee != null ? employee.getEmployee_id() : -1;
		Date today = new Date(System.currentTimeMillis());

		// 2. Resolve Today's Attendance & Status
		Attendance todayAttendance = null;
		int totalPresentDays = 0;
		List<Attendance> recentAttendance = new ArrayList<>();

		if (empId > 0) {
			List<Attendance> allEmpAttendance = attendanceDao.getAttendanceByEmployee(empId);
			if (allEmpAttendance != null) {
				for (Attendance att : allEmpAttendance) {
					if (att.getAttendance_date() != null && att.getAttendance_date().toString().equals(today.toString())) {
						todayAttendance = att;
					}
					if ("Present".equalsIgnoreCase(att.getStatus()) || "Late".equalsIgnoreCase(att.getStatus())
							|| "Half Day".equalsIgnoreCase(att.getStatus()) || "Checked In".equalsIgnoreCase(att.getStatus())) {
						totalPresentDays++;
					}
				}
				// Recent 5 attendance records
				int size = allEmpAttendance.size();
				int fromIndex = Math.max(0, size - 5);
				recentAttendance = new ArrayList<>(allEmpAttendance.subList(fromIndex, size));
				Collections.reverse(recentAttendance);
			}
		}

		// Work status derivation
		String workStatus = "NOT_CHECKED_IN";
		if (todayAttendance != null) {
			if (todayAttendance.getCheck_out_time() != null) {
				workStatus = "CHECKED_OUT";
			} else if (todayAttendance.getBreak_start_time() != null && todayAttendance.getBreak_end_time() == null) {
				workStatus = "ON_BREAK";
			} else if (todayAttendance.getCheck_in_time() != null) {
				workStatus = "WORKING";
			}
		}

		// 3. Resolve Tasks Assigned to this Employee
		List<Task> myTasks = new ArrayList<>();
		int myTotalTasks = 0;
		int myPendingTasks = 0;
		int myInProgressTasks = 0;
		int myCompletedTasks = 0;
		int myOverdueTasks = 0;

		if (empId > 0) {
			List<Task> empTasks = taskDao.getTasksByEmployee(empId);
			if (empTasks != null) {
				myTasks = empTasks;
				myTotalTasks = empTasks.size();
				for (Task t : empTasks) {
					if (t.getStatus() == TaskStatus.COMPLETED) {
						myCompletedTasks++;
					} else if (t.getStatus() == TaskStatus.IN_PROGRESS) {
						myInProgressTasks++;
					} else {
						myPendingTasks++;
					}

					if (t.getDueDate() != null && t.getDueDate().before(today) && t.getStatus() != TaskStatus.COMPLETED) {
						myOverdueTasks++;
					}
				}
			}
		}

		// 4. Resolve Leaves for this Employee
		List<Leave> myLeaves = new ArrayList<>();
		int leavesApprovedCount = 0;
		int leavesPendingCount = 0;
		int leavesRejectedCount = 0;

		if (empId > 0) {
			List<Leave> empLeaves = leaveDao.getLeavesByEmployee(empId);
			if (empLeaves != null) {
				myLeaves = empLeaves;
				for (Leave l : empLeaves) {
					if ("Approved".equalsIgnoreCase(l.getStatus())) {
						leavesApprovedCount++;
					} else if ("Pending".equalsIgnoreCase(l.getStatus())) {
						leavesPendingCount++;
					} else if ("Rejected".equalsIgnoreCase(l.getStatus())) {
						leavesRejectedCount++;
					}
				}
			}
		}

		// Total annual leave quota (standard 24 days)
		int totalLeaveQuota = 24;
		int remainingLeaves = Math.max(0, totalLeaveQuota - leavesApprovedCount);

		// 5. Resolve Upcoming Meetings for this Employee
		List<Meeting> myUpcomingMeetings = new ArrayList<>();
		if (empId > 0) {
			try {
				List<Meeting> empMeetings = meetingDao.getMeetingsByEmployee(empId);
				if (empMeetings != null) {
					for (Meeting m : empMeetings) {
						if (m.getMeetingDate() != null && !m.getMeetingDate().before(today)) {
							myUpcomingMeetings.add(m);
						}
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		// Set all attributes for JSP rendering
		request.setAttribute("todayAttendance", todayAttendance);
		request.setAttribute("workStatus", workStatus);
		request.setAttribute("totalPresentDays", totalPresentDays);
		request.setAttribute("recentAttendance", recentAttendance);

		request.setAttribute("myTasks", myTasks);
		request.setAttribute("myTotalTasks", myTotalTasks);
		request.setAttribute("myPendingTasks", myPendingTasks);
		request.setAttribute("myInProgressTasks", myInProgressTasks);
		request.setAttribute("myCompletedTasks", myCompletedTasks);
		request.setAttribute("myOverdueTasks", myOverdueTasks);

		request.setAttribute("myLeaves", myLeaves);
		request.setAttribute("leavesApprovedCount", leavesApprovedCount);
		request.setAttribute("leavesPendingCount", leavesPendingCount);
		request.setAttribute("leavesRejectedCount", leavesRejectedCount);
		request.setAttribute("remainingLeaves", remainingLeaves);
		request.setAttribute("totalLeaveQuota", totalLeaveQuota);

		request.setAttribute("myUpcomingMeetings", myUpcomingMeetings);
		request.setAttribute("upcomingMeetingsCount", myUpcomingMeetings.size());

		request.getRequestDispatcher("employeeDashboard.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}