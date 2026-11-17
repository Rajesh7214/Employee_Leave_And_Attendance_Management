<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
String sessionRole = (String) session.getAttribute("role");
com.rajesh.elams.model.User loggedUser = (com.rajesh.elams.model.User) session.getAttribute("loggedUser");
if ((sessionRole == null || sessionRole.isBlank()) && loggedUser != null) {
	sessionRole = loggedUser.getRole();
}
if ((sessionRole == null || sessionRole.isBlank()) && session.getAttribute("employee") != null) {
	com.rajesh.elams.model.Employee sessionEmp = (com.rajesh.elams.model.Employee) session.getAttribute("employee");
	if (sessionEmp.getDesignation() != null && sessionEmp.getDesignation().toLowerCase().contains("manager")) {
		sessionRole = "manager";
	}
}

if (!"admin".equalsIgnoreCase(sessionRole)) {
	if ("hr".equalsIgnoreCase(sessionRole)) {
		response.sendRedirect("hrDashboard");
	} else if ("manager".equalsIgnoreCase(sessionRole)) {
		response.sendRedirect("managerDashboard");
	} else {
		response.sendRedirect("viewEmployeesServlet");
	}
	return;
}
String backDashUrl = "adminDashboardServlet";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Add New Employee | ELAMS</title>
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
	max-width: 920px;
	margin: 35px auto;
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
}

/* ===== HERO PREVIEW CARD ===== */
.hero-preview-card {
	background: #ffffff;
	border-radius: 24px;
	padding: 24px 30px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	margin-bottom: 28px;
	display: flex;
	align-items: center;
	gap: 22px;
	position: relative;
	overflow: hidden;
}

.hero-preview-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 5px;
	background: linear-gradient(90deg, #38bdf8 0%, #0d9488 100%);
}

.avatar-preview-box {
	position: relative;
	flex-shrink: 0;
}

.avatar-preview-img {
	width: 76px;
	height: 76px;
	border-radius: 20px;
	object-fit: cover;
	display: block;
	box-shadow: 0 6px 18px rgba(2, 132, 199, 0.22);
	border: 3px solid #ffffff;
}

.banner-meta h2 {
	font-size: 22px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 4px;
}

.banner-meta p {
	font-size: 13.5px;
	font-weight: 600;
	color: #0d9488;
}

/* Info Credential Box */
.credential-info-box {
	background: #f0fdf4;
	border: 1px solid #bbf7d0;
	border-left: 4px solid #10b981;
	border-radius: 16px;
	padding: 16px 20px;
	margin-bottom: 25px;
	font-size: 13.5px;
	color: #166534;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 12px;
}

.credential-info-box strong {
	color: #14532d;
}

.pwd-badge {
	background: #ffffff;
	border: 1px dashed #10b981;
	padding: 4px 12px;
	border-radius: 8px;
	font-weight: 800;
	font-family: monospace;
	font-size: 14px;
	color: #047857;
}

/* ===== FORM CARD ===== */
.form-card {
	background: #ffffff;
	border-radius: 24px;
	padding: 35px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
}

.form-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
	gap: 24px;
}

.form-group {
	margin-bottom: 22px;
}

.form-group label {
	display: block;
	font-size: 13.5px;
	font-weight: 700;
	color: #334155;
	margin-bottom: 8px;
}

.form-group label span.required {
	color: #e11d48;
}

.input-wrapper {
	position: relative;
}

.input-wrapper i {
	position: absolute;
	left: 16px;
	top: 50%;
	transform: translateY(-50%);
	color: #0284c7;
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
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.14);
}

.help-text {
	font-size: 12px;
	color: #94a3b8;
	margin-top: 6px;
	font-weight: 500;
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

.alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
.alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

/* Form Action Buttons */
.form-actions {
	display: flex;
	align-items: center;
	gap: 14px;
	margin-top: 15px;
	padding-top: 25px;
	border-top: 1px dashed #e2e8f0;
}

.btn-submit {
	background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
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
	box-shadow: 0 4px 16px rgba(13, 148, 136, 0.3);
	transition: all 0.25s ease;
	flex: 1;
	justify-content: center;
}

.btn-submit:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(13, 148, 136, 0.4);
}

.btn-reset {
	background: #f1f5f9;
	color: #475569;
	padding: 14px 28px;
	border-radius: 14px;
	border: none;
	font-size: 14.5px;
	font-weight: 700;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s;
}

.btn-reset:hover {
	background: #e2e8f0;
	color: #0f172a;
}

@media (max-width: 768px) {
	.navbar { padding: 14px 20px; }
	.container { padding: 0 16px; margin: 20px auto; }
	.form-grid { grid-template-columns: 1fr; }
	.form-actions { flex-direction: column; }
	.btn-submit, .btn-reset { width: 100%; text-align: center; }
}
</style>
</head>

