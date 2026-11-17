<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.AuditLog"%>
<%@ page import="com.rajesh.elams.model.LoginLog"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}
String activePage = "auditLogs";

Employee employee = (Employee) session.getAttribute("employee");
if (employee == null && loggedUser != null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(loggedUser.getEmail());
	} catch (Exception ignored) {}
}

String adminName = employee != null && employee.getEmployee_name() != null ? employee.getEmployee_name() : "Admin";
String adminPhoto = (employee != null && employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + adminName + "&background=4f46e5&color=fff&bold=true";

@SuppressWarnings("unchecked")
List<AuditLog> auditLogs = (List<AuditLog>) request.getAttribute("auditLogs");

@SuppressWarnings("unchecked")
List<LoginLog> loginLogs = (List<LoginLog>) request.getAttribute("loginLogs");

String searchKeyword = (String) request.getAttribute("searchKeyword");
String selectedModule = (String) request.getAttribute("selectedModule");
String selectedAction = (String) request.getAttribute("selectedAction");
String selectedSeverity = (String) request.getAttribute("selectedSeverity");
String selectedDate = (String) request.getAttribute("selectedDate");
String startDate = (String) request.getAttribute("startDate");
String endDate = (String) request.getAttribute("endDate");
String activeTab = (String) request.getAttribute("activeTab");

String purgeMessage = (String) request.getAttribute("purgeMessage");
String purgeError = (String) request.getAttribute("purgeError");

if (searchKeyword == null) searchKeyword = "";
if (selectedModule == null) selectedModule = "All";
if (selectedAction == null) selectedAction = "All";
if (selectedSeverity == null) selectedSeverity = "All";
if (selectedDate == null) selectedDate = "";
if (startDate == null) startDate = "";
if (endDate == null) endDate = "";
if (activeTab == null) activeTab = "audit";

int totalAuditCount = request.getAttribute("totalAuditCount") != null ? (Integer) request.getAttribute("totalAuditCount") : 0;
int todayAuditCount = request.getAttribute("todayAuditCount") != null ? (Integer) request.getAttribute("todayAuditCount") : 0;
int totalLoginCount = request.getAttribute("totalLoginCount") != null ? (Integer) request.getAttribute("totalLoginCount") : 0;
int todayLoginCount = request.getAttribute("todayLoginCount") != null ? (Integer) request.getAttribute("todayLoginCount") : 0;

String todayDateStr = new SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Audit &amp; System Logs | SmartOffice Executive Hub</title>

<!-- Font Awesome & Google Fonts -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

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
	font-family: 'Plus Jakarta Sans', sans-serif;
}

body {
	background-color: var(--bg-main);
	color: var(--text-primary);
	display: flex;
	min-height: 100vh;
}

/* Sidebar Styling */
.sidebar {
	width: var(--sidebar-w);
	background: #0f172a;
	color: #ffffff;
	position: fixed;
	top: 0;
	left: 0;
	height: 100vh;
	overflow-y: auto;
	z-index: 100;
}

