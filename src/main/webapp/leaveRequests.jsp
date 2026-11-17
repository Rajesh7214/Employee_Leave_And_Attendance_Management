<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.rajesh.elams.model.Leave"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.User"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
if (loggedUser == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String role = (String) session.getAttribute("role");
if (role == null) role = loggedUser.getRole();

String dashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";

String uName = loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "User";
uName = Character.toUpperCase(uName.charAt(0)) + (uName.length() > 1 ? uName.substring(1) : "");

@SuppressWarnings("unchecked")
List<Leave> pendingLeaves = (List<Leave>) request.getAttribute("pendingLeaves");
@SuppressWarnings("unchecked")
List<Leave> approvedLeaves = (List<Leave>) request.getAttribute("approvedLeaves");
@SuppressWarnings("unchecked")
List<Leave> rejectedLeaves = (List<Leave>) request.getAttribute("rejectedLeaves");
@SuppressWarnings("unchecked")
List<Leave> allLeaves = (List<Leave>) request.getAttribute("allLeaves");

@SuppressWarnings("unchecked")
Map<Integer, Employee> employeeMap = (Map<Integer, Employee>) request.getAttribute("employeeMap");
if (employeeMap == null) employeeMap = new HashMap<>();

int pendingCount = pendingLeaves != null ? pendingLeaves.size() : 0;
int approvedCount = approvedLeaves != null ? approvedLeaves.size() : 0;
int rejectedCount = rejectedLeaves != null ? rejectedLeaves.size() : 0;
int totalCount = allLeaves != null ? allLeaves.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>ELAMS | Leave Approvals &amp; Workforce Portal</title>

<!-- Fonts & Icons -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;600;700&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
:root {
	--bg-body: #f8fafc;
	--bg-sidebar: #090d16;
	--card-surface: #ffffff;
	--card-muted: #f8fafc;
	--border-light: #e2e8f0;
	--border-subtle: #f1f5f9;
	
	--primary-indigo: #4f46e5;
	--primary-indigo-light: #6366f1;
	--accent-emerald: #10b981;
	--accent-amber: #f59e0b;
	--accent-rose: #f43f5e;
	--accent-cyan: #0284c7;

	--text-main: #0f172a;
	--text-secondary: #475569;
	--text-muted: #64748b;
	
	--radius-md: 14px;
	--radius-lg: 20px;
	--shadow-card: 0 4px 20px -2px rgba(15, 23, 42, 0.05), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
	--shadow-hover: 0 12px 28px -4px rgba(15, 23, 42, 0.08);
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: var(--bg-body);
	color: var(--text-main);
	min-height: 100vh;
	display: flex;
	flex-direction: column;
}

/* Header Navbar */
.navbar {
	background: linear-gradient(135deg, #090d16 0%, #1e1b4b 100%);
	color: #ffffff;
	padding: 16px 36px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 20px rgba(9, 13, 22, 0.3);
	position: sticky;
	top: 0;
	z-index: 100;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.brand-wrap {
	display: flex;
	align-items: center;
	gap: 12px;
}

.brand-icon {
	width: 40px;
	height: 40px;
	border-radius: 12px;
	background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 19px;
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(79, 70, 229, 0.4);
}

.brand-text {
	font-size: 19px;
	font-weight: 800;
	letter-spacing: -0.4px;
}

.brand-text span {
	color: #818cf8;
}

.navbar-right {
	display: flex;
	align-items: center;
	gap: 16px;
}

.user-pill {
	display: flex;
	align-items: center;
	gap: 10px;
	background: rgba(255, 255, 255, 0.08);
	padding: 5px 14px 5px 6px;
	border-radius: 30px;
	border: 1px solid rgba(255, 255, 255, 0.12);
}

.avatar-circle {
	width: 32px;
	height: 32px;
	border-radius: 50%;
	background: #4f46e5;
	color: #ffffff;
	font-weight: 800;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 13px;
}

.btn-nav-dash {
	padding: 8px 16px;
	border-radius: 10px;
	background: rgba(255, 255, 255, 0.12);
	color: #ffffff;
	text-decoration: none;
	font-size: 13px;
	font-weight: 700;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s ease;
	border: 1px solid rgba(255, 255, 255, 0.15);
}

.btn-nav-dash:hover {
	background: #4f46e5;
	border-color: #4f46e5;
	transform: translateY(-1px);
}

/* Main Content Container */
.main-viewport {
	padding: 32px 36px 48px;
	max-width: 1440px;
	margin: 0 auto;
	width: 100%;
	display: flex;
	flex-direction: column;
	gap: 28px;
}

/* Flash Alert Banner */
.flash-alert-banner {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 14px 20px;
	border-radius: var(--radius-md);
	background: #ecfdf5;
	border: 1px solid #a7f3d0;
	color: #047857;
	font-size: 14px;
	font-weight: 700;
	box-shadow: 0 4px 12px rgba(16, 185, 129, 0.1);
}

/* Top Workspace Title Header */
.workspace-header-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 16px;
}

.page-headline h1 {
	font-size: 24px;
	font-weight: 800;
	color: var(--text-main);
	letter-spacing: -0.4px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.page-headline p {
	font-size: 13.5px;
	color: var(--text-muted);
	font-weight: 500;
	margin-top: 4px;
}

.btn-refresh {
	padding: 9px 18px;
	border-radius: 12px;
	background: #ffffff;
	border: 1px solid var(--border-light);
	color: var(--text-secondary);
	font-size: 13px;
	font-weight: 700;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	box-shadow: 0 2px 6px rgba(0,0,0,0.04);
	transition: all 0.2s ease;
	text-decoration: none;
}

.btn-refresh:hover {
	border-color: #cbd5e1;
	color: var(--primary-indigo);
	transform: translateY(-1px);
}

/* KPI Summary Cards Grid */
.kpi-cards-grid {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 20px;
}

@media (max-width: 1024px) {
	.kpi-cards-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 640px) {
	.kpi-cards-grid { grid-template-columns: 1fr; }
}

.kpi-card {
	background: var(--card-surface);
	border-radius: var(--radius-lg);
	padding: 20px 22px;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-card);
	display: flex;
	align-items: center;
	justify-content: space-between;
	transition: all 0.2s ease;
}

.kpi-card:hover {
	transform: translateY(-2px);
	box-shadow: var(--shadow-hover);
	border-color: #cbd5e1;
}

.kpi-info {
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.kpi-label {
	font-size: 13px;
	font-weight: 600;
	color: var(--text-muted);
}

.kpi-value {
	font-size: 26px;
	font-weight: 800;
	color: var(--text-main);
	letter-spacing: -0.5px;
	line-height: 1.1;
}

.kpi-icon-box {
	width: 48px;
	height: 48px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	color: #ffffff;
}

.icon-amber   { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3); }
.icon-emerald { background: linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
.icon-rose    { background: linear-gradient(135deg, #f43f5e 0%, #e11d48 100%); box-shadow: 0 4px 12px rgba(244, 63, 94, 0.3); }
.icon-indigo  { background: linear-gradient(135deg, #6366f1 0%, #4338ca 100%); box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }

/* Main Table Container Card */
.table-panel-card {
	background: var(--card-surface);
	border-radius: var(--radius-lg);
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-card);
	overflow: hidden;
	display: flex;
	flex-direction: column;
}

/* Control Bar: Tabs & Search Input */
.table-control-bar {
	padding: 18px 24px;
	background: var(--card-surface);
	border-bottom: 1px solid var(--border-light);
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 16px;
}

.tabs-navigation {
	display: flex;
	align-items: center;
	gap: 8px;
	background: var(--card-muted);
	padding: 4px;
	border-radius: 12px;
	border: 1px solid var(--border-subtle);
}

.tab-btn {
	padding: 7px 16px;
	border-radius: 9px;
	font-size: 13px;
	font-weight: 700;
	color: var(--text-secondary);
	border: none;
	background: transparent;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s ease;
}

.tab-btn:hover {
	color: var(--text-main);
}

.tab-btn.active {
	background: #ffffff;
	color: var(--primary-indigo);
	box-shadow: 0 2px 8px rgba(15, 23, 42, 0.08);
}

.tab-badge {
	padding: 2px 7px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 800;
	background: var(--border-light);
	color: var(--text-secondary);
}

.tab-btn.active .tab-badge {
	background: #e0e7ff;
	color: var(--primary-indigo);
}

/* Search Box */
.search-box-wrap {
	position: relative;
	min-width: 280px;
}

.search-box-wrap i {
	position: absolute;
	left: 14px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text-muted);
	font-size: 14px;
}

.search-input {
	width: 100%;
	padding: 9px 14px 9px 38px;
	border-radius: 10px;
	border: 1px solid var(--border-light);
	background: var(--card-muted);
	font-size: 13px;
	color: var(--text-main);
	outline: none;
	transition: all 0.2s ease;
}

.search-input:focus {
	background: #ffffff;
	border-color: var(--primary-indigo-light);
	box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

/* Custom Table View */
.table-responsive {
	width: 100%;
	overflow-x: auto;
}

.leave-data-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 13px;
	text-align: left;
}

.leave-data-table th {
	background: #f8fafc;
	color: var(--text-secondary);
	font-weight: 700;
	padding: 14px 18px;
	text-transform: uppercase;
	font-size: 11.5px;
	letter-spacing: 0.5px;
	border-bottom: 1px solid var(--border-light);
	white-space: nowrap;
}

.leave-data-table td {
	padding: 16px 18px;
	border-bottom: 1px solid var(--border-subtle);
	color: var(--text-main);
	vertical-align: middle;
}

.leave-data-table tr:last-child td {
	border-bottom: none;
}

.leave-data-table tr:hover td {
	background: #faf5ff;
}

/* Employee Pill in Table */
.emp-cell-profile {
	display: flex;
	align-items: center;
	gap: 12px;
}

.emp-table-avatar {
	width: 38px;
	height: 38px;
	border-radius: 12px;
	object-fit: cover;
	border: 1px solid var(--border-light);
	background: #4f46e5;
	color: #ffffff;
	font-weight: 800;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 14px;
	flex-shrink: 0;
}

.emp-details {
	display: flex;
	flex-direction: column;
	gap: 2px;
}

.emp-name {
	font-size: 13.5px;
	font-weight: 700;
	color: var(--text-main);
}

.emp-meta {
	font-size: 11px;
	color: var(--text-muted);
	font-weight: 500;
}

/* Badges & Chips */
.leave-type-chip {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 10px;
	border-radius: 8px;
	font-size: 12px;
	font-weight: 700;
	background: #e0f2fe;
	color: #0369a1;
	border: 1px solid #bae6fd;
}

.chip-lop-warning {
	background: #fef2f2;
	color: #b91c1c;
	border-color: #fecaca;
}

.duration-tag {
	font-family: 'JetBrains Mono', monospace;
	font-size: 11.5px;
	font-weight: 700;
	padding: 2px 7px;
	border-radius: 6px;
	background: #f1f5f9;
	color: var(--text-secondary);
	display: inline-block;
	margin-top: 3px;
}

/* Status Badges */
.status-pill {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 10px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
}

.status-pending  { background: #fffbeb; color: #b45309; border: 1px solid #fde68a; }
.status-approved { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
.status-rejected { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }

.status-dot {
	width: 7px;
	height: 7px;
	border-radius: 50%;
	display: inline-block;
}

.dot-pending  { background: #f59e0b; box-shadow: 0 0 6px #f59e0b; }
.dot-approved { background: #10b981; box-shadow: 0 0 6px #10b981; }
.dot-rejected { background: #f43f5e; box-shadow: 0 0 6px #f43f5e; }

/* Action Buttons */
.action-btns-group {
	display: flex;
	align-items: center;
	gap: 8px;
}

.btn-act {
	padding: 7px 14px;
	border-radius: 8px;
	font-size: 12px;
	font-weight: 700;
	border: none;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	text-decoration: none;
	transition: all 0.2s ease;
}

.btn-approve-act {
	background: #10b981;
	color: #ffffff;
	box-shadow: 0 2px 6px rgba(16, 185, 129, 0.3);
}

.btn-approve-act:hover {
	background: #059669;
	transform: translateY(-1px);
}

.btn-reject-act {
	background: #f43f5e;
	color: #ffffff;
	box-shadow: 0 2px 6px rgba(244, 63, 94, 0.3);
}

.btn-reject-act:hover {
	background: #e11d48;
	transform: translateY(-1px);
}

.btn-lop-act {
	background: #f59e0b;
	color: #ffffff;
	box-shadow: 0 2px 6px rgba(245, 158, 11, 0.3);
}

.btn-lop-act:hover {
	background: #d97706;
	transform: translateY(-1px);
}

/* Empty Table View */
.table-empty-box {
	padding: 48px 24px;
	text-align: center;
	color: var(--text-muted);
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 12px;
}

.table-empty-box i {
	font-size: 44px;
	color: #cbd5e1;
}

.table-empty-box h3 {
	font-size: 16px;
	font-weight: 800;
	color: var(--text-main);
}
</style>
</head>
<body>

	<!-- Top Navigation Navbar -->
	<header class="navbar">
		<div class="brand-wrap">
			<div class="brand-icon">
				<i class="fa-solid fa-shield-halved"></i>
			</div>
			<div class="brand-text">ELAMS<span>.</span> Workforce</div>
		</div>

		<div class="navbar-right">
			<div class="user-pill">
				<div class="avatar-circle"><%=uName.substring(0, 1).toUpperCase()%></div>
				<span style="font-size: 13px; font-weight: 700;"><%=uName%> (<%=role != null ? role.toUpperCase() : "HR"%>)</span>
			</div>
			<a href="<%=dashUrl%>" class="btn-nav-dash">
				<i class="fa-solid fa-gauge-high"></i> Dashboard
			</a>
		</div>
	</header>

	<!-- Main Container -->
	<main class="main-viewport">

		<!-- Flash Message Alert -->
		<% if (request.getAttribute("flashSuccess") != null || session.getAttribute("flashSuccess") != null) { 
			String fMsg = request.getAttribute("flashSuccess") != null ? (String) request.getAttribute("flashSuccess") : (String) session.getAttribute("flashSuccess");
			session.removeAttribute("flashSuccess");
		%>
		<div class="flash-alert-banner">
			<i class="fa-solid fa-circle-check" style="font-size: 18px;"></i>
			<span><%=fMsg%></span>
		</div>
		<% } %>

		<!-- Workspace Header Row -->
		<div class="workspace-header-row">
			<div class="page-headline">
				<h1><i class="fa-solid fa-file-signature" style="color: var(--primary-indigo);"></i> Leave Approvals &amp; Management</h1>
				<p>Review, authorize, and manage employee leave applications across the enterprise.</p>
			</div>
			<a href="javascript:location.reload();" class="btn-refresh">
				<i class="fa-solid fa-arrows-rotate"></i> Refresh View
			</a>
		</div>

		<!-- KPI Summary Cards Grid -->
		<div class="kpi-cards-grid">
			<!-- Card 1: Pending -->
			<div class="kpi-card">
				<div class="kpi-info">
					<span class="kpi-label">Pending Approvals</span>
					<span class="kpi-value"><%=pendingCount%></span>
				</div>
				<div class="kpi-icon-box icon-amber">
					<i class="fa-solid fa-hourglass-half"></i>
				</div>
			</div>

			<!-- Card 2: Approved -->
			<div class="kpi-card">
				<div class="kpi-info">
					<span class="kpi-label">Approved Applications</span>
					<span class="kpi-value"><%=approvedCount%></span>
				</div>
				<div class="kpi-icon-box icon-emerald">
					<i class="fa-solid fa-circle-check"></i>
				</div>
			</div>

			<!-- Card 3: Rejected -->
			<div class="kpi-card">
				<div class="kpi-info">
					<span class="kpi-label">Rejected Applications</span>
					<span class="kpi-value"><%=rejectedCount%></span>
				</div>
				<div class="kpi-icon-box icon-rose">
					<i class="fa-solid fa-circle-xmark"></i>
				</div>
			</div>

			<!-- Card 4: Total Processed -->
			<div class="kpi-card">
				<div class="kpi-info">
					<span class="kpi-label">Total Submissions</span>
					<span class="kpi-value"><%=totalCount%></span>
				</div>
				<div class="kpi-icon-box icon-indigo">
					<i class="fa-solid fa-layer-group"></i>
				</div>
			</div>
		</div>

		<!-- Main Table Panel -->
		<div class="table-panel-card">
			<!-- Control Bar: Tabs & Real-time Search -->
			<div class="table-control-bar">
				<div class="tabs-navigation">
					<button class="tab-btn active" onclick="switchTab('pending', this)">
						<i class="fa-solid fa-clock-rotate-left"></i> Pending <span class="tab-badge"><%=pendingCount%></span>
					</button>
					<button class="tab-btn" onclick="switchTab('approved', this)">
						<i class="fa-solid fa-check"></i> Approved <span class="tab-badge"><%=approvedCount%></span>
					</button>
					<button class="tab-btn" onclick="switchTab('rejected', this)">
						<i class="fa-solid fa-xmark"></i> Rejected <span class="tab-badge"><%=rejectedCount%></span>
					</button>
					<button class="tab-btn" onclick="switchTab('all', this)">
						<i class="fa-solid fa-list"></i> All Applications <span class="tab-badge"><%=totalCount%></span>
					</button>
				</div>

				<div class="search-box-wrap">
					<i class="fa-solid fa-magnifying-glass"></i>
					<input type="text" id="leaveSearchInput" class="search-input" placeholder="Search by name, ID, type, reason..." onkeyup="filterLeaveTable()" />
				</div>
			</div>

			<!-- Table Body Container -->
			<div class="table-responsive">

				<!-- 1. PENDING LEAVES TAB -->
				<div id="tab-pending" class="tab-content-panel">
					<% if (pendingLeaves != null && !pendingLeaves.isEmpty()) { %>
					<table class="leave-data-table">
						<thead>
							<tr>
								<th>App ID</th>
								<th>Employee</th>
								<th>Leave Type</th>
								<th>Duration &amp; Dates</th>
								<th>Reason</th>
								<th>Status</th>
								<th style="text-align: right;">Decision Actions</th>
							</tr>
						</thead>
						<tbody>
							<%
							for (Leave l : pendingLeaves) {
								Employee emp = employeeMap.get(l.getEmployeeId());
								String empName = emp != null && emp.getEmployee_name() != null ? emp.getEmployee_name() : "Employee #" + l.getEmployeeId();
								String dept = emp != null && emp.getDepartment() != null ? emp.getDepartment() : "Staff";
								String desig = emp != null && emp.getDesignation() != null ? emp.getDesignation() : "Associate";
								String photo = emp != null && emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank() ? emp.getProfile_photo() : "";
								
								String lType = l.getLeaveType() != null ? l.getLeaveType() : "Leave";
								boolean isLop = lType.toUpperCase().contains("UNPAID") || lType.toUpperCase().contains("LOP") || lType.toUpperCase().contains("LOSS");

								long dayCount = 1;
								if (l.getStartDate() != null && l.getEndDate() != null) {
									long diff = l.getEndDate().getTime() - l.getStartDate().getTime();
									dayCount = Math.max(1, (diff / (1000 * 60 * 60 * 24)) + 1);
								}
							%>
							<tr class="leave-row-item">
								<td><strong>#L<%=l.getLeaveId()%></strong></td>
								<td>
									<div class="emp-cell-profile">
										<% if (!photo.isEmpty()) { %>
											<img src="<%=photo%>" alt="Photo" class="emp-table-avatar" />
										<% } else { %>
											<div class="emp-table-avatar"><%=empName.substring(0, 1).toUpperCase()%></div>
										<% } %>
										<div class="emp-details">
											<span class="emp-name"><%=empName%></span>
											<span class="emp-meta"><%=desig%> &bull; <%=dept%> (EMP#<%=l.getEmployeeId()%>)</span>
										</div>
									</div>
								</td>
								<td>
									<span class="leave-type-chip <%=isLop ? "chip-lop-warning" : ""%>">
										<i class="fa-solid <%=isLop ? "fa-triangle-exclamation" : "fa-calendar-day"%>"></i> <%=lType%>
									</span>
								</td>
								<td>
									<div style="font-weight: 700; color: var(--text-main);">
										<%=l.getStartDate()%> &rarr; <%=l.getEndDate() != null ? l.getEndDate() : l.getStartDate()%>
									</div>
									<span class="duration-tag"><%=dayCount%> <%=dayCount == 1 ? "Day" : "Days"%></span>
								</td>
								<td style="max-width: 240px; color: var(--text-secondary);">
									<%=l.getReason() != null && !l.getReason().isBlank() ? l.getReason() : "No reason specified"%>
								</td>
								<td>
									<span class="status-pill status-pending">
										<span class="status-dot dot-pending"></span> Pending
									</span>
								</td>
								<td>
									<div class="action-btns-group" style="justify-content: flex-end;">
										<button onclick="approveLeave(<%=l.getLeaveId()%>, '<%=empName%>')" class="btn-act btn-approve-act" title="Approve Leave (Auto-check Paid Balance)">
											<i class="fa-solid fa-check"></i> Approve
										</button>
										<button onclick="approveLeaveAsLop(<%=l.getLeaveId()%>, '<%=empName%>')" class="btn-act btn-lop-act" title="Approve Leave as Loss of Pay (LOP)">
											<i class="fa-solid fa-user-minus"></i> Approve as LOP
										</button>
										<button onclick="rejectLeave(<%=l.getLeaveId()%>, '<%=empName%>')" class="btn-act btn-reject-act">
											<i class="fa-solid fa-xmark"></i> Reject
										</button>
									</div>
								</td>
							</tr>
							<% } %>
						</tbody>
					</table>
					<% } else { %>
					<div class="table-empty-box">
						<i class="fa-solid fa-circle-check" style="color: var(--accent-emerald);"></i>
						<h3>No Pending Leave Applications</h3>
						<p>All employee leave requests have been reviewed and processed.</p>
					</div>
					<% } %>
				</div>

				<!-- 2. APPROVED LEAVES TAB -->
				<div id="tab-approved" class="tab-content-panel" style="display: none;">
					<% if (approvedLeaves != null && !approvedLeaves.isEmpty()) { %>
					<table class="leave-data-table">
						<thead>
							<tr>
								<th>App ID</th>
								<th>Employee</th>
								<th>Leave Type</th>
								<th>Duration &amp; Dates</th>
								<th>Reason</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
							<%
							for (Leave l : approvedLeaves) {
								Employee emp = employeeMap.get(l.getEmployeeId());
								String empName = emp != null && emp.getEmployee_name() != null ? emp.getEmployee_name() : "Employee #" + l.getEmployeeId();
								String dept = emp != null && emp.getDepartment() != null ? emp.getDepartment() : "Staff";
								String desig = emp != null && emp.getDesignation() != null ? emp.getDesignation() : "Associate";
								String photo = emp != null && emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank() ? emp.getProfile_photo() : "";
								String lType = l.getLeaveType() != null ? l.getLeaveType() : "Leave";

								long dayCount = 1;
								if (l.getStartDate() != null && l.getEndDate() != null) {
									long diff = l.getEndDate().getTime() - l.getStartDate().getTime();
									dayCount = Math.max(1, (diff / (1000 * 60 * 60 * 24)) + 1);
								}
							%>
							<tr class="leave-row-item">
								<td><strong>#L<%=l.getLeaveId()%></strong></td>
								<td>
									<div class="emp-cell-profile">
										<% if (!photo.isEmpty()) { %>
											<img src="<%=photo%>" alt="Photo" class="emp-table-avatar" />
										<% } else { %>
											<div class="emp-table-avatar"><%=empName.substring(0, 1).toUpperCase()%></div>
										<% } %>
										<div class="emp-details">
											<span class="emp-name"><%=empName%></span>
											<span class="emp-meta"><%=desig%> &bull; <%=dept%></span>
										</div>
									</div>
								</td>
								<td><span class="leave-type-chip"><i class="fa-solid fa-calendar-check"></i> <%=lType%></span></td>
								<td>
									<div style="font-weight: 700;"><%=l.getStartDate()%> &rarr; <%=l.getEndDate()%></div>
									<span class="duration-tag"><%=dayCount%> Days</span>
								</td>
								<td style="max-width: 240px; color: var(--text-secondary);"><%=l.getReason() != null ? l.getReason() : "-"%></td>
								<td>
									<span class="status-pill status-approved">
										<span class="status-dot dot-approved"></span> Approved
									</span>
								</td>
							</tr>
							<% } %>
						</tbody>
					</table>
					<% } else { %>
					<div class="table-empty-box">
						<i class="fa-solid fa-folder-open"></i>
						<h3>No Approved Leave Records</h3>
						<p>There are no historical approved leave applications.</p>
					</div>
					<% } %>
				</div>

				<!-- 3. REJECTED LEAVES TAB -->
				<div id="tab-rejected" class="tab-content-panel" style="display: none;">
					<% if (rejectedLeaves != null && !rejectedLeaves.isEmpty()) { %>
					<table class="leave-data-table">
						<thead>
							<tr>
								<th>App ID</th>
								<th>Employee</th>
								<th>Leave Type</th>
								<th>Duration &amp; Dates</th>
								<th>Reason</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
							<%
							for (Leave l : rejectedLeaves) {
								Employee emp = employeeMap.get(l.getEmployeeId());
								String empName = emp != null && emp.getEmployee_name() != null ? emp.getEmployee_name() : "Employee #" + l.getEmployeeId();
								String dept = emp != null && emp.getDepartment() != null ? emp.getDepartment() : "Staff";
								String desig = emp != null && emp.getDesignation() != null ? emp.getDesignation() : "Associate";
								String photo = emp != null && emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank() ? emp.getProfile_photo() : "";
								String lType = l.getLeaveType() != null ? l.getLeaveType() : "Leave";

								long dayCount = 1;
								if (l.getStartDate() != null && l.getEndDate() != null) {
									long diff = l.getEndDate().getTime() - l.getStartDate().getTime();
									dayCount = Math.max(1, (diff / (1000 * 60 * 60 * 24)) + 1);
								}
							%>
							<tr class="leave-row-item">
								<td><strong>#L<%=l.getLeaveId()%></strong></td>
								<td>
									<div class="emp-cell-profile">
										<% if (!photo.isEmpty()) { %>
											<img src="<%=photo%>" alt="Photo" class="emp-table-avatar" />
										<% } else { %>
											<div class="emp-table-avatar"><%=empName.substring(0, 1).toUpperCase()%></div>
										<% } %>
										<div class="emp-details">
											<span class="emp-name"><%=empName%></span>
											<span class="emp-meta"><%=desig%> &bull; <%=dept%></span>
										</div>
									</div>
								</td>
								<td><span class="leave-type-chip chip-lop-warning"><i class="fa-solid fa-calendar-xmark"></i> <%=lType%></span></td>
								<td>
									<div style="font-weight: 700;"><%=l.getStartDate()%> &rarr; <%=l.getEndDate()%></div>
									<span class="duration-tag"><%=dayCount%> Days</span>
								</td>
								<td style="max-width: 240px; color: var(--text-secondary);"><%=l.getReason() != null ? l.getReason() : "-"%></td>
								<td>
									<span class="status-pill status-rejected">
										<span class="status-dot dot-rejected"></span> Rejected
									</span>
								</td>
							</tr>
							<% } %>
						</tbody>
					</table>
					<% } else { %>
					<div class="table-empty-box">
						<i class="fa-solid fa-folder-open"></i>
						<h3>No Rejected Leave Records</h3>
						<p>There are no rejected leave applications.</p>
					</div>
					<% } %>
				</div>

				<!-- 4. ALL LEAVES TAB -->
				<div id="tab-all" class="tab-content-panel" style="display: none;">
					<% if (allLeaves != null && !allLeaves.isEmpty()) { %>
					<table class="leave-data-table">
						<thead>
							<tr>
								<th>App ID</th>
								<th>Employee</th>
								<th>Leave Type</th>
								<th>Duration &amp; Dates</th>
								<th>Reason</th>
								<th>Status</th>
								<th style="text-align: right;">Actions</th>
							</tr>
						</thead>
						<tbody>
							<%
							for (Leave l : allLeaves) {
								Employee emp = employeeMap.get(l.getEmployeeId());
								String empName = emp != null && emp.getEmployee_name() != null ? emp.getEmployee_name() : "Employee #" + l.getEmployeeId();
								String dept = emp != null && emp.getDepartment() != null ? emp.getDepartment() : "Staff";
								String desig = emp != null && emp.getDesignation() != null ? emp.getDesignation() : "Associate";
								String photo = emp != null && emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank() ? emp.getProfile_photo() : "";
								String lType = l.getLeaveType() != null ? l.getLeaveType() : "Leave";
								String st = l.getStatus() != null ? l.getStatus() : "Pending";

								String pillClass = "status-pending";
								String dotClass = "dot-pending";
								if ("Approved".equalsIgnoreCase(st)) { pillClass = "status-approved"; dotClass = "dot-approved"; }
								else if ("Rejected".equalsIgnoreCase(st)) { pillClass = "status-rejected"; dotClass = "dot-rejected"; }

								long dayCount = 1;
								if (l.getStartDate() != null && l.getEndDate() != null) {
									long diff = l.getEndDate().getTime() - l.getStartDate().getTime();
									dayCount = Math.max(1, (diff / (1000 * 60 * 60 * 24)) + 1);
								}
							%>
							<tr class="leave-row-item">
								<td><strong>#L<%=l.getLeaveId()%></strong></td>
								<td>
									<div class="emp-cell-profile">
										<% if (!photo.isEmpty()) { %>
											<img src="<%=photo%>" alt="Photo" class="emp-table-avatar" />
										<% } else { %>
											<div class="emp-table-avatar"><%=empName.substring(0, 1).toUpperCase()%></div>
										<% } %>
										<div class="emp-details">
											<span class="emp-name"><%=empName%></span>
											<span class="emp-meta"><%=desig%> &bull; <%=dept%></span>
										</div>
									</div>
								</td>
								<td><span class="leave-type-chip"><i class="fa-regular fa-calendar"></i> <%=lType%></span></td>
								<td>
									<div style="font-weight: 700;"><%=l.getStartDate()%> &rarr; <%=l.getEndDate()%></div>
									<span class="duration-tag"><%=dayCount%> Days</span>
								</td>
								<td style="max-width: 240px; color: var(--text-secondary);"><%=l.getReason() != null ? l.getReason() : "-"%></td>
								<td>
									<span class="status-pill <%=pillClass%>">
										<span class="status-dot <%=dotClass%>"></span> <%=st%>
									</span>
								</td>
								<td>
									<% if ("Pending".equalsIgnoreCase(st)) { %>
									<div class="action-btns-group" style="justify-content: flex-end;">
										<button onclick="approveLeave(<%=l.getLeaveId()%>, '<%=empName%>')" class="btn-act btn-approve-act" title="Approve Leave (Auto-check Paid Balance)">
											<i class="fa-solid fa-check"></i> Approve
										</button>
										<button onclick="approveLeaveAsLop(<%=l.getLeaveId()%>, '<%=empName%>')" class="btn-act btn-lop-act" title="Approve Leave as Loss of Pay (LOP)">
											<i class="fa-solid fa-user-minus"></i> Approve as LOP
										</button>
										<button onclick="rejectLeave(<%=l.getLeaveId()%>, '<%=empName%>')" class="btn-act btn-reject-act">
											<i class="fa-solid fa-xmark"></i> Reject
										</button>
									</div>
									<% } else { %>
									<div style="text-align: right; font-size: 12px; color: var(--text-muted); font-weight: 600;">Processed</div>
									<% } %>
								</td>
							</tr>
							<% } %>
						</tbody>
					</table>
					<% } else { %>
					<div class="table-empty-box">
						<i class="fa-solid fa-folder-open"></i>
						<h3>No Leave Applications</h3>
						<p>No employee leave applications found in the system database.</p>
					</div>
					<% } %>
				</div>

			</div>
		</div>

	</main>

	<!-- Scripts for Tab Switcher, Filter & Actions -->
	<script>
		function switchTab(tabName, btnElem) {
			// Update tab button styles
			const buttons = document.querySelectorAll('.tab-btn');
			buttons.forEach(btn => btn.classList.remove('active'));
			if (btnElem) btnElem.classList.add('active');

			// Hide all panels
			const panels = document.querySelectorAll('.tab-content-panel');
			panels.forEach(p => p.style.display = 'none');

			// Show target panel
			const targetPanel = document.getElementById('tab-' + tabName);
			if (targetPanel) {
				targetPanel.style.display = 'block';
			}

			// Re-apply search filter if any
			filterLeaveTable();
		}

		function filterLeaveTable() {
			const query = document.getElementById('leaveSearchInput').value.toLowerCase().trim();
			const activePanel = document.querySelector('.tab-content-panel[style*="display: block"]') || document.getElementById('tab-pending');
			
			if (activePanel) {
				const rows = activePanel.querySelectorAll('.leave-row-item');
				rows.forEach(row => {
					const text = row.textContent.toLowerCase();
					if (text.includes(query)) {
						row.style.display = '';
					} else {
						row.style.display = 'none';
					}
				});
			}
		}

		function approveLeave(leaveId, empName) {
			if (confirm('Are you sure you want to APPROVE Leave Application #' + leaveId + ' for ' + empName + '?\n(System will auto-check paid leave balance)')) {
				window.location.href = 'approveLeave?leaveId=' + leaveId;
			}
		}

		function approveLeaveAsLop(leaveId, empName) {
			if (confirm('Are you sure you want to APPROVE Leave Application #' + leaveId + ' for ' + empName + ' AS LOSS OF PAY (LOP)?\nThis will convert the leave to unpaid and deduct salary during payroll calculation.')) {
				window.location.href = 'approveLeave?leaveId=' + leaveId + '&asLop=true';
			}
		}

		function rejectLeave(leaveId, empName) {
			if (confirm('Are you sure you want to REJECT Leave Application #' + leaveId + ' for ' + empName + '?')) {
				window.location.href = 'rejectLeave?leaveId=' + leaveId;
			}
		}
	</script>
</body>
</html>