<%@page import="java.util.List"%>
<%@page import="com.rajesh.elams.model.Meeting"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
if (session == null || session.getAttribute("loggedUser") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

if (request.getAttribute("meetings") == null) {
	response.sendRedirect(request.getContextPath() + "/viewMeetings");
	return;
}

List<Meeting> meetingList = (List<Meeting>) request.getAttribute("meetings");
String search = (String) request.getAttribute("search");
String statusFilter = (String) request.getAttribute("status");
String typeFilter = (String) request.getAttribute("meetingType");
String priorityFilter = (String) request.getAttribute("priority");
String dateFilter = (String) request.getAttribute("date");
String role = (String) session.getAttribute("role");
boolean canManage = "admin".equalsIgnoreCase(role) || "manager".equalsIgnoreCase(role);

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
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Meetings Management | ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: #f8fafc;
	color: #0f172a;
	min-height: 100vh;
	display: flex;
	flex-direction: column;
}

/* Topbar */
.topbar {
	height: 70px;
	background: #ffffff;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 0 36px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
	position: sticky;
	top: 0;
	z-index: 90;
}

.topbar-left {
	display: flex;
	align-items: center;
	gap: 16px;
}

.btn-back-nav {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	color: #475569;
	text-decoration: none;
	font-weight: 700;
	font-size: 13.5px;
	background: #f1f5f9;
	padding: 8px 16px;
	border-radius: 10px;
	transition: all 0.2s;
}

.btn-back-nav:hover {
	background: #e2e8f0;
	color: #0f172a;
}

.topbar h2 {
	color: #0f172a;
	font-size: 20px;
	font-weight: 800;
}

.right-icons {
	display: flex;
	align-items: center;
	gap: 18px;
}

/* Main Container */
.container {
	padding: 32px 36px;
	max-width: 1280px;
	margin: 0 auto;
	width: 100%;
	flex: 1;
}

/* Header Action Row */
.header-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24px;
	flex-wrap: wrap;
	gap: 16px;
}

.header-title h1 {
	font-size: 24px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 10px;
}

.header-title p {
	font-size: 13.5px;
	color: #64748b;
	margin-top: 4px;
}

.btn-add {
	background: #4f46e5;
	color: #ffffff;
	text-decoration: none;
	padding: 10px 20px;
	border-radius: 12px;
	font-size: 14px;
	font-weight: 700;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
	transition: all 0.2s ease;
}

.btn-add:hover {
	background: #4338ca;
	transform: translateY(-2px);
}

/* Filter Card */
.filter-card {
	background: #ffffff;
	border-radius: 18px;
	padding: 20px 24px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03), 0 0 0 1px rgba(226, 232, 240, 0.8);
	margin-bottom: 24px;
}

.filter-form {
	display: flex;
	flex-wrap: wrap;
	gap: 14px;
	align-items: flex-end;
}

.filter-group {
	display: flex;
	flex-direction: column;
	gap: 6px;
	flex: 1;
	min-width: 160px;
}

.filter-group label {
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	color: #64748b;
	letter-spacing: 0.5px;
}

.filter-group input, .filter-group select {
	padding: 9px 14px;
	border: 1px solid #cbd5e1;
	border-radius: 10px;
	font-size: 13.5px;
	color: #0f172a;
	background: #f8fafc;
	outline: none;
	transition: all 0.2s;
}

.filter-group input:focus, .filter-group select:focus {
	border-color: #6366f1;
	background: #ffffff;
	box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.filter-actions {
	display: flex;
	gap: 10px;
}

.btn-filter {
	background: #0f172a;
	color: #ffffff;
	border: none;
	padding: 10px 20px;
	border-radius: 10px;
	font-weight: 700;
	font-size: 13.5px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: background 0.2s;
}

.btn-filter:hover {
	background: #1e293b;
}

.btn-reset {
	background: #f1f5f9;
	color: #475569;
	text-decoration: none;
	padding: 10px 16px;
	border-radius: 10px;
	font-weight: 700;
	font-size: 13.5px;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: background 0.2s;
}

.btn-reset:hover {
	background: #e2e8f0;
	color: #0f172a;
}

/* Table Card */
.table-card {
	background: #ffffff;
	border-radius: 18px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03), 0 0 0 1px rgba(226, 232, 240, 0.8);
	overflow: hidden;
}

