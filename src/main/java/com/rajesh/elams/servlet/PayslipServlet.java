package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;

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

@WebServlet("/payslip")
public class PayslipServlet extends HttpServlet {

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

		int payrollId = parseParamInt(request.getParameter("id"), 0);
		int month = parseParamInt(request.getParameter("month"), LocalDate.now().getMonthValue());
		int year = parseParamInt(request.getParameter("year"), LocalDate.now().getYear());

		Payroll payroll = null;

		if (payrollId > 0) {
			payroll = payrollService.getPayrollById(payrollId);
		}

		if (payroll == null) {
			int empId = parseParamInt(request.getParameter("employeeId"), 0);
			if (empId <= 0) {
				Employee emp = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
				if (emp != null) empId = emp.getEmployee_id();
			}
			if (empId > 0) {
				payroll = payrollService.getPayrollByEmployeeAndMonth(empId, month, year);
				if (payroll == null || !"PAID".equalsIgnoreCase(payroll.getStatus())) {
					payroll = payrollService.calculateSalaryForEmployee(empId, month, year);
				}
			}
		} else if (!"PAID".equalsIgnoreCase(payroll.getStatus())) {
			payroll = payrollService.calculateSalaryForEmployee(payroll.getEmployeeId(), payroll.getMonth(), payroll.getYear());
		}

		// Security Authorization: Employees can only view their own payslips
		if ("employee".equalsIgnoreCase(role) && payroll != null) {
			Employee emp = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
			if (emp != null && emp.getEmployee_id() != payroll.getEmployeeId()) {
				response.sendRedirect(request.getContextPath() + "/myPayroll");
				return;
			}
		}

		request.setAttribute("payroll", payroll);
		request.getRequestDispatcher("/payslip.jsp").forward(request, response);
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
