<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="com.rajesh.elams.model.MeetingParticipant"%>

<%
Meeting meeting = (Meeting) request.getAttribute("meeting");
List<MeetingParticipant> participants = (List<MeetingParticipant>) request.getAttribute("participants");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Meeting Attendance | RChips Solutions ELAMS</title>
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
	width: 90%;
	max-width: 900px;
	margin: 35px auto;
}

.card {
	background: white;
	border-radius: 12px;
	padding: 30px;
	box-shadow: 0 8px 25px rgba(0, 0, 0, .08);
}

h2 {
	color: #d6336c;
	margin-top: 0;
}

table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 20px;
}

th {
	background: #d6336c;
	color: white;
	padding: 12px;
	text-align: left;
}

td {
	padding: 12px;
	border-bottom: 1px solid #eee;
}

select {
	padding: 6px 12px;
	border-radius: 6px;
	border: 1px solid #ccc;
	font-size: 14px;
}

.badge {
	padding: 4px 10px;
	border-radius: 10px;
	font-size: 12px;
	font-weight: bold;
}
.badge-PRESENT { background: #c8e6c9; color: #2e7d32; }
.badge-ABSENT { background: #ffcdd2; color: #c62828; }
.badge-LATE { background: #fff9c4; color: #f57f17; }
.badge-EXCUSED { background: #e1bee7; color: #6a1b9a; }

.back-btn {
	display: inline-block;
	margin-top: 20px;
	color: #d6336c;
	text-decoration: none;
	font-weight: bold;
}
</style>
</head>
<body>

	<div class="container">

		<div class="card">
			<h2><i class="fa-solid fa-clipboard-user"></i> Meeting Attendance Tracking</h2>
			<% if (meeting != null) { %>
				<p><strong>Title:</strong> <%=meeting.getTitle()%></p>
				<p><strong>Date & Time:</strong> <%=meeting.getMeetingDate()%> | <%=meeting.getStartTime()%> - <%=meeting.getEndTime()%></p>
			<% } %>

			<table>
				<tr>
					<th>Participant ID</th>
					<th>Employee Name</th>
					<th>Invitation Status</th>
					<th>Attendance Status</th>
					<th>Mark Attendance</th>
				</tr>
				<%
				if (participants != null && !participants.isEmpty()) {
					for (MeetingParticipant p : participants) {
				%>
					<tr>
						<td>#<%=p.getEmployeeId()%></td>
						<td><strong><%=p.getEmployeeName() != null ? p.getEmployeeName() : "Employee #" + p.getEmployeeId()%></strong></td>
						<td><%=p.getInvitationStatus()%></td>
						<td>
							<% if (p.getAttendance() != null) { %>
								<span class="badge badge-<%=p.getAttendance()%>"><%=p.getAttendance()%></span>
							<% } else { %>
								<span style="color:#999;">Not Marked</span>
							<% } %>
						</td>
						<td>
							<form action="meetingAttendance" method="post" style="margin:0;">
								<input type="hidden" name="meetingId" value="<%=meeting.getMeetingId()%>">
								<input type="hidden" name="participantId" value="<%=p.getParticipantId()%>">
								<select name="attendance" onchange="this.form.submit()">
									<option value="">-- Select --</option>
									<option value="PRESENT" <%= "PRESENT".equals(String.valueOf(p.getAttendance())) ? "selected" : "" %>>Present</option>
									<option value="ABSENT" <%= "ABSENT".equals(String.valueOf(p.getAttendance())) ? "selected" : "" %>>Absent</option>
									<option value="LATE" <%= "LATE".equals(String.valueOf(p.getAttendance())) ? "selected" : "" %>>Late</option>
									<option value="EXCUSED" <%= "EXCUSED".equals(String.valueOf(p.getAttendance())) ? "selected" : "" %>>Excused</option>
								</select>
							</form>
						</td>
					</tr>
				<%
					}
				} else {
				%>
					<tr><td colspan="5" style="text-align:center;">No participants listed.</td></tr>
				<% } %>
			</table>

			<a href="viewMeetings" class="back-btn"><i class="fa-solid fa-arrow-left"></i> Back to Meetings</a>
		</div>

	</div>

</body>
</html>
