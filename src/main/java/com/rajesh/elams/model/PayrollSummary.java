package com.rajesh.elams.model;

import java.io.Serializable;

public class PayrollSummary implements Serializable {
	private static final long serialVersionUID = 1L;

	private int month;
	private int year;
	private int totalEmployees;
	private int calculatedCount;
	private int pendingApprovalCount;
	private int approvedCount;
	private int paidCount;

	private double totalGrossAmount;
	private double totalDeductionsAmount;
	private double totalLopDeductionsAmount;
	private double totalNetAmount;

	public PayrollSummary() {
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

	public int getTotalEmployees() {
		return totalEmployees;
	}

	public void setTotalEmployees(int totalEmployees) {
		this.totalEmployees = totalEmployees;
	}

	public int getCalculatedCount() {
		return calculatedCount;
	}

	public void setCalculatedCount(int calculatedCount) {
		this.calculatedCount = calculatedCount;
	}

	public int getPendingApprovalCount() {
		return pendingApprovalCount;
	}

	public void setPendingApprovalCount(int pendingApprovalCount) {
		this.pendingApprovalCount = pendingApprovalCount;
	}

	public int getApprovedCount() {
		return approvedCount;
	}

	public void setApprovedCount(int approvedCount) {
		this.approvedCount = approvedCount;
	}

	public int getPaidCount() {
		return paidCount;
	}

	public void setPaidCount(int paidCount) {
		this.paidCount = paidCount;
	}

	public double getTotalGrossAmount() {
		return totalGrossAmount;
	}

	public void setTotalGrossAmount(double totalGrossAmount) {
		this.totalGrossAmount = totalGrossAmount;
	}

	public double getTotalDeductionsAmount() {
		return totalDeductionsAmount;
	}

	public void setTotalDeductionsAmount(double totalDeductionsAmount) {
		this.totalDeductionsAmount = totalDeductionsAmount;
	}

	public double getTotalLopDeductionsAmount() {
		return totalLopDeductionsAmount;
	}

	public void setTotalLopDeductionsAmount(double totalLopDeductionsAmount) {
		this.totalLopDeductionsAmount = totalLopDeductionsAmount;
	}

	public double getTotalNetAmount() {
		return totalNetAmount;
	}

	public void setTotalNetAmount(double totalNetAmount) {
		this.totalNetAmount = totalNetAmount;
	}
}
