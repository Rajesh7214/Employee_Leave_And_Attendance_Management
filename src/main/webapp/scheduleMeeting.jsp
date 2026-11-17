<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.rajesh.elams.model.Employee"%>

<%
String role = (String) session.getAttribute("role");
if (role == null || (!"admin".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role))) {
	response.sendRedirect("viewMeetings");
	return;
}
String dashboardUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "managerDashboard";

List<Employee> employees = (List<Employee>) request.getAttribute("employees");
Map<String, List<Employee>> deptGroups = new LinkedHashMap<>();
if (employees != null) {
	for (Employee emp : employees) {
		String dept = (emp.getDepartment() != null && !emp.getDepartment().isBlank()) ? emp.getDepartment() : "General / Unassigned";
		deptGroups.computeIfAbsent(dept, k -> new ArrayList<>()).add(emp);
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Schedule Meeting - ELAMS</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background-color: #f5f5f5;
	color: #333;
}

.navbar {
	background: linear-gradient(135deg, #ee5a8a 0%, #d6336c 100%);
	color: white;
	padding: 15px 20px;
	text-align: center;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.navbar h1 {
	font-size: 24px;
	font-weight: bold;
}

.container {
	max-width: 850px;
	margin: 30px auto;
	padding: 0 20px;
}

.page-title {
	font-size: 28px;
	color: #2c3e50;
	margin-bottom: 10px;
	text-align: center;
}

.page-subtitle {
	font-size: 14px;
	color: #7f8c8d;
	text-align: center;
	margin-bottom: 30px;
}

.form-container {
	background-color: white;
	border: 2px solid #bdc3c7;
	border-radius: 8px;
	padding: 30px;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.form-row {
	display: flex;
	gap: 20px;
}

.form-row .form-group {
	flex: 1;
}

.form-group {
	margin-bottom: 20px;
}

.form-group label {
	display: block;
	font-weight: bold;
	color: #2c3e50;
	margin-bottom: 8px;
	font-size: 14px;
}

.required {
	color: #e74c3c;
}

.form-group input, .form-group select, .form-group textarea {
	width: 100%;
	padding: 10px 12px;
	border: 1px solid #bdc3c7;
	border-radius: 4px;
	font-size: 14px;
	font-family: inherit;
}

.form-group textarea {
	min-height: 90px;
	resize: vertical;
}

/* Enhanced Participant Selector Controls */
.global-select-bar {
	background: #f8fafc;
	border: 1px solid #e2e8f0;
	border-radius: 8px 8px 0 0;
	padding: 12px 16px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	font-size: 14px;
}

.select-all-label {
	display: flex;
	align-items: center;
	gap: 8px;
	font-weight: 700;
	color: #1e293b;
	cursor: pointer;
}

.select-all-label input {
	width: 18px;
	height: 18px;
	cursor: pointer;
}

.selection-counter {
	font-size: 13px;
	font-weight: 600;
	color: #d6336c;
	background: #fff0f5;
	padding: 4px 12px;
	border-radius: 20px;
	border: 1px solid #ffc1d9;
}

.group-search-bar {
	padding: 10px 14px;
	background: #ffffff;
	border-left: 1px solid #e2e8f0;
	border-right: 1px solid #e2e8f0;
	position: relative;
}

.group-search-bar input {
	width: 100%;
	padding: 9px 14px 9px 36px;
	border: 1px solid #cbd5e1;
	border-radius: 6px;
	font-size: 13px;
}

.group-search-bar i {
	position: absolute;
	left: 26px;
	top: 50%;
	transform: translateY(-50%);
	color: #94a3b8;
}

.participants-container {
	border: 1px solid #e2e8f0;
	border-radius: 0 0 8px 8px;
	max-height: 340px;
	overflow-y: auto;
	background: #fafafa;
}

.dept-group-card {
	border-bottom: 1px solid #e2e8f0;
}

.dept-group-card:last-child {
	border-bottom: none;
}

.dept-header {
	background: #f1f5f9;
	padding: 10px 16px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	font-weight: 700;
	color: #334155;
	font-size: 13px;
	border-bottom: 1px solid #e2e8f0;
}

.dept-title {
	display: flex;
	align-items: center;
	gap: 8px;
}

.dept-select-all {
	display: flex;
	align-items: center;
	gap: 6px;
	font-size: 12px;
	color: #d6336c;
	cursor: pointer;
	font-weight: 600;
}

.dept-select-all input {
	cursor: pointer;
	width: 15px;
	height: 15px;
}

.dept-employees-list {
	padding: 6px 16px;
	background: #ffffff;
}

/* Elegant Employee Item Styling */
.participant-item {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 10px 12px;
	border-bottom: 1px solid #f1f5f9;
	border-radius: 8px;
	margin-bottom: 4px;
	transition: background 0.15s ease;
}

.participant-item:hover {
	background: #f8fafc;
}

.participant-item:last-child {
	border-bottom: none;
}

.emp-info-wrapper {
	display: flex;
	align-items: center;
	gap: 12px;
	cursor: pointer;
	flex: 1;
}

.emp-avatar {
	width: 38px;
	height: 38px;
	border-radius: 50%;
	background: linear-gradient(135deg, #d6336c, #ee5a8a);
	color: white;
	display: flex;
	align-items: center;
	justify-content: center;
	font-weight: 700;
	font-size: 14px;
	flex-shrink: 0;
	box-shadow: 0 2px 6px rgba(214, 51, 108, 0.25);
}

.emp-details-text {
	display: flex;
	flex-direction: column;
	gap: 2px;
}

.emp-name-row {
	display: flex;
	align-items: center;
	gap: 8px;
}

.emp-name {
	font-size: 14px;
	font-weight: 700;
	color: #0f172a;
}

.emp-id-badge {
	font-size: 11px;
	background: #e2e8f0;
	color: #475569;
	padding: 2px 6px;
	border-radius: 4px;
	font-weight: 600;
}

.emp-meta-row {
	font-size: 12px;
	color: #64748b;
	display: flex;
	align-items: center;
	gap: 10px;
}

.emp-checkbox-input {
	width: 18px;
	height: 18px;
	cursor: pointer;
	accent-color: #d6336c;
}

.button-group {
	display: flex;
	gap: 10px;
	justify-content: center;
	margin-top: 30px;
}

.btn-submit {
	background-color: #27ae60;
	color: white;
	padding: 12px 30px;
	border: none;
	border-radius: 4px;
	font-size: 16px;
	font-weight: bold;
	cursor: pointer;
	flex: 1;
	max-width: 220px;
}

.btn-submit:hover {
	background-color: #229954;
}

.back-link {
	display: inline-block;
	margin-top: 20px;
	padding: 10px 24px;
	background-color: #ea4c79;
	color: white;
	border-radius: 30px;
	text-decoration: none;
	font-size: 14px;
	font-weight: bold;
}

.back-link:hover {
	background-color: #d6336c;
}

.alert {
	padding: 12px 15px;
	border-radius: 4px;
	margin-bottom: 20px;
	border-left: 4px solid;
}

.alert-error {
	background-color: #f8d7da;
	border-left-color: #e74c3c;
	color: #721c24;
}

footer {
	background: linear-gradient(135deg, #ee5a8a 0%, #d6336c 100%);
	color: white;
	text-align: center;
	padding: 20px;
	margin-top: 50px;
	font-size: 12px;
}
</style>
</head>
<body>

	<div class="navbar">
		<h1>ELAMS - Schedule Meeting</h1>
	</div>

	<div class="container">

		<h2 class="page-title">Schedule a Meeting</h2>
		<p class="page-subtitle">Organize group meetings and invite individual participants or department groups.</p>

		<%
		String errorMessage = (String) request.getAttribute("errorMessage");
		if (errorMessage != null) {
		%>
		<div class="alert alert-error">
			<i class="fas fa-exclamation-triangle"></i> <%=errorMessage%>
		</div>
		<%
		}
		%>

		<div class="form-container">
			<form action="scheduleMeeting" method="post">

				<!-- Auto-Generated Meeting ID -->
				<div class="form-group">
					<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
						<label for="meetingRefId" style="margin-bottom: 0; font-weight: 700; color: #334155;">Meeting ID <small style="font-weight: 600; color: #0284c7;">(Auto-generated)</small></label>
						<button type="button" onclick="generateMeetingId()" style="background: #e0f2fe; border: 1px solid #bae6fd; color: #0284c7; font-weight: 700; font-size: 12px; padding: 4px 10px; border-radius: 8px; cursor: pointer; transition: all 0.2s;">
							<i class="fa-solid fa-wand-magic-sparkles"></i> Auto-Generate New ID
						</button>
					</div>
					<div style="position: relative; display: flex; align-items: center;">
						<i class="fa-solid fa-hashtag" style="position: absolute; left: 14px; color: #0284c7; font-size: 14px;"></i>
						<input type="text" id="meetingRefId" readonly style="padding-left: 38px; font-weight: 700; color: #0284c7; background: #f8fafc; border: 1.8px solid #cbd5e1; border-radius: 8px; width: 100%; height: 42px;" />
					</div>
				</div>

				<div class="form-group">
					<label for="title">Meeting Title <span class="required">*</span></label>
					<input type="text" id="title" name="title" required
						placeholder="e.g. Q3 Department Strategy Discussion">
				</div>

				<div class="form-group">
					<label for="description">Description</label>
					<textarea id="description" name="description"
						placeholder="Brief overview of the meeting purpose"></textarea>
				</div>

				<div class="form-group">
					<label for="agenda">Agenda</label>
					<textarea id="agenda" name="agenda"
						placeholder="Topics to be discussed"></textarea>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="meetingDate">Date <span class="required">*</span></label>
						<input type="date" id="meetingDate" name="meetingDate" required>
					</div>
					<div class="form-group">
						<label for="startTime">Start Time <span class="required">*</span></label>
						<input type="time" id="startTime" name="startTime" required>
					</div>
					<div class="form-group">
						<label for="endTime">End Time <span class="required">*</span></label>
						<input type="time" id="endTime" name="endTime" required>
					</div>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="meetingType">Meeting Type <span class="required">*</span></label>
						<select id="meetingType" name="meetingType" required>
							<option value="Team Meeting">Team Meeting</option>
							<option value="Client Meeting">Client Meeting</option>
							<option value="Department Meeting">Department Meeting</option>
							<option value="HR Meeting">HR Meeting</option>
							<option value="Project Discussion">Project Discussion</option>
							<option value="Sprint Planning">Sprint Planning</option>
							<option value="Daily Standup">Daily Standup</option>
							<option value="Review Meeting">Review Meeting</option>
							<option value="Interview">Interview</option>
							<option value="Training Session">Training Session</option>
						</select>
					</div>
					<div class="form-group">
						<label for="meetingMode">Meeting Mode <span class="required">*</span></label>
						<select id="meetingMode" name="meetingMode" required onchange="toggleModeFields()">
							<option value="ONLINE">Online</option>
							<option value="OFFLINE">Offline</option>
							<option value="HYBRID">Hybrid</option>
						</select>
					</div>
					<div class="form-group">
						<label for="priority">Priority</label>
						<select id="priority" name="priority">
							<option value="Low">Low</option>
							<option value="Medium" selected>Medium</option>
							<option value="High">High</option>
						</select>
					</div>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="room">Meeting Room</label>
						<input type="text" id="room" name="room" placeholder="e.g. Conference Room A">
					</div>
					<div class="form-group">
						<label for="meetingLink">Join Link (if online)</label>
						<input type="text" id="meetingLink" name="meetingLink" placeholder="e.g. https://meet.example.com/xyz">
					</div>
				</div>

				<!-- Invite Participants Section -->
				<div class="form-group">
					<label><i class="fa-solid fa-user-plus"></i> Invite Participants</label>

					<!-- Global Toolbar -->
					<div class="global-select-bar">
						<label class="select-all-label">
							<input type="checkbox" id="globalSelectAll" onchange="toggleAllEmployees(this.checked)">
							<span>Select All Employees</span>
						</label>
						<span class="selection-counter" id="selectionCount">Selected: 0</span>
					</div>

					<!-- Search Bar -->
					<div class="group-search-bar">
						<i class="fa-solid fa-magnifying-glass"></i>
						<input type="text" id="participantSearch" onkeyup="filterParticipants()" placeholder="Search employee name or department...">
					</div>

					<!-- Group & Individual Employee List -->
					<div class="participants-container">
						<%
						if (!deptGroups.isEmpty()) {
							int groupIdx = 0;
							for (Map.Entry<String, List<Employee>> entry : deptGroups.entrySet()) {
								groupIdx++;
								String deptName = entry.getKey();
								List<Employee> groupEmps = entry.getValue();
						%>
						<div class="dept-group-card" id="groupCard_<%=groupIdx%>">
							<div class="dept-header">
								<div class="dept-title">
									<i class="fa-solid fa-folder-tree" style="color: #d6336c;"></i>
									<span>Group: <%=deptName%> (<%=groupEmps.size()%>)</span>
								</div>
								<label class="dept-select-all">
									<input type="checkbox" class="group-header-checkbox" onchange="toggleGroupCheckboxes(<%=groupIdx%>, this.checked)">
									Select Group
								</label>
							</div>

							<div class="dept-employees-list" id="groupList_<%=groupIdx%>">
								<%
								for (Employee emp : groupEmps) {
									String initial = (emp.getEmployee_name() != null && !emp.getEmployee_name().isEmpty())
											? emp.getEmployee_name().substring(0, 1).toUpperCase()
											: "E";
								%>
								<div class="participant-item">
									<label class="emp-info-wrapper" for="emp<%=emp.getEmployee_id()%>">
										<div class="emp-avatar"><%=initial%></div>
										<div class="emp-details-text">
											<div class="emp-name-row">
												<span class="emp-name"><%=emp.getEmployee_name()%></span>
												<span class="emp-id-badge">#<%=emp.getEmployee_id()%></span>
											</div>
											<div class="emp-meta-row">
												<span><i class="fa-solid fa-briefcase"></i> <%=emp.getDesignation() != null ? emp.getDesignation() : "Employee"%></span>
												<span>•</span>
												<span><i class="fa-solid fa-building"></i> <%=deptName%></span>
											</div>
										</div>
									</label>

									<input type="checkbox" name="participants"
										value="<%=emp.getEmployee_id()%>"
										class="emp-checkbox-input emp-checkbox group-checkbox-<%=groupIdx%>"
										id="emp<%=emp.getEmployee_id()%>"
										onchange="updateSelectionCounter()">
								</div>
								<%
								}
								%>
							</div>
						</div>
						<%
							}
						} else {
						%>
						<div style="padding: 20px; text-align: center; color: #888;">No employees available to invite.</div>
						<%
						}
						%>
					</div>
				</div>

				<div class="button-group">
					<button type="submit" class="btn-submit">Schedule Meeting</button>
				</div>

			</form>
		</div>

		<a href="<%=dashboardUrl%>" class="back-link">
			<i class="fas fa-arrow-left"></i> Back to Dashboard
		</a>

	</div>

	<footer>
		<p>&copy; 2026 ELAMS - Employee Leave &amp; Attendance Management System. All rights reserved.</p>
	</footer>

	<script>
		function toggleModeFields() {
			var mode = document.getElementById("meetingMode").value;
			var room = document.getElementById("room");
			var link = document.getElementById("meetingLink");
			if (mode === "ONLINE") {
				link.required = true;
				room.required = false;
			} else if (mode === "OFFLINE") {
				room.required = true;
				link.required = false;
			} else {
				room.required = true;
				link.required = true;
			}
		}
		toggleModeFields();

		// Toggle All Employees (Global Select All)
		function toggleAllEmployees(isChecked) {
			var checkboxes = document.querySelectorAll('.emp-checkbox');
			checkboxes.forEach(function(cb) {
				cb.checked = isChecked;
			});
			var groupCheckboxes = document.querySelectorAll('.group-header-checkbox');
			groupCheckboxes.forEach(function(gcb) {
				gcb.checked = isChecked;
			});
			updateSelectionCounter();
		}

		// Toggle Group Selection (Check/Uncheck group employees)
		function toggleGroupCheckboxes(groupIdx, isChecked) {
			var checkboxes = document.querySelectorAll('.group-checkbox-' + groupIdx);
			checkboxes.forEach(function(cb) {
				cb.checked = isChecked;
			});
			updateSelectionCounter();
		}

		// Update Selection Counter Badge
		function updateSelectionCounter() {
			var total = document.querySelectorAll('.emp-checkbox').length;
			var selected = document.querySelectorAll('.emp-checkbox:checked').length;
			document.getElementById('selectionCount').innerText = "Selected: " + selected + " of " + total;

			var globalCb = document.getElementById('globalSelectAll');
			if (globalCb) {
				globalCb.checked = (selected === total && total > 0);
			}
		}

		// Filter Participants by Name or Department
		function filterParticipants() {
			var input = document.getElementById("participantSearch").value.toLowerCase();
			var cards = document.querySelectorAll(".dept-group-card");

			cards.forEach(function(card) {
				var text = card.innerText.toLowerCase();
				if (text.indexOf(input) > -1) {
					card.style.display = "";
				} else {
					card.style.display = "none";
				}
			});
		}

		function generateMeetingId() {
			var rand = Math.floor(1000 + Math.random() * 9000);
			var year = new Date().getFullYear();
			document.getElementById("meetingRefId").value = "MTG-" + year + "-" + rand;
		}

		document.addEventListener("DOMContentLoaded", function() {
			updateSelectionCounter();
			generateMeetingId();
		});
	</script>

</body>
</html>
