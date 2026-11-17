<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Attendance"%>
<%@ page import="com.rajesh.elams.dao.AttendanceDao"%>
<%@ page import="com.rajesh.elams.dao.AttendanceDaoImpl"%>
<%@ page import="java.util.List"%>
<%
Employee employee = (Employee) session.getAttribute("employee");
if (employee == null) {
	com.rajesh.elams.model.User user = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
	if (user != null) {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(user.getEmail());
		if (employee != null) {
			session.setAttribute("employee", employee);
			session.setAttribute("employeeId", employee.getEmployee_id());
		}
	}
}

if (employee == null) {
	response.sendRedirect("login.jsp");
	return;
}

String role = (String) session.getAttribute("role");
String dashboardUrl = "employeeDashboardServlet";
if ("admin".equalsIgnoreCase(role)) {
	dashboardUrl = "adminDashboardServlet";
} else if ("hr".equalsIgnoreCase(role)) {
	dashboardUrl = "hrDashboard";
} else if ("manager".equalsIgnoreCase(role)) {
	dashboardUrl = "managerDashboard";
}

AttendanceDao attendanceDao = new AttendanceDaoImpl();
java.sql.Date today = java.sql.Date.valueOf(java.time.LocalDate.now());

Attendance todayAttendance = null;
List<Attendance> records = attendanceDao.getAttendanceByEmployee(employee.getEmployee_id());
if (records != null) {
	for (Attendance a : records) {
		if (a.getAttendance_date() != null && a.getAttendance_date().toString().equals(today.toString())) {
			todayAttendance = a;
			break;
		}
	}
}

String checkInTimeStr = "";
String checkOutTimeStr = "";
String breakStartStr = "";
String breakEndStr = "";
int breakMinutes = 0;

if (todayAttendance != null) {
	if (todayAttendance.getCheck_in_time() != null)
		checkInTimeStr = todayAttendance.getCheck_in_time().toString();
	if (todayAttendance.getCheck_out_time() != null)
		checkOutTimeStr = todayAttendance.getCheck_out_time().toString();
	if (todayAttendance.getBreak_start_time() != null)
		breakStartStr = todayAttendance.getBreak_start_time().toString();
	if (todayAttendance.getBreak_end_time() != null)
		breakEndStr = todayAttendance.getBreak_end_time().toString();
	breakMinutes = todayAttendance.getTotal_break_minutes();
}

boolean hasCheckedIn = !checkInTimeStr.isEmpty();
boolean hasCheckedOut = !checkOutTimeStr.isEmpty();
boolean isOnBreak = hasCheckedIn && !hasCheckedOut && !breakStartStr.isEmpty() && breakEndStr.isEmpty();
boolean hasCompletedBreak = !breakStartStr.isEmpty() && !breakEndStr.isEmpty();

String statusText = "Not Logged In";
String statusBadgeClass = "status-none";
if (hasCheckedOut) {
	statusText = "Logged Out";
	statusBadgeClass = "status-out";
} else if (isOnBreak) {
	statusText = "On Break";
	statusBadgeClass = "status-break";
} else if (hasCheckedIn) {
	statusText = "Logged In";
	statusBadgeClass = "status-in";
}

String empName = employee.getEmployee_name() != null ? employee.getEmployee_name() : "Employee";
String initial = !empName.isEmpty() ? empName.substring(0, 1).toUpperCase() : "E";
String empCode = "EMP-" + String.format("%04d", employee.getEmployee_id());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Attendance Control Portal | RChips ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700&display=swap"
	rel="stylesheet" />

