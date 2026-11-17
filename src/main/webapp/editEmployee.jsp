<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.User"%>

<%
Employee employee = (Employee) request.getAttribute("employee");
if (employee == null) {
	response.sendRedirect("viewEmployees");
	return;
}

String role = (String) session.getAttribute("role");
String backDashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";

String photo = (employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + (employee.getEmployee_name() != null ? employee.getEmployee_name() : "Emp") + "&background=4f46e5&color=fff&bold=true";

com.rajesh.elams.dao.UserDao userDao = new com.rajesh.elams.dao.UserDaoImpl();
User userAccount = userDao.getUserByEmail(employee.getEmail());
String currentAccountRole = userAccount != null ? userAccount.getRole() : "Employee";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Employee Profile &amp; Governance | ELAMS</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet" />

<style>
:root {
	--brand-primary: #4f46e5;
	--brand-primary-light: #6366f1;
	--brand-secondary: #06b6d4;
	--bg-main: #f8fafc;
	--card-bg: #ffffff;
	--text-primary: #0f172a;
	--text-secondary: #64748b;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background-color: var(--bg-main);
	color: var(--text-primary);
	min-height: 100vh;
}

/* Navbar Header */
.navbar {
	background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
	color: white;
	padding: 16px 36px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 20px rgba(79, 70, 229, 0.28);
	position: sticky;
	top: 0;
	z-index: 90;
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
	background: rgba(255, 255, 255, 0.2);
	width: 42px;
	height: 42px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.navbar-title {
	font-size: 20px;
	font-weight: 800;
	letter-spacing: -0.5px;
}

/* Main Container */
.container {
	max-width: 960px;
	margin: 32px auto;
	padding: 0 24px;
}

.page-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 20px;
	margin-bottom: 25px;
}

.page-title-group h1 {
	font-size: 26px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 10px;
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
	color: #4f46e5;
	background: #eef2ff;
	border: 1px solid #c7d2fe;
	padding: 10px 22px;
	border-radius: 30px;
	font-weight: 700;
	font-size: 14px;
	transition: all 0.25s ease;
}

.back-btn:hover {
	background: #4f46e5;
	color: white;
	transform: translateY(-2px);
}

/* Hero Profile Banner */
.profile-banner-card {
	background: #ffffff;
	border-radius: 24px;
	padding: 24px 30px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	margin-bottom: 28px;
	display: flex;
	align-items: center;
	gap: 24px;
	position: relative;
	overflow: hidden;
}

.profile-banner-card::before {
	content: '';
	position: absolute;
	top: 0; left: 0; right: 0;
	height: 5px;
	background: linear-gradient(90deg, #4f46e5 0%, #06b6d4 100%);
}

.avatar-preview-box {
	position: relative;
	flex-shrink: 0;
}

.avatar-preview-img {
	width: 82px;
	height: 82px;
	border-radius: 24px;
	object-fit: cover;
	display: block;
	box-shadow: 0 6px 20px rgba(79, 70, 229, 0.22);
	border: 3px solid #ffffff;
}

.banner-meta .emp-id-badge {
	font-size: 11.5px;
	font-weight: 800;
	color: #4f46e5;
	background: #eef2ff;
	padding: 4px 12px;
	border-radius: 8px;
	display: inline-block;
	margin-bottom: 6px;
	font-family: 'JetBrains Mono', monospace;
}

.banner-meta h2 {
	font-size: 22px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 4px;
}

.banner-meta .desig-tag {
	font-size: 13.5px;
	font-weight: 600;
	color: #0284c7;
	display: flex;
	align-items: center;
	gap: 8px;
}

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
.alert-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
.alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

/* Workspace Card & Tabs */
.form-card {
	background: #ffffff;
	border-radius: 24px;
	padding: 32px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
}

.nav-tabs {
	display: flex;
	gap: 10px;
	border-bottom: 1px solid #e2e8f0;
	padding-bottom: 16px;
	margin-bottom: 28px;
	overflow-x: auto;
}

.tab-link {
	padding: 10px 20px;
	border-radius: 12px;
	font-size: 13.5px;
	font-weight: 700;
	color: #64748b;
	background: #f1f5f9;
	border: none;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s ease;
	white-space: nowrap;
}

.tab-link.active {
	background: #4f46e5;
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(79, 70, 229, 0.3);
}

.tab-content { display: none; }
.tab-content.active { display: block; }

.form-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
	gap: 24px;
}

.form-group { margin-bottom: 20px; }

.form-group label {
	display: block;
	font-size: 13px;
	font-weight: 700;
	color: #334155;
	margin-bottom: 8px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.form-group label span.required { color: #e11d48; }

.input-wrapper { position: relative; }

.input-wrapper i {
	position: absolute;
	left: 16px;
	top: 50%;
	transform: translateY(-50%);
	color: #4f46e5;
	font-size: 15px;
}

.input-wrapper input, .input-wrapper select {
	width: 100%;
	padding: 12px 18px 12px 46px;
	border: 1px solid #cbd5e1;
	border-radius: 14px;
	font-size: 14px;
	color: #0f172a;
	background: #f8fafc;
	outline: none;
	transition: all 0.25s ease;
}

.input-wrapper input:focus, .input-wrapper select:focus {
	background: #ffffff;
	border-color: #4f46e5;
	box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.12);
}

.help-text {
	font-size: 12px;
	color: #94a3b8;
	margin-top: 6px;
	font-weight: 500;
}

/* Actions */
.form-actions {
	display: flex;
	align-items: center;
	gap: 14px;
	margin-top: 28px;
	padding-top: 24px;
	border-top: 1px dashed #e2e8f0;
}

.btn-save {
	background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
	color: white;
	padding: 14px 32px;
	border-radius: 14px;
	border: none;
	font-size: 15px;
	font-weight: 800;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	box-shadow: 0 4px 16px rgba(79, 70, 229, 0.35);
	transition: all 0.25s ease;
	flex: 1;
	justify-content: center;
}

.btn-save:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(79, 70, 229, 0.45);
}

.btn-cancel {
	background: #f1f5f9;
	color: #475569;
	padding: 14px 28px;
	border-radius: 14px;
	text-decoration: none;
	font-size: 14.5px;
	font-weight: 700;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s;
}

.btn-cancel:hover { background: #e2e8f0; color: #0f172a; }

.payroll-card {
	background: #f8fafc;
	border: 1px solid #e2e8f0;
	border-radius: 18px;
	padding: 24px;
	display: flex;
	align-items: center;
	justify-content: space-between;
}
</style>
</head>

<body>

	<!-- Top Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-user-pen"></i>
			<span class="navbar-title">ELAMS Employee Governance Center</span>
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
				<h1><i class="fa-solid fa-user-gear" style="color: #4f46e5;"></i> Edit Employee Profile</h1>
				<p>Manage personal details, department assignment, and system login permissions</p>
			</div>
			<a href="viewEmployees" class="back-btn">
				<i class="fa-solid fa-arrow-left"></i> Directory List
			</a>
		</div>

		<!-- Profile Banner Card -->
		<div class="profile-banner-card">
			<div class="avatar-preview-box">
				<img id="avatarPreview" src="<%=photo%>" class="avatar-preview-img" alt="Employee Photo" />
			</div>
			<div class="banner-meta">
				<span class="emp-id-badge">EMP ID #<%=employee.getEmployee_id()%></span>
				<h2><%=employee.getEmployee_name()%></h2>
				<div class="desig-tag">
					<i class="fa-solid fa-briefcase"></i> <%=employee.getDesignation() != null ? employee.getDesignation() : "Employee"%>
					<span style="color:#cbd5e1; margin:0 4px;">•</span>
					<i class="fa-solid fa-building"></i> <%=employee.getDepartment() != null ? employee.getDepartment() : "General"%>
					<span style="color:#cbd5e1; margin:0 4px;">•</span>
					<i class="fa-solid fa-shield"></i> <%=currentAccountRole.toUpperCase()%> ACCOUNT
				</div>
			</div>
		</div>

		<!-- Alerts -->
		<%
		String successMessage = (String) request.getAttribute("successMessage");
		if (successMessage != null && !successMessage.isEmpty()) {
		%>
		<div class="alert alert-success">
			<i class="fa-solid fa-circle-check"></i> <%=successMessage%>
		</div>
		<% } %>

		<%
		String errorMessage = (String) request.getAttribute("errorMessage");
		if (errorMessage != null && !errorMessage.isEmpty()) {
		%>
		<div class="alert alert-error">
			<i class="fa-solid fa-triangle-exclamation"></i> <%=errorMessage%>
		</div>
		<% } %>

		<!-- Form Card Container -->
		<div class="form-card">
			<form action="updateEmployee" method="post" onsubmit="return validateForm()">
				<input type="hidden" name="id" value="<%=employee.getEmployee_id()%>" />

				<!-- Nav Tab Links -->
				<div class="nav-tabs">
					<button type="button" class="tab-link active" onclick="switchTab('tab-personal', this)">
						<i class="fa-solid fa-id-card"></i> 1. Personal &amp; Contact Info
					</button>
					<button type="button" class="tab-link" onclick="switchTab('tab-org', this)">
						<i class="fa-solid fa-sitemap"></i> 2. Department &amp; Position
					</button>
					<button type="button" class="tab-link" onclick="switchTab('tab-account', this)">
						<i class="fa-solid fa-key"></i> 3. Role &amp; Login Governance
					</button>
					<button type="button" class="tab-link" onclick="switchTab('tab-payroll', this)">
						<i class="fa-solid fa-money-bill-wave"></i> 4. Compensation Shortcut
					</button>
				</div>

				<!-- TAB 1: Personal & Contact -->
				<div id="tab-personal" class="tab-content active">
					<div class="form-grid">
						<div class="form-group">
							<label for="name">Employee Full Name <span class="required">*</span></label>
							<div class="input-wrapper">
								<i class="fa-solid fa-user"></i>
								<input type="text" id="name" name="name" value="<%=employee.getEmployee_name()%>" placeholder="Enter full name" required pattern="[A-Za-z\s]{2,50}" />
							</div>
							<div class="help-text">Legal name of employee (2-50 letters)</div>
						</div>

						<div class="form-group">
							<label for="email">Email Address <span class="required">*</span></label>
							<div class="input-wrapper">
								<i class="fa-solid fa-envelope"></i>
								<input type="email" id="email" name="email" value="<%=employee.getEmail()%>" placeholder="name@company.com" required />
							</div>
							<div class="help-text">Official organization email address</div>
						</div>

						<div class="form-group">
							<label for="phone">Phone Number <span class="required">*</span></label>
							<div class="input-wrapper">
								<i class="fa-solid fa-phone"></i>
								<input type="tel" id="phone" name="phone" value="<%=employee.getPhone()%>" placeholder="Enter mobile number" required pattern="[0-9\-\+\s]{10,15}" />
							</div>
							<div class="help-text">Direct mobile contact (10-15 digits)</div>
						</div>

						<div class="form-group">
							<label for="profilePhoto">Profile Photo URL</label>
							<div class="input-wrapper">
								<i class="fa-solid fa-image"></i>
								<input type="text" id="profilePhoto" name="profilePhoto" value="<%=employee.getProfile_photo() != null ? employee.getProfile_photo() : ""%>" placeholder="https://example.com/avatar.jpg" oninput="updateAvatarPreview()" />
							</div>
							<div class="help-text">Direct image URL for avatar preview</div>
						</div>
					</div>
				</div>

				<!-- TAB 2: Department & Position -->
				<div id="tab-org" class="tab-content">
					<div class="form-grid">
						<div class="form-group">
							<label for="department">Department <span class="required">*</span></label>
							<div class="input-wrapper">
								<i class="fa-solid fa-building"></i>
								<select id="department" name="department" required>
									<option value="">-- Select Department --</option>
									<option value="IT" <%="IT".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Information Technology (IT)</option>
									<option value="HR" <%="HR".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Human Resources (HR)</option>
									<option value="Finance" <%="Finance".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Finance</option>
									<option value="Sales" <%="Sales".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Sales</option>
									<option value="Marketing" <%="Marketing".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Marketing</option>
									<option value="Operations" <%="Operations".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Operations</option>
									<option value="Management" <%="Management".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Management</option>
									<option value="Other" <%="Other".equalsIgnoreCase(employee.getDepartment()) ? "selected" : ""%>>Other</option>
								</select>
							</div>
							<div class="help-text">Assigned organizational unit</div>
						</div>

						<div class="form-group">
							<label for="designation">Job Designation <span class="required">*</span></label>
							<div class="input-wrapper">
								<i class="fa-solid fa-id-badge"></i>
								<select id="designation" name="designation" required>
									<option value="">-- Select Designation --</option>
									<option value="Manager" <%="Manager".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Manager</option>
									<option value="Senior Developer" <%="Senior Developer".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Senior Developer</option>
									<option value="Developer" <%="Developer".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Developer</option>
									<option value="Junior Developer" <%="Junior Developer".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Junior Developer</option>
									<option value="Analyst" <%="Analyst".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Analyst</option>
									<option value="Executive" <%="Executive".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Executive</option>
									<option value="Intern" <%="Intern".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Intern</option>
									<option value="Other" <%="Other".equalsIgnoreCase(employee.getDesignation()) ? "selected" : ""%>>Other</option>
								</select>
							</div>
							<div class="help-text">Official job title</div>
						</div>
					</div>
				</div>

				<!-- TAB 3: Role & Login Governance -->
				<div id="tab-account" class="tab-content">
					<div class="form-grid">
						<div class="form-group">
							<label for="userRole">System Access Role <span class="required">*</span></label>
							<div class="input-wrapper">
								<i class="fa-solid fa-user-shield"></i>
								<select id="userRole" name="userRole" required>
									<option value="Employee" <%="Employee".equalsIgnoreCase(currentAccountRole) ? "selected" : ""%>>Employee (Standard Access)</option>
									<option value="Manager" <%="Manager".equalsIgnoreCase(currentAccountRole) ? "selected" : ""%>>Manager (Team Approval Access)</option>
									<option value="HR" <%="HR".equalsIgnoreCase(currentAccountRole) ? "selected" : ""%>>HR Specialist (Workforce Admin)</option>
									<option value="Admin" <%="Admin".equalsIgnoreCase(currentAccountRole) ? "selected" : ""%>>Administrator (Full Control)</option>
								</select>
							</div>
							<div class="help-text">Synchronizes permissions in authentication database</div>
						</div>

						<div class="form-group">
							<label>Account Sync Status</label>
							<div style="padding: 12px; background: #ecfdf5; border: 1px solid #a7f3d0; border-radius: 14px; font-size: 13px; font-weight: 700; color: #065f46; display: flex; align-items: center; gap: 10px;">
								<i class="fa-solid fa-link"></i> Linked Account: <%=employee.getEmail()%>
							</div>
							<div class="help-text">Email updates automatically synchronize login username credentials</div>
						</div>
					</div>
				</div>

				<!-- TAB 4: Compensation Shortcut -->
				<div id="tab-payroll" class="tab-content">
					<div class="payroll-card">
						<div>
							<h3 style="font-size: 16px; font-weight: 800; color: #0f172a;"><i class="fa-solid fa-file-invoice-dollar" style="color: #4f46e5;"></i> Salary &amp; Structure Management</h3>
							<p style="font-size: 13.5px; color: #64748b; margin-top: 4px;">Configure base pay, allowances, and deductions for <%=employee.getEmployee_name()%></p>
						</div>
						<a href="manageSalary?empId=<%=employee.getEmployee_id()%>" class="back-btn" style="background: #4f46e5; color: white;">
							<i class="fa-solid fa-sliders"></i> Manage Salary
						</a>
					</div>
				</div>

				<!-- Form Actions -->
				<div class="form-actions">
					<button type="submit" class="btn-save">
						<i class="fa-solid fa-floppy-disk"></i> Save Employee Changes
					</button>
					<a href="viewEmployees" class="btn-cancel">
						Cancel
					</a>
				</div>
			</form>
		</div>

	</div>

	<!-- Form JS Logic -->
	<script>
	function switchTab(tabId, btn) {
		var tabs = document.getElementsByClassName("tab-content");
		for (var i = 0; i < tabs.length; i++) {
			tabs[i].classList.remove("active");
		}
		var links = document.getElementsByClassName("tab-link");
		for (var j = 0; j < links.length; j++) {
			links[j].classList.remove("active");
		}
		document.getElementById(tabId).classList.add("active");
		btn.classList.add("active");
	}

	function updateAvatarPreview() {
		var photoUrl = document.getElementById("profilePhoto").value.trim();
		var img = document.getElementById("avatarPreview");
		var name = document.getElementById("name").value.trim() || "Emp";
		if (photoUrl) {
			img.src = photoUrl;
		} else {
			img.src = "https://ui-avatars.com/api/?name=" + encodeURIComponent(name) + "&background=4f46e5&color=fff&bold=true";
		}
	}

	function validateForm() {
		var name = document.getElementById("name").value.trim();
		var email = document.getElementById("email").value.trim();
		var phone = document.getElementById("phone").value.trim();
		var department = document.getElementById("department").value;
		var designation = document.getElementById("designation").value;

		if (name.length < 2 || name.length > 50) {
			alert("Employee name must be between 2 and 50 characters.");
			return false;
		}
		if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
			alert("Please enter a valid email address.");
			return false;
		}
		if (!/^[0-9\-\+\s]{10,15}$/.test(phone)) {
			alert("Phone number must be 10 to 15 digits.");
			return false;
		}
		if (!department) {
			alert("Please select a department.");
			return false;
		}
		if (!designation) {
			alert("Please select a designation.");
			return false;
		}
		return true;
	}
	</script>
</body>
</html>