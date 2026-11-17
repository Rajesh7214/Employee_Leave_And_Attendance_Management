package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

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

@WebServlet("/payrollReport")
public class PayrollReportServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private PayrollService payrollService;

	@Override
	public void init() throws ServletException {
		payrollService = new PayrollService();
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

		if (!"admin".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role)) {
			response.sendRedirect(request.getContextPath() + "/payrollDashboard");
			return;
		}

		LocalDate today = LocalDate.now();
		int month = parseParamInt(request.getParameter("month"), today.getMonthValue());
		int year = parseParamInt(request.getParameter("year"), today.getYear());

		List<Payroll> payrolls = payrollService.getPayrollsByMonth(month, year);
		if (payrolls == null || payrolls.isEmpty()) {
			payrolls = payrollService.calculateAndSaveBatchPayroll(month, year);
		}
		PayrollSummary summary = payrollService.getPayrollSummary(month, year);

		request.setAttribute("payrolls", payrolls);
		request.setAttribute("summary", summary);
		request.setAttribute("currentMonth", month);
		request.setAttribute("currentYear", year);

		request.getRequestDispatcher("/payrollReport.jsp").forward(request, response);
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
