<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.rajesh.elams.model.Employee"%>

<%
String role = (String) session.getAttribute("role");
if (role == null || (!"admin".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role))) {
	response.sendRedirect("viewTasksServlet");
	return;
}
String backDashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "managerDashboard";

List<Employee> employeeList = (List<Employee>) request.getAttribute("employees");
if (employeeList == null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employeeList = empDao.getAllEmployees();
	} catch (Exception ignored) {}
}

String preselectedEmpId = request.getParameter("employeeId");

Set<String> departmentSet = new TreeSet<>();
if (employeeList != null) {
	for (Employee e : employeeList) {
		if (e.getDepartment() != null && !e.getDepartment().isBlank()) {
			departmentSet.add(e.getDepartment().trim());
		}
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Create &amp; Assign Task | ELAMS</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

:root {
	--bg-dark: #090d16;
	--card-glass: rgba(15, 23, 42, 0.75);
	--border-glass: rgba(255, 255, 255, 0.12);
	--neon-indigo: #6366f1;
	--neon-cyan: #38bdf8;
	--neon-emerald: #10b981;
	--neon-amber: #fbbf24;
	--neon-rose: #f43f5e;
	--text-light: #f8fafc;
	--text-muted: #94a3b8;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background-color: var(--bg-dark);
	background-image: 
		radial-gradient(at 15% 15%, rgba(99, 102, 241, 0.15) 0px, transparent 50%),
		radial-gradient(at 85% 85%, rgba(16, 185, 129, 0.12) 0px, transparent 50%),
		radial-gradient(at 50% 50%, rgba(56, 189, 248, 0.1) 0px, transparent 50%);
	background-attachment: fixed;
	color: var(--text-light);
	min-height: 100vh;
}

/* Header Navbar */
.navbar {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border-bottom: 1px solid var(--border-glass);
	color: white;
	padding: 16px 35px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	position: sticky;
	top: 0;
	z-index: 100;
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
	background: rgba(99, 102, 241, 0.2);
	border: 1px solid rgba(99, 102, 241, 0.4);
	color: var(--neon-indigo);
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
}

/* Page Layout */
.layout-wrapper {
	max-width: 900px;
	margin: 0 auto;
	padding: 35px 24px;
}

.page-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 25px;
}

.page-header h1 {
	font-size: 28px;
	font-weight: 800;
	color: #ffffff;
}

.back-btn {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	text-decoration: none;
	color: var(--text-light);
	background: rgba(255, 255, 255, 0.06);
	border: 1px solid var(--border-glass);
	padding: 10px 22px;
	border-radius: 14px;
	font-weight: 700;
	font-size: 14px;
	transition: all 0.25s;
}

.back-btn:hover {
	background: rgba(255, 255, 255, 0.12);
	border-color: rgba(255, 255, 255, 0.25);
	color: #ffffff;
}

/* Form Card */
.card {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border-radius: 24px;
	padding: 35px;
	border: 1px solid var(--border-glass);
	box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
	position: relative;
	overflow: hidden;
}

.card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 4px;
	background: linear-gradient(90deg, #6366f1 0%, #38bdf8 100%);
}

/* Assignment Mode Switcher */
.mode-label {
	font-size: 13.5px;
	font-weight: 700;
	color: var(--text-muted);
	margin-bottom: 10px;
	display: block;
}

.mode-grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 12px;
	margin-bottom: 26px;
}

.mode-option {
	border: 1px solid var(--border-glass);
	border-radius: 16px;
	padding: 14px;
	text-align: center;
	cursor: pointer;
	transition: all 0.25s;
	background: rgba(15, 23, 42, 0.6);
}

.mode-option:hover {
	border-color: var(--neon-indigo);
	background: rgba(99, 102, 241, 0.1);
}

.mode-option.active {
	border-color: var(--neon-indigo);
	background: rgba(99, 102, 241, 0.2);
	box-shadow: 0 0 20px rgba(99, 102, 241, 0.3);
}

.mode-option i {
	font-size: 20px;
	color: var(--neon-cyan);
	display: block;
	margin-bottom: 6px;
}

.mode-option span {
	font-size: 13px;
	font-weight: 800;
	color: #ffffff;
	display: block;
}

