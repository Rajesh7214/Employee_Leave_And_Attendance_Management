<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>

<%
String view = (String) request.getAttribute("view");
String selectedDate = (String) request.getAttribute("selectedDate");
String startDateStr = (String) request.getAttribute("startDate");
String endDateStr = (String) request.getAttribute("endDate");
List<Meeting> meetings = (List<Meeting>) request.getAttribute("meetings");

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
<title>Meeting Calendar View | RChips Solutions ELAMS</title>
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

.header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 25px;
}

h2 {
	color: #d6336c;
	margin: 0;
}

.view-tabs {
	display: flex;
	gap: 10px;
	background: white;
	padding: 6px;
	border-radius: 30px;
	box-shadow: 0 4px 10px rgba(0,0,0,0.06);
}

.tab-btn {
	padding: 8px 18px;
	border-radius: 20px;
	text-decoration: none;
	color: #555;
	font-weight: 600;
	font-size: 14px;
	transition: all 0.3s ease;
}

.tab-btn.active {
	background: #d6336c;
	color: white;
	box-shadow: 0 4px 10px rgba(214, 51, 108, 0.3);
}

.date-picker-bar {
	background: white;
	padding: 15px 20px;
	border-radius: 10px;
	margin-bottom: 20px;
	display: flex;
	align-items: center;
	gap: 15px;
	box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.date-picker-bar input {
	padding: 8px 12px;
	border: 1px solid #ccc;
	border-radius: 6px;
	font-size: 14px;
}

.calendar-card {
	background: white;
	border-radius: 12px;
	padding: 25px;
	box-shadow: 0 6px 18px rgba(0,0,0,0.07);
}

.meeting-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
	gap: 20px;
	margin-top: 15px;
}

.meeting-card {
	background: #fbf9fa;
	border-left: 5px solid #d6336c;
	border-radius: 8px;
	padding: 16px;
	box-shadow: 0 2px 8px rgba(0,0,0,0.05);
	transition: transform 0.2s;
}

.meeting-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 6px 15px rgba(0,0,0,0.1);
}

.meeting-card h4 {
	margin: 0 0 8px 0;
	color: #2c3e50;
	font-size: 16px;
}

.meta-item {
	font-size: 13px;
	color: #666;
	margin-bottom: 6px;
	display: flex;
	align-items: center;
	gap: 8px;
}

.badge {
	padding: 3px 8px;
	border-radius: 10px;
	font-size: 11px;
	font-weight: bold;
}

.badge-mode { background: #e3f2fd; color: #1565c0; }
.badge-type { background: #f3e5f5; color: #7b1fa2; }
.badge-status { background: #e8f5e9; color: #2e7d32; }

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

		<div class="header">
			<h2><i class="fa-solid fa-calendar-days"></i> Meeting Calendar View</h2>
			<div class="view-tabs">
				<a href="calendarView?view=daily&date=<%=selectedDate%>" class="tab-btn <%= "daily".equalsIgnoreCase(view) ? "active" : "" %>">Daily View</a>
				<a href="calendarView?view=weekly&date=<%=selectedDate%>" class="tab-btn <%= "weekly".equalsIgnoreCase(view) ? "active" : "" %>">Weekly View</a>
				<a href="calendarView?view=monthly&date=<%=selectedDate%>" class="tab-btn <%= "monthly".equalsIgnoreCase(view) ? "active" : "" %>">Monthly View</a>
			</div>
		</div>

		<div class="date-picker-bar">
			<form action="calendarView" method="get" style="display:flex; align-items:center; gap:12px;">
				<input type="hidden" name="view" value="<%=view%>">
				<label for="dateSelect"><strong>Select Date:</strong></label>
				<input type="date" id="dateSelect" name="date" value="<%=selectedDate%>" onchange="this.form.submit()">
				<span style="color:#777;">(Active Range: <strong><%=startDateStr%></strong> to <strong><%=endDateStr%></strong>)</span>
			</form>
		</div>

		<div class="calendar-card">
			<h3>Meetings (<%= "daily".equalsIgnoreCase(view) ? "Daily" : "weekly".equalsIgnoreCase(view) ? "Weekly" : "Monthly" %> View)</h3>
			
			<div class="meeting-grid">
				<%
				boolean found = false;
				if (meetings != null) {
					for (Meeting m : meetings) {
						String mDateStr = String.valueOf(m.getMeetingDate());
						// Filter according to date range
						if (mDateStr.compareTo(startDateStr) >= 0 && mDateStr.compareTo(endDateStr) <= 0) {
							found = true;
				%>
					<div class="meeting-card">
						<h4><%=m.getTitle()%></h4>
						<div class="meta-item"><i class="fa-regular fa-clock"></i> <%=m.getMeetingDate()%> | <%=m.getStartTime()%> - <%=m.getEndTime()%></div>
						<div class="meta-item"><i class="fa-solid fa-location-dot"></i> <%=m.getMeetingMode()%>: <%=m.getRoom() != null ? m.getRoom() : m.getMeetingLink() != null ? m.getMeetingLink() : "-"%></div>
						<div class="meta-item"><i class="fa-solid fa-tag"></i> Type: <%=m.getMeetingType()%></div>
						<div style="margin-top:10px; display:flex; gap:6px;">
							<span class="badge badge-mode"><%=m.getMeetingMode()%></span>
							<span class="badge badge-type"><%=m.getMeetingType()%></span>
							<span class="badge badge-status"><%=m.getStatus()%></span>
						</div>
						<div style="margin-top:12px;">
							<a href="meetingDetails?id=<%=m.getMeetingId()%>" style="color:#d6336c; font-size:13px; font-weight:bold; text-decoration:none;">View Details & Minutes →</a>
						</div>
					</div>
				<%
						}
					}
				}
				if (!found) {
				%>
					<p style="color:#888; grid-column: 1 / -1; text-align:center; padding:30px;">No meetings scheduled for this timeframe.</p>
				<% } %>
			</div>
		</div>

		<a href="<%=dashboardUrl%>" class="back-btn"><i class="fa-solid fa-arrow-left"></i> Back to Dashboard</a>

	</div>

</body>
</html>
