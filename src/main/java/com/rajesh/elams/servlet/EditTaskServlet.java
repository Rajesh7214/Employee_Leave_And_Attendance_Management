package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/editTaskServlet", "/editTask"})
public class EditTaskServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		jakarta.servlet.http.HttpSession session = request.getSession(false);
		String role = session != null ? (String) session.getAttribute("role") : null;
		if (session == null || !("admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		String taskId = request.getParameter("taskId");

		if (taskId == null || taskId.trim().isEmpty()) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		Task task = taskDao.getTaskById(taskId);

		if (task == null) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		request.setAttribute("task", task);

		request.getRequestDispatcher("editTask.jsp").forward(request, response);
	}
}