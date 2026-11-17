package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.PayrollService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/teamPayroll")
public class TeamPayrollServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private PayrollService payrollService;
	private EmployeeDao employeeDao;

	@Override
	public void init() throws ServletException {
		payrollService = new PayrollService();
		employeeDao = new EmployeeDaoImpl();
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
		if (role == null) role = loggedUser.getRole();

		Employee manager = employeeDao.getEmployeeByEmail(loggedUser.getEmail());

		LocalDate today = LocalDate.now();
		int month = parseParamInt(request.getParameter("month"), today.getMonthValue());
		int year = parseParamInt(request.getParameter("year"), today.getYear());
		String reqDept = request.getParameter("department");

		String department = (reqDept != null && !reqDept.isBlank())
				? reqDept.trim()
				: (manager != null && manager.getDepartment() != null ? manager.getDepartment() : "Engineering");

		List<Payroll> teamPayrolls;
		if ("admin".equalsIgnoreCase(role) || "hr".equalsIgnoreCase(role)) {
			if (reqDept != null && !reqDept.isBlank() && !"ALL".equalsIgnoreCase(reqDept)) {
				teamPayrolls = payrollService.getPayrollsByDepartment(department, month, year);
			} else {
				teamPayrolls = payrollService.getPayrollsByMonth(month, year);
			}
		} else {
			teamPayrolls = payrollService.getPayrollsByDepartment(department, month, year);
		}

		request.setAttribute("teamPayrolls", teamPayrolls);
		request.setAttribute("department", department);
		request.setAttribute("currentMonth", month);
		request.setAttribute("currentYear", year);

		request.getRequestDispatcher("/teamPayroll.jsp").forward(request, response);
	}

	private int parseParamInt(String val, int defaultVal) {
		if (val == null || val.isBlank()) return defaultVal;
		try {
			return Integer.parseInt(val.trim());
		} catch (NumberFormatException e) {
			return defaultVal;
		}
	}
}
