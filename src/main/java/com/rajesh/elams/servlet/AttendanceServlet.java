package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

import com.rajesh.elams.dao.AttendanceDao;
import com.rajesh.elams.dao.AttendanceDaoImpl;
import com.rajesh.elams.model.Attendance;
import com.rajesh.elams.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/markAttendance")
public class AttendanceServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private AttendanceDao attendanceDao;

	@Override
	public void init() {
		attendanceDao = new AttendanceDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		processAttendance(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		processAttendance(request, response);
	}

	private void processAttendance(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null || (session.getAttribute("employee") == null && session.getAttribute("loggedUser") == null)) {
			response.sendRedirect("login.jsp");
			return;
		}

		Employee emp = (Employee) session.getAttribute("employee");
		if (emp == null) {
			com.rajesh.elams.model.User user = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
			if (user != null) {
				com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
				emp = empDao.getEmployeeByEmail(user.getEmail());
				if (emp != null) {
					session.setAttribute("employee", emp);
					session.setAttribute("employeeId", emp.getEmployee_id());
				}
			}
		}

		if (emp == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		Date today = Date.valueOf(LocalDate.now());

		Attendance existingAttendance = null;
		List<Attendance> empRecords = attendanceDao.getAttendanceByEmployee(emp.getEmployee_id());
		if (empRecords != null) {
			for (Attendance a : empRecords) {
				if (a.getAttendance_date() != null && a.getAttendance_date().toString().equals(today.toString())) {
					existingAttendance = a;
					break;
				}
			}
		}

		if (existingAttendance == null) {
			Attendance attendance = new Attendance();
			attendance.setEmployee_id(emp.getEmployee_id());
			attendance.setAttendance_date(today);

			Time now = Time.valueOf(LocalTime.now());
			attendance.setCheck_in_time(now);
			attendance.setCheck_out_time(null);

			String status = now.toLocalTime().isAfter(LocalTime.of(10, 0)) ? "Late" : "Present";
			attendance.setStatus(status);

			String location = request.getParameter("location");
			if (location == null || location.isBlank()) {
				location = "Office / Remote";
			}
			attendance.setLocation(location.trim());

			attendanceDao.markAttendance(attendance);
		}

		response.sendRedirect("attendance.jsp");
	}
}