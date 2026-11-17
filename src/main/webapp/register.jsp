<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Create Account - ELAMS</title>

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
}

body {
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	background: linear-gradient(135deg, #ffb6c9 0%, #ffd1de 100%);
	min-height: 100vh;
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 20px;
	overflow-x: hidden;
}

.login-card {
	background: white;
	border-radius: 24px;
	box-shadow: 0 25px 50px rgba(214, 51, 108, 0.25);
	width: 100%;
	max-width: 860px;
	display: flex;
	overflow: hidden;
	animation: slideIn 0.5s ease-out;
	min-height: 520px;
}

@keyframes slideIn {
	from {
		opacity: 0;
		transform: translateY(-20px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

/* ================= ILLUSTRATION PANEL ================= */
.illustration-panel {
	position: relative;
	flex: 1 1 46%;
	background: #ffffff;
	padding: 48px 40px;
	display: flex;
	flex-direction: column;
	justify-content: center;
	overflow: hidden;
}

.blob-blue {
	position: absolute;
	left: -70px;
	bottom: -90px;
	width: 230px;
	height: 230px;
	background: #8ed1ec;
	border-radius: 42% 58% 65% 35%/45% 40% 60% 55%;
	z-index: 0;
}

.blob-pink {
	position: absolute;
	right: -60px;
	bottom: -70px;
	width: 260px;
	height: 230px;
	background: #ea4c79;
	border-radius: 60% 40% 38% 62%/55% 45% 55% 45%;
	z-index: 1;
}

.blob-pink::before {
	content: "";
	position: absolute;
	left: 30px;
	top: -18px;
	width: 60px;
	height: 60px;
	background: repeating-radial-gradient(circle, transparent 0, transparent 3px, rgba(255
		, 255, 255, 0.55) 4px, transparent 5px);
	border-radius: 50%;
	opacity: .6;
}

.dot-yellow {
	position: absolute;
	top: 78px;
	left: 46px;
	width: 22px;
	height: 22px;
	background: #fdd06c;
	border-radius: 50%;
	z-index: 2;
}

.dot-pink-sm {
	position: absolute;
	top: 58px;
	right: 70px;
	width: 14px;
	height: 14px;
	background: #eb5588;
	border-radius: 50%;
	z-index: 2;
}

.dot-dark {
	position: absolute;
	bottom: 96px;
	left: 34px;
	width: 12px;
	height: 12px;
	background: #2d3436;
	border-radius: 50%;
	z-index: 2;
}

.squiggle {
	position: absolute;
	top: 40px;
	left: 60px;
	width: 200px;
	z-index: 2;
	opacity: .55;
}

.wave-doodle {
	position: absolute;
	bottom: 130px;
	left: 130px;
	z-index: 2;
	opacity: .5;
}

.illustration-text {
	position: relative;
	z-index: 3;
	margin-top: 40px;
}

.illustration-text h1 {
	font-size: 30px;
	color: #2d3436;
	margin-bottom: 12px;
	font-weight: 700;
}

.illustration-text p {
	color: #7f8c8d;
	font-size: 14px;
	line-height: 1.6;
	max-width: 260px;
}

/* ================= FORM PANEL ================= */
.form-panel {
	flex: 1 1 54%;
	padding: 48px 44px;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.form-panel h2 {
	font-size: 30px;
	color: #2d3436;
	font-weight: 700;
	margin-bottom: 8px;
}

.brand-tag {
	color: #ea4c79;
	font-size: 12px;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 1.5px;
	margin-bottom: 26px;
}

.form-group {
	margin-bottom: 18px;
}

label {
	display: block;
	margin-bottom: 7px;
	color: #2d3436;
	font-weight: 600;
	font-size: 13px;
}

input[type="text"], input[type="email"], input[type="tel"], input[type="date"],
	input[type="password"], select {
	width: 100%;
	padding: 13px 16px;
	border: 2px solid #f1e4ea;
	border-radius: 10px;
	font-size: 14px;
	transition: all 0.3s ease;
	background: #fbf7f9;
	font-family: 'Segoe UI', sans-serif;
	color: #2d3436;
}

select {
	cursor: pointer;
	appearance: none;
	background-image:
		url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23b2bec3' stroke-width='2' fill='none' fill-rule='evenodd'/%3E%3C/svg%3E");
	background-repeat: no-repeat;
	background-position: right 16px center;
	padding-right: 40px;
}

input[type="text"]:focus, input[type="email"]:focus, input[type="tel"]:focus,
	input[type="date"]:focus, input[type="password"]:focus, select:focus {
	outline: none;
	border-color: #ea4c79;
	background-color: white;
	box-shadow: 0 0 0 4px rgba(234, 76, 121, 0.12);
}

.field-hint {
	display: block;
	margin-top: 6px;
	font-size: 12px;
	color: #999;
}

.field-hint.match {
	color: #1e8e5a;
}

.field-hint.mismatch {
	color: #c0335c;
}

.password-container {
	position: relative;
}

.toggle-password {
	position: absolute;
	right: 15px;
	top: 50%;
	transform: translateY(-50%);
	cursor: pointer;
	color: #b2bec3;
	font-size: 18px;
	user-select: none;
	border: none;
	background: none;
}

.toggle-password:hover {
	color: #ea4c79;
}

.alert {
	padding: 13px 16px;
	border-radius: 10px;
	margin-bottom: 18px;
	font-size: 13px;
	font-weight: 500;
	animation: slideIn 0.3s ease-out;
}

.alert-error {
	background: #fdecef;
	color: #c0335c;
	border-left: 4px solid #ea4c79;
	display: flex;
	align-items: center;
	gap: 10px;
}

.alert-error::before {
	content: "⚠";
	font-size: 18px;
}

.alert-success {
	background: #eafaf1;
	color: #1e8e5a;
	border-left: 4px solid #27ae60;
}

.remember-section {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24px;
	font-size: 13px;
}

.checkbox-wrapper {
	display: flex;
	align-items: center;
}

input[type="checkbox"] {
	margin-right: 6px;
	cursor: pointer;
	width: 17px;
	height: 17px;
	accent-color: #ea4c79;
}

.checkbox-wrapper label {
	margin: 0;
	font-weight: normal;
	cursor: pointer;
	color: #636e72;
}

.forgot-password {
	color: #ea4c79;
	text-decoration: none;
	font-weight: 600;
	transition: color 0.3s;
}

.forgot-password:hover {
	color: #d6336c;
	text-decoration: underline;
}

.login-btn {
	width: 100%;
	padding: 14px;
	background: linear-gradient(135deg, #ee5a8a 0%, #d6336c 100%);
	color: white;
	border: none;
	border-radius: 30px;
	font-size: 16px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.3s ease;
	box-shadow: 0 8px 20px rgba(234, 76, 121, 0.35);
}

.login-btn:hover {
	transform: translateY(-2px);
	box-shadow: 0 10px 25px rgba(234, 76, 121, 0.5);
}

.login-btn:active {
	transform: translateY(0);
}

.login-btn:disabled {
	opacity: 0.6;
	cursor: not-allowed;
}

.signup-section {
	text-align: center;
	margin-top: 18px;
	font-size: 13px;
	color: #7f8c8d;
}

.signup-section a {
	color: #ea4c79;
	text-decoration: none;
	font-weight: 600;
	transition: color 0.3s;
}

.signup-section a:hover {
	color: #d6336c;
	text-decoration: underline;
}

.security-notice {
	text-align: center;
	margin-top: 16px;
	font-size: 11px;
	color: #b2bec3;
}

@media ( max-width : 760px) {
	.login-card {
		max-width: 420px;
	}
	.illustration-panel {
		display: none;
	}
	.form-panel {
		padding: 40px 30px;
	}
}

/* Loading state */
.login-btn.loading {
	pointer-events: none;
}

.login-btn.loading::after {
	content: " ⏳";
}
</style>

</head>

<body>

	<div class="login-card">

		<!-- Illustration Panel -->
		<div class="illustration-panel">
			<svg class="squiggle" viewBox="0 0 200 90" fill="none"
				xmlns="http://www.w3.org/2000/svg">
				<path
					d="M2 2C40 2 30 40 55 45C80 50 75 20 95 25C115 30 105 55 125 58C145 61 150 40 175 45C190 48 195 60 198 70"
					stroke="#636e72" stroke-width="2" stroke-linecap="round" />
			</svg>
			<div class="dot-yellow"></div>
			<div class="dot-pink-sm"></div>
			<div class="dot-dark"></div>
			<div class="blob-blue"></div>
			<div class="blob-pink"></div>

			<div class="illustration-text">
				<h1>Join ELAMS</h1>
				<p>Create your employee account to apply for leave, mark
					attendance, and track your tasks.</p>
			</div>
		</div>

		<!-- Form Panel -->
		<div class="form-panel">
			<div class="brand-tag">ELAMS</div>
			<h2>Create Account</h2>

			<!-- Error / Success Message Display -->
			<%
			String error = (String) request.getAttribute("errorMessage");

			if (error != null && !error.isEmpty()) {
			%>
			<div class="alert alert-error">
				<%=error%>
			</div>
			<%
			}
			%>

			<!-- Register Form -->
			<form action="register" method="post" autocomplete="off">

				<div class="form-group">
					<label for="name">Full name</label> <input type="text" id="name"
						name="name" placeholder="Enter your full name" required>
				</div>

				<div class="form-group">
					<label for="email">Email</label> <input type="email" id="email"
						name="email" placeholder="Enter your email" required
						autocomplete="email">
				</div>

				<div class="form-group">
					<label for="phone">Phone number</label> <input type="tel"
						id="phone" name="phone" placeholder="10-digit phone number"
						pattern="[0-9]{10}" inputmode="numeric" maxlength="10" required>
					<span class="field-hint">Digits only, no spaces or dashes</span>
				</div>

				<div class="form-group">
					<label for="department">Department</label> <select id="department"
						name="department" required>
						<option value="" disabled selected>Select department</option>
						<option value="Engineering">Engineering</option>
						<option value="Human Resources">Human Resources</option>
						<option value="Sales">Sales</option>
						<option value="Marketing">Marketing</option>
						<option value="Finance">Finance</option>
						<option value="Operations">Operations</option>
					</select>
				</div>

				<div class="form-group">
					<label for="designation">Designation</label> <input type="text"
						id="designation" name="designation"
						placeholder="e.g. Software Developer" required>
				</div>

				<!-- Password Field -->
				<div class="form-group">
					<label for="password">Password</label>
					<div class="password-container">
						<input type="password" id="password" name="password"
							placeholder="At least 6 characters" required minlength="6"
							autocomplete="new-password">
						<button type="button" class="toggle-password" id="togglePassword"
							aria-label="Toggle password visibility">👁️</button>
					</div>
				</div>

				<!-- Confirm Password Field -->
				<div class="form-group">
					<label for="confirmPassword">Confirm password</label>
					<div class="password-container">
						<input type="password" id="confirmPassword" name="confirmPassword"
							placeholder="Re-enter your password" required minlength="6"
							autocomplete="new-password">
						<button type="button" class="toggle-password"
							id="toggleConfirmPassword"
							aria-label="Toggle password visibility">👁️</button>
					</div>
					<span class="field-hint" id="matchHint"></span>
				</div>

				<!-- Register Button -->
				<button type="submit" class="login-btn" id="registerBtn">Create
					Account</button>

			</form>

			<div class="signup-section">
				Already have an account? <a href="login.jsp">Sign In</a>
			</div>

			<!-- Security Notice -->
			<div class="security-notice">🔒 Your password is encrypted and
				never stored in plain text</div>
		</div>
	</div>

	<script>
		// Toggle Password Visibility (both fields)
		function wireToggle(buttonId, inputId) {
			const btn = document.getElementById(buttonId);
			const input = document.getElementById(inputId);
			btn.addEventListener('click', function(e) {
				e.preventDefault();
				const type = input.getAttribute('type') === 'password' ? 'text'
						: 'password';
				input.setAttribute('type', type);
			});
		}
		wireToggle('togglePassword', 'password');
		wireToggle('toggleConfirmPassword', 'confirmPassword');

		// Live password-match feedback
		const pwdField = document.getElementById('password');
		const confirmField = document.getElementById('confirmPassword');
		const matchHint = document.getElementById('matchHint');

		function checkMatch() {
			if (confirmField.value === '') {
				matchHint.textContent = '';
				matchHint.className = 'field-hint';
				return;
			}
			if (pwdField.value === confirmField.value) {
				matchHint.textContent = '✓ Passwords match';
				matchHint.className = 'field-hint match';
			} else {
				matchHint.textContent = '✗ Passwords do not match';
				matchHint.className = 'field-hint mismatch';
			}
		}
		pwdField.addEventListener('input', checkMatch);
		confirmField.addEventListener('input', checkMatch);

		// Client-side confirm-password check + prevent double submit
		document.querySelector('form').addEventListener('submit', function(e) {
			const pwd = pwdField.value;
			const confirm = confirmField.value;
			if (pwd !== confirm) {
				e.preventDefault();
				alert('Passwords do not match.');
				return;
			}
			const btn = document.getElementById('registerBtn');
			btn.disabled = true;
			btn.classList.add('loading');
			btn.textContent = 'Creating Account...';
		});
	</script>
</body>
</html>
