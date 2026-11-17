package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollSummary;

public interface PayrollDao {
	boolean savePayroll(Payroll payroll);

	boolean updatePayroll(Payroll payroll);

	boolean updatePayrollStatus(int payrollId, String status);

	boolean updateBatchPayrollStatus(int month, int year, String fromStatus, String toStatus);

	Payroll getPayrollById(int payrollId);

	Payroll getPayrollByEmployeeAndMonth(int employeeId, int month, int year);

	List<Payroll> getPayrollsByMonth(int month, int year);

	List<Payroll> getPayrollsByEmployee(int employeeId);

	List<Payroll> getPayrollsByDepartment(String department, int month, int year);

	PayrollSummary getPayrollSummary(int month, int year);

	boolean deletePayroll(int payrollId);
}
