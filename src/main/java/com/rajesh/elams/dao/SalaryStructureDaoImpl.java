package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.SalaryStructure;
import com.rajesh.elams.util.DbUtil;

public class SalaryStructureDaoImpl implements SalaryStructureDao {

	public SalaryStructureDaoImpl() {
		createTableIfNotExists();
	}

	private void createTableIfNotExists() {
		String sql = "CREATE TABLE IF NOT EXISTS salary_structure ("
				+ "id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "employee_id INT NOT NULL UNIQUE, "
				+ "basic_salary DOUBLE DEFAULT 30000.0, "
				+ "hra DOUBLE DEFAULT 10000.0, "
				+ "transport_allowance DOUBLE DEFAULT 3000.0, "
				+ "medical_allowance DOUBLE DEFAULT 2000.0, "
				+ "bonus DOUBLE DEFAULT 0.0, "
				+ "other_allowances DOUBLE DEFAULT 0.0, "
				+ "pf DOUBLE DEFAULT 3600.0, "
				+ "professional_tax DOUBLE DEFAULT 200.0, "
				+ "loan_deduction DOUBLE DEFAULT 0.0, "
				+ "advance_salary DOUBLE DEFAULT 0.0, "
				+ "other_deductions DOUBLE DEFAULT 500.0, "
				+ "effective_from DATE NULL, "
				+ "status VARCHAR(20) DEFAULT 'ACTIVE'"
				+ ")";
		try (Connection conn = DbUtil.getConnection();
			 Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(sql);
			try { stmt.executeUpdate("ALTER TABLE salary_structure ADD COLUMN bonus DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
			try { stmt.executeUpdate("ALTER TABLE salary_structure ADD COLUMN advance_salary DOUBLE DEFAULT 0.0"); } catch (Exception ignored) {}
		} catch (Exception e) {
			System.err.println("Error creating salary_structure table: " + e.getMessage());
		}
	}

	@Override
	public boolean saveSalaryStructure(SalaryStructure salaryStructure) {
		SalaryStructure existing = getSalaryStructureByEmployeeId(salaryStructure.getEmployeeId());
		if (existing != null) {
			salaryStructure.setId(existing.getId());
			return updateSalaryStructure(salaryStructure);
		}

		String sql = "INSERT INTO salary_structure (employee_id, basic_salary, hra, transport_allowance, "
				+ "medical_allowance, bonus, other_allowances, pf, professional_tax, loan_deduction, advance_salary, other_deductions, effective_from, status) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

			ps.setInt(1, salaryStructure.getEmployeeId());
			ps.setDouble(2, salaryStructure.getBasicSalary());
			ps.setDouble(3, salaryStructure.getHra());
			ps.setDouble(4, salaryStructure.getTransportAllowance());
			ps.setDouble(5, salaryStructure.getMedicalAllowance());
			ps.setDouble(6, salaryStructure.getBonus());
			ps.setDouble(7, salaryStructure.getOtherAllowances());
			ps.setDouble(8, salaryStructure.getPf());
			ps.setDouble(9, salaryStructure.getProfessionalTax());
			ps.setDouble(10, salaryStructure.getLoanDeduction());
			ps.setDouble(11, salaryStructure.getAdvanceSalary());
			ps.setDouble(12, salaryStructure.getOtherDeductions());
			ps.setDate(13, salaryStructure.getEffectiveFrom() != null ? salaryStructure.getEffectiveFrom() : new java.sql.Date(System.currentTimeMillis()));
			ps.setString(14, salaryStructure.getStatus() != null ? salaryStructure.getStatus() : "ACTIVE");

			int affected = ps.executeUpdate();
			if (affected > 0) {
				try (ResultSet rs = ps.getGeneratedKeys()) {
					if (rs.next()) {
						salaryStructure.setId(rs.getInt(1));
					}
				}
				return true;
			}
		} catch (Exception e) {
			System.err.println("Error saving salary structure: " + e.getMessage());
		}
		return false;
	}

	@Override
	public boolean updateSalaryStructure(SalaryStructure salaryStructure) {
		String sql = "UPDATE salary_structure SET basic_salary=?, hra=?, transport_allowance=?, "
				+ "medical_allowance=?, bonus=?, other_allowances=?, pf=?, professional_tax=?, loan_deduction=?, "
				+ "advance_salary=?, other_deductions=?, effective_from=?, status=? WHERE employee_id=?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {

			ps.setDouble(1, salaryStructure.getBasicSalary());
			ps.setDouble(2, salaryStructure.getHra());
			ps.setDouble(3, salaryStructure.getTransportAllowance());
			ps.setDouble(4, salaryStructure.getMedicalAllowance());
			ps.setDouble(5, salaryStructure.getBonus());
			ps.setDouble(6, salaryStructure.getOtherAllowances());
			ps.setDouble(7, salaryStructure.getPf());
			ps.setDouble(8, salaryStructure.getProfessionalTax());
			ps.setDouble(9, salaryStructure.getLoanDeduction());
			ps.setDouble(10, salaryStructure.getAdvanceSalary());
			ps.setDouble(11, salaryStructure.getOtherDeductions());
			ps.setDate(12, salaryStructure.getEffectiveFrom() != null ? salaryStructure.getEffectiveFrom() : new java.sql.Date(System.currentTimeMillis()));
			ps.setString(13, salaryStructure.getStatus() != null ? salaryStructure.getStatus() : "ACTIVE");
			ps.setInt(14, salaryStructure.getEmployeeId());

			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			System.err.println("Error updating salary structure: " + e.getMessage());
		}
		return false;
	}

