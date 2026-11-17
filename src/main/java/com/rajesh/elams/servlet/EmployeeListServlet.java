package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/employeeListServlet", "/employeeList"})
public class EmployeeListServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;

	@Override
	public void init() throws ServletException {
		employeeDao = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		List<Employee> employeeList = employeeDao.getAllEmployees();

		request.setAttribute("employeeList", employeeList);
		request.setAttribute("employees", employeeList);

		request.getRequestDispatcher("employees.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		doGet(request, response);
	}
}
