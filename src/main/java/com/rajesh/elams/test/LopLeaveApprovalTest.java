package com.rajesh.elams.test;

import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.model.Leave;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.service.LeaveService;
import com.rajesh.elams.service.PayrollService;

public class LopLeaveApprovalTest {

	public static void main(String[] args) {
		System.out.println("==================================================");
		System.out.println("   VERIFYING AUTO-LOP LEAVE APPROVAL & PAYROLL");
		System.out.println("==================================================");

		LeaveDao leaveDao = new LeaveDaoImpl();
		LeaveService leaveService = new LeaveService();
		PayrollService payrollService = new PayrollService();

		int empId = 4; // Test employee (e.g. Rajesh Kumar)
		LocalDate startLd = LocalDate.of(2026, 9, 10);
		LocalDate endLd = LocalDate.of(2026, 9, 12); // 3 Days leave

		Leave leave = new Leave();
		leave.setEmployeeId(empId);
		leave.setLeaveType("Casual Leave");
		leave.setStartdate(Date.valueOf(startLd));
		leave.setEndDate(Date.valueOf(endLd));
		leave.setReason("Urgent personal work - testing LOP auto conversion");
		leave.setStatus("Pending");

		boolean applied = leaveDao.applyLeave(leave);
		System.out.println("✔ Applied test leave: " + applied);

		// Get inserted leave
		List<Leave> empLeaves = leaveDao.getLeavesByEmployee(empId);
		Leave insertedLeave = null;
		if (empLeaves != null && !empLeaves.isEmpty()) {
			insertedLeave = empLeaves.get(0); // Latest leave
		}

		if (insertedLeave == null) {
			System.err.println("❌ ERROR: Failed to retrieve inserted leave application!");
			System.exit(1);
		}

		int leaveId = insertedLeave.getLeaveId();
		System.out.println("✔ Retrieved Leave ID: #" + leaveId + " (Initial Type: " + insertedLeave.getLeaveType() + ")");

		// Approve as LOP
		boolean approvedAsLop = leaveService.approveLeaveAsLop(leaveId);
		System.out.println("✔ Approved Leave #" + leaveId + " as LOP Status: " + approvedAsLop);

		Leave updatedLeave = leaveDao.getLeaveById(leaveId);
		System.out.println("✔ Updated Leave Type in DB: " + (updatedLeave != null ? updatedLeave.getLeaveType() : "NULL"));
		System.out.println("✔ Updated Leave Status in DB: " + (updatedLeave != null ? updatedLeave.getStatus() : "NULL"));

		// Calculate September 2026 Payroll
		Payroll p = payrollService.calculateSalaryForEmployee(empId, 9, 2026);
		if (p == null) {
			System.err.println("❌ ERROR: Failed to calculate September 2026 payroll!");
			System.exit(1);
		}

		System.out.println("--------------------------------------------------");
		System.out.println("✔ Payroll Month/Year: " + p.getMonth() + "/" + p.getYear());
		System.out.println("✔ Unpaid Leave (LOP) Days Calculated: " + p.getUnpaidLeaveDays());
		System.out.println("✔ LOP Deduction Amount: ₹" + p.getUnpaidLeaveDeduction());
		System.out.println("✔ Gross Salary: ₹" + p.getGrossSalary());
		System.out.println("✔ Net Salary after LOP: ₹" + p.getNetSalary());
		System.out.println("--------------------------------------------------");

		if (updatedLeave != null && updatedLeave.getLeaveType().contains("LOP") && p.getUnpaidLeaveDays() >= 3 && p.getUnpaidLeaveDeduction() > 0) {
			System.out.println("==================================================");
			System.out.println("🎉 AUTO-LOP APPROVAL & PAYROLL DEDUCTION VERIFIED!");
			System.out.println("==================================================");
		} else {
			System.err.println("❌ ERROR: Verification failed. LOP leaves or payroll math did not reflect expected values.");
			System.exit(1);
		}
	}
}
