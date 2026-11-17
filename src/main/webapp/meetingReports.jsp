<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="com.rajesh.elams.model.EmployeeMeetingCount"%>
<%@ page import="com.rajesh.elams.model.DepartmentMeetingCount"%>
<%@ page import="com.rajesh.elams.model.MeetingTypeDuration"%>
<%@ page import="com.rajesh.elams.model.MeetingAttendanceSummary"%>

<%
String range = (String) request.getAttribute("range");
String fromDate = (String) request.getAttribute("fromDate");
String toDate = (String) request.getAttribute("toDate");

List<Meeting> rangeMeetings = (List<Meeting>) request.getAttribute("rangeMeetings");
List<Meeting> missedMeetings = (List<Meeting>) request.getAttribute("missedMeetings");
List<EmployeeMeetingCount> employeeWiseCounts = (List<EmployeeMeetingCount>) request.getAttribute("employeeWiseCounts");
List<DepartmentMeetingCount> departmentWiseCounts = (List<DepartmentMeetingCount>) request
		.getAttribute("departmentWiseCounts");
List<MeetingTypeDuration> durationAnalysis = (List<MeetingTypeDuration>) request.getAttribute("durationAnalysis");
MeetingAttendanceSummary attendanceSummary = (MeetingAttendanceSummary) request.getAttribute("attendanceSummary");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Meeting Report | ELAMS</title>

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
	max-width: 1200px;
	margin: 30px auto;
}

h2 {
	text-align: center;
	color: #d6336c;
	margin-bottom: 5px;
}

.subtitle {
	text-align: center;
	color: #777;
	margin-bottom: 25px;
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

.summary-cards {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
	gap: 18px;
	margin-bottom: 25px;
}

.summary-card {
	background: white;
	border-radius: 10px;
	padding: 18px;
	box-shadow: 0 0 12px rgba(0, 0, 0, .08);
	text-align: center;
	border-top: 5px solid #d6336c;
}

.summary-card .num {
	font-size: 32px;
	font-weight: bold;
	color: #333;
}

.summary-card .label {
	color: #777;
	font-size: 13px;
	margin-top: 5px;
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
	display: flex;
	align-items: center;
	gap: 8px;
}

.two-col {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
}

@media ( max-width : 800px) {
	.two-col {
		grid-template-columns: 1fr;
	}
}

.filter-bar {
	display: flex;
	flex-wrap: wrap;
	gap: 12px;
	align-items: end;
	margin-bottom: 10px;
}

.filter-bar .field {
	display: flex;
	flex-direction: column;
	font-size: 12px;
	color: #555;
}

.filter-bar select, .filter-bar input {
	margin-top: 6px;
	padding: 8px;
	border: 1px solid #ccc;
	border-radius: 6px;
}

.btn {
	background: #d6336c;
	color: white;
	border: none;
	padding: 9px 16px;
	border-radius: 6px;
	font-weight: bold;
	cursor: pointer;
}

.btn:hover {
	background: #b81f57;
}

table {
	width: 100%;
	border-collapse: collapse;
}

th {
	background: #d6336c;
	color: white;
	padding: 8px;
	text-align: left;
	font-size: 13px;
}

td {
	padding: 8px;
	border-bottom: 1px solid #eee;
	font-size: 13px;
}

.badge {
	padding: 3px 9px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: bold;
	color: white;
	background: #495057;
}

.SCHEDULED {
	background: #1971c2;
}

.ONGOING {
	background: #f08c00;
}

.COMPLETED {
	background: #2f9e44;
}

.CANCELLED {
	background: #e03131;
}

.POSTPONED {
	background: #868e96;
}

.PENDING_APPROVAL {
	background: #9c36b5;
}

.empty-note {
	color: #999;
	font-style: italic;
	padding: 10px 0;
}

.attendance-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
	gap: 12px;
	text-align: center;
}

.attendance-grid div {
	background: #f8f9fa;
	border-radius: 8px;
	padding: 12px 6px;
}

.attendance-grid .num {
	font-size: 22px;
	font-weight: bold;
	color: #333;
}

.attendance-grid .label {
	font-size: 12px;
	color: #777;
}
</style>