/* Form Groups */
.form-group {
	margin-bottom: 22px;
}

.form-group label {
	display: block;
	font-size: 13.5px;
	font-weight: 700;
	color: var(--text-muted);
	margin-bottom: 8px;
}

.form-group input[type="text"],
.form-group input[type="date"],
.form-group select,
.form-group textarea {
	width: 100%;
	padding: 13px 16px;
	border: 1px solid var(--border-glass);
	border-radius: 14px;
	font-size: 14.5px;
	color: #ffffff;
	background: rgba(15, 23, 42, 0.6);
	outline: none;
	transition: all 0.25s;
}

.form-group textarea {
	height: 100px;
	resize: vertical;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
	border-color: var(--neon-indigo);
	box-shadow: 0 0 20px rgba(99, 102, 241, 0.3);
}

/* Group Checkbox Grid */
.employee-checkbox-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
	gap: 12px;
	max-height: 240px;
	overflow-y: auto;
	padding: 14px;
	background: rgba(15, 23, 42, 0.6);
	border: 1px solid var(--border-glass);
	border-radius: 16px;
}

.emp-checkbox-card {
	display: flex;
	align-items: center;
	gap: 10px;
	background: rgba(255, 255, 255, 0.04);
	padding: 10px 14px;
	border-radius: 12px;
	border: 1px solid var(--border-glass);
	cursor: pointer;
	transition: all 0.2s;
}

.emp-checkbox-card:hover {
	border-color: var(--neon-indigo);
	background: rgba(99, 102, 241, 0.15);
}

.emp-checkbox-card input[type="checkbox"] {
	width: 18px;
	height: 18px;
	accent-color: var(--neon-indigo);
	cursor: pointer;
}

.emp-checkbox-info {
	display: flex;
	flex-direction: column;
}

.emp-checkbox-name {
	font-size: 13.5px;
	font-weight: 700;
	color: #ffffff;
}

.emp-checkbox-dept {
	font-size: 11.5px;
	color: var(--text-muted);
	font-weight: 600;
}

/* Priority Badges */
.priority-options {
	display: flex;
	gap: 12px;
}

.priority-pill {
	flex: 1;
	text-align: center;
	padding: 12px;
	border-radius: 14px;
	border: 2px solid rgba(255, 255, 255, 0.12);
	cursor: pointer;
	font-size: 13.5px;
	font-weight: 800;
	background: rgba(255, 255, 255, 0.04);
	color: var(--text-light);
	transition: all 0.2s;
}

