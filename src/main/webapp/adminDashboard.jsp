<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Leave"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Calendar"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}
if (request.getAttribute("employeeCount") == null) {
	response.sendRedirect(request.getContextPath() + "/adminDashboardServlet");
	return;
}

Employee employee = (Employee) session.getAttribute("employee");
if (employee == null && loggedUser != null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(loggedUser.getEmail());
	} catch (Exception ignored) {}
}

String adminEmail = loggedUser != null && loggedUser.getEmail() != null ? loggedUser.getEmail() : "admin@elams.com";
String adminName = employee != null && employee.getEmployee_name() != null ? employee.getEmployee_name() : (adminEmail.contains("@") ? adminEmail.split("@")[0] : adminEmail);
if (adminName != null && !adminName.isBlank()) {
	adminName = Character.toUpperCase(adminName.charAt(0)) + (adminName.length() > 1 ? adminName.substring(1) : "");
} else {
	adminName = "Admin";
}

String adminPhoto = (employee != null && employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + adminName + "&background=4f46e5&color=fff&bold=true";

int employeeCount = request.getAttribute("employeeCount") != null ? (Integer) request.getAttribute("employeeCount") : 0;
int presentCount = request.getAttribute("presentCount") != null ? (Integer) request.getAttribute("presentCount") : 0;
int absentCount = request.getAttribute("absentCount") != null ? (Integer) request.getAttribute("absentCount") : 0;
int halfDayCount = request.getAttribute("halfDayCount") != null ? (Integer) request.getAttribute("halfDayCount") : 0;
int pendingLeaves = request.getAttribute("pendingLeaves") != null ? (Integer) request.getAttribute("pendingLeaves") : 0;

int totalTasks = request.getAttribute("totalTasks") != null ? (Integer) request.getAttribute("totalTasks") : 0;
int completedTasks = request.getAttribute("completedTasks") != null ? (Integer) request.getAttribute("completedTasks") : 0;
int pendingTasks = request.getAttribute("pendingTasks") != null ? (Integer) request.getAttribute("pendingTasks") : 0;
int inProgressTasks = request.getAttribute("inProgressTasks") != null ? (Integer) request.getAttribute("inProgressTasks") : 0;
int overdueTasks = request.getAttribute("overdueTasks") != null ? (Integer) request.getAttribute("overdueTasks") : 0;
int completionRate = request.getAttribute("completionRate") != null ? (Integer) request.getAttribute("completionRate") : 0;

int totalMeetings = request.getAttribute("totalMeetings") != null ? (Integer) request.getAttribute("totalMeetings") : 0;
int upcomingMeetings = request.getAttribute("upcomingMeetings") != null ? (Integer) request.getAttribute("upcomingMeetings") : 0;

@SuppressWarnings("unchecked")
List<Leave> pendingLeavesList = (List<Leave>) request.getAttribute("pendingLeavesList");

@SuppressWarnings("unchecked")
List<Meeting> todayMeetings = (List<Meeting>) request.getAttribute("todayMeetings");

@SuppressWarnings("unchecked")
List<Employee> recentEmployees = (List<Employee>) request.getAttribute("recentEmployees");



int attendanceRate = employeeCount > 0 ? (presentCount * 100) / employeeCount : 0;
String todayDateStr = new SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date());

String activePage = "dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>RChips Solutions | Executive Admin Command Hub</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />

<style>
:root {
	--brand-primary: #4f46e5;
	--brand-primary-light: #6366f1;
	--brand-secondary: #06b6d4;
	--accent-emerald: #10b981;
	--accent-amber: #f59e0b;
	--accent-rose: #f43f5e;
	--bg-main: #f8fafc;
	--card-bg: #ffffff;
	--text-primary: #0f172a;
	--text-secondary: #64748b;
	--sidebar-w: 270px;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: var(--bg-main);
	color: var(--text-primary);
	display: flex;
	min-height: 100vh;
}

