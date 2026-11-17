<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.sql.Date"%>
<%@ page import="com.rajesh.elams.model.Task"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.TaskStatus"%>

<%
List<Task> taskList = (List<Task>) request.getAttribute("taskList");
List<Employee> employees = (List<Employee>) request.getAttribute("employees");
String searchTaskId = (String) request.getAttribute("searchTaskId");
String searchEmpId = (String) request.getAttribute("searchEmpId");
String searchStatus = (String) request.getAttribute("searchStatus");
String searchPriority = (String) request.getAttribute("searchPriority");

String successMsg = (String) session.getAttribute("successMessage");
if (successMsg != null) {
	session.removeAttribute("successMessage");
}
String errorMsg = (String) session.getAttribute("errorMessage");
if (errorMsg != null) {
	session.removeAttribute("errorMessage");
}

String userRole = (String) session.getAttribute("role");
boolean canManageTask = "admin".equalsIgnoreCase(userRole) || "manager".equalsIgnoreCase(userRole);
String backDashUrl = "admin".equalsIgnoreCase(userRole) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(userRole) ? "hrDashboard" : "manager".equalsIgnoreCase(userRole) ? "managerDashboard" : "employeeDashboardServlet";

Map<Integer, String> empNameMap = new HashMap<>();
if (employees != null) {
	for (Employee e : employees) {
		empNameMap.put(e.getEmployee_id(), e.getEmployee_name());
	}
}

int totalCount = 0;
int pendingCount = 0;
int inProgressCount = 0;
int completedCount = 0;
int overdueCount = 0;

Date today = new Date(System.currentTimeMillis());

if (taskList != null) {
	totalCount = taskList.size();
	for (Task t : taskList) {
		String st = t.getStatus() != null ? t.getStatus().name() : "PENDING";
		if ("COMPLETED".equalsIgnoreCase(st)) {
			completedCount++;
		} else if ("IN_PROGRESS".equalsIgnoreCase(st)) {
			inProgressCount++;
		} else {
			pendingCount++;
		}
		
		if (!"COMPLETED".equalsIgnoreCase(st) && t.getDueDate() != null && t.getDueDate().before(today)) {
			overdueCount++;
		}
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Task Management | ELAMS SmartOffice</title>

<!-- Google Fonts & Font Awesome -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
:root {
	--primary: #4f46e5;
	--primary-hover: #4338ca;
	--primary-light: #e0e7ff;
	--bg-main: #f8fafc;
	--card-bg: #ffffff;
	--text-dark: #0f172a;
	--text-muted: #64748b;
	--border-color: #e2e8f0;
	--radius: 16px;
	--shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.03), 0 4px 6px rgba(0, 0, 0, 0.03);
	--shadow-md: 0 10px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.03);
	--shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.08), 0 8px 10px -6px rgba(0, 0, 0, 0.04);
}

* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

body {
	font-family: 'Inter', sans-serif;
	background-color: var(--bg-main);
	color: var(--text-dark);
	padding-bottom: 60px;
	line-height: 1.5;
}

.main-wrapper {
	max-width: 1350px;
	margin: 0 auto;
	padding: 30px 20px;
}

/* Header Banner */
.page-header {
	background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%);
	border-radius: var(--radius);
	padding: 35px 40px;
	color: white;
	margin-bottom: 30px;
	box-shadow: var(--shadow-lg);
	position: relative;
	overflow: hidden;
}

.page-header::before {
	content: '';
	position: absolute;
	top: -50%;
	right: -10%;
	width: 450px;
	height: 450px;
	background: radial-gradient(circle, rgba(99, 102, 241, 0.25) 0%, rgba(255,255,255,0) 70%);
	border-radius: 50%;
	pointer-events: none;
}

.header-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 20px;
}

.header-title-box {
	display: flex;
	align-items: center;
	gap: 16px;
}

.header-icon {
	width: 54px;
	height: 54px;
	background: rgba(255, 255, 255, 0.12);
	backdrop-filter: blur(10px);
	border: 1px solid rgba(255, 255, 255, 0.2);
	border-radius: 16px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24px;
	color: #a5b4fc;
}

.header-title-box h1 {
	font-family: 'Outfit', sans-serif;
	font-size: 28px;
	font-weight: 700;
	letter-spacing: -0.5px;
}