<body>

	<!-- Top Ocean Teal & Sky Blue Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-user-plus"></i>
			<span class="navbar-title">ELAMS Add Employee</span>
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
				<h1>👤 Add New Employee</h1>
				<p>Create a new employee profile and generate login access credentials</p>
			</div>
			<a href="viewEmployees" class="back-btn">
				<i class="fa-solid fa-arrow-left"></i> View Directory
			</a>
		</div>

		<!-- Live Hero Preview Banner -->
		<div class="hero-preview-card">
			<div class="avatar-preview-box">
				<img id="avatarPreview" src="https://ui-avatars.com/api/?name=New+Employee&background=0284c7&color=fff&bold=true" class="avatar-preview-img" alt="Avatar Preview" />
			</div>
			<div class="banner-meta">
				<h2 id="previewName">New Employee Profile</h2>
				<p id="previewSubtitle"><i class="fa-solid fa-building"></i> Select department & designation below</p>
			</div>
		</div>

		<!-- Credential Info Banner -->
		<div class="credential-info-box">
			<div>
				<i class="fa-solid fa-key" style="margin-right: 6px;"></i>
				<strong>Automatic Account Creation:</strong> A login account will be generated with default password:
			</div>
			<span class="pwd-badge">Welcome@123</span>
		</div>

		<!-- Success & Error Alert Messages -->
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
			<form action="addEmployee" method="post" onsubmit="return validateForm()">

				<div class="form-grid">

					<!-- Full Name -->
					<div class="form-group">
						<label for="name">Employee Full Name <span class="required">*</span></label>
						<div class="input-wrapper">
							<i class="fa-solid fa-user"></i>
							<input type="text" id="name" name="name" placeholder="e.g. Rahul Sharma" required pattern="[A-Za-z\s]{2,50}" title="Name must contain only letters and spaces (2-50 characters)" oninput="updateLivePreview()" />
						</div>
						<div class="help-text">Full legal name of the employee</div>
					</div>

					<!-- Email Address -->
					<div class="form-group">
						<label for="email">Email Address <span class="required">*</span></label>
						<div class="input-wrapper">
							<i class="fa-solid fa-envelope"></i>
							<input type="email" id="email" name="email" placeholder="rahul@company.com" required title="Please enter a valid email address" />
						</div>
						<div class="help-text">Used for login and official notifications</div>
					</div>

					<!-- Phone Number -->
					<div class="form-group">
						<label for="phone">Phone Number <span class="required">*</span></label>
						<div class="input-wrapper">
							<i class="fa-solid fa-phone"></i>
							<input type="tel" id="phone" name="phone" placeholder="9876543210" required pattern="[0-9\-\+\s]{10,15}" title="Phone number must be 10-15 digits" />
						</div>
						<div class="help-text">Direct contact mobile number (10-15 digits)</div>
					</div>

					<!-- Profile Photo URL -->
					<div class="form-group">
						<label for="profilePhoto">Profile Photo URL</label>
						<div class="input-wrapper">
							<i class="fa-solid fa-image"></i>
							<input type="text" id="profilePhoto" name="profilePhoto" placeholder="https://example.com/photo.jpg" oninput="updateLivePreview()" />
						</div>
						<div class="help-text">Optional link to avatar photo image</div>
					</div>

					<!-- Department Selector -->
					<div class="form-group">
						<label for="department">Department <span class="required">*</span></label>
						<div class="input-wrapper">
							<i class="fa-solid fa-building"></i>
							<select id="department" name="department" required onchange="updateLivePreview()">
								<option value="">-- Select Department --</option>
								<option value="IT">Information Technology (IT)</option>
								<option value="HR">Human Resources (HR)</option>
								<option value="Finance">Finance</option>
								<option value="Sales">Sales</option>
								<option value="Marketing">Marketing</option>
								<option value="Operations">Operations</option>
								<option value="Management">Management</option>
								<option value="Other">Other</option>
							</select>
						</div>
						<div class="help-text">Department assignment</div>
					</div>

					<!-- Job Designation Selector -->
					<div class="form-group">
						<label for="designation">Job Designation <span class="required">*</span></label>
						<div class="input-wrapper">
							<i class="fa-solid fa-id-badge"></i>
							<select id="designation" name="designation" required onchange="updateLivePreview()">
								<option value="">-- Select Designation --</option>
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
						<div class="help-text">Job title position</div>
					</div>

					<!-- Account Role Selector -->
					<div class="form-group">
						<label for="role">Account Access Role <span class="required">*</span></label>
						<div class="input-wrapper">
							<i class="fa-solid fa-user-shield"></i>
							<select id="role" name="role" required>
								<option value="employee" selected>Employee (Standard Access)</option>
								<option value="hr">HR (Human Resources &amp; Payroll Manager)</option>
								<option value="manager">Manager (Team Leader Access)</option>
								<option value="admin">Admin (System Administrator Access)</option>
							</select>
						</div>
						<div class="help-text">Permissions role for logging into ELAMS</div>
					</div>

				</div>

	<!-- Form JS Logic -->
	<script>
	function updateLivePreview() {
		var name = document.getElementById("name").value.trim() || "New Employee Profile";
		var dept = document.getElementById("department").value || "General";
		var desig = document.getElementById("designation").value || "Team Member";
		var photoUrl = document.getElementById("profilePhoto").value.trim();
		var img = document.getElementById("avatarPreview");

		document.getElementById("previewName").innerText = name;
		document.getElementById("previewSubtitle").innerHTML = '<i class="fa-solid fa-building"></i> ' + dept + ' • ' + desig;

		if (photoUrl) {
			img.src = photoUrl;
		} else {
			img.src = "https://ui-avatars.com/api/?name=" + encodeURIComponent(name) + "&background=0284c7&color=fff&bold=true";
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
			document.getElementById("name").focus();
			return false;
		}
		if (!/^[A-Za-z\s]+$/.test(name)) {
			alert("Employee name must contain only letters and spaces.");
			document.getElementById("name").focus();
			return false;
		}
		if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
			alert("Please enter a valid email address.");
			document.getElementById("email").focus();
			return false;
		}
		if (!/^[0-9\-\+\s]{10,15}$/.test(phone)) {
			alert("Phone number must be 10 to 15 digits.");
			document.getElementById("phone").focus();
			return false;
		}
		if (!department) {
			alert("Please select a department.");
			document.getElementById("department").focus();
			return false;
		}
		if (!designation) {
			alert("Please select a designation.");
			document.getElementById("designation").focus();
			return false;
		}
		return true;
	}

	// Initialize calculations on load
	window.addEventListener('DOMContentLoaded', calcSalaryPreview);
	</script>
</body>
</html>