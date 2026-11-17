package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/taskReportServlet", "/taskReport"})
public class TaskReportServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setAttribute("totalTasks", taskDao.totalTasks());
		request.setAttribute("completedTasks", taskDao.completedTasks());
		request.setAttribute("pendingTasks", taskDao.pendingTasks());
		request.setAttribute("inProgressTasks", taskDao.inProgressTasks());
		request.setAttribute("overdueTasks", taskDao.overdueTasks());
		request.setAttribute("taskList", taskDao.getAllTasks());

		try {
			com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
			request.setAttribute("employeeList", empDao.getAllEmployees());
		} catch (Exception ignored) {}

		request.getRequestDispatcher("taskReport.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}