<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Leave"%>
<%@ page import="com.rajesh.elams.model.Task"%>
<%@ page import="com.rajesh.elams.model.Priority"%>
<%@ page import="com.rajesh.elams.model.TaskStatus"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="com.rajesh.elams.model.PayrollSummary"%>
<%@ page import="com.rajesh.elams.model.Payroll"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Locale"%>

<%
User manager = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");

boolean isAuthorized = manager != null && role != null
		&& ("manager".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role));

if (!isAuthorized) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

if (request.getAttribute("totalTasks") == null) {
	response.sendRedirect(request.getContextPath() + "/managerDashboard");
	return;
}

String managerEmail = (manager != null && manager.getEmail() != null) ? manager.getEmail() : "Manager";

Employee employee = (Employee) session.getAttribute("employee");
if (employee == null && manager != null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(manager.getEmail());
	} catch (Exception ignored) {}
}

String displayName = employee != null && employee.getEmployee_name() != null ? employee.getEmployee_name() : managerEmail.split("@")[0];
displayName = Character.toUpperCase(displayName.charAt(0)) + (displayName.length() > 1 ? displayName.substring(1) : "");

String managerPhoto = (employee != null && employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + displayName + "&background=2563eb&color=fff&bold=true";

String department = employee != null && employee.getDepartment() != null ? employee.getDepartment() : "Operations";
String currentDateStr = new SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date());

int totalTasksVal = request.getAttribute("totalTasks") != null ? (Integer) request.getAttribute("totalTasks") : 0;
int completedTasksVal = request.getAttribute("completedTasks") != null ? (Integer) request.getAttribute("completedTasks") : 0;
int inProgressTasksVal = request.getAttribute("inProgressTasks") != null ? (Integer) request.getAttribute("inProgressTasks") : 0;
int pendingTasksVal = request.getAttribute("pendingTasks") != null ? (Integer) request.getAttribute("pendingTasks") : 0;
int overdueTasksVal = request.getAttribute("overdueTasks") != null ? (Integer) request.getAttribute("overdueTasks") : 0;
int completionRateVal = request.getAttribute("completionRate") != null ? (Integer) request.getAttribute("completionRate") : 0;

int todayPresentVal = request.getAttribute("todayPresent") != null ? (Integer) request.getAttribute("todayPresent") : 0;
int todayAbsentVal = request.getAttribute("todayAbsent") != null ? (Integer) request.getAttribute("todayAbsent") : 0;
int todayHalfDayVal = request.getAttribute("todayHalfDay") != null ? (Integer) request.getAttribute("todayHalfDay") : 0;
int totalEmployeesVal = request.getAttribute("totalEmployees") != null ? (Integer) request.getAttribute("totalEmployees") : 0;
int pendingLeavesCountVal = request.getAttribute("pendingLeavesCount") != null ? (Integer) request.getAttribute("pendingLeavesCount") : 0;

int totalMeetingsVal = request.getAttribute("totalMeetings") != null ? (Integer) request.getAttribute("totalMeetings") : 0;
int upcomingMeetingsVal = request.getAttribute("upcomingMeetings") != null ? (Integer) request.getAttribute("upcomingMeetings") : 0;

@SuppressWarnings("unchecked")
List<Employee> teamMembers = (List<Employee>) request.getAttribute("teamMembers");

@SuppressWarnings("unchecked")
List<Leave> pendingLeaves = (List<Leave>) request.getAttribute("pendingLeaves");

@SuppressWarnings("unchecked")
List<Task> highPriorityTasks = (List<Task>) request.getAttribute("highPriorityTasks");

@SuppressWarnings("unchecked")
List<Meeting> todayMeetings = (List<Meeting>) request.getAttribute("todayMeetings");

int teamAttendanceRate = totalEmployeesVal > 0 ? (todayPresentVal * 100) / totalEmployeesVal : 0;
String activePage = "dashboard";

