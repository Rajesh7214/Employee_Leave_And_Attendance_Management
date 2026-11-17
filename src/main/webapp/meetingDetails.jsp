<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="com.rajesh.elams.model.MeetingParticipant"%>
<%@ page import="com.rajesh.elams.model.MeetingNote"%>
<%@ page import="com.rajesh.elams.model.MeetingAttachment"%>

<%
if (session == null || session.getAttribute("loggedUser") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

Meeting meeting = (Meeting) request.getAttribute("meeting");
List<MeetingParticipant> participants = (List<MeetingParticipant>) request.getAttribute("participants");
MeetingNote note = (MeetingNote) request.getAttribute("meetingNote");
List<MeetingAttachment> attachments = (List<MeetingAttachment>) request.getAttribute("attachments");
Boolean isOrganizerOrAdmin = (Boolean) request.getAttribute("isOrganizerOrAdmin");
String myInvitationStatus = (String) request.getAttribute("myInvitationStatus");

String role = (String) session.getAttribute("role");
String dashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";

if (meeting == null) {
	response.sendRedirect(request.getContextPath() + "/viewMeetings");
	return;
}

// Calculate attendance stats
int totalParticipants = participants != null ? participants.size() : 0;
int presentCount = 0;
int absentCount = 0;
int lateCount = 0;
int pendingCount = 0;

if (participants != null) {
	for (MeetingParticipant p : participants) {
		String att = p.getAttendance() != null ? p.getAttendance().toString() : "Not Marked";
		if ("Present".equalsIgnoreCase(att)) presentCount++;
		else if ("Absent".equalsIgnoreCase(att)) absentCount++;
		else if ("Late".equalsIgnoreCase(att)) lateCount++;
		else pendingCount++;
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title><%=meeting.getTitle()%> | Meeting Details | ELAMS</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: linear-gradient(180deg, #f0f9ff 0%, #f4f6fb 100%);
	color: #0f172a;
	min-height: 100vh;
}

/* Header Navbar */
.navbar {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	padding: 16px 35px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 20px rgba(13, 148, 136, 0.28);
	position: sticky;
	top: 0;
	z-index: 100;
}

.navbar-brand {
	display: flex;
	align-items: center;
	gap: 12px;
	text-decoration: none;
	color: white;
}

.navbar-brand i {
	font-size: 22px;
	background: rgba(255, 255, 255, 0.22);
	width: 42px;
	height: 42px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.navbar-title {
	font-size: 22px;
	font-weight: 800;
}

.layout-wrapper {
	max-width: 1050px;
	margin: 0 auto;
	padding: 30px 24px;
}

.card {
	background: #ffffff;
	border-radius: 20px;
	padding: 28px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
	margin-bottom: 24px;
}

/* Hero / Header Card */
.hero-card {
	background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
	border-left: 6px solid #0284c7;
}

.meeting-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-start;
	gap: 16px;
	flex-wrap: wrap;
}

.meeting-title {
	font-size: 26px;
	font-weight: 800;
	color: #0f172a;
	line-height: 1.3;
}

.status-badge {
	padding: 8px 18px;
	border-radius: 24px;
	font-size: 13px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.status-SCHEDULED { background: #e0f2fe; color: #0284c7; border: 1px solid #bae6fd; }
.status-ONGOING { background: #fef3c7; color: #d97706; border: 1px solid #fde68a; }
.status-COMPLETED { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
.status-CANCELLED { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

/* Join Banner */
.join-banner {
	background: linear-gradient(135deg, #059669 0%, #10b981 100%);
	color: white;
	border-radius: 16px;
	padding: 20px 24px;
	margin: 20px 0 10px 0;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 16px;
	box-shadow: 0 8px 24px rgba(16, 185, 129, 0.25);
}

.join-banner-info {
	display: flex;
	align-items: center;
	gap: 14px;
}

.join-banner-icon {
	width: 48px;
	height: 48px;
	background: rgba(255, 255, 255, 0.2);
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 22px;
}

.btn-join-now {
	background: #ffffff;
	color: #047857;
	padding: 12px 28px;
	border-radius: 12px;
	font-weight: 800;
	font-size: 15px;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	transition: all 0.2s ease;
	box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.btn-join-now:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(0,0,0,0.15);
	background: #f0fdf4;
}

/* Info Grid */
.info-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
	gap: 14px;
	margin: 20px 0 10px 0;
}

.info-item {
	background: #f8fafc;
	border-radius: 14px;
	padding: 14px 18px;
	border: 1px solid #f1f5f9;
}

.info-item .label {
	font-size: 11.5px;
	font-weight: 800;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.info-item .value {
	font-size: 14.5px;
	font-weight: 700;
	color: #0f172a;
	margin-top: 4px;
}

/* Action Button Bar */
.action-bar {
	display: flex;
	gap: 10px;
	flex-wrap: wrap;
	margin-top: 20px;
	padding-top: 16px;
	border-top: 1px solid #f1f5f9;
}

.btn-pill {
	padding: 9px 18px;
	border-radius: 12px;
	font-size: 13.5px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	cursor: pointer;
	border: none;
	transition: all 0.2s ease;
}

.btn-pill-primary { background: #0284c7; color: white; }
.btn-pill-primary:hover { background: #0369a1; }
.btn-pill-success { background: #10b981; color: white; }
.btn-pill-success:hover { background: #059669; }
.btn-pill-danger { background: #ef4444; color: white; }
.btn-pill-danger:hover { background: #dc2626; }
.btn-pill-secondary { background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; }
.btn-pill-secondary:hover { background: #e2e8f0; }

/* Stats Bar for Attendance */
.attendance-stats {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
	gap: 12px;
	margin-bottom: 20px;
}

.stat-pill {
	background: #f8fafc;
	border-radius: 14px;
	padding: 14px;
	border: 1px solid #e2e8f0;
	text-align: center;
}

.stat-value {
	font-size: 22px;
	font-weight: 800;
}

.stat-label {
	font-size: 11.5px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
	margin-top: 2px;
}

.stat-present .stat-value { color: #16a34a; }
.stat-absent .stat-value { color: #dc2626; }
.stat-late .stat-value { color: #d97706; }
.stat-total .stat-value { color: #0284c7; }

/* Table Styling */
table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 10px;
}

th {
	background: #f8fafc;
	padding: 12px 16px;
	font-size: 12px;
	font-weight: 800;
	color: #475569;
	text-transform: uppercase;
	border-bottom: 2px solid #e2e8f0;
	text-align: left;
}

td {
	padding: 14px 16px;
	font-size: 13.5px;
	color: #1e293b;
	border-bottom: 1px solid #f1f5f9;
}

.badge-inv {
	padding: 4px 10px;
	border-radius: 12px;
	font-size: 11.5px;
	font-weight: 700;
}
.inv-accepted { background: #dcfce7; color: #15803d; }
.inv-rejected { background: #fee2e2; color: #b91c1c; }
.inv-pending { background: #fef3c7; color: #b45309; }

.badge-att {
	padding: 5px 12px;
	border-radius: 12px;
	font-size: 12px;
	font-weight: 700;
	display: inline-flex;
	align-items: center;
	gap: 6px;
}
.att-present { background: #dcfce7; color: #15803d; }
.att-absent { background: #fee2e2; color: #b91c1c; }
.att-late { background: #fef3c7; color: #b45309; }
.att-pending { background: #f1f5f9; color: #64748b; }

/* Attachments Styling */
.attachments-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
	gap: 16px;
	margin-top: 16px;
}

.attachment-card {
	background: #f8fafc;
	border: 1px solid #e2e8f0;
	border-radius: 14px;
	padding: 16px;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	gap: 12px;
	transition: all 0.2s ease;
}

.attachment-card:hover {
	border-color: #38bdf8;
	box-shadow: 0 6px 16px rgba(2, 132, 199, 0.08);
}

.attachment-header {
	display: flex;
	align-items: center;
	gap: 12px;
}

.attachment-icon {
	width: 42px;
	height: 42px;
	border-radius: 10px;
	background: #e0f2fe;
	color: #0284c7;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 18px;
	flex-shrink: 0;
}

.attachment-name {
	font-size: 14px;
	font-weight: 700;
	color: #0f172a;
	word-break: break-all;
}

.attachment-meta {
	font-size: 11.5px;
	color: #64748b;
	margin-top: 2px;
}

.attachment-actions {
	display: flex;
	align-items: center;
	justify-content: space-between;
	border-top: 1px dashed #e2e8f0;
	padding-top: 10px;
}

.notes-box {
	background: #f8fafc;
	border-left: 4px solid #0284c7;
	padding: 18px;
	border-radius: 12px;
	margin-top: 12px;
}

textarea, input[type="text"] {
	width: 100%;
	padding: 12px;
	border: 1.8px solid #cbd5e1;
	border-radius: 12px;
	font-size: 14px;
	outline: none;
	margin-bottom: 12px;
}

textarea:focus, input[type="text"]:focus, select:focus {
	border-color: #0284c7;
}

.btn-save {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	border: none;
	padding: 10px 24px;
	border-radius: 12px;
	font-weight: 700;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
}
</style>
</head>
<body>

	<!-- Top Navbar -->
	<div class="navbar">
		<a href="<%=dashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-handshake"></i>
			<span class="navbar-title">Meeting Session Details</span>
		</a>
		<div style="display: flex; align-items: center; gap: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>
	</div>

	<div class="layout-wrapper">

		<!-- 1. HERO MEETING HEADER CARD -->
		<div class="card hero-card">
			<div class="meeting-header">
				<div>
					<div class="meeting-title"><%=meeting.getTitle()%></div>
					<div style="color: #64748b; font-size: 14px; font-weight: 600; margin-top: 6px;">
						Organized by <strong><%=meeting.getOrganizerName() != null ? meeting.getOrganizerName() : "EMP-" + meeting.getOrganizerId()%></strong>
					</div>
				</div>
				<span class="status-badge status-<%=meeting.getStatus()%>"><%=meeting.getStatus()%></span>
			</div>

			<!-- JOIN MEETING BANNER (Virtual / Hybrid Link) -->
			<% if (meeting.getMeetingLink() != null && !meeting.getMeetingLink().isBlank()) { %>
			<div class="join-banner">
				<div class="join-banner-info">
					<div class="join-banner-icon">
						<i class="fa-solid fa-video"></i>
					</div>
					<div>
						<div style="font-size: 16px; font-weight: 800;">Virtual Meeting Available</div>
						<div style="font-size: 13px; opacity: 0.9;">Click to launch and join the session directly</div>
					</div>
				</div>
				<a href="<%=meeting.getMeetingLink()%>" target="_blank" class="btn-join-now">
					<i class="fa-solid fa-arrow-up-right-from-square"></i> Join Meeting
				</a>
			</div>
			<% } %>

			<!-- INFO GRID -->
			<div class="info-grid">
				<div class="info-item">
					<div class="label">Date</div>
					<div class="value"><%=meeting.getMeetingDate()%></div>
				</div>
				<div class="info-item">
					<div class="label">Time</div>
					<div class="value"><%=meeting.getStartTime()%> - <%=meeting.getEndTime()%></div>
				</div>
				<div class="info-item">
					<div class="label">Type</div>
					<div class="value"><%=meeting.getMeetingType()%></div>
				</div>
				<div class="info-item">
					<div class="label">Mode</div>
					<div class="value"><%=meeting.getMeetingMode()%></div>
				</div>
				<% if (meeting.getRoom() != null && !meeting.getRoom().isBlank()) { %>
				<div class="info-item">
					<div class="label">Room / Location</div>
					<div class="value"><%=meeting.getRoom()%></div>
				</div>
				<% } %>
			</div>

			<% if (meeting.getDescription() != null && !meeting.getDescription().isBlank()) { %>
			<div style="margin-top: 14px;">
				<span style="font-size: 11.5px; font-weight: 800; color: #64748b; text-transform: uppercase;">Description</span>
				<p style="font-size: 14.5px; color: #334155; margin-top: 4px; line-height: 1.6;"><%=meeting.getDescription()%></p>
			</div>
			<% } %>

			<% if (meeting.getAgenda() != null && !meeting.getAgenda().isBlank()) { %>
			<div style="margin-top: 14px;">
				<span style="font-size: 11.5px; font-weight: 800; color: #64748b; text-transform: uppercase;">Agenda</span>
				<p style="font-size: 14.5px; color: #334155; margin-top: 4px; line-height: 1.6;"><%=meeting.getAgenda()%></p>
			</div>
			<% } %>

			<!-- QUICK ACTION BAR -->
			<div class="action-bar">
				<a href="viewMeetings" class="btn-pill btn-pill-secondary">
					<i class="fa-solid fa-arrow-left"></i> Back to Meetings
				</a>

				<% if ("Pending".equalsIgnoreCase(myInvitationStatus)) { %>
				<a href="respondMeeting?meetingId=<%=meeting.getMeetingId()%>&decision=Accepted" class="btn-pill btn-pill-success">
					<i class="fa-solid fa-check"></i> Accept Invitation
				</a>
				<a href="respondMeeting?meetingId=<%=meeting.getMeetingId()%>&decision=Rejected" class="btn-pill btn-pill-danger">
					<i class="fa-solid fa-xmark"></i> Reject
				</a>
				<% } %>

				<% if (Boolean.TRUE.equals(isOrganizerOrAdmin)) { %>
				<a href="editMeeting?meetingId=<%=meeting.getMeetingId()%>" class="btn-pill btn-pill-secondary">
					<i class="fa-solid fa-pen-to-square"></i> Reschedule / Edit
				</a>
				<% } %>

				<button onclick="window.print()" class="btn-pill btn-pill-secondary">
					<i class="fa-solid fa-print"></i> Print / Export
				</button>
			</div>
		</div>

		<!-- 2. PARTICIPANTS & ATTENDANCE DASHBOARD -->
		<div class="card" id="participantsSection">
			<h3 style="font-size: 18.5px; font-weight: 800; color: #0f172a; margin-bottom: 16px;">
				<i class="fa-solid fa-users-rectangle" style="color: #0284c7;"></i> Participants &amp; Attendance Management
			</h3>

			<!-- Stat Counters -->
			<div class="attendance-stats">
				<div class="stat-pill stat-total">
					<div class="stat-value"><%=totalParticipants%></div>
					<div class="stat-label">Total Invited</div>
				</div>
				<div class="stat-pill stat-present">
					<div class="stat-value"><%=presentCount%></div>
					<div class="stat-label">Present</div>
				</div>
				<div class="stat-pill stat-absent">
					<div class="stat-value"><%=absentCount%></div>
					<div class="stat-label">Absent</div>
				</div>
				<div class="stat-pill stat-late">
					<div class="stat-value"><%=lateCount%></div>
					<div class="stat-label">Late</div>
				</div>
			</div>

			<!-- Participant Attendance Table -->
			<form action="markMeetingAttendance" method="post">
				<input type="hidden" name="meetingId" value="<%=meeting.getMeetingId()%>" />
				<table>
					<thead>
						<tr>
							<th>Employee</th>
							<th>Email</th>
							<th>Invitation Status</th>
							<th>Attendance Status</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (participants != null && !participants.isEmpty()) {
							for (MeetingParticipant p : participants) {
								String inv = p.getInvitationStatus() != null ? p.getInvitationStatus().toString() : "Pending";
								String invClass = "inv-pending";
								if ("Accepted".equalsIgnoreCase(inv)) invClass = "inv-accepted";
								if ("Rejected".equalsIgnoreCase(inv)) invClass = "inv-rejected";

								String att = p.getAttendance() != null ? p.getAttendance().toString() : "Not Marked";
								String attClass = "att-pending";
								if ("Present".equalsIgnoreCase(att)) attClass = "att-present";
								else if ("Absent".equalsIgnoreCase(att)) attClass = "att-absent";
								else if ("Late".equalsIgnoreCase(att)) attClass = "att-late";
						%>
						<tr>
							<td>
								<strong><%=p.getEmployeeName() != null ? p.getEmployeeName() : "Employee #" + p.getEmployeeId()%></strong>
							</td>
							<td><%=p.getEmployeeEmail() != null ? p.getEmployeeEmail() : "-"%></td>
							<td><span class="badge-inv <%=invClass%>"><%=inv%></span></td>
							<td>
								<% if (Boolean.TRUE.equals(isOrganizerOrAdmin)) { %>
								<select name="attendance_<%=p.getEmployeeId()%>" style="padding: 6px 12px; border-radius: 8px; border: 1px solid #cbd5e1; font-size: 13px; font-weight: 600;">
									<option value="Not Marked" <%="Not Marked".equalsIgnoreCase(att) ? "selected" : ""%>>Not Marked</option>
									<option value="Present" <%="Present".equalsIgnoreCase(att) ? "selected" : ""%>>Present</option>
									<option value="Absent" <%="Absent".equalsIgnoreCase(att) ? "selected" : ""%>>Absent</option>
									<option value="Late" <%="Late".equalsIgnoreCase(att) ? "selected" : ""%>>Late</option>
								</select>
								<% } else { %>
								<span class="badge-att <%=attClass%>"><%=att%></span>
								<% } %>
							</td>
						</tr>
						<%
							}
						} else {
						%>
						<tr>
							<td colspan="4" style="text-align: center; color: #64748b; padding: 20px;">No participants attached to this meeting.</td>
						</tr>
						<% } %>
					</tbody>
				</table>

				<% if (Boolean.TRUE.equals(isOrganizerOrAdmin) && participants != null && !participants.isEmpty()) { %>
				<div style="margin-top: 18px;">
					<button type="submit" class="btn-save">
						<i class="fa-solid fa-floppy-disk"></i> Update Participant Attendance
					</button>
				</div>
				<% } %>
			</form>
		</div>

		<!-- 3. DOCUMENTS & ATTACHMENTS CARD -->
		<div class="card" id="attachmentsSection">
			<h3 style="font-size: 18.5px; font-weight: 800; color: #0f172a; margin-bottom: 16px;">
				<i class="fa-solid fa-folder-open" style="color: #0284c7;"></i> Meeting Documents &amp; Attachments
			</h3>

			<!-- Upload Form for Organizer / Admin -->
			<% if (Boolean.TRUE.equals(isOrganizerOrAdmin)) { %>
			<div style="background: #f8fafc; border-radius: 14px; padding: 20px; border: 1px solid #e2e8f0; margin-bottom: 20px;">
				<h4 style="font-size: 14px; font-weight: 800; color: #334155; margin-bottom: 12px;">
					<i class="fa-solid fa-plus-circle"></i> Add New Attachment / Document Link
				</h4>
				<form action="uploadMeetingAttachment" method="post">
					<input type="hidden" name="meetingId" value="<%=meeting.getMeetingId()%>" />
					<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px;">
						<div>
							<label style="font-size: 12px; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Document Title / Name</label>
							<input type="text" name="fileName" placeholder="e.g. Q3 Presentation Slides.pdf" required />
						</div>
						<div>
							<label style="font-size: 12px; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">File Path or URL Link</label>
							<input type="text" name="filePath" placeholder="https://drive.google.com/... or file link" required />
						</div>
						<div>
							<label style="font-size: 12px; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Category / Type</label>
							<select name="fileType" style="width: 100%; padding: 12px; border-radius: 12px; border: 1.8px solid #cbd5e1; font-size: 14px; outline: none; margin-bottom: 12px;">
								<option value="PDF Document">PDF Document</option>
								<option value="Presentation / Slides">Presentation / Slides</option>
								<option value="Spreadsheet / Excel">Spreadsheet / Excel</option>
								<option value="Meeting Minutes">Meeting Minutes</option>
								<option value="External Link">External Link</option>
							</select>
						</div>
					</div>
					<div>
						<label style="font-size: 12px; font-weight: 700; color: #475569; display: block; margin-bottom: 4px;">Brief Description (Optional)</label>
						<input type="text" name="description" placeholder="Brief notes about this attachment..." />
					</div>
					<button type="submit" class="btn-save">
						<i class="fa-solid fa-cloud-arrow-up"></i> Upload Attachment
					</button>
				</form>
			</div>
			<% } %>

			<!-- Attachments List -->
			<% if (attachments != null && !attachments.isEmpty()) { %>
			<div class="attachments-grid">
				<% for (MeetingAttachment att : attachments) { 
					String iconClass = "fa-file-lines";
					if (att.getFileType() != null) {
						String ft = att.getFileType().toLowerCase();
						if (ft.contains("pdf")) iconClass = "fa-file-pdf";
						else if (ft.contains("slide") || ft.contains("presentation")) iconClass = "fa-file-powerpoint";
						else if (ft.contains("sheet") || ft.contains("excel")) iconClass = "fa-file-excel";
						else if (ft.contains("link")) iconClass = "fa-link";
					}
				%>
				<div class="attachment-card">
					<div class="attachment-header">
						<div class="attachment-icon">
							<i class="fa-solid <%=iconClass%>"></i>
						</div>
						<div>
							<div class="attachment-name"><%=att.getFileName()%></div>
							<div class="attachment-meta">
								Added by <strong><%=att.getUploadedByName()%></strong>
							</div>
						</div>
					</div>
					<% if (att.getDescription() != null && !att.getDescription().isBlank()) { %>
					<p style="font-size: 12.5px; color: #475569;"><%=att.getDescription()%></p>
					<% } %>
					<div class="attachment-actions">
						<a href="<%=att.getFilePath()%>" target="_blank" style="color: #0284c7; font-size: 13px; font-weight: 700; text-decoration: none;">
							<i class="fa-solid fa-download"></i> View / Open File
						</a>
						<% if (Boolean.TRUE.equals(isOrganizerOrAdmin)) { %>
						<a href="deleteMeetingAttachment?attachmentId=<%=att.getAttachmentId()%>&meetingId=<%=meeting.getMeetingId()%>" 
						   onclick="return confirm('Remove this attachment?');" 
						   style="color: #ef4444; font-size: 12px; text-decoration: none;">
							<i class="fa-solid fa-trash"></i>
						</a>
						<% } %>
					</div>
				</div>
				<% } %>
			</div>
			<% } else { %>
			<p style="color: #64748b; font-size: 14px; margin-top: 8px;">No attachments or documents uploaded for this meeting yet.</p>
			<% } %>
		</div>

		<!-- 4. MEETING NOTES & ACTION ITEMS CARD -->
		<div class="card" id="notesSection">
			<h3 style="font-size: 18.5px; font-weight: 800; color: #0f172a; margin-bottom: 14px;">
				<i class="fa-solid fa-note-sticky" style="color: #0284c7;"></i> Meeting Notes &amp; Action Items
			</h3>
			<% if (note != null) { %>
			<div class="notes-box">
				<strong style="color: #0284c7; font-size: 14px;">Discussion Summary:</strong>
				<p style="margin-top: 4px; line-height: 1.6; color: #334155;"><%=note.getSummary()%></p>
				<strong style="color: #0284c7; display: block; margin-top: 14px; font-size: 14px;">Action Items &amp; Key Decisions:</strong>
				<p style="margin-top: 4px; line-height: 1.6; color: #334155;"><%=note.getActionItems()%></p>
			</div>
			<% } else { %>
			<p style="color: #64748b; font-size: 14px;">No meeting notes recorded yet.</p>
			<% } %>

			<% if (Boolean.TRUE.equals(isOrganizerOrAdmin)) { %>
			<form action="uploadMeetingNotes" method="post" style="margin-top: 20px; border-top: 1px solid #f1f5f9; padding-top: 16px;">
				<input type="hidden" name="meetingId" value="<%=meeting.getMeetingId()%>" />
				<label style="font-size: 13px; font-weight: 700; color: #334155; margin-bottom: 6px; display: block;">Summary of Discussion</label>
				<textarea name="summary" placeholder="Summary of topics discussed..." rows="3"><%=note != null ? note.getSummary() : ""%></textarea>
				<label style="font-size: 13px; font-weight: 700; color: #334155; margin-bottom: 6px; display: block;">Action Items &amp; Follow-ups</label>
				<textarea name="actionItems" placeholder="Action items assigned..." rows="3"><%=note != null ? note.getActionItems() : ""%></textarea>
				<button type="submit" class="btn-save"><i class="fa-solid fa-cloud-arrow-up"></i> Save Meeting Notes</button>
			</form>
			<% } %>
		</div>

	</div>

</body>
</html>
