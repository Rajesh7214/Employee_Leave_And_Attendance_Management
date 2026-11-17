package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
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

@WebServlet(urlPatterns = {"/attendanceReportServlet", "/attendanceReport"})
public class AttendanceReportServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private AttendanceDao attendanceDAO;

	@Override
	public void init() {
		attendanceDAO = new AttendanceDaoImpl();
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
		String role = (String) session.getAttribute("role");

		boolean isEmployeeOnly = "employee".equalsIgnoreCase(role) || (!"admin".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role));

		if (isEmployeeOnly && employee != null) {

			
			List<Attendance> records = attendanceDAO.getAttendanceByEmployee(employee.getEmployee_id());

			int present = 0, absent = 0, halfDay = 0;

			for (Attendance a : records) {
				String st = a.getStatus() != null ? a.getStatus().trim() : "";
				if ("Present".equalsIgnoreCase(st) || "Late".equalsIgnoreCase(st) || "Early Leave".equalsIgnoreCase(st) || "Overtime".equalsIgnoreCase(st) || "In Office".equalsIgnoreCase(st) || "On Duty".equalsIgnoreCase(st)) {
					present++;
				} else if ("Absent".equalsIgnoreCase(st)) {
					absent++;
				} else if (st.toLowerCase().contains("half")) {
					halfDay++;
				} else if (!st.isEmpty()) {
					present++;
				}
			}

			request.setAttribute("present", present);
			request.setAttribute("absent", absent);
			request.setAttribute("halfDay", halfDay);
			request.setAttribute("records", records);
			request.setAttribute("isEmployeeView", true);
			request.setAttribute("backUrl", "employeeDashboardServlet");

		} else {

			Date today = new Date(System.currentTimeMillis());

			int present = attendanceDAO.getPresentCount(today);
			int absent = attendanceDAO.getAbsentCount(today);
			int halfDay = attendanceDAO.getHalfDayCount(today);

			request.setAttribute("present", present);
			request.setAttribute("absent", absent);
			request.setAttribute("halfDay", halfDay);
			request.setAttribute("isEmployeeView", false);
			request.setAttribute("backUrl",
					"admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "managerDashboard");
		}

		request.getRequestDispatcher("attendanceReport.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}