PayrollSummary teamPayrollSummary = (PayrollSummary) request.getAttribute("teamPayrollSummary");
@SuppressWarnings("unchecked")
List<Payroll> teamPayrolls = (List<Payroll>) request.getAttribute("teamPayrolls");
String curMonthName = (String) request.getAttribute("curMonthName");
if (curMonthName == null) curMonthName = "August";
int curYearVal = request.getAttribute("curYear") != null ? (Integer) request.getAttribute("curYear") : 2026;

NumberFormat currFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Manager Command Center | RChips Solutions Suite</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
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
body { background: var(--surface-bg); color: var(--text-primary); min-height: 100vh; display: flex; overflow-x: hidden; }
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

/* Sticky Top Header Bar with Right Aligned Notification Bell */
.top-header-bar {
	height: 72px;
	background: rgba(255, 255, 255, 0.92);
	backdrop-filter: blur(16px);
	-webkit-backdrop-filter: blur(16px);
	border-bottom: 1px solid var(--border-color);
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 32px;
	position: sticky;
	top: 0;
	z-index: 90;
	margin: -32px -32px 28px -32px;
	box-shadow: 0 4px 20px rgba(15, 23, 42, 0.04);
}

.top-header-left {
	display: flex;
	align-items: center;
	gap: 16px;
}

.top-header-brand {
	display: flex;
	align-items: center;
	gap: 10px;
	font-size: 18px;
	font-weight: 800;
	color: #0f172a;
	letter-spacing: -0.4px;
}

.top-header-brand i {
	color: var(--blue-primary);
	font-size: 18px;
	background: #eff6ff;
	width: 38px;
	height: 38px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	border: 1px solid #bfdbfe;
}

.top-header-badge {
	font-size: 11px;
	font-weight: 800;
	color: #059669;
	background: #ecfdf5;
	border: 1px solid #a7f3d0;
	padding: 4px 12px;
	border-radius: 20px;
	display: flex;
	align-items: center;
	gap: 6px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.live-pulse-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: #10b981;
	display: inline-block;
	box-shadow: 0 0 8px #10b981;
}

.top-header-right {
	display: flex;
	align-items: center;
	gap: 16px;
}

.header-clock-pill {
	background: #f1f5f9;
	border: 1px solid #e2e8f0;
	padding: 7px 16px;
	border-radius: 50px;
	display: flex;
	align-items: center;
	gap: 8px;
	font-size: 12.5px;
	font-weight: 700;
	color: #0f172a;
	font-family: 'JetBrains Mono', monospace;
}

.header-clock-pill i {
	color: var(--blue-primary);
}

.manager-profile-pill {
	display: flex;
	align-items: center;
	gap: 10px;
	background: #ffffff;
	border: 1px solid #e2e8f0;
	padding: 4px 14px 4px 5px;
	border-radius: 50px;
	font-size: 13px;
	font-weight: 700;
	color: #0f172a;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.manager-profile-pill img {
	width: 32px;
	height: 32px;
	border-radius: 50%;
	object-fit: cover;
}

.topbar-notif-container {
	display: flex;
	align-items: center;
}

.topbar-notif-container .notif-bell-btn {
	background: #f1f5f9 !important;
	border-color: #cbd5e1 !important;
	color: #0f172a !important;
}

.topbar-notif-container .notif-bell-btn:hover,
.topbar-notif-container .notif-bell-btn.active {
	background: var(--blue-primary) !important;
	color: #ffffff !important;
	border-color: var(--blue-primary) !important;
}

/* Hero Royal Blue Banner */
.hero-banner {
	background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #1e3a8a 100%);
	border-radius: 24px;
	padding: 30px 36px;
	color: #ffffff;
	margin-bottom: 28px;
	position: relative;
	overflow: hidden;
	box-shadow: 0 16px 36px rgba(15, 23, 42, 0.15);
}

.hero-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 20px;
}

.hero-user-info { display: flex; align-items: center; gap: 18px; }
.hero-avatar-img { width: 68px; height: 68px; border-radius: 20px; object-fit: cover; border: 3px solid rgba(255, 255, 255, 0.25); box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3); }