.priority-pill.high.active { border-color: #ef4444; background: rgba(239, 68, 68, 0.18); color: #f87171; }
.priority-pill.medium.active { border-color: #f59e0b; background: rgba(245, 158, 11, 0.18); color: #fbbf24; }
.priority-pill.low.active { border-color: #10b981; background: rgba(16, 185, 129, 0.18); color: #34d399; }

/* Alert Messages */
.alert {
	padding: 14px 20px;
	border-radius: 14px;
	margin-bottom: 24px;
	font-size: 14px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 10px;
}

.alert-error { background: rgba(239, 68, 68, 0.2); color: #fca5a5; border: 1px solid rgba(239, 68, 68, 0.4); }

/* Submit Button */
.btn-submit {
	background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
	color: white;
	padding: 16px 32px;
	border-radius: 16px;
	border: none;
	font-size: 16px;
	font-weight: 800;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	box-shadow: 0 4px 16px rgba(99, 102, 241, 0.35);
	transition: all 0.25s;
	width: 100%;
	margin-top: 10px;
}

.btn-submit:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(99, 102, 241, 0.5);
}
</style>
</head>

<body>

	<!-- Top Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-list-check"></i>
			<span class="navbar-title">Create &amp; Assign Task</span>
		</a>
		<div style="display: flex; align-items: center; gap: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>
	</div>

	<!-- Page Container -->
	<div class="layout-wrapper">

		<div class="page-header">
			<div>
				<h1>📝 Task Management</h1>
				<p style="color: #64748b; margin-top: 4px; font-size: 14px;">Assign individual, group, or department-wide work items</p>
			</div>
			<a href="<%=backDashUrl%>" class="back-btn">
				<i class="fa-solid fa-house"></i> Dashboard
			</a>
		</div>

		<!-- Error Banner -->
		<%
		String errorMessage = (String) session.getAttribute("errorMessage");
		if (errorMessage != null) {
			session.removeAttribute("errorMessage");
		%>
		<div class="alert alert-error">
			<i class="fa-solid fa-circle-exclamation"></i> <%=errorMessage%>
		</div>
		<% } %>

		<div class="card">
			<form action="createTask" method="post" id="createTaskForm">

				<!-- Hidden input for assignment type -->
				<input type="hidden" name="assignmentType" id="assignmentTypeInput" value="INDIVIDUAL" />
				<!-- Hidden input for priority -->
				<input type="hidden" name="priority" id="priorityInput" value="MEDIUM" />

				<!-- Task Type Switcher -->
				<span class="mode-label">Select Task Assignment Type</span>
				<div class="mode-grid">
					<div class="mode-option active" id="modeIndividual" onclick="selectAssignmentMode('INDIVIDUAL')">
						<i class="fa-solid fa-user"></i>
						<span>Individual Task</span>
					</div>
					<div class="mode-option" id="modeGroup" onclick="selectAssignmentMode('GROUP')">
						<i class="fa-solid fa-users"></i>
						<span>Group Task</span>
					</div>
					<div class="mode-option" id="modeDepartment" onclick="selectAssignmentMode('DEPARTMENT')">
						<i class="fa-solid fa-building"></i>
						<span>Department Task</span>
					</div>
				</div>

				<!-- Task ID Auto-Generated -->
				<div class="form-group">
					<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
						<label for="taskId" style="margin-bottom: 0;">Task ID <small style="font-weight: 600; color: #0284c7;">(Auto-generated)</small></label>
						<button type="button" onclick="generateTaskId()" style="background: #e0f2fe; border: 1px solid #bae6fd; color: #0284c7; font-weight: 700; font-size: 12px; padding: 4px 10px; border-radius: 8px; cursor: pointer; transition: all 0.2s;">
							<i class="fa-solid fa-wand-magic-sparkles"></i> Auto-Generate New ID
						</button>
					</div>
					<div style="position: relative; display: flex; align-items: center;">
						<i class="fa-solid fa-hashtag" style="position: absolute; left: 16px; color: #0284c7; font-size: 14px;"></i>
						<input type="text" id="taskId" name="taskId" style="padding-left: 42px; font-weight: 700; color: #0f172a;" placeholder="e.g. TSK-2026-1001" required />
					</div>
				</div>

				<!-- Task Name -->
				<div class="form-group">
					<label for="taskName">Task Title / Name</label>
					<input type="text" id="taskName" name="taskName" placeholder="e.g. Develop User Dashboard Module" required />
				</div>

				<!-- Description -->
				<div class="form-group">
					<label for="description">Task Description</label>
					<textarea id="description" name="description" placeholder="Provide detailed instructions and scope for this task..."></textarea>
				</div>

				<!-- INDIVIDUAL ASSIGNMENT SECTION -->
				<div class="form-group" id="individualSection">
					<label for="employeeId">Assign to Employee</label>
					<select id="employeeId" name="employeeId">
						<option value="">-- Select Employee --</option>
						<%
						if (employeeList != null) {
							for (Employee emp : employeeList) {
								boolean isSelected = preselectedEmpId != null && String.valueOf(emp.getEmployee_id()).equals(preselectedEmpId);
						%>
						<option value="<%=emp.getEmployee_id()%>" <%=isSelected ? "selected" : ""%>>
							<%=emp.getEmployee_name()%> (ID #<%=emp.getEmployee_id()%> - <%=emp.getDepartment() != null ? emp.getDepartment() : "General"%>)
						</option>
						<%
							}
						}
						%>
					</select>
				</div>

				<!-- GROUP MULTI-SELECT SECTION -->
				<div class="form-group" id="groupSection" style="display: none;">
					<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
						<label style="margin-bottom: 0;">Select Group Team Members</label>
						<button type="button" onclick="toggleSelectAllEmps()" style="background: none; border: none; color: #0284c7; font-weight: 700; font-size: 12.5px; cursor: pointer;">
							<i class="fa-solid fa-check-double"></i> Select All / Deselect
						</button>
					</div>
					<div class="employee-checkbox-grid">
						<%
						if (employeeList != null) {
							for (Employee emp : employeeList) {
						%>
						<label class="emp-checkbox-card">
							<input type="checkbox" name="employeeIds" value="<%=emp.getEmployee_id()%>" class="emp-check-item" />
							<div class="emp-checkbox-info">
								<span class="emp-checkbox-name"><%=emp.getEmployee_name()%></span>
								<span class="emp-checkbox-dept">#<%=emp.getEmployee_id()%> • <%=emp.getDepartment() != null ? emp.getDepartment() : "General"%></span>
							</div>
						</label>
						<%
							}
						}
						%>
					</div>
				</div>

				<!-- DEPARTMENT ASSIGNMENT SECTION -->
				<div class="form-group" id="departmentSection" style="display: none;">
					<label for="departmentGroup">Select Department</label>
					<select id="departmentGroup" name="departmentGroup">
						<option value="ALL">🌟 Entire Company (All Employees)</option>
						<%
						for (String dept : departmentSet) {
						%>
						<option value="<%=dept%>">🏢 <%=dept%> Department</option>
						<% } %>
					</select>
				</div>

				<!-- Priority Selection -->
				<div class="form-group">
					<label>Task Priority</label>
					<div class="priority-options">
						<div class="priority-pill low" onclick="selectPriority('LOW', this)">LOW</div>
						<div class="priority-pill medium active" onclick="selectPriority('MEDIUM', this)">MEDIUM</div>
						<div class="priority-pill high" onclick="selectPriority('HIGH', this)">HIGH</div>
					</div>
				</div>

				<!-- Due Date -->
				<div class="form-group">
					<label for="dueDate">Due Date</label>
					<input type="date" id="dueDate" name="dueDate" required />
				</div>

				<button type="submit" class="btn-submit" id="submitBtn">
					<i class="fa-solid fa-plus-circle"></i> Create &amp; Assign Task
				</button>
			</form>
		</div>

	</div>

	<script>
	// Default due date to tomorrow
	var tomorrow = new Date();
	tomorrow.setDate(tomorrow.getDate() + 1);
	document.getElementById('dueDate').valueAsDate = tomorrow;

	function selectAssignmentMode(mode) {
		document.getElementById('assignmentTypeInput').value = mode;

		document.getElementById('modeIndividual').classList.remove('active');
		document.getElementById('modeGroup').classList.remove('active');
		document.getElementById('modeDepartment').classList.remove('active');

		document.getElementById('individualSection').style.display = 'none';
		document.getElementById('groupSection').style.display = 'none';
		document.getElementById('departmentSection').style.display = 'none';

		document.getElementById('employeeId').required = false;

		if (mode === 'GROUP') {
			document.getElementById('modeGroup').classList.add('active');
			document.getElementById('groupSection').style.display = 'block';
		} else if (mode === 'DEPARTMENT') {
			document.getElementById('modeDepartment').classList.add('active');
			document.getElementById('departmentSection').style.display = 'block';
		} else {
			document.getElementById('modeIndividual').classList.add('active');
			document.getElementById('individualSection').style.display = 'block';
			document.getElementById('employeeId').required = true;
		}
	}

	function selectPriority(val, el) {
		document.getElementById('priorityInput').value = val;
		document.querySelectorAll('.priority-pill').forEach(function(pill) {
			pill.classList.remove('active');
		});
		el.classList.add('active');
	}

	var allSelected = false;
	function toggleSelectAllEmps() {
		allSelected = !allSelected;
		document.querySelectorAll('.emp-check-item').forEach(function(cb) {
			cb.checked = allSelected;
		});
	}

	function generateTaskId() {
		var rand = Math.floor(1000 + Math.random() * 9000);
		var year = new Date().getFullYear();
		document.getElementById("taskId").value = "TSK-" + year + "-" + rand;
	}

	// Auto-generate Task ID on page load
	if (!document.getElementById("taskId").value) {
		generateTaskId();
	}

	// Default initialization
	<% if (preselectedEmpId != null && !preselectedEmpId.isBlank()) { %>
		selectAssignmentMode('INDIVIDUAL');
	<% } else { %>
		selectAssignmentMode('INDIVIDUAL');
	<% } %>
	</script>

</body>
</html>
