package com.rajesh.elams.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.PayrollService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/exportPayroll")
public class ExportPayrollServlet extends HttpServlet {

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

		response.setContentType("text/csv; charset=UTF-8");
		response.setHeader("Content-Disposition", "attachment; filename=\"Payroll_Report_" + month + "_" + year + ".csv\"");

		PrintWriter writer = response.getWriter();
		writer.println("Payroll ID,Employee ID,Employee Name,Department,Designation,Month,Year,Basic Salary,HRA,Transport Allowance,Medical Allowance,Other Allowances,Gross Salary,PF,Professional Tax,Loan Deduction,Other Deductions,Unpaid Leave Deduction,Total Deductions,Net Salary,Status,Payment Date");

		if (payrolls != null) {
			for (Payroll p : payrolls) {
				writer.printf("%d,%d,\"%s\",\"%s\",\"%s\",%d,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,\"%s\",\"%s\"\n",
						p.getPayrollId(),
						p.getEmployeeId(),
						p.getEmployeeName() != null ? p.getEmployeeName().replace("\"", "\"\"") : "",
						p.getDepartment() != null ? p.getDepartment().replace("\"", "\"\"") : "",
						p.getDesignation() != null ? p.getDesignation().replace("\"", "\"\"") : "",
						p.getMonth(),
						p.getYear(),
						p.getBasicSalary(),
						p.getHra(),
						p.getTransportAllowance(),
						p.getMedicalAllowance(),
						p.getOtherAllowances(),
						p.getGrossSalary(),
						p.getPf(),
						p.getProfessionalTax(),
						p.getLoanDeduction(),
						p.getOtherDeductions(),
						p.getUnpaidLeaveDeduction(),
						p.getTotalDeductions(),
						p.getNetSalary(),
						p.getStatus(),
						p.getPaymentDate() != null ? p.getPaymentDate().toString() : "N/A"
				);
			}
		}
		writer.flush();
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