	@Override
	public SalaryStructure getSalaryStructureByEmployeeId(int employeeId) {
		String sql = "SELECT * FROM salary_structure WHERE employee_id = ?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, employeeId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return extractSalaryStructure(rs);
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting salary structure by employeeId: " + e.getMessage());
		}
		return null;
	}

	@Override
	public SalaryStructure getSalaryStructureById(int id) {
		String sql = "SELECT * FROM salary_structure WHERE id = ?";
		try (Connection conn = DbUtil.getConnection();
			 PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, id);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return extractSalaryStructure(rs);
				}
			}
		} catch (Exception e) {
			System.err.println("Error getting salary structure by id: " + e.getMessage());
		}
		return null;
	}

	@Override
	public List<SalaryStructure> getAllActiveSalaryStructures() {
		List<SalaryStructure> list = new ArrayList<>();
		String sql = "SELECT * FROM salary_structure WHERE status = 'ACTIVE'";
		try (Connection conn = DbUtil.getConnection();
			 Statement stmt = conn.createStatement();
			 ResultSet rs = stmt.executeQuery(sql)) {
			while (rs.next()) {
				list.add(extractSalaryStructure(rs));
			}
		} catch (Exception e) {
			System.err.println("Error getting active salary structures: " + e.getMessage());
		}
		return list;
	}

	private SalaryStructure extractSalaryStructure(ResultSet rs) throws SQLException {
		SalaryStructure ss = new SalaryStructure();
		try { ss.setId(rs.getInt("id")); } catch (Exception e) { try { ss.setId(rs.getInt("salary_structure_id")); } catch (Exception ignored) {} }
		ss.setEmployeeId(rs.getInt("employee_id"));
		ss.setBasicSalary(rs.getDouble("basic_salary"));
		ss.setHra(rs.getDouble("hra"));
		ss.setTransportAllowance(rs.getDouble("transport_allowance"));
		ss.setMedicalAllowance(rs.getDouble("medical_allowance"));
		try { ss.setBonus(rs.getDouble("bonus")); } catch (Exception ignored) {}
		ss.setOtherAllowances(rs.getDouble("other_allowances"));
		ss.setPf(rs.getDouble("pf"));
		ss.setProfessionalTax(rs.getDouble("professional_tax"));
		ss.setLoanDeduction(rs.getDouble("loan_deduction"));
		try { ss.setAdvanceSalary(rs.getDouble("advance_salary")); } catch (Exception ignored) {}
		ss.setOtherDeductions(rs.getDouble("other_deductions"));
		ss.setEffectiveFrom(rs.getDate("effective_from"));
		ss.setStatus(rs.getString("status"));
		return ss;
	}
}
