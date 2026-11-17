<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="com.rajesh.elams.model.Task"%>

<%
List<Task> taskList = (List<Task>) request.getAttribute("taskList");
String role = (String) session.getAttribute("role");
boolean canManage = "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Task Management</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<style>
body {
	font-family: Arial, Helvetica, sans-serif;
	background: #f4f6f9;
	margin: 0;
	padding: 0;
}

.container {
	width: 95%;
	margin: 30px auto;
}

h2 {
	text-align: center;
	color: #d6336c;
}

.top-bar {
	text-align: right;
	margin-bottom: 20px;
}

.add-btn {
	background: #28a745;
	color: white;
	text-decoration: none;
	padding: 10px 15px;
	border-radius: 5px;
}

.add-btn:hover {
	background: #218838;
}

table {
	width: 100%;
	border-collapse: collapse;
	background: white;
	box-shadow: 0 0 10px rgba(0, 0, 0, .2);
}

th {
	background: #d6336c;
	color: white;
	padding: 12px;
}

td {
	padding: 10px;
	text-align: center;
	border-bottom: 1px solid #ddd;
}

tr:hover {
	background: #f8f8f8;
}

.btn {
	color: white;
	text-decoration: none;
	padding: 6px 12px;
	border-radius: 5px;
}

.edit {
	background: #3498db;
}

.delete {
	background: #e74c3c;
}

.back {
	margin-top: 20px;
	text-align: center;
}

.back a {
	color: #d6336c;
	text-decoration: none;
	font-weight: bold;
}
</style>

</head>

<body>

	<div class="container">

		<h2>Task Management</h2>

		<% if (canManage) { %>
		<div class="top-bar">
			<a href="createTask" class="add-btn">+ Create New Task</a>
		</div>
		<% } %>

		<table>

			<tr>
				<th>Task ID</th>
				<th>Task Name</th>
				<th>Description</th>
				<th>Employee ID</th>
				<th>Assigned By</th>
				<th>Priority</th>
				<th>Status</th>
				<th>Assigned Date</th>
				<th>Due Date</th>
				<th>Completion Date</th>
				<th>Edit</th>
				<th>Delete</th>
			</tr>

			<%
			if (taskList != null && !taskList.isEmpty()) {

				for (Task task : taskList) {
			%>

			<tr>

				<td><%=task.getTaskId()%></td>

				<td><%=task.getTaskName()%></td>

				<td><%=task.getDescription()%></td>

				<td><%=task.getEmployeeId()%></td>

				<td><%=task.getAssignedBy()%></td>

				<td><%=task.getPriority().name()%></td>

				<td><%=task.getStatus().name()%></td>

				<td><%=task.getAssignedDate()%></td>

				<td><%=task.getDueDate()%></td>

				<td><%=task.getCompletionDate() == null ? "-" : task.getCompletionDate()%>
				</td>

				<td>
					<% if (canManage) { %>
					<a class="btn edit" href="editTaskServlet?taskId=<%=task.getTaskId()%>"> Edit </a>
					<% } else { %>
					-
					<% } %>
				</td>

				<td>
					<% if (canManage) { %>
					<a class="btn delete" href="deleteTask?taskId=<%=task.getTaskId()%>" onclick="return confirm('Are you sure you want to delete this task?');"> Delete </a>
					<% } else { %>
					-
					<% } %>
				</td>

			</tr>

			<%
			}

			} else {
			%>

			<tr>
				<td colspan="12">No Tasks Found</td>
			</tr>

			<%
			}
			%>

		</table>

		<!-- Download Report Button (Bottom) -->
		<div style="margin-top: 25px; margin-bottom: 20px; text-align: center; padding: 20px; background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.06);">
			<a href="exportTaskReport" style="background:#0284c7; color:white; padding:14px 28px; border-radius:12px; font-weight:bold; text-decoration:none; display:inline-flex; align-items:center; gap:10px; font-size:15px; box-shadow: 0 4px 14px rgba(2,132,199,0.3); transition: transform 0.15s ease;">
				<i class="fa-solid fa-file-csv" style="font-size:20px;"></i> Download CSV Task Report
			</a>
		</div>

		<div class="back">
			<br> <a href="adminDashboardServlet">← Back to Dashboard</a>
		</div>

	</div>

</body>
</html>