<style>
:root {
	--primary-blue: #2563eb;
	--primary-dark: #1d4ed8;
	--primary-indigo: #4f46e5;
	--accent-gradient: linear-gradient(135deg, #2563eb 0%, #4f46e5 100%);
	--bg-main: #0f172a;
	--bg-surface: #1e293b;
	--bg-card: #ffffff;
	--text-primary: #0f172a;
	--text-secondary: #475569;
	--text-muted: #64748b;
	--emerald-color: #10b981;
	--amber-color: #f59e0b;
	--rose-color: #ef4444;
	--border-light: #e2e8f0;
	--shadow-soft: 0 10px 30px -5px rgba(15, 23, 42, 0.08);
	--shadow-hover: 0 20px 40px -10px rgba(37, 99, 235, 0.18);
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: #f8fafc;
	background-image: 
		radial-gradient(at 0% 0%, rgba(37, 99, 235, 0.07) 0px, transparent 50%),
		radial-gradient(at 100% 100%, rgba(79, 70, 229, 0.05) 0px, transparent 50%),
		linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
	background-attachment: fixed;
	color: var(--text-primary);
	min-height: 100vh;
	display: flex;
	flex-direction: column;
}

/* Header Topbar */
.topbar {
	height: 76px;
	background: rgba(255, 255, 255, 0.9);
	backdrop-filter: blur(12px);
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 0 40px;
	border-bottom: 1px solid var(--border-light);
	position: sticky;
	top: 0;
	z-index: 100;
	box-shadow: 0 4px 20px rgba(15, 23, 42, 0.03);
}

.brand-wrapper {
	display: flex;
	align-items: center;
	gap: 14px;
}

.brand-icon {
	width: 44px;
	height: 44px;
	background: var(--accent-gradient);
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #ffffff;
	font-size: 20px;
	box-shadow: 0 6px 16px rgba(37, 99, 235, 0.3);
}

.brand-text h2 {
	font-size: 19px;
	font-weight: 800;
	color: var(--text-primary);
	letter-spacing: -0.4px;
}

.brand-text p {
	font-size: 12px;
	color: var(--text-muted);
	font-weight: 600;
}

.topbar-right {
	display: flex;
	align-items: center;
	gap: 20px;
}

.clock-pill {
	background: #f1f5f9;
	border: 1px solid var(--border-light);
	padding: 8px 18px;
	border-radius: 50px;
	display: flex;
	align-items: center;
	gap: 10px;
	font-size: 13px;
	font-weight: 700;
	color: var(--text-primary);
	font-family: 'JetBrains Mono', monospace;
}

.clock-pill i {
	color: var(--primary-blue);
}

/* Main Container */
.main-wrapper {
	max-width: 960px;
	margin: 36px auto;
	padding: 0 24px;
	width: 100%;
	flex: 1;
}

/* Hero Profile Banner */
.hero-banner {
	background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
	border-radius: 28px;
	padding: 32px 40px;
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 24px;
	box-shadow: 0 20px 40px rgba(15, 23, 42, 0.15);
	position: relative;
	overflow: hidden;
	margin-bottom: 28px;
}

.hero-banner::before {
	content: '';
	position: absolute;
	top: -50%;
	right: -20%;
	width: 300px;
	height: 300px;
	background: radial-gradient(circle, rgba(37, 99, 235, 0.3) 0%, transparent 70%);
	pointer-events: none;
}

.user-info-group {
	display: flex;
	align-items: center;
	gap: 20px;
	z-index: 2;
}

.user-avatar {
	width: 68px;
	height: 68px;
	border-radius: 20px;
	background: var(--accent-gradient);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 28px;
	font-weight: 800;
	box-shadow: 0 8px 24px rgba(37, 99, 235, 0.4);
	border: 2px solid rgba(255, 255, 255, 0.2);
}

.user-details h1 {
	font-size: 24px;
	font-weight: 800;
	letter-spacing: -0.5px;
	margin-bottom: 4px;
}

.user-meta-pills {
	display: flex;
	align-items: center;
	gap: 12px;
	font-size: 13px;
	color: #94a3b8;
	font-weight: 600;
}

.user-meta-pills span {
	display: flex;
	align-items: center;
	gap: 6px;
}

/* Status Badge Components */
.status-pill {
	display: inline-flex;
	align-items: center;
	gap: 10px;
	padding: 10px 22px;
	border-radius: 50px;
	font-size: 14px;
	font-weight: 800;
	letter-spacing: 0.2px;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.1);
	z-index: 2;
}

.status-dot {
	width: 10px;
	height: 10px;
	border-radius: 50%;
	display: inline-block;
	position: relative;
}

.status-dot::after {
	content: '';
	position: absolute;
	top: -3px;
	left: -3px;
	right: -3px;
	bottom: -3px;
	border-radius: 50%;
	animation: pulseRing 1.8s infinite ease-out;
}

@keyframes pulseRing {
	0% { transform: scale(0.9); opacity: 0.8; }
	100% { transform: scale(1.8); opacity: 0; }
}

