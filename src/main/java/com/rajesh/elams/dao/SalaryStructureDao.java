package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.SalaryStructure;

public interface SalaryStructureDao {
	boolean saveSalaryStructure(SalaryStructure salaryStructure);

	boolean updateSalaryStructure(SalaryStructure salaryStructure);

	SalaryStructure getSalaryStructureByEmployeeId(int employeeId);

	SalaryStructure getSalaryStructureById(int id);

	List<SalaryStructure> getAllActiveSalaryStructures();
}
