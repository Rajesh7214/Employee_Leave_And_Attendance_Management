package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.LeaveDao;
import com.rajesh.elams.dao.LeaveDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Leave;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/leaveRequests")
public class LeaveRequestsServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private LeaveDao leaveDAO;
	private EmployeeDao employeeDAO;

	@Override
	public void init() {
		leaveDAO = new LeaveDaoImpl();
		employeeDAO = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		List<Leave> pendingLeaves = leaveDAO.getPendingLeaves();
		List<Leave> approvedLeaves = leaveDAO.getApprovedLeaves();
		List<Leave> rejectedLeaves = leaveDAO.getRejectedLeaves();
		List<Leave> allLeaves = leaveDAO.getAllLeaves();

		Map<Integer, Employee> employeeMap = new HashMap<>();
		try {
			List<Employee> allEmployees = employeeDAO.getAllEmployees();
			if (allEmployees != null) {
				for (Employee emp : allEmployees) {
					employeeMap.put(emp.getEmployee_id(), emp);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		request.setAttribute("pendingLeaves", pendingLeaves);
		request.setAttribute("approvedLeaves", approvedLeaves);
		request.setAttribute("rejectedLeaves", rejectedLeaves);
		request.setAttribute("allLeaves", allLeaves);
		request.setAttribute("employeeMap", employeeMap);

		request.getRequestDispatcher("leaveRequests.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}