.header-title-box p {
	color: #c7d2fe;
	font-size: 14px;
	margin-top: 4px;
}

.header-actions {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
}

.header-btn {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	padding: 10px 20px;
	border-radius: 30px;
	font-size: 13.5px;
	font-weight: 600;
	text-decoration: none;
	transition: all 0.2s ease;
	cursor: pointer;
}

.btn-create {
	background: #10b981;
	color: white;
	box-shadow: 0 4px 14px rgba(16, 185, 129, 0.3);
}

.btn-create:hover {
	background: #059669;
	transform: translateY(-2px);
}

.btn-report {
	background: #0284c7;
	color: white;
	box-shadow: 0 4px 14px rgba(2, 132, 199, 0.3);
}

.btn-report:hover {
	background: #0369a1;
	transform: translateY(-2px);
}

.btn-back {
	background: rgba(255, 255, 255, 0.15);
	backdrop-filter: blur(10px);
	color: white;
	border: 1px solid rgba(255, 255, 255, 0.2);
}

.btn-back:hover {
	background: rgba(255, 255, 255, 0.28);
	transform: translateY(-2px);
}

/* Toast Flash Alerts */
.alert-toast {
	padding: 14px 20px;
	border-radius: 12px;
	margin-bottom: 25px;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 12px;
	box-shadow: var(--shadow-sm);
	animation: slideIn 0.3s ease;
}

@keyframes slideIn {
	from { opacity: 0; transform: translateY(-10px); }
	to { opacity: 1; transform: translateY(0); }
}

.alert-success { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }
.alert-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

/* Metrics Counter Cards */
.stats-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
	gap: 20px;
	margin-bottom: 35px;
}

.stat-card {
	background: var(--card-bg);
	border-radius: var(--radius);
	padding: 22px 24px;
	box-shadow: var(--shadow-sm);
	border: 1px solid var(--border-color);
	display: flex;
	align-items: center;
	justify-content: space-between;
	transition: all 0.25s ease;
}

.stat-card:hover {
	transform: translateY(-4px);
	box-shadow: var(--shadow-md);
}

.stat-info h3 {
	font-size: 26px;
	font-weight: 700;
	font-family: 'Outfit', sans-serif;
	color: var(--text-dark);
}

.stat-info p {
	font-size: 13px;
	color: var(--text-muted);
	font-weight: 500;
	margin-top: 2px;
}

.stat-icon-wrapper {
	width: 48px;
	height: 48px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
}

