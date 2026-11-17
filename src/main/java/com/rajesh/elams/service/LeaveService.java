package com.rajesh.elams.service;

import java.util.List;

import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.model.Leave;

public class LeaveService {

	private final LeaveDao leaveDao;

	public LeaveService() {
		this.leaveDao = new LeaveDaoImpl();
	}

	public boolean applyLeave(Leave leave) {
		if (leave == null || leave.getEmployeeId() <= 0) return false;
		if (leave.getStartDate() == null || leave.getEndDate() == null) return false;
		leave.setStatus("Pending");
		return leaveDao.applyLeave(leave);
	}

	public List<Leave> getPendingLeaves() {
		return leaveDao.getPendingLeaves();
	}

	public List<Leave> getAllLeaves() {
		return leaveDao.getAllLeaves();
	}

	public List<Leave> getLeavesByEmployee(int employeeId) {
		if (employeeId <= 0) return List.of();
		return leaveDao.getLeavesByEmployee(employeeId);
	}

	public boolean approveLeave(int leaveId) {
		if (leaveId <= 0) return false;
		return leaveDao.updateLeaveStatus(leaveId, "Approved");
	}

	public boolean approveLeaveAsLop(int leaveId) {
		if (leaveId <= 0) return false;
		Leave leave = leaveDao.getLeaveById(leaveId);
		if (leave == null) return false;
		String updatedType = "Loss of Pay (LOP)";
		if (leave.getLeaveType() != null && !leave.getLeaveType().toUpperCase().contains("LOP")) {
			updatedType = leave.getLeaveType() + " (Converted to LOP)";
		}
		return leaveDao.updateLeaveStatusAndType(leaveId, "Approved", updatedType);
	}

	public boolean approveLeaveWithAutoLopCheck(int leaveId, int annualPaidQuota) {
		if (leaveId <= 0) return false;
		Leave leave = leaveDao.getLeaveById(leaveId);
		if (leave == null) return false;

		// If leave is explicitly requested as LOP/Unpaid, approve as LOP
		String reqType = leave.getLeaveType() != null ? leave.getLeaveType().toUpperCase() : "";
		if (reqType.contains("LOP") || reqType.contains("UNPAID") || reqType.contains("WITHOUT PAY")) {
			return approveLeaveAsLop(leaveId);
		}

		// Calculate total paid leave days already approved in current year
		int currentYear = java.time.LocalDate.now().getYear();
		List<Leave> empLeaves = leaveDao.getLeavesByEmployee(leave.getEmployeeId());
		int paidDaysTaken = 0;

		if (empLeaves != null) {
			for (Leave l : empLeaves) {
				if (l.getLeaveId() != leaveId && "Approved".equalsIgnoreCase(l.getStatus())) {
					String type = l.getLeaveType() != null ? l.getLeaveType().toUpperCase() : "";
					if (!type.contains("LOP") && !type.contains("UNPAID") && !type.contains("WITHOUT PAY")) {
						if (l.getStartDate() != null) {
							java.time.LocalDate s = l.getStartDate().toLocalDate();
							java.time.LocalDate e = l.getEndDate() != null ? l.getEndDate().toLocalDate() : s;
							if (s.getYear() == currentYear) {
								long days = java.time.temporal.ChronoUnit.DAYS.between(s, e) + 1;
								paidDaysTaken += (int) Math.max(1, days);
							}
						}
					}
				}
			}
		}

		// Check days requested in this leave
		java.time.LocalDate reqStart = leave.getStartDate() != null ? leave.getStartDate().toLocalDate() : java.time.LocalDate.now();
		java.time.LocalDate reqEnd = leave.getEndDate() != null ? leave.getEndDate().toLocalDate() : reqStart;
		long reqDays = java.time.temporal.ChronoUnit.DAYS.between(reqStart, reqEnd) + 1;

		if (paidDaysTaken + reqDays > annualPaidQuota) {
			// Balance exhausted -> Auto-convert to LOP
			return approveLeaveAsLop(leaveId);
		} else {
			// Normal Paid Leave approval
			return approveLeave(leaveId);
		}
	}

	public boolean rejectLeave(int leaveId) {
		if (leaveId <= 0) return false;
		return leaveDao.updateLeaveStatus(leaveId, "Rejected");
	}
}
