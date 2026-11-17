package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;

import com.rajesh.elams.dao.AttendanceDao;
import com.rajesh.elams.dao.AttendanceDaoImpl;
import com.rajesh.elams.model.Employee;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/startBreak")
public class StartBreakServlet extends HttpServlet {

	private AttendanceDao attendanceDao;

	@Override
	public void init() {
		attendanceDao = new AttendanceDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {

		HttpSession session = request.getSession(false);

		if (session == null || (session.getAttribute("employee") == null && session.getAttribute("loggedUser") == null)) {
			response.sendRedirect("login.jsp");
			return;
		}

		Employee employee = (Employee) session.getAttribute("employee");
		if (employee == null) {
			com.rajesh.elams.model.User user = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
			if (user != null) {
				com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
				employee = empDao.getEmployeeByEmail(user.getEmail());
				if (employee != null) {
					session.setAttribute("employee", employee);
					session.setAttribute("employeeId", employee.getEmployee_id());
				}
			}
		}

		if (employee != null) {
			Date today = Date.valueOf(LocalDate.now());
			com.rajesh.elams.model.Attendance todayAtt = null;
			java.util.List<com.rajesh.elams.model.Attendance> records = attendanceDao.getAttendanceByEmployee(employee.getEmployee_id());
			if (records != null) {
				for (com.rajesh.elams.model.Attendance a : records) {
					if (a.getAttendance_date() != null && a.getAttendance_date().toString().equals(today.toString())) {
						todayAtt = a;
						break;
					}
				}
			}
			if (todayAtt != null && todayAtt.getCheck_in_time() != null && todayAtt.getCheck_out_time() == null) {
				Time now = Time.valueOf(LocalTime.now());
				attendanceDao.startBreak(employee.getEmployee_id(), today, now);
			}
		}

		response.sendRedirect("attendance.jsp");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
		doGet(request, response);
	}
}