.role-badge {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 5px 14px;
	border-radius: 20px;
	background: rgba(255, 255, 255, 0.15);
	backdrop-filter: blur(8px);
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 6px;
	color: #60a5fa;
	border: 1px solid rgba(96, 165, 250, 0.3);
}

.hero-user-info h1 { font-size: 26px; font-weight: 800; letter-spacing: -0.5px; margin-bottom: 3px; }
.hero-user-info p { font-size: 13.5px; color: #94a3b8; font-weight: 500; }

.live-clock-card {
	background: rgba(255, 255, 255, 0.08);
	backdrop-filter: blur(8px);
	border: 1px solid rgba(255, 255, 255, 0.18);
	padding: 14px 22px;
	border-radius: 18px;
	text-align: right;
}
.live-clock-time { font-family: 'JetBrains Mono', monospace; font-size: 22px; font-weight: 800; color: white; }
.live-clock-date { font-size: 11.5px; color: #cbd5e1; margin-top: 2px; font-weight: 600; }

/* Quick Action Shortcuts */
.quick-shortcuts-row { display: flex; gap: 12px; margin-bottom: 28px; flex-wrap: wrap; }
.btn-shortcut {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 11px 20px;
	border-radius: 14px;
	font-size: 13px;
	font-weight: 700;
	background: #ffffff;
	border: 1px solid var(--border-color);
	color: #334155;
	box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
	transition: all 0.2s ease;
}
.btn-shortcut:hover {
	transform: translateY(-2px);
	border-color: var(--blue-primary);
	color: var(--blue-primary);
	box-shadow: 0 8px 20px rgba(37, 99, 235, 0.12);
}

/* 5 KPI Cards Grid */
.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 18px; margin-bottom: 28px; }
.kpi-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 22px;
	border: 1px solid var(--border-color);
	box-shadow: 0 4px 18px rgba(15, 23, 42, 0.03);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	transition: all 0.25s ease;
}
.kpi-card:hover { transform: translateY(-4px); border-color: #bfdbfe; box-shadow: 0 10px 25px rgba(37, 99, 235, 0.08); }

.kpi-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
.kpi-title { font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }
.kpi-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; color: white; }

