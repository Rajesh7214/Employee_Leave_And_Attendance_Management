<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Leave"%>
<%@ page import="com.rajesh.elams.model.Notification"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="com.rajesh.elams.model.PayrollSummary"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.Month"%>
<%@ page import="java.time.format.TextStyle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || (!"hr".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role))) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

if (request.getAttribute("totalEmployees") == null) {
	response.sendRedirect(request.getContextPath() + "/hrDashboardServlet");
	return;
}

Employee employee = (Employee) session.getAttribute("employee");
if (employee == null && loggedUser != null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(loggedUser.getEmail());
		if (employee != null) {
			session.setAttribute("employee", employee);
			session.setAttribute("employeeId", employee.getEmployee_id());
		}
	} catch (Exception ignored) {}
}

String hrName = employee != null && employee.getEmployee_name() != null
		? employee.getEmployee_name()
		: (loggedUser.getEmail().split("@")[0]);
hrName = Character.toUpperCase(hrName.charAt(0)) + (hrName.length() > 1 ? hrName.substring(1) : "");
String displayName = hrName;
String hrPhoto = (employee != null && employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + hrName + "&background=2563eb&color=fff&bold=true";
String activePage = "dashboard";

int totalEmployees = (Integer) request.getAttribute("totalEmployees");
@SuppressWarnings("unchecked")
List<Employee> recentEmployees = (List<Employee>) request.getAttribute("recentEmployees");
@SuppressWarnings("unchecked")
Map<String, Integer> deptCounts = (Map<String, Integer>) request.getAttribute("deptCounts");

int presentCount = (Integer) request.getAttribute("presentCount");
int absentCount = (Integer) request.getAttribute("absentCount");
int halfDayCount = (Integer) request.getAttribute("halfDayCount");
int attendanceRate = (Integer) request.getAttribute("attendanceRate");

int pendingLeavesCount = (Integer) request.getAttribute("pendingLeavesCount");
int approvedLeavesCount = (Integer) request.getAttribute("approvedLeavesCount");
int rejectedLeavesCount = (Integer) request.getAttribute("rejectedLeavesCount");

@SuppressWarnings("unchecked")
List<Leave> pendingLeavesList = (List<Leave>) request.getAttribute("pendingLeavesList");
@SuppressWarnings("unchecked")
Map<Integer, Employee> employeeMap = (Map<Integer, Employee>) request.getAttribute("employeeMap");

PayrollSummary payrollSummary = (PayrollSummary) request.getAttribute("payrollSummary");
int hrMonth = request.getAttribute("currentMonth") != null ? (Integer) request.getAttribute("currentMonth") : LocalDate.now().getMonthValue();
int hrYear = request.getAttribute("currentYear") != null ? (Integer) request.getAttribute("currentYear") : LocalDate.now().getYear();
String hrMonthName = Month.of(hrMonth).getDisplayName(TextStyle.FULL, Locale.ENGLISH);

int openRequisitions = request.getAttribute("openRequisitions") != null ? (Integer) request.getAttribute("openRequisitions") : 6;
int activeCandidates = request.getAttribute("activeCandidates") != null ? (Integer) request.getAttribute("activeCandidates") : 24;

@SuppressWarnings("unchecked")
List<Notification> recentAnnouncements = (List<Notification>) request.getAttribute("recentAnnouncements");

@SuppressWarnings("unchecked")
List<Meeting> myMeetings = (List<Meeting>) request.getAttribute("myMeetings");
int myMeetingsCount = request.getAttribute("myMeetingsCount") != null ? (Integer) request.getAttribute("myMeetingsCount") : 0;

NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
String todayDateStr = new SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date());

