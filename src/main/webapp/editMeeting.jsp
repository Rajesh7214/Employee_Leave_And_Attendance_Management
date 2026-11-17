<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="com.rajesh.elams.model.MeetingMode"%>
<%@ page import="com.rajesh.elams.model.MeetingStatus"%>

<%
User user = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");

boolean isAuthorized = user != null && role != null
		&& ("manager".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role));

if (!isAuthorized) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

Meeting meeting = (Meeting) request.getAttribute("meeting");
if (meeting == null) {
	response.sendRedirect("viewMeetings");
	return;
}

Employee loggedEmp = (Employee) session.getAttribute("employee");
String displayName = loggedEmp != null && loggedEmp.getEmployee_name() != null 
		? loggedEmp.getEmployee_name() 
		: (user.getEmail() != null ? user.getEmail().split("@")[0] : "Manager");
displayName = Character.toUpperCase(displayName.charAt(0)) + displayName.substring(1);

String profilePhoto = (loggedEmp != null && loggedEmp.getProfile_photo() != null && !loggedEmp.getProfile_photo().isBlank())
		? loggedEmp.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + displayName + "&background=0284c7&color=fff&bold=true";

String activePage = "meetings";

String startTimeFormatted = meeting.getStartTime() != null ? meeting.getStartTime().toString().substring(0, 5) : "09:00";
String endTimeFormatted = meeting.getEndTime() != null ? meeting.getEndTime().toString().substring(0, 5) : "10:00";
String currentModeStr = meeting.getMeetingMode() != null ? meeting.getMeetingMode().name() : "OFFLINE";
String currentStatusStr = meeting.getStatus() != null ? meeting.getStatus().name() : "SCHEDULED";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Edit Meeting | ELAMS</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css" />
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

/* ===== APP LAYOUT ===== */
.app-shell {
	display: flex;
	min-height: 100vh;
}

.main-wrapper {
	margin-left: 252px;
	width: calc(100% - 252px);
	display: flex;
	flex-direction: column;
	min-width: 0;
}

/* ===== TOPBAR ===== */
.topbar {
	height: 72px;
	background: #ffffff;
	padding: 0 32px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03), 0 0 0 1px rgba(226, 232, 240, 0.8);
	position: sticky;
	top: 0;
	z-index: 80;
}

.topbar-title h2 {
	font-size: 20px;
	font-weight: 800;
	color: #0f172a;
	letter-spacing: -0.5px;
}

.topbar-actions {
	display: flex;
	align-items: center;
	gap: 16px;
}

.profile-pill {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 5px 14px 5px 6px;
	background: #f8fafc;
	border: 1px solid #cbd5e1;
	border-radius: 30px;
	text-decoration: none;
	color: #0f172a;
	font-weight: 700;
	font-size: 13.5px;
	transition: all 0.2s;
}

.profile-pill:hover {
	background: #e0f2fe;
	border-color: #0284c7;
}

.avatar-img {
	width: 34px;
	height: 34px;
	border-radius: 50%;
	object-fit: cover;
}

/* ===== CONTENT BODY ===== */
.content-body {
	padding: 32px;
	flex: 1;
	max-width: 900px;
}

.breadcrumb-bar {
	display: flex;
	align-items: center;
	gap: 8px;
	font-size: 13.5px;
	color: #64748b;
	margin-bottom: 20px;
	font-weight: 600;
}

.breadcrumb-bar a {
	color: #0284c7;
	text-decoration: none;
}

.breadcrumb-bar a:hover {
	text-decoration: underline;
}

/* Form Container Card */
.form-card {
	background: #ffffff;
	border-radius: 22px;
	padding: 32px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	position: relative;
	overflow: hidden;
}

.form-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 5px;
	background: linear-gradient(90deg, #0284c7 0%, #38bdf8 100%);
}

