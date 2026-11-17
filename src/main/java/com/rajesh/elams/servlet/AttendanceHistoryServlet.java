
package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.AttendanceDao;
import com.rajesh.elams.dao.AttendanceDaoImpl;
import com.rajesh.elams.model.Attendance;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/attendanceHistory")
public class AttendanceHistoryServlet extends HttpServlet {

	private AttendanceDao attendanceDao;

	@Override
	public void init() {
		attendanceDao = new AttendanceDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String role = (String) session.getAttribute("role");
		com.rajesh.elams.model.Employee loggedEmp = (com.rajesh.elams.model.Employee) session.getAttribute("employee");
		Integer sessionEmpId = (Integer) session.getAttribute("employeeId");

		String employeeIdParam = request.getParameter("employeeId");
		int targetEmpId = 0;

		if (employeeIdParam != null && !employeeIdParam.trim().isEmpty()) {
			try {
				targetEmpId = Integer.parseInt(employeeIdParam.trim());
			} catch (NumberFormatException ignored) {}
		} else if (loggedEmp != null) {
			targetEmpId = loggedEmp.getEmployee_id();
		} else if (sessionEmpId != null) {
			targetEmpId = sessionEmpId;
		}

		List<Attendance> attendanceList;

		if (targetEmpId > 0 && !"admin".equalsIgnoreCase(role)) {
			attendanceList = attendanceDao.getAttendanceByEmployee(targetEmpId);
			request.setAttribute("isAllEmployeesView", false);
		} else if (targetEmpId > 0 && employeeIdParam != null && !employeeIdParam.isBlank()) {
			attendanceList = attendanceDao.getAttendanceByEmployee(targetEmpId);
			request.setAttribute("isAllEmployeesView", false);
		} else {
			attendanceList = attendanceDao.getAllAttendance();
			request.setAttribute("isAllEmployeesView", true);
		}

		int present = 0, absent = 0, halfDay = 0, late = 0, overtime = 0;
		if (attendanceList != null) {
			for (Attendance a : attendanceList) {
				String st = a.getStatus() != null ? a.getStatus().trim() : "";
				if ("Late".equalsIgnoreCase(st)) {
					late++;
					present++;
				} else if ("Overtime".equalsIgnoreCase(st)) {
					overtime++;
					present++;
				} else if ("Present".equalsIgnoreCase(st) || "Early Leave".equalsIgnoreCase(st) || "On Time".equalsIgnoreCase(st) || a.getCheck_in_time() != null) {
					present++;
				} else if ("Absent".equalsIgnoreCase(st)) {
					absent++;
				} else if ("Half Day".equalsIgnoreCase(st) || "Halfday".equalsIgnoreCase(st)) {
					halfDay++;
				}
			}
		}

		int totalDays = attendanceList != null ? attendanceList.size() : 0;
		double attendanceRate = totalDays > 0 ? ((present + (halfDay * 0.5)) / (double) totalDays) * 100.0 : 100.0;

		request.setAttribute("attendanceList", attendanceList != null ? attendanceList : java.util.Collections.emptyList());
		request.setAttribute("present", present);
		request.setAttribute("absent", absent);
		request.setAttribute("halfDay", halfDay);
		request.setAttribute("late", late);
		request.setAttribute("overtime", overtime);
		request.setAttribute("totalDays", totalDays);
		request.setAttribute("attendanceRate", String.format("%.1f", attendanceRate));
		request.setAttribute("targetEmpId", targetEmpId);
		request.setAttribute("backUrl", "admin".equalsIgnoreCase(role) ? "adminDashboardServlet"
				: "hr".equalsIgnoreCase(role) ? "hrDashboard"
				: "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet");

		request.getRequestDispatcher("attendanceHistory.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}