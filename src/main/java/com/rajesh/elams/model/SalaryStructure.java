package com.rajesh.elams.model;

import java.io.Serializable;
import java.sql.Date;

public class SalaryStructure implements Serializable {
	private static final long serialVersionUID = 1L;

	private int id;
	private int employeeId;
	private double basicSalary;
	private double hra;
	private double transportAllowance;
	private double medicalAllowance;
	private double bonus;
	private double otherAllowances;
	private double pf;
	private double professionalTax;
	private double loanDeduction;
	private double advanceSalary;
	private double otherDeductions;
	private Date effectiveFrom;
	private String status;

	public SalaryStructure() {
		this.basicSalary = 30000.0;
		this.hra = 10000.0;
		this.transportAllowance = 3000.0;
		this.medicalAllowance = 2000.0;
		this.bonus = 0.0;
		this.otherAllowances = 0.0;
		this.pf = 3600.0;
		this.professionalTax = 200.0;
		this.loanDeduction = 0.0;
		this.advanceSalary = 0.0;
		this.otherDeductions = 500.0;
		this.status = "ACTIVE";
	}

	public SalaryStructure(int id, int employeeId, double basicSalary, double hra, double transportAllowance,
			double medicalAllowance, double bonus, double otherAllowances, double pf, double professionalTax,
			double loanDeduction, double advanceSalary, double otherDeductions, Date effectiveFrom, String status) {
		this.id = id;
		this.employeeId = employeeId;
		this.basicSalary = basicSalary;
		this.hra = hra;
		this.transportAllowance = transportAllowance;
		this.medicalAllowance = medicalAllowance;
		this.bonus = bonus;
		this.otherAllowances = otherAllowances;
		this.pf = pf;
		this.professionalTax = professionalTax;
		this.loanDeduction = loanDeduction;
		this.advanceSalary = advanceSalary;
		this.otherDeductions = otherDeductions;
		this.effectiveFrom = effectiveFrom;
		this.status = status;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getEmployeeId() {
		return employeeId;
	}

	public void setEmployeeId(int employeeId) {
		this.employeeId = employeeId;
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

	public Date getEffectiveFrom() {
		return effectiveFrom;
	}

	public void setEffectiveFrom(Date effectiveFrom) {
		this.effectiveFrom = effectiveFrom;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public double getGrossSalary() {
		return basicSalary + hra + transportAllowance + medicalAllowance + bonus + otherAllowances;
	}

	public double getTotalDeductions() {
		return pf + professionalTax + loanDeduction + advanceSalary + otherDeductions;
	}

	public double getNetSalary() {
		return getGrossSalary() - getTotalDeductions();
	}
}