</head>
<body>

	<div class="container">

		<h2>
			<i class="fa-solid fa-chart-column"></i> Meeting Reports
		</h2>
		<p class="subtitle">Admin analytics for the Meeting Management
			Module (section 11).</p>

		<%
		String userRole = (String) session.getAttribute("role");
		String backDashUrl = "admin".equalsIgnoreCase(userRole) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(userRole) ? "hrDashboard" : "managerDashboard";
		%>
		<div class="top-links">
			<a href="<%=backDashUrl%>"><i class="fa-solid fa-house"></i>
				Dashboard</a> <a href="viewMeetings"><i
				class="fa-solid fa-camera-video"></i> All Meetings </a> <a
				href="manageMeetingRooms"><i class="fa-solid fa-door-open"></i>
				Meeting Rooms</a>
		</div>

		<!-- ================= SUMMARY CARDS ================= -->
		<div class="summary-cards">
			<div class="summary-card">
				<div class="num">${totalMeetings}</div>
				<div class="label">Total Meetings</div>
			</div>
			<div class="summary-card">
				<div class="num">${upcomingMeetings}</div>
				<div class="label">Upcoming</div>
			</div>
			<div class="summary-card">
				<div class="num">${completedMeetings}</div>
				<div class="label">Completed</div>
			</div>
			<div class="summary-card">
				<div class="num">${cancelledMeetings}</div>
				<div class="label">Cancelled</div>
			</div>
			<div class="summary-card">
				<div class="num"><%=missedMeetings == null ? 0 : missedMeetings.size()%></div>
				<div class="label">Missed Meetings</div>
			</div>
		</div>

		<!-- ================= DAILY / WEEKLY / MONTHLY MEETINGS ================= -->
		<div class="card">
			<h3>
				<i class="fa-solid fa-calendar-days"></i> Meetings by Date Range
			</h3>

			<form class="filter-bar" action="meetingReports" method="get">
				<div class="field">
					Quick Range <select name="range" onchange="this.form.submit()">
						<option value="daily" <%="daily".equals(range) ? "selected" : ""%>>Daily
							(Today)</option>
						<option value="weekly"
							<%="weekly".equals(range) ? "selected" : ""%>>Weekly
							(Last 7 days)</option>
						<option value="monthly"
							<%="monthly".equals(range) ? "selected" : ""%>>Monthly
							(Last 30 days)</option>
						<option value="custom"
							<%="custom".equals(range) ? "selected" : ""%>>Custom</option>
					</select>
				</div>
				<div class="field">
					From <input type="date" name="fromDate" value="<%=fromDate%>">
				</div>
				<div class="field">
					To <input type="date" name="toDate" value="<%=toDate%>">
				</div>
				<div class="field">
					<button type="submit" class="btn">Apply</button>
				</div>
			</form>

			<table>
				<tr>
					<th>Title</th>
					<th>Organizer</th>
					<th>Date</th>
					<th>Time</th>
					<th>Type</th>
					<th>Status</th>
				</tr>
				<%
				if (rangeMeetings != null && !rangeMeetings.isEmpty()) {
					for (Meeting m : rangeMeetings) {
				%>
				<tr>
					<td><a href="meetingDetail?meetingId=<%=m.getMeetingId()%>"><%=m.getTitle()%></a></td>
					<td><%=m.getOrganizerName()%></td>
					<td><%=m.getMeetingDate()%></td>
					<td><%=m.getStartTime()%> - <%=m.getEndTime()%></td>
					<td><%=m.getMeetingType() == null ? "-" : m.getMeetingType()%></td>
					<td><span class="badge <%=m.getStatus().name()%>"><%=m.getStatus().name()%></span></td>
				</tr>
				<%
				}
				} else {
				%>
				<tr>
					<td colspan="6" class="empty-note">No meetings scheduled in
						this date range.</td>
				</tr>
				<%
				}
				%>
			</table>
		</div>

		<div class="two-col">

			<!-- ================= EMPLOYEE-WISE ================= -->
			<div class="card">
				<h3>
					<i class="fa-solid fa-user"></i> Employee-wise Meetings
				</h3>
				<table>
					<tr>
						<th>Employee</th>
						<th>Department</th>
						<th>Meetings</th>
					</tr>
					<%
					if (employeeWiseCounts != null && !employeeWiseCounts.isEmpty()) {
						for (EmployeeMeetingCount e : employeeWiseCounts) {
					%>
					<tr>
						<td><%=e.getEmployeeName()%></td>
						<td><%=e.getDepartment() == null ? "-" : e.getDepartment()%></td>
						<td><%=e.getMeetingCount()%></td>
					</tr>
					<%
					}
					} else {
					%>
					<tr>
						<td colspan="3" class="empty-note">No data available.</td>
					</tr>
					<%
					}
					%>
				</table>
			</div>

			<!-- ================= DEPARTMENT-WISE ================= -->
			<div class="card">
				<h3>
					<i class="fa-solid fa-building"></i> Department-wise Meetings
				</h3>
				<table>
					<tr>
						<th>Department</th>
						<th>Meetings</th>
					</tr>
					<%
					if (departmentWiseCounts != null && !departmentWiseCounts.isEmpty()) {
						for (DepartmentMeetingCount d : departmentWiseCounts) {
					%>
					<tr>
						<td><%=d.getDepartment()%></td>
						<td><%=d.getMeetingCount()%></td>
					</tr>
					<%
					}
					} else {
					%>
					<tr>
						<td colspan="2" class="empty-note">No data available.</td>
					</tr>
					<%
					}
					%>
				</table>
			</div>
		</div>

		<div class="two-col">

			<!-- ================= ATTENDANCE REPORT ================= -->
			<div class="card">
				<h3>
					<i class="fa-solid fa-clipboard-check"></i> Attendance Report
				</h3>
				<%
				if (attendanceSummary != null && attendanceSummary.getTotal() > 0) {
				%>
				<div class="attendance-grid">
					<div>
						<div class="num"><%=attendanceSummary.getPresent()%></div>
						<div class="label">Present</div>
					</div>
					<div>
						<div class="num"><%=attendanceSummary.getAbsent()%></div>
						<div class="label">Absent</div>
					</div>
					<div>
						<div class="num"><%=attendanceSummary.getLate()%></div>
						<div class="label">Late</div>
					</div>
					<div>
						<div class="num"><%=attendanceSummary.getExcused()%></div>
						<div class="label">Excused</div>
					</div>
					<div>
						<div class="num"><%=attendanceSummary.getNotMarked()%></div>
						<div class="label">Not Marked</div>
					</div>
				</div>
				<%
				} else {
				%>
				<p class="empty-note">No attendance has been recorded yet.</p>
				<%
				}
				%>
			</div>

			<!-- ================= DURATION ANALYSIS ================= -->
			<div class="card">
				<h3>
					<i class="fa-solid fa-stopwatch"></i> Meeting Duration Analysis
				</h3>
				<table>
					<tr>
						<th>Meeting Type</th>
						<th>Count</th>
						<th>Avg Duration</th>
					</tr>
					<%
					if (durationAnalysis != null && !durationAnalysis.isEmpty()) {
						for (MeetingTypeDuration d : durationAnalysis) {
					%>
					<tr>
						<td><%=d.getMeetingType()%></td>
						<td><%=d.getMeetingCount()%></td>
						<td><%=Math.round(d.getAvgDurationMinutes())%> min</td>
					</tr>
					<%
					}
					} else {
					%>
					<tr>
						<td colspan="3" class="empty-note">No data available.</td>
					</tr>
					<%
					}
					%>
				</table>
			</div>
		</div>

		<!-- ================= MISSED MEETINGS ================= -->
		<div class="card">
			<h3>
				<i class="fa-solid fa-calendar-xmark"></i> Missed Meetings
			</h3>
			<p style="color: #777; font-size: 13px; margin-top: -8px;">Meetings
				whose date has passed but were never marked Ongoing, Completed,
				Cancelled, or Postponed.</p>
			<table>
				<tr>
					<th>Title</th>
					<th>Organizer</th>
					<th>Date</th>
					<th>Time</th>
				</tr>
				<%
				if (missedMeetings != null && !missedMeetings.isEmpty()) {
					for (Meeting m : missedMeetings) {
				%>
				<tr>
					<td><a href="meetingDetail?meetingId=<%=m.getMeetingId()%>"><%=m.getTitle()%></a></td>
					<td><%=m.getOrganizerName()%></td>
					<td><%=m.getMeetingDate()%></td>
					<td><%=m.getStartTime()%> - <%=m.getEndTime()%></td>
				</tr>
				<%
				}
				} else {
				%>
				<tr>
					<td colspan="4" class="empty-note">No missed meetings. 🎉</td>
				</tr>
				<%
				}
				%>
			</table>
		</div>

		<!-- ================= DOWNLOAD REPORT SECTION (BOTTOM) ================= -->
		<div style="margin-top: 25px; margin-bottom: 25px; text-align: center; padding: 22px; background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.06);">
			<a href="exportMeetingReport?range=<%=range%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>" style="background:#0284c7; color:white; padding:14px 28px; border-radius:12px; font-weight:bold; text-decoration:none; display:inline-flex; align-items:center; gap:10px; font-size:15px; box-shadow: 0 4px 14px rgba(2,132,199,0.3); transition: transform 0.15s ease;">
				<i class="fa-solid fa-file-csv" style="font-size:20px;"></i> Download Report
			</a>
		</div>

	</div>

</body>
</html>
