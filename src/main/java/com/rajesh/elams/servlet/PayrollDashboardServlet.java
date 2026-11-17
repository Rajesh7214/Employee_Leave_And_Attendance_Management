package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollSummary;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.PayrollService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = { "/payrollDashboard", "/payroll" })
public class PayrollDashboardServlet extends HttpServlet {

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

		if ("employee".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/myPayroll");
			return;
		}
		if ("manager".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/teamPayroll");
			return;
		}

		LocalDate today = LocalDate.now();
		int month = parseParamInt(request.getParameter("month"), today.getMonthValue());
		int year = parseParamInt(request.getParameter("year"), today.getYear());
		String statusFilter = request.getParameter("status");

		List<Employee> allEmployees = employeeDao.getAllEmployees();
		List<Payroll> payrollList = payrollService.getPayrollsByMonth(month, year);
		// Manual Payroll Generation: Payroll records are generated manually via "Run Batch Calculation" or "Calculate Employee Salary".
		PayrollSummary summary = payrollService.getPayrollSummary(month, year);

		request.setAttribute("payrollList", payrollList);
		request.setAttribute("payrollSummary", summary);
		request.setAttribute("allEmployees", allEmployees);
		request.setAttribute("currentMonth", month);
		request.setAttribute("currentYear", year);
		request.setAttribute("statusFilter", statusFilter != null ? statusFilter : "ALL");

		request.getRequestDispatcher("/payrollDashboard.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
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
