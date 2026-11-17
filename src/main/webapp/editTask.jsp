<%@page import="com.rajesh.elams.model.Task"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
Task task = (Task) request.getAttribute("task");
if (task == null) {
	response.sendRedirect("viewTasksServlet");
	return;
}
String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Task | ELAMS</title>

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
	background: #f4f6f9;
	min-height: 100vh;
}

.navbar {
	height: 70px;
	background: linear-gradient(135deg, #ee5a8a 0%, #d6336c 100%);
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 4px 15px rgba(214, 51, 108, .25);
}

.navbar h1 {
	color: white;
	font-size: 22px;
}

.container {
	width: 92%;
	max-width: 600px;
	margin: 45px auto;
}

.task-info-card {
	background: #fdf2f6;
	border-left: 4px solid #d6336c;
	padding: 14px 18px;
	border-radius: 6px;
	margin-bottom: 22px;
	font-size: 13px;
	color: #2c3e50;
}

.task-info-card strong {
	color: #d6336c;
}

.form-container {
	background: white;
	border-radius: 14px;
	padding: 35px;
	box-shadow: 0 8px 25px rgba(0, 0, 0, .08);
}

.alert {
	padding: 12px 16px;
	border-radius: 8px;
	margin-bottom: 20px;
	font-size: 14px;
	font-weight: 500;
	background: #fdecef;
	color: #c0335c;
	border-left: 4px solid #ea4c79;
}

.form-group {
	margin-bottom: 20px;
}

.form-group label {
	display: block;
	font-weight: 600;
	color: #2c3e50;
	margin-bottom: 8px;
	font-size: 14px;
}

.form-group input, .form-group textarea, .form-group select {
	width: 100%;
	padding: 12px 14px;
	border: 1px solid #e0dde3;
	border-radius: 8px;
	font-size: 14px;
	font-family: inherit;
	background: #fbf7f9;
	transition: all .25s ease;
}

.form-group textarea {
	height: 90px;
	resize: vertical;
}

.form-group input:focus, .form-group textarea:focus, .form-group select:focus
	{
	outline: none;
	border-color: #d6336c;
	background: white;
	box-shadow: 0 0 0 3px rgba(214, 51, 108, .12);
}

.btn-update {
	width: 100%;
	margin-top: 10px;
	padding: 14px;
	background: linear-gradient(135deg, #ee5a8a, #d6336c);
	color: white;
	border: none;
	font-size: 16px;
	font-weight: bold;
	border-radius: 30px;
	cursor: pointer;
	transition: all .3s;
	box-shadow: 0 8px 20px rgba(214, 51, 108, .3);
}

.btn-update:hover {
	transform: translateY(-2px);
	box-shadow: 0 10px 25px rgba(214, 51, 108, .4);
}

.back {
	text-align: center;
	margin-top: 22px;
}

.back a {
	text-decoration: none;
	color: #d6336c;
	font-weight: 600;
	font-size: 14px;
}

.back a:hover {
	text-decoration: underline;
}

@media ( max-width : 600px) {
	.container {
		margin: 25px auto;
	}
	.form-container {
		padding: 22px;
	}
}
</style>

</head>
<body>

	<div class="navbar">
		<h1>ELAMS - Edit Task</h1>
	</div>

	<div class="container">

		<div class="task-info-card">
			<strong>Task ID:</strong>
			<%=task.getTaskId()%>
			&nbsp;&nbsp;&nbsp; <strong>Assigned To (Employee ID):</strong>
			<%=task.getEmployeeId()%>
		</div>

		<div class="form-container">

			<%
			if (errorMessage != null) {
			%>
			<div class="alert"><%=errorMessage%></div>
			<%
			}
			%>

			<form action="updateTask" method="post">

				<input type="hidden" name="taskId" value="<%=task.getTaskId()%>">

				<div class="form-group">
					<label for="taskName">Task Name</label> <input type="text"
						id="taskName" name="taskName" value="<%=task.getTaskName()%>"
						required>
				</div>

				<div class="form-group">
					<label for="description">Description</label>
					<textarea id="description" name="description" required><%=task.getDescription() == null ? "" : task.getDescription()%></textarea>
				</div>

				<div class="form-group">
					<label for="priority">Priority</label> <select id="priority"
						name="priority" required>
						<option value="HIGH"
							<%="HIGH".equalsIgnoreCase(String.valueOf(task.getPriority())) ? "selected" : ""%>>HIGH</option>
						<option value="MEDIUM"
							<%="MEDIUM".equalsIgnoreCase(String.valueOf(task.getPriority())) ? "selected" : ""%>>MEDIUM</option>
						<option value="LOW"
							<%="LOW".equalsIgnoreCase(String.valueOf(task.getPriority())) ? "selected" : ""%>>LOW</option>
					</select>
				</div>

				<div class="form-group">
					<label for="dueDate">Due Date</label> <input type="date"
						id="dueDate" name="dueDate"
						value="<%=task.getDueDate() != null ? task.getDueDate().toString() : ""%>"
						required>
				</div>

				<button type="submit" class="btn-update">Update Task</button>

			</form>

		</div>

		<div class="back">
			<a href="viewTasksServlet">← Back to Tasks</a>
		</div>

	</div>

</body>
</html>
