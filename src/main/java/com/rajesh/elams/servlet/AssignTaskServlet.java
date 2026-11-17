package com.rajesh.elams.servlet;

import java.io.IOException;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/assignTask")
public class AssignTaskServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TaskDao taskDao;
	private EmployeeDao empDao;
	private NotificationService notificationService;

	@Override
	public void init() {
		taskDao = new TaskDaoImpl();
		empDao = new EmployeeDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String role = session != null ? (String) session.getAttribute("role") : null;
		if (session == null || !("admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		String taskId = request.getParameter("taskId");
		String employeeIdStr = request.getParameter("employeeId");

		if (taskId != null && employeeIdStr != null) {
			try {
				int employeeId = Integer.parseInt(employeeIdStr);
				boolean success = taskDao.assignTask(taskId, employeeId);
				if (success) {
					Task task = taskDao.getTaskById(taskId);
					if (task != null) {
						Employee currentEmp = (Employee) session.getAttribute("employee");
						int senderId = currentEmp != null ? currentEmp.getEmployee_id() : 1;
						String senderName = currentEmp != null ? currentEmp.getEmployee_name() : "Manager";

						Employee assignedEmp = empDao.getEmployeeById(employeeId);
						if (assignedEmp != null) {
							notificationService.notifyTaskAssignment(task, senderId, senderName, assignedEmp);
						}
					}
					session.setAttribute("successMessage", "Task Assigned Successfully");
				} else {
					session.setAttribute("errorMessage", "Failed to assign task.");
				}
			} catch (Exception e) {
				session.setAttribute("errorMessage", "Invalid Employee ID format.");
			}
		}

		response.sendRedirect("viewTasksServlet");
	}
}