package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
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

@WebServlet(urlPatterns = {"/updateTaskStatus", "/updateTaskStatusServlet"})
public class UpdateTaskStatusServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;
	private EmployeeDao employeeDao;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
		employeeDao = new EmployeeDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		handleStatusUpdate(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		handleStatusUpdate(request, response);
	}

	private void handleStatusUpdate(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (session == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		String taskId = request.getParameter("taskId");
		String status = request.getParameter("status");

		if (taskId == null || taskId.isBlank()) {
			session.setAttribute("errorMessage", "Invalid task identifier.");
			redirectUser(request, response, session);
			return;
		}

		taskId = taskId.trim();

		String normStatus = "PENDING";
		if (status != null && !status.isBlank()) {
			String s = status.trim().toUpperCase();
			if ("COMPLETED".equals(s) || "COMPLETE".equals(s) || "DONE".equals(s)) {
				normStatus = "COMPLETED";
			} else if ("IN_PROGRESS".equals(s) || "IN PROGRESS".equals(s) || "PROGRESS".equals(s) || "WORKING".equals(s)) {
				normStatus = "IN_PROGRESS";
			} else {
				normStatus = "PENDING";
			}
		}

		Task task = taskDao.getTaskById(taskId);
		if (task == null) {
			session.setAttribute("errorMessage", "Task not found.");
			redirectUser(request, response, session);
			return;
		}

		boolean isAjax = "json".equalsIgnoreCase(request.getParameter("format"))
				|| "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

		boolean ok = taskDao.updateTaskStatus(taskId, normStatus);

		if (ok) {
			String statusLabel = "COMPLETED".equals(normStatus) ? "Completed" : ("IN_PROGRESS".equals(normStatus) ? "In Progress" : "Pending");
			session.setAttribute("successMessage", "Task status updated to " + statusLabel + " successfully!");

			try {
				Employee loggedEmp = (Employee) session.getAttribute("employee");
				if (loggedEmp == null) {
					Object empIdObj = session.getAttribute("employeeId");
					if (empIdObj != null) {
						int empId = Integer.parseInt(empIdObj.toString());
						loggedEmp = employeeDao.getEmployeeById(empId);
					}
				}

				if (loggedEmp != null) {
					com.rajesh.elams.service.NotificationService notifService = new com.rajesh.elams.service.NotificationService();
					String empName = loggedEmp.getEmployee_name() != null ? loggedEmp.getEmployee_name() : "Employee";
					String title = "Task " + statusLabel + ": " + (task.getTaskName() != null ? task.getTaskName() : taskId);
					String msg = empName + " marked task \"" + (task.getTaskName() != null ? task.getTaskName() : taskId) + "\" as " + statusLabel + ".";
					com.rajesh.elams.model.Notification notif = new com.rajesh.elams.model.Notification(
							loggedEmp.getEmployee_id(),
							1L,
							title,
							msg,
							com.rajesh.elams.model.Notification.CAT_TASK,
							"COMPLETED".equals(normStatus) ? com.rajesh.elams.model.Notification.PRIORITY_MEDIUM : com.rajesh.elams.model.Notification.PRIORITY_LOW
					);
					notif.setSenderName(empName);
					notifService.createNotification(notif);
				}
			} catch (Exception ignored) {}
		} else {
			session.setAttribute("errorMessage", "Failed to update task status in database.");
		}

		if (isAjax) {
			response.setContentType("application/json");
			response.getWriter().print("{\"success\":" + ok + ",\"status\":\"" + normStatus + "\",\"taskId\":\"" + taskId + "\"}");
			return;
		}

		redirectUser(request, response, session);
	}

	private void redirectUser(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
		String redirect = request.getParameter("redirect");
		String referer = request.getHeader("Referer");

		if ("myTasks".equalsIgnoreCase(redirect) || (referer != null && referer.contains("myTasks"))) {
			response.sendRedirect("myTasks");
		} else if ("taskReport".equalsIgnoreCase(redirect) || (referer != null && referer.contains("taskReport"))) {
			response.sendRedirect("taskReportServlet");
		} else {
			response.sendRedirect("viewTasksServlet");
		}
	}
}