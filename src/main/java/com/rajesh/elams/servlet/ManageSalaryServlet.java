package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Locale;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.SalaryStructureDao;
import com.rajesh.elams.dao.SalaryStructureDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.SalaryStructure;
import com.rajesh.elams.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/manageSalary")
public class ManageSalaryServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;
	private SalaryStructureDao salaryStructureDao;
	private com.rajesh.elams.dao.PayrollDao payrollDao;

	@Override
	public void init() throws ServletException {
		employeeDao = new EmployeeDaoImpl();
		salaryStructureDao = new SalaryStructureDaoImpl();
		payrollDao = new com.rajesh.elams.dao.PayrollDaoImpl();
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

		List<Employee> allEmployees = employeeDao.getAllEmployees();
		List<String> allDepartments = new java.util.ArrayList<>();
		if (allEmployees != null) {
			for (Employee emp : allEmployees) {
				if (emp.getDepartment() != null && !emp.getDepartment().isBlank() && !allDepartments.contains(emp.getDepartment())) {
					allDepartments.add(emp.getDepartment());
				}
			}
		}

		String selectedDept = request.getParameter("department");
		if (selectedDept == null || selectedDept.isBlank()) selectedDept = "ALL";

		String searchQuery = request.getParameter("searchQuery");
		if (searchQuery == null) searchQuery = request.getParameter("search");
		if (searchQuery != null) searchQuery = searchQuery.trim();

		int selectedEmpId = parseParamInt(request.getParameter("employeeId"), 0);

		if (!"ALL".equalsIgnoreCase(selectedDept) && allEmployees != null && !allEmployees.isEmpty()) {
			boolean empMatchesDept = false;
			if (selectedEmpId > 0) {
				for (Employee emp : allEmployees) {
					if (emp.getEmployee_id() == selectedEmpId && emp.getDepartment() != null && selectedDept.equalsIgnoreCase(emp.getDepartment().trim())) {
						empMatchesDept = true;
						break;
					}
				}
			}
			if (!empMatchesDept) {
				for (Employee emp : allEmployees) {
					if (emp.getDepartment() != null && selectedDept.equalsIgnoreCase(emp.getDepartment().trim())) {
						selectedEmpId = emp.getEmployee_id();
						break;
					}
				}
			}
		}

		if (selectedEmpId <= 0 && allEmployees != null && !allEmployees.isEmpty()) {
			if (searchQuery != null && !searchQuery.isEmpty()) {
				String q = searchQuery.toLowerCase();
				for (Employee emp : allEmployees) {
					String empCode = "emp" + String.format("%03d", emp.getEmployee_id());
					if ((emp.getEmployee_name() != null && emp.getEmployee_name().toLowerCase().contains(q)) ||
						(emp.getDepartment() != null && emp.getDepartment().toLowerCase().contains(q)) ||
						empCode.contains(q) || String.valueOf(emp.getEmployee_id()).equals(q)) {
						selectedEmpId = emp.getEmployee_id();
						break;
					}
				}
			}
			if (selectedEmpId <= 0) {
				selectedEmpId = allEmployees.get(0).getEmployee_id();
			}
		}

		int selectedMonth = parseParamInt(request.getParameter("month"), 8);
		int selectedYear = parseParamInt(request.getParameter("year"), 2026);

		SalaryStructure salaryStructure = null;
		Employee selectedEmployee = null;
		int realLopDays = 0;
		double realLopDeduction = 0.0;

		com.rajesh.elams.service.PayrollService payrollService = new com.rajesh.elams.service.PayrollService();

		if (selectedEmpId > 0) {
			selectedEmployee = employeeDao.getEmployeeById(selectedEmpId);
			salaryStructure = salaryStructureDao.getSalaryStructureByEmployeeId(selectedEmpId);
			if (salaryStructure == null) {
				salaryStructure = new SalaryStructure();
				salaryStructure.setEmployeeId(selectedEmpId);
			}

			com.rajesh.elams.model.Payroll existingPayroll = payrollService.getPayrollByEmployeeAndMonth(selectedEmpId, selectedMonth, selectedYear);
			if (existingPayroll != null) {
				realLopDays = existingPayroll.getUnpaidLeaveDays();
				realLopDeduction = existingPayroll.getUnpaidLeaveDeduction();
			} else {
				realLopDays = payrollService.getUnpaidLeaveDays(selectedEmpId, selectedMonth, selectedYear);
				double dailyBasic = salaryStructure.getBasicSalary() / 26.0;
				realLopDeduction = Math.round(dailyBasic * realLopDays * 100.0) / 100.0;
			}
		}

		request.setAttribute("allEmployees", allEmployees);
		request.setAttribute("allDepartments", allDepartments);
		request.setAttribute("selectedDept", selectedDept);
		request.setAttribute("selectedEmployee", selectedEmployee);
		request.setAttribute("salaryStructure", salaryStructure);
		request.setAttribute("selectedMonth", selectedMonth);
		request.setAttribute("selectedYear", selectedYear);
		request.setAttribute("realLopDays", realLopDays);
		request.setAttribute("realLopDeduction", realLopDeduction);
		request.setAttribute("searchQuery", searchQuery != null ? searchQuery : "");

		request.getRequestDispatcher("/manageSalary.jsp").forward(request, response);
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

		int employeeId = parseParamInt(request.getParameter("employeeId"), 0);
		if (employeeId <= 0) {
			response.sendRedirect(request.getContextPath() + "/manageSalary");
			return;
		}

		String action = request.getParameter("action");

		// Check if action is saving LOP math from Live Inspector
		if ("saveLop".equalsIgnoreCase(action)) {
			int customLopDays = parseParamInt(request.getParameter("customLopDays"), 0);
			int selectedMonth = parseParamInt(request.getParameter("month"), 8);
			int selectedYear = parseParamInt(request.getParameter("year"), 2026);
			String formulaBasis = request.getParameter("formulaBasis");

			com.rajesh.elams.service.PayrollService payrollService = new com.rajesh.elams.service.PayrollService();
			SalaryStructure ss = salaryStructureDao.getSalaryStructureByEmployeeId(employeeId);
			if (ss == null) {
				ss = new SalaryStructure();
				ss.setEmployeeId(employeeId);
			}

			com.rajesh.elams.model.Payroll p = payrollService.getPayrollByEmployeeAndMonth(employeeId, selectedMonth, selectedYear);
			if (p == null) {
				p = payrollService.calculateSalaryForEmployee(employeeId, selectedMonth, selectedYear);
			}
			if (p == null) {
				p = new com.rajesh.elams.model.Payroll();
				p.setEmployeeId(employeeId);
				p.setMonth(selectedMonth);
				p.setYear(selectedYear);
				p.setBasicSalary(ss.getBasicSalary());
				p.setHra(ss.getHra());
				p.setTransportAllowance(ss.getTransportAllowance());
				p.setMedicalAllowance(ss.getMedicalAllowance());
				p.setBonus(ss.getBonus());
				p.setOtherAllowances(ss.getOtherAllowances());
				p.setGrossSalary(ss.getGrossSalary());
				p.setPf(ss.getPf());
				p.setProfessionalTax(ss.getProfessionalTax());
				p.setLoanDeduction(ss.getLoanDeduction());
				p.setAdvanceSalary(ss.getAdvanceSalary());
				p.setOtherDeductions(ss.getOtherDeductions());
				p.setStatus(com.rajesh.elams.model.PayrollStatus.CALCULATED.name());
			}

			double dailyRate = ss.getBasicSalary() / 26.0;
			if ("gross30".equalsIgnoreCase(formulaBasis)) {
				dailyRate = p.getGrossSalary() / 30.0;
			} else if ("gross26".equalsIgnoreCase(formulaBasis)) {
				dailyRate = p.getGrossSalary() / 26.0;
			}

			double lopDeduction = Math.round(dailyRate * customLopDays * 100.0) / 100.0;
			double fixedDed = ss.getPf() + ss.getProfessionalTax() + ss.getLoanDeduction() + ss.getAdvanceSalary() + ss.getOtherDeductions();
			double totalDed = Math.round((fixedDed + lopDeduction) * 100.0) / 100.0;
			double net = Math.max(0.0, Math.round((p.getGrossSalary() - totalDed) * 100.0) / 100.0);

			p.setUnpaidLeaveDays(customLopDays);
			p.setUnpaidLeaveDeduction(lopDeduction);
			p.setTotalDeductions(totalDed);
			p.setNetSalary(net);

			boolean lopSaved = payrollDao.savePayroll(p);
			if (lopSaved) {
				request.setAttribute("successMessage", "Live LOP Math Saved Successfully: " + customLopDays + " Days LOP (Deduction: ₹" + String.format(Locale.US, "%.2f", lopDeduction) + ")!");
			} else {
				request.setAttribute("errorMessage", "Failed to save Live LOP calculation.");
			}

			doGet(request, response);
			return;
		}

		double basicSalary = parseDouble(request.getParameter("basicSalary"), 30000.0);
		double hra = parseDouble(request.getParameter("hra"), 10000.0);
		double transportAllowance = parseDouble(request.getParameter("transportAllowance"), 3000.0);
		double medicalAllowance = parseDouble(request.getParameter("medicalAllowance"), 2000.0);
		double bonus = parseDouble(request.getParameter("bonus"), 0.0);
		double otherAllowances = parseDouble(request.getParameter("otherAllowances"), 0.0);
		double pf = parseDouble(request.getParameter("pf"), 3600.0);
		double professionalTax = parseDouble(request.getParameter("professionalTax"), 200.0);
		double loanDeduction = parseDouble(request.getParameter("loanDeduction"), 0.0);
		double advanceSalary = parseDouble(request.getParameter("advanceSalary"), 0.0);
		double otherDeductions = parseDouble(request.getParameter("otherDeductions"), 500.0);
		String status = request.getParameter("status");
		String effDateStr = request.getParameter("effectiveFrom");

		Date effectiveFrom = (effDateStr != null && !effDateStr.isBlank())
				? Date.valueOf(effDateStr.trim())
				: Date.valueOf(LocalDate.now());

		SalaryStructure ss = salaryStructureDao.getSalaryStructureByEmployeeId(employeeId);
		if (ss == null) {
			ss = new SalaryStructure();
			ss.setEmployeeId(employeeId);
		}

		ss.setBasicSalary(basicSalary);
		ss.setHra(hra);
		ss.setTransportAllowance(transportAllowance);
		ss.setMedicalAllowance(medicalAllowance);
		ss.setBonus(bonus);
		ss.setOtherAllowances(otherAllowances);
		ss.setPf(pf);
		ss.setProfessionalTax(professionalTax);
		ss.setLoanDeduction(loanDeduction);
		ss.setAdvanceSalary(advanceSalary);
		ss.setOtherDeductions(otherDeductions);
		ss.setEffectiveFrom(effectiveFrom);
		ss.setStatus(status != null && !status.isBlank() ? status : "ACTIVE");

		boolean isNewSalary = (ss.getId() == 0);
		boolean saved = salaryStructureDao.saveSalaryStructure(ss);
		if (saved) {
			request.setAttribute("successMessage", "Salary structure updated successfully!");

			String actor = loggedUser != null ? loggedUser.getEmail() : "Admin/HR";
			String salAction = isNewSalary ? "CREATE_SALARY" : "UPDATE_SALARY";
			com.rajesh.elams.service.AuditService.logAction(actor, salAction, "Payroll", "SAL-EMP-" + employeeId, (isNewSalary ? "Created" : "Updated") + " salary structure components (Basic: ₹" + basicSalary + ")", request.getRemoteAddr());
		} else {
			request.setAttribute("errorMessage", "Failed to update salary structure.");
		}

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

	private double parseDouble(String val, double defaultVal) {
		if (val == null || val.isBlank()) return defaultVal;
		try {
			return Double.parseDouble(val.trim());
		} catch (NumberFormatException e) {
			return defaultVal;
		}
	}
}
