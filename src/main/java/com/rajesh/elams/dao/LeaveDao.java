package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.Leave;

public interface LeaveDao {
	boolean applyLeave(Leave leave);

	boolean updateLeaveStatus(int leaveId, String status);

	boolean updateLeaveStatusAndType(int leaveId, String status, String leaveType);

	boolean cancelLeave(int leaveId);

	Leave getLeaveById(int leaveId);

	List<Leave> getLeavesByEmployee(int employeeId);

	List<Leave> getPendingLeaves();

	List<Leave> getApprovedLeaves();

	List<Leave> getRejectedLeaves();

	List<Leave> getAllLeaves();
}
