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
import com.rajesh.elams.model.TaskStatus;
import com.rajesh.elams.model.User;
import com.rajesh.elams.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/createTask")
public class CreateTaskServlet extends HttpServlet {

	private TaskDao taskDAO;
	private EmployeeDao employeeDAO;
	private NotificationService notificationService;

	@Override
	public void init() {
		taskDAO = new TaskDaoImpl();
		employeeDAO = new EmployeeDaoImpl();
		notificationService = new NotificationService();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (!isAdminOrManager(session)) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		request.setAttribute("employees", employeeDAO.getAllEmployees());

		request.getRequestDispatcher("createTask.jsp").forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);

		if (!isAdminOrManager(session)) {
			response.sendRedirect("viewTasksServlet");
			return;
		}

		String assignmentType = request.getParameter("assignmentType");
		if (assignmentType == null || assignmentType.isBlank()) {
			assignmentType = "INDIVIDUAL";
		}

		String taskName = request.getParameter("taskName");
		String description = request.getParameter("description");
		String priorityStr = request.getParameter("priority");
		String dueDateStr = request.getParameter("dueDate");
		String customTaskId = request.getParameter("taskId");

		Priority priority = Priority.valueOf(priorityStr != null ? priorityStr : "MEDIUM");
		Date dueDate = Date.valueOf(dueDateStr);
		Date assignedDate = new Date(System.currentTimeMillis());

		User loggedUser = (User) session.getAttribute("loggedUser");
		String assignedBy = loggedUser != null ? loggedUser.getEmail() : "Manager";

		int senderId = 1;
		String senderName = assignedBy;
		Employee loggedEmp = (Employee) session.getAttribute("employee");
		if (loggedEmp != null) {
			if (loggedEmp.getEmployee_id() > 0) {
				senderId = loggedEmp.getEmployee_id();
			}
			if (loggedEmp.getEmployee_name() != null && !loggedEmp.getEmployee_name().isBlank()) {
				senderName = loggedEmp.getEmployee_name();
			}
		}

		java.util.List<Integer> targetEmployeeIds = new java.util.ArrayList<>();

		if ("GROUP".equalsIgnoreCase(assignmentType)) {
			String[] empIdArray = request.getParameterValues("employeeIds");
			if (empIdArray != null) {
				for (String idStr : empIdArray) {
					try {
						targetEmployeeIds.add(Integer.parseInt(idStr));
					} catch (Exception ignored) {}
				}
			}
		} else if ("DEPARTMENT".equalsIgnoreCase(assignmentType)) {
			String targetDept = request.getParameter("departmentGroup");
			java.util.List<Employee> allEmps = employeeDAO.getAllEmployees();
			if (allEmps != null) {
				for (Employee e : allEmps) {
					if ("ALL".equalsIgnoreCase(targetDept) || (e.getDepartment() != null && e.getDepartment().equalsIgnoreCase(targetDept))) {
						targetEmployeeIds.add(e.getEmployee_id());
					}
				}
			}
		} else {
			// INDIVIDUAL
			String empIdStr = request.getParameter("employeeId");
			if (empIdStr != null && !empIdStr.isBlank()) {
				try {
					targetEmployeeIds.add(Integer.parseInt(empIdStr));
				} catch (Exception ignored) {}
			}
		}

		if (targetEmployeeIds.isEmpty()) {
			session.setAttribute("errorMessage", "Please select at least one employee or department for task assignment.");
			response.sendRedirect("createTask");
			return;
		}

		int countCreated = 0;
		long baseTimestamp = System.currentTimeMillis();

		for (int idx = 0; idx < targetEmployeeIds.size(); idx++) {
			int empId = targetEmployeeIds.get(idx);
			Task task = new Task();

			if (customTaskId != null && !customTaskId.trim().isEmpty()) {
				task.setTaskId(targetEmployeeIds.size() == 1 ? customTaskId.trim() : customTaskId.trim() + "-" + (idx + 1));
			} else {
				task.setTaskId("TSK-" + baseTimestamp + (targetEmployeeIds.size() == 1 ? "" : "-" + (idx + 1)));
			}

			task.setTaskName(taskName);
			task.setDescription(description);
			task.setEmployeeId(empId);
			task.setPriority(priority);
			task.setDueDate(dueDate);
			task.setStatus(TaskStatus.PENDING);
			task.setAssignedDate(assignedDate);
			task.setCompletionDate(null);
			task.setAssignedBy(assignedBy);

			taskDAO.createTask(task);
			countCreated++;

			try {
				Employee assignedEmp = employeeDAO.getEmployeeById(empId);
				if (assignedEmp != null) {
					notificationService.notifyTaskAssignment(task, senderId, senderName, assignedEmp);
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		if (countCreated > 1) {
			session.setAttribute("successMessage", "Group Task Assigned to " + countCreated + " Employees Successfully!");
		} else {
			session.setAttribute("successMessage", "Task Created and Assigned Successfully!");
		}

		com.rajesh.elams.service.AuditService.logAction(assignedBy, "CREATE_TASK", "Tasks", "TSK-" + baseTimestamp, "Created task: " + taskName + " (Count: " + countCreated + ")", request.getRemoteAddr());

		response.sendRedirect("viewTasksServlet");
	}

	private boolean isAdminOrManager(HttpSession session) {
		if (session == null) return false;
		String role = (String) session.getAttribute("role");
		return "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);
	}
}
