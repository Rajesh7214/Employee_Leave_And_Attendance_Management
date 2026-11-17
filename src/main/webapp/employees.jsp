<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.rajesh.elams.model.Employee"%>

<%
String role = (String) session.getAttribute("role");
com.rajesh.elams.model.User loggedUser = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
if ((role == null || role.isBlank()) && loggedUser != null) {
	role = loggedUser.getRole();
}
if ((role == null || role.isBlank()) && session.getAttribute("employee") != null) {
	Employee sessionEmp = (Employee) session.getAttribute("employee");
	if (sessionEmp.getDesignation() != null && sessionEmp.getDesignation().toLowerCase().contains("manager")) {
		role = "manager";
	}
}
String backDashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";

List<Employee> employees = (List<Employee>) request.getAttribute("employees");
if (employees == null) {
	employees = (List<Employee>) request.getAttribute("employeeList");
}

int totalEmployees = employees != null ? employees.size() : 0;

Set<String> departments = new TreeSet<>();
int managerCount = 0;
if (employees != null) {
	for (Employee emp : employees) {
		if (emp.getDepartment() != null && !emp.getDepartment().isBlank()) {
			departments.add(emp.getDepartment().trim());
		}
		if (emp.getDesignation() != null && (emp.getDesignation().toLowerCase().contains("manager") || emp.getDesignation().toLowerCase().contains("admin") || emp.getDesignation().toLowerCase().contains("lead"))) {
			managerCount++;
		}
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Employee Directory | ELAMS</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background-color: #f0fdf4;
	background: linear-gradient(180deg, #f0f9ff 0%, #f4f6fb 100%);
	color: #0f172a;
	min-height: 100vh;
}

/* ===== OCEAN TEAL & SKY BLUE HEADER NAVBAR ===== */
.navbar {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	padding: 16px 35px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 20px rgba(13, 148, 136, 0.28);
}

.navbar-brand {
	display: flex;
	align-items: center;
	gap: 12px;
	text-decoration: none;
	color: white;
}

.navbar-brand i {
	font-size: 22px;
	background: rgba(255, 255, 255, 0.22);
	width: 42px;
	height: 42px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.navbar-title {
	font-size: 22px;
	font-weight: 800;
	letter-spacing: -0.5px;
}

/* ===== MAIN CONTAINER ===== */
.container {
	max-width: 1400px;
	margin: 30px auto;
	padding: 0 24px;
}

/* Page Header */
.page-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 20px;
	margin-bottom: 25px;
}

.page-title-group h1 {
	font-size: 28px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 12px;
}

.page-title-group p {
	font-size: 14px;
	color: #64748b;
	margin-top: 4px;
}

.back-btn {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	text-decoration: none;
	color: #0284c7;
	background: #e0f2fe;
	border: 1px solid #bae6fd;
	padding: 10px 22px;
	border-radius: 30px;
	font-weight: 700;
	font-size: 14px;
	transition: all 0.25s ease;
	box-shadow: 0 2px 8px rgba(2, 132, 199, 0.1);
}

.back-btn:hover {
	background: #0284c7;
	color: white;
	transform: translateY(-2px);
	box-shadow: 0 4px 14px rgba(2, 132, 199, 0.25);
}

/* ===== STATS SECTION ===== */
.stats-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
	gap: 20px;
	margin-bottom: 30px;
}

.stat-card {
	background: #ffffff;
	border-radius: 18px;
	padding: 22px 26px;
	display: flex;
	align-items: center;
	gap: 20px;
	box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.stat-card:hover {
	transform: translateY(-4px);
	box-shadow: 0 10px 25px rgba(2, 132, 199, 0.1);
}

.stat-icon {
	width: 56px;
	height: 56px;
	border-radius: 16px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24px;
	flex-shrink: 0;
	color: white;
}

.stat-sky { background: linear-gradient(135deg, #38bdf8 0%, #0284c7 100%); box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3); }
.stat-teal { background: linear-gradient(135deg, #2dd4bf 0%, #0d9488 100%); box-shadow: 0 4px 12px rgba(13, 148, 136, 0.3); }
.stat-emerald { background: linear-gradient(135deg, #34d399 0%, #059669 100%); box-shadow: 0 4px 12px rgba(5, 150, 105, 0.3); }
.stat-indigo { background: linear-gradient(135deg, #818cf8 0%, #4f46e5 100%); box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3); }

.stat-info .value {
	font-size: 30px;
	font-weight: 800;
	color: #0f172a;
	line-height: 1.1;
}

.stat-info .label {
	font-size: 12px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-top: 4px;
}

/* ===== TOOLBAR & SEARCH ===== */
.toolbar-card {
	background: #ffffff;
	border-radius: 18px;
	padding: 20px 26px;
	box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	margin-bottom: 28px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 18px;
}

.search-filter-group {
	display: flex;
	align-items: center;
	gap: 14px;
	flex: 1;
	min-width: 300px;
}

.search-input-wrapper {
	position: relative;
	flex: 1;
}

.search-input-wrapper i {
	position: absolute;
	left: 16px;
	top: 50%;
	transform: translateY(-50%);
	color: #0284c7;
	font-size: 16px;
}

.search-input-wrapper input {
	width: 100%;
	padding: 12px 18px 12px 44px;
	border: 1px solid #cbd5e1;
	border-radius: 14px;
	font-size: 14px;
	outline: none;
	transition: all 0.25s;
	background: #f8fafc;
	color: #0f172a;
}

.search-input-wrapper input:focus {
	background: #ffffff;
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.14);
}

.dept-select {
	padding: 12px 18px;
	border: 1px solid #cbd5e1;
	border-radius: 14px;
	font-size: 14px;
	font-weight: 700;
	color: #334155;
	background: #f8fafc;
	outline: none;
	cursor: pointer;
	transition: all 0.2s;
}

.dept-select:focus {
	border-color: #0284c7;
	background: #ffffff;
}

.action-controls {
	display: flex;
	align-items: center;
	gap: 14px;
}

.btn-add {
	background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
	color: white;
	padding: 12px 24px;
	border-radius: 14px;
	text-decoration: none;
	font-weight: 700;
	font-size: 14px;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	box-shadow: 0 4px 14px rgba(13, 148, 136, 0.3);
	transition: all 0.25s ease;
}

.btn-add:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(13, 148, 136, 0.4);
}

.view-toggle {
	display: flex;
	background: #f1f5f9;
	padding: 4px;
	border-radius: 12px;
	border: 1px solid #e2e8f0;
}

.toggle-btn {
	padding: 8px 16px;
	border: none;
	background: transparent;
	color: #64748b;
	font-weight: 700;
	font-size: 13px;
	border-radius: 9px;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s;
}

.toggle-btn.active {
	background: #ffffff;
	color: #0284c7;
	box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* ===== GRID CARDS VIEW ===== */
.directory-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
	gap: 24px;
}

.emp-card {
	background: #ffffff;
	border-radius: 22px;
	padding: 26px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	transition: all 0.3s ease;
	position: relative;
	overflow: hidden;
}

.emp-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 5px;
	background: linear-gradient(90deg, #38bdf8 0%, #0d9488 100%);
}

.emp-card:hover {
	transform: translateY(-6px);
	box-shadow: 0 16px 32px rgba(2, 132, 199, 0.14), 0 0 0 1px rgba(2, 132, 199, 0.3);
}

.emp-card-header {
	display: flex;
	align-items: flex-start;
	gap: 16px;
	margin-bottom: 20px;
}

.emp-avatar-box {
	position: relative;
	flex-shrink: 0;
}

.emp-avatar {
	width: 62px;
	height: 62px;
	border-radius: 18px;
	object-fit: cover;
	display: block;
	box-shadow: 0 6px 16px rgba(2, 132, 199, 0.22);
}

.online-indicator {
	position: absolute;
	bottom: -2px;
	right: -2px;
	width: 14px;
	height: 14px;
	background: #10b981;
	border: 3px solid #ffffff;
	border-radius: 50%;
}

.emp-main-info {
	flex: 1;
	min-width: 0;
}

.emp-id-tag {
	font-size: 11px;
	font-weight: 800;
	color: #0284c7;
	background: #e0f2fe;
	padding: 3px 9px;
	border-radius: 8px;
	display: inline-block;
	margin-bottom: 6px;
	letter-spacing: 0.3px;
}

.emp-name {
	font-size: 17px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 3px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.emp-designation {
	font-size: 13px;
	font-weight: 600;
	color: #0d9488;
}

.emp-details-list {
	display: flex;
	flex-direction: column;
	gap: 11px;
	margin-bottom: 22px;
	background: #f8fafc;
	padding: 16px;
	border-radius: 14px;
	border: 1px solid #f1f5f9;
}

.emp-detail-item {
	display: flex;
	align-items: center;
	gap: 12px;
	font-size: 13px;
	color: #475569;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.emp-detail-item i {
	width: 18px;
	color: #0284c7;
	flex-shrink: 0;
	font-size: 14px;
}

.emp-detail-item a {
	color: #334155;
	text-decoration: none;
	font-weight: 600;
	transition: color 0.2s;
}

.emp-detail-item a:hover {
	color: #0284c7;
	text-decoration: underline;
}

.dept-badge {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	background: #e0f2fe;
	color: #0369a1;
	font-size: 11.5px;
	font-weight: 700;
	padding: 4px 12px;
	border-radius: 20px;
}

.desig-badge {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	background: #ccfbf1;
	color: #0f766e;
	font-size: 11.5px;
	font-weight: 700;
	padding: 4px 12px;
	border-radius: 20px;
}

.emp-card-footer {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 10px;
	padding-top: 16px;
	border-top: 1px dashed #e2e8f0;
}

.card-btn {
	flex: 1;
	padding: 9px 14px;
	border-radius: 12px;
	font-size: 12.5px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 6px;
	transition: all 0.2s ease;
	border: none;
	cursor: pointer;
}

.btn-card-edit { background: #e0f2fe; color: #0284c7; }
.btn-card-edit:hover { background: #0284c7; color: white; }

.btn-card-task { background: #fef3c7; color: #d97706; }
.btn-card-task:hover { background: #d97706; color: white; }

.btn-card-del { background: #fee2e2; color: #dc2626; }
.btn-card-del:hover { background: #dc2626; color: white; }

/* ===== TABLE VIEW ===== */
.directory-table-container {
	background: #ffffff;
	border-radius: 22px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	overflow: hidden;
	display: none;
}

.directory-table {
	width: 100%;
	border-collapse: collapse;
	text-align: left;
}

.directory-table th {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	padding: 16px 22px;
	font-size: 12.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.directory-table td {
	padding: 16px 22px;
	border-bottom: 1px solid #f1f5f9;
	font-size: 14px;
	color: #1e293b;
	vertical-align: middle;
}

.directory-table tr:hover {
	background: #f0f9ff;
}

/* Empty Search Results */
.empty-state {
	background: #ffffff;
	border-radius: 22px;
	padding: 60px 20px;
	text-align: center;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
	grid-column: 1 / -1;
}

.empty-state i {
	font-size: 48px;
	color: #cbd5e1;
	margin-bottom: 14px;
}

.empty-state h3 {
	font-size: 19px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 6px;
}

.empty-state p {
	font-size: 14px;
	color: #64748b;
}

@media (max-width: 768px) {
	.navbar { padding: 14px 20px; }
	.container { padding: 0 16px; margin: 20px auto; }
	.toolbar-card { flex-direction: column; align-items: stretch; }
	.search-filter-group { flex-direction: column; }
	.action-controls { justify-content: space-between; }
}
</style>
</head>

<body>

	<!-- Top Ocean Teal & Sky Blue Gradient Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-users"></i>
			<span class="navbar-title">Employee Directory</span>
		</a>
		<div style="display: flex; align-items: center; gap: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>
	</div>

	<!-- Main Content Container -->
	<div class="container">

		<!-- Page Header -->
		<div class="page-header">
			<div class="page-title-group">
				<h1>👥 Employee Directory</h1>
				<p>Browse team members, contact information, and manage records</p>
			</div>
			<a href="<%=backDashUrl%>" class="back-btn">
				<i class="fa-solid fa-house"></i> Back to Dashboard
			</a>
		</div>

		<!-- Summary Statistics Cards -->
		<div class="stats-grid">
			<div class="stat-card">
				<div class="stat-icon stat-sky">
					<i class="fa-solid fa-users"></i>
				</div>
				<div class="stat-info">
					<div class="value"><%=totalEmployees%></div>
					<div class="label">Total Employees</div>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-icon stat-teal">
					<i class="fa-solid fa-building"></i>
				</div>
				<div class="stat-info">
					<div class="value"><%=departments.size()%></div>
					<div class="label">Active Departments</div>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-icon stat-emerald">
					<i class="fa-solid fa-user-shield"></i>
				</div>
				<div class="stat-info">
					<div class="value"><%=managerCount%></div>
					<div class="label">Managers & Leaders</div>
				</div>
			</div>

			<div class="stat-card">
				<div class="stat-icon stat-indigo">
					<i class="fa-solid fa-id-card"></i>
				</div>
				<div class="stat-info">
					<div class="value"><%=totalEmployees - managerCount%></div>
					<div class="label">Staff Members</div>
				</div>
			</div>
		</div>

		<!-- Toolbar with Real-Time Search, Dept Filter & View Switcher -->
		<div class="toolbar-card">
			<div class="search-filter-group">
				<div class="search-input-wrapper">
					<i class="fa-solid fa-magnifying-glass"></i>
					<input type="text" id="empSearchInput" placeholder="Search by name, email, department, or ID..." onkeyup="filterEmployees()" />
				</div>

				<select id="deptFilter" class="dept-select" onchange="filterEmployees()">
					<option value="ALL">All Departments</option>
					<% for (String dept : departments) { %>
						<option value="<%=dept%>"><%=dept%></option>
					<% } %>
				</select>
			</div>

			<div class="action-controls">
				<% if ("admin".equalsIgnoreCase(role)) { %>
				<a href="addEmployee.jsp" class="btn-add">
					<i class="fa-solid fa-user-plus"></i> Add Employee
				</a>
				<% } %>

				<div class="view-toggle">
					<button type="button" class="toggle-btn active" id="btnGridView" onclick="switchView('grid')">
						<i class="fa-solid fa-border-all"></i> Cards
					</button>
					<button type="button" class="toggle-btn" id="btnTableView" onclick="switchView('table')">
						<i class="fa-solid fa-list"></i> Table
					</button>
				</div>
			</div>
		</div>

		<!-- Grid Cards View Container -->
		<div class="directory-grid" id="gridContainer">
			<%
			if (employees != null && !employees.isEmpty()) {
				for (Employee emp : employees) {
					String photo = (emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank()) 
							? emp.getProfile_photo() 
							: "https://ui-avatars.com/api/?name=" + (emp.getEmployee_name() != null ? emp.getEmployee_name() : "Emp") + "&background=0284c7&color=fff&bold=true";
					String deptStr = (emp.getDepartment() != null && !emp.getDepartment().isBlank()) ? emp.getDepartment() : "General";
					String desigStr = (emp.getDesignation() != null && !emp.getDesignation().isBlank()) ? emp.getDesignation() : "Employee";
			%>
			<div class="emp-card" data-name="<%=emp.getEmployee_name() != null ? emp.getEmployee_name().toLowerCase() : ""%>" data-email="<%=emp.getEmail() != null ? emp.getEmail().toLowerCase() : ""%>" data-dept="<%=deptStr.toLowerCase()%>" data-desig="<%=desigStr.toLowerCase()%>" data-id="<%=emp.getEmployee_id()%>">
				<div>
					<div class="emp-card-header">
						<div class="emp-avatar-box">
							<img src="<%=photo%>" class="emp-avatar" alt="<%=emp.getEmployee_name()%> Profile" />
							<span class="online-indicator" title="Active Employee Account"></span>
						</div>
						<div class="emp-main-info">
							<span class="emp-id-tag">ID #<%=emp.getEmployee_id()%></span>
							<h3 class="emp-name"><%=emp.getEmployee_name()%></h3>
							<div class="emp-designation"><%=desigStr%></div>
						</div>
					</div>

					<div class="emp-details-list">
						<div class="emp-detail-item">
							<i class="fa-solid fa-building"></i>
							<span class="dept-badge"><%=deptStr%></span>
						</div>
						<div class="emp-detail-item">
							<i class="fa-regular fa-envelope"></i>
							<a href="mailto:<%=emp.getEmail()%>" title="Send Email"><%=emp.getEmail()%></a>
						</div>
						<div class="emp-detail-item">
							<i class="fa-solid fa-phone"></i>
							<a href="tel:<%=emp.getPhone()%>" title="Call Phone">+91 <%=emp.getPhone()%></a>
						</div>
					</div>
				</div>

				<div class="emp-card-footer">
					<button type="button" onclick="openQuickEditModal(<%=emp.getEmployee_id()%>)" class="card-btn" style="background: #e0e7ff; color: #4338ca; border: none; cursor: pointer;" title="Quick Edit Modal">
						<i class="fa-solid fa-bolt"></i> Quick Edit
					</button>
					<a href="editEmployee?id=<%=emp.getEmployee_id()%>" class="card-btn btn-card-edit" title="Edit Profile">
						<i class="fa-solid fa-pen-to-square"></i> Full Edit
					</a>
					<a href="createTask?employeeId=<%=emp.getEmployee_id()%>" class="card-btn btn-card-task" title="Assign Task">
						<i class="fa-solid fa-list-check"></i> Task
					</a>
					<% if ("admin".equalsIgnoreCase(role)) { %>
					<button type="button" onclick="confirmDelete(<%=emp.getEmployee_id()%>, '<%=emp.getEmployee_name()%>')" class="card-btn btn-card-del" title="Remove Employee">
						<i class="fa-solid fa-trash"></i> Delete
					</button>
					<% } %>
				</div>
			</div>
			<%
				}
			}
			%>
		</div>

		<!-- Table View Container -->
		<div class="directory-table-container" id="tableContainer">
			<table class="directory-table">
				<thead>
					<tr>
						<th>Employee</th>
						<th>ID</th>
						<th>Department</th>
						<th>Designation</th>
						<th>Email</th>
						<th>Phone</th>
						<th style="text-align: right;">Actions</th>
					</tr>
				</thead>
				<tbody>
					<%
					if (employees != null && !employees.isEmpty()) {
						for (Employee emp : employees) {
							String photo = (emp.getProfile_photo() != null && !emp.getProfile_photo().isBlank()) 
									? emp.getProfile_photo() 
									: "https://ui-avatars.com/api/?name=" + (emp.getEmployee_name() != null ? emp.getEmployee_name() : "Emp") + "&background=0284c7&color=fff&bold=true";
							String deptStr = (emp.getDepartment() != null && !emp.getDepartment().isBlank()) ? emp.getDepartment() : "General";
							String desigStr = (emp.getDesignation() != null && !emp.getDesignation().isBlank()) ? emp.getDesignation() : "Employee";
					%>
					<tr class="table-row" data-name="<%=emp.getEmployee_name() != null ? emp.getEmployee_name().toLowerCase() : ""%>" data-email="<%=emp.getEmail() != null ? emp.getEmail().toLowerCase() : ""%>" data-dept="<%=deptStr.toLowerCase()%>" data-desig="<%=desigStr.toLowerCase()%>" data-id="<%=emp.getEmployee_id()%>">
						<td>
							<div style="display: flex; align-items: center; gap: 12px;">
								<img src="<%=photo%>" style="width: 40px; height: 40px; border-radius: 12px; object-fit: cover;" alt="Avatar" />
								<div>
									<div style="font-weight: 800; color: #0f172a;"><%=emp.getEmployee_name()%></div>
								</div>
							</div>
						</td>
						<td><span class="emp-id-tag">#<%=emp.getEmployee_id()%></span></td>
						<td><span class="dept-badge"><%=deptStr%></span></td>
						<td><span class="desig-badge"><%=desigStr%></span></td>
						<td><a href="mailto:<%=emp.getEmail()%>" style="color: #0284c7; text-decoration: none; font-weight: 600;"><%=emp.getEmail()%></a></td>
						<td><a href="tel:<%=emp.getPhone()%>" style="color: #475569; text-decoration: none; font-weight: 600;">+91 <%=emp.getPhone()%></a></td>
						<td style="text-align: right;">
							<div style="display: inline-flex; gap: 6px;">
								<button type="button" onclick="openQuickEditModal(<%=emp.getEmployee_id()%>)" class="card-btn" style="background: #e0e7ff; color: #4338ca; border: none; cursor: pointer; flex: none; padding: 7px 12px;" title="Quick Edit Modal">
									<i class="fa-solid fa-bolt"></i>
								</button>
								<a href="editEmployee?id=<%=emp.getEmployee_id()%>" class="card-btn btn-card-edit" style="flex: none; padding: 7px 12px;" title="Edit Profile">
									<i class="fa-solid fa-pen-to-square"></i>
								</a>
								<a href="createTask?employeeId=<%=emp.getEmployee_id()%>" class="card-btn btn-card-task" style="flex: none; padding: 7px 12px;" title="Assign Task">
									<i class="fa-solid fa-list-check"></i>
								</a>
								<% if ("admin".equalsIgnoreCase(role)) { %>
								<button type="button" onclick="confirmDelete(<%=emp.getEmployee_id()%>, '<%=emp.getEmployee_name()%>')" class="card-btn btn-card-del" style="flex: none; padding: 7px 12px;" title="Delete Employee">
									<i class="fa-solid fa-trash"></i>
								</button>
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

		<!-- Empty Search Result Container -->
		<div class="empty-state" id="emptySearchState" style="display: none;">
			<i class="fa-solid fa-user-slash"></i>
			<h3>No Employees Found</h3>
			<p>No employee records matched your search query or department filter.</p>
		</div>

	</div>

	<!-- Interactive Javascript Logic -->
	<script>
	function filterEmployees() {
		var query = document.getElementById("empSearchInput").value.toLowerCase().trim();
		var deptFilter = document.getElementById("deptFilter").value.toLowerCase().trim();

		var cards = document.querySelectorAll("#gridContainer .emp-card");
		var rows = document.querySelectorAll("#tableContainer .table-row");
		var visibleCount = 0;

		cards.forEach(function(card) {
			var name = card.getAttribute("data-name") || "";
			var email = card.getAttribute("data-email") || "";
			var dept = card.getAttribute("data-dept") || "";
			var desig = card.getAttribute("data-desig") || "";
			var id = card.getAttribute("data-id") || "";

			var matchesQuery = !query || name.indexOf(query) !== -1 || email.indexOf(query) !== -1 || dept.indexOf(query) !== -1 || desig.indexOf(query) !== -1 || id.indexOf(query) !== -1;
			var matchesDept = (deptFilter === "all") || (dept === deptFilter);

			if (matchesQuery && matchesDept) {
				card.style.display = "flex";
				visibleCount++;
			} else {
				card.style.display = "none";
			}
		});

		rows.forEach(function(row) {
			var name = row.getAttribute("data-name") || "";
			var email = row.getAttribute("data-email") || "";
			var dept = row.getAttribute("data-dept") || "";
			var desig = row.getAttribute("data-desig") || "";
			var id = row.getAttribute("data-id") || "";

			var matchesQuery = !query || name.indexOf(query) !== -1 || email.indexOf(query) !== -1 || dept.indexOf(query) !== -1 || desig.indexOf(query) !== -1 || id.indexOf(query) !== -1;
			var matchesDept = (deptFilter === "all") || (dept === deptFilter);

			if (matchesQuery && matchesDept) {
				row.style.display = "";
			} else {
				row.style.display = "none";
			}
		});

		var emptyState = document.getElementById("emptySearchState");
		if (emptyState) {
			emptyState.style.display = visibleCount === 0 ? "block" : "none";
		}
	}

	function switchView(viewType) {
		var grid = document.getElementById("gridContainer");
		var table = document.getElementById("tableContainer");
		var btnGrid = document.getElementById("btnGridView");
		var btnTable = document.getElementById("btnTableView");

		if (viewType === 'grid') {
			grid.style.display = "grid";
			table.style.display = "none";
			btnGrid.classList.add("active");
			btnTable.classList.remove("active");
		} else {
			grid.style.display = "none";
			table.style.display = "block";
			btnTable.classList.add("active");
			btnGrid.classList.remove("active");
		}
	}

	function confirmDelete(id, name) {
		if (confirm("Are you sure you want to remove " + name + " (ID: #" + id + ") from the system?\n\nThis action cannot be undone.")) {
			window.location.href = "deleteEmployee?id=" + id;
		}
	}

	function openQuickEditModal(empId) {
		var modal = document.getElementById("quickEditModal");
		modal.style.display = "flex";

		fetch("${pageContext.request.contextPath}/api/employee/get?id=" + empId)
			.then(function(res) { return res.json(); })
			.then(function(data) {
				if (data.error) {
					alert(data.error);
					closeQuickEditModal();
					return;
				}
				document.getElementById("qe_id").value = data.employee_id;
				document.getElementById("qe_name").value = data.employee_name || "";
				document.getElementById("qe_email").value = data.email || "";
				document.getElementById("qe_phone").value = data.phone || "";
				document.getElementById("qe_department").value = data.department || "IT";
				document.getElementById("qe_designation").value = data.designation || "Developer";
				document.getElementById("qe_userRole").value = data.account_role || "Employee";
			})
			.catch(function(err) {
				alert("Error loading employee details: " + err.message);
				closeQuickEditModal();
			});
	}

	function closeQuickEditModal() {
		document.getElementById("quickEditModal").style.display = "none";
	}

	function submitQuickEditForm(e) {
		e.preventDefault();
		var formData = new URLSearchParams(new FormData(document.getElementById("quickEditForm")));

		fetch("${pageContext.request.contextPath}/api/employee/update", {
			method: "POST",
			headers: { "Content-Type": "application/x-www-form-urlencoded" },
			body: formData.toString()
		})
		.then(function(res) { return res.json(); })
		.then(function(data) {
			if (data.success) {
				alert("Employee details updated successfully!");
				window.location.reload();
			} else {
				alert("Error: " + (data.error || "Update failed"));
			}
		})
		.catch(function(err) {
			alert("Server communication error: " + err.message);
		});
	}
	</script>

	<!-- Quick Edit Modal Drawer -->
	<div id="quickEditModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(15,23,42,0.6); backdrop-filter:blur(4px); z-index:999; align-items:center; justify-content:center;">
		<div style="background:#fff; border-radius:24px; width:90%; max-width:540px; padding:32px; box-shadow:0 20px 40px rgba(0,0,0,0.2);">
			<div style="display:flex; align-items:center; justify-content:space-between; border-bottom:1px solid #e2e8f0; padding-bottom:16px; margin-bottom:20px;">
				<h3 style="font-size:18px; font-weight:800; color:#0f172a;"><i class="fa-solid fa-bolt" style="color:#4f46e5;"></i> Quick Edit Employee</h3>
				<button type="button" style="background:none; border:none; font-size:22px; color:#94a3b8; cursor:pointer;" onclick="closeQuickEditModal()">&times;</button>
			</div>
			<form id="quickEditForm" onsubmit="submitQuickEditForm(event)">
				<input type="hidden" id="qe_id" name="id" />
				<div style="margin-bottom:14px;">
					<label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">Full Name</label>
					<input type="text" id="qe_name" name="name" required style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; outline:none; font-size:13.5px;" />
				</div>
				<div style="margin-bottom:14px;">
					<label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">Email Address</label>
					<input type="email" id="qe_email" name="email" required style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; outline:none; font-size:13.5px;" />
				</div>
				<div style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:14px;">
					<div>
						<label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">Phone</label>
						<input type="tel" id="qe_phone" name="phone" required style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; outline:none; font-size:13.5px;" />
					</div>
					<div>
						<label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">System Role</label>
						<select id="qe_userRole" name="userRole" style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; outline:none; font-size:13.5px;">
							<option value="Employee">Employee</option>
							<option value="Manager">Manager</option>
							<option value="HR">HR</option>
							<option value="Admin">Admin</option>
						</select>
					</div>
				</div>
				<div style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:20px;">
					<div>
						<label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">Department</label>
						<select id="qe_department" name="department" required style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; outline:none; font-size:13.5px;">
							<option value="IT">IT</option>
							<option value="HR">HR</option>
							<option value="Finance">Finance</option>
							<option value="Sales">Sales</option>
							<option value="Marketing">Marketing</option>
							<option value="Operations">Operations</option>
							<option value="Management">Management</option>
							<option value="Other">Other</option>
						</select>
					</div>
					<div>
						<label style="display:block; font-size:12px; font-weight:700; color:#475569; margin-bottom:6px;">Designation</label>
						<select id="qe_designation" name="designation" required style="width:100%; padding:10px 14px; border-radius:10px; border:1px solid #cbd5e1; outline:none; font-size:13.5px;">
							<option value="Manager">Manager</option>
							<option value="Senior Developer">Senior Developer</option>
							<option value="Developer">Developer</option>
							<option value="Junior Developer">Junior Developer</option>
							<option value="Analyst">Analyst</option>
							<option value="Executive">Executive</option>
							<option value="Intern">Intern</option>
							<option value="Other">Other</option>
						</select>
					</div>
				</div>
				<div style="display:flex; justify-content:flex-end; gap:12px;">
					<button type="button" onclick="closeQuickEditModal()" style="padding:10px 20px; border-radius:10px; border:1px solid #cbd5e1; background:#f1f5f9; font-weight:700; cursor:pointer;">Cancel</button>
					<button type="submit" style="padding:10px 22px; border-radius:10px; border:none; background:#4f46e5; color:#fff; font-weight:700; cursor:pointer;">Save Changes</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>