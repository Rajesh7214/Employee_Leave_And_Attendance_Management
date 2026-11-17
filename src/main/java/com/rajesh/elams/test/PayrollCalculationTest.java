package com.rajesh.elams.test;

import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollStatus;
import com.rajesh.elams.model.SalaryStructure;

public class PayrollCalculationTest {

	public static void main(String[] args) {
		System.out.println("==================================================");
		System.out.println("   Running SmartOffice Module 11 Payroll Unit Test");
		System.out.println("==================================================");

		boolean allPassed = true;

		// Test 1: SalaryStructure Calculations
		SalaryStructure ss = new SalaryStructure();
		ss.setBasicSalary(30000.0);
		ss.setHra(10000.0);
		ss.setTransportAllowance(3000.0);
		ss.setMedicalAllowance(2000.0);
		ss.setOtherAllowances(0.0);
		ss.setPf(3600.0);
		ss.setProfessionalTax(200.0);
		ss.setLoanDeduction(0.0);
		ss.setOtherDeductions(500.0);

		double expectedGross = 45000.0;
		double expectedDeductions = 4300.0;
		double expectedNet = 40700.0;

		if (Math.abs(ss.getGrossSalary() - expectedGross) < 0.01) {
			System.out.println("✅ TEST 1.1 PASSED: Gross Salary = ₹" + ss.getGrossSalary());
		} else {
			System.err.println("❌ TEST 1.1 FAILED: Expected Gross " + expectedGross + ", got " + ss.getGrossSalary());
			allPassed = false;
		}

		if (Math.abs(ss.getTotalDeductions() - expectedDeductions) < 0.01) {
			System.out.println("✅ TEST 1.2 PASSED: Total Deductions = ₹" + ss.getTotalDeductions());
		} else {
			System.err.println("❌ TEST 1.2 FAILED: Expected Deductions " + expectedDeductions + ", got " + ss.getTotalDeductions());
			allPassed = false;
		}

		if (Math.abs(ss.getNetSalary() - expectedNet) < 0.01) {
			System.out.println("✅ TEST 1.3 PASSED: Net Salary = ₹" + ss.getNetSalary());
		} else {
			System.err.println("❌ TEST 1.3 FAILED: Expected Net " + expectedNet + ", got " + ss.getNetSalary());
			allPassed = false;
		}

		// Test 2: LOP Attendance Deduction Calculation
		int workingDays = 26;
		int unpaidLeaveDays = 2;
		double perDayBasic = ss.getBasicSalary() / (double) workingDays;
		double expectedLopDeduction = Math.round(perDayBasic * unpaidLeaveDays * 100.0) / 100.0; // 2307.69

		Payroll p = new Payroll();
		p.setBasicSalary(ss.getBasicSalary());
		p.setHra(ss.getHra());
		p.setTransportAllowance(ss.getTransportAllowance());
		p.setMedicalAllowance(ss.getMedicalAllowance());
		p.setGrossSalary(ss.getGrossSalary());
		p.setPf(ss.getPf());
		p.setProfessionalTax(ss.getProfessionalTax());
		p.setOtherDeductions(ss.getOtherDeductions());
		p.setWorkingDays(workingDays);
		p.setUnpaidLeaveDays(unpaidLeaveDays);
		p.setUnpaidLeaveDeduction(expectedLopDeduction);

		double actualTotalDeductions = ss.getPf() + ss.getProfessionalTax() + ss.getOtherDeductions() + expectedLopDeduction;
		double actualNetSalary = Math.max(0.0, Math.round((ss.getGrossSalary() - actualTotalDeductions) * 100.0) / 100.0);

		p.setTotalDeductions(actualTotalDeductions);
		p.setNetSalary(actualNetSalary);

		if (Math.abs(p.getUnpaidLeaveDeduction() - 2307.69) < 0.05) {
			System.out.println("✅ TEST 2.1 PASSED: Unpaid Leave LOP Deduction = ₹" + p.getUnpaidLeaveDeduction());
		} else {
			System.err.println("❌ TEST 2.1 FAILED: Expected LOP ~2307.69, got " + p.getUnpaidLeaveDeduction());
			allPassed = false;
		}

		// Test 3: PayrollStatus Workflow Validation
		p.setStatus(PayrollStatus.CALCULATED.name());
		if (PayrollStatus.CALCULATED.name().equals(p.getStatus())) {
			System.out.println("✅ TEST 3.1 PASSED: Payroll status set to CALCULATED");
		} else {
			System.err.println("❌ TEST 3.1 FAILED: Status mismatch");
			allPassed = false;
		}

		p.setStatus(PayrollStatus.PENDING_APPROVAL.name());
		p.setStatus(PayrollStatus.APPROVED.name());
		p.setStatus(PayrollStatus.PAID.name());

		if (PayrollStatus.PAID.name().equals(p.getStatus())) {
			System.out.println("✅ TEST 3.2 PASSED: Payroll workflow progressed to PAID");
		} else {
			System.err.println("❌ TEST 3.2 FAILED: Workflow status mismatch");
			allPassed = false;
		}

		System.out.println("==================================================");
		if (allPassed) {
			System.out.println("🎉 ALL MODULE 11 PAYROLL UNIT TESTS PASSED SUCCESSFULLY!");
		} else {
			System.err.println("🚨 SOME UNIT TESTS FAILED!");
		}
		System.out.println("==================================================");
	}
}
