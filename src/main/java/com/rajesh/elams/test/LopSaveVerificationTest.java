package com.rajesh.elams.test;

import com.rajesh.elams.dao.PayrollDao;
import com.rajesh.elams.dao.PayrollDaoImpl;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.service.PayrollService;

public class LopSaveVerificationTest {

	public static void main(String[] args) {
		System.out.println("==================================================");
		System.out.println("   VERIFYING LOP SAVE & RETRIEVAL IN DATABASE");
		System.out.println("==================================================");

		PayrollDao dao = new PayrollDaoImpl();
		PayrollService service = new PayrollService();

		int empId = 1;
		int month = 8;
		int year = 2026;

		// Calculate payroll with LOP
		Payroll p = service.calculateSalaryForEmployee(empId, month, year);
		if (p == null) {
			System.err.println("❌ ERROR: Failed to calculate salary for employee " + empId);
			System.exit(1);
		}

		p.setUnpaidLeaveDays(3);
		p.setUnpaidLeaveDeduction(3461.54);
		p.setTotalDeductions(4300.0 + 3461.54);
		p.setNetSalary(p.getGrossSalary() - p.getTotalDeductions());

		boolean saved = dao.savePayroll(p);
		System.out.println("✔ Payroll Save Status: " + saved);

		Payroll retrieved = dao.getPayrollByEmployeeAndMonth(empId, month, year);
		if (retrieved == null) {
			System.err.println("❌ ERROR: Could not retrieve saved payroll!");
			System.exit(1);
		}

		System.out.println("✔ Retrieved LOP Days: " + retrieved.getUnpaidLeaveDays());
		System.out.println("✔ Retrieved LOP Deduction: ₹" + retrieved.getUnpaidLeaveDeduction());
		System.out.println("✔ Retrieved Net Salary: ₹" + retrieved.getNetSalary());

		if (retrieved.getUnpaidLeaveDays() == 3 && Math.abs(retrieved.getUnpaidLeaveDeduction() - 3461.54) < 0.01) {
			System.out.println("==================================================");
			System.out.println("🎉 LOP SAVE & RETRIEVAL VERIFIED SUCCESSFULLY!");
			System.out.println("==================================================");
		} else {
			System.err.println("❌ ERROR: LOP values in database do not match expected saved values!");
			System.exit(1);
		}
	}
}