String flashSuccess = (String) session.getAttribute("flashSuccess");
if (flashSuccess != null) {
	session.removeAttribute("flashSuccess");
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>HR Executive Command Center | RChips Solutions Suite</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<!-- Chart.js for Visual Analytics -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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
	background: radial-gradient(circle at 10% 10%, rgba(37, 99, 235, 0.06) 0%, transparent 45%),
	            linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

.white-card {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 20px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

/* Hero Royal Blue Banner */
.hero-banner {
	background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 50%, #2563eb 100%);
	border-radius: 24px;
	padding: 32px 38px;
	color: #ffffff;
	margin-bottom: 28px;
	position: relative;
	overflow: hidden;
	box-shadow: 0 16px 36px rgba(37, 99, 235, 0.25);
}

.hero-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 20px;
	position: relative;
	z-index: 2;
}

.greeting-block h1 {
	font-size: 28px;
	font-weight: 800;
	letter-spacing: -0.5px;
	margin-bottom: 6px;
	display: flex;
	align-items: center;
	gap: 12px;
}

.greeting-block p {
	font-size: 14px;
	color: #dbeafe;
	display: flex;
	align-items: center;
	gap: 8px;
}

.badge-role-hr {
	background: rgba(255, 255, 255, 0.2);
	backdrop-filter: blur(8px);
	border: 1px solid rgba(255, 255, 255, 0.3);
	padding: 4px 14px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 800;
	letter-spacing: 0.5px;
	text-transform: uppercase;
	color: #ffffff;
}

.hero-actions {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
	position: relative;
	z-index: 2;
}

.live-clock-badge {
	font-family: 'JetBrains Mono', monospace;
	font-size: 18px;
	font-weight: 800;
	background: rgba(255, 255, 255, 0.15);
	border: 1px solid rgba(255, 255, 255, 0.3);
	padding: 8px 18px;
	border-radius: 14px;
	color: #ffffff;
	display: flex;
	align-items: center;
	gap: 8px;
}

.btn-header {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 10px 20px;
	border-radius: 12px;
	font-size: 13.5px;
	font-weight: 800;
	text-decoration: none;
	transition: all 0.2s ease;
	cursor: pointer;
	border: none;
}

.btn-header-emerald {
	background: linear-gradient(135deg, #10b981, #059669);
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(16, 185, 129, 0.35);
}

.btn-header-glass {
	background: rgba(255, 255, 255, 0.15);
	color: #ffffff;
	border: 1px solid rgba(255, 255, 255, 0.3);
}
.btn-header-glass:hover { background: rgba(255, 255, 255, 0.25); transform: translateY(-2px); }

/* 5 KPI Cards Grid */
.kpi-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
	gap: 20px;
	margin-bottom: 32px;
}

.kpi-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 22px 24px;
	box-shadow: 0 4px 20px rgba(15, 23, 42, 0.03);
	border: 1px solid var(--border-color);
	position: relative;
	transition: all 0.25s ease;
	text-decoration: none;
	color: inherit;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.kpi-card:hover {
	transform: translateY(-4px);
	box-shadow: 0 16px 32px rgba(37, 99, 235, 0.08);
	border-color: #bfdbfe;
}

.kpi-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 14px; }
.kpi-label { font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.6px; }
.kpi-icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 18px; color: #ffffff; }

