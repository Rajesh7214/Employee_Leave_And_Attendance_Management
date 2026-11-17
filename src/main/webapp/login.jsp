<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Sign In | ELAMS Workforce Suite</title>
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
	background: radial-gradient(circle at 10% 20%, #0f172a 0%, #0284c7 100%);
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 24px;
	position: relative;
	overflow-x: hidden;
}

/* Background Ambient Glow */
body::before {
	content: '';
	position: absolute;
	top: -150px;
	left: -150px;
	width: 500px;
	height: 500px;
	background: rgba(13, 148, 136, 0.25);
	border-radius: 50%;
	filter: blur(100px);
	z-index: 0;
}

.login-wrapper {
	position: relative;
	z-index: 1;
	background: #ffffff;
	border-radius: 28px;
	box-shadow: 0 25px 80px rgba(0, 0, 0, 0.45), 0 0 0 1px rgba(255, 255, 255, 0.1);
	width: 100%;
	max-width: 1040px;
	display: flex;
	overflow: hidden;
	min-height: 620px;
}

/* ===== LEFT DARK GLASSMORPHIC HERO PANEL ===== */
.left-panel {
	flex: 1 1 48%;
	background: linear-gradient(145deg, #0b0f19 0%, #0f172a 50%, #1e293b 100%);
	padding: 55px 45px;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	color: white;
	position: relative;
	overflow: hidden;
}

.left-panel::before {
	content: '';
	position: absolute;
	top: -100px;
	right: -100px;
	width: 300px;
	height: 300px;
	background: rgba(2, 132, 199, 0.18);
	border-radius: 50%;
	filter: blur(60px);
}

.brand-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	position: relative;
	z-index: 2;
}

.brand-logo {
	display: flex;
	align-items: center;
	gap: 12px;
	font-size: 24px;
	font-weight: 800;
	letter-spacing: -0.5px;
}

.logo-icon {
	width: 44px;
	height: 44px;
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	color: #ffffff;
	box-shadow: 0 8px 20px rgba(2, 132, 199, 0.4);
}

.version-pill {
	background: rgba(255, 255, 255, 0.1);
	border: 1px solid rgba(255, 255, 255, 0.18);
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 6px;
	color: #cbd5e1;
}

.status-dot {
	width: 7px;
	height: 7px;
	background: #10b981;
	border-radius: 50%;
	box-shadow: 0 0 8px #10b981;
}

.panel-body {
	position: relative;
	z-index: 2;
	margin: 30px 0;
}

.panel-tag {
	display: inline-block;
	background: rgba(2, 132, 199, 0.2);
	color: #38bdf8;
	padding: 5px 14px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.8px;
	margin-bottom: 14px;
	border: 1px solid rgba(56, 189, 248, 0.3);
}

.panel-body h1 {
	font-size: 32px;
	font-weight: 800;
	line-height: 1.25;
	margin-bottom: 16px;
	color: #ffffff;
}

.panel-body p {
	font-size: 14.5px;
	color: #94a3b8;
	line-height: 1.6;
	margin-bottom: 26px;
}

/* Glass Feature Cards */
.feature-cards {
	display: flex;
	flex-direction: column;
	gap: 12px;
}

.glass-card {
	background: rgba(255, 255, 255, 0.05);
	border: 1px solid rgba(255, 255, 255, 0.1);
	border-radius: 16px;
	padding: 14px 18px;
	display: flex;
	align-items: center;
	gap: 14px;
	backdrop-filter: blur(10px);
}

.glass-icon {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	background: rgba(2, 132, 199, 0.2);
	color: #38bdf8;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 16px;
	flex-shrink: 0;
}

.glass-text {
	font-size: 13.5px;
	font-weight: 700;
	color: #f1f5f9;
}

.security-footer {
	position: relative;
	z-index: 2;
	display: flex;
	align-items: center;
	gap: 10px;
	font-size: 12px;
	color: #64748b;
	font-weight: 600;
}

/* ===== RIGHT HIGH-CONTRAST FORM PANEL ===== */
.right-panel {
	flex: 1 1 52%;
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
	border-radius: 14px;
	margin-bottom: 22px;
	font-size: 13.5px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 12px;
}

.alert-error { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
.alert-success { background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; }

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
	left: 18px;
	color: #0284c7;
	font-size: 16px;
}

.input-wrapper input {
	width: 100%;
	padding: 15px 46px 15px 48px;
	border: 1.8px solid #cbd5e1;
	border-radius: 16px;
	font-size: 14.5px;
	font-weight: 600;
	color: #0f172a;
	background: #f8fafc;
	outline: none;
	transition: all 0.25s ease;
}

.input-wrapper input:focus {
	background: #ffffff;
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.15);
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

.options-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 26px;
	font-size: 13.5px;
}

.remember-me {
	display: flex;
	align-items: center;
	gap: 8px;
	color: #475569;
	font-weight: 600;
	cursor: pointer;
}

.remember-me input {
	accent-color: #0d9488;
	width: 17px;
	height: 17px;
	cursor: pointer;
}

.forgot-link {
	color: #0284c7;
	text-decoration: none;
	font-weight: 700;
	transition: color 0.15s;
}

.forgot-link:hover {
	color: #0369a1;
	text-decoration: underline;
}

