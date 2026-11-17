package com.rajesh.elams.servlet;

import java.io.IOException;
import java.sql.Date;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Priority;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/updateTask", "/updateTaskServlet"})
public class UpdateTaskServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao dao;
	private EmployeeDao employeeDao;
	private NotificationService notificationService;

	@Override
	public void init() throws ServletException {
		dao = new TaskDaoImpl();
		employeeDao = new EmployeeDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String role = session != null ? (String) session.getAttribute("role") : null;
		if (session == null || role == null || (!"admin".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role))) {
			response.sendRedirect(request.getContextPath() + "/viewTasksServlet");
			return;
		}

		String taskId = request.getParameter("taskId");
		if (taskId == null || taskId.isBlank()) {
			taskId = request.getParameter("id");
		}

		if (taskId == null || taskId.isBlank()) {
			response.sendRedirect(request.getContextPath() + "/viewTasksServlet");
			return;
		}

		taskId = taskId.trim();
		Task task = dao.getTaskById(taskId);

		if (task == null) {
			session.setAttribute("flashError", "Task not found.");
			response.sendRedirect(request.getContextPath() + "/viewTasksServlet");
			return;
		}

		String taskName = request.getParameter("taskName");
		String description = request.getParameter("description");
		String priorityStr = request.getParameter("priority");
		String dueDateStr = request.getParameter("dueDate");

		if (taskName != null) task.setTaskName(taskName);
		if (description != null) task.setDescription(description);

		try {
			if (priorityStr != null && !priorityStr.isBlank()) {
				task.setPriority(Priority.valueOf(priorityStr.trim().toUpperCase()));
			}
			if (dueDateStr != null && !dueDateStr.isBlank()) {
				task.setDueDate(Date.valueOf(dueDateStr.trim()));
			}
		} catch (Exception e) {
			request.setAttribute("errorMessage", "Please enter a valid priority and due date.");
			request.setAttribute("task", task);
			request.getRequestDispatcher("editTask.jsp").forward(request, response);
			return;
		}

		boolean result = dao.updateTask(task);

		if (result) {
			session.setAttribute("flashSuccess", "Task updated successfully.");
			if (task.getEmployeeId() > 0) {
				try {
					Employee currentEmp = (Employee) session.getAttribute("employee");
					int senderId = currentEmp != null ? currentEmp.getEmployee_id() : 1;
					String senderName = currentEmp != null && currentEmp.getEmployee_name() != null
							? currentEmp.getEmployee_name()
							: ("admin".equalsIgnoreCase(role) ? "System Admin" : "Manager");

					Employee assignedEmp = employeeDao.getEmployeeById(task.getEmployeeId());
					if (assignedEmp != null) {
						notificationService.notifyTaskUpdated(task, senderId, senderName, assignedEmp);
					}
				} catch (Exception e) {
					System.err.println("[UpdateTaskServlet] Error dispatching update notification: " + e.getMessage());
				}
			}
			response.sendRedirect(request.getContextPath() + "/viewTasksServlet");
		} else {
			request.setAttribute("errorMessage", "We couldn't save your changes right now (database error).");
			request.setAttribute("task", task);
			request.getRequestDispatcher("editTask.jsp").forward(request, response);
		}
	}
}