.kpi-icon-blue { background: linear-gradient(135deg, #2563eb, #1d4ed8); box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }
.kpi-icon-violet { background: linear-gradient(135deg, #8b5cf6, #7c3aed); box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3); }
.kpi-icon-cyan { background: linear-gradient(135deg, #0284c7, #0369a1); box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3); }
.kpi-icon-amber { background: linear-gradient(135deg, #f59e0b, #d97706); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3); }
.kpi-icon-emerald { background: linear-gradient(135deg, #10b981, #059669); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }

.kpi-value { font-size: 28px; font-weight: 800; color: #0f172a; letter-spacing: -0.8px; margin-bottom: 8px; }
.kpi-foot { display: flex; align-items: center; justify-content: space-between; font-size: 12px; color: var(--text-secondary); font-weight: 600; }

.kpi-tag { display: inline-flex; align-items: center; gap: 4px; padding: 3px 8px; border-radius: 6px; font-size: 11.5px; font-weight: 700; }
.kpi-tag-success { background: #dcfce7; color: #15803d; }
.kpi-tag-warning { background: #fef3c7; color: #b45309; }
.kpi-tag-info { background: #dbeafe; color: #1e40af; }

/* Dual-Pane Grid */
.dual-pane-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 28px;
	margin-bottom: 32px;
}
@media (max-width: 1050px) { .dual-pane-grid { grid-template-columns: 1fr; } }

.card-panel { padding: 26px; }
.panel-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; padding-bottom: 14px; border-bottom: 1px solid var(--border-color); }
.panel-title { font-size: 16.5px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 10px; }
.panel-link { font-size: 13px; font-weight: 700; color: var(--blue-primary); text-decoration: none; }
.panel-link:hover { text-decoration: underline; }

/* Attendance Progress & Legends */
.attendance-progress-wrap { margin-bottom: 16px; }
.att-bar-labels { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 13.5px; font-weight: 700; }
.progress-track { height: 14px; background: #e2e8f0; border-radius: 20px; overflow: hidden; display: flex; }
.progress-fill-present { background: #10b981; }
.progress-fill-half { background: #f59e0b; }
.progress-fill-absent { background: #ef4444; }

.att-legend { display: flex; justify-content: space-around; margin-top: 18px; padding-top: 14px; border-top: 1px dashed var(--border-color); }
.att-legend-item { text-align: center; }
.att-legend-item .count { font-size: 22px; font-weight: 800; font-family: 'JetBrains Mono', monospace; }
.att-legend-item .label { font-size: 12px; font-weight: 600; color: var(--text-secondary); }

/* Custom Data Table */
.custom-table { width: 100%; border-collapse: collapse; font-size: 13.5px; }
.custom-table th { background: #f8fafc; color: #475569; font-weight: 800; text-align: left; padding: 12px 14px; border-bottom: 1px solid var(--border-color); font-size: 11.5px; text-transform: uppercase; letter-spacing: 0.5px; }
.custom-table td { padding: 14px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }
.custom-table tr:hover { background: #f8fafc; }

.emp-cell { display: flex; align-items: center; gap: 12px; }
.emp-cell-avatar { width: 36px; height: 36px; border-radius: 10px; background: linear-gradient(135deg, var(--blue-primary), var(--blue-dark)); color: #ffffff; font-weight: 800; font-size: 14px; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(37, 99, 235, 0.25); }

.badge-tag { display: inline-block; padding: 4px 10px; border-radius: 8px; font-size: 11.5px; font-weight: 800; }
.badge-vacation { background: #dbeafe; color: #1e40af; }

.btn-action-sm { display: inline-flex; align-items: center; gap: 6px; padding: 7px 12px; border-radius: 10px; font-size: 12px; font-weight: 800; text-decoration: none; border: none; cursor: pointer; transition: all 0.15s ease; }
.btn-approve { background: #dcfce7; color: #15803d; }
.btn-approve:hover { background: #15803d; color: #ffffff; }
.btn-reject { background: #fee2e2; color: #b91c1c; }
.btn-reject:hover { background: #b91c1c; color: #ffffff; }

.empty-state-box { text-align: center; padding: 32px 20px; color: var(--text-secondary); }
.empty-state-box i { font-size: 36px; color: #cbd5e1; margin-bottom: 10px; }
</style>
</head>

<body>

	<!-- Include Unified Sidebar -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf"%>

	<div class="main-content">

		<!-- Top Navigation Header: Right Aligned Notifications & Profile Badge -->
		<div style="display: flex; justify-content: flex-end; align-items: center; gap: 14px; margin-bottom: 20px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf"%>
			<a href="profile.jsp" style="display: flex; align-items: center; gap: 10px; padding: 4px 16px 4px 5px; background: #ffffff; border: 1px solid #e2e8f0; border-radius: 30px; font-weight: 700; font-size: 13.5px; color: #0f172a; box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04); transition: all 0.2s;" title="My Profile">
				<img src="<%=hrPhoto%>" alt="HR Avatar" style="width: 34px; height: 34px; border-radius: 50%; object-fit: cover;" />
				<span><%=hrName%></span>
			</a>
		</div>

		<!-- Flash Message Banner -->
		<% if (flashSuccess != null) { %>
		<div style="background: #dcfce7; border: 1px solid #86efac; color: #166534; padding: 14px 20px; border-radius: 14px; margin-bottom: 24px; font-weight: 700; display: flex; align-items: center; gap: 10px;">
			<i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
			<span><%=flashSuccess%></span>
		</div>
		<% } %>

		<!-- Hero Financial & Workforce Banner -->
		<div class="hero-banner">
			<div class="hero-top">
				<div class="greeting-block">
					<div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
						<span class="badge-role-hr"><i class="fa-solid fa-shield-heart"></i> Enterprise HR Operations Command</span>
					</div>
					<h1>Welcome back, <%=hrName%>! 👋</h1>
					<p><i class="fa-regular fa-calendar-check"></i> <%=todayDateStr%> &bull; <i class="fa-solid fa-building-user"></i> Managing <%=totalEmployees%> Employees across <%=deptCounts.size()%> Departments</p>
				</div>
				<div class="hero-actions">
					<div class="live-clock-badge">
						<i class="fa-regular fa-clock" style="font-size: 16px;"></i>
						<span id="liveHrClock">00:00:00</span>
					</div>
					<a href="${pageContext.request.contextPath}/payrollDashboard" class="btn-header btn-header-emerald">
						<i class="fa-solid fa-money-check-dollar"></i> Payroll Hub
					</a>
					<a href="${pageContext.request.contextPath}/sendNotification" class="btn-header btn-header-glass">
						<i class="fa-solid fa-bullhorn"></i> Broadcast
					</a>
				</div>
			</div>
		</div>

		<!-- 5 KPI Cards Grid -->
		<div class="kpi-grid">
			<a href="${pageContext.request.contextPath}/viewEmployeesServlet" class="kpi-card" style="border-left: 4px solid #2563eb;">
				<div class="kpi-head">
					<span class="kpi-label">1. Employee Directory</span>
					<div class="kpi-icon kpi-icon-blue"><i class="fa-solid fa-users"></i></div>
				</div>
				<div class="kpi-value"><%=totalEmployees%></div>
				<div class="kpi-foot">
					<span class="kpi-tag kpi-tag-info"><i class="fa-solid fa-user-plus"></i> View Roster</span>
					<span>Active Personnel</span>
				</div>
			</a>

			<a href="${pageContext.request.contextPath}/manageSalary" class="kpi-card" style="border-left: 4px solid #8b5cf6;">
				<div class="kpi-head">
					<span class="kpi-label">2. Salary Packages</span>
					<div class="kpi-icon kpi-icon-violet"><i class="fa-solid fa-gears"></i></div>
				</div>
				<div class="kpi-value" style="font-size: 20px; font-weight: 800; color: #1e40af;">CTC Setup</div>
				<div class="kpi-foot">
					<span class="kpi-tag kpi-tag-info"><i class="fa-solid fa-sliders"></i> Configure CTC</span>
					<span>Allowances &amp; Deductions</span>
				</div>
			</a>

			<a href="${pageContext.request.contextPath}/attendanceHistory" class="kpi-card" style="border-left: 4px solid #0284c7;">
				<div class="kpi-head">
					<span class="kpi-label">3. Daily Attendance</span>
					<div class="kpi-icon kpi-icon-cyan"><i class="fa-solid fa-clock-rotate-left"></i></div>
				</div>
				<div class="kpi-value"><%=attendanceRate%>%</div>
				<div class="kpi-foot">
					<span class="kpi-tag kpi-tag-success"><i class="fa-solid fa-calendar-check"></i> Timesheets</span>
					<span><%=presentCount%> Present Today</span>
				</div>
			</a>

			<a href="${pageContext.request.contextPath}/leaveRequests" class="kpi-card" style="border-left: 4px solid #f59e0b;">
				<div class="kpi-head">
					<span class="kpi-label">4. Leave Queue</span>
					<div class="kpi-icon kpi-icon-amber"><i class="fa-solid fa-plane-arrival"></i></div>
				</div>
				<div class="kpi-value"><%=pendingLeavesCount%></div>
				<div class="kpi-foot">
					<% if (pendingLeavesCount > 0) { %>
					<span class="kpi-tag kpi-tag-warning"><i class="fa-solid fa-triangle-exclamation"></i> Action Required</span>
					<% } else { %>
					<span class="kpi-tag kpi-tag-success"><i class="fa-solid fa-check-double"></i> All Reviewed</span>
					<% } %>
					<span>Pending Applications</span>
				</div>
			</a>

			<a href="${pageContext.request.contextPath}/payrollDashboard" class="kpi-card" style="border-left: 4px solid #10b981;">
				<div class="kpi-head">
					<span class="kpi-label">5. Monthly Payroll</span>
					<div class="kpi-icon kpi-icon-emerald"><i class="fa-solid fa-money-check-dollar"></i></div>
				</div>
				<div class="kpi-value" style="font-size: 18px; font-family: 'JetBrains Mono', monospace; color: #047857;"><%=payrollSummary != null ? currencyFmt.format(payrollSummary.getTotalNetAmount()) : "₹0.00"%></div>
				<div class="kpi-foot">
					<span class="kpi-tag kpi-tag-success"><i class="fa-solid fa-bolt"></i> Disbursal Hub</span>
					<span><%=payrollSummary != null ? payrollSummary.getPendingApprovalCount() : 0%> Approvals</span>
				</div>
			</a>
		</div>

		<!-- Dual-Pane Operations Table Grid -->
		<div class="dual-pane-grid">

			<!-- Pane 1: Attendance Pulse -->
			<div class="white-card card-panel">
				<div class="panel-header">
					<div class="panel-title"><i class="fa-solid fa-chart-simple" style="color: #0284c7;"></i> Daily Attendance Pulse</div>
					<a href="${pageContext.request.contextPath}/attendanceHistory" class="panel-link">Attendance Logs <i class="fa-solid fa-arrow-right"></i></a>
				</div>
				<div class="attendance-progress-wrap">
					<div class="att-bar-labels">
						<span>Workforce Attendance Ratio</span>
						<span style="color: #15803d;"><%=presentCount%> / <%=totalEmployees%> Present (<%=attendanceRate%>%)</span>
					</div>
					<div class="progress-track">
						<%
						int presentPct = totalEmployees > 0 ? (presentCount * 100) / totalEmployees : 0;
						int halfPct = totalEmployees > 0 ? (halfDayCount * 100) / totalEmployees : 0;
						int absentPct = totalEmployees > 0 ? (absentCount * 100) / totalEmployees : 0;
						%>
						<div class="progress-fill-present" style="width: <%=presentPct%>%;" title="Present: <%=presentCount%>"></div>
						<div class="progress-fill-half" style="width: <%=halfPct%>%;" title="Half Day: <%=halfDayCount%>"></div>
						<div class="progress-fill-absent" style="width: <%=absentPct%>%;" title="Absent: <%=absentCount%>"></div>
					</div>
					<div class="att-legend">
						<div class="att-legend-item"><div class="count" style="color: #10b981;"><%=presentCount%></div><div class="label">Present</div></div>
						<div class="att-legend-item"><div class="count" style="color: #f59e0b;"><%=halfDayCount%></div><div class="label">Half Day</div></div>
						<div class="att-legend-item"><div class="count" style="color: #ef4444;"><%=absentCount%></div><div class="label">Absent</div></div>
					</div>
				</div>
			</div>

			<!-- Pane 2: Leave Requests Queue -->
			<div class="white-card card-panel">
				<div class="panel-header">
					<div class="panel-title"><i class="fa-solid fa-file-signature" style="color: #f59e0b;"></i> Pending Leave Review Queue (<%=pendingLeavesCount%>)</div>
					<a href="${pageContext.request.contextPath}/leaveRequests" class="panel-link">Manage Queue <i class="fa-solid fa-arrow-right"></i></a>
				</div>
				<% if (pendingLeavesList != null && !pendingLeavesList.isEmpty()) { %>
				<div style="overflow-x: auto;">
					<table class="custom-table">
						<thead>
							<tr>
								<th>Employee</th>
								<th>Leave Type</th>
								<th>Duration</th>
								<th>Action</th>
							</tr>
						</thead>
						<tbody>
							<%
							int leaveIdx = 0;
							for (Leave l : pendingLeavesList) {
								if (++leaveIdx > 5) break;
								Employee emp = employeeMap.get(l.getEmployeeId());
								String eName = emp != null ? emp.getEmployee_name() : "Emp #" + l.getEmployeeId();
								String dept = emp != null ? emp.getDepartment() : "General";
								String initial = !eName.isEmpty() ? String.valueOf(eName.charAt(0)).toUpperCase() : "E";
							%>
							<tr>
								<td>
									<div class="emp-cell">
										<div class="emp-cell-avatar"><%=initial%></div>
										<div>
											<div style="font-weight: 800; color: #0f172a;"><%=eName%></div>
											<div style="font-size: 11.5px; color: #64748b;"><%=dept%></div>
										</div>
									</div>
								</td>
								<td><span class="badge-tag badge-vacation"><%=l.getLeaveType()%></span></td>
								<td>
									<div style="font-weight: 700;"><%=l.getStartDate()%></div>
									<div style="font-size: 11.5px; color: #64748b;">to <%=l.getEndDate()%></div>
								</td>
								<td>
									<div style="display: flex; gap: 6px;">
										<a href="${pageContext.request.contextPath}/approveLeave?leaveId=<%=l.getLeaveId()%>" class="btn-action-sm btn-approve" title="Approve Leave (Auto-check Paid Balance)" onclick="return confirm('Approve leave application for <%=eName%>? (Auto-checks paid balance)');"><i class="fa-solid fa-check"></i></a>
										<a href="${pageContext.request.contextPath}/approveLeave?leaveId=<%=l.getLeaveId()%>&asLop=true" class="btn-action-sm" style="background: #fff7ed; color: #c2410c; border: 1px solid #ffedd5;" title="Approve Leave as Loss of Pay (LOP)" onclick="return confirm('Approve leave application for <%=eName%> AS LOSS OF PAY (LOP)?');"><i class="fa-solid fa-user-minus"></i></a>
										<a href="${pageContext.request.contextPath}/rejectLeave?leaveId=<%=l.getLeaveId()%>" class="btn-action-sm btn-reject" title="Reject Leave" onclick="return confirm('Reject leave application for <%=eName%>?');"><i class="fa-solid fa-xmark"></i></a>
									</div>
								</td>
							</tr>
							<% } %>
						</tbody>
					</table>
				</div>
				<% } else { %>
				<div class="empty-state-box">
					<i class="fa-solid fa-clipboard-check"></i>
					<h4 style="font-weight: 800; color: #0f172a;">No Pending Leave Requests</h4>
					<p>All leave applications have been processed cleanly.</p>
				</div>
				<% } %>
			</div>

		</div>

		<!-- Dynamic Analytics & Direct Controls Grid -->
		<div class="dual-pane-grid">

			<!-- Department Headcount Analytics -->
			<div class="white-card card-panel">
				<div class="panel-header">
					<div class="panel-title"><i class="fa-solid fa-chart-pie" style="color: #2563eb;"></i> Department Distribution</div>
					<a href="${pageContext.request.contextPath}/viewEmployeesServlet" class="panel-link">Full Directory <i class="fa-solid fa-arrow-right"></i></a>
				</div>
				<div style="height: 220px; position: relative;"><canvas id="deptChartHr"></canvas></div>
			</div>

			<!-- Monthly Payroll Command & Recent Joiners -->
			<div style="display: flex; flex-direction: column; gap: 24px;">

				<!-- Payroll Direct Actions -->
				<div class="white-card card-panel">
					<div class="panel-header">
						<div class="panel-title"><i class="fa-solid fa-money-check-dollar" style="color: #10b981;"></i> Monthly Payroll Direct Actions</div>
						<a href="${pageContext.request.contextPath}/payrollDashboard" class="panel-link">Payroll Hub <i class="fa-solid fa-arrow-right"></i></a>
					</div>
					<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 14px;">
						<form action="${pageContext.request.contextPath}/processPayroll" method="post">
							<input type="hidden" name="action" value="calculateBatch">
							<input type="hidden" name="month" value="<%=hrMonth%>">
							<input type="hidden" name="year" value="<%=hrYear%>">
							<button type="submit" class="btn-header btn-header-emerald" style="width: 100%; justify-content: center; background: linear-gradient(135deg, #2563eb, #1d4ed8);" onclick="return confirm('Run batch salary calculation for <%=hrMonthName%> <%=hrYear%>?');">
								<i class="fa-solid fa-bolt"></i> Run Batch Calculation
							</button>
						</form>

						<form action="${pageContext.request.contextPath}/processPayroll" method="post">
							<input type="hidden" name="action" value="approveMonth">
							<input type="hidden" name="month" value="<%=hrMonth%>">
							<input type="hidden" name="year" value="<%=hrYear%>">
							<button type="submit" class="btn-header btn-header-emerald" style="width: 100%; justify-content: center;" onclick="return confirm('Executive approve batch payroll for <%=hrMonthName%> <%=hrYear%>?');">
								<i class="fa-solid fa-stamp"></i> Executive Approve
							</button>
						</form>
					</div>

					<div style="display: flex; gap: 10px;">
						<a href="${pageContext.request.contextPath}/manageSalary" class="btn-action-sm" style="background: #dbeafe; color: #1e40af; flex: 1; justify-content: center; padding: 10px;">
							<i class="fa-solid fa-gears"></i> Manage CTC Packages
						</a>
						<a href="${pageContext.request.contextPath}/exportPayroll?month=<%=hrMonth%>&year=<%=hrYear%>" class="btn-action-sm" style="background: #f1f5f9; color: #334155; flex: 1; justify-content: center; padding: 10px;">
							<i class="fa-solid fa-file-csv"></i> Export Payroll CSV
						</a>
					</div>
				</div>

				<!-- Recent Onboardings Snippet -->
				<div class="white-card card-panel">
					<div class="panel-header">
						<div class="panel-title"><i class="fa-solid fa-id-badge" style="color: #2563eb;"></i> Recent Employee Onboardings</div>
						<a href="${pageContext.request.contextPath}/viewEmployeesServlet" class="panel-link">View All <i class="fa-solid fa-arrow-right"></i></a>
					</div>
					<% if (recentEmployees != null && !recentEmployees.isEmpty()) { %>
					<div style="overflow-x: auto;">
						<table class="custom-table">
							<thead>
								<tr>
									<th>Employee</th>
									<th>Department</th>
									<th>Designation</th>
									<th>Action</th>
								</tr>
							</thead>
							<tbody>
								<% for (Employee emp : recentEmployees) {
									String initial = emp.getEmployee_name() != null && !emp.getEmployee_name().isBlank() ? String.valueOf(emp.getEmployee_name().charAt(0)).toUpperCase() : "E";
								%>
								<tr>
									<td>
										<div class="emp-cell">
											<div class="emp-cell-avatar"><%=initial%></div>
											<div>
												<div style="font-weight: 800; color: #0f172a;"><%=emp.getEmployee_name()%></div>
												<div style="font-size: 11.5px; color: #64748b;"><%=emp.getEmail()%></div>
											</div>
										</div>
									</td>
									<td><span class="badge-tag badge-vacation"><%=emp.getDepartment() != null ? emp.getDepartment() : "General"%></span></td>
									<td><strong style="color: #334155;"><%=emp.getDesignation() != null ? emp.getDesignation() : "Staff"%></strong></td>
									<td>
										<a href="${pageContext.request.contextPath}/manageSalary?employeeId=<%=emp.getEmployee_id()%>" class="btn-action-sm btn-approve" title="Configure Salary">
											<i class="fa-solid fa-gears"></i> Salary Setup
										</a>
									</td>
								</tr>
								<% } %>
							</tbody>
						</table>
					</div>
					<% } else { %>
					<div class="empty-state-box">
						<i class="fa-solid fa-users-slash"></i>
						<h4>No Employee Records Available</h4>
					</div>
					<% } %>
				</div>

			</div>

		</div>

		<!-- My Meetings & Interview Schedule Panel -->
		<div class="white-card card-panel" style="margin-top: 24px;">
			<div class="panel-header">
				<div class="panel-title">
					<i class="fa-solid fa-calendar-check" style="color: #7c3aed;"></i> My Meetings &amp; Interview Schedule (<%=myMeetingsCount%>)
				</div>
				<div style="display: flex; gap: 10px; align-items: center;">
					<a href="${pageContext.request.contextPath}/scheduleMeeting" class="btn-action-sm btn-approve" style="padding: 6px 14px; text-decoration: none; border-radius: 8px;">
						<i class="fa-solid fa-calendar-plus"></i> Schedule Meeting
					</a>
					<a href="${pageContext.request.contextPath}/myMeetings" class="panel-link">View All My Meetings <i class="fa-solid fa-arrow-right"></i></a>
				</div>
			</div>

			<% if (myMeetings != null && !myMeetings.isEmpty()) { %>
			<div style="overflow-x: auto;">
				<table class="custom-table">
					<thead>
						<tr>
							<th>Meeting Title</th>
							<th>Date &amp; Time</th>
							<th>Mode / Room</th>
							<th>Status</th>
							<th>Action</th>
						</tr>
					</thead>
					<tbody>
						<%
						int mIdx = 0;
						for (Meeting m : myMeetings) {
							if (++mIdx > 5) break;
							String mode = m.getMeetingMode() != null ? m.getMeetingMode().name() : "ONLINE";
							boolean isOnline = "ONLINE".equalsIgnoreCase(mode);
							String status = m.getStatus() != null ? m.getStatus().name() : "SCHEDULED";
							String statusClass = "badge-vacation";
							if ("COMPLETED".equalsIgnoreCase(status)) statusClass = "badge-approved";
							else if ("CANCELLED".equalsIgnoreCase(status)) statusClass = "badge-rejected";
						%>
						<tr>
							<td>
								<div style="font-weight: 800; color: #0f172a; font-size: 14px;"><%=m.getTitle()%></div>
								<div style="font-size: 11.5px; color: #64748b;"><%=m.getDescription() != null && !m.getDescription().isBlank() ? m.getDescription() : "HR Meeting / Interview"%></div>
							</td>
							<td>
								<div style="font-weight: 700; color: #334155;"><i class="fa-solid fa-calendar" style="color: #4f46e5; margin-right: 4px;"></i> <%=m.getMeetingDate()%></div>
								<div style="font-size: 11.5px; color: #64748b;"><i class="fa-solid fa-clock" style="margin-right: 4px;"></i> <%=m.getStartTime()%> - <%=m.getEndTime()%></div>
							</td>
							<td>
								<span class="badge-tag <%=isOnline ? "badge-vacation" : "badge-approved"%>">
									<i class="fa-solid <%=isOnline ? "fa-video" : "fa-door-open"%>"></i> <%=mode%>
								</span>
								<div style="font-size: 11px; color: #64748b; margin-top: 2px;">
									<%=m.getRoom() != null && !m.getRoom().isBlank() ? m.getRoom() : (isOnline ? "Virtual Room" : "Office HQ")%>
								</div>
							</td>
							<td>
								<span class="badge-tag <%=statusClass%>"><%=status%></span>
							</td>
							<td>
								<div style="display: flex; gap: 6px;">
									<% if (isOnline && m.getMeetingLink() != null && !m.getMeetingLink().isBlank()) { %>
									<a href="<%=m.getMeetingLink()%>" target="_blank" class="btn-action-sm btn-approve" title="Join Video Call">
										<i class="fa-solid fa-video"></i> Join Call
									</a>
									<% } %>
									<a href="${pageContext.request.contextPath}/viewMeetings" class="btn-action-sm" style="background: #f1f5f9; color: #334155;" title="View Details">
										<i class="fa-solid fa-eye"></i> Details
									</a>
								</div>
							</td>
						</tr>
						<% } %>
					</tbody>
				</table>
			</div>
			<% } else { %>
			<div class="empty-state-box">
				<i class="fa-solid fa-calendar-xmark"></i>
				<h4 style="font-weight: 800; color: #0f172a;">No Scheduled Meetings Found</h4>
				<p>You have no upcoming meetings or interviews scheduled. Click "Schedule Meeting" to create one.</p>
			</div>
			<% } %>
		</div>

	</div>

	<!-- JavaScript for Chart.js and Ticking Clock -->
	<script>
		document.addEventListener("DOMContentLoaded", function() {
			<%
			StringBuilder labelsSb = new StringBuilder("[");
			StringBuilder dataSb = new StringBuilder("[");
			int idx = 0;
			for (Map.Entry<String, Integer> entry : deptCounts.entrySet()) {
				if (idx > 0) {
					labelsSb.append(", ");
					dataSb.append(", ");
				}
				labelsSb.append("\"").append(entry.getKey()).append("\"");
				dataSb.append(entry.getValue());
				idx++;
			}
			labelsSb.append("]");
			dataSb.append("]");
			%>
			const deptLabels = <%=labelsSb.toString()%>;
			const deptData = <%=dataSb.toString()%>;
			const colorPalette = ['#2563eb', '#0284c7', '#10b981', '#f59e0b', '#ec4899', '#8b5cf6', '#64748b'];

			const ctxHr = document.getElementById('deptChartHr');
			if (ctxHr) {
				new Chart(ctxHr, {
					type: 'doughnut',
					data: {
						labels: deptLabels,
						datasets: [{
							data: deptData,
							backgroundColor: colorPalette.slice(0, deptLabels.length),
							borderWidth: 2,
							borderColor: '#ffffff'
						}]
					},
					options: {
						responsive: true,
						maintainAspectRatio: false,
						plugins: { legend: { position: 'bottom' } },
						cutout: '65%'
					}
				});
			}

			function updateHrClock() {
				var now = new Date();
				var hours = String(now.getHours()).padStart(2, '0');
				var minutes = String(now.getMinutes()).padStart(2, '0');
				var seconds = String(now.getSeconds()).padStart(2, '0');
				var clockEl = document.getElementById("liveHrClock");
				if (clockEl) {
					clockEl.innerText = hours + ":" + minutes + ":" + seconds;
				}
			}
			setInterval(updateHrClock, 1000);
			updateHrClock();
		});
	</script>
</body>
</html>