.btn-login {
	width: 100%;
	padding: 16px;
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	border: none;
	border-radius: 16px;
	font-size: 16px;
	font-weight: 800;
	cursor: pointer;
	transition: all 0.25s ease;
	box-shadow: 0 10px 25px rgba(2, 132, 199, 0.3);
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
}

.btn-login:hover {
	transform: translateY(-2px);
	box-shadow: 0 14px 32px rgba(2, 132, 199, 0.42);
}

.signup-prompt {
	margin-top: 26px;
	text-align: center;
	font-size: 14px;
	color: #64748b;
	font-weight: 600;
}

.create-account-link {
	color: #0284c7;
	font-weight: 800;
	text-decoration: none;
	margin-left: 6px;
	transition: color 0.15s;
}

.create-account-link:hover {
	text-decoration: underline;
}

@media (max-width: 860px) {
	.login-wrapper {
		flex-direction: column;
		max-width: 480px;
	}
	.left-panel, .right-panel {
		padding: 38px 28px;
	}
}
</style>
</head>
<body>

	<div class="login-wrapper">

		<!-- Left Dark Glassmorphic Hero Panel -->
		<div class="left-panel">
			<div class="brand-header">
				<div class="brand-logo">
					<div class="logo-icon">
						<i class="fa-solid fa-shield-halved"></i>
					</div>
					<span>ELAMS</span>
				</div>
				<div class="version-pill">
					<span class="status-dot"></span> System Portal v2.4
				</div>
			</div>

			<div class="panel-body">
				<span class="panel-tag">Enterprise Operations</span>
				<h1>Streamline Your Workforce Operations</h1>
				<p>Unified enterprise solution for attendance logging, leave approvals, meeting scheduling, and task analytics.</p>

				<div class="feature-cards">
					<div class="glass-card">
						<div class="glass-icon">
							<i class="fa-solid fa-clock"></i>
						</div>
						<div class="glass-text">Real-Time Attendance &amp; Break Tracking</div>
					</div>

					<div class="glass-card">
						<div class="glass-icon">
							<i class="fa-solid fa-file-signature"></i>
						</div>
						<div class="glass-text">Automated Multi-Tier Leave Approvals</div>
					</div>

					<div class="glass-card">
						<div class="glass-icon">
							<i class="fa-solid fa-calendar-check"></i>
						</div>
						<div class="glass-text">Interactive Meeting Calendar &amp; Booking</div>
					</div>
				</div>
			</div>

			<div class="security-footer">
				<i class="fa-solid fa-lock" style="color:#10b981;"></i>
				<span>BCrypt 256-bit Encrypted Portal Access</span>
			</div>
		</div>

		<!-- Right High-Contrast Form Panel -->
		<div class="right-panel">
			<div class="form-header">
				<h2>Sign In to Your Account 👋</h2>
				<p>Enter your credentials to access your workspace</p>
			</div>

			<%
			String error = (String) request.getAttribute("errorMessage");
			String success = (String) request.getAttribute("successMessage");

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

			<form action="${pageContext.request.contextPath}/login" method="post" autocomplete="off" id="loginForm">
				
				<div class="form-group">
					<label for="email">Work Email or Username</label>
					<div class="input-wrapper">
						<i class="fa-solid fa-envelope input-icon"></i>
						<input type="text" id="email" name="email" placeholder="e.g. employee@elams.com" required="required" autocomplete="username" />
					</div>
				</div>

				<div class="form-group">
					<label for="password">Password</label>
					<div class="input-wrapper">
						<i class="fa-solid fa-lock input-icon"></i>
						<input type="password" id="password" name="password" placeholder="Enter password" required="required" autocomplete="current-password" />
						<button type="button" class="toggle-password" onclick="togglePasswordVisibility()" aria-label="Toggle password visibility">
							<i class="fa-solid fa-eye" id="pwdIcon"></i>
						</button>
					</div>
				</div>

				<div class="options-row">
					<label class="remember-me">
						<input type="checkbox" id="rememberMe" name="rememberMe" />
						<span>Remember me</span>
					</label>
					<a href="${pageContext.request.contextPath}/forgotPassword.jsp" class="forgot-link">Forgot Password?</a>
				</div>

				<button type="submit" class="btn-login" id="submitBtn">
					<i class="fa-solid fa-right-to-bracket"></i> Sign In to Portal
				</button>
			</form>

			<div class="signup-prompt">
				<span>Don't have an account?</span>
				<a href="${pageContext.request.contextPath}/register.jsp" class="create-account-link">
					<i class="fa-solid fa-user-plus" style="font-size: 13px;"></i> Create Account
				</a>
			</div>
		</div>

	</div>

	<script>
		function togglePasswordVisibility() {
			var pwdInput = document.getElementById("password");
			var pwdIcon = document.getElementById("pwdIcon");
			if (pwdInput.type === "password") {
				pwdInput.type = "text";
				pwdIcon.className = "fa-solid fa-eye-slash";
			} else {
				pwdInput.type = "password";
				pwdIcon.className = "fa-solid fa-eye";
			}
		}

		document.getElementById("loginForm").addEventListener("submit", function() {
			var btn = document.getElementById("submitBtn");
			btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Authenticating...';
			btn.style.opacity = "0.88";
			btn.style.pointerEvents = "none";
		});
	</script>
</body>
</html>
