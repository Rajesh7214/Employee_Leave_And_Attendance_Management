<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Date"%>
<%@ page import="com.rajesh.elams.model.Task"%>
<%@ page import="com.rajesh.elams.model.TaskStatus"%>

<%
List<Task> taskList = (List<Task>) request.getAttribute("taskList");
String successMsg = (String) session.getAttribute("successMessage");
if (successMsg != null) {
	session.removeAttribute("successMessage");
}
String errorMsg = (String) session.getAttribute("errorMessage");
if (errorMsg != null) {
	session.removeAttribute("errorMessage");
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
<title>My Assigned Tasks | ELAMS SmartOffice</title>

<!-- Google Fonts & Font Awesome -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
:root {
	--primary: #6366f1;
	--primary-hover: #4f46e5;
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
	padding-bottom: 50px;
	line-height: 1.5;
}

.tasks-wrapper {
	max-width: 1250px;
	margin: 0 auto;
	padding: 30px 20px;
}

/* Header Banner */
.page-header {
	background: linear-gradient(135deg, #1e1b4b 0%, #312e81 40%, #4338ca 100%);
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
	right: -20%;
	width: 400px;
	height: 400px;
	background: radial-gradient(circle, rgba(255,255,255,0.12) 0%, rgba(255,255,255,0) 70%);
	border-radius: 50%;
	pointer-events: none;
}

.header-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 15px;
}

.header-title {
	font-family: 'Outfit', sans-serif;
	font-size: 28px;
	font-weight: 700;
	letter-spacing: -0.5px;
	display: flex;
	align-items: center;
	gap: 12px;
}

.header-title i {
	background: rgba(255, 255, 255, 0.15);
	padding: 12px;
	border-radius: 12px;
	font-size: 22px;
}

.header-subtitle {
	color: #c7d2fe;
	font-size: 14px;
	margin-top: 6px;
}

.back-dash-link {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	background: rgba(255, 255, 255, 0.15);
	backdrop-filter: blur(10px);
	color: white;
	text-decoration: none;
	padding: 10px 18px;
	border-radius: 30px;
	font-size: 14px;
	font-weight: 500;
	transition: all 0.2s ease;
	border: 1px solid rgba(255, 255, 255, 0.2);
}

.back-dash-link:hover {
	background: rgba(255, 255, 255, 0.28);
	transform: translateY(-2px);
}

/* Flash Toast Alerts */
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

.alert-success {
	background: #f0fdf4;
	color: #166534;
	border: 1px solid #bbf7d0;
}

.alert-error {
	background: #fef2f2;
	color: #991b1b;
	border: 1px solid #fecaca;
}

/* Stats Metrics Cards Grid */
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
.toolbar-container {
	background: var(--card-bg);
	border-radius: var(--radius);
	padding: 18px 24px;
	box-shadow: var(--shadow-sm);
	border: 1px solid var(--border-color);
	margin-bottom: 30px;
	display: flex;
	flex-wrap: wrap;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
}

.search-box {
	position: relative;
	flex: 1;
	min-width: 260px;
}

.search-box input {
	width: 100%;
	padding: 11px 16px 11px 42px;
	border-radius: 10px;
	border: 1px solid var(--border-color);
	font-size: 14px;
	background: #f8fafc;
	transition: all 0.2s ease;
	outline: none;
}

.search-box input:focus {
	background: white;
	border-color: var(--primary);
	box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.search-box i {
	position: absolute;
	left: 15px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text-muted);
	font-size: 15px;
}

.filter-group {
	display: flex;
	align-items: center;
	gap: 10px;
	flex-wrap: wrap;
}

.filter-btn {
	background: #f1f5f9;
	border: 1px solid transparent;
	padding: 8px 16px;
	border-radius: 20px;
	font-size: 13px;
	font-weight: 500;
	color: var(--text-muted);
	cursor: pointer;
	transition: all 0.2s ease;
}

.filter-btn:hover {
	background: #e2e8f0;
	color: var(--text-dark);
}

.filter-btn.active {
	background: var(--primary);
	color: white;
	box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
}

.view-toggle {
	display: flex;
	background: #f1f5f9;
	padding: 4px;
	border-radius: 10px;
}

.toggle-btn {
	border: none;
	background: transparent;
	padding: 8px 14px;
	border-radius: 8px;
	cursor: pointer;
	color: var(--text-muted);
	font-size: 14px;
	transition: all 0.2s ease;
}

.toggle-btn.active {
	background: white;
	color: var(--primary);
	box-shadow: var(--shadow-sm);
}

/* Card Grid Layout */
.tasks-grid-view {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
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
	margin-bottom: 20px;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.task-meta-details {
	background: #f8fafc;
	border-radius: 12px;
	padding: 12px 16px;
	margin-bottom: 20px;
	display: flex;
	flex-direction: column;
	gap: 8px;
	border: 1px dashed #e2e8f0;
}

.meta-item {
	font-size: 12.5px;
	color: var(--text-muted);
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.meta-item span {
	font-weight: 600;
	color: var(--text-dark);
}

.meta-item.overdue span {
	color: #e11d48;
}

/* Card Actions */
.card-actions {
	display: flex;
	align-items: center;
	gap: 10px;
	padding-top: 15px;
	border-top: 1px solid var(--border-color);
}

.status-select-wrap {
	flex: 1;
}

.status-select-wrap select {
	width: 100%;
	padding: 9px 12px;
	border-radius: 8px;
	border: 1px solid var(--border-color);
	font-size: 13px;
	font-weight: 500;
	background: white;
	cursor: pointer;
	outline: none;
	transition: all 0.2s ease;
}

.status-select-wrap select:focus {
	border-color: var(--primary);
}

.btn-complete-action {
	background: #16a34a;
	color: white;
	border: none;
	padding: 9px 14px;
	border-radius: 8px;
	font-size: 13px;
	font-weight: 600;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
	white-space: nowrap;
}

.btn-complete-action:hover {
	background: #15803d;
	box-shadow: 0 4px 10px rgba(22, 163, 74, 0.25);
}

.btn-done-disabled {
	background: #f1f5f9;
	color: #16a34a;
	padding: 9px 14px;
	border-radius: 8px;
	font-size: 13px;
	font-weight: 600;
	display: inline-flex;
	align-items: center;
	gap: 6px;
}

/* Table View (Alternative View) */
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

.tasks-table tr:last-child td {
	border-bottom: none;
}

.tasks-table tr:hover {
	background: #f8fafc;
}

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

.empty-state p {
	font-size: 14px;
	color: var(--text-muted);
}

@media (max-width: 768px) {
	.tasks-wrapper { padding: 15px 12px; }
	.page-header { padding: 25px 20px; }
	.header-title { font-size: 22px; }
	.stats-grid { grid-template-columns: repeat(2, 1fr); }
	.toolbar-container { flex-direction: column; align-items: stretch; }
	.search-box { min-width: 100%; }
	.tasks-grid-view { grid-template-columns: 1fr; }
}
</style>
</head>

<body>

	<div class="tasks-wrapper">

		<!-- Header Banner -->
		<div class="page-header">
			<div class="header-top">
				<div>
					<div class="header-title">
						<i class="fa-solid fa-list-check"></i> My Assigned Tasks
					</div>
					<div class="header-subtitle">Manage, track, and update your active work assignments in real time</div>
				</div>
				<a href="employeeDashboardServlet" class="back-dash-link">
					<i class="fa-solid fa-house"></i> Dashboard
				</a>
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
					<p>Total Assigned</p>
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

		<!-- Control Toolbar -->
		<div class="toolbar-container">
			<div class="search-box">
				<i class="fa-solid fa-magnifying-glass"></i>
				<input type="text" id="searchInput" placeholder="Search tasks by title, ID, or assigner..." onkeyup="applyTaskFilters()">
			</div>

			<div class="filter-group">
				<button class="filter-btn active" onclick="filterByStatus('ALL', this)">All</button>
				<button class="filter-btn" onclick="filterByStatus('PENDING', this)">Pending</button>
				<button class="filter-btn" onclick="filterByStatus('IN_PROGRESS', this)">In Progress</button>
				<button class="filter-btn" onclick="filterByStatus('COMPLETED', this)">Completed</button>
			</div>

			<div class="view-toggle">
				<button class="toggle-btn active" id="btnGridView" onclick="switchView('grid')" title="Card View">
					<i class="fa-solid fa-grip"></i>
				</button>
				<button class="toggle-btn" id="btnTableView" onclick="switchView('table')" title="Table View">
					<i class="fa-solid fa-table-list"></i>
				</button>
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
			%>

			<div class="task-card" 
				 data-title="<%= task.getTaskName() != null ? task.getTaskName().toLowerCase() : "" %>"
				 data-id="<%= task.getTaskId() != null ? task.getTaskId().toLowerCase() : "" %>"
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
					<div class="task-meta-details">
						<div class="meta-item">
							<i class="fa-solid fa-user-gear"></i> Assigned By:
							<span><%= task.getAssignedBy() != null ? task.getAssignedBy() : "Manager" %></span>
						</div>
						<div class="meta-item">
							<i class="fa-solid fa-calendar-day"></i> Assigned Date:
							<span><%= task.getAssignedDate() %></span>
						</div>
						<div class="meta-item <%= isOverdue ? "overdue" : "" %>">
							<i class="fa-solid fa-calendar-check"></i> Due Date:
							<span>
								<%= task.getDueDate() %>
								<% if (isOverdue) { %>
									<i class="fa-solid fa-circle-exclamation" title="Overdue"></i>
								<% } %>
							</span>
						</div>
						<% if (task.getCompletionDate() != null) { %>
							<div class="meta-item">
								<i class="fa-solid fa-circle-check" style="color:#16a34a;"></i> Completed On:
								<span><%= task.getCompletionDate() %></span>
							</div>
						<% } %>
					</div>

					<div class="card-actions">
						<div class="status-select-wrap">
							<form action="updateTaskStatus" method="post" style="margin:0;">
								<input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
								<input type="hidden" name="redirect" value="myTasks">
								<select name="status" onchange="this.form.submit()">
									<option value="PENDING" <%= "PENDING".equals(statusStr) ? "selected" : "" %>>Pending</option>
									<option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusStr) ? "selected" : "" %>>In Progress</option>
									<option value="COMPLETED" <%= "COMPLETED".equals(statusStr) ? "selected" : "" %>>Completed</option>
								</select>
							</form>
						</div>

						<% if (!"COMPLETED".equalsIgnoreCase(statusStr)) { %>
							<a class="btn-complete-action" href="updateTaskStatus?taskId=<%= task.getTaskId() %>&status=COMPLETED&redirect=myTasks">
								<i class="fa-solid fa-check"></i> Complete
							</a>
						<% } else { %>
							<span class="btn-done-disabled">
								<i class="fa-solid fa-circle-check"></i> Done
							</span>
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
					<i class="fa-solid fa-clipboard-check"></i>
				</div>
				<h4>No Assigned Tasks Found</h4>
				<p>You have zero active or pending task assignments at the moment.</p>
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
						<th>Assigned By</th>
						<th>Priority</th>
						<th>Status</th>
						<th>Assigned Date</th>
						<th>Due Date</th>
						<th>Completion Date</th>
						<th>Status Action</th>
					</tr>
				</thead>
				<tbody id="tableBody">
					<%
					if (taskList != null && !taskList.isEmpty()) {
						for (Task task : taskList) {
							String statusStr = task.getStatus() != null ? task.getStatus().name() : "PENDING";
							String priorityStr = task.getPriority() != null ? task.getPriority().name() : "MEDIUM";
					%>
					<tr class="table-task-row"
						data-title="<%= task.getTaskName() != null ? task.getTaskName().toLowerCase() : "" %>"
						data-id="<%= task.getTaskId() != null ? task.getTaskId().toLowerCase() : "" %>"
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
						<td><%= task.getAssignedBy() != null ? task.getAssignedBy() : "Manager" %></td>
						<td><span class="badge-priority p-<%= priorityStr %>"><%= priorityStr %></span></td>
						<td>
							<span class="badge-status st-<%= statusStr %>">
								<span class="dot-indicator"></span>
								<%= statusStr.replace("_", " ") %>
							</span>
						</td>
						<td><%= task.getAssignedDate() %></td>
						<td><%= task.getDueDate() %></td>
						<td><%= task.getCompletionDate() != null ? task.getCompletionDate() : "-" %></td>
						<td>
							<div style="display:flex; align-items:center; gap:8px;">
								<form action="updateTaskStatus" method="post" style="margin:0;">
									<input type="hidden" name="taskId" value="<%= task.getTaskId() %>">
									<input type="hidden" name="redirect" value="myTasks">
									<select name="status" style="padding:6px 10px; border-radius:6px; border:1px solid var(--border-color);" onchange="this.form.submit()">
										<option value="PENDING" <%= "PENDING".equals(statusStr) ? "selected" : "" %>>Pending</option>
										<option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusStr) ? "selected" : "" %>>In Progress</option>
										<option value="COMPLETED" <%= "COMPLETED".equals(statusStr) ? "selected" : "" %>>Completed</option>
									</select>
								</form>

								<% if (!"COMPLETED".equalsIgnoreCase(statusStr)) { %>
									<a class="btn-complete-action" style="padding:6px 10px; font-size:12px;" href="updateTaskStatus?taskId=<%= task.getTaskId() %>&status=COMPLETED&redirect=myTasks">
										<i class="fa-solid fa-check"></i>
									</a>
								<% } %>
							</div>
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
let currentStatusFilter = 'ALL';

function filterByStatus(status, btnElement) {
	currentStatusFilter = status;
	
	// Toggle button active states
	document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
	if (btnElement) btnElement.classList.add('active');
	
	applyTaskFilters();
}

function applyTaskFilters() {
	const query = document.getElementById('searchInput').value.toLowerCase().trim();
	
	// Filter Card View
	const cards = document.querySelectorAll('.task-card');
	let visibleCardCount = 0;
	
	cards.forEach(card => {
		const title = card.getAttribute('data-title') || '';
		const id = card.getAttribute('data-id') || '';
		const assigner = card.getAttribute('data-assigner') || '';
		const status = card.getAttribute('data-status') || '';
		
		const matchesQuery = title.includes(query) || id.includes(query) || assigner.includes(query);
		const matchesStatus = (currentStatusFilter === 'ALL') || (status === currentStatusFilter);
		
		if (matchesQuery && matchesStatus) {
			card.style.display = 'flex';
			visibleCardCount++;
		} else {
			card.style.display = 'none';
		}
	});
	
	// Filter Table Rows View
	const rows = document.querySelectorAll('.table-task-row');
	rows.forEach(row => {
		const title = row.getAttribute('data-title') || '';
		const id = row.getAttribute('data-id') || '';
		const assigner = row.getAttribute('data-assigner') || '';
		const status = row.getAttribute('data-status') || '';
		
		const matchesQuery = title.includes(query) || id.includes(query) || assigner.includes(query);
		const matchesStatus = (currentStatusFilter === 'ALL') || (status === currentStatusFilter);
		
		if (matchesQuery && matchesStatus) {
			row.style.display = '';
		} else {
			row.style.display = 'none';
		}
	});
}

function switchView(viewMode) {
	const gridView = document.getElementById('tasksGridView');
	const tableView = document.getElementById('tasksTableView');
	const btnGrid = document.getElementById('btnGridView');
	const btnTable = document.getElementById('btnTableView');
	
	if (viewMode === 'grid') {
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
