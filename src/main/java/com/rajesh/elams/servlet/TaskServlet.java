package com.rajesh.elams.servlet;

import java.io.IOException;
import java.util.List;

import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/task", "/tasks"})
public class TaskServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getParameter("action");

		try {

			if ("status".equals(action)) {

				String taskId = request.getParameter("taskId");
				String status = request.getParameter("status");

				taskDao.updateTaskStatus(taskId, status);

				response.sendRedirect("task");
				return;
			}

			response.sendRedirect("viewTasksServlet");
			return;

		} catch (Exception e) {

			e.printStackTrace();
			throw new ServletException(e);

		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		doGet(request, response);

	}

}