.custom-table {
	width: 100%;
	border-collapse: collapse;
	text-align: left;
}

.custom-table th {
	background: #f8fafc;
	color: #475569;
	font-size: 12px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	padding: 14px 20px;
	border-bottom: 1px solid #e2e8f0;
}

.custom-table td {
	padding: 16px 20px;
	font-size: 14px;
	color: #334155;
	border-bottom: 1px solid #f1f5f9;
	vertical-align: middle;
}

.custom-table tr:last-child td {
	border-bottom: none;
}

.custom-table tr:hover td {
	background: #f8fafc;
}

.meeting-title-cell {
	font-weight: 700;
	color: #0f172a;
}

/* Status Badges */
.badge-status {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 12px;
	border-radius: 30px;
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.3px;
}

.status-SCHEDULED { background: #e0f2fe; color: #0284c7; }
.status-ONGOING { background: #fef3c7; color: #d97706; }
.status-COMPLETED { background: #dcfce7; color: #15803d; }
.status-CANCELLED { background: #fee2e2; color: #b91c1c; }
.status-POSTPONED { background: #f3e8ff; color: #7e22ce; }
.status-PENDING_APPROVAL { background: #ccfbf1; color: #0f766e; }

/* Action Buttons */
.action-btns {
	display: flex;
	align-items: center;
	gap: 6px;
	flex-wrap: wrap;
}

.btn-action-sm {
	padding: 6px 12px;
	border-radius: 8px;
	font-size: 12.5px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.15s ease;
}

.btn-view {
	background: #eef2ff;
	color: #4f46e5;
}
.btn-view:hover {
	background: #4f46e5;
	color: #ffffff;
}

.btn-edit {
	background: #fef3c7;
	color: #b45309;
}
.btn-edit:hover {
	background: #f59e0b;
	color: #ffffff;
}

.btn-delete {
	background: #fee2e2;
	color: #dc2626;
}
.btn-delete:hover {
	background: #dc2626;
	color: #ffffff;
}

/* Empty State */
.empty-state {
	padding: 50px 20px;
	text-align: center;
	color: #64748b;
}

.empty-state i {
	font-size: 44px;
	color: #cbd5e1;
	margin-bottom: 12px;
}

.empty-state h3 {
	font-size: 16px;
	color: #334155;
	margin-bottom: 4px;
}
</style>
</head>
<body>

	<!-- Topbar -->
	<div class="topbar">
		<div class="topbar-left">
			<a href="<%=dashboardUrl%>" class="btn-back-nav">
				<i class="fa-solid fa-arrow-left"></i> Dashboard
			</a>
			<h2>Meetings Management</h2>
		</div>
		<div class="right-icons">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>
	</div>

	<!-- Main Container -->
	<div class="container">
		<!-- Header Row -->
		<div class="header-row">
			<div class="header-title">
				<h1><i class="fa-solid fa-handshake" style="color: #4f46e5;"></i> All Meetings</h1>
				<p>Browse, filter, schedule, and manage organizational meeting sessions.</p>
			</div>
			<% if (canManage) { %>
			<a href="scheduleMeeting" class="btn-add">
				<i class="fa-solid fa-plus"></i> Schedule New Meeting
			</a>
			<% } %>
		</div>

		<!-- Filter Card -->
		<div class="filter-card">
			<form class="filter-form" action="viewMeetings" method="get">
				<div class="filter-group">
					<label><i class="fa-solid fa-magnifying-glass"></i> Search</label>
					<input type="text" name="search" placeholder="Title or organizer..." value="<%=search != null ? search : ""%>">
				</div>

				<div class="filter-group">
					<label><i class="fa-solid fa-chart-line"></i> Status</label>
					<select name="status">
						<option value="">All Statuses</option>
						<option value="SCHEDULED" <%="SCHEDULED".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Scheduled</option>
						<option value="ONGOING" <%="ONGOING".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Ongoing</option>
						<option value="COMPLETED" <%="COMPLETED".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Completed</option>
						<option value="CANCELLED" <%="CANCELLED".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Cancelled</option>
						<option value="POSTPONED" <%="POSTPONED".equalsIgnoreCase(statusFilter) ? "selected" : ""%>>Postponed</option>
					</select>
				</div>

				<div class="filter-group">
					<label><i class="fa-solid fa-tag"></i> Type</label>
					<input type="text" name="meetingType" placeholder="e.g. Sprint Review" value="<%=typeFilter != null ? typeFilter : ""%>">
				</div>

				<div class="filter-group">
					<label><i class="fa-solid fa-flag"></i> Priority</label>
					<select name="priority">
						<option value="">All Priorities</option>
						<option value="Low" <%="Low".equalsIgnoreCase(priorityFilter) ? "selected" : ""%>>Low</option>
						<option value="Normal" <%="Normal".equalsIgnoreCase(priorityFilter) ? "selected" : ""%>>Normal</option>
						<option value="High" <%="High".equalsIgnoreCase(priorityFilter) ? "selected" : ""%>>High</option>
					</select>
				</div>

				<div class="filter-group">
					<label><i class="fa-solid fa-calendar"></i> Date</label>
					<input type="date" name="date" value="<%=dateFilter != null ? dateFilter : ""%>">
				</div>

				<div class="filter-actions">
					<button type="submit" class="btn-filter">
						<i class="fa-solid fa-filter"></i> Filter
					</button>
					<a href="viewMeetings" class="btn-reset">
						<i class="fa-solid fa-rotate-left"></i> Reset
					</a>
				</div>
			</form>
		</div>

		<!-- Meetings Table Card -->
		<div class="table-card">
			<table class="custom-table">
				<thead>
					<tr>
						<th>Title</th>
						<th>Type</th>
						<th>Mode</th>
						<th>Date</th>
						<th>Time</th>
						<th>Organizer</th>
						<th>Priority</th>
						<th>Status</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					<% if (meetingList != null && !meetingList.isEmpty()) {
						for (Meeting m : meetingList) {
							String statusClass = m.getStatus() != null ? m.getStatus().name().toUpperCase() : "SCHEDULED";
					%>
					<tr>
						<td class="meeting-title-cell"><%=m.getTitle()%></td>
						<td><%=m.getMeetingType() != null ? m.getMeetingType() : "-"%></td>
						<td><%=m.getMeetingMode() != null ? m.getMeetingMode() : "-"%></td>
						<td><%=m.getMeetingDate() != null ? m.getMeetingDate() : "-"%></td>
						<td><%=m.getStartTime()%> - <%=m.getEndTime()%></td>
						<td><%=m.getOrganizerName() != null ? m.getOrganizerName() : "Organizer"%></td>
						<td><%=m.getPriority() != null ? m.getPriority() : "Normal"%></td>
						<td>
							<span class="badge-status status-<%=statusClass%>">
								<%=m.getStatus()%>
							</span>
						</td>
						<td>
							<div class="action-btns">
								<a href="meetingDetail?meetingId=<%=m.getMeetingId()%>" class="btn-action-sm btn-view">
									<i class="fa-solid fa-eye"></i> View
								</a>
								<% if (canManage) { %>
								<a href="editMeeting?meetingId=<%=m.getMeetingId()%>" class="btn-action-sm btn-edit">
									<i class="fa-solid fa-pen-to-square"></i> Edit
								</a>
								<a href="deleteMeeting?meetingId=<%=m.getMeetingId()%>" class="btn-action-sm btn-delete" onclick="return confirm('Are you sure you want to delete this meeting?');">
									<i class="fa-solid fa-trash"></i> Delete
								</a>
								<% } %>
							</div>
						</td>
					</tr>
					<% }
					} else { %>
					<tr>
						<td colspan="9">
							<div class="empty-state">
								<i class="fa-solid fa-calendar-xmark"></i>
								<h3>No Meetings Found</h3>
								<p>Try clearing filters or schedule a new meeting session.</p>
							</div>
						</td>
					</tr>
					<% } %>
				</tbody>
			</table>
		</div>
	</div>

</body>
</html>
