package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.Payroll;
import com.rajesh.elams.model.PayrollSummary;
import com.rajesh.elams.util.DbUtil;

public class PayrollDaoImpl implements PayrollDao {

	public PayrollDaoImpl() {
		createTableIfNotExists();
	}

	private void createTableIfNotExists() {
		String sql = "CREATE TABLE IF NOT EXISTS payroll ("
				+ "payroll_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "employee_id INT NOT NULL, "
				+ "month INT NOT NULL, "
				+ "year INT NOT NULL, "
				+ "basic_salary DOUBLE NOT NULL, "
				+ "hra DOUBLE DEFAULT 0.0, "
				+ "transport_allowance DOUBLE DEFAULT 0.0, "
				+ "medical_allowance DOUBLE DEFAULT 0.0, "
				+ "bonus DOUBLE DEFAULT 0.0, "
				+ "other_allowances DOUBLE DEFAULT 0.0, "
				+ "gross_salary DOUBLE NOT NULL, "
				+ "pf DOUBLE DEFAULT 0.0, "
				+ "professional_tax DOUBLE DEFAULT 0.0, "
				+ "loan_deduction DOUBLE DEFAULT 0.0, "
				+ "advance_salary DOUBLE DEFAULT 0.0, "
				+ "other_deductions DOUBLE DEFAULT 0.0, "
				+ "unpaid_leave_deduction DOUBLE DEFAULT 0.0, "
				+ "lop_deduction DOUBLE DEFAULT 0.0, "
				+ "total_deductions DOUBLE NOT NULL, "
				+ "net_salary DOUBLE NOT NULL, "
				+ "working_days INT DEFAULT 26, "
				+ "present_days INT DEFAULT 26, "
				+ "unpaid_leave_days INT DEFAULT 0, "
				+ "unpaid_leaves INT DEFAULT 0, "
				+ "status VARCHAR(30) DEFAULT 'DRAFT', "
				+ "payment_date DATE NULL, "
				+ "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
				+ "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, "
				+ "UNIQUE KEY uk_employee_month_year (employee_id, month, year)"
				+ ")";
		try (Connection conn = DbUtil.getConnection();
			 Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(sql);
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN month INT NOT NULL DEFAULT 8"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN year INT NOT NULL DEFAULT 2026"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN transport_allowance DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN medical_allowance DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN other_allowances DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN bonus DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN gross_salary DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN pf DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN professional_tax DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN loan_deduction DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN advance_salary DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN other_deductions DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN unpaid_leave_deduction DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN lop_deduction DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN total_deductions DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN net_salary DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN working_days INT DEFAULT 26"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN present_days INT DEFAULT 26"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN unpaid_leave_days INT DEFAULT 0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN unpaid_leaves INT DEFAULT 0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN status VARCHAR(30) DEFAULT 'DRAFT'"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE payroll ADD COLUMN payment_date DATE NULL"); } catch (Exception ignored) {}
		} catch (Exception e) {
			System.err.println("Error creating payroll table: " + e.getMessage());
		}
	}

	@Override
	public boolean savePayroll(Payroll p) {
		Payroll existing = getPayrollByEmployeeAndMonth(p.getEmployeeId(), p.getMonth(), p.getYear());
		if (existing != null) {
			p.setPayrollId(existing.getPayrollId());
			return updatePayroll(p);
		}

		String sql = "INSERT INTO payroll (employee_id, month, year, basic_salary, hra, transport_allowance, "
				+ "medical_allowance, bonus, other_allowances, gross_salary, pf, professional_tax, loan_deduction, "
				+ "other_deductions, unpaid_leave_deduction, lop_deduction, total_deductions, net_salary, working_days, present_days, "
				+ "unpaid_leave_days, unpaid_leaves, status, payment_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

			ps.setInt(1, p.getEmployeeId());
			ps.setInt(2, p.getMonth());
			ps.setInt(3, p.getYear());
			ps.setDouble(4, p.getBasicSalary());
			ps.setDouble(5, p.getHra());
			ps.setDouble(6, p.getTransportAllowance());
			ps.setDouble(7, p.getMedicalAllowance());
			ps.setDouble(8, p.getBonus());
			ps.setDouble(9, p.getOtherAllowances());
			ps.setDouble(10, p.getGrossSalary());
			ps.setDouble(11, p.getPf());
			ps.setDouble(12, p.getProfessionalTax());
			ps.setDouble(13, p.getLoanDeduction());
			ps.setDouble(14, p.getOtherDeductions());
			ps.setDouble(15, p.getUnpaidLeaveDeduction());
			ps.setDouble(16, p.getUnpaidLeaveDeduction());
			ps.setDouble(17, p.getTotalDeductions());
			ps.setDouble(18, p.getNetSalary());
			ps.setInt(19, p.getWorkingDays());
			ps.setInt(20, p.getPresentDays());
			ps.setInt(21, p.getUnpaidLeaveDays());
			ps.setInt(22, p.getUnpaidLeaveDays());
			ps.setString(23, p.getStatus() != null ? p.getStatus() : "DRAFT");
			ps.setDate(24, p.getPaymentDate());

			int affected = ps.executeUpdate();
			if (affected > 0) {
				try (ResultSet rs = ps.getGeneratedKeys()) {
					if (rs.next()) {
						p.setPayrollId(rs.getInt(1));
					}
				}
				return true;
			}
		} catch (Exception e) {
			// Fallback if schema has standard column set
			String fallbackSql = "INSERT INTO payroll (employee_id, month, year, basic_salary, hra, transport_allowance, "
					+ "medical_allowance, bonus, other_allowances, gross_salary, pf, professional_tax, loan_deduction, "
					+ "other_deductions, unpaid_leave_deduction, total_deductions, net_salary, working_days, present_days, "
					+ "unpaid_leave_days, status, payment_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
			try (Connection conn = DbUtil.getConnection();
				 PreparedStatement ps = conn.prepareStatement(fallbackSql, Statement.RETURN_GENERATED_KEYS)) {

				ps.setInt(1, p.getEmployeeId());
				ps.setInt(2, p.getMonth());
				ps.setInt(3, p.getYear());
				ps.setDouble(4, p.getBasicSalary());
				ps.setDouble(5, p.getHra());
				ps.setDouble(6, p.getTransportAllowance());
				ps.setDouble(7, p.getMedicalAllowance());
				ps.setDouble(8, p.getBonus());
				ps.setDouble(9, p.getOtherAllowances());
				ps.setDouble(10, p.getGrossSalary());
				ps.setDouble(11, p.getPf());
				ps.setDouble(12, p.getProfessionalTax());
				ps.setDouble(13, p.getLoanDeduction());
				ps.setDouble(14, p.getOtherDeductions());
				ps.setDouble(15, p.getUnpaidLeaveDeduction());
				ps.setDouble(16, p.getTotalDeductions());
				ps.setDouble(17, p.getNetSalary());
				ps.setInt(18, p.getWorkingDays());
				ps.setInt(19, p.getPresentDays());
				ps.setInt(20, p.getUnpaidLeaveDays());
				ps.setString(21, p.getStatus() != null ? p.getStatus() : "DRAFT");
				ps.setDate(22, p.getPaymentDate());

				int affected = ps.executeUpdate();
				if (affected > 0) {
					try (ResultSet rs = ps.getGeneratedKeys()) {
						if (rs.next()) {
							p.setPayrollId(rs.getInt(1));
						}
					}
					return true;
				}
			} catch (Exception ex) {
				System.err.println("Error saving payroll: " + ex.getMessage());
			}
		}
		return false;
	}

	@Override
	public boolean updatePayroll(Payroll p) {
		String sql = "UPDATE payroll SET basic_salary=?, hra=?, transport_allowance=?, medical_allowance=?, bonus=?, "
				+ "other_allowances=?, gross_salary=?, pf=?, professional_tax=?, loan_deduction=?, other_deductions=?, "
				+ "unpaid_leave_deduction=?, lop_deduction=?, total_deductions=?, net_salary=?, working_days=?, present_days=?, "
				+ "unpaid_leave_days=?, unpaid_leaves=?, status=?, payment_date=? WHERE payroll_id=?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setDouble(1, p.getBasicSalary());
			ps.setDouble(2, p.getHra());
			ps.setDouble(3, p.getTransportAllowance());
			ps.setDouble(4, p.getMedicalAllowance());
			ps.setDouble(5, p.getBonus());
			ps.setDouble(6, p.getOtherAllowances());
			ps.setDouble(7, p.getGrossSalary());
			ps.setDouble(8, p.getPf());
			ps.setDouble(9, p.getProfessionalTax());
			ps.setDouble(10, p.getLoanDeduction());
			ps.setDouble(11, p.getOtherDeductions());
			ps.setDouble(12, p.getUnpaidLeaveDeduction());
			ps.setDouble(13, p.getUnpaidLeaveDeduction());
			ps.setDouble(14, p.getTotalDeductions());
			ps.setDouble(15, p.getNetSalary());
			ps.setInt(16, p.getWorkingDays());
			ps.setInt(17, p.getPresentDays());
			ps.setInt(18, p.getUnpaidLeaveDays());
			ps.setInt(19, p.getUnpaidLeaveDays());
			ps.setString(20, p.getStatus());
			ps.setDate(21, p.getPaymentDate());
			ps.setInt(22, p.getPayrollId());

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			String fallbackSql = "UPDATE payroll SET basic_salary=?, hra=?, transport_allowance=?, medical_allowance=?, bonus=?, "
					+ "other_allowances=?, gross_salary=?, pf=?, professional_tax=?, loan_deduction=?, other_deductions=?, "
					+ "unpaid_leave_deduction=?, total_deductions=?, net_salary=?, working_days=?, present_days=?, "
					+ "unpaid_leave_days=?, status=?, payment_date=? WHERE payroll_id=?";
			try (Connection conn = DbUtil.getConnection();
				 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {

				ps.setDouble(1, p.getBasicSalary());
				ps.setDouble(2, p.getHra());
				ps.setDouble(3, p.getTransportAllowance());
				ps.setDouble(4, p.getMedicalAllowance());
				ps.setDouble(5, p.getBonus());
				ps.setDouble(6, p.getOtherAllowances());
				ps.setDouble(7, p.getGrossSalary());
				ps.setDouble(8, p.getPf());
				ps.setDouble(9, p.getProfessionalTax());
				ps.setDouble(10, p.getLoanDeduction());
				ps.setDouble(11, p.getOtherDeductions());
				ps.setDouble(12, p.getUnpaidLeaveDeduction());
				ps.setDouble(13, p.getTotalDeductions());
				ps.setDouble(14, p.getNetSalary());
				ps.setInt(15, p.getWorkingDays());
				ps.setInt(16, p.getPresentDays());
				ps.setInt(17, p.getUnpaidLeaveDays());
				ps.setString(18, p.getStatus());
				ps.setDate(19, p.getPaymentDate());
				ps.setInt(20, p.getPayrollId());

				return ps.executeUpdate() > 0;
			} catch (Exception ex) {
				System.err.println("Error updating payroll: " + ex.getMessage());
			}
		}
		return false;
	}

	@Override
	public boolean updatePayrollStatus(int payrollId, String status) {
		Date payDate = "PAID".equalsIgnoreCase(status) ? new Date(System.currentTimeMillis()) : null;
		String sql = "UPDATE payroll SET status = ?, payment_date = COALESCE(payment_date, ?) WHERE payroll_id = ?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, status);
			ps.setDate(2, payDate);
			ps.setInt(3, payrollId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("Error updating payroll status: " + e.getMessage());
		}
		return false;
	}

	@Override
	public boolean updateBatchPayrollStatus(int month, int year, String fromStatus, String toStatus) {
		Date payDate = "PAID".equalsIgnoreCase(toStatus) ? new Date(System.currentTimeMillis()) : null;
		StringBuilder sql = new StringBuilder("UPDATE payroll SET status = ?, payment_date = COALESCE(payment_date, ?) WHERE month = ? AND year = ?");
		if (fromStatus != null && !fromStatus.isBlank() && !"ALL".equalsIgnoreCase(fromStatus)) {
			sql.append(" AND status = ?");
		}
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql.toString())) {
			ps.setString(1, toStatus);
			ps.setDate(2, payDate);
			ps.setInt(3, month);
			ps.setInt(4, year);
			if (fromStatus != null && !fromStatus.isBlank() && !"ALL".equalsIgnoreCase(fromStatus)) {
				ps.setString(5, fromStatus);
			}
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("Error updating batch payroll status: " + e.getMessage());
		}
		return false;
	}

	@Override
	public Payroll getPayrollById(int payrollId) {
		String sql = "SELECT p.*, e.employee_name, e.department, e.designation, e.email "
				+ "FROM payroll p JOIN employees e ON p.employee_id = e.employee_id WHERE p.payroll_id = ?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, payrollId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return extractPayroll(rs);
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting payroll by id: " + e.getMessage());
		}
		return null;
	}

	@Override
	public Payroll getPayrollByEmployeeAndMonth(int employeeId, int month, int year) {
		String sql = "SELECT p.*, e.employee_name, e.department, e.designation, e.email "
				+ "FROM payroll p JOIN employees e ON p.employee_id = e.employee_id "
				+ "WHERE p.employee_id = ? AND p.month = ? AND p.year = ?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, employeeId);
			ps.setInt(2, month);
			ps.setInt(3, year);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return extractPayroll(rs);
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting payroll by employee and month: " + e.getMessage());
		}
		return null;
	}

	@Override
	public List<Payroll> getPayrollsByMonth(int month, int year) {
		List<Payroll> list = new ArrayList<>();
		String sql = "SELECT p.*, e.employee_name, e.department, e.designation, e.email "
				+ "FROM payroll p JOIN employees e ON p.employee_id = e.employee_id "
				+ "WHERE p.month = ? AND p.year = ? ORDER BY e.employee_name ASC";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, month);
			ps.setInt(2, year);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(extractPayroll(rs));
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting payrolls by month: " + e.getMessage());
		}
		return list;
	}

	@Override
	public List<Payroll> getPayrollsByEmployee(int employeeId) {
		List<Payroll> list = new ArrayList<>();
		String sql = "SELECT p.*, e.employee_name, e.department, e.designation, e.email "
				+ "FROM payroll p JOIN employees e ON p.employee_id = e.employee_id "
				+ "WHERE p.employee_id = ? ORDER BY p.year DESC, p.month DESC";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, employeeId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(extractPayroll(rs));
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting payrolls by employee: " + e.getMessage());
		}
		return list;
	}

	@Override
	public List<Payroll> getPayrollsByDepartment(String department, int month, int year) {
		List<Payroll> list = new ArrayList<>();
		String sql = "SELECT p.*, e.employee_name, e.department, e.designation, e.email "
				+ "FROM payroll p JOIN employees e ON p.employee_id = e.employee_id "
				+ "WHERE p.month = ? AND p.year = ? AND e.department = ? ORDER BY e.employee_name ASC";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, month);
			ps.setInt(2, year);
			ps.setString(3, department);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(extractPayroll(rs));
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting payrolls by department: " + e.getMessage());
		}
		return list;
	}

	@Override
	public PayrollSummary getPayrollSummary(int month, int year) {
		PayrollSummary summary = new PayrollSummary();
		summary.setMonth(month);
		summary.setYear(year);

		// Get total employees
		String empCountSql = "SELECT COUNT(*) FROM employees";
		try (Connection conn = DbUtil.getConnection();
			 Statement stmt = conn.createStatement();
			 ResultSet rs = stmt.executeQuery(empCountSql)) {
			if (rs.next()) {
				summary.setTotalEmployees(rs.getInt(1));
			}
		} catch (Exception e) {
			System.err.println("Error getting employee count for summary: " + e.getMessage());
		}

		String sql = "SELECT "
				+ "COUNT(*) as total_records, "
				+ "SUM(CASE WHEN status = 'CALCULATED' THEN 1 ELSE 0 END) as calculated_cnt, "
				+ "SUM(CASE WHEN status = 'PENDING_APPROVAL' THEN 1 ELSE 0 END) as pending_cnt, "
				+ "SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) as approved_cnt, "
				+ "SUM(CASE WHEN status = 'PAID' OR status = 'PROCESSED' THEN 1 ELSE 0 END) as paid_cnt, "
				+ "COALESCE(SUM(gross_salary), 0.0) as sum_gross, "
				+ "COALESCE(SUM(total_deductions), 0.0) as sum_deductions, "
				+ "COALESCE(SUM(COALESCE(unpaid_leave_deduction, lop_deduction)), 0.0) as sum_lop, "
				+ "COALESCE(SUM(net_salary), 0.0) as sum_net "
				+ "FROM payroll WHERE month = ? AND year = ?";

		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, month);
			ps.setInt(2, year);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					summary.setCalculatedCount(rs.getInt("calculated_cnt"));
					summary.setPendingApprovalCount(rs.getInt("pending_cnt"));
					summary.setApprovedCount(rs.getInt("approved_cnt"));
					summary.setPaidCount(rs.getInt("paid_cnt"));
					summary.setTotalGrossAmount(rs.getDouble("sum_gross"));
					summary.setTotalDeductionsAmount(rs.getDouble("sum_deductions"));
					summary.setTotalLopDeductionsAmount(rs.getDouble("sum_lop"));
					summary.setTotalNetAmount(rs.getDouble("sum_net"));
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting payroll summary: " + e.getMessage());
		}
		return summary;
	}

	@Override
	public boolean deletePayroll(int payrollId) {
		String sql = "DELETE FROM payroll WHERE payroll_id = ?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, payrollId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("Error deleting payroll: " + e.getMessage());
		}
		return false;
	}

	private Payroll extractPayroll(ResultSet rs) throws SQLException {
		Payroll p = new Payroll();
		p.setPayrollId(rs.getInt("payroll_id"));
		p.setEmployeeId(rs.getInt("employee_id"));
		try { p.setMonth(rs.getInt("month")); } catch (Exception e1) { try { p.setMonth(rs.getInt("payroll_month")); } catch (Exception ignored) {} }
		try { p.setYear(rs.getInt("year")); } catch (Exception e1) { try { p.setYear(rs.getInt("payroll_year")); } catch (Exception ignored) {} }
		p.setBasicSalary(rs.getDouble("basic_salary"));
		p.setHra(rs.getDouble("hra"));
		p.setTransportAllowance(rs.getDouble("transport_allowance"));
		p.setMedicalAllowance(rs.getDouble("medical_allowance"));
		p.setBonus(rs.getDouble("bonus"));
		p.setOtherAllowances(rs.getDouble("other_allowances"));
		p.setGrossSalary(rs.getDouble("gross_salary"));
		p.setPf(rs.getDouble("pf"));
		p.setProfessionalTax(rs.getDouble("professional_tax"));
		p.setLoanDeduction(rs.getDouble("loan_deduction"));
		try { p.setAdvanceSalary(rs.getDouble("advance_salary")); } catch (Exception ignored) {}
		p.setOtherDeductions(rs.getDouble("other_deductions"));
		
		double lopDed = 0.0;
		try { lopDed = rs.getDouble("unpaid_leave_deduction"); } catch (Exception e1) { try { lopDed = rs.getDouble("lop_deduction"); } catch (Exception ignored) {} }
		p.setUnpaidLeaveDeduction(lopDed);

		p.setTotalDeductions(rs.getDouble("total_deductions"));
		p.setNetSalary(rs.getDouble("net_salary"));
		p.setWorkingDays(rs.getInt("working_days"));
		p.setPresentDays(rs.getInt("present_days"));

		int lopDays = 0;
		try { lopDays = rs.getInt("unpaid_leave_days"); } catch (Exception e1) { try { lopDays = rs.getInt("unpaid_leaves"); } catch (Exception ignored) {} }
		p.setUnpaidLeaveDays(lopDays);
		p.setStatus(rs.getString("status"));
		p.setPaymentDate(rs.getDate("payment_date"));
		try { p.setCreatedAt(rs.getTimestamp("created_at")); } catch (Exception ignored) {}
		try { p.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (Exception ignored) {}

		try {
			p.setEmployeeName(rs.getString("employee_name"));
			p.setDepartment(rs.getString("department"));
			p.setDesignation(rs.getString("designation"));
			p.setEmail(rs.getString("email"));
		} catch (SQLException ignored) {}

		return p;
	}
}
