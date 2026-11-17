package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/viewTasksServlet", "/viewTasks"})
public class ViewTasksServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;
	private EmployeeDao employeeDao;

	@Override
	public void init() {
		taskDao = new TaskDaoImpl();
		employeeDao = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String searchTaskId = request.getParameter("searchTaskId");
		String searchEmpId = request.getParameter("searchEmpId");
		String searchStatus = request.getParameter("searchStatus");
		String searchPriority = request.getParameter("searchPriority");

		List<Task> taskList;
		if ((searchTaskId != null && !searchTaskId.isBlank()) ||
			(searchEmpId != null && !searchEmpId.isBlank()) ||
			(searchStatus != null && !searchStatus.isBlank()) ||
			(searchPriority != null && !searchPriority.isBlank())) {
			taskList = taskDao.searchTasks(searchTaskId, searchEmpId, searchStatus, searchPriority);
		} else {
			taskList = taskDao.getAllTasks();
		}

		request.setAttribute("taskList", taskList);
		request.setAttribute("employees", employeeDao.getAllEmployees());
		request.setAttribute("searchTaskId", searchTaskId);
		request.setAttribute("searchEmpId", searchEmpId);
		request.setAttribute("searchStatus", searchStatus);
		request.setAttribute("searchPriority", searchPriority);

		request.getRequestDispatcher("viewTasks.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}