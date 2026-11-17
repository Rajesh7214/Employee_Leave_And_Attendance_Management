<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>

<%
String role = (String) session.getAttribute("role");
String backDashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";
String activePage = "changePassword";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Change Password | ELAMS</title>
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
	background: linear-gradient(180deg, #f0f9ff 0%, #f4f6fb 100%);
	color: #0f172a;
	min-height: 100vh;
}

/* Header Navbar */
.navbar {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	padding: 16px 35px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 20px rgba(13, 148, 136, 0.28);
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
}

/* Page Layout */
.layout-wrapper {
	display: flex;
	max-width: 1400px;
	margin: 0 auto;
	padding: 30px 24px;
	gap: 30px;
}

.main-content {
	flex: 1;
	max-width: 780px;
	margin: 0 auto;
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
	color: #0f172a;
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
	transition: all 0.25s;
}

.back-btn:hover {
	background: #0284c7;
	color: white;
}

/* Form Card */
.card {
	background: #ffffff;
	border-radius: 24px;
	padding: 35px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	position: relative;
	overflow: hidden;
}

.card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 5px;
	background: linear-gradient(90deg, #38bdf8 0%, #0d9488 100%);
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

.input-wrapper {
	position: relative;
	display: flex;
	align-items: center;
}

.input-wrapper i.input-icon {
	position: absolute;
	left: 16px;
	color: #0284c7;
	font-size: 15px;
}

.input-wrapper input {
	width: 100%;
	padding: 13px 44px 13px 46px;
	border: 1px solid #cbd5e1;
	border-radius: 14px;
	font-size: 14.5px;
	color: #0f172a;
	background: #f8fafc;
	outline: none;
	transition: all 0.25s;
}

.input-wrapper input:focus {
	background: #ffffff;
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.14);
}

.toggle-btn {
	position: absolute;
	right: 14px;
	background: none;
	border: none;
	color: #94a3b8;
	cursor: pointer;
	font-size: 15px;
	padding: 6px;
}

.toggle-btn:hover {
	color: #0284c7;
}

/* Password Strength Indicator Bar */
.strength-bar-wrapper {
	margin-top: 8px;
	height: 6px;
	background: #e2e8f0;
	border-radius: 4px;
	overflow: hidden;
	display: none;
}

.strength-bar {
	height: 100%;
	width: 0%;
	transition: all 0.3s ease;
	border-radius: 4px;
}

.strength-label {
	font-size: 12px;
	font-weight: 700;
	margin-top: 4px;
	display: block;
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

/* Buttons */
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
	justify-content: center;
	gap: 10px;
	box-shadow: 0 4px 16px rgba(13, 148, 136, 0.3);
	transition: all 0.25s;
	width: 100%;
	margin-top: 10px;
}

.btn-submit:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(13, 148, 136, 0.4);
}
</style>
</head>

<body>

	<!-- Top Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-key"></i>
			<span class="navbar-title">Change Password</span>
		</a>
		<div style="display: flex; align-items: center; gap: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>
	</div>

	<!-- Page Container -->
	<div class="layout-wrapper">
		<div class="main-content">

			<div class="page-header">
				<div>
					<h1>🔒 Security Settings</h1>
					<p style="color: #64748b; margin-top: 4px; font-size: 14px;">Update your password to keep your account safe</p>
				</div>
				<a href="<%=backDashUrl%>" class="back-btn">
					<i class="fa-solid fa-house"></i> Dashboard
				</a>
			</div>

			<!-- Success & Error Banners -->
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

			<div class="card">
				<form action="changePassword" method="post" id="changePwdForm">

					<!-- Current Password -->
					<div class="form-group">
						<label for="currentPassword">Current Password</label>
						<div class="input-wrapper">
							<i class="fa-solid fa-lock input-icon"></i>
							<input type="password" id="currentPassword" name="currentPassword" placeholder="Enter current password" required />
							<button type="button" class="toggle-btn" onclick="togglePass('currentPassword', 'iconCurr')">
								<i class="fa-solid fa-eye" id="iconCurr"></i>
							</button>
						</div>
					</div>

					<!-- New Password -->
					<div class="form-group">
						<label for="newPassword">New Password</label>
						<div class="input-wrapper">
							<i class="fa-solid fa-key input-icon"></i>
							<input type="password" id="newPassword" name="newPassword" placeholder="Enter new password (min. 6 chars)" required oninput="checkStrength()" />
							<button type="button" class="toggle-btn" onclick="togglePass('newPassword', 'iconNew')">
								<i class="fa-solid fa-eye" id="iconNew"></i>
							</button>
						</div>
						<div class="strength-bar-wrapper" id="strengthWrapper">
							<div class="strength-bar" id="strengthBar"></div>
						</div>
						<span class="strength-label" id="strengthLabel"></span>
					</div>

					<!-- Confirm New Password -->
					<div class="form-group">
						<label for="confirmPassword">Confirm New Password</label>
						<div class="input-wrapper">
							<i class="fa-solid fa-check-double input-icon"></i>
							<input type="password" id="confirmPassword" name="confirmPassword" placeholder="Re-enter new password" required oninput="checkMatch()" />
							<button type="button" class="toggle-btn" onclick="togglePass('confirmPassword', 'iconConf')">
								<i class="fa-solid fa-eye" id="iconConf"></i>
							</button>
						</div>
						<span class="strength-label" id="matchLabel"></span>
					</div>

					<button type="submit" class="btn-submit" id="saveBtn">
						<i class="fa-solid fa-shield-halved"></i> Update Password
					</button>
				</form>
			</div>

		</div>
	</div>

	<script>
	function togglePass(inputId, iconId) {
		var input = document.getElementById(inputId);
		var icon = document.getElementById(iconId);
		if (input.type === "password") {
			input.type = "text";
			icon.className = "fa-solid fa-eye-slash";
		} else {
			input.type = "password";
			icon.className = "fa-solid fa-eye";
		}
	}

	function checkStrength() {
		var pwd = document.getElementById("newPassword").value;
		var wrapper = document.getElementById("strengthWrapper");
		var bar = document.getElementById("strengthBar");
		var label = document.getElementById("strengthLabel");

		if (!pwd) {
			wrapper.style.display = "none";
			label.innerText = "";
			return;
		}

		wrapper.style.display = "block";
		var score = 0;
		if (pwd.length >= 6) score++;
		if (pwd.length >= 10) score++;
		if (/[A-Z]/.test(pwd)) score++;
		if (/[0-9]/.test(pwd)) score++;
		if (/[^A-Za-z0-9]/.test(pwd)) score++;

		if (score <= 2) {
			bar.style.width = "33%";
			bar.style.background = "#ef4444";
			label.style.color = "#ef4444";
			label.innerText = "Weak password";
		} else if (score <= 4) {
			bar.style.width = "66%";
			bar.style.background = "#f59e0b";
			label.style.color = "#f59e0b";
			label.innerText = "Medium strength";
		} else {
			bar.style.width = "100%";
			bar.style.background = "#10b981";
			label.style.color = "#10b981";
			label.innerText = "Strong password ✓";
		}

		checkMatch();
	}

	function checkMatch() {
		var pwd = document.getElementById("newPassword").value;
		var conf = document.getElementById("confirmPassword").value;
		var label = document.getElementById("matchLabel");

		if (!conf) {
			label.innerText = "";
			return;
		}

		if (pwd === conf) {
			label.style.color = "#10b981";
			label.innerText = "✓ Passwords match";
		} else {
			label.style.color = "#ef4444";
			label.innerText = "✕ Passwords do not match";
		}
	}
	</script>
</body>
</html>
