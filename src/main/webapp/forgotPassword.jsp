<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Reset Password | ELAMS</title>
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
	min-height: 100vh;
	background: linear-gradient(135deg, #e0f2fe 0%, #f0fdf4 45%, #e0f2fe 100%);
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 24px;
	position: relative;
	overflow-x: hidden;
}

.login-wrapper {
	position: relative;
	z-index: 1;
	background: #ffffff;
	border-radius: 28px;
	box-shadow: 0 25px 70px rgba(2, 132, 199, 0.18), 0 0 0 1px rgba(255, 255, 255, 0.8);
	width: 100%;
	max-width: 980px;
	display: flex;
	overflow: hidden;
	min-height: 600px;
}

/* Left Brand Panel */
.left-panel {
	flex: 1 1 45%;
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	padding: 50px;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	color: white;
	position: relative;
}

.brand-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.brand-logo {
	display: flex;
	align-items: center;
	gap: 12px;
	font-size: 24px;
	font-weight: 800;
}

.logo-icon {
	width: 44px;
	height: 44px;
	background: rgba(255, 255, 255, 0.22);
	border: 1px solid rgba(255, 255, 255, 0.35);
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
}

.version-pill {
	background: rgba(255, 255, 255, 0.2);
	border: 1px solid rgba(255, 255, 255, 0.3);
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 6px;
}

.status-dot {
	width: 7px;
	height: 7px;
	background: #34d399;
	border-radius: 50%;
}

.panel-body h1 {
	font-size: 32px;
	font-weight: 800;
	line-height: 1.25;
	margin-bottom: 16px;
}

.panel-body p {
	font-size: 14.5px;
	color: rgba(255, 255, 255, 0.92);
	line-height: 1.6;
	margin-bottom: 30px;
}

.security-card {
	background: rgba(255, 255, 255, 0.15);
	border: 1px solid rgba(255, 255, 255, 0.25);
	border-radius: 16px;
	padding: 16px 18px;
	display: flex;
	align-items: center;
	gap: 14px;
}

.security-icon {
	width: 40px;
	height: 40px;
	background: #ffffff;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	color: #0d9488;
	font-size: 18px;
}

/* Right Form Panel */
.right-panel {
	flex: 1 1 55%;
	padding: 55px 48px;
	display: flex;
	flex-direction: column;
	justify-content: center;
	background: #ffffff;
}

.form-header h2 {
	font-size: 28px;
	color: #0f172a;
	font-weight: 800;
	margin-bottom: 6px;
}

.form-header p {
	font-size: 14px;
	color: #64748b;
	margin-bottom: 24px;
}

.alert {
	padding: 14px 16px;
	border-radius: 12px;
	margin-bottom: 24px;
	font-size: 13.5px;
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 12px;
}

.alert-error { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
.alert-success { background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; }

.form-group {
	margin-bottom: 20px;
}

.form-group label {
	display: block;
	font-size: 13px;
	font-weight: 700;
	color: #1e293b;
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
	font-size: 16px;
}

.input-wrapper input {
	width: 100%;
	padding: 14px 44px 14px 46px;
	border: 1.8px solid #cbd5e1;
	border-radius: 16px;
	font-size: 14.5px;
	font-weight: 500;
	color: #0f172a;
	background: #f8fafc;
	outline: none;
	transition: all 0.25s;
}

.input-wrapper input:focus {
	background: #ffffff;
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.18);
}

.toggle-password {
	position: absolute;
	right: 14px;
	background: none;
	border: none;
	color: #94a3b8;
	cursor: pointer;
	font-size: 16px;
	padding: 4px;
}

.toggle-password:hover {
	color: #0284c7;
}

.btn-login {
	width: 100%;
	padding: 16px;
	background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
	color: white;
	border: none;
	border-radius: 16px;
	font-size: 16px;
	font-weight: 800;
	cursor: pointer;
	transition: all 0.25s;
	box-shadow: 0 10px 25px rgba(13, 148, 136, 0.3);
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	margin-top: 10px;
}

.btn-login:hover {
	transform: translateY(-2px);
	box-shadow: 0 14px 32px rgba(13, 148, 136, 0.45);
}

.back-link {
	color: #0284c7;
	font-weight: 800;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	margin-top: 22px;
}

