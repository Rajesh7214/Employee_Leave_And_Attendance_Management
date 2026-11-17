<%@page import="java.util.List"%>
<%@page import="com.rajesh.elams.model.Meeting"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%
if (session == null || session.getAttribute("loggedUser") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

if (request.getAttribute("meetings") == null) {
	response.sendRedirect(request.getContextPath() + "/myMeetings");
	return;
}

List<Meeting> meetingList = (List<Meeting>) request.getAttribute("meetings");
Object currentEmployeeIdObj = request.getAttribute("currentEmployeeId");
Integer currentEmployeeId = currentEmployeeIdObj == null ? null : (Integer) currentEmployeeIdObj;
String errorMessage = (String) request.getAttribute("errorMessage");
String role = (String) session.getAttribute("role");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Meetings | ELAMS</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
body {
	font-family: Arial, Helvetica, sans-serif;
	background: #f4f6f9;
	margin: 0;
	padding: 0;
}

.container {
	width: 95%;
	max-width: 900px;
	margin: 30px auto;
}

h2 {
	text-align: center;
	color: #d6336c;
	margin-bottom: 25px;
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

.meeting-card {
	background: white;
	border-radius: 10px;
	padding: 18px 20px;
	margin-bottom: 14px;
	box-shadow: 0 4px 14px rgba(0, 0, 0, .08);
	border-left: 4px solid #d6336c;
}

.meeting-card .top {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	flex-wrap: wrap;
	gap: 10px;
}

.meeting-card h4 {
	margin: 0 0 4px;
	color: #2c3e50;
	font-size: 16px;
}

.meeting-card .meta {
	font-size: 13px;
	color: #8a8a92;
}

.badge {
	display: inline-block;
	padding: 4px 12px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 700;
	color: white;
}

.badge-SCHEDULED {
	background: #3498db;
}

.badge-ONGOING {
	background: #f39c12;
}

.badge-COMPLETED {
	background: #8a97a1;
}

.badge-CANCELLED {
	background: #e74c3c;
}

.badge-POSTPONED {
	background: #9b59b6;
}

.badge-PENDING_APPROVAL {
	background: #16a085;
}

.actions {
	margin-top: 12px;
	display: flex;
	gap: 10px;
	align-items: center;
}

.btn {
	text-decoration: none;
	padding: 8px 16px;
	border-radius: 6px;
	font-size: 13px;
	font-weight: 600;
	color: white;
	border: none;
	cursor: pointer;
}

.view-btn {
	background: #3498db;
}

.view-btn:hover {
	background: #217dbb;
}

.accept-btn {
	background: #28a745;
}

.accept-btn:hover {
	background: #218838;
}

.reject-btn {
	background: #e74c3c;
}

.reject-btn:hover {
	background: #c0392b;
}

.you-organized {
	font-size: 11px;
	color: #d6336c;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: .03em;
}

.empty-state {
	text-align: center;
	color: #8a8a92;
	padding: 40px;
	background: white;
	border-radius: 10px;
	box-shadow: 0 4px 14px rgba(0, 0, 0, .06);
}

.back {
	text-align: center;
	margin-top: 30px;
}

.back-btn {
	display: inline-block;
	background: #d6336c;
	color: white;
	text-decoration: none;
	padding: 12px 25px;
	border-radius: 30px;
	font-size: 16px;
	font-weight: bold;
	transition: .3s;
	box-shadow: 0 5px 12px rgba(0, 0, 0, .2);
}

.back-btn:hover {
	background: #b52b5d;
	transform: translateY(-2px);
	box-shadow: 0 8px 18px rgba(0, 0, 0, .3);
}
</style>

</head>
<body>

	<div class="container">

		<h2>
			<i class="fa-solid fa-calendar-check"></i> My Meetings
		</h2>

		<%
		if (errorMessage != null) {
		%>
		<div class="alert"><%=errorMessage%></div>
		<%
		}
		%>

		<%
		if (meetingList != null && !meetingList.isEmpty()) {
			for (Meeting m : meetingList) {
				boolean isOrganizer = currentEmployeeId != null && currentEmployeeId == m.getOrganizerId();
		%>
		<div class="meeting-card">
			<div class="top">
				<div>
					<h4><%=m.getTitle()%></h4>
					<div class="meta">
						<%=m.getMeetingDate()%>
						&middot;
						<%=m.getStartTime()%>
						-
						<%=m.getEndTime()%>
						&middot;
						<%=m.getMeetingType()%>
						&middot;
						<%=m.getMeetingMode()%>
						<%
						if (isOrganizer) {
						%>
						&middot; <span class="you-organized">You organized this</span>
						<%
						} else {
						%>
						&middot; Organized by
						<%=m.getOrganizerName()%>
						<%
						}
						%>
					</div>
				</div>
				<span class="badge badge-<%=m.getStatus()%>"><%=m.getStatus()%></span>
			</div>

			<div class="actions">
				<a class="btn view-btn"
					href="meetingDetail?meetingId=<%=m.getMeetingId()%>"> <i
					class="fa-solid fa-eye"></i> View Details
				</a>

				<%
				if (!isOrganizer) {
				%>
				<form action="respondInvitation" method="post"
					style="display: inline;">
					<input type="hidden" name="meetingId" value="<%=m.getMeetingId()%>">
					<input type="hidden" name="decision" value="ACCEPTED">
					<button type="submit" class="btn accept-btn">
						<i class="fa-solid fa-check"></i> Accept
					</button>
				</form>
				<form action="respondInvitation" method="post"
					style="display: inline;">
					<input type="hidden" name="meetingId" value="<%=m.getMeetingId()%>">
					<input type="hidden" name="decision" value="REJECTED">
					<button type="submit" class="btn reject-btn">
						<i class="fa-solid fa-xmark"></i> Reject
					</button>
				</form>
				<%
				}
				%>
			</div>
		</div>
		<%
		}
		} else {
		%>
		<div class="empty-state">You have no meetings scheduled or
			invited to yet.</div>
		<%
		}
		%>

		<div class="back">

			<a
				href="<%="admin".equalsIgnoreCase(role) ? "adminDashboardServlet"
		: "hr".equalsIgnoreCase(role) ? "hrDashboard"
		: "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet"%>"
				class="back-btn"> <i class="fa-solid fa-house"></i> Back to
				Dashboard

			</a>

		</div>

	</div>

</body>
</html>
