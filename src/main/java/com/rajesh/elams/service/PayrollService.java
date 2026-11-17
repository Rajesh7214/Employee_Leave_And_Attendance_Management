package com.rajesh.elams.service;

import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.dao.AttendanceDao;
import com.rajesh.elams.dao.AttendanceDaoImpl;
import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.dao.PayrollDao;
import com.rajesh.elams.dao.PayrollDaoImpl;
import com.rajesh.elams.dao.SalaryStructureDao;
import com.rajesh.elams.dao.SalaryStructureDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollStatus;
import com.rajesh.elams.model.PayrollSummary;
import com.rajesh.elams.model.SalaryStructure;

public class PayrollService {

	private EmployeeDao employeeDao;
	private SalaryStructureDao salaryStructureDao;
	private PayrollDao payrollDao;
	private AttendanceDao attendanceDao;
	private LeaveDao leaveDao;

	public PayrollService() {
		this.employeeDao = new EmployeeDaoImpl();
		this.salaryStructureDao = new SalaryStructureDaoImpl();
		this.payrollDao = new PayrollDaoImpl();
		this.attendanceDao = new AttendanceDaoImpl();
		this.leaveDao = new LeaveDaoImpl();
	}

	public Payroll calculateSalaryForEmployee(int employeeId, int month, int year) {
		Employee employee = employeeDao.getEmployeeById(employeeId);
		if (employee == null) {
			return null;
		}

		SalaryStructure structure = salaryStructureDao.getSalaryStructureByEmployeeId(employeeId);
		if (structure == null || structure.getBasicSalary() <= 0) {
			// Manual Salary Structure Provisioning: Require salary structure to be configured first under Manage Salary.
			return null;
		}

		int workingDays = 26;
		int unpaidLeaveDays = getUnpaidLeaveDays(employeeId, month, year);
		int presentDays = Math.max(0, workingDays - unpaidLeaveDays);

		double basicSalary = structure.getBasicSalary();
		double hra = structure.getHra();
		double transport = structure.getTransportAllowance();
		double medical = structure.getMedicalAllowance();
		double otherAllowances = structure.getOtherAllowances();
		double bonus = structure.getBonus();

		double grossSalary = basicSalary + hra + transport + medical + otherAllowances + bonus;

		double pf = structure.getPf();
		double professionalTax = structure.getProfessionalTax();
		double loanDeduction = structure.getLoanDeduction();
		double advanceSalary = structure.getAdvanceSalary();
		double otherDeductions = structure.getOtherDeductions();

		double perDayBasic = basicSalary / (double) workingDays;
		double unpaidLeaveDeduction = Math.round(perDayBasic * unpaidLeaveDays * 100.0) / 100.0;

		double totalDeductions = pf + professionalTax + loanDeduction + advanceSalary + otherDeductions + unpaidLeaveDeduction;
		double netSalary = Math.max(0.0, Math.round((grossSalary - totalDeductions) * 100.0) / 100.0);

		Payroll p = payrollDao.getPayrollByEmployeeAndMonth(employeeId, month, year);
		if (p == null) {
			p = new Payroll();
			p.setEmployeeId(employeeId);
			p.setMonth(month);
			p.setYear(year);
			p.setStatus(PayrollStatus.CALCULATED.name());
		} else {
			// Don't modify if already PAID
			if (PayrollStatus.PAID.name().equalsIgnoreCase(p.getStatus())) {
				return p;
			}
			p.setStatus(PayrollStatus.CALCULATED.name());
		}

		p.setBasicSalary(basicSalary);
		p.setHra(hra);
		p.setTransportAllowance(transport);
		p.setMedicalAllowance(medical);
		p.setOtherAllowances(otherAllowances);
		p.setBonus(bonus);
		p.setGrossSalary(grossSalary);

		p.setPf(pf);
		p.setProfessionalTax(professionalTax);
		p.setLoanDeduction(loanDeduction);
		p.setAdvanceSalary(advanceSalary);
		p.setOtherDeductions(otherDeductions);
		p.setUnpaidLeaveDeduction(unpaidLeaveDeduction);
		p.setTotalDeductions(totalDeductions);

		p.setNetSalary(netSalary);

		p.setWorkingDays(workingDays);
		p.setPresentDays(presentDays);
		p.setUnpaidLeaveDays(unpaidLeaveDays);

		p.setEmployeeName(employee.getEmployee_name());
		p.setDepartment(employee.getDepartment());
		p.setDesignation(employee.getDesignation());
		p.setEmail(employee.getEmail());

		payrollDao.savePayroll(p);
		return p;
	}

	public List<Payroll> calculateAndSaveBatchPayroll(int month, int year) {
		List<Employee> employees = employeeDao.getAllEmployees();
		List<Payroll> results = new ArrayList<>();
		if (employees != null) {
			for (Employee emp : employees) {
				Payroll p = calculateSalaryForEmployee(emp.getEmployee_id(), month, year);
				if (p != null) {
					results.add(p);
				}
			}
		}
		return results;
	}