.back-link:hover {
	text-decoration: underline;
}

@media (max-width: 840px) {
	.login-wrapper { flex-direction: column; max-width: 480px; }
	.left-panel, .right-panel { padding: 36px 28px; }
}
</style>
</head>
<body>

	<div class="login-wrapper">
		<!-- Left Panel -->
		<div class="left-panel">
			<div class="brand-header">
				<div class="brand-logo">
					<div class="logo-icon">
						<i class="fa-solid fa-clock-rotate-left"></i>
					</div>
					<span>ELAMS</span>
				</div>
				<div class="version-pill">
					<span class="status-dot"></span> Account Recovery
				</div>
			</div>

			<div class="panel-body">
				<span style="background: rgba(255,255,255,0.2); padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 800; text-transform: uppercase;">Password Reset</span>
				<h1 style="margin-top: 12px;">Secure Account Recovery</h1>
				<p>Enter your registered account email and set up a new password to restore portal access instantly.</p>

				<div class="security-card">
					<div class="security-icon">
						<i class="fa-solid fa-shield-halved"></i>
					</div>
					<div>
						<div style="font-weight: 700;">BCrypt Security</div>
						<div style="font-size: 12px; opacity: 0.85;">Encrypted credential protection</div>
					</div>
				</div>
			</div>

			<div style="border-top: 1px solid rgba(255,255,255,0.2); padding-top: 16px; font-size: 12px;">
				&copy; 2026 ELAMS Inc. All rights reserved.
			</div>
		</div>

		<!-- Right Panel Form -->
		<div class="right-panel">
			<div class="form-header">
				<h2>Reset Password 🔒</h2>
				<p>Enter your email and set a new password</p>
			</div>

			<%
			String error = (String) request.getAttribute("errorMessage");
			String success = (String) request.getAttribute("successMessage");
			String emailVal = (String) request.getAttribute("email");
			if (emailVal == null) emailVal = "";

			if (error != null && !error.trim().isEmpty()) {
			%>
			<div class="alert alert-error">
				<i class="fa-solid fa-circle-exclamation"></i>
				<span><%=error%></span>
			</div>
			<% } %>

			<%
			if (success != null && !success.trim().isEmpty()) {
			%>
			<div class="alert alert-success">
				<i class="fa-solid fa-circle-check"></i>
				<span><%=success%></span>
			</div>
			<% } %>

			<form action="${pageContext.request.contextPath}/forgotPassword" method="post" id="resetForm">
				<div class="form-group">
					<label for="email">Account Email</label>
					<div class="input-wrapper">
						<i class="fa-solid fa-envelope input-icon"></i>
						<input type="email" id="email" name="email" value="<%=emailVal%>" placeholder="e.g. employee@elams.com" required="required" autocomplete="email" />
					</div>
				</div>

				<div class="form-group">
					<label for="newPassword">New Password</label>
					<div class="input-wrapper">
						<i class="fa-solid fa-lock input-icon"></i>
						<input type="password" id="newPassword" name="newPassword" placeholder="Enter new password" required="required" autocomplete="new-password" />
						<button type="button" class="toggle-password" onclick="toggleVisibility('newPassword', 'pwdIcon1')">
							<i class="fa-solid fa-eye" id="pwdIcon1"></i>
						</button>
					</div>
				</div>

				<div class="form-group">
					<label for="confirmPassword">Confirm New Password</label>
					<div class="input-wrapper">
						<i class="fa-solid fa-lock input-icon"></i>
						<input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm new password" required="required" autocomplete="new-password" />
						<button type="button" class="toggle-password" onclick="toggleVisibility('confirmPassword', 'pwdIcon2')">
							<i class="fa-solid fa-eye" id="pwdIcon2"></i>
						</button>
					</div>
				</div>

				<button type="submit" class="btn-login" id="submitBtn">
					<i class="fa-solid fa-key"></i> Update Password
				</button>
			</form>

			<div style="text-align: center;">
				<a href="${pageContext.request.contextPath}/login.jsp" class="back-link">
					<i class="fa-solid fa-arrow-left"></i> Back to Sign In
				</a>
			</div>
		</div>
	</div>

	<script>
		function toggleVisibility(inputId, iconId) {
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
	</script>
</body>
</html>