.icon-total { background: #e0e7ff; color: #4338ca; }
.icon-pending { background: #fef3c7; color: #d97706; }
.icon-progress { background: #dbeafe; color: #2563eb; }
.icon-completed { background: #dcfce7; color: #16a34a; }
.icon-overdue { background: #ffe4e6; color: #e11d48; }

/* Control Toolbar & Filters */
.toolbar-card {
	background: var(--card-bg);
	border-radius: var(--radius);
	padding: 20px 24px;
	box-shadow: var(--shadow-sm);
	border: 1px solid var(--border-color);
	margin-bottom: 30px;
}

.server-search-form {
	display: flex;
	flex-wrap: wrap;
	gap: 14px;
	align-items: center;
	margin-bottom: 16px;
	padding-bottom: 16px;
	border-bottom: 1px solid var(--border-color);
}

.server-search-form input,
.server-search-form select {
	padding: 10px 14px;
	border-radius: 10px;
	border: 1px solid var(--border-color);
	font-size: 13.5px;
	background: #f8fafc;
	outline: none;
	transition: all 0.2s ease;
}

.server-search-form input:focus,
.server-search-form select:focus {
	background: white;
	border-color: var(--primary);
}

.btn-search {
	background: var(--primary);
	color: white;
	border: none;
	padding: 10px 18px;
	border-radius: 10px;
	font-size: 13.5px;
	font-weight: 600;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
}

.btn-search:hover { background: var(--primary-hover); }

.btn-reset {
	background: #64748b;
	color: white;
	text-decoration: none;
	padding: 10px 16px;
	border-radius: 10px;
	font-size: 13.5px;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
}

.btn-reset:hover { background: #475569; }

.quick-toolbar {
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
}

.live-search-box {
	position: relative;
	flex: 1;
	min-width: 250px;
}

.live-search-box input {
	width: 100%;
	padding: 10px 16px 10px 40px;
	border-radius: 10px;
	border: 1px solid var(--border-color);
	font-size: 13.5px;
	background: #f8fafc;
	outline: none;
}

.live-search-box input:focus {
	background: white;
	border-color: var(--primary);
}

.live-search-box i {
	position: absolute;
	left: 14px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text-muted);
	font-size: 14px;
}

.filter-pills {
	display: flex;
	align-items: center;
	gap: 8px;
	flex-wrap: wrap;
}

.pill-btn {
	background: #f1f5f9;
	border: 1px solid transparent;
	padding: 7px 15px;
	border-radius: 20px;
	font-size: 13px;
	font-weight: 500;
	color: var(--text-muted);
	cursor: pointer;
	transition: all 0.2s ease;
}

.pill-btn:hover { background: #e2e8f0; color: var(--text-dark); }
.pill-btn.active {
	background: var(--primary);
	color: white;
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
}

.view-toggle-wrap {
	display: flex;
	background: #f1f5f9;
	padding: 4px;
	border-radius: 10px;
}

.view-btn {
	border: none;
	background: transparent;
	padding: 7px 13px;
	border-radius: 8px;
	cursor: pointer;
	color: var(--text-muted);
	font-size: 14px;
	transition: all 0.2s ease;
}

.view-btn.active {
	background: white;
	color: var(--primary);
	box-shadow: var(--shadow-sm);
}

/* Card Grid View */
.tasks-grid-view {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
	gap: 24px;
}

.task-card {
	background: var(--card-bg);
	border-radius: var(--radius);
	border: 1px solid var(--border-color);
	box-shadow: var(--shadow-sm);
	padding: 24px;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	transition: all 0.25s ease;
	position: relative;
}

.task-card:hover {
	transform: translateY(-4px);
	box-shadow: var(--shadow-md);
	border-color: #cbd5e1;
}

.task-card-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 14px;
}

.task-id-badge {
	font-size: 12px;
	font-weight: 700;
	color: var(--primary);
	background: var(--primary-light);
	padding: 4px 10px;
	border-radius: 8px;
	letter-spacing: 0.3px;
}

.badges-row {
	display: flex;
	align-items: center;
	gap: 6px;
}

.badge-priority {
	font-size: 11px;
	font-weight: 700;
	padding: 4px 10px;
	border-radius: 20px;
	text-transform: uppercase;
}

.p-HIGH { background: #ffe4e6; color: #e11d48; }
.p-MEDIUM { background: #fef3c7; color: #d97706; }
.p-LOW { background: #dcfce7; color: #15803d; }

.badge-status {
	font-size: 11px;
	font-weight: 700;
	padding: 4px 10px;
	border-radius: 20px;
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

.st-PENDING { background: #fff7ed; color: #c2410c; }
.st-IN_PROGRESS { background: #eff6ff; color: #1d4ed8; }
.st-COMPLETED { background: #f0fdf4; color: #15803d; }

.dot-indicator {
	width: 6px;
	height: 6px;
	border-radius: 50%;
}
.st-PENDING .dot-indicator { background: #c2410c; }
.st-IN_PROGRESS .dot-indicator { background: #1d4ed8; }
.st-COMPLETED .dot-indicator { background: #15803d; }

.task-title {
	font-family: 'Outfit', sans-serif;
	font-size: 18px;
	font-weight: 600;
	color: var(--text-dark);
	margin-bottom: 8px;
	line-height: 1.35;
}

.task-desc {
	font-size: 13.5px;
	color: var(--text-muted);
	margin-bottom: 18px;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.task-meta-box {
	background: #f8fafc;
	border-radius: 12px;
	padding: 12px 16px;
	margin-bottom: 18px;
	display: flex;
	flex-direction: column;
	gap: 8px;
	border: 1px dashed #e2e8f0;
}

.meta-row {
	font-size: 12.5px;
	color: var(--text-muted);
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.meta-row span {
	font-weight: 600;
	color: var(--text-dark);
}

.meta-row.overdue span { color: #e11d48; }

.card-control-row {
	display: flex;
	flex-direction: column;
	gap: 10px;
	margin-bottom: 16px;
	background: #f1f5f9;
	padding: 12px;
	border-radius: 12px;
}

.control-item {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 10px;
}

.control-item label {
	font-size: 12px;
	font-weight: 600;
	color: var(--text-muted);
}

.control-item select {
	padding: 5px 8px;
	font-size: 12px;
	border-radius: 6px;
	border: 1px solid var(--border-color);
	background: white;
	outline: none;
	cursor: pointer;
}

.card-footer-actions {
	display: flex;
	align-items: center;
	justify-content: flex-end;
	gap: 8px;
	padding-top: 14px;
	border-top: 1px solid var(--border-color);
}

.btn-icon-action {
	padding: 7px 14px;
	border-radius: 8px;
	font-size: 13px;
	font-weight: 600;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
}

.btn-edit-act { background: #e0e7ff; color: #4338ca; }
.btn-edit-act:hover { background: #c7d2fe; }

.btn-del-act { background: #ffe4e6; color: #e11d48; }
.btn-del-act:hover { background: #fecdd3; }

/* Table View */
.tasks-table-view {
	background: var(--card-bg);
	border-radius: var(--radius);
	box-shadow: var(--shadow-sm);
	border: 1px solid var(--border-color);
	overflow: hidden;
	display: none;
}

.tasks-table {
	width: 100%;
	border-collapse: collapse;
	text-align: left;
}

.tasks-table th {
	background: #f8fafc;
	padding: 14px 18px;
	font-size: 12px;
	font-weight: 700;
	color: var(--text-muted);
	text-transform: uppercase;
	letter-spacing: 0.5px;
	border-bottom: 1px solid var(--border-color);
}

.tasks-table td {
	padding: 16px 18px;
	font-size: 13.5px;
	border-bottom: 1px solid var(--border-color);
	vertical-align: middle;
}

.tasks-table tr:last-child td { border-bottom: none; }
.tasks-table tr:hover { background: #f8fafc; }

/* Empty State */
.empty-state {
	grid-column: 1 / -1;
	background: var(--card-bg);
	border-radius: var(--radius);
	padding: 60px 20px;
	text-align: center;
	border: 1px dashed var(--border-color);
	box-shadow: var(--shadow-sm);
}

.empty-state-icon {
	width: 70px;
	height: 70px;
	background: #e0e7ff;
	color: var(--primary);
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 28px;
	margin: 0 auto 20px;
}

.empty-state h4 {
	font-family: 'Outfit', sans-serif;
	font-size: 20px;
	font-weight: 600;
	color: var(--text-dark);
	margin-bottom: 8px;
}

.empty-state p { font-size: 14px; color: var(--text-muted); }

@media (max-width: 768px) {
	.main-wrapper { padding: 15px 12px; }
	.page-header { padding: 25px 20px; }
	.header-title-box h1 { font-size: 22px; }
	.stats-grid { grid-template-columns: repeat(2, 1fr); }
	.server-search-form { flex-direction: column; align-items: stretch; }
	.quick-toolbar { flex-direction: column; align-items: stretch; }
	.tasks-grid-view { grid-template-columns: 1fr; }
}
</style>
</head>

<body>

	<div class="main-wrapper">

		<!-- Header Banner -->
		<div class="page-header">
			<div class="header-top">
				<div class="header-title-box">
					<div class="header-icon">
						<i class="fa-solid fa-list-check"></i>
					</div>
					<div>
						<h1>Task Management</h1>
						<p>Monitor, assign, edit, and track status across all organization tasks</p>
					</div>
				</div>

				<div class="header-actions">
					<a href="taskReport" class="header-btn btn-report">
						<i class="fa-solid fa-chart-pie"></i> Task Reports
					</a>
					<% if (canManageTask) { %>
						<a href="createTask" class="header-btn btn-create">
							<i class="fa-solid fa-plus"></i> Create Task
						</a>
					<% } %>
					<a href="<%= backDashUrl %>" class="header-btn btn-back">
						<i class="fa-solid fa-house"></i> Dashboard
					</a>
				</div>
			</div>
		</div>

		<!-- Toast Flash Alerts -->
		<% if (successMsg != null) { %>
			<div class="alert-toast alert-success">
				<i class="fa-solid fa-circle-check"></i> <%= successMsg %>
			</div>
		<% } %>
		<% if (errorMsg != null) { %>
			<div class="alert-toast alert-error">
				<i class="fa-solid fa-circle-exclamation"></i> <%= errorMsg %>
			</div>
		<% } %>

		<!-- Metric Summary Cards -->
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-info">
					<h3><%= totalCount %></h3>
					<p>Total Tasks</p>
				</div>
				<div class="stat-icon-wrapper icon-total">
					<i class="fa-solid fa-clipboard-list"></i>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-info">
					<h3><%= pendingCount %></h3>
					<p>Pending Tasks</p>
				</div>
				<div class="stat-icon-wrapper icon-pending">
					<i class="fa-solid fa-clock"></i>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-info">
					<h3><%= inProgressCount %></h3>
					<p>In Progress</p>
				</div>
				<div class="stat-icon-wrapper icon-progress">
					<i class="fa-solid fa-spinner"></i>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-info">
					<h3><%= completedCount %></h3>
					<p>Completed Tasks</p>
				</div>
				<div class="stat-icon-wrapper icon-completed">
					<i class="fa-solid fa-circle-check"></i>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-info">
					<h3><%= overdueCount %></h3>
					<p>Overdue Tasks</p>
				</div>
				<div class="stat-icon-wrapper icon-overdue">
					<i class="fa-solid fa-triangle-exclamation"></i>
				</div>
			</div>
		</div>

		<!-- Toolbar & Filters Card -->
		<div class="toolbar-card">
			<!-- Server-side Search Form -->
			<form action="viewTasksServlet" method="get" class="server-search-form">
				<input type="text" name="searchTaskId" placeholder="Task ID (e.g. T101)" value="<%= searchTaskId != null ? searchTaskId : "" %>">
				<input type="text" name="searchEmpId" placeholder="Employee ID" value="<%= searchEmpId != null ? searchEmpId : "" %>">
				
				<select name="searchStatus">
					<option value="ALL">All Statuses</option>
					<option value="PENDING" <%= "PENDING".equalsIgnoreCase(searchStatus) ? "selected" : "" %>>Pending</option>
					<option value="IN_PROGRESS" <%= "IN_PROGRESS".equalsIgnoreCase(searchStatus) ? "selected" : "" %>>In Progress</option>
					<option value="COMPLETED" <%= "COMPLETED".equalsIgnoreCase(searchStatus) ? "selected" : "" %>>Completed</option>
				</select>

				<select name="searchPriority">
					<option value="ALL">All Priorities</option>
					<option value="HIGH" <%= "HIGH".equalsIgnoreCase(searchPriority) ? "selected" : "" %>>High</option>
					<option value="MEDIUM" <%= "MEDIUM".equalsIgnoreCase(searchPriority) ? "selected" : "" %>>Medium</option>
					<option value="LOW" <%= "LOW".equalsIgnoreCase(searchPriority) ? "selected" : "" %>>Low</option>
				</select>

				<button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
				<a href="viewTasksServlet" class="btn-reset"><i class="fa-solid fa-rotate-left"></i> Reset</a>
			</form>

			<!-- Client-side Quick Toolbar -->
			<div class="quick-toolbar">
				<div class="live-search-box">
					<i class="fa-solid fa-filter"></i>
					<input type="text" id="liveSearchInput" placeholder="Instant filter task title, assigner, or employee..." onkeyup="applyLiveFilters()">
				</div>

				<div class="filter-pills">
					<button class="pill-btn active" onclick="filterByPillStatus('ALL', this)">All</button>
					<button class="pill-btn" onclick="filterByPillStatus('PENDING', this)">Pending</button>
					<button class="pill-btn" onclick="filterByPillStatus('IN_PROGRESS', this)">In Progress</button>
					<button class="pill-btn" onclick="filterByPillStatus('COMPLETED', this)">Completed</button>
				</div>

				<div class="view-toggle-wrap">
					<button class="view-btn active" id="btnGrid" onclick="switchTaskView('grid')" title="Card Grid View">
						<i class="fa-solid fa-grip"></i>
					</button>
					<button class="view-btn" id="btnTable" onclick="switchTaskView('table')" title="Table View">
						<i class="fa-solid fa-table-list"></i>
					</button>
				</div>
			</div>
		</div>

		<!-- Card Grid View -->
		<div class="tasks-grid-view" id="tasksGridView">
			<%
			if (taskList != null && !taskList.isEmpty()) {
				for (Task task : taskList) {
					String statusStr = task.getStatus() != null ? task.getStatus().name() : "PENDING";
					String priorityStr = task.getPriority() != null ? task.getPriority().name() : "MEDIUM";
					boolean isOverdue = !"COMPLETED".equalsIgnoreCase(statusStr) && task.getDueDate() != null && task.getDueDate().before(today);
					String empName = empNameMap.getOrDefault(task.getEmployeeId(), "Emp #" + task.getEmployeeId());
			%>

			<div class="task-card"
				 data-title="<%= task.getTaskName() != null ? task.getTaskName().toLowerCase() : "" %>"
				 data-id="<%= task.getTaskId() != null ? task.getTaskId().toLowerCase() : "" %>"
				 data-emp="<%= empName.toLowerCase() %>"
				 data-assigner="<%= task.getAssignedBy() != null ? task.getAssignedBy().toLowerCase() : "" %>"
				 data-status="<%= statusStr %>"
				 data-priority="<%= priorityStr %>">
				
				<div>
					<div class="task-card-header">
						<span class="task-id-badge"><%= task.getTaskId() %></span>
						<div class="badges-row">
							<span class="badge-priority p-<%= priorityStr %>"><%= priorityStr %></span>
							<span class="badge-status st-<%= statusStr %>">
								<span class="dot-indicator"></span>
								<%= statusStr.replace("_", " ") %>
							</span>
						</div>
					</div>

					<h3 class="task-title"><%= task.getTaskName() %></h3>
					<p class="task-desc"><%= task.getDescription() != null ? task.getDescription() : "No detailed description provided." %></p>
				</div>

				<div>
					<div class="task-meta-box">
						<div class="meta-row">
							<i class="fa-solid fa-user"></i> Assigned To:
							<span><%= empName %> (ID: <%= task.getEmployeeId() %>)</span>
						</div>
						<div class="meta-row">
							<i class="fa-solid fa-user-tie"></i> Assigned By:
							<span><%= task.getAssignedBy() != null ? task.getAssignedBy() : "Manager" %></span>
						</div>
						<div class="meta-row">
							<i class="fa-solid fa-calendar-day"></i> Assigned Date:
							<span><%= task.getAssignedDate() %></span>
						</div>
						<div class="meta-row <%= isOverdue ? "overdue" : "" %>">
							<i class="fa-solid fa-calendar-check"></i> Due Date:
							<span>
								<%= task.getDueDate() %>
								<% if (isOverdue) { %>
									<i class="fa-solid fa-circle-exclamation" title="Overdue"></i>
								<% } %>
							</span>
						</div>
						<% if (task.getCompletionDate() != null) { %>
							<div class="meta-row">
								<i class="fa-solid fa-circle-check" style="color:#10b981;"></i> Completed On:
								<span><%= task.getCompletionDate() %></span>
							</div>
						<% } %>
					</div>

					<% if (canManageTask) { %>
						<div class="card-control-row">
							<div class="control-item">
								<label><i class="fa-solid fa-user-gear"></i> Quick Re-assign:</label>
								<form action="assignTask" method="post" style="margin:0;">
									<input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
									<select name="employeeId" onchange="this.form.submit()">
										<option value="">Select Employee...</option>
										<% if (employees != null) {
											for (Employee emp : employees) { %>
												<option value="<%= emp.getEmployee_id() %>" <%= emp.getEmployee_id() == task.getEmployeeId() ? "selected" : "" %>>
													<%= emp.getEmployee_name() %> (ID: <%= emp.getEmployee_id() %>)
												</option>
										<%  }
										   } %>
									</select>
								</form>
							</div>

							<div class="control-item">
								<label><i class="fa-solid fa-sliders"></i> Status Action:</label>
								<form action="updateTaskStatus" method="post" style="margin:0;">
									<input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
									<input type="hidden" name="redirect" value="viewTasks">
									<select name="status" onchange="this.form.submit()">
										<option value="PENDING" <%= "PENDING".equals(statusStr) ? "selected" : "" %>>Pending</option>
										<option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusStr) ? "selected" : "" %>>In Progress</option>
										<option value="COMPLETED" <%= "COMPLETED".equals(statusStr) ? "selected" : "" %>>Completed</option>
									</select>
								</form>
							</div>
						</div>
					<% } %>

					<div class="card-footer-actions">
						<% if (canManageTask) { %>
							<a href="editTaskServlet?taskId=<%= task.getTaskId() %>" class="btn-icon-action btn-edit-act" title="Edit Task">
								<i class="fa-solid fa-pen-to-square"></i> Edit
							</a>
							<a href="deleteTaskServlet?taskId=<%= task.getTaskId() %>" class="btn-icon-action btn-del-act" onclick="return confirm('Are you sure you want to delete this task?');" title="Delete Task">
								<i class="fa-solid fa-trash"></i> Delete
							</a>
						<% } else { %>
							<span style="font-size:12px; color:var(--text-muted);">View Only</span>
						<% } %>
					</div>
				</div>
			</div>

			<%
				}
			} else {
			%>

			<div class="empty-state">
				<div class="empty-state-icon">
					<i class="fa-solid fa-folder-open"></i>
				</div>
				<h4>No Tasks Found</h4>
				<p>No task records match your current search or filter parameters.</p>
			</div>

			<% } %>
		</div>

		<!-- Table View -->
		<div class="tasks-table-view" id="tasksTableView">
			<table class="tasks-table">
				<thead>
					<tr>
						<th>Task ID</th>
						<th>Task Name</th>
						<th>Assigned Employee</th>
						<th>Assigned By</th>
						<th>Priority</th>
						<th>Status</th>
						<th>Due Date</th>
						<th>Completion Date</th>
						<th>Quick Re-assign</th>
						<th>Status Action</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					<%
					if (taskList != null && !taskList.isEmpty()) {
						for (Task task : taskList) {
							String statusStr = task.getStatus() != null ? task.getStatus().name() : "PENDING";
							String priorityStr = task.getPriority() != null ? task.getPriority().name() : "MEDIUM";
							String empName = empNameMap.getOrDefault(task.getEmployeeId(), "Emp #" + task.getEmployeeId());
					%>
					<tr class="table-task-row"
						data-title="<%= task.getTaskName() != null ? task.getTaskName().toLowerCase() : "" %>"
						data-id="<%= task.getTaskId() != null ? task.getTaskId().toLowerCase() : "" %>"
						data-emp="<%= empName.toLowerCase() %>"
						data-assigner="<%= task.getAssignedBy() != null ? task.getAssignedBy().toLowerCase() : "" %>"
						data-status="<%= statusStr %>"
						data-priority="<%= priorityStr %>">
						<td><span class="task-id-badge"><%= task.getTaskId() %></span></td>
						<td>
							<strong><%= task.getTaskName() %></strong>
							<% if (task.getDescription() != null && !task.getDescription().isBlank()) { %>
								<div style="font-size:12px; color:var(--text-muted); margin-top:2px;"><%= task.getDescription() %></div>
							<% } %>
						</td>
						<td><strong><%= empName %></strong> <span style="font-size:11px; color:var(--text-muted);">(ID: <%= task.getEmployeeId() %>)</span></td>
						<td><%= task.getAssignedBy() != null ? task.getAssignedBy() : "Manager" %></td>
						<td><span class="badge-priority p-<%= priorityStr %>"><%= priorityStr %></span></td>
						<td>
							<span class="badge-status st-<%= statusStr %>">
								<span class="dot-indicator"></span>
								<%= statusStr.replace("_", " ") %>
							</span>
						</td>
						<td><%= task.getDueDate() %></td>
						<td><%= task.getCompletionDate() != null ? task.getCompletionDate() : "-" %></td>
						<td>
							<% if (canManageTask) { %>
								<form action="assignTask" method="post" style="margin:0;">
									<input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
									<select name="employeeId" style="padding:5px 8px; font-size:12px; border-radius:6px; border:1px solid var(--border-color);" onchange="this.form.submit()">
										<option value="">Re-assign...</option>
										<% if (employees != null) {
											for (Employee emp : employees) { %>
												<option value="<%= emp.getEmployee_id() %>" <%= emp.getEmployee_id() == task.getEmployeeId() ? "selected" : "" %>>
													<%= emp.getEmployee_name() %>
												</option>
										<%  }
										   } %>
									</select>
								</form>
							<% } else { %>
								-
							<% } %>
						</td>
						<td>
							<% if (canManageTask) { %>
								<form action="updateTaskStatus" method="post" style="margin:0;">
									<input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
									<input type="hidden" name="redirect" value="viewTasks">
									<select name="status" style="padding:5px 8px; font-size:12px; border-radius:6px; border:1px solid var(--border-color);" onchange="this.form.submit()">
										<option value="PENDING" <%= "PENDING".equals(statusStr) ? "selected" : "" %>>Pending</option>
										<option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusStr) ? "selected" : "" %>>In Progress</option>
										<option value="COMPLETED" <%= "COMPLETED".equals(statusStr) ? "selected" : "" %>>Completed</option>
									</select>
								</form>
							<% } else { %>
								<span class="badge-status st-<%= statusStr %>"><%= statusStr %></span>
							<% } %>
						</td>
						<td>
							<% if (canManageTask) { %>
								<div style="display:flex; gap:6px;">
									<a href="editTaskServlet?taskId=<%= task.getTaskId() %>" class="btn-icon-action btn-edit-act" title="Edit"><i class="fa-solid fa-pen-to-square"></i></a>
									<a href="deleteTaskServlet?taskId=<%= task.getTaskId() %>" class="btn-icon-action btn-del-act" onclick="return confirm('Are you sure you want to delete this task?');" title="Delete"><i class="fa-solid fa-trash"></i></a>
								</div>
							<% } else { %>
								-
							<% } %>
						</td>
					</tr>
					<%
						}
					}
					%>
				</tbody>
			</table>
		</div>

	</div>

<script>
let currentPillFilter = 'ALL';

function filterByPillStatus(status, btnElement) {
	currentPillFilter = status;
	document.querySelectorAll('.pill-btn').forEach(btn => btn.classList.remove('active'));
	if (btnElement) btnElement.classList.add('active');
	applyLiveFilters();
}

function applyLiveFilters() {
	const query = document.getElementById('liveSearchInput').value.toLowerCase().trim();
	
	// Grid Cards
	const cards = document.querySelectorAll('.task-card');
	cards.forEach(card => {
		const title = card.getAttribute('data-title') || '';
		const id = card.getAttribute('data-id') || '';
		const emp = card.getAttribute('data-emp') || '';
		const assigner = card.getAttribute('data-assigner') || '';
		const status = card.getAttribute('data-status') || '';
		
		const matchesQuery = title.includes(query) || id.includes(query) || emp.includes(query) || assigner.includes(query);
		const matchesStatus = (currentPillFilter === 'ALL') || (status === currentPillFilter);
		
		card.style.display = (matchesQuery && matchesStatus) ? 'flex' : 'none';
	});
	
	// Table Rows
	const rows = document.querySelectorAll('.table-task-row');
	rows.forEach(row => {
		const title = row.getAttribute('data-title') || '';
		const id = row.getAttribute('data-id') || '';
		const emp = row.getAttribute('data-emp') || '';
		const assigner = row.getAttribute('data-assigner') || '';
		const status = row.getAttribute('data-status') || '';
		
		const matchesQuery = title.includes(query) || id.includes(query) || emp.includes(query) || assigner.includes(query);
		const matchesStatus = (currentPillFilter === 'ALL') || (status === currentPillFilter);
		
		row.style.display = (matchesQuery && matchesStatus) ? '' : 'none';
	});
}

function switchTaskView(mode) {
	const gridView = document.getElementById('tasksGridView');
	const tableView = document.getElementById('tasksTableView');
	const btnGrid = document.getElementById('btnGrid');
	const btnTable = document.getElementById('btnTable');
	
	if (mode === 'grid') {
		gridView.style.display = 'grid';
		tableView.style.display = 'none';
		btnGrid.classList.add('active');
		btnTable.classList.remove('active');
	} else {
		gridView.style.display = 'none';
		tableView.style.display = 'block';
		btnGrid.classList.remove('active');
		btnTable.classList.add('active');
	}
}
</script>

</body>
</html>