.logo-brand {
	padding: 24px 20px;
	display: flex;
	align-items: center;
	gap: 12px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.logo-icon {
	width: 40px;
	height: 40px;
	border-radius: 12px;
	background: linear-gradient(135deg, #4f46e5, #06b6d4);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	color: #fff;
	box-shadow: 0 4px 15px rgba(79, 70, 229, 0.4);
}

.logo-text {
	font-size: 20px;
	font-weight: 800;
	color: #ffffff;
}

.logo-text span { color: #38bdf8; }

.menu-nav { padding: 20px 16px; }

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

/* Main Container */
.main-wrapper {
	margin-left: var(--sidebar-w);
	width: calc(100% - var(--sidebar-w));
	display: flex;
	flex-direction: column;
	min-height: 100vh;
}

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
	border: 1px solid #e2e8f0;
}

.user-avatar {
	width: 34px;
	height: 34px;
	border-radius: 50%;
	object-fit: cover;
}

.content-body {
	padding: 32px 36px;
	flex: 1;
}

/* Hero Header & Stats */
.audit-hero {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 28px;
	flex-wrap: wrap;
	gap: 16px;
}

.hero-title h1 {
	font-size: 26px;
	font-weight: 800;
	color: #0f172a;
	letter-spacing: -0.5px;
}

.hero-title p {
	font-size: 14px;
	color: #64748b;
	margin-top: 4px;
}

.stats-grid {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 20px;
	margin-bottom: 32px;
}

.stat-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 22px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
	display: flex;
	align-items: center;
	gap: 18px;
}

.stat-icon-wrap {
	width: 52px;
	height: 52px;
	border-radius: 16px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 22px;
}

.icon-purple { background: #eef2ff; color: #4f46e5; }
.icon-emerald { background: #ecfdf5; color: #10b981; }
.icon-amber { background: #fffbeb; color: #f59e0b; }
.icon-cyan { background: #ecfeff; color: #0891b2; }

.stat-info h4 {
	font-size: 12.5px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.stat-info h2 {
	font-size: 24px;
	font-weight: 800;
	color: #0f172a;
	margin-top: 2px;
}

/* Tabs & Filter Bar */
.filter-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 24px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
	margin-bottom: 28px;
}

.tab-buttons {
	display: flex;
	gap: 12px;
	border-bottom: 1px solid #e2e8f0;
	padding-bottom: 16px;
	margin-bottom: 20px;
}

.tab-btn {
	padding: 10px 22px;
	border-radius: 12px;
	font-size: 14px;
	font-weight: 700;
	border: none;
	background: #f1f5f9;
	color: #64748b;
	cursor: pointer;
	text-decoration: none;
	display: flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s;
}

.tab-btn.active {
	background: #4f46e5;
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(79, 70, 229, 0.3);
}

.filter-form {
	display: flex;
	flex-wrap: wrap;
	gap: 16px;
	align-items: flex-end;
}

.filter-group {
	display: flex;
	flex-direction: column;
	gap: 6px;
	flex: 1;
	min-width: 140px;
}

.filter-group label {
	font-size: 12px;
	font-weight: 700;
	color: #475569;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.filter-input, .filter-select {
	padding: 11px 16px;
	border-radius: 12px;
	border: 1px solid #cbd5e1;
	background: #f8fafc;
	font-size: 13.5px;
	font-weight: 600;
	color: #0f172a;
	outline: none;
	transition: all 0.2s;
	width: 100%;
}

.filter-input:focus, .filter-select:focus {
	border-color: #4f46e5;
	background: #ffffff;
	box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
}

.btn-filter-submit {
	padding: 11px 24px;
	background: #4f46e5;
	color: #ffffff;
	border-radius: 12px;
	border: none;
	font-size: 14px;
	font-weight: 700;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 8px;
	transition: background 0.2s;
	height: 44px;
}

.btn-filter-submit:hover { background: #4338ca; }

.btn-filter-reset {
	padding: 11px 18px;
	background: #f1f5f9;
	color: #64748b;
	border-radius: 12px;
	border: 1px solid #cbd5e1;
	font-size: 14px;
	font-weight: 700;
	text-decoration: none;
	display: flex;
	align-items: center;
	gap: 6px;
	height: 44px;
}

.btn-filter-reset:hover { background: #e2e8f0; color: #0f172a; }

.btn-purge-modal {
	padding: 11px 18px;
	background: #fff1f2;
	color: #e11d48;
	border-radius: 12px;
	border: 1px solid #fecdd3;
	font-size: 14px;
	font-weight: 700;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 6px;
	height: 44px;
}

.btn-purge-modal:hover { background: #ffe4e6; }

/* Table Container */
.table-card {
	background: #ffffff;
	border-radius: 20px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
	overflow: hidden;
}

.table-header-box {
	padding: 20px 24px;
	border-bottom: 1px solid #f1f5f9;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.table-header-box h3 {
	font-size: 17px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 10px;
}

.badge-count {
	padding: 3px 10px;
	border-radius: 20px;
	background: #e0e7ff;
	color: #4338ca;
	font-size: 12px;
	font-weight: 800;
}

.audit-table {
	width: 100%;
	border-collapse: collapse;
	text-align: left;
}

.audit-table th {
	background: #f8fafc;
	padding: 14px 20px;
	font-size: 12px;
	font-weight: 800;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	border-bottom: 1px solid #e2e8f0;
}

.audit-table td {
	padding: 16px 20px;
	border-bottom: 1px solid #f1f5f9;
	font-size: 13.5px;
	color: #334155;
	vertical-align: middle;
}

.audit-table tr:hover td {
	background: #f8fafc;
}

.user-cell {
	font-weight: 700;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 8px;
}

.user-avatar-sm {
	width: 28px;
	height: 28px;
	border-radius: 50%;
	background: #4f46e5;
	color: #fff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 12px;
	font-weight: 800;
}

/* Action Badges */
.act-badge {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 12px;
	border-radius: 8px;
	font-size: 11.5px;
	font-weight: 800;
	font-family: 'JetBrains Mono', monospace;
	text-transform: uppercase;
}

.act-create { background: #dcfce7; color: #15803d; }
.act-update { background: #e0f2fe; color: #0369a1; }
.act-delete { background: #ffe4e6; color: #be123c; }
.act-approve { background: #d1fae5; color: #047857; }
.act-reject { background: #fee2e2; color: #b91c1c; }
.act-login { background: #ede9fe; color: #6d28d9; }
.act-logout { background: #f1f5f9; color: #475569; }
.act-export { background: #dbeafe; color: #1e40af; }
.act-default { background: #f3f4f6; color: #374151; }

/* Severity Badges */
.sev-badge {
	display: inline-flex;
	align-items: center;
	gap: 5px;
	padding: 3px 10px;
	border-radius: 6px;
	font-size: 11px;
	font-weight: 800;
	letter-spacing: 0.5px;
}
.sev-info { background: #e0f2fe; color: #0369a1; }
.sev-warn { background: #fef3c7; color: #b45309; }
.sev-security { background: #fce7f3; color: #be185d; }
.sev-critical { background: #ffe4e6; color: #9f1239; }

.module-tag {
	font-size: 12px;
	font-weight: 700;
	color: #475569;
	background: #f1f5f9;
	padding: 3px 10px;
	border-radius: 6px;
}

.record-code {
	font-family: 'JetBrains Mono', monospace;
	font-size: 12.5px;
	font-weight: 700;
	color: #4f46e5;
	background: #eef2ff;
	padding: 2px 8px;
	border-radius: 6px;
}

.btn-inspect {
	padding: 4px 10px;
	border-radius: 8px;
	background: #eef2ff;
	color: #4f46e5;
	border: 1px solid #c7d2fe;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.2s;
}
.btn-inspect:hover { background: #4f46e5; color: #ffffff; }

.empty-state {
	padding: 48px;
	text-align: center;
	color: #64748b;
}

.empty-state i {
	font-size: 42px;
	color: #cbd5e1;
	margin-bottom: 14px;
}

.empty-state h4 {
	font-size: 16px;
	font-weight: 700;
	color: #0f172a;
}

/* Detail Drawer Modal */
.modal-overlay {
	display: none;
	position: fixed;
	top: 0; left: 0; width: 100%; height: 100%;
	background: rgba(15, 23, 42, 0.6);
	backdrop-filter: blur(4px);
	z-index: 999;
	align-items: center;
	justify-content: center;
}
.modal-card {
	background: #ffffff;
	border-radius: 20px;
	width: 90%;
	max-width: 600px;
	padding: 28px;
	box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
}
.modal-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	border-bottom: 1px solid #e2e8f0;
	padding-bottom: 16px;
	margin-bottom: 20px;
}
.modal-header h3 { font-size: 18px; font-weight: 800; color: #0f172a; }
.btn-close-modal { background: none; border: none; font-size: 20px; color: #94a3b8; cursor: pointer; }
.btn-close-modal:hover { color: #0f172a; }
.json-viewer {
	background: #0f172a;
	color: #38bdf8;
	padding: 16px;
	border-radius: 12px;
	font-family: 'JetBrains Mono', monospace;
	font-size: 12.5px;
	white-space: pre-wrap;
	word-break: break-all;
	max-height: 300px;
	overflow-y: auto;
}
</style>
</head>

<body>

	<div class="app-shell">
		<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

		<!-- Main Content Wrapper -->
		<div class="main">

			<!-- Topbar Header -->
			<header class="topbar">
				<div class="topbar-title">
					<div class="crumb"><i class="fa-solid fa-clipboard-list"></i> System &amp; Audit Governance</div>
					Audit &amp; Activity Monitoring Command Hub
				</div>
				<div class="topbar-right" style="display: flex; align-items: center; gap: 14px;">
					<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
					<a href="${pageContext.request.contextPath}/profile.jsp" class="topbar-user" style="display: flex; align-items: center; gap: 10px; background: rgba(255,255,255,0.15); padding: 5px 14px 5px 6px; border-radius: 30px; color: #fff; text-decoration: none; font-weight: 700; font-size: 13px; border: 1px solid rgba(255,255,255,0.25);">
						<img src="<%= adminPhoto %>" alt="Admin" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover;">
						<span><%= adminName %></span>
						<span style="background: rgba(255,255,255,0.2); color: #fff; padding: 2px 8px; border-radius: 12px; font-size: 11px;">ADMIN</span>
					</a>
				</div>
			</header>

			<!-- Page Content -->
			<div class="page-content" style="padding: 28px;">

			<!-- Purge Alert Banners -->
			<% if (purgeMessage != null) { %>
				<div style="padding: 14px 20px; background: #ecfdf5; border: 1px solid #a7f3d0; color: #065f46; border-radius: 12px; margin-bottom: 20px; font-weight: 700; display: flex; align-items: center; gap: 10px;">
					<i class="fa-solid fa-circle-check" style="font-size: 18px;"></i> <%= purgeMessage %>
				</div>
			<% } %>
			<% if (purgeError != null) { %>
				<div style="padding: 14px 20px; background: #fff1f2; border: 1px solid #fecdd3; color: #9f1239; border-radius: 12px; margin-bottom: 20px; font-weight: 700; display: flex; align-items: center; gap: 10px;">
					<i class="fa-solid fa-triangle-exclamation" style="font-size: 18px;"></i> <%= purgeError %>
				</div>
			<% } %>

			<!-- Hero Header -->
			<div class="audit-hero">
				<div class="hero-title">
					<h1><i class="fa-solid fa-shield-cat" style="color: #4f46e5; margin-right: 8px;"></i> System Audit &amp; Event Logs</h1>
					<p>Real-time security trail recording user operations, login activities, severity risks, and JSON event metadata across all modules.</p>
				</div>
			</div>

			<!-- Summary Stats Cards -->
			<div class="stats-grid">
				<div class="stat-card">
					<div class="stat-icon-wrap icon-purple"><i class="fa-solid fa-layer-group"></i></div>
					<div class="stat-info">
						<h4>Total Audit Logs</h4>
						<h2><%= totalAuditCount %></h2>
					</div>
				</div>
				<div class="stat-card">
					<div class="stat-icon-wrap icon-emerald"><i class="fa-solid fa-bolt"></i></div>
					<div class="stat-info">
						<h4>Today's Actions</h4>
						<h2><%= todayAuditCount %></h2>
					</div>
				</div>
				<div class="stat-card">
					<div class="stat-icon-wrap icon-cyan"><i class="fa-solid fa-right-to-bracket"></i></div>
					<div class="stat-info">
						<h4>Total Logins Recorded</h4>
						<h2><%= totalLoginCount %></h2>
					</div>
				</div>
				<div class="stat-card">
					<div class="stat-icon-wrap icon-amber"><i class="fa-solid fa-user-clock"></i></div>
					<div class="stat-info">
						<h4>Today's Active Logins</h4>
						<h2><%= todayLoginCount %></h2>
					</div>
				</div>
			</div>

			<!-- Tabs & Search Filter Card -->
			<div class="filter-card">

				<!-- Tab Toggles -->
				<div class="tab-buttons">
					<a href="${pageContext.request.contextPath}/auditLogs?tab=audit" class="tab-btn <%= "audit".equals(activeTab) ? "active" : "" %>">
						<i class="fa-solid fa-list-check"></i> User Operations Audit Log
					</a>
					<a href="${pageContext.request.contextPath}/auditLogs?tab=login" class="tab-btn <%= "login".equals(activeTab) ? "active" : "" %>">
						<i class="fa-solid fa-key"></i> Login &amp; Session History Log
					</a>
				</div>

				<!-- Search Form -->
				<% if ("audit".equals(activeTab)) { %>
				<form action="${pageContext.request.contextPath}/auditLogs" method="get" class="filter-form">
					<input type="hidden" name="tab" value="audit">
					
					<div class="filter-group" style="flex: 2;">
						<label><i class="fa-solid fa-magnifying-glass"></i> Search Logs</label>
						<input type="text" name="search" class="filter-input" placeholder="Search by Username, Description, Record ID..." value="<%= searchKeyword %>">
					</div>

					<div class="filter-group">
						<label><i class="fa-solid fa-cubes"></i> Module</label>
						<select name="module" class="filter-select">
							<option value="All" <%= "All".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>All Modules</option>
							<option value="User Management" <%= "User Management".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>User Management</option>
							<option value="Employee Management" <%= "Employee Management".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Employee Management</option>
							<option value="Leave Management" <%= "Leave Management".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Leave Management</option>
							<option value="Attendance" <%= "Attendance".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Attendance</option>
							<option value="Tasks" <%= "Tasks".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Tasks</option>
							<option value="Meetings" <%= "Meetings".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Meetings</option>
							<option value="Payroll" <%= "Payroll".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Payroll</option>
							<option value="System Settings" <%= "System Settings".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>System Settings</option>
							<option value="Authentication" <%= "Authentication".equalsIgnoreCase(selectedModule) ? "selected" : "" %>>Authentication</option>
						</select>
					</div>

					<div class="filter-group">
						<label><i class="fa-solid fa-filter"></i> Action Type</label>
						<select name="action" class="filter-select">
							<option value="All" <%= "All".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>All Actions</option>
							<option value="CREATE_USER" <%= "CREATE_USER".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>CREATE_USER</option>
							<option value="UPDATE_USER" <%= "UPDATE_USER".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>UPDATE_USER</option>
							<option value="CREATE_EMPLOYEE" <%= "CREATE_EMPLOYEE".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>CREATE_EMPLOYEE</option>
							<option value="UPDATE_EMPLOYEE" <%= "UPDATE_EMPLOYEE".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>UPDATE_EMPLOYEE</option>
							<option value="DEACTIVATE_EMPLOYEE" <%= "DEACTIVATE_EMPLOYEE".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>DEACTIVATE_EMPLOYEE</option>
							<option value="APPLY_LEAVE" <%= "APPLY_LEAVE".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>APPLY_LEAVE</option>
							<option value="APPROVE_LEAVE" <%= "APPROVE_LEAVE".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>APPROVE_LEAVE</option>
							<option value="REJECT_LEAVE" <%= "REJECT_LEAVE".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>REJECT_LEAVE</option>
							<option value="CREATE_SALARY" <%= "CREATE_SALARY".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>CREATE_SALARY</option>
							<option value="UPDATE_SALARY" <%= "UPDATE_SALARY".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>UPDATE_SALARY</option>
							<option value="PROCESS_PAYROLL" <%= "PROCESS_PAYROLL".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>PROCESS_PAYROLL</option>
							<option value="EXPORT_AUDIT_LOGS" <%= "EXPORT_AUDIT_LOGS".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>EXPORT_AUDIT_LOGS</option>
							<option value="PURGE_AUDIT_LOGS" <%= "PURGE_AUDIT_LOGS".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>PURGE_AUDIT_LOGS</option>
							<option value="LOGIN" <%= "LOGIN".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>LOGIN</option>
							<option value="LOGOUT" <%= "LOGOUT".equalsIgnoreCase(selectedAction) ? "selected" : "" %>>LOGOUT</option>
						</select>
					</div>

					<div class="filter-group">
						<label><i class="fa-solid fa-triangle-exclamation"></i> Severity</label>
						<select name="severity" class="filter-select">
							<option value="All" <%= "All".equalsIgnoreCase(selectedSeverity) ? "selected" : "" %>>All Severities</option>
							<option value="INFO" <%= "INFO".equalsIgnoreCase(selectedSeverity) ? "selected" : "" %>>INFO</option>
							<option value="WARN" <%= "WARN".equalsIgnoreCase(selectedSeverity) ? "selected" : "" %>>WARN</option>
							<option value="SECURITY" <%= "SECURITY".equalsIgnoreCase(selectedSeverity) ? "selected" : "" %>>SECURITY</option>
							<option value="CRITICAL" <%= "CRITICAL".equalsIgnoreCase(selectedSeverity) ? "selected" : "" %>>CRITICAL</option>
						</select>
					</div>

					<div class="filter-group">
						<label><i class="fa-solid fa-calendar-day"></i> From Date</label>
						<input type="date" name="startDate" class="filter-input" value="<%= startDate %>">
					</div>

					<div class="filter-group">
						<label><i class="fa-solid fa-calendar-day"></i> To Date</label>
						<input type="date" name="endDate" class="filter-input" value="<%= endDate %>">
					</div>

					<button type="submit" class="btn-filter-submit">
						<i class="fa-solid fa-filter"></i> Apply
					</button>
					<a href="${pageContext.request.contextPath}/auditLogs" class="btn-filter-reset">
						<i class="fa-solid fa-rotate-left"></i> Reset
					</a>
					<button type="button" class="btn-purge-modal" onclick="openPurgeModal()">
						<i class="fa-solid fa-trash-can"></i> Purge
					</button>
				</form>
				<% } else { %>
				<p style="font-size: 13.5px; color: #64748b;"><i class="fa-solid fa-info-circle"></i> Showing recent user authentication attempts, IP addresses, session state, and timestamps.</p>
				<% } %>

			</div>

			<!-- Main Table Content -->
			<div class="table-card">
				<% if ("audit".equals(activeTab)) { %>
				<div class="table-header-box">
					<h3><i class="fa-solid fa-table-list"></i> System Operations Audit Log <span class="badge-count"><%= auditLogs != null ? auditLogs.size() : 0 %> Entries</span></h3>
				</div>

				<table class="audit-table">
					<thead>
						<tr>
							<th>User</th>
							<th>Action</th>
							<th>Module</th>
							<th>Severity</th>
							<th>Record ID</th>
							<th>Description</th>
							<th>Details</th>
							<th>IP Address</th>
							<th>Timestamp</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (auditLogs != null && !auditLogs.isEmpty()) {
							for (AuditLog log : auditLogs) {
								String act = log.getAction() != null ? log.getAction().toUpperCase() : "UNKNOWN";
								String badgeClass = "act-default";
								if (act.contains("CREATE")) badgeClass = "act-create";
								else if (act.contains("UPDATE")) badgeClass = "act-update";
								else if (act.contains("DELETE") || act.contains("DEACTIVATE") || act.contains("PURGE")) badgeClass = "act-delete";
								else if (act.contains("APPROVE")) badgeClass = "act-approve";
								else if (act.contains("REJECT")) badgeClass = "act-reject";
								else if (act.contains("LOGIN")) badgeClass = "act-login";
								else if (act.contains("LOGOUT")) badgeClass = "act-logout";
								else if (act.contains("EXPORT")) badgeClass = "act-export";

								String sev = log.getSeverity() != null ? log.getSeverity().toUpperCase() : "INFO";
								String sevClass = "sev-info";
								if ("WARN".equals(sev)) sevClass = "sev-warn";
								else if ("SECURITY".equals(sev)) sevClass = "sev-security";
								else if ("CRITICAL".equals(sev)) sevClass = "sev-critical";

								String username = log.getUsername() != null ? log.getUsername() : "System";
								String initial = username.length() > 0 ? username.substring(0, 1).toUpperCase() : "S";
						%>
						<tr>
							<td>
								<div class="user-cell">
									<div class="user-avatar-sm"><%= initial %></div>
									<span><%= username %></span>
								</div>
							</td>
							<td>
								<span class="act-badge <%= badgeClass %>"><%= act %></span>
							</td>
							<td>
								<span class="module-tag"><%= log.getModule() %></span>
							</td>
							<td>
								<span class="sev-badge <%= sevClass %>"><%= sev %></span>
							</td>
							<td>
								<span class="record-code"><%= log.getRecordId() != null ? log.getRecordId() : "-" %></span>
							</td>
							<td><%= log.getDescription() %></td>
							<td>
								<button type="button" class="btn-inspect" onclick="openDetailModal(<%= log.getLogId() %>)">
									<i class="fa-solid fa-code"></i> Inspect
								</button>
							</td>
							<td><code style="color: #64748b;"><%= log.getIpAddress() %></code></td>
							<td style="font-weight: 600; color: #475569;"><%= log.getFormattedDate() %></td>
						</tr>
						<%
							}
						} else {
						%>
						<tr>
							<td colspan="9">
								<div class="empty-state">
									<i class="fa-solid fa-folder-open"></i>
									<h4>No Audit Logs Found</h4>
									<p>No activity logs matched your filter criteria or search keyword.</p>
								</div>
							</td>
						</tr>
						<% } %>
					</tbody>
				</table>

				<% } else { %>

				<!-- Login History Table -->
				<div class="table-header-box">
					<h3><i class="fa-solid fa-user-lock"></i> Authentication &amp; Login History <span class="badge-count"><%= loginLogs != null ? loginLogs.size() : 0 %> Entries</span></h3>
				</div>

				<table class="audit-table">
					<thead>
						<tr>
							<th>User</th>
							<th>Action</th>
							<th>Status</th>
							<th>Login Time</th>
							<th>Logout Time</th>
							<th>IP Address</th>
							<th>User Agent / Browser</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (loginLogs != null && !loginLogs.isEmpty()) {
							for (LoginLog log : loginLogs) {
								String status = log.getStatus() != null ? log.getStatus() : "SUCCESS";
								boolean isSuccess = "SUCCESS".equalsIgnoreCase(status);
								String username = log.getUsername() != null ? log.getUsername() : "Guest";
								String initial = username.length() > 0 ? username.substring(0, 1).toUpperCase() : "G";
						%>
						<tr>
							<td>
								<div class="user-cell">
									<div class="user-avatar-sm" style="background: <%= isSuccess ? "#4f46e5" : "#f43f5e" %>;"><%= initial %></div>
									<span><%= username %></span>
								</div>
							</td>
							<td><span class="act-badge act-login"><%= log.getAction() %></span></td>
							<td>
								<span class="act-badge <%= isSuccess ? "act-create" : "act-reject" %>">
									<%= status %>
								</span>
							</td>
							<td style="font-weight: 700; color: #0f172a;"><%= log.getFormattedLoginTime() %></td>
							<td style="font-weight: 600; color: #64748b;"><%= log.getFormattedLogoutTime() %></td>
							<td><code style="color: #64748b;"><%= log.getIpAddress() %></code></td>
							<td style="max-width: 250px; font-size: 12px; color: #64748b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%= log.getUserAgent() %></td>
						</tr>
						<%
							}
						} else {
						%>
						<tr>
							<td colspan="7">
								<div class="empty-state">
									<i class="fa-solid fa-folder-open"></i>
									<h4>No Login Logs Recorded</h4>
									<p>No login activity events available.</p>
								</div>
							</td>
						</tr>
						<% } %>
					</tbody>
				</table>
				<% } %>

			</div>
		</div>
	</div>
</div>

<!-- Log Metadata Detail Modal -->
<div id="detailModal" class="modal-overlay">
	<div class="modal-card">
		<div class="modal-header">
			<h3><i class="fa-solid fa-code-commit" style="color: #4f46e5;"></i> Audit Event JSON Metadata</h3>
			<button class="btn-close-modal" onclick="closeDetailModal()">&times;</button>
		</div>
		<div id="modalContent">
			<p style="font-size: 13.5px; color: #64748b;">Loading log details...</p>
		</div>
	</div>
</div>

<!-- Purge Modal -->
<div id="purgeModal" class="modal-overlay">
	<div class="modal-card" style="max-width: 480px;">
		<div class="modal-header">
			<h3 style="color: #e11d48;"><i class="fa-solid fa-trash-can"></i> Purge Historical Logs</h3>
			<button class="btn-close-modal" onclick="closePurgeModal()">&times;</button>
		</div>
		<form action="${pageContext.request.contextPath}/auditLogs" method="get">
			<input type="hidden" name="tab" value="audit">
			<p style="font-size: 13.5px; color: #64748b; margin-bottom: 16px;">
				Permanently remove audit log records older than a specific retention period. This action is logged for security compliance.
			</p>
			<div class="filter-group" style="margin-bottom: 20px;">
				<label>Purge Logs Older Than (Days)</label>
				<select name="purgeDays" class="filter-select">
					<option value="30">30 Days</option>
					<option value="60">60 Days</option>
					<option value="90" selected>90 Days</option>
					<option value="180">180 Days</option>
				</select>
			</div>
			<div style="display: flex; justify-content: flex-end; gap: 12px;">
				<button type="button" class="btn-filter-reset" onclick="closePurgeModal()">Cancel</button>
				<button type="submit" class="btn-filter-submit" style="background: #e11d48;">Execute Purge</button>
			</div>
		</form>
	</div>
</div>

<script>
function openDetailModal(logId) {
	var modal = document.getElementById("detailModal");
	var content = document.getElementById("modalContent");
	modal.style.display = "flex";
	content.innerHTML = "<p style='font-size:13.5px; color:#64748b;'><i class='fa-solid fa-spinner fa-spin'></i> Fetching audit event metadata...</p>";

	fetch("${pageContext.request.contextPath}/api/auditLogs?id=" + logId)
		.then(function(res) { return res.json(); })
		.then(function(data) {
			if (data.error) {
				content.innerHTML = "<p style='color:#e11d48; font-weight:700;'>" + data.error + "</p>";
				return;
			}
			var html = "<div style='margin-bottom:14px; font-size:13.5px; color:#334155;'>";
			html += "<strong>Log ID:</strong> #" + data.logId + " | <strong>User:</strong> " + data.username + " | <strong>Action:</strong> " + data.action + "<br>";
			html += "<strong>IP:</strong> " + data.ipAddress + " | <strong>Timestamp:</strong> " + data.formattedDate;
			html += "</div>";
			html += "<div class='json-viewer'>" + JSON.stringify(data.details, null, 2) + "</div>";
			content.innerHTML = html;
		})
		.catch(function(err) {
			content.innerHTML = "<p style='color:#e11d48; font-weight:700;'>Failed to load details: " + err.message + "</p>";
		});
}

function closeDetailModal() {
	document.getElementById("detailModal").style.display = "none";
}

function openPurgeModal() {
	document.getElementById("purgeModal").style.display = "flex";
}

function closePurgeModal() {
	document.getElementById("purgeModal").style.display = "none";
}
</script>

</body>
</html>