/* ================= Sidebar Navigation ================= */
.sidebar {
	width: var(--sidebar-w);
	background: linear-gradient(180deg, #0f172a 0%, #1e293b 100%);
	position: fixed;
	left: 0;
	top: 0;
	bottom: 0;
	overflow-y: auto;
	z-index: 100;
	border-right: 1px solid rgba(255, 255, 255, 0.08);
}

.logo-brand {
	padding: 24px 28px;
	display: flex;
	align-items: center;
	gap: 12px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.logo-icon {
	width: 40px;
	height: 40px;
	border-radius: 12px;
	background: linear-gradient(135deg, #6366f1 0%, #38bdf8 100%);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);
}

.logo-text {
	font-size: 20px;
	font-weight: 800;
	color: #ffffff;
	letter-spacing: -0.5px;
}

.logo-text span { color: #38bdf8; }

.menu-nav {
	padding: 20px 16px;
}

.menu-label {
	padding: 14px 16px 6px;
	font-size: 11px;
	font-weight: 800;
	text-transform: uppercase;
	color: #64748b;
	letter-spacing: 0.8px;
}

.menu-item {
	display: flex;
	align-items: center;
	gap: 14px;
	padding: 12px 16px;
	border-radius: 12px;
	text-decoration: none;
	color: #94a3b8;
	font-size: 14px;
	font-weight: 600;
	transition: all 0.2s ease;
	margin-bottom: 4px;
}

.menu-item:hover {
	background: rgba(255, 255, 255, 0.06);
	color: #ffffff;
}

.menu-item.active {
	background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
	color: #ffffff;
	box-shadow: 0 4px 18px rgba(79, 70, 229, 0.35);
}

.menu-item i {
	font-size: 17px;
	width: 22px;
	text-align: center;
}

/* ================= Main Container ================= */
.main-wrapper {
	margin-left: var(--sidebar-w);
	width: calc(100% - var(--sidebar-w));
	display: flex;
	flex-direction: column;
	min-height: 100vh;
}

/* ================= Topbar Header ================= */
.topbar-header {
	height: 72px;
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

.topbar-title h2 {
	font-size: 20px;
	font-weight: 800;
	color: var(--text-primary);
	letter-spacing: -0.4px;
}

.topbar-right {
	display: flex;
	align-items: center;
	gap: 18px;
}

.user-profile-badge {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 4px 16px 4px 5px;
	background: #f1f5f9;
	border-radius: 30px;
	text-decoration: none;
	color: #0f172a;
	font-weight: 700;
	font-size: 13.5px;
	transition: all 0.2s ease;
	border: 1px solid #e2e8f0;
}

.user-profile-badge:hover {
	background: #e2e8f0;
}

.avatar-photo-wrapper {
	position: relative;
	width: 36px;
	height: 36px;
}

.avatar-photo-img {
	width: 36px;
	height: 36px;
	border-radius: 50%;
	object-fit: cover;
}

.active-status-dot {
	position: absolute;
	bottom: 0;
	right: 0;
	width: 10px;
	height: 10px;
	background: #10b981;
	border: 2px solid #ffffff;
	border-radius: 50%;
}

/* ================= Dashboard Content ================= */
.dashboard-content {
	padding: 36px;
	flex: 1;
}

/* Hero Banner Card */
.hero-welcome-card {
	background: linear-gradient(135deg, #1e1b4b 0%, #312e81 40%, #0369a1 100%);
	border-radius: 24px;
	padding: 28px 36px;
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 28px;
	box-shadow: 0 12px 30px rgba(30, 27, 75, 0.25);
	position: relative;
	overflow: hidden;
}

.hero-welcome-card::after {
	content: '';
	position: absolute;
	right: -40px;
	bottom: -40px;
	width: 220px;
	height: 220px;
	background: rgba(255, 255, 255, 0.08);
	border-radius: 50%;
	pointer-events: none;
}

.hero-left {
	display: flex;
	align-items: center;
	gap: 22px;
}

.hero-avatar-img {
	width: 68px;
	height: 68px;
	border-radius: 20px;
	object-fit: cover;
	box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
	border: 2px solid rgba(255, 255, 255, 0.3);
}

.hero-badge-tag {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 12px;
	border-radius: 20px;
	background: rgba(255, 255, 255, 0.18);
	backdrop-filter: blur(10px);
	color: #ffffff;
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 6px;
}

.hero-left h1 {
	font-size: 24px;
	font-weight: 800;
	letter-spacing: -0.4px;
	margin-bottom: 4px;
}

.hero-left p {
	font-size: 13.5px;
	color: rgba(255, 255, 255, 0.85);
}

.hero-clock {
	text-align: right;
	background: rgba(0, 0, 0, 0.22);
	backdrop-filter: blur(8px);
	padding: 14px 22px;
	border-radius: 18px;
	border: 1px solid rgba(255, 255, 255, 0.12);
}

.clock-time {
	font-family: 'JetBrains Mono', monospace;
	font-size: 24px;
	font-weight: 800;
}

.clock-date {
	font-size: 12px;
	color: rgba(255, 255, 255, 0.8);
	margin-top: 2px;
}

/* Quick Action Buttons */
.quick-action-bar {
	display: flex;
	gap: 12px;
	margin-bottom: 28px;
	flex-wrap: wrap;
}

.btn-quick {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 11px 18px;
	border-radius: 14px;
	font-size: 13.5px;
	font-weight: 700;
	text-decoration: none;
	transition: all 0.2s ease;
	background: #ffffff;
	border: 1px solid #e2e8f0;
	color: #334155;
	box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
}

.btn-quick:hover {
	transform: translateY(-2px);
	border-color: #cbd5e1;
	box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
	color: var(--brand-primary);
}

/* Metric Cards Grid */
.cards-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
	gap: 20px;
	margin-bottom: 32px;
}

.card-kpi {
	background: var(--card-bg);
	border-radius: 20px;
	padding: 22px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
	transition: all 0.25s ease;
	text-decoration: none;
	color: inherit;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.card-kpi:hover {
	transform: translateY(-4px);
	box-shadow: 0 12px 28px rgba(0, 0, 0, 0.07);
	border-color: #cbd5e1;
}

.kpi-top {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 14px;
}

.kpi-icon-box {
	width: 50px;
	height: 50px;
	border-radius: 15px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	color: #ffffff;
}

.pink-grad { background: linear-gradient(135deg, #ec4899 0%, #db2777 100%); box-shadow: 0 4px 14px rgba(236, 72, 153, 0.3); }
.green-grad { background: linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow: 0 4px 14px rgba(16, 185, 129, 0.3); }
.red-grad { background: linear-gradient(135deg, #f43f5e 0%, #e11d48 100%); box-shadow: 0 4px 14px rgba(244, 63, 94, 0.3); }
.orange-grad { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); box-shadow: 0 4px 14px rgba(245, 158, 11, 0.3); }
.blue-grad { background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); box-shadow: 0 4px 14px rgba(2, 132, 199, 0.3); }
.purple-grad { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); box-shadow: 0 4px 14px rgba(139, 92, 246, 0.3); }

.kpi-title {
	font-size: 12.5px;
	font-weight: 700;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 4px;
}

.kpi-value {
	font-size: 30px;
	font-weight: 800;
	color: var(--text-primary);
	font-family: 'JetBrains Mono', monospace;
	line-height: 1.1;
}

.kpi-link-hint {
	font-size: 12px;
	font-weight: 700;
	color: var(--brand-primary);
	margin-top: 10px;
	display: flex;
	align-items: center;
	gap: 6px;
}

/* ===== Analytics & Charts Strip ===== */
.analytics-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 24px;
	margin-bottom: 32px;
}

@media (max-width: 1024px) {
	.analytics-grid { grid-template-columns: 1fr; }
}

.analytics-card {
	background: #ffffff;
	border-radius: 22px;
	padding: 24px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.analytics-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 18px;
}

.analytics-title {
	font-size: 16px;
	font-weight: 800;
	color: var(--text-primary);
	display: flex;
	align-items: center;
	gap: 10px;
}

/* Progress Multi-Bar */
.multi-bar {
	height: 14px;
	border-radius: 10px;
	background: #e2e8f0;
	display: flex;
	overflow: hidden;
	margin: 18px 0;
}

.bar-seg {
	height: 100%;
	transition: width 0.5s ease;
}

.seg-done { background: #10b981; }
.seg-prog { background: #6366f1; }
.seg-pend { background: #f59e0b; }
.seg-over { background: #f43f5e; }

.legend-row {
	display: flex;
	flex-wrap: wrap;
	gap: 16px;
	font-size: 12.5px;
	font-weight: 700;
	color: #475569;
}

.legend-item {
	display: flex;
	align-items: center;
	gap: 6px;
}

.legend-dot {
	width: 10px;
	height: 10px;
	border-radius: 50%;
}

/* ===== Two-Column Operations Center ===== */
.dual-section-grid {
	display: grid;
	grid-template-columns: 1.1fr 0.9fr;
	gap: 24px;
	margin-bottom: 32px;
}

@media (max-width: 1024px) {
	.dual-section-grid { grid-template-columns: 1fr; }
}

.widget-box {
	background: #ffffff;
	border-radius: 22px;
	padding: 24px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.widget-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 18px;
	padding-bottom: 14px;
	border-bottom: 1px solid #f1f5f9;
}

.widget-title {
	font-size: 16.5px;
	font-weight: 800;
	color: var(--text-primary);
	display: flex;
	align-items: center;
	gap: 10px;
}

.widget-link {
	font-size: 13px;
	font-weight: 700;
	color: var(--brand-primary);
	text-decoration: none;
}

/* Pending Leave Cards */
.leave-approval-item {
	background: #f8fafc;
	border-radius: 16px;
	padding: 16px;
	border: 1px solid #f1f5f9;
	margin-bottom: 12px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 14px;
	transition: all 0.2s ease;
}

.leave-approval-item:hover {
	background: #ffffff;
	border-color: #cbd5e1;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.04);
}

.leave-user-detail h4 {
	font-size: 14.5px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 2px;
}

.leave-user-detail p {
	font-size: 12.5px;
	color: #64748b;
}

.leave-type-pill {
	font-size: 11px;
	font-weight: 800;
	padding: 2px 8px;
	border-radius: 10px;
	background: #fef3c7;
	color: #b45309;
	text-transform: uppercase;
	display: inline-block;
	margin-bottom: 4px;
}

.leave-action-btns {
	display: flex;
	gap: 8px;
}

.btn-act-app {
	padding: 7px 14px;
	background: #10b981;
	color: white;
	border-radius: 10px;
	font-size: 12px;
	font-weight: 700;
	text-decoration: none;
	transition: background 0.15s;
}

.btn-act-app:hover { background: #059669; }

.btn-act-rej {
	padding: 7px 14px;
	background: #f43f5e;
	color: white;
	border-radius: 10px;
	font-size: 12px;
	font-weight: 700;
	text-decoration: none;
	transition: background 0.15s;
}

.btn-act-rej:hover { background: #e11d48; }

/* Meeting Items */
.meet-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 14px;
	border-radius: 14px;
	background: #f8fafc;
	margin-bottom: 10px;
	border: 1px solid #f1f5f9;
}

.meet-row:hover {
	background: #ffffff;
	border-color: #cbd5e1;
}

.empty-state {
	text-align: center;
	padding: 28px 20px;
	color: #94a3b8;
}

.empty-state i {
	font-size: 32px;
	color: #cbd5e1;
	margin-bottom: 8px;
}

/* Recent Employees Table */
.recent-emp-box {
	background: #ffffff;
	border-radius: 22px;
	padding: 24px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
}

.emp-table {
	width: 100%;
	border-collapse: collapse;
}

.emp-table th {
	text-align: left;
	padding: 12px 16px;
	font-size: 12px;
	font-weight: 800;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	border-bottom: 1px solid #e2e8f0;
}

.emp-table td {
	padding: 14px 16px;
	font-size: 13.5px;
	color: #334155;
	border-bottom: 1px solid #f1f5f9;
}

.emp-table tr:last-child td { border-bottom: none; }
.emp-table tr:hover td { background: #f8fafc; }

.emp-name-col {
	display: flex;
	align-items: center;
	gap: 12px;
	font-weight: 700;
	color: #0f172a;
}

.emp-mini-photo {
	width: 34px;
	height: 34px;
	border-radius: 10px;
	object-fit: cover;
}
</style>
</head>

<body>

	<!-- 1. Sidebar Navigation -->
	<div class="sidebar">
		<div class="logo-brand">
			<div class="logo-icon"><i class="fa-solid fa-shield-halved"></i></div>
			<div class="logo-text">SmartOffice<span>.</span></div>
		</div>

		<div class="menu-nav">
			<div class="menu-label">Executive Command</div>
			<a class="menu-item active" href="adminDashboardServlet">
				<i class="fa-solid fa-house"></i> Dashboard
			</a>

			<div class="menu-label">Workforce &amp; Attendance</div>
			<a class="menu-item" href="viewEmployeesServlet">
				<i class="fa-solid fa-users"></i> Employee Roster
			</a>
			<a class="menu-item" href="addEmployee.jsp">
				<i class="fa-solid fa-user-plus"></i> Add Employee
			</a>
			<a class="menu-item" href="leaveRequests">
				<i class="fa-solid fa-file-circle-check"></i> Leave Approvals
			</a>
			<a class="menu-item" href="attendance.jsp">
				<i class="fa-solid fa-calendar-check"></i> Daily Attendance
			</a>
			<a class="menu-item" href="attendanceHistory">
				<i class="fa-solid fa-clock-rotate-left"></i> Attendance History
			</a>

			<div class="menu-label">Task Operations</div>
			<a class="menu-item" href="viewTasksServlet">
				<i class="fa-solid fa-list-check"></i> All Tasks
			</a>
			<a class="menu-item" href="createTask">
				<i class="fa-solid fa-square-plus"></i> Create Task
			</a>
			<a class="menu-item" href="taskReportServlet">
				<i class="fa-solid fa-chart-pie"></i> Task Reports
			</a>

			<div class="menu-label">Meetings &amp; Rooms</div>
			<a class="menu-item" href="viewMeetings">
				<i class="fa-solid fa-handshake"></i> Meetings List
			</a>
			<a class="menu-item" href="scheduleMeeting">
				<i class="fa-solid fa-calendar-plus"></i> Schedule Meeting
			</a>
			<a class="menu-item" href="calendarView">
				<i class="fa-solid fa-calendar-days"></i> Meeting Calendar
			</a>
			<a class="menu-item" href="meetingReports">
				<i class="fa-solid fa-chart-column"></i> Meeting Reports
			</a>



			<div class="menu-label">Payroll &amp; Compensation</div>
			<a class="menu-item" href="payrollDashboard">
				<i class="fa-solid fa-money-check-dollar"></i> Executive Payroll Hub
			</a>
			<a class="menu-item" href="manageSalary">
				<i class="fa-solid fa-gears"></i> Salary Package Setup
			</a>
			<a class="menu-item" href="payrollReport">
				<i class="fa-solid fa-file-invoice-dollar"></i> Payroll Analytical Reports
			</a>

			<div class="menu-label">System &amp; Settings</div>
			<a class="menu-item" href="auditLogs">
				<i class="fa-solid fa-clipboard-list"></i> Audit Logs
			</a>
			<a class="menu-item" href="systemSettings">
				<i class="fa-solid fa-sliders"></i> System Settings
			</a>
			<a class="menu-item" href="sendNotification">
				<i class="fa-solid fa-bullhorn"></i> Broadcast Alerts
			</a>
			<a class="menu-item" href="profile.jsp">
				<i class="fa-solid fa-user-gear"></i> My Profile
			</a>
			<a class="menu-item" href="logout" style="color: #f43f5e;" onclick="return confirm('Are you sure you want to logout?');">
				<i class="fa-solid fa-right-from-bracket"></i> Logout
			</a>
		</div>
	</div>

	<!-- 2. Main Wrapper -->
	<div class="main-wrapper">

		<!-- Topbar Header -->
		<div class="topbar-header">
			<div class="topbar-title">
				<h2>Executive Command Center</h2>
			</div>
			<div class="topbar-right">
				<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
				<a href="profile.jsp" class="user-profile-badge" title="My Profile">
					<div class="avatar-photo-wrapper">
						<img src="<%=adminPhoto%>" alt="Admin Photo" class="avatar-photo-img" />
						<span class="active-status-dot"></span>
					</div>
					<span><%=adminName%></span>
				</a>
			</div>
		</div>

		<!-- Dashboard Content -->
		<div class="dashboard-content">

			<!-- Hero Welcome Card -->
			<div class="hero-welcome-card">
				<div class="hero-left">
					<img src="<%=adminPhoto%>" class="hero-avatar-img" alt="Admin Photo" />
					<div>
						<div class="hero-badge-tag"><i class="fa-solid fa-crown"></i> Chief Administrator</div>
						<h1>Welcome Back, <%=adminName%> 👋</h1>
						<p>SmartOffice Workforce Governance &amp; Operations Command Suite</p>
					</div>
				</div>

				<div class="hero-clock">
					<div class="clock-time" id="liveClock">--:--:--</div>
					<div class="clock-date"><%=todayDateStr%></div>
				</div>
			</div>



			<!-- Quick Action Shortcuts -->
			<div class="quick-action-bar">
				<a href="addEmployee.jsp" class="btn-quick">
					<i class="fa-solid fa-user-plus" style="color: #10b981;"></i> Add Employee
				</a>
				<a href="leaveRequests" class="btn-quick">
					<i class="fa-solid fa-file-circle-check" style="color: #f59e0b;"></i> Review Leaves (<%=pendingLeaves%>)
				</a>
				<a href="createTask" class="btn-quick">
					<i class="fa-solid fa-square-plus" style="color: #6366f1;"></i> Assign Task
				</a>
				<a href="scheduleMeeting" class="btn-quick">
					<i class="fa-solid fa-calendar-plus" style="color: #06b6d4;"></i> Schedule Meeting
				</a>
				<a href="sendNotification" class="btn-quick">
					<i class="fa-solid fa-paper-plane" style="color: #ec4899;"></i> Send Broadcast
				</a>
				<a href="taskReportServlet" class="btn-quick">
					<i class="fa-solid fa-chart-line" style="color: #8b5cf6;"></i> Analytics
				</a>
			</div>

			<!-- Core KPI Metric Cards -->
			<div class="cards-grid">

				<!-- 1. Total Workforce -->
				<a href="viewEmployeesServlet" class="card-kpi">
					<div class="kpi-top">
						<div>
							<div class="kpi-title">Total Workforce</div>
							<div class="kpi-value"><%=employeeCount%></div>
						</div>
						<div class="kpi-icon-box pink-grad">
							<i class="fa-solid fa-users"></i>
						</div>
					</div>
					<div class="kpi-link-hint">Manage Directory →</div>
				</a>

				<!-- 2. Present Today -->
				<a href="attendanceHistory" class="card-kpi">
					<div class="kpi-top">
						<div>
							<div class="kpi-title">Present Today</div>
							<div class="kpi-value"><%=presentCount%> <small style="font-size:14px; color:#10b981; font-weight:700;">(<%=attendanceRate%>%)</small></div>
						</div>
						<div class="kpi-icon-box green-grad">
							<i class="fa-solid fa-user-check"></i>
						</div>
					</div>
					<div class="kpi-link-hint">Daily Attendance →</div>
				</a>

				<!-- 3. Absent / Leave Today -->
				<div class="card-kpi">
					<div class="kpi-top">
						<div>
							<div class="kpi-title">Absent Today</div>
							<div class="kpi-value"><%=absentCount%> <small style="font-size:13px; color:#f59e0b;">+ <%=halfDayCount%> Half-day</small></div>
						</div>
						<div class="kpi-icon-box red-grad">
							<i class="fa-solid fa-user-xmark"></i>
						</div>
					</div>
					<div class="kpi-link-hint" style="color:#64748b;">Live Status Track</div>
				</div>

				<!-- 4. Pending Leave Approvals -->
				<a href="leaveRequests" class="card-kpi">
					<div class="kpi-top">
						<div>
							<div class="kpi-title">Pending Leaves</div>
							<div class="kpi-value"><%=pendingLeaves%></div>
						</div>
						<div class="kpi-icon-box orange-grad">
							<i class="fa-solid fa-calendar-days"></i>
						</div>
					</div>
					<div class="kpi-link-hint">Action Requests →</div>
				</a>

				<!-- 5. Active Tasks -->
				<a href="viewTasksServlet" class="card-kpi">
					<div class="kpi-top">
						<div>
							<div class="kpi-title">Total Tasks</div>
							<div class="kpi-value"><%=totalTasks%></div>
						</div>
						<div class="kpi-icon-box blue-grad">
							<i class="fa-solid fa-list-check"></i>
						</div>
					</div>
					<div class="kpi-link-hint"><%=completionRate%>% Completion Rate →</div>
				</a>

				<!-- 6. Scheduled Meetings -->
				<a href="calendarView" class="card-kpi">
					<div class="kpi-top">
						<div>
							<div class="kpi-title">Upcoming Meetings</div>
							<div class="kpi-value"><%=upcomingMeetings%></div>
						</div>
						<div class="kpi-icon-box purple-grad">
							<i class="fa-solid fa-handshake"></i>
						</div>
					</div>
					<div class="kpi-link-hint">Calendar Schedule →</div>
				</a>

			</div>

			<!-- Analytics & Health Gauges -->
			<div class="analytics-grid">

				<!-- Task Pipeline Health -->
				<div class="analytics-card">
					<div class="analytics-header">
						<div class="analytics-title">
							<i class="fa-solid fa-chart-pie" style="color: #6366f1;"></i> Task Operations Pipeline
						</div>
						<span style="font-weight:800; font-size:14px; color:#10b981;"><%=completionRate%>% Done</span>
					</div>

					<%
					int compPct = totalTasks > 0 ? (completedTasks * 100) / totalTasks : 0;
					int inProgPct = totalTasks > 0 ? (inProgressTasks * 100) / totalTasks : 0;
					int pendPct = totalTasks > 0 ? (pendingTasks * 100) / totalTasks : 0;
					int overPct = totalTasks > 0 ? (overdueTasks * 100) / totalTasks : 0;
					%>
					<div class="multi-bar">
						<div class="bar-seg seg-done" style="width: <%=compPct%>%;" title="Completed: <%=completedTasks%>"></div>
						<div class="bar-seg seg-prog" style="width: <%=inProgPct%>%;" title="In Progress: <%=inProgressTasks%>"></div>
						<div class="bar-seg seg-pend" style="width: <%=pendPct%>%;" title="Pending: <%=pendingTasks%>"></div>
						<div class="bar-seg seg-over" style="width: <%=overPct%>%;" title="Overdue: <%=overdueTasks%>"></div>
					</div>

					<div class="legend-row">
						<div class="legend-item"><span class="legend-dot" style="background:#10b981;"></span> Completed (<%=completedTasks%>)</div>
						<div class="legend-item"><span class="legend-dot" style="background:#6366f1;"></span> In Progress (<%=inProgressTasks%>)</div>
						<div class="legend-item"><span class="legend-dot" style="background:#f59e0b;"></span> Pending (<%=pendingTasks%>)</div>
						<div class="legend-item"><span class="legend-dot" style="background:#f43f5e;"></span> Overdue (<%=overdueTasks%>)</div>
					</div>
				</div>

				<!-- Today's Attendance Pulse -->
				<div class="analytics-card">
					<div class="analytics-header">
						<div class="analytics-title">
							<i class="fa-solid fa-users-viewfinder" style="color: #0284c7;"></i> Today's Workforce Attendance
						</div>
						<span style="font-weight:800; font-size:14px; color:#0284c7;"><%=presentCount%> / <%=employeeCount%> Present</span>
					</div>

					<%
					int presPct = employeeCount > 0 ? (presentCount * 100) / employeeCount : 0;
					int absPct = employeeCount > 0 ? (absentCount * 100) / employeeCount : 0;
					int halfPct = employeeCount > 0 ? (halfDayCount * 100) / employeeCount : 0;
					int otherPct = Math.max(0, 100 - presPct - absPct - halfPct);
					%>
					<div class="multi-bar">
						<div class="bar-seg" style="width: <%=presPct%>%; background: #10b981;" title="Present: <%=presentCount%>"></div>
						<div class="bar-seg" style="width: <%=halfPct%>%; background: #f59e0b;" title="Half Day: <%=halfDayCount%>"></div>
						<div class="bar-seg" style="width: <%=absPct%>%; background: #f43f5e;" title="Absent: <%=absentCount%>"></div>
						<div class="bar-seg" style="width: <%=otherPct%>%; background: #cbd5e1;" title="Not Logged"></div>
					</div>

					<div class="legend-row">
						<div class="legend-item"><span class="legend-dot" style="background:#10b981;"></span> Present (<%=presentCount%>)</div>
						<div class="legend-item"><span class="legend-dot" style="background:#f59e0b;"></span> Half-Day (<%=halfDayCount%>)</div>
						<div class="legend-item"><span class="legend-dot" style="background:#f43f5e;"></span> Absent (<%=absentCount%>)</div>
					</div>
				</div>

			</div>

			<!-- Live Action Center: Pending Leaves & Today's Schedule -->
			<div class="dual-section-grid">

				<!-- Pending Leaves Approvals -->
				<div class="widget-box">
					<div class="widget-header">
						<div class="widget-title">
							<i class="fa-solid fa-calendar-check" style="color: #f59e0b;"></i> Pending Leave Approvals
						</div>
						<a href="leaveRequests" class="widget-link">View All (<%=pendingLeaves%>) →</a>
					</div>

					<div class="widget-content">
						<%
						if (pendingLeavesList != null && !pendingLeavesList.isEmpty()) {
							int count = 0;
							for (Leave l : pendingLeavesList) {
								if (count++ >= 4) break;
						%>
						<div class="leave-approval-item">
							<div class="leave-user-detail">
								<span class="leave-type-pill"><%=l.getLeaveType() != null ? l.getLeaveType() : "Leave"%></span>
								<h4>Emp ID: #<%=l.getEmployeeId()%></h4>
								<p>
									<i class="fa-regular fa-calendar"></i> <%=l.getStartDate()%> to <%=l.getEndDate()%>
									<% if (l.getReason() != null && !l.getReason().isBlank()) { %>
										• "<%=l.getReason()%>"
									<% } %>
								</p>
							</div>
							<div class="leave-action-btns">
								<form action="approveLeave" method="POST" style="display:inline;">
									<input type="hidden" name="leaveId" value="<%=l.getLeaveId()%>" />
									<button type="submit" class="btn-act-app" style="border:none; cursor:pointer;" title="Approve Leave (Auto-check Paid Balance)">
										<i class="fa-solid fa-check"></i> Approve
									</button>
								</form>
								<form action="approveLeave" method="POST" style="display:inline;">
									<input type="hidden" name="leaveId" value="<%=l.getLeaveId()%>" />
									<input type="hidden" name="asLop" value="true" />
									<button type="submit" class="btn-act-app" style="border:none; cursor:pointer; background: #c2410c;" title="Approve Leave as Loss of Pay (LOP)">
										<i class="fa-solid fa-user-minus"></i> Approve LOP
									</button>
								</form>
								<form action="rejectLeave" method="POST" style="display:inline;">
									<input type="hidden" name="leaveId" value="<%=l.getLeaveId()%>" />
									<button type="submit" class="btn-act-rej" style="border:none; cursor:pointer;">
										<i class="fa-solid fa-xmark"></i> Reject
									</button>
								</form>
							</div>
						</div>
						<%
							}
						} else {
						%>
						<div class="empty-state">
							<i class="fa-solid fa-clipboard-check"></i>
							<p>No pending leave applications requiring approval.</p>
						</div>
						<% } %>
					</div>
				</div>

				<!-- Today's Meetings & Rooms -->
				<div class="widget-box">
					<div class="widget-header">
						<div class="widget-title">
							<i class="fa-solid fa-video" style="color: #8b5cf6;"></i> Today's Schedule &amp; Meetings
						</div>
						<a href="calendarView" class="widget-link">Schedule →</a>
					</div>

					<div class="widget-content">
						<%
						if (todayMeetings != null && !todayMeetings.isEmpty()) {
							int count = 0;
							for (Meeting m : todayMeetings) {
								if (count++ >= 4) break;
						%>
						<div class="meet-row">
							<div>
								<h4 style="font-size:14px; font-weight:700; color:#0f172a; margin-bottom:2px;"><%=m.getTitle()%></h4>
								<p style="font-size:12px; color:#64748b;">
									<i class="fa-regular fa-clock"></i> <%=m.getStartTime()%> - <%=m.getEndTime()%>
									<% if (m.getRoom() != null && !m.getRoom().isBlank()) { %>
										• <i class="fa-solid fa-door-open"></i> <%=m.getRoom()%>
									<% } %>
								</p>
							</div>
							<div>
								<% if (m.getMeetingLink() != null && !m.getMeetingLink().isBlank()) { %>
									<a href="<%=m.getMeetingLink()%>" target="_blank" class="btn-act-app" style="background:#0284c7;">
										Join
									</a>
								<% } else { %>
									<span style="font-size:11px; font-weight:700; color:#64748b;"><%=m.getStatus()%></span>
								<% } %>
							</div>
						</div>
						<%
							}
						} else {
						%>
						<div class="empty-state">
							<i class="fa-solid fa-calendar-xmark"></i>
							<p>No meetings scheduled for today.</p>
						</div>
						<% } %>
					</div>
				</div>

			</div>

			<!-- Recent Employee Onboardings Table -->
			<div class="recent-emp-box">
				<div class="widget-header">
					<div class="widget-title">
						<i class="fa-solid fa-users" style="color: #ec4899;"></i> Workforce Directory Preview
					</div>
					<a href="viewEmployeesServlet" class="widget-link">View Full Directory →</a>
				</div>

				<div style="overflow-x: auto;">
					<table class="emp-table">
						<thead>
							<tr>
								<th>Employee</th>
								<th>Department</th>
								<th>Designation</th>
								<th>Phone</th>
								<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<%
							if (recentEmployees != null && !recentEmployees.isEmpty()) {
								for (Employee emp : recentEmployees) {
									String photo = (emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank())
											? emp.getProfile_photo()
											: "https://ui-avatars.com/api/?name=" + emp.getEmployee_name() + "&background=6366f1&color=fff&bold=true";
							%>
							<tr>
								<td>
									<div class="emp-name-col">
										<img src="<%=photo%>" class="emp-mini-photo" alt="Photo" />
										<div>
											<div><%=emp.getEmployee_name()%></div>
											<small style="color:#64748b; font-size:11.5px;"><%=emp.getEmail()%></small>
										</div>
									</div>
								</td>
								<td><%=emp.getDepartment() != null ? emp.getDepartment() : "—"%></td>
								<td><%=emp.getDesignation() != null ? emp.getDesignation() : "—"%></td>
								<td><%=emp.getPhone() != 0 ? emp.getPhone() : "—"%></td>
								<td>
									<a href="viewEmployeesServlet" style="color:#4f46e5; font-weight:700; font-size:12.5px; text-decoration:none;">
										View →
									</a>
								</td>
							</tr>
							<%
								}
							} else {
							%>
							<tr>
								<td colspan="5" style="text-align:center; padding:20px; color:#94a3b8;">No employees in directory yet.</td>
							</tr>
							<% } %>
						</tbody>
					</table>
				</div>
			</div>

		</div>
	</div>

	<!-- Live Clock Script -->
	<script>
	function updateLiveClock() {
		const now = new Date();
		let hours = now.getHours();
		let minutes = now.getMinutes();
		let seconds = now.getSeconds();
		const ampm = hours >= 12 ? 'PM' : 'AM';
		hours = hours % 12;
		hours = hours ? hours : 12;
		const hoursStr = hours < 10 ? '0' + hours : hours;
		const minutesStr = minutes < 10 ? '0' + minutes : minutes;
		const secondsStr = seconds < 10 ? '0' + seconds : seconds;
		const el = document.getElementById('liveClock');
		if (el) {
			el.textContent = hoursStr + ':' + minutesStr + ':' + secondsStr + ' ' + ampm;
		}
	}
	setInterval(updateLiveClock, 1000);
	updateLiveClock();
	</script>
</body>
</html>