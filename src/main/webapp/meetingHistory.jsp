<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>

<%
List<Meeting> historyList = (List<Meeting>) request.getAttribute("historyList");
String search = (String) request.getAttribute("search");
String status = (String) request.getAttribute("status");
String meetingType = (String) request.getAttribute("meetingType");
String priority = (String) request.getAttribute("priority");
String date = (String) request.getAttribute("date");

String role = (String) session.getAttribute("role");
String dashboardUrl = "employeeDashboardServlet";
if ("admin".equalsIgnoreCase(role)) {
	dashboardUrl = "adminDashboardServlet";
} else if ("hr".equalsIgnoreCase(role)) {
	dashboardUrl = "hrDashboard";
} else if ("manager".equalsIgnoreCase(role)) {
	dashboardUrl = "managerDashboard";
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Meeting History & Archive | RChips Solutions ELAMS</title>
<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background: #f4f6f9;
	margin: 0;
	padding: 0;
}

.container {
	width: 95%;
	max-width: 1200px;
	margin: 30px auto;
}

h2 {
	color: #d6336c;
	margin-bottom: 25px;
	text-align: center;
}

.filter-box {
	background: white;
	padding: 20px;
	border-radius: 10px;
	box-shadow: 0 4px 12px rgba(0,0,0,0.06);
	margin-bottom: 25px;
}

.filter-form {
	display: flex;
	flex-wrap: wrap;
	gap: 15px;
	align-items: center;
}

.filter-form input, .filter-form select {
	padding: 10px 14px;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 14px;
}

.btn-filter, .btn-reset {
	padding: 10px 18px;
	border-radius: 6px;
	font-weight: bold;
	cursor: pointer;
	text-decoration: none;
	border: none;
	font-size: 14px;
}

.btn-filter { background: #d6336c; color: white; }
.btn-reset { background: #6c757d; color: white; }

table {
	width: 100%;
	border-collapse: collapse;
	background: white;
	border-radius: 10px;
	overflow: hidden;
	box-shadow: 0 4px 15px rgba(0,0,0,0.08);
}

th {
	background: #d6336c;
	color: white;
	padding: 12px;
	font-size: 14px;
}

td {
	padding: 12px;
	text-align: center;
	border-bottom: 1px solid #eee;
	font-size: 14px;
}

tr:hover { background: #f9f9f9; }

.badge {
	padding: 4px 10px;
	border-radius: 10px;
	font-weight: bold;
	font-size: 12px;
}

.badge-COMPLETED { background: #c8e6c9; color: #2e7d32; }
.badge-SCHEDULED { background: #bbdefb; color: #1565c0; }
.badge-CANCELLED { background: #ffcdd2; color: #c62828; }

.back-btn {
	display: inline-block;
	margin-top: 25px;
	color: #d6336c;
	text-decoration: none;
	font-weight: bold;
	padding: 10px 20px;
	background: white;
	border: 1px solid #ffc1d9;
	border-radius: 20px;
	transition: all 0.2s ease;
}
.back-btn:hover {
	background: #d6336c;
	color: white;
}
</style>
</head>
<body>

	<div class="container">

		<h2><i class="fa-solid fa-clock-rotate-left"></i> Meeting History & Records</h2>

		<!-- Filter Bar -->
		<div class="filter-box">
			<form action="meetingHistory" method="get" class="filter-form">
				<input type="text" name="search" placeholder="Search by title..." value="<%= search != null ? search : "" %>">
				<input type="date" name="date" value="<%= date != null ? date : "" %>">
				
				<select name="meetingType">
					<option value="">All Meeting Types</option>
					<option value="Team Meeting" <%= "Team Meeting".equals(meetingType) ? "selected" : "" %>>Team Meeting</option>
					<option value="Client Meeting" <%= "Client Meeting".equals(meetingType) ? "selected" : "" %>>Client Meeting</option>
					<option value="Department Meeting" <%= "Department Meeting".equals(meetingType) ? "selected" : "" %>>Department Meeting</option>
					<option value="HR Meeting" <%= "HR Meeting".equals(meetingType) ? "selected" : "" %>>HR Meeting</option>
					<option value="Project Discussion" <%= "Project Discussion".equals(meetingType) ? "selected" : "" %>>Project Discussion</option>
					<option value="Sprint Planning" <%= "Sprint Planning".equals(meetingType) ? "selected" : "" %>>Sprint Planning</option>
					<option value="Daily Standup" <%= "Daily Standup".equals(meetingType) ? "selected" : "" %>>Daily Standup</option>
					<option value="Review Meeting" <%= "Review Meeting".equals(meetingType) ? "selected" : "" %>>Review Meeting</option>
					<option value="Interview" <%= "Interview".equals(meetingType) ? "selected" : "" %>>Interview</option>
					<option value="Training Session" <%= "Training Session".equals(meetingType) ? "selected" : "" %>>Training Session</option>
				</select>

				<select name="status">
					<option value="">All Statuses</option>
					<option value="COMPLETED" <%= "COMPLETED".equals(status) ? "selected" : "" %>>Completed</option>
					<option value="SCHEDULED" <%= "SCHEDULED".equals(status) ? "selected" : "" %>>Scheduled</option>
					<option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>Cancelled</option>
				</select>

				<select name="priority">
					<option value="">All Priorities</option>
					<option value="High" <%= "High".equals(priority) ? "selected" : "" %>>High</option>
					<option value="Normal" <%= "Normal".equals(priority) ? "selected" : "" %>>Normal</option>
					<option value="Low" <%= "Low".equals(priority) ? "selected" : "" %>>Low</option>
				</select>

				<button type="submit" class="btn-filter"><i class="fa-solid fa-filter"></i> Filter</button>
				<a href="meetingHistory" class="btn-reset"><i class="fa-solid fa-rotate-left"></i> Reset</a>
			</form>
		</div>

		<table>
			<tr>
				<th>Meeting ID</th>
				<th>Title</th>
				<th>Type</th>
				<th>Mode</th>
				<th>Date</th>
				<th>Time</th>
				<th>Priority</th>
				<th>Status</th>
				<th>Attendance & Notes</th>
			</tr>
			<%
			if (historyList != null && !historyList.isEmpty()) {
				for (Meeting m : historyList) {
			%>
				<tr>
					<td>#<%=m.getMeetingId()%></td>
					<td><strong><%=m.getTitle()%></strong></td>
					<td><%=m.getMeetingType()%></td>
					<td><%=m.getMeetingMode()%></td>
					<td><%=m.getMeetingDate()%></td>
					<td><%=m.getStartTime()%> - <%=m.getEndTime()%></td>
					<td><%=m.getPriority()%></td>
					<td><span class="badge badge-<%=m.getStatus()%>"><%=m.getStatus()%></span></td>
					<td>
						<a href="meetingAttendance?meetingId=<%=m.getMeetingId()%>" style="color:#28a745; text-decoration:none; margin-right:8px; font-weight:bold;">
							<i class="fa-solid fa-user-check"></i> Attendance
						</a>
						|
						<a href="meetingDetails?id=<%=m.getMeetingId()%>" style="color:#d6336c; text-decoration:none; font-weight:bold; margin-left:8px;">
							<i class="fa-solid fa-file-alt"></i> Notes/Details
						</a>
					</td>
				</tr>
			<%
				}
			} else {
			%>
				<tr><td colspan="9">No meeting history found matching criteria.</td></tr>
			<% } %>
		</table>

		<a href="<%=dashboardUrl%>" class="back-btn"><i class="fa-solid fa-arrow-left"></i> Back to Dashboard</a>

	</div>

</body>
</html>