.status-in {
	background: rgba(16, 185, 129, 0.15);
	color: #34d399;
	border: 1px solid rgba(52, 211, 153, 0.3);
}
.status-in .status-dot, .status-in .status-dot::after { background: #34d399; }

.status-break {
	background: rgba(245, 158, 11, 0.15);
	color: #fbbf24;
	border: 1px solid rgba(251, 191, 36, 0.3);
}
.status-break .status-dot, .status-break .status-dot::after { background: #fbbf24; }

.status-out {
	background: rgba(99, 102, 241, 0.15);
	color: #818cf8;
	border: 1px solid rgba(129, 140, 248, 0.3);
}
.status-out .status-dot, .status-out .status-dot::after { background: #818cf8; }

.status-none {
	background: rgba(148, 163, 184, 0.15);
	color: #cbd5e1;
	border: 1px solid rgba(203, 213, 225, 0.3);
}
.status-none .status-dot, .status-none .status-dot::after { background: #cbd5e1; }

/* Metrics Grid Cards */
.metrics-grid {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 18px;
	margin-bottom: 28px;
}

.metric-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 20px 22px;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-soft);
	transition: all 0.25s ease;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.metric-card:hover {
	transform: translateY(-3px);
	box-shadow: var(--shadow-hover);
	border-color: #cbd5e1;
}

.metric-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 12px;
}

.metric-title {
	font-size: 13px;
	font-weight: 700;
	color: var(--text-muted);
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.metric-icon {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 16px;
}

.icon-blue { background: #eff6ff; color: var(--primary-blue); }
.icon-rose { background: #fef2f2; color: var(--rose-color); }
.icon-amber { background: #fffbe6; color: var(--amber-color); }
.icon-emerald { background: #ecfdf5; color: var(--emerald-color); }

.metric-value {
	font-size: 20px;
	font-weight: 800;
	color: var(--text-primary);
	font-family: 'JetBrains Mono', monospace;
}

.metric-sub {
	font-size: 12px;
	color: var(--text-muted);
	font-weight: 600;
	margin-top: 4px;
}

/* Control Panel Section */
.panel-card {
	background: #ffffff;
	border-radius: 24px;
	border: 1px solid var(--border-light);
	padding: 32px;
	box-shadow: var(--shadow-soft);
	margin-bottom: 28px;
}

.panel-title-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 24px;
	padding-bottom: 16px;
	border-bottom: 1px solid var(--border-light);
}

.panel-title {
	font-size: 18px;
	font-weight: 800;
	color: var(--text-primary);
	display: flex;
	align-items: center;
	gap: 10px;
}

.panel-title i {
	color: var(--primary-blue);
}

.geo-tag {
	font-size: 12px;
	font-weight: 700;
	color: #1e40af;
	background: #eff6ff;
	padding: 6px 14px;
	border-radius: 20px;
	border: 1px solid #bfdbfe;
	display: flex;
	align-items: center;
	gap: 6px;
}

/* Action Cards Layout */
.action-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 24px;
}

.action-card {
	background: #f8fafc;
	border: 1px solid var(--border-light);
	border-radius: 20px;
	padding: 28px 24px;
	text-align: center;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	gap: 16px;
	transition: all 0.3s ease;
}

.action-card:hover {
	border-color: #cbd5e1;
	background: #ffffff;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.03);
}

.action-card-title {
	font-size: 15px;
	font-weight: 700;
	color: var(--text-secondary);
}

.action-card-value {
	font-size: 24px;
	font-weight: 800;
	font-family: 'JetBrains Mono', monospace;
	color: var(--text-primary);
}

/* Buttons Styling */
.btn-action {
	width: 100%;
	padding: 14px 28px;
	border-radius: 14px;
	font-size: 15px;
	font-weight: 800;
	border: none;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	text-decoration: none;
	transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.btn-login {
	background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
	color: #ffffff;
	box-shadow: 0 8px 20px rgba(37, 99, 235, 0.35);
}

.btn-login:hover {
	transform: translateY(-2px);
	box-shadow: 0 12px 26px rgba(37, 99, 235, 0.45);
	background: linear-gradient(135deg, #1d4ed8 0%, #1e40af 100%);
}

.btn-logout {
	background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
	color: #ffffff;
	box-shadow: 0 8px 20px rgba(239, 68, 68, 0.35);
}

.btn-logout:hover {
	transform: translateY(-2px);
	box-shadow: 0 12px 26px rgba(239, 68, 68, 0.45);
	background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
}

.btn-break-start {
	background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
	color: #ffffff;
	box-shadow: 0 8px 20px rgba(245, 158, 11, 0.35);
}

.btn-break-start:hover {
	transform: translateY(-2px);
	box-shadow: 0 12px 26px rgba(245, 158, 11, 0.45);
}

.btn-resume {
	background: linear-gradient(135deg, #10b981 0%, #059669 100%);
	color: #ffffff;
	box-shadow: 0 8px 20px rgba(16, 185, 129, 0.35);
}

.btn-resume:hover {
	transform: translateY(-2px);
	box-shadow: 0 12px 26px rgba(16, 185, 129, 0.45);
}

.btn-disabled {
	background: #e2e8f0;
	color: #94a3b8;
	cursor: not-allowed;
	box-shadow: none;
}

.badge-state {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 10px 20px;
	border-radius: 12px;
	font-size: 14px;
	font-weight: 700;
	width: 100%;
	justify-content: center;
}

.badge-in-state {
	background: #eff6ff;
	color: #1d4ed8;
	border: 1px solid #bfdbfe;
}

.badge-out-state {
	background: #f1f5f9;
	color: #475569;
	border: 1px solid #cbd5e1;
}

/* Footer & Navigation */
.footer-nav {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 16px;
}

.btn-secondary {
	display: inline-flex;
	align-items: center;
	gap: 10px;
	background: #ffffff;
	border: 1px solid var(--border-light);
	padding: 12px 24px;
	border-radius: 14px;
	color: var(--text-secondary);
	font-weight: 700;
	font-size: 14px;
	text-decoration: none;
	box-shadow: var(--shadow-soft);
	transition: all 0.25s ease;
}

.btn-secondary:hover {
	background: #f8fafc;
	color: var(--primary-blue);
	border-color: #cbd5e1;
	transform: translateY(-2px);
}

@media (max-width: 768px) {
	.topbar { padding: 0 20px; }
	.metrics-grid { grid-template-columns: repeat(2, 1fr); }
	.action-grid { grid-template-columns: 1fr; }
	.hero-banner { padding: 24px; }
}
</style>
</head>
<body>

	<!-- Topbar -->
	<header class="topbar">
		<div class="brand-wrapper">
			<div class="brand-icon">
				<i class="fa-solid fa-clock-rotate-left"></i>
			</div>
			<div class="brand-text">
				<h2>Attendance Portal</h2>
				<p>RChips Solutions ELAMS</p>
			</div>
		</div>

		<div class="topbar-right">
			<div class="clock-pill">
				<i class="fa-regular fa-clock"></i> <span id="liveClock">Loading...</span>
			</div>
		</div>
	</header>

	<!-- Main Workspace -->
	<main class="main-wrapper">

		<!-- User Hero Banner -->
		<section class="hero-banner">
			<div class="user-info-group">
				<div class="user-avatar"><%=initial%></div>
				<div class="user-details">
					<h1><%=empName%></h1>
					<div class="user-meta-pills">
						<span><i class="fa-solid fa-id-badge"></i> <%=empCode%></span>
						<span>•</span>
						<span><i class="fa-solid fa-user-shield"></i> <%=role != null ? role.toUpperCase() : "MEMBER"%></span>
					</div>
				</div>
			</div>

			<!-- Status Badge -->
			<div class="status-pill <%=statusBadgeClass%>">
				<span class="status-dot"></span> <%=statusText%>
			</div>
		</section>

		<!-- Metrics Grid -->
		<section class="metrics-grid">
			<!-- Metric 1: Login Time -->
			<div class="metric-card">
				<div class="metric-header">
					<span class="metric-title">Login Time</span>
					<div class="metric-icon icon-blue">
						<i class="fa-solid fa-right-to-bracket"></i>
					</div>
				</div>
				<div>
					<div class="metric-value"><%=hasCheckedIn ? checkInTimeStr : "--:--"%></div>
					<div class="metric-sub"><%=hasCheckedIn ? "Recorded Check-in" : "Pending Login"%></div>
				</div>
			</div>

			<!-- Metric 2: Logout Time -->
			<div class="metric-card">
				<div class="metric-header">
					<span class="metric-title">LogOut Time</span>
					<div class="metric-icon icon-rose">
						<i class="fa-solid fa-right-from-bracket"></i>
					</div>
				</div>
				<div>
					<div class="metric-value"><%=hasCheckedOut ? checkOutTimeStr : "--:--"%></div>
					<div class="metric-sub"><%=hasCheckedOut ? "Shift Completed" : "Active Session"%></div>
				</div>
			</div>

			<!-- Metric 3: Break Time -->
			<div class="metric-card">
				<div class="metric-header">
					<span class="metric-title">Break Duration</span>
					<div class="metric-icon icon-amber">
						<i class="fa-solid fa-mug-hot"></i>
					</div>
				</div>
				<div>
					<div class="metric-value" id="breakDurationVal"><%=breakMinutes%> <span style="font-size: 14px; font-weight:600;">mins</span></div>
					<div class="metric-sub" id="breakDurationSub"><%=isOnBreak ? "Break in progress..." : (hasCompletedBreak ? "Break taken" : "No break logged")%></div>
				</div>
			</div>

			<!-- Metric 4: Active Work Timer -->
			<div class="metric-card">
				<div class="metric-header">
					<span class="metric-title">Active Time</span>
					<div class="metric-icon icon-emerald">
						<i class="fa-solid fa-stopwatch"></i>
					</div>
				</div>
				<div>
					<div class="metric-value" id="activeTimer">00h 00m</div>
					<div class="metric-sub" id="activeTimerSub">Calculating duration...</div>
				</div>
			</div>
		</section>

		<!-- Main Attendance Action Panel -->
		<section class="panel-card">
			<div class="panel-title-row">
				<div class="panel-title">
					<i class="fa-solid fa-fingerprint"></i> Attendance Control Center
				</div>
				<div class="geo-tag">
					<i class="fa-solid fa-shield-halved"></i> Enterprise Geo-Verified
				</div>
			</div>

			<div class="action-grid">
				<!-- Action Card 1: Duty Session (Login / Logout) -->
				<div class="action-card">
					<div class="action-card-title">Duty Session Control</div>
					<div class="action-card-value">
						<% if (!hasCheckedIn) { %>
							Not Checked In
						<% } else if (hasCheckedOut) { %>
							Shift Ended
						<% } else { %>
							Active Session
						<% } %>
					</div>

					<div style="width: 100%;">
						<% if (!hasCheckedIn) { %>
							<form action="markAttendance" method="post" style="width: 100%;">
								<input type="hidden" name="location" id="userLocationCheckin" value="Office / Remote" />
								<button type="submit" class="btn-action btn-login">
									<i class="fa-solid fa-right-to-bracket"></i> Login
								</button>
							</form>
						<% } else if (!hasCheckedOut) { %>
							<form action="markCheckout" method="post" style="width: 100%;">
								<input type="hidden" name="location" id="userLocationCheckout" value="Office / Remote" />
								<button type="submit" class="btn-action btn-logout">
									<i class="fa-solid fa-right-from-bracket"></i> Logout
								</button>
							</form>
						<% } else { %>
							<div class="badge-state badge-out-state">
								<i class="fa-solid fa-circle-check" style="color: var(--emerald-color);"></i> Logged Out
							</div>
						<% } %>
					</div>
				</div>

				<!-- Action Card 2: Break Management (Start Break / Resume) -->
				<div class="action-card">
					<div class="action-card-title">Break Management</div>
					<div class="action-card-value">
						<% if (isOnBreak) { %>
							On Break
						<% } else if (hasCompletedBreak) { %>
							<%=breakMinutes%> mins Total
						<% } else { %>
							Standard Shift
						<% } %>
					</div>

					<div style="width: 100%;">
						<% if (hasCheckedIn && !hasCheckedOut && !isOnBreak) { %>
							<a href="startBreak" class="btn-action btn-break-start">
								<i class="fa-solid fa-mug-hot"></i> Start Break
							</a>
						<% } else if (isOnBreak) { %>
							<a href="endBreak" class="btn-action btn-resume">
								<i class="fa-solid fa-play"></i> Resume
							</a>
						<% } else { %>
							<button type="button" class="btn-action btn-disabled" disabled>
								<i class="fa-solid fa-mug-hot"></i> Start Break
							</button>
						<% } %>
					</div>
				</div>
			</div>
		</section>

		<!-- Footer Navigation Links -->
		<nav class="footer-nav">
			<a href="attendanceHistory?employeeId=<%=employee.getEmployee_id()%>" class="btn-secondary">
				<i class="fa-solid fa-clock-rotate-left"></i> View Attendance History
			</a>
			<a href="<%=dashboardUrl%>" class="btn-secondary">
				<i class="fa-solid fa-house"></i> Back to Dashboard
			</a>
		</nav>

	</main>

	<!-- Real-time JavaScript for Live Clock & Active Duration Calculator -->
	<script>
		function updateClock() {
			const now = new Date();
			const options = { day: '2-digit', month: 'short', year: 'numeric' };
			const datePart = now.toLocaleDateString('en-GB', options);
			
			let hours = now.getHours();
			const minutes = String(now.getMinutes()).padStart(2, '0');
			const seconds = String(now.getSeconds()).padStart(2, '0');
			const ampm = hours >= 12 ? 'pm' : 'am';
			hours = hours % 12;
			hours = hours ? hours : 12;
			const hoursStr = String(hours).padStart(2, '0');

			const timeFormatted = datePart + ", " + hoursStr + ":" + minutes + ":" + seconds + " " + ampm;
			const clockEl = document.getElementById("liveClock");
			if (clockEl) clockEl.innerText = timeFormatted;
		}

		updateClock();
		setInterval(updateClock, 1000);

		// Calculate Real-Time Active Elapsed Time
		const checkInTimeStr = "<%=checkInTimeStr%>";
		const checkOutTimeStr = "<%=checkOutTimeStr%>";
		const breakStartStr = "<%=breakStartStr%>";
		const breakMinutes = <%=breakMinutes%>;
		const isOnBreak = <%=isOnBreak%>;

		function updateActiveTimer() {
			const timerEl = document.getElementById("activeTimer");
			const subEl = document.getElementById("activeTimerSub");
			const breakValEl = document.getElementById("breakDurationVal");
			const breakSubEl = document.getElementById("breakDurationSub");

			if (!checkInTimeStr) {
				if (timerEl) timerEl.innerText = "00h 00m";
				if (subEl) subEl.innerText = "Not checked in today";
				return;
			}

			const now = new Date();
			const checkInParts = checkInTimeStr.split(":");
			const checkInDate = new Date();
			checkInDate.setHours(parseInt(checkInParts[0], 10), parseInt(checkInParts[1], 10), parseInt(checkInParts[2] || 0, 10), 0);

			let endPoint = now;
			if (checkOutTimeStr) {
				const checkOutParts = checkOutTimeStr.split(":");
				endPoint = new Date();
				endPoint.setHours(parseInt(checkOutParts[0], 10), parseInt(checkOutParts[1], 10), parseInt(checkOutParts[2] || 0, 10), 0);
			}

			let diffMs = endPoint - checkInDate;
			if (diffMs < 0) diffMs = 0;

			let totalMinutes = Math.floor(diffMs / (1000 * 60));

			let currentBreakMins = 0;
			if (isOnBreak && breakStartStr) {
				const breakParts = breakStartStr.split(":");
				const breakStartDate = new Date();
				breakStartDate.setHours(parseInt(breakParts[0], 10), parseInt(breakParts[1], 10), parseInt(breakParts[2] || 0, 10), 0);
				let curBreakMs = now - breakStartDate;
				if (curBreakMs > 0) {
					currentBreakMins = Math.floor(curBreakMs / (1000 * 60));
				}
				if (breakValEl) {
					breakValEl.innerHTML = (breakMinutes + currentBreakMins) + ' <span style="font-size: 14px; font-weight:600;">mins</span>';
				}
				if (breakSubEl) {
					breakSubEl.innerText = "Break in progress (" + currentBreakMins + "m this session)";
				}
			}

			let netMinutes = totalMinutes - breakMinutes - currentBreakMins;
			if (netMinutes < 0) netMinutes = 0;

			const hours = Math.floor(netMinutes / 60);
			const mins = netMinutes % 60;
			const hoursPadded = String(hours).padStart(2, '0');
			const minsPadded = String(mins).padStart(2, '0');

			if (timerEl) timerEl.innerText = hoursPadded + "h " + minsPadded + "m";
			
			if (subEl) {
				if (checkOutTimeStr) {
					subEl.innerText = "Total shift duration";
				} else if (isOnBreak) {
					subEl.innerText = "Paused for break";
				} else {
					subEl.innerText = "Live elapsed time";
				}
			}
		}

		updateActiveTimer();
		setInterval(updateActiveTimer, 1000);

		// Optional Geo-Location tagging
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(pos) {
				const locStr = "Office Geo: " + pos.coords.latitude.toFixed(4) + ", " + pos.coords.longitude.toFixed(4);
				const inEl = document.getElementById("userLocationCheckin");
				const outEl = document.getElementById("userLocationCheckout");
				if (inEl) inEl.value = locStr;
				if (outEl) outEl.value = locStr;
			}, function(err) {
				// Geolocation fallback stays default
			});
		}
	</script>
</body>
</html>