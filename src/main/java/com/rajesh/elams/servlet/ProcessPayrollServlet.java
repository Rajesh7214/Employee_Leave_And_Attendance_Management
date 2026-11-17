package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;

import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollStatus;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.PayrollService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/processPayroll")
public class ProcessPayrollServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private PayrollService payrollService;

	@Override
	public void init() throws ServletException {
		payrollService = new PayrollService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

		String action = request.getParameter("action");
		int month = parseParamInt(request.getParameter("month"), LocalDate.now().getMonthValue());
		int year = parseParamInt(request.getParameter("year"), LocalDate.now().getYear());

		if ("calculateSingle".equalsIgnoreCase(action)) {
			int employeeId = parseParamInt(request.getParameter("employeeId"), 0);
			if (employeeId > 0) {
				Payroll p = payrollService.calculateSalaryForEmployee(employeeId, month, year);
				if (p == null) {
					session.setAttribute("message", "Cannot calculate salary: Salary structure not configured for this employee. Please configure salary structure under Manage Salary first.");
				} else if ("submitForApproval".equalsIgnoreCase(request.getParameter("subAction"))) {
					payrollService.updateStatus(p.getPayrollId(), PayrollStatus.PENDING_APPROVAL.name());
					session.setAttribute("message", "Salary calculated & submitted for HR approval!");
				} else if ("approveDirect".equalsIgnoreCase(request.getParameter("subAction"))) {
					payrollService.updateStatus(p.getPayrollId(), PayrollStatus.APPROVED.name());
					session.setAttribute("message", "Salary calculated & Executive Approved!");
				} else {
					session.setAttribute("message", "Salary calculated successfully for employee!");
				}
			}
		} else if ("calculateAndSubmit".equalsIgnoreCase(action)) {
			int employeeId = parseParamInt(request.getParameter("employeeId"), 0);
			if (employeeId > 0) {
				Payroll p = payrollService.calculateSalaryForEmployee(employeeId, month, year);
				if (p != null) {
					payrollService.updateStatus(p.getPayrollId(), PayrollStatus.PENDING_APPROVAL.name());
					session.setAttribute("message", "Salary calculated & submitted for approval!");
				}
			}
		} else if ("calculateBatch".equalsIgnoreCase(action)) {
			payrollService.calculateAndSaveBatchPayroll(month, year);
			session.setAttribute("message", "Batch payroll calculated successfully!");
			String actor = loggedUser != null ? loggedUser.getEmail() : "Admin/HR";
			com.rajesh.elams.service.AuditService.logAction(actor, "PROCESS_PAYROLL", "Payroll", "BATCH-" + month + "-" + year, "Calculated batch payroll for Month " + month + "/" + year, request.getRemoteAddr());
			if ("submitForApproval".equalsIgnoreCase(request.getParameter("subAction"))) {
				payrollService.submitBatchForApproval(month, year);
				session.setAttribute("message", "Batch payroll calculated & submitted for approval!");
			}
		} else if ("submitApproval".equalsIgnoreCase(action)) {
			payrollService.submitBatchForApproval(month, year);
			session.setAttribute("message", "Payroll submitted for approval!");
			String actor = loggedUser != null ? loggedUser.getEmail() : "Admin/HR";
			com.rajesh.elams.service.AuditService.logAction(actor, "PROCESS_PAYROLL", "Payroll", "SUBMIT-" + month + "-" + year, "Submitted batch payroll for HR approval", request.getRemoteAddr());
		} else if ("approveMonth".equalsIgnoreCase(action)) {
			payrollService.approveBatchPayroll(month, year);
			session.setAttribute("message", "Executive Approval granted for monthly payroll!");
			String actor = loggedUser != null ? loggedUser.getEmail() : "Admin/HR";
			com.rajesh.elams.service.AuditService.logAction(actor, "PROCESS_PAYROLL", "Payroll", "APPROVE-" + month + "-" + year, "Granted Executive Approval for Month " + month + "/" + year, request.getRemoteAddr());
		} else if ("processPayment".equalsIgnoreCase(action)) {
			payrollService.processAndPayBatchPayroll(month, year);
			session.setAttribute("message", "Salaries disbursed and marked as PAID!");

			String actor = loggedUser != null ? loggedUser.getEmail() : "Admin/HR";
			com.rajesh.elams.service.AuditService.logAction(actor, "PROCESS_PAYROLL", "Payroll", "PAY-" + month + "-" + year, "Disbursed payroll salaries for Month " + month + "/" + year, request.getRemoteAddr());
		} else if ("updateStatus".equalsIgnoreCase(action)) {
			int payrollId = parseParamInt(request.getParameter("payrollId"), 0);
			String status = request.getParameter("status");
			if (payrollId > 0 && status != null && !status.isBlank()) {
				Payroll existing = payrollService.getPayrollById(payrollId);
				if (existing != null && PayrollStatus.PAID.name().equalsIgnoreCase(existing.getStatus())) {
					session.setAttribute("message", "Cannot modify status of a PAID payroll record!");
				} else {
					payrollService.updateStatus(payrollId, status);
					session.setAttribute("message", "Payroll record status updated to " + status + "!");
				}
			}
		} else if ("deleteRecord".equalsIgnoreCase(action)) {
			int payrollId = parseParamInt(request.getParameter("payrollId"), 0);
			if (payrollId > 0) {
				Payroll existing = payrollService.getPayrollById(payrollId);
				if (existing != null && PayrollStatus.PAID.name().equalsIgnoreCase(existing.getStatus())) {
					session.setAttribute("message", "Cannot delete a PAID payroll record!");
				} else {
					payrollService.deletePayroll(payrollId);
					session.setAttribute("message", "Payroll record deleted successfully.");
				}
			}
		}

		response.sendRedirect(request.getContextPath() + "/payrollDashboard?month=" + month + "&year=" + year);
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