.icon-blue { background: linear-gradient(135deg, #2563eb, #1d4ed8); box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }
.icon-emerald { background: linear-gradient(135deg, #10b981, #059669); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
.icon-amber { background: linear-gradient(135deg, #f59e0b, #d97706); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3); }
.icon-purple { background: linear-gradient(135deg, #8b5cf6, #7c3aed); box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3); }

.kpi-val { font-size: 28px; font-weight: 800; color: #0f172a; font-family: 'JetBrains Mono', monospace; }
.kpi-sub { font-size: 11.5px; font-weight: 700; color: var(--text-secondary); margin-top: 6px; }

/* Delivery Progress Card */
.progress-card { padding: 24px 28px; margin-bottom: 28px; }
.progress-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; }
.progress-header h3 { font-size: 16px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px; }

.stacked-progress-track { height: 14px; border-radius: 10px; background: #e2e8f0; display: flex; overflow: hidden; margin: 12px 0; }
.seg-comp { background: #10b981; }
.seg-prog { background: #2563eb; }
.seg-pend { background: #f59e0b; }
.seg-over { background: #ef4444; }

.progress-legends { display: flex; gap: 20px; flex-wrap: wrap; font-size: 12px; font-weight: 700; color: #475569; }
.legend-dot-item { display: flex; align-items: center; gap: 6px; }
.dot-pill { width: 9px; height: 9px; border-radius: 50%; }

/* Dual Section Grid */
.dual-pane-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 28px; }
@media (max-width: 1050px) { .dual-pane-grid { grid-template-columns: 1fr; } }

.widget-card { padding: 24px; }
.widget-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; padding-bottom: 12px; border-bottom: 1px solid var(--border-color); }
.widget-title { font-size: 16px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 10px; }
.widget-link { font-size: 12.5px; font-weight: 700; color: var(--blue-primary); }

.item-row { background: #f8fafc; border: 1px solid var(--border-color); border-radius: 14px; padding: 14px 16px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; }
.empty-box { text-align: center; padding: 32px 20px; color: var(--text-secondary); }
.empty-box i { font-size: 32px; color: #cbd5e1; margin-bottom: 8px; }

/* Team Roster Section */
.roster-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 16px; margin-top: 16px; }
.roster-card { background: #f8fafc; border: 1px solid var(--border-color); border-radius: 16px; padding: 16px; transition: all 0.2s; }
.roster-card:hover { background: #ffffff; border-color: #bfdbfe; transform: translateY(-2px); box-shadow: 0 6px 18px rgba(37, 99, 235, 0.08); }
.roster-user { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.roster-img { width: 44px; height: 44px; border-radius: 12px; object-fit: cover; }
.btn-roster-action { flex: 1; padding: 7px; border-radius: 8px; font-size: 11.5px; font-weight: 700; text-align: center; border: none; cursor: pointer; transition: all 0.15s; }
</style>
</head>

<body>
<div class="app-wrapper">

	<!-- Unified Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Workspace -->
	<div class="main-content">

		<!-- Sticky Top Header Bar with Right Aligned Notification Bar -->
		<header class="top-header-bar">
			<div class="top-header-left">
				<div class="top-header-brand">
					<i class="fa-solid fa-briefcase"></i>
					<span>Operations Command Center</span>
				</div>
				<div class="top-header-badge">
					<span class="live-pulse-dot"></span> LIVE OVERHEAD
				</div>
			</div>

			<div class="top-header-right">
				<div class="header-clock-pill">
					<i class="fa-regular fa-clock"></i>
					<span id="topLiveClock">--:--:--</span>
				</div>

				<div class="manager-profile-pill">
					<img src="<%=managerPhoto%>" alt="Manager Avatar" />
					<span><%=displayName%></span>
				</div>

				<!-- Right Aligned Notification Bell Component -->
				<div class="topbar-notif-container">
					<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
				</div>
			</div>
		</header>

		<!-- Hero Royal Blue Banner -->
		<div class="hero-banner">
			<div class="hero-top">
				<div class="hero-user-info">
					<img src="<%=managerPhoto%>" class="hero-avatar-img" alt="Manager Avatar" />
					<div>
						<div class="role-badge"><i class="fa-solid fa-user-tie"></i> Operations Manager &bull; <%=department%></div>
						<h1>Welcome Back, <%=displayName%> 👋</h1>
						<p>Team Attendance, Task Operations, and Workflow Oversight Hub</p>
					</div>
				</div>

				<div class="live-clock-card">
					<div class="live-clock-time" id="liveClock">--:--:--</div>
					<div class="live-clock-date"><%=currentDateStr%></div>
				</div>
			</div>
		</div>

		<!-- Quick Action Shortcuts -->
		<div class="quick-shortcuts-row">
			<a href="createTask" class="btn-shortcut">
				<i class="fa-solid fa-square-plus" style="color: #2563eb;"></i> Assign Task
			</a>
			<a href="leaveRequests" class="btn-shortcut">
				<i class="fa-solid fa-calendar-check" style="color: #f59e0b;"></i> Team Leaves (<%=pendingLeavesCountVal%>)
			</a>
			<a href="scheduleMeeting" class="btn-shortcut">
				<i class="fa-solid fa-calendar-plus" style="color: #0284c7;"></i> Schedule Meeting
			</a>
			<a href="attendanceReportServlet" class="btn-shortcut">
				<i class="fa-solid fa-chart-column" style="color: #10b981;"></i> Attendance Report
			</a>
			<a href="sendNotification" class="btn-shortcut">
				<i class="fa-solid fa-paper-plane" style="color: #ec4899;"></i> Team Announcement
			</a>
		</div>

		<!-- 5 KPI Cards Grid -->
		<div class="kpi-grid">
			<div class="kpi-card" style="border-left: 4px solid #2563eb;">
				<div class="kpi-head">
					<span class="kpi-title">Total Team</span>
					<div class="kpi-icon icon-blue"><i class="fa-solid fa-users"></i></div>
				</div>
				<div class="kpi-val"><%=totalEmployeesVal%></div>
				<div class="kpi-sub">Assigned Team Members</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #10b981;">
				<div class="kpi-head">
					<span class="kpi-title">Present Today</span>
					<div class="kpi-icon icon-emerald"><i class="fa-solid fa-user-check"></i></div>
				</div>
				<div class="kpi-val"><%=todayPresentVal%> <small style="font-size: 14px; color: #10b981;">(<%=teamAttendanceRate%>%)</small></div>
				<div class="kpi-sub"><%=todayAbsentVal%> Absent &bull; <%=todayHalfDayVal%> Half-day</div>
			</div>

			<a href="leaveRequests" class="kpi-card" style="border-left: 4px solid #f59e0b;">
				<div class="kpi-head">
					<span class="kpi-title">Pending Leaves</span>
					<div class="kpi-icon icon-amber"><i class="fa-solid fa-calendar-days"></i></div>
				</div>
				<div class="kpi-val"><%=pendingLeavesCountVal%></div>
				<div class="kpi-sub" style="color: #2563eb;">Review Applications &rarr;</div>
			</a>

			<a href="viewTasksServlet" class="kpi-card" style="border-left: 4px solid #8b5cf6;">
				<div class="kpi-head">
					<span class="kpi-title">Team Tasks</span>
					<div class="kpi-icon icon-purple"><i class="fa-solid fa-list-check"></i></div>
				</div>
				<div class="kpi-val"><%=totalTasksVal%></div>
				<div class="kpi-sub" style="color: #2563eb;"><%=completionRateVal%>% Completion Rate &rarr;</div>
			</a>

			<a href="calendarView" class="kpi-card" style="border-left: 4px solid #0284c7;">
				<div class="kpi-head">
					<span class="kpi-title">Upcoming Meetings</span>
					<div class="kpi-icon icon-blue"><i class="fa-solid fa-video"></i></div>
				</div>
				<div class="kpi-val"><%=upcomingMeetingsVal%></div>
				<div class="kpi-sub" style="color: #2563eb;">Meeting Calendar &rarr;</div>
			</a>
		</div>

		<!-- Task Health Progress Bar -->
		<div class="white-card progress-card">
			<div class="progress-header">
				<h3><i class="fa-solid fa-chart-line" style="color: #2563eb;"></i> Team Task Delivery & Health Progress</h3>
				<span style="font-size: 15px; font-weight: 800; color: #10b981;"><%=completionRateVal%>% Completed</span>
			</div>

			<%
			int cPct = totalTasksVal > 0 ? (completedTasksVal * 100) / totalTasksVal : 0;
			int ipPct = totalTasksVal > 0 ? (inProgressTasksVal * 100) / totalTasksVal : 0;
			int pPct = totalTasksVal > 0 ? (pendingTasksVal * 100) / totalTasksVal : 0;
			int oPct = totalTasksVal > 0 ? (overdueTasksVal * 100) / totalTasksVal : 0;
			%>
			<div class="stacked-progress-track">
				<div class="seg-comp" style="width: <%=cPct%>%;" title="Completed"></div>
				<div class="seg-prog" style="width: <%=ipPct%>%;" title="In Progress"></div>
				<div class="seg-pend" style="width: <%=pPct%>%;" title="Pending"></div>
				<div class="seg-over" style="width: <%=oPct%>%;" title="Overdue"></div>
			</div>

			<div class="progress-legends">
				<div class="legend-dot-item"><span class="dot-pill" style="background:#10b981;"></span> Completed (<%=completedTasksVal%>)</div>
				<div class="legend-dot-item"><span class="dot-pill" style="background:#2563eb;"></span> In Progress (<%=inProgressTasksVal%>)</div>
				<div class="legend-dot-item"><span class="dot-pill" style="background:#f59e0b;"></span> Pending (<%=pendingTasksVal%>)</div>
				<div class="legend-dot-item"><span class="dot-pill" style="background:#ef4444;"></span> Overdue (<%=overdueTasksVal%>)</div>
			</div>
		</div>

		<!-- Interactive Click to Open Team Salary Summary Card -->
		<div class="white-card widget-card" style="margin-bottom: 28px;">
			<div onclick="toggleTeamSalaryDrawer()" style="display: flex; justify-content: space-between; align-items: center; cursor: pointer; user-select: none;">
				<div class="widget-title">
					<i class="fa-solid fa-money-check-dollar" style="color: #10b981;"></i> Team Salary Summary (<%=curMonthName%> <%=curYearVal%>)
				</div>
				<div style="display: flex; align-items: center; gap: 12px;">
					<span style="font-size: 13px; font-weight: 800; color: #059669; font-family: 'JetBrains Mono', monospace; background: #f0fdf4; padding: 4px 12px; border-radius: 10px; border: 1px solid #bbf7d0;">
						Net: <%=teamPayrollSummary != null ? currFmt.format(teamPayrollSummary.getTotalNetAmount()) : "₹0.00"%>
					</span>
					<button type="button" class="btn-shortcut" style="padding: 6px 14px; font-size: 12.5px; color: #2563eb; border-color: #bfdbfe; background: #eff6ff;">
						<span id="salaryBtnLabel">Click to Open</span> <i class="fa-solid fa-chevron-down" id="salaryChevronIcon" style="transition: transform 0.3s;"></i>
					</button>
				</div>
			</div>

			<!-- Collapsible Drawer -->
			<div id="teamSalaryDetailsDrawer" style="display: none; padding-top: 20px; border-top: 1px solid #f1f5f9; margin-top: 16px;">
				<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 20px;">
					<div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 16px; padding: 16px; text-align: center;">
						<small style="display: block; font-size: 11px; font-weight: 800; color: #166534; text-transform: uppercase; margin-bottom: 4px;">Total Disbursable Net</small>
						<span style="font-size: 20px; font-weight: 800; color: #15803d; font-family: 'JetBrains Mono', monospace;"><%=teamPayrollSummary != null ? currFmt.format(teamPayrollSummary.getTotalNetAmount()) : "₹0.00"%></span>
					</div>
					<div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 16px; padding: 16px; text-align: center;">
						<small style="display: block; font-size: 11px; font-weight: 800; color: #1e40af; text-transform: uppercase; margin-bottom: 4px;">Total Gross Budget</small>
						<span style="font-size: 20px; font-weight: 800; color: #1d4ed8; font-family: 'JetBrains Mono', monospace;"><%=teamPayrollSummary != null ? currFmt.format(teamPayrollSummary.getTotalGrossAmount()) : "₹0.00"%></span>
					</div>
					<div style="background: #fff5f5; border: 1px solid #fca5a5; border-radius: 16px; padding: 16px; text-align: center;">
						<small style="display: block; font-size: 11px; font-weight: 800; color: #991b1b; text-transform: uppercase; margin-bottom: 4px;">Deductions &amp; LOP Sum</small>
						<span style="font-size: 20px; font-weight: 800; color: #dc2626; font-family: 'JetBrains Mono', monospace;"><%=teamPayrollSummary != null ? currFmt.format(teamPayrollSummary.getTotalDeductionsAmount() + teamPayrollSummary.getTotalLopDeductionsAmount()) : "₹0.00"%></span>
					</div>
				</div>

				<% if (teamPayrolls != null && !teamPayrolls.isEmpty()) { %>
				<div style="overflow-x: auto;">
					<table style="width: 100%; border-collapse: separate; border-spacing: 0 6px; font-size: 13.5px;">
						<thead>
							<tr style="color: #64748b; font-size: 11.5px; text-transform: uppercase; font-weight: 800;">
								<th style="text-align: left; padding: 10px 14px;">Employee</th>
								<th style="text-align: left; padding: 10px 14px;">Department</th>
								<th style="text-align: left; padding: 10px 14px;">Gross Salary</th>
								<th style="text-align: left; padding: 10px 14px;">Net Payable</th>
								<th style="text-align: left; padding: 10px 14px;">Status</th>
							</tr>
						</thead>
						<tbody>
							<% for (Payroll p : teamPayrolls) { %>
							<tr style="background: #f8fafc; border-radius: 10px;">
								<td style="padding: 12px 14px; font-weight: 700; color: #0f172a;"><%=p.getEmployeeName()%></td>
								<td style="padding: 12px 14px; color: #64748b;"><%=p.getDepartment() != null ? p.getDepartment() : "General"%></td>
								<td style="padding: 12px 14px; font-family: 'JetBrains Mono', monospace;"><%=currFmt.format(p.getGrossSalary())%></td>
								<td style="padding: 12px 14px; font-family: 'JetBrains Mono', monospace; font-weight: 800; color: #15803d;"><%=currFmt.format(p.getNetSalary())%></td>
								<td style="padding: 12px 14px;"><span style="background: #dcfce7; color: #15803d; padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 800;"><%=p.getStatus()%></span></td>
							</tr>
							<% } %>
						</tbody>
					</table>
				</div>
				<% } else { %>
				<div class="empty-box" style="padding: 16px;">No detailed payroll records available for this month.</div>
				<% } %>
			</div>
		</div>

		<!-- 2 Pane Grid: Pending Leave Requests & Urgent Tasks -->
		<div class="dual-pane-grid">
			<!-- Pane 1: Pending Leave Applications -->
			<div class="white-card widget-card">
				<div class="widget-header">
					<div class="widget-title"><i class="fa-solid fa-envelope-open-text" style="color: #f59e0b;"></i> Pending Team Leaves</div>
					<a href="leaveRequests" class="widget-link">View All (<%=pendingLeavesCountVal%>) &rarr;</a>
				</div>

				<% if (pendingLeaves != null && !pendingLeaves.isEmpty()) { 
					int maxL = Math.min(pendingLeaves.size(), 4);
					for (int i = 0; i < maxL; i++) {
						Leave l = pendingLeaves.get(i);
						String lEmpName = "EMP-" + l.getEmployeeId();
						if (teamMembers != null) {
							for (Employee e : teamMembers) {
								if (e.getEmployee_id() == l.getEmployeeId()) {
									lEmpName = e.getEmployee_name();
									break;
								}
							}
						}
				%>
				<div class="item-row">
					<div>
						<div style="font-size: 13.5px; font-weight: 800; color: #0f172a;"><%=lEmpName%></div>
						<div style="font-size: 12px; color: #64748b;"><%=l.getLeaveType()%> &bull; <%=l.getStartDate()%> to <%=l.getEndDate()%></div>
					</div>
					<div style="display: flex; gap: 6px;">
						<a href="approveLeave?leaveId=<%=l.getLeaveId()%>" class="btn-shortcut" style="padding: 6px 10px; font-size: 11.5px; color: #15803d; background: #ecfdf5; border-color: #a7f3d0;" title="Approve (Auto-check Paid Balance)">Approve</a>
						<a href="approveLeave?leaveId=<%=l.getLeaveId()%>&asLop=true" class="btn-shortcut" style="padding: 6px 10px; font-size: 11.5px; color: #c2410c; background: #fff7ed; border-color: #ffedd5;" title="Approve as Loss of Pay (LOP)">Approve LOP</a>
						<a href="rejectLeave?leaveId=<%=l.getLeaveId()%>" class="btn-shortcut" style="padding: 6px 10px; font-size: 11.5px; color: #b91c1c; background: #fff5f5; border-color: #fca5a5;">Reject</a>
					</div>
				</div>
				<% } } else { %>
				<div class="empty-box">
					<i class="fa-solid fa-circle-check"></i>
					<div>No pending leave applications to review</div>
				</div>
				<% } %>
			</div>

			<!-- Pane 2: High Priority Tasks -->
			<div class="white-card widget-card">
				<div class="widget-header">
					<div class="widget-title"><i class="fa-solid fa-fire" style="color: #ef4444;"></i> High Priority Operations</div>
					<a href="viewTasksServlet" class="widget-link">All Tasks &rarr;</a>
				</div>

				<% if (highPriorityTasks != null && !highPriorityTasks.isEmpty()) { 
					int maxT = Math.min(highPriorityTasks.size(), 4);
					for (int i = 0; i < maxT; i++) {
						Task t = highPriorityTasks.get(i);
						String tAssignee = "EMP-" + t.getEmployeeId();
						if (teamMembers != null) {
							for (Employee e : teamMembers) {
								if (e.getEmployee_id() == t.getEmployeeId()) {
									tAssignee = e.getEmployee_name();
									break;
								}
							}
						}
				%>
				<div class="item-row">
					<div>
						<div style="font-size: 13.5px; font-weight: 800; color: #0f172a;"><%=t.getTaskName()%></div>
						<div style="font-size: 12px; color: #64748b;">Assigned to: <%=tAssignee%></div>
					</div>
					<span style="font-size: 11px; font-weight: 800; padding: 4px 10px; border-radius: 20px; background: #fee2e2; color: #dc2626;"><%=t.getStatus() != null ? t.getStatus() : "PENDING"%></span>
				</div>
				<% } } else { %>
				<div class="empty-box">
					<i class="fa-solid fa-list-check"></i>
					<div>No high priority tasks pending</div>
				</div>
				<% } %>
			</div>
		</div>

		<!-- Team Roster Status Grid -->
		<div class="white-card widget-card">
			<div class="widget-header">
				<div class="widget-title"><i class="fa-solid fa-users-gear" style="color: #2563eb;"></i> Team Duty &amp; Attendance Roster</div>
				<a href="attendanceReportServlet" class="widget-link">Full Attendance Roster &rarr;</a>
			</div>

			<% if (teamMembers != null && !teamMembers.isEmpty()) { %>
			<div class="roster-grid">
				<% for (Employee tm : teamMembers) { 
					String photo = (tm.getProfile_photo() != null && !tm.getProfile_photo().isBlank())
							? tm.getProfile_photo()
							: "https://ui-avatars.com/api/?name=" + tm.getEmployee_name() + "&background=0284c7&color=fff";
				%>
				<div class="roster-card">
					<div class="roster-user">
						<img src="<%=photo%>" class="roster-img" alt="Member Avatar" />
						<div>
							<div style="font-size: 14px; font-weight: 800; color: #0f172a;"><%=tm.getEmployee_name()%></div>
							<div style="font-size: 12px; color: #64748b;"><%=tm.getDesignation() != null ? tm.getDesignation() : "Team Member"%></div>
						</div>
					</div>
					<div style="display: flex; gap: 8px; margin-top: 10px;">
						<a href="createTask?assigneeId=<%=tm.getEmployee_id()%>" class="btn-roster-action" style="background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe;">Assign Task</a>
						<a href="attendanceHistory?employeeId=<%=tm.getEmployee_id()%>" class="btn-roster-action" style="background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1;">History</a>
					</div>
				</div>
				<% } %>
			</div>
			<% } else { %>
			<div class="empty-box">
				<i class="fa-solid fa-user-group"></i>
				<div>No team members registered under your department</div>
			</div>
			<% } %>
		</div>

	</div>
</div>

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

	const timeFormatted = hoursStr + ":" + minutes + ":" + seconds + " " + ampm;
	
	const heroClockEl = document.getElementById("liveClock");
	if (heroClockEl) heroClockEl.innerText = timeFormatted;

	const topClockEl = document.getElementById("topLiveClock");
	if (topClockEl) topClockEl.innerText = timeFormatted;
}

updateClock();
setInterval(updateClock, 1000);

function toggleTeamSalaryDrawer() {
	var drawer = document.getElementById("teamSalaryDetailsDrawer");
	var label = document.getElementById("salaryBtnLabel");
	var icon = document.getElementById("salaryChevronIcon");
	if (!drawer) return;
	if (drawer.style.display === "none" || drawer.style.display === "") {
		drawer.style.display = "block";
		if (label) label.innerText = "Click to Close";
		if (icon) icon.style.transform = "rotate(180deg)";
	} else {
		drawer.style.display = "none";
		if (label) label.innerText = "Click to Open";
		if (icon) icon.style.transform = "rotate(0deg)";
	}
}
</script>
</body>
</html>
