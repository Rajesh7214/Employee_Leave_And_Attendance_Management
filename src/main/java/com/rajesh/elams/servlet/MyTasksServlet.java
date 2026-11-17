package com.rajesh.elams.servlet;


import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/myTasks")
public class MyTasksServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		Employee employee = (Employee) session.getAttribute("employee");

		if (employee == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		List<Task> taskList = taskDao.getTasksByEmployee(employee.getEmployee_id());

		request.setAttribute("taskList", taskList);

		request.getRequestDispatcher("myTasks.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}