	public boolean submitForApproval(int payrollId) {
		return payrollDao.updatePayrollStatus(payrollId, PayrollStatus.PENDING_APPROVAL.name());
	}

	public boolean submitBatchForApproval(int month, int year) {
		return payrollDao.updateBatchPayrollStatus(month, year, PayrollStatus.CALCULATED.name(), PayrollStatus.PENDING_APPROVAL.name());
	}

	public boolean approveBatchPayroll(int month, int year) {
		payrollDao.updateBatchPayrollStatus(month, year, PayrollStatus.CALCULATED.name(), PayrollStatus.APPROVED.name());
		return payrollDao.updateBatchPayrollStatus(month, year, PayrollStatus.PENDING_APPROVAL.name(), PayrollStatus.APPROVED.name());
	}

	public boolean processAndPayBatchPayroll(int month, int year) {
		return payrollDao.updateBatchPayrollStatus(month, year, PayrollStatus.APPROVED.name(), PayrollStatus.PAID.name());
	}

	public boolean updateStatus(int payrollId, String newStatus) {
		return payrollDao.updatePayrollStatus(payrollId, newStatus);
	}

	public PayrollSummary getPayrollSummary(int month, int year) {
		return payrollDao.getPayrollSummary(month, year);
	}

	public List<Payroll> getPayrollsByDepartment(String department, int month, int year) {
		return payrollDao.getPayrollsByDepartment(department, month, year);
	}

	public List<Payroll> getPayrollsByMonth(int month, int year) {
		return payrollDao.getPayrollsByMonth(month, year);
	}

	public List<Payroll> getPayrollsByEmployee(int employeeId) {
		return payrollDao.getPayrollsByEmployee(employeeId);
	}

	public Payroll getPayrollById(int payrollId) {
		return payrollDao.getPayrollById(payrollId);
	}

	public Payroll getPayrollByEmployeeAndMonth(int employeeId, int month, int year) {
		return payrollDao.getPayrollByEmployeeAndMonth(employeeId, month, year);
	}

	public boolean deletePayroll(int payrollId) {
		return payrollDao.deletePayroll(payrollId);
	}

	public int getUnpaidLeaveDays(int employeeId, int month, int year) {
		int count = 0;
		try {
			List<Leave> leaves = leaveDao.getLeavesByEmployee(employeeId);
			if (leaves != null) {
				for (Leave l : leaves) {
					String status = l.getStatus() != null ? l.getStatus().toUpperCase().trim() : "";
					if ("APPROVED".equals(status) || "ACCEPTED".equals(status) || "GRANTED".equals(status)) {
						String type = l.getLeaveType() != null ? l.getLeaveType().toUpperCase().trim() : "";
						if (type.contains("UNPAID") || type.contains("LOP") || type.contains("LOSS OF PAY")
								|| type.contains("WITHOUT PAY") || type.contains("NO PAY") || type.contains("UN-PAID")
								|| type.contains("UNPAY") || type.contains("L.O.P") || type.contains("UNAPPROVED")) {
							java.sql.Date start = l.getStartDate();
							java.sql.Date end = l.getEndDate() != null ? l.getEndDate() : start;
							if (start != null) {
								java.time.LocalDate cur = start.toLocalDate();
								java.time.LocalDate endLd = end.toLocalDate();
								while (!cur.isAfter(endLd)) {
									if (cur.getMonthValue() == month && cur.getYear() == year) {
										count++;
									}
									cur = cur.plusDays(1);
								}
							}
						}
					}
				}
			}

			// Also check Attendance records for unexcused 'Absent' days in this month/year
			List<com.rajesh.elams.model.Attendance> attList = attendanceDao.getAttendanceByEmployee(employeeId);
			if (attList != null) {
				for (com.rajesh.elams.model.Attendance att : attList) {
					if (att.getAttendance_date() != null) {
						java.time.LocalDate ad = att.getAttendance_date().toLocalDate();
						if (ad.getMonthValue() == month && ad.getYear() == year) {
							String attStatus = att.getStatus() != null ? att.getStatus().toUpperCase().trim() : "";
							if (attStatus.contains("ABSENT") || attStatus.contains("UNEXCUSED") || attStatus.contains("LOP") || attStatus.contains("LOSS")) {
								boolean inApprovedLeave = false;
								if (leaves != null) {
									for (Leave l : leaves) {
										String st = l.getStatus() != null ? l.getStatus().toUpperCase().trim() : "";
										if (("APPROVED".equals(st) || "ACCEPTED".equals(st) || "GRANTED".equals(st)) && l.getStartDate() != null) {
											java.time.LocalDate lst = l.getStartDate().toLocalDate();
											java.time.LocalDate len = (l.getEndDate() != null ? l.getEndDate() : l.getStartDate()).toLocalDate();
											if (!ad.isBefore(lst) && !ad.isAfter(len)) {
												inApprovedLeave = true;
												break;
											}
										}
									}
								}
								if (!inApprovedLeave) {
									count++;
								}
							}
						}
					}
				}
			}
		} catch (Exception e) {
			System.err.println("Error querying leave LOP / attendance days: " + e.getMessage());
		}
		return count;
	}
}
