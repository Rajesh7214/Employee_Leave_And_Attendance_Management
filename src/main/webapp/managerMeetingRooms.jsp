<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<%@ page import="java.util.List"%>
<%@ page import="com.rajesh.elams.model.MeetingRoom"%>

<%
List<MeetingRoom> roomList = (List<MeetingRoom>) request.getAttribute("rooms");
String errorMessage = (String) request.getAttribute("errorMessage");

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
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Meeting Rooms | ELAMS</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />

<style>
body {
	font-family: Arial, Helvetica, sans-serif;
	background: #f4f6f9;
	margin: 0;
	padding: 0;
}

.container {
	width: 90%;
	max-width: 1000px;
	margin: 30px auto;
}

h2 {
	text-align: center;
	color: #d6336c;
	margin-bottom: 25px;
}

.card {
	background: white;
	border-radius: 10px;
	padding: 20px;
	box-shadow: 0 0 12px rgba(0, 0, 0, .08);
	margin-bottom: 25px;
}

.card h3 {
	margin-top: 0;
	color: #333;
}

.form-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
	gap: 14px;
	align-items: end;
}

.field {
	display: flex;
	flex-direction: column;
	font-size: 13px;
	color: #555;
}

.field input {
	margin-top: 6px;
	padding: 9px;
	border: 1px solid #ccc;
	border-radius: 6px;
}

.btn {
	background: #d6336c;
	color: white;
	border: none;
	padding: 10px 18px;
	border-radius: 6px;
	font-weight: bold;
	cursor: pointer;
	transition: .3s;
	text-decoration: none;
	display: inline-block;
}

.btn:hover {
	background: #b81f57;
}

.btn-small {
	padding: 6px 12px;
	font-size: 13px;
}

.btn-outline {
	background: white;
	color: #d6336c;
	border: 1px solid #d6336c;
}

.btn-outline:hover {
	background: #ffe6ef;
}

.btn-danger {
	background: #e03131;
}

.btn-danger:hover {
	background: #c92a2a;
}

table {
	width: 100%;
	border-collapse: collapse;
	background: white;
	border-radius: 10px;
	overflow: hidden;
}

th {
	background: #d6336c;
	color: white;
	padding: 10px;
	text-align: left;
}

td {
	padding: 10px;
	border-bottom: 1px solid #eee;
}

tr:hover {
	background: #fafafa;
}

.badge {
	padding: 4px 10px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: bold;
	color: white;
}

.active {
	background: #2f9e44;
}

.inactive {
	background: #868e96;
}

.error-box {
	background: #ffe3e3;
	color: #c92a2a;
	padding: 12px 16px;
	border-radius: 8px;
	margin-bottom: 18px;
}

.actions {
	display: flex;
	gap: 8px;
}

.top-links {
	margin-bottom: 20px;
}

.top-links a {
	text-decoration: none;
	color: #d6336c;
	font-weight: 600;
	margin-right: 18px;
}
</style>

</head>
<body>

	<div class="container">

		<h2>
			<i class="fa-solid fa-door-open"></i> Manage Meeting Rooms
		</h2>

		<div class="top-links">
			<a href="<%=dashboardUrl%>"><i class="fa-solid fa-house"></i>
				Dashboard</a> <a href="viewMeetings"><i
				class="fa-solid fa-camera-video"></i> All Meetings</a> <a
				href="meetingReports"><i class="fa-solid fa-chart-column"></i>
				Meeting Reports</a>
		</div>

		<%
		if (errorMessage != null) {
		%>
		<div class="error-box">
			<i class="fa-solid fa-triangle-exclamation"></i>
			<%=errorMessage%></div>
		<%
		}
		%>

		<div class="card">
			<h3>Add Meeting Room</h3>
			<form action="manageMeetingRooms" method="post">
				<div class="form-grid">
					<div class="field">
						Room Name <input type="text" name="roomName"
							placeholder="e.g. Conference Room A" required>
					</div>
					<div class="field">
						Location <input type="text" name="location"
							placeholder="e.g. 3rd Floor, East Wing">
					</div>
					<div class="field">
						Capacity <input type="number" name="capacity" min="1"
							placeholder="e.g. 10">
					</div>
					<div class="field">
						<button type="submit" class="btn">
							<i class="fa-solid fa-plus"></i> Add Room
						</button>
					</div>
				</div>
			</form>
		</div>

		<table>
			<tr>
				<th>Room Name</th>
				<th>Location</th>
				<th>Capacity</th>
				<th>Status</th>
				<th>Actions</th>
			</tr>

			<%
			if (roomList != null && !roomList.isEmpty()) {
				for (MeetingRoom room : roomList) {
			%>
			<tr>
				<td><%=room.getRoomName()%></td>
				<td><%=room.getLocation() == null ? "-" : room.getLocation()%></td>
				<td><%=room.getCapacity() == null ? "-" : room.getCapacity()%></td>
				<td><span
					class="badge <%="ACTIVE".equalsIgnoreCase(room.getStatus()) ? "active" : "inactive"%>">
						<%=room.getStatus()%>
				</span></td>
				<td class="actions"><a class="btn btn-small btn-outline"
					href="editMeetingRoom?roomId=<%=room.getRoomId()%>"> <i
						class="fa-solid fa-pen"></i> Edit
				</a> <a class="btn btn-small btn-danger"
					href="deleteMeetingRoom?roomId=<%=room.getRoomId()%>"
					onclick="return confirm('Delete room \'<%=room.getRoomName()%>\'? This cannot be undone.');">
						<i class="fa-solid fa-trash"></i> Delete
				</a></td>
			</tr>
			<%
			}
			} else {
			%>
			<tr>
				<td colspan="5" style="text-align: center;">No meeting rooms
					have been added yet.</td>
			</tr>
			<%
			}
			%>

		</table>

	</div>

</body>
</html>
