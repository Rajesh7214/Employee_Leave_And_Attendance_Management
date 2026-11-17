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

@WebServlet(urlPatterns = {"/deleteTaskServlet", "/deleteTask"})
public class DeleteTaskServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;
	private EmployeeDao employeeDao;
	private NotificationService notificationService;

	@Override
	public void init() throws ServletException {
		taskDao = new TaskDaoImpl();
		employeeDao = new EmployeeDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		String role = session != null ? (String) session.getAttribute("role") : null;
		if (session == null || !("admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role))) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		String taskId = request.getParameter("taskId");

		if (taskId != null && !taskId.isEmpty()) {
			Task task = taskDao.getTaskById(taskId);
			if (task != null && task.getEmployeeId() > 0) {
				try {
					HttpSession session1 = request.getSession(false);
					Employee currentEmp = session1 != null ? (Employee) session1.getAttribute("employee") : null;
					int senderId = currentEmp != null ? currentEmp.getEmployee_id() : 1;
					String senderName = currentEmp != null ? currentEmp.getEmployee_name() : "Manager";

					Employee assignedEmp = employeeDao.getEmployeeById(task.getEmployeeId());
					if (assignedEmp != null) {
						notificationService.notifyTaskDeleted(task, senderId, senderName, assignedEmp);
					}
				} catch (Exception e) {
					System.err.println("[DeleteTaskServlet] Error dispatching delete notification: " + e.getMessage());
				}
			}
			taskDao.deleteTask(taskId);
		}

		response.sendRedirect("viewTasksServlet");
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}