.form-card-title {
	font-size: 20px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 24px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.form-card-title i {
	color: #0284c7;
}

.alert-error {
	background: #fef2f2;
	border: 1px solid #fecaca;
	color: #991b1b;
	padding: 14px 18px;
	border-radius: 14px;
	font-size: 13.5px;
	font-weight: 700;
	margin-bottom: 24px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.form-grid {
	display: grid;
	grid-template-columns: repeat(2, 1fr);
	gap: 20px;
}

.form-group-full {
	grid-column: span 2;
}

.form-group {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.form-group label {
	font-size: 13px;
	font-weight: 700;
	color: #334155;
}

.form-group label span {
	color: #ef4444;
}

.form-control {
	width: 100%;
	padding: 11px 14px;
	border-radius: 12px;
	border: 1px solid #cbd5e1;
	background: #f8fafc;
	font-size: 14px;
	color: #0f172a;
	font-weight: 600;
	outline: none;
	transition: all 0.2s ease;
}

.form-control:focus {
	border-color: #0284c7;
	background: #ffffff;
	box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
}

textarea.form-control {
	min-height: 85px;
	resize: vertical;
}

.section-divider {
	grid-column: span 2;
	height: 1px;
	background: #e2e8f0;
	margin: 10px 0;
}

.section-label {
	grid-column: span 2;
	font-size: 14px;
	font-weight: 800;
	color: #0284c7;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-top: 6px;
}

.btn-row {
	display: flex;
	align-items: center;
	justify-content: flex-end;
	gap: 14px;
	margin-top: 32px;
	padding-top: 20px;
	border-top: 1px solid #e2e8f0;
}

.btn {
	padding: 11px 24px;
	border-radius: 12px;
	font-size: 14px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	cursor: pointer;
	border: none;
	transition: all 0.2s ease;
}

.btn-primary {
	background: #0284c7;
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(2, 132, 199, 0.25);
}

.btn-primary:hover {
	background: #0369a1;
	transform: translateY(-2px);
}

.btn-secondary {
	background: #f1f5f9;
	color: #475569;
}

.btn-secondary:hover {
	background: #e2e8f0;
	color: #0f172a;
}

/* Footer */
footer {
	text-align: center;
	padding: 20px;
	color: #94a3b8;
	font-size: 13px;
	background: #ffffff;
	border-top: 1px solid #e2e8f0;
	margin-top: auto;
}

@media (max-width: 992px) {
	.main-wrapper { margin-left: 0; width: 100%; }
	.content-body { padding: 20px; }
	.form-grid { grid-template-columns: 1fr; }
	.form-group-full, .section-divider, .section-label { grid-column: span 1; }
}
</style>
</head>

<body>

	<div class="app-shell">

		<!-- Shared Sidebar Navigation -->
		<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

		<!-- Main Workspace Wrapper -->
		<div class="main-wrapper">

			<!-- Topbar Navigation -->
			<header class="topbar">
				<div class="topbar-title">
					<h2>Edit Meeting #<%=meeting.getMeetingId()%></h2>
				</div>

				<div class="topbar-actions">
					<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>

					<a href="managerProfile.jsp" class="profile-pill" title="View Profile">
						<img src="<%=profilePhoto%>" class="avatar-img" alt="<%=displayName%>" />
						<span><%=displayName%></span>
					</a>
				</div>
			</header>

			<!-- Content Body -->
			<div class="content-body">

				<!-- Breadcrumb -->
				<div class="breadcrumb-bar">
					<a href="viewMeetings">Meetings</a>
					<i class="fa-solid fa-chevron-right" style="font-size: 10px;"></i>
					<a href="meetingDetail?meetingId=<%=meeting.getMeetingId()%>">Meeting #<%=meeting.getMeetingId()%></a>
					<i class="fa-solid fa-chevron-right" style="font-size: 10px;"></i>
					<span>Edit Details</span>
				</div>

				<!-- Form Card -->
				<div class="form-card">
					<div class="form-card-title">
						<i class="fa-solid fa-pen-to-square"></i> Modify Scheduled Meeting
					</div>

					<%
					String errorMessage = (String) request.getAttribute("errorMessage");
					if (errorMessage != null && !errorMessage.isBlank()) {
					%>
						<div class="alert-error">
							<i class="fa-solid fa-circle-exclamation"></i>
							<span><%=errorMessage%></span>
						</div>
					<% } %>

					<form action="editMeeting" method="post" id="editMeetingForm">
						<input type="hidden" name="meetingId" value="<%=meeting.getMeetingId()%>" />

						<div class="form-grid">
							<!-- Section 1: Meeting Essentials -->
							<div class="section-label">📌 Meeting Essentials</div>

							<div class="form-group form-group-full">
								<label for="title">Meeting Title <span>*</span></label>
								<input type="text" id="title" name="title" class="form-control" 
									value="<%=meeting.getTitle() != null ? meeting.getTitle() : ""%>" 
									required maxlength="150" placeholder="e.g. Q3 Roadmap Review & Sprint Alignment" />
							</div>

							<div class="form-group">
								<label for="meetingType">Meeting Category</label>
								<select id="meetingType" name="meetingType" class="form-control">
									<%
									String[] types = { "Team Meeting", "Client Meeting", "Department Meeting", "HR Meeting", "Project Discussion",
											"Sprint Planning", "Daily Standup", "Review Meeting", "Interview", "Training Session" };
									for (String t : types) {
										String sel = t.equalsIgnoreCase(meeting.getMeetingType()) ? "selected" : "";
									%>
										<option value="<%=t%>" <%=sel%>><%=t%></option>
									<% } %>
								</select>
							</div>

							<div class="form-group">
								<label for="priority">Priority Level</label>
								<select id="priority" name="priority" class="form-control">
									<%
									String[] priorities = { "Low", "Medium", "High" };
									for (String pr : priorities) {
										String sel = pr.equalsIgnoreCase(meeting.getPriority()) ? "selected" : "";
									%>
										<option value="<%=pr%>" <%=sel%>><%=pr%></option>
									<% } %>
								</select>
							</div>

							<div class="form-group form-group-full">
								<label for="status">Meeting Lifecycle Status</label>
								<select id="status" name="status" class="form-control">
									<%
									String[] statuses = { "SCHEDULED", "PENDING_APPROVAL", "ONGOING", "COMPLETED", "CANCELLED", "POSTPONED" };
									for (String st : statuses) {
										String sel = st.equalsIgnoreCase(currentStatusStr) ? "selected" : "";
									%>
										<option value="<%=st%>" <%=sel%>><%=st.replace("_", " ")%></option>
									<% } %>
								</select>
							</div>

							<!-- Section 2: Date & Time -->
							<div class="section-divider"></div>
							<div class="section-label">⏰ Schedule &amp; Timings</div>

							<div class="form-group">
								<label for="meetingDate">Meeting Date <span>*</span></label>
								<input type="date" id="meetingDate" name="meetingDate" class="form-control" 
									value="<%=meeting.getMeetingDate() != null ? meeting.getMeetingDate().toString() : ""%>" required />
							</div>

							<div class="form-group" style="display: flex; gap: 10px;">
								<div style="flex: 1;">
									<label for="startTime">Start Time <span>*</span></label>
									<input type="time" id="startTime" name="startTime" class="form-control" 
										value="<%=startTimeFormatted%>" required />
								</div>
								<div style="flex: 1;">
									<label for="endTime">End Time <span>*</span></label>
									<input type="time" id="endTime" name="endTime" class="form-control" 
										value="<%=endTimeFormatted%>" required />
								</div>
							</div>

							<!-- Section 3: Venue & Link -->
							<div class="section-divider"></div>
							<div class="section-label">📍 Venue &amp; Location Mode</div>

							<div class="form-group form-group-full">
								<label for="meetingMode">Access Mode</label>
								<select id="meetingMode" name="meetingMode" class="form-control" onchange="toggleModeFields()">
									<%
									String[] modes = { "ONLINE", "OFFLINE", "HYBRID" };
									for (String md : modes) {
										String sel = md.equalsIgnoreCase(currentModeStr) ? "selected" : "";
									%>
										<option value="<%=md%>" <%=sel%>><%=md%></option>
									<% } %>
								</select>
							</div>

							<div class="form-group" id="roomGroup">
								<label for="room">Meeting Room / Location</label>
								<input type="text" id="room" name="room" class="form-control" 
									value="<%=meeting.getRoom() != null ? meeting.getRoom() : ""%>" 
									placeholder="e.g. Conference Room A / Boardroom 3" />
							</div>

							<div class="form-group" id="linkGroup">
								<label for="meetingLink">Video Call Link</label>
								<input type="url" id="meetingLink" name="meetingLink" class="form-control" 
									value="<%=meeting.getMeetingLink() != null ? meeting.getMeetingLink() : ""%>" 
									placeholder="https://meet.google.com/... or Zoom link" />
							</div>

							<!-- Section 4: Details & Agenda -->
							<div class="section-divider"></div>
							<div class="section-label">📝 Description &amp; Agenda</div>

							<div class="form-group form-group-full">
								<label for="description">Meeting Description</label>
								<textarea id="description" name="description" class="form-control" 
									placeholder="Provide brief context or goals for attendees..."><%=meeting.getDescription() != null ? meeting.getDescription() : ""%></textarea>
							</div>

							<div class="form-group form-group-full">
								<label for="agenda">Agenda Points</label>
								<textarea id="agenda" name="agenda" class="form-control" 
									placeholder="List specific discussion topics, key decisions, or presentation outline..."><%=meeting.getAgenda() != null ? meeting.getAgenda() : ""%></textarea>
							</div>
						</div>

						<div class="btn-row">
							<a href="meetingDetail?meetingId=<%=meeting.getMeetingId()%>" class="btn btn-secondary">
								<i class="fa-solid fa-xmark"></i> Cancel
							</a>
							<button type="submit" class="btn btn-primary">
								<i class="fa-solid fa-floppy-disk"></i> Save Changes
							</button>
						</div>
					</form>
				</div>

			</div>

			<!-- Footer -->
			<footer>
				&copy; 2026 ELAMS - Employee Leave &amp; Attendance Management System. All Rights Reserved.
			</footer>
		</div>
	</div>

	<script>
		function toggleModeFields() {
			const mode = document.getElementById('meetingMode').value;
			const roomGroup = document.getElementById('roomGroup');
			const linkGroup = document.getElementById('linkGroup');

			if (mode === 'ONLINE') {
				roomGroup.style.opacity = '0.5';
				linkGroup.style.opacity = '1';
			} else if (mode === 'OFFLINE') {
				roomGroup.style.opacity = '1';
				linkGroup.style.opacity = '0.5';
			} else {
				roomGroup.style.opacity = '1';
				linkGroup.style.opacity = '1';
			}
		}
		document.addEventListener('DOMContentLoaded', toggleModeFields);
	</script>
</body>
</html>
