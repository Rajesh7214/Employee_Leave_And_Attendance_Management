package com.rajesh.elams.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/exportTaskReport")
public class ExportTaskReportServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private TaskDao taskDao;

	@Override
	public void init() {
		taskDao = new TaskDaoImpl();
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpSession session = request.getSession(false);
		if (session == null || session.getAttribute("loggedUser") == null) {
			response.sendRedirect("login.jsp");
			return;
		}

		List<Task> tasks = taskDao.getAllTasks();

		response.setContentType("text/csv");
		response.setHeader("Content-Disposition", "attachment; filename=\"Task_Report_" + LocalDate.now() + ".csv\"");

		try (PrintWriter writer = response.getWriter()) {
			writer.println("Task ID,Task Name,Description,Assigned Employee ID,Assigned By,Priority,Status,Assigned Date,Due Date,Completion Date");

			if (tasks != null) {
				for (Task t : tasks) {
					String priorityStr = t.getPriority() != null ? t.getPriority().name() : "";
					String statusStr = t.getStatus() != null ? t.getStatus().name() : "";

					writer.printf("\"%s\",\"%s\",\"%s\",%d,\"%s\",\"%s\",\"%s\",%s,%s,%s\n",
							escapeCsv(t.getTaskId()),
							escapeCsv(t.getTaskName()),
							escapeCsv(t.getDescription()),
							t.getEmployeeId(),
							escapeCsv(t.getAssignedBy()),
							escapeCsv(priorityStr),
							escapeCsv(statusStr),
							t.getAssignedDate() != null ? t.getAssignedDate().toString() : "",
							t.getDueDate() != null ? t.getDueDate().toString() : "",
							t.getCompletionDate() != null ? t.getCompletionDate().toString() : ""
					);
				}
			}
			writer.flush();
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

	private String escapeCsv(String input) {
		if (input == null) return "";
		return input.replace("\"", "\"\"");
	}
}
