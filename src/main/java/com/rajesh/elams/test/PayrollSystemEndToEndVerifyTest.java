package com.rajesh.elams.test;

import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.PayrollDao;
import com.rajesh.elams.dao.PayrollDaoImpl;
import com.rajesh.elams.dao.SalaryStructureDao;
import com.rajesh.elams.dao.SalaryStructureDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollStatus;
import com.rajesh.elams.model.PayrollSummary;
import com.rajesh.elams.model.SalaryStructure;
import com.rajesh.elams.service.PayrollService;

public class PayrollSystemEndToEndVerifyTest {

	public static void main(String[] args) {
		System.out.println("==================================================");
		System.out.println("   SMARTOFFICE PAYROLL SYSTEM END-TO-END VERIFICATION");
		System.out.println("==================================================");

		try {
			EmployeeDao empDao = new EmployeeDaoImpl();
			SalaryStructureDao salaryDao = new SalaryStructureDaoImpl();
			PayrollService payrollService = new PayrollService();
			PayrollDao payrollDao = new PayrollDaoImpl();

			// Step 1: Ensure test employee exists
			List<Employee> employees = empDao.getAllEmployees();
			if (employees == null || employees.isEmpty()) {
				Employee newEmp = new Employee();
				newEmp.setEmployee_name("Verification Test User");
				newEmp.setEmail("verify.user@smartoffice.com");
				newEmp.setDepartment("Engineering");
				newEmp.setDesignation("Senior Developer");
				newEmp.setPhone(9876543210L);
				empDao.addEmployee(newEmp);
				employees = empDao.getAllEmployees();
			}

			Employee testEmp = employees.get(0);
			int empId = testEmp.getEmployee_id();
			System.out.println("✔ STEP 1: Employee verified -> ID: " + empId + ", Name: " + testEmp.getEmployee_name());

			// Step 2: Ensure salary structure exists with 12-component test values
			SalaryStructure struct = salaryDao.getSalaryStructureByEmployeeId(empId);
			if (struct == null) {
				struct = new SalaryStructure();
				struct.setEmployeeId(empId);
			}
			struct.setBasicSalary(30000.0);
			struct.setHra(10000.0);
			struct.setTransportAllowance(3000.0);
			struct.setMedicalAllowance(2000.0);
			struct.setBonus(1000.0);
			struct.setOtherAllowances(2000.0);

			struct.setPf(3600.0);
			struct.setProfessionalTax(200.0);
			struct.setLoanDeduction(500.0);
			struct.setAdvanceSalary(500.0);
			struct.setOtherDeductions(500.0);

			salaryDao.saveSalaryStructure(struct);
			System.out.println("✔ STEP 2: Salary Structure saved -> Basic: ₹" + struct.getBasicSalary() + ", Gross: ₹" + struct.getGrossSalary());

			// Step 3: Test Salary Calculation
			int month = LocalDate.now().getMonthValue();
			int year = LocalDate.now().getYear();

			Payroll calcResult = payrollService.calculateSalaryForEmployee(empId, month, year);
			if (calcResult == null || calcResult.getGrossSalary() <= 0) {
				throw new RuntimeException("Salary Calculation failed!");
			}
			System.out.println("✔ STEP 3: Salary Calculation PASSED!");
			System.out.println("   - Gross Salary: ₹" + calcResult.getGrossSalary());
			System.out.println("   - Total Deductions: ₹" + calcResult.getTotalDeductions());
			System.out.println("   - Net Salary: ₹" + calcResult.getNetSalary());

			// Step 4: Test Batch Calculation
			payrollDao.updateBatchPayrollStatus(month, year, null, "CALCULATED");
			List<Payroll> batchResult = payrollService.calculateAndSaveBatchPayroll(month, year);
			payrollDao.updateBatchPayrollStatus(month, year, null, "CALCULATED");
			if (batchResult == null || batchResult.isEmpty()) {
				throw new RuntimeException("Batch Calculation failed!");
			}
			System.out.println("✔ STEP 4: Batch Payroll Calculation PASSED -> Processed " + batchResult.size() + " records.");

			// Step 5: Test Approval Workflow Transitions
			// 5.1 Submit for Approval
			payrollService.submitBatchForApproval(month, year);
			Payroll pSubmitted = payrollDao.getPayrollByEmployeeAndMonth(empId, month, year);
			if (pSubmitted == null || !PayrollStatus.PENDING_APPROVAL.name().equals(pSubmitted.getStatus())) {
				throw new RuntimeException("Submit Approval failed! Expected PENDING_APPROVAL, got: " + (pSubmitted != null ? pSubmitted.getStatus() : "null"));
			}
			System.out.println("✔ STEP 5.1: Submit Approval PASSED -> Status: " + pSubmitted.getStatus());

			// 5.2 Executive Approve
			payrollService.approveBatchPayroll(month, year);
			Payroll pApproved = payrollDao.getPayrollByEmployeeAndMonth(empId, month, year);
			if (pApproved == null || !PayrollStatus.APPROVED.name().equals(pApproved.getStatus())) {
				throw new RuntimeException("Executive Approval failed! Expected APPROVED, got: " + (pApproved != null ? pApproved.getStatus() : "null"));
			}
			System.out.println("✔ STEP 5.2: Executive Approve PASSED -> Status: " + pApproved.getStatus());

			// 5.3 Process Payment (Mark Paid)
			payrollService.processAndPayBatchPayroll(month, year);
			Payroll pPaid = payrollDao.getPayrollByEmployeeAndMonth(empId, month, year);
			if (pPaid == null || !PayrollStatus.PAID.name().equals(pPaid.getStatus())) {
				throw new RuntimeException("Payment Disbursal failed! Expected PAID, got: " + (pPaid != null ? pPaid.getStatus() : "null"));
			}
			System.out.println("✔ STEP 5.3: Disburse Payout (Mark Paid) PASSED -> Status: " + pPaid.getStatus());

			// Step 6: Test Payslip Data Retrieval
			Payroll payslipObj = payrollDao.getPayrollById(pPaid.getPayrollId());
			if (payslipObj == null || payslipObj.getNetSalary() <= 0) {
				throw new RuntimeException("Payslip Data Retrieval failed!");
			}
			System.out.println("✔ STEP 6: Payslip Generation Data Retrieval PASSED -> ID: " + payslipObj.getPayrollId() + ", Net: ₹" + payslipObj.getNetSalary());

			// Step 7: Test Payroll Summary Metrics
			PayrollSummary summary = payrollService.getPayrollSummary(month, year);
			if (summary == null || summary.getPaidCount() <= 0) {
				throw new RuntimeException("Payroll Summary generation failed!");
			}
			System.out.println("✔ STEP 7: Payroll Summary Metrics PASSED!");
			System.out.println("   - Total Employees: " + summary.getTotalEmployees());
			System.out.println("   - Paid Count: " + summary.getPaidCount());
			System.out.println("   - Total Net Amount: ₹" + summary.getTotalNetAmount());

			System.out.println("==================================================");
			System.out.println("🎉 ALL END-TO-END PAYROLL & APPROVAL VERIFICATIONS PASSED!");
			System.out.println("==================================================");
		} catch (Exception e) {
			System.err.println("❌ VERIFICATION TEST FAILED: " + e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}
	}
}
