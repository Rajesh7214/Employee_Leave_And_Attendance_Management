package com.rajesh.elams.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
import java.time.Month;
import java.time.format.TextStyle;
import java.util.Locale;

public class Payroll implements Serializable {
	private static final long serialVersionUID = 1L;

	private int payrollId;
	private int employeeId;
	private int month;
	private int year;

	private double basicSalary;
	private double hra;
	private double transportAllowance;
	private double medicalAllowance;
	private double bonus;
	private double otherAllowances;
	private double grossSalary;

	private double pf;
	private double professionalTax;
	private double loanDeduction;
	private double advanceSalary;
	private double otherDeductions;
	private double unpaidLeaveDeduction;
	private double totalDeductions;

	private double netSalary;

	private int workingDays;
	private int presentDays;
	private int unpaidLeaveDays;

	private String status; // DRAFT, CALCULATED, PENDING_APPROVAL, APPROVED, PROCESSED, PAID, CANCELLED
	private Date paymentDate;
	private Timestamp createdAt;
	private Timestamp updatedAt;

	// Joined attributes for UI rendering
	private String employeeName;
	private String department;
	private String designation;
	private String email;

	public Payroll() {
		this.workingDays = 26;
		this.status = PayrollStatus.DRAFT.name();
	}

	public int getPayrollId() {
		return payrollId;
	}

	public void setPayrollId(int payrollId) {
		this.payrollId = payrollId;
	}

	public int getEmployeeId() {
		return employeeId;
	}

	public void setEmployeeId(int employeeId) {
		this.employeeId = employeeId;
	}

	public int getMonth() {
		return month;
	}

	public void setMonth(int month) {
		this.month = month;
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
	}

	public double getBasicSalary() {
		return basicSalary;
	}

	public void setBasicSalary(double basicSalary) {
		this.basicSalary = basicSalary;
	}

	public double getHra() {
		return hra;
	}

	public void setHra(double hra) {
		this.hra = hra;
	}

	public double getTransportAllowance() {
		return transportAllowance;
	}

	public void setTransportAllowance(double transportAllowance) {
		this.transportAllowance = transportAllowance;
	}

	public double getMedicalAllowance() {
		return medicalAllowance;
	}

	public void setMedicalAllowance(double medicalAllowance) {
		this.medicalAllowance = medicalAllowance;
	}

	public double getBonus() {
		return bonus;
	}

	public void setBonus(double bonus) {
		this.bonus = bonus;
	}

	public double getOtherAllowances() {
		return otherAllowances;
	}

	public void setOtherAllowances(double otherAllowances) {
		this.otherAllowances = otherAllowances;
	}

	public double getGrossSalary() {
		return grossSalary;
	}

	public void setGrossSalary(double grossSalary) {
		this.grossSalary = grossSalary;
	}

	public double getPf() {
		return pf;
	}

	public void setPf(double pf) {
		this.pf = pf;
	}

	public double getProfessionalTax() {
		return professionalTax;
	}

	public void setProfessionalTax(double professionalTax) {
		this.professionalTax = professionalTax;
	}

	public double getLoanDeduction() {
		return loanDeduction;
	}

	public void setLoanDeduction(double loanDeduction) {
		this.loanDeduction = loanDeduction;
	}

	public double getAdvanceSalary() {
		return advanceSalary;
	}

	public void setAdvanceSalary(double advanceSalary) {
		this.advanceSalary = advanceSalary;
	}

	public double getOtherDeductions() {
		return otherDeductions;
	}

	public void setOtherDeductions(double otherDeductions) {
		this.otherDeductions = otherDeductions;
	}

	public double getUnpaidLeaveDeduction() {
		return unpaidLeaveDeduction;
	}

	public void setUnpaidLeaveDeduction(double unpaidLeaveDeduction) {
		this.unpaidLeaveDeduction = unpaidLeaveDeduction;
	}

	public double getTotalDeductions() {
		return totalDeductions;
	}

	public void setTotalDeductions(double totalDeductions) {
		this.totalDeductions = totalDeductions;
	}

	public double getNetSalary() {
		return netSalary;
	}

	public void setNetSalary(double netSalary) {
		this.netSalary = netSalary;
	}

	public int getWorkingDays() {
		return workingDays;
	}

	public void setWorkingDays(int workingDays) {
		this.workingDays = workingDays;
	}

	public int getPresentDays() {
		return presentDays;
	}

	public void setPresentDays(int presentDays) {
		this.presentDays = presentDays;
	}

	public int getUnpaidLeaveDays() {
		return unpaidLeaveDays;
	}

	public void setUnpaidLeaveDays(int unpaidLeaveDays) {
		this.unpaidLeaveDays = unpaidLeaveDays;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Date getPaymentDate() {
		return paymentDate;
	}

	public void setPaymentDate(Date paymentDate) {
		this.paymentDate = paymentDate;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}

	public String getEmployeeName() {
		return employeeName;
	}

	public void setEmployeeName(String employeeName) {
		this.employeeName = employeeName;
	}

	public String getDepartment() {
		return department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	public String getDesignation() {
		return designation;
	}

	public void setDesignation(String designation) {
		this.designation = designation;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getMonthName() {
		try {
			return Month.of(month).getDisplayName(TextStyle.FULL, Locale.ENGLISH);
		} catch (Exception e) {
			return String.valueOf(month);
		}
	}
}
