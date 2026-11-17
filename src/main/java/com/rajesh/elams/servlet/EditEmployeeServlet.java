package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.model.Employee;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/editEmployee")
public class EditEmployeeServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private EmployeeDao employeeDao;

	@Override
	public void init() throws ServletException {
		employeeDao = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String idParam = request.getParameter("id");

		if (idParam == null || idParam.trim().isEmpty()) {
			response.sendRedirect("employeeListServlet");
			return;
		}

		int id;
		try {
			id = Integer.parseInt(idParam.trim());
		} catch (NumberFormatException e) {
			response.sendRedirect("employeeListServlet");
			return;
		}

		Employee employee = employeeDao.getEmployeeById(id);

		if (employee == null) {
			response.sendRedirect("employeeListServlet");
			return;
		}

		request.setAttribute("employee", employee);

		request.getRequestDispatcher("editEmployee.jsp").forward(request, response);
	}
}