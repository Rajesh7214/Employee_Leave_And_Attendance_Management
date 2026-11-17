<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
String taskId = request.getParameter("taskId");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Update Task Status</title>

<style>
body {
	font-family: Arial;
	background: #f4f4f4;
}

.container {
	width: 450px;
	margin: 80px auto;
	background: white;
	padding: 30px;
	border-radius: 10px;
	box-shadow: 0 0 10px gray;
}

h2 {
	text-align: center;
	color: #d63384;
}

label {
	font-weight: bold;
}

input, select {
	width: 100%;
	padding: 10px;
	margin-top: 8px;
	margin-bottom: 20px;
}

button {
	width: 100%;
	padding: 12px;
	background: #d63384;
	color: white;
	border: none;
	cursor: pointer;
	font-size: 16px;
}

button:hover {
	background: #b52b69;
}
</style>

</head>

<body>

	<div class="container">

		<h2>Update Task Status</h2>

		<form action="updateTaskStatus" method="get">

			<label>Task ID</label> <input type="text" name="taskId"
				value="<%=taskId%>" readonly> <label>Status</label> <select
				name="status">

				<option value="PENDING">Pending</option>

				<option value="IN_PROGRESS">In Progress</option>

				<option value="COMPLETED">Completed</option>

			</select>

			<button type="submit">Update Status</button>

		</form>

	</div>

</body>
</html>