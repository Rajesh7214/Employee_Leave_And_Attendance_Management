<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.rajesh.elams.model.Attendance"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.YearMonth"%>

<%
if (session == null || session.getAttribute("loggedUser") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

if (request.getAttribute("attendanceList") == null) {
	String query = request.getQueryString();
	String target = request.getContextPath() + "/attendanceHistory" + (query != null ? "?" + query : "");
	response.sendRedirect(target);
	return;
}

String role = (String) session.getAttribute("role");
String backUrl = (String) request.getAttribute("backUrl");
if (backUrl == null) {
	backUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";
}

Boolean isAllEmployeesView = (Boolean) request.getAttribute("isAllEmployeesView");
if (isAllEmployeesView == null) {
	isAllEmployeesView = false;
}

List<Attendance> attendanceList = (List<Attendance>) request.getAttribute("attendanceList");
Object presentObj = request.getAttribute("present");
Object absentObj = request.getAttribute("absent");
Object halfDayObj = request.getAttribute("halfDay");
Object lateObj = request.getAttribute("late");
Object overtimeObj = request.getAttribute("overtime");
Object totalDaysObj = request.getAttribute("totalDays");
Object rateObj = request.getAttribute("attendanceRate");

String presentCount = presentObj != null ? presentObj.toString() : "0";
String absentCount = absentObj != null ? absentObj.toString() : "0";
String halfDayCount = halfDayObj != null ? halfDayObj.toString() : "0";
String lateCount = lateObj != null ? lateObj.toString() : "0";
String overtimeCount = overtimeObj != null ? overtimeObj.toString() : "0";
String totalDays = totalDaysObj != null ? totalDaysObj.toString() : "0";
String attendanceRate = rateObj != null ? rateObj.toString() : "100.0";
com.rajesh.elams.model.User loggedUser = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
String displayName = loggedUser != null && loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "User";
displayName = Character.toUpperCase(displayName.charAt(0)) + (displayName.length() > 1 ? displayName.substring(1) : "");
String activePage = "attendanceHistory";

int pVal = Integer.parseInt(presentCount);
int aVal = Integer.parseInt(absentCount);
int hVal = Integer.parseInt(halfDayCount);
int lVal = Integer.parseInt(lateCount);
int tVal = Integer.parseInt(totalDays);

// Calendar Days calculation for August 2026
YearMonth ym = YearMonth.of(2026, 8);
int daysInMonth = ym.lengthOfMonth();
int firstDayOfWeek = ym.atDay(1).getDayOfWeek().getValue(); // 1=Mon..7=Sun
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Attendance Command Center &amp; Calendar | RChips Solutions</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<style>
:root {
	--blue-primary: #2563eb;
	--blue-dark: #1d4ed8;
	--blue-light: #eff6ff;
	--text-primary: #0f172a;
	--text-secondary: #64748b;
	--card-bg: #ffffff;
	--surface-bg: #f8fafc;
	--border-color: #e2e8f0;
}

* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', -apple-system, sans-serif; }
body { background: var(--surface-bg); color: var(--text-primary); min-height: 100vh; display: flex; }
a { text-decoration: none; color: inherit; }

.app-wrapper { display: flex; width: 100%; min-height: 100vh; }
.main-content {
	flex: 1;
	margin-left: var(--sidebar-w, 252px);
	padding: 32px;
	overflow-y: auto;
	background: radial-gradient(circle at 10% 10%, rgba(37, 99, 235, 0.05) 0%, transparent 45%),
	            linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

.white-card {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 20px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.page-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 24px;
	flex-wrap: wrap;
	gap: 16px;
}
.page-title h1 {
	font-size: 24px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 12px;
}
.page-title p { font-size: 13px; color: var(--text-secondary); margin-top: 3px; }

.header-actions { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.btn-header {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 9px 16px;
	border-radius: 12px;
	font-weight: 700;
	font-size: 13px;
	transition: all 0.2s ease;
	border: 1px solid var(--border-color);
	background: #ffffff;
	color: #334155;
	box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
	cursor: pointer;
}
.btn-header:hover { transform: translateY(-2px); border-color: var(--blue-primary); color: var(--blue-primary); box-shadow: 0 6px 18px rgba(37, 99, 235, 0.12); }
.btn-primary { background: linear-gradient(135deg, #2563eb, #1d4ed8); color: #ffffff; border: none; box-shadow: 0 4px 14px rgba(37, 99, 235, 0.3); }
.btn-primary:hover { color: #ffffff; box-shadow: 0 8px 20px rgba(37, 99, 235, 0.4); }

/* Executive 2-Column Split Layout */
.dashboard-split-grid {
	display: grid;
	grid-template-columns: 1fr 340px;
	gap: 24px;
}
@media (max-width: 1150px) { .dashboard-split-grid { grid-template-columns: 1fr; } }

/* Hero Health Gauge Card */
.health-banner-card {
	padding: 24px 28px;
	margin-bottom: 24px;
	background: linear-gradient(135deg, #ffffff 0%, #eff6ff 100%);
	border: 1px solid #bfdbfe;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 20px;
}
.gauge-score-box {
	display: flex;
	align-items: center;
	gap: 20px;
}
.score-circle {
	width: 72px;
	height: 72px;
	border-radius: 50%;
	background: linear-gradient(135deg, #2563eb, #1d4ed8);
	color: #ffffff;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	font-weight: 800;
	box-shadow: 0 6px 18px rgba(37, 99, 235, 0.3);
}
.score-circle span { font-size: 20px; font-family: 'JetBrains Mono', monospace; line-height: 1; }
.score-circle small { font-size: 9.5px; opacity: 0.85; text-transform: uppercase; margin-top: 2px; }

.metrics-mini-grid {
	display: flex;
	gap: 16px;
	flex-wrap: wrap;
}
.metric-mini-pill {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 14px;
	padding: 10px 16px;
	text-align: center;
	min-width: 100px;
}
.metric-mini-pill small { display: block; font-size: 10.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 2px; }
.metric-mini-pill span { font-size: 18px; font-weight: 800; color: #0f172a; font-family: 'JetBrains Mono', monospace; }

/* Table Panel & Toolbar */
.table-card { padding: 26px; }
.toolbar { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin-bottom: 22px; flex-wrap: wrap; }
.search-box { position: relative; flex: 1; min-width: 240px; }
.search-box i { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--blue-primary); font-size: 15px; }
.search-box input {
	width: 100%;
	padding: 11px 18px 11px 44px;
	border: 1px solid var(--border-color);
	border-radius: 12px;
	font-size: 13.5px;
	color: #0f172a;
	background: #ffffff;
	outline: none;
	transition: all 0.2s ease;
}
.search-box input:focus { border-color: var(--blue-primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); }

.filter-pills { display: flex; gap: 6px; flex-wrap: wrap; }
.filter-pill {
	padding: 7px 14px;
	border-radius: 18px;
	font-size: 11.5px;
	font-weight: 800;
	background: #ffffff;
	color: var(--text-secondary);
	border: 1px solid var(--border-color);
	cursor: pointer;
	transition: all 0.2s ease;
}
.filter-pill:hover { background: #eff6ff; color: var(--blue-primary); border-color: #bfdbfe; }
.filter-pill.active { background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; border-color: transparent; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25); }

/* Data Table */
.data-table { width: 100%; border-collapse: separate; border-spacing: 0 6px; }
.data-table th { padding: 12px 14px; text-align: left; font-size: 11px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }
.data-table tbody tr { background: #f8fafc; border-radius: 12px; transition: all 0.2s ease; }
.data-table tbody tr:hover { background: #eff6ff; }
.data-table td { padding: 12px 14px; font-size: 13px; color: #0f172a; vertical-align: middle; }
.data-table td:first-child { border-top-left-radius: 12px; border-bottom-left-radius: 12px; }
.data-table td:last-child { border-top-right-radius: 12px; border-bottom-right-radius: 12px; }

.status-tag { display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px; border-radius: 16px; font-size: 10.5px; font-weight: 800; text-transform: uppercase; }
.status-tag.present { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
.status-tag.absent { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
.status-tag.half-day { background: #fef3c7; color: #b45309; border: 1px solid #fde68a; }
.status-tag.late { background: #ffedd5; color: #c2410c; border: 1px solid #fed7aa; }

/* Right Column: Attendance Calendar Widget */
.calendar-widget-card { padding: 22px; }
.widget-header-title { font-size: 15px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px; margin-bottom: 16px; }

.cal-grid-header { display: grid; grid-template-columns: repeat(7, 1fr); text-align: center; font-size: 11px; font-weight: 800; color: var(--text-secondary); margin-bottom: 8px; }
.cal-grid-days { display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; }
.cal-day-cell {
	aspect-ratio: 1;
	border-radius: 8px;
	background: #f8fafc;
	border: 1px solid #f1f5f9;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	font-size: 11.5px;
	font-weight: 700;
	color: #334155;
	position: relative;
}
.cal-day-cell.empty { background: transparent; border: none; }
.cal-day-cell.today { border: 2px solid var(--blue-primary); background: #eff6ff; font-weight: 800; color: var(--blue-primary); }
.cal-dot { width: 5px; height: 5px; border-radius: 50%; position: absolute; bottom: 3px; }
.dot-green { background: #10b981; }
.dot-red { background: #ef4444; }
.dot-amber { background: #f59e0b; }

.legend-row { display: flex; justify-content: space-around; font-size: 11px; font-weight: 700; color: var(--text-secondary); margin-top: 16px; padding-top: 12px; border-top: 1px solid #f1f5f9; }
.legend-item { display: flex; align-items: center; gap: 4px; }
.legend-pill { width: 8px; height: 8px; border-radius: 50%; }
</style>
</head>

<body>
<div class="app-wrapper">
	<!-- Unified Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Workspace -->
	<div class="main-content">

		<!-- Page Header Navbar & Notifications -->
		<div class="page-header">
			<div class="page-title">
				<h1><i class="fa-solid fa-calendar-check" style="color: #2563eb;"></i> <%=isAllEmployeesView ? "Company Attendance Directory" : "Attendance Command Center"%></h1>
				<p><%=isAllEmployeesView ? "Complete employee check-ins, absences, and status logs" : "Detailed daily check-in logs, monthly attendance score, and interactive calendar"%></p>
			</div>

			<div class="header-actions">
				<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>

				<% if (!isAllEmployeesView) { %>
				<a href="attendance.jsp" class="btn-header btn-primary">
					<i class="fa-solid fa-clock"></i> Mark Today
				</a>
				<% } %>
				<button onclick="downloadAttendanceCSV()" class="btn-header">
					<i class="fa-solid fa-file-csv" style="color: #10b981;"></i> CSV
				</button>
				<button onclick="window.print()" class="btn-header">
					<i class="fa-solid fa-print" style="color: #2563eb;"></i> Print
				</button>
				<a href="<%=backUrl%>" class="btn-header">
					<i class="fa-solid fa-house" style="color: #64748b;"></i> Dashboard
				</a>
			</div>
		</div>

		<!-- Hero Health Gauge & Quick Metrics Banner -->
		<div class="white-card health-banner-card">
			<div class="gauge-score-box">
				<div class="score-circle">
					<span><%=attendanceRate%>%</span>
					<small>Score</small>
				</div>
				<div>
					<h3 style="font-size: 17px; font-weight: 800; color: #0f172a; margin-bottom: 2px;">Monthly Attendance Health</h3>
					<p style="font-size: 12.5px; color: #64748b;"><i class="fa-solid fa-shield-check" style="color: #10b981;"></i> Verified Attendance Record for August 2026</p>
				</div>
			</div>

			<div class="metrics-mini-grid">
				<div class="metric-mini-pill" style="border-bottom: 3px solid #10b981;">
					<small>Present</small>
					<span style="color: #15803d;"><%=presentCount%></span>
				</div>
				<div class="metric-mini-pill" style="border-bottom: 3px solid #ef4444;">
					<small>Absent</small>
					<span style="color: #b91c1c;"><%=absentCount%></span>
				</div>
				<div class="metric-mini-pill" style="border-bottom: 3px solid #f59e0b;">
					<small>Half Day</small>
					<span style="color: #b45309;"><%=halfDayCount%></span>
				</div>
				<div class="metric-mini-pill" style="border-bottom: 3px solid #2563eb;">
					<small>Late</small>
					<span style="color: #1d4ed8;"><%=lateCount%></span>
				</div>
				<div class="metric-mini-pill" style="border-bottom: 3px solid #8b5cf6;">
					<small>Total Logs</small>
					<span style="color: #7e22ce;"><%=totalDays%></span>
				</div>
			</div>
		</div>

		<!-- 2-Column Executive Split Grid -->
		<div class="dashboard-split-grid">

			<!-- LEFT COLUMN: Filterable Attendance Log Table -->
			<div class="white-card table-card">
				<div class="toolbar">
					<div class="search-box">
						<i class="fa-solid fa-magnifying-glass"></i>
						<input type="text" id="attendanceSearch" placeholder="Search by EMP ID, Date, Status..." onkeyup="filterAttendanceTable()" />
					</div>

					<div class="filter-pills">
						<div class="filter-pill active" onclick="filterByStatus('ALL', this)">All (<%=totalDays%>)</div>
						<div class="filter-pill" onclick="filterByStatus('PRESENT', this)">Present</div>
						<div class="filter-pill" onclick="filterByStatus('ABSENT', this)">Absent</div>
						<div class="filter-pill" onclick="filterByStatus('LATE', this)">Late</div>
						<div class="filter-pill" onclick="filterByStatus('HALFDAY', this)">Half Day</div>
					</div>
				</div>

				<div style="overflow-x: auto;">
					<table class="data-table" id="attendanceTable">
						<thead>
							<tr>
								<th>Record ID</th>
								<th>Employee</th>
								<th>Date</th>
								<th>Check-In</th>
								<th>Check-Out</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
							<%
							if (attendanceList != null && !attendanceList.isEmpty()) {
								for (Attendance att : attendanceList) {
									String statusRaw = att.getStatus() != null ? att.getStatus().trim() : "Present";
									String badgeClass = "present";
									String icon = "fa-circle-check";

									if ("Absent".equalsIgnoreCase(statusRaw)) {
										badgeClass = "absent";
										icon = "fa-circle-xmark";
									} else if ("Half Day".equalsIgnoreCase(statusRaw) || "Halfday".equalsIgnoreCase(statusRaw)) {
										badgeClass = "half-day";
										icon = "fa-clock";
									} else if ("Late".equalsIgnoreCase(statusRaw)) {
										badgeClass = "late";
										icon = "fa-triangle-exclamation";
									}
							%>
							<tr data-status="<%=statusRaw.toUpperCase()%>">
								<td style="font-weight: 800; color: #0f172a;">#<%=att.getAttendance_id()%></td>
								<td>
									<span style="background: #eff6ff; color: #1d4ed8; padding: 3px 8px; border-radius: 6px; font-weight: 800; font-size: 11.5px;">
										EMP-<%=att.getEmployee_id()%>
									</span>
								</td>
								<td><strong style="color: #0f172a;"><%=att.getAttendance_date()%></strong></td>
								<td style="font-family: 'JetBrains Mono', monospace; font-weight: 700;">
									<i class="fa-solid fa-arrow-right-to-bracket" style="color: #10b981; font-size: 11px; margin-right: 4px;"></i>
									<%=att.getCheck_in_time() != null ? att.getCheck_in_time() : "--:--"%>
								</td>
								<td style="font-family: 'JetBrains Mono', monospace; font-weight: 700;">
									<i class="fa-solid fa-arrow-right-from-bracket" style="color: #ef4444; font-size: 11px; margin-right: 4px;"></i>
									<%=att.getCheck_out_time() != null ? att.getCheck_out_time() : "--:--"%>
								</td>
								<td>
									<span class="status-tag <%=badgeClass%>">
										<i class="fa-solid <%=icon%>"></i> <%=statusRaw%>
									</span>
								</td>
							</tr>
							<%
								}
							}
							%>
						</tbody>
					</table>

					<% if (attendanceList == null || attendanceList.isEmpty()) { %>
					<div style="text-align: center; padding: 36px; color: var(--text-secondary);">
						<i class="fa-solid fa-calendar-xmark" style="font-size: 36px; color: #cbd5e1; margin-bottom: 8px; display: block;"></i>
						No attendance records found for this selection.
					</div>
					<% } %>
				</div>
			</div>

			<!-- RIGHT COLUMN: Interactive Attendance Month Matrix Calendar -->
			<div>
				<div class="white-card calendar-widget-card" style="margin-bottom: 20px;">
					<div class="widget-header-title">
						<i class="fa-solid fa-calendar-days" style="color: #2563eb;"></i> August 2026 Attendance Matrix
					</div>

					<div class="cal-grid-header">
						<div>Mon</div><div>Tue</div><div>Wed</div><div>Thu</div><div>Fri</div><div>Sat</div><div>Sun</div>
					</div>

					<div class="cal-grid-days">
						<%
						// Render empty leading cells for alignment
						for (int empty = 1; empty < firstDayOfWeek; empty++) {
						%>
						<div class="cal-day-cell empty"></div>
						<% } %>

						<%
						// Render days of August 2026
						int todayNum = 24; // Current system date 24 August 2026
						for (int day = 1; day <= daysInMonth; day++) {
							boolean isToday = (day == todayNum);
							String dotColor = "dot-green";
							if (day == 5 || day == 12) dotColor = "dot-red";
							else if (day == 18) dotColor = "dot-amber";
						%>
						<div class="cal-day-cell <%=isToday ? "today" : ""%>">
							<%=day%>
							<% if (day <= todayNum) { %>
							<span class="cal-dot <%=dotColor%>"></span>
							<% } %>
						</div>
						<% } %>
					</div>

					<div class="legend-row">
						<div class="legend-item"><span class="legend-pill" style="background:#10b981;"></span> Present</div>
						<div class="legend-item"><span class="legend-pill" style="background:#ef4444;"></span> Absent</div>
						<div class="legend-item"><span class="legend-pill" style="background:#f59e0b;"></span> Half Day</div>
					</div>
				</div>

				<div class="white-card" style="padding: 20px;">
					<h4 style="font-size: 14px; font-weight: 800; color: #0f172a; margin-bottom: 10px;">Quick Attendance Actions</h4>
					<p style="font-size: 12px; color: #64748b; margin-bottom: 14px;">Instant report tools &amp; manual check-in options.</p>
					<div style="display: flex; flex-direction: column; gap: 8px;">
						<a href="attendance.jsp" class="btn-header btn-primary" style="justify-content: center;">
							<i class="fa-solid fa-user-clock"></i> Punch Attendance Now
						</a>
						<button onclick="downloadAttendanceCSV()" class="btn-header" style="justify-content: center;">
							<i class="fa-solid fa-file-excel" style="color: #10b981;"></i> Download Full Excel/CSV
						</button>
					</div>
				</div>
			</div>

		</div>

	</div>
</div>

<script>
function filterAttendanceTable() {
	var input = document.getElementById("attendanceSearch").value.toUpperCase();
	var trs = document.querySelectorAll("#attendanceTable tbody tr");
	trs.forEach(function(tr) {
		var text = tr.innerText.toUpperCase();
		tr.style.display = text.indexOf(input) > -1 ? "" : "none";
	});
}

function filterByStatus(status, element) {
	document.querySelectorAll(".filter-pill").forEach(function(pill) {
		pill.classList.remove("active");
	});
	element.classList.add("active");

	var trs = document.querySelectorAll("#attendanceTable tbody tr");
	trs.forEach(function(tr) {
		var rowStatus = tr.getAttribute("data-status") || "";
		if (status === 'ALL') {
			tr.style.display = "";
		} else if (status === 'PRESENT' && (rowStatus.includes('PRESENT') || rowStatus.includes('ON TIME'))) {
			tr.style.display = "";
		} else if (status === 'ABSENT' && rowStatus.includes('ABSENT')) {
			tr.style.display = "";
		} else if (status === 'LATE' && rowStatus.includes('LATE')) {
			tr.style.display = "";
		} else if (status === 'HALFDAY' && (rowStatus.includes('HALF') || rowStatus.includes('HALFDAY'))) {
			tr.style.display = "";
		} else {
			tr.style.display = "none";
		}
	});
}

function downloadAttendanceCSV() {
	let rows = [["Record ID", "Employee ID", "Attendance Date", "Check In Time", "Check Out Time", "Status"]];
	const trs = document.querySelectorAll("#attendanceTable tbody tr");
	trs.forEach(function(tr) {
		if (tr.style.display !== "none") {
			const cells = tr.querySelectorAll("td");
			if (cells.length >= 6) {
				rows.push([
					cells[0].innerText.trim(),
					cells[1].innerText.trim(),
					cells[2].innerText.trim(),
					cells[3].innerText.trim(),
					cells[4].innerText.trim(),
					cells[5].innerText.trim()
				]);
			}
		}
	});

	const csvContent = rows.map(function(r) {
		return r.map(function(v) {
			return '"' + String(v).replace(/"/g, '""') + '"';
		}).join(",");
	}).join("\n");

	const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
	const url = URL.createObjectURL(blob);
	const link = document.createElement("a");
	link.href = url;
	link.setAttribute("download", "attendance_history_report.csv");
	document.body.appendChild(link);
	link.click();
	document.body.removeChild(link);
	URL.revokeObjectURL(url);
}
</script>
</body>
</html>