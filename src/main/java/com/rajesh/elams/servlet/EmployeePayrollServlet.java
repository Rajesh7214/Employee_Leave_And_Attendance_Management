package com.rajesh.elams.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.SalaryStructureDao;
import com.rajesh.elams.dao.SalaryStructureDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.SalaryStructure;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.PayrollService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/myPayroll")
public class EmployeePayrollServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private PayrollService payrollService;
	private EmployeeDao employeeDao;
	private SalaryStructureDao salaryStructureDao;

	@Override
	public void init() throws ServletException {
		payrollService = new PayrollService();
		employeeDao = new EmployeeDaoImpl();
		salaryStructureDao = new SalaryStructureDaoImpl();
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
		Employee employee = employeeDao.getEmployeeByEmail(loggedUser.getEmail());

		if (employee == null) {
			try {
				employee = new Employee();
				String emailPrefix = loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "User";
				String name = Character.toUpperCase(emailPrefix.charAt(0)) + (emailPrefix.length() > 1 ? emailPrefix.substring(1) : "");
				employee.setEmployee_name(name);
				employee.setEmail(loggedUser.getEmail());
				employee.setDepartment("Executive");
				employee.setDesignation(loggedUser.getRole() != null ? loggedUser.getRole().toUpperCase() : "Executive");
				employee.setPhone(9876543210L);
				employeeDao.addEmployee(employee);
				employee = employeeDao.getEmployeeByEmail(loggedUser.getEmail());
			} catch (Exception ignored) {}
		}

		if (employee == null) {
			List<Employee> allEmps = employeeDao.getAllEmployees();
			if (allEmps != null && !allEmps.isEmpty()) {
				employee = allEmps.get(0);
			}
		}

		if (employee == null) {
			response.sendRedirect(request.getContextPath() + "/login.jsp");
			return;
		}

		LocalDate today = LocalDate.now();
		int currentMonth = today.getMonthValue();
		int currentYear = today.getYear();

		SalaryStructure salaryStructure = salaryStructureDao.getSalaryStructureByEmployeeId(employee.getEmployee_id());
		if (salaryStructure == null) {
			salaryStructure = new SalaryStructure();
			salaryStructure.setEmployeeId(employee.getEmployee_id());
		}

		Payroll currentMonthPayroll = payrollService.getPayrollByEmployeeAndMonth(employee.getEmployee_id(), currentMonth, currentYear);
		if (currentMonthPayroll == null || !"PAID".equalsIgnoreCase(currentMonthPayroll.getStatus())) {
			currentMonthPayroll = payrollService.calculateSalaryForEmployee(employee.getEmployee_id(), currentMonth, currentYear);
		}

		List<Payroll> payrollHistory = payrollService.getPayrollsByEmployee(employee.getEmployee_id());

		request.setAttribute("employee", employee);
		request.setAttribute("salaryStructure", salaryStructure);
		request.setAttribute("currentMonthPayroll", currentMonthPayroll);
		request.setAttribute("payrollHistory", payrollHistory);
		request.setAttribute("currentMonth", currentMonth);
		request.setAttribute("currentYear", currentYear);

		request.getRequestDispatcher("/myPayroll.jsp").forward(request, response);
	}
}
