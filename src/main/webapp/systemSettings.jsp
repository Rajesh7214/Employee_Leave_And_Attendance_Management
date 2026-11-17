<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="java.util.Map"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}
String activePage = "systemSettings";

Employee employee = (Employee) session.getAttribute("employee");
if (employee == null && loggedUser != null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(loggedUser.getEmail());
	} catch (Exception ignored) {}
}

String adminName = employee != null && employee.getEmployee_name() != null ? employee.getEmployee_name() : "Admin";
String adminPhoto = (employee != null && employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + adminName + "&background=6366f1&color=fff&bold=true";

@SuppressWarnings("unchecked")
Map<String, String> settings = (Map<String, String>) request.getAttribute("settings");

String companyName = settings != null && settings.containsKey("company_name") ? settings.get("company_name") : "SmartOffice Solutions";
String workingStartTime = settings != null && settings.containsKey("working_start_time") ? settings.get("working_start_time") : "09:00 AM";
String workingEndTime = settings != null && settings.containsKey("working_end_time") ? settings.get("working_end_time") : "06:00 PM";
String maxBreaks = settings != null && settings.containsKey("max_breaks") ? settings.get("max_breaks") : "2";
String sessionTimeout = settings != null && settings.containsKey("session_timeout") ? settings.get("session_timeout") : "30";

String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Executive System Governance | SmartOffice Enterprise</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<style>
:root {
	--indigo-primary: #6366f1;
	--indigo-dark: #4f46e5;
	--indigo-light: #e0e7ff;
	--purple-accent: #a855f7;
	--cyan-accent: #06b6d4;
	--emerald-accent: #10b981;
	--text-main: #0f172a;
	--text-sub: #64748b;
	--bg-canvas: #f8fafc;
	--card-border: #e2e8f0;
}

* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', -apple-system, sans-serif; }
body { background: var(--bg-canvas); color: var(--text-main); min-height: 100vh; display: flex; overflow-x: hidden; }

.app-wrapper { display: flex; width: 100%; min-height: 100vh; }
.main-content {
	flex: 1;
	margin-left: var(--sidebar-w, 252px);
	padding: 28px 36px;
	overflow-y: auto;
	background: radial-gradient(circle at 10% 10%, rgba(99, 102, 241, 0.06) 0%, transparent 45%),
	            radial-gradient(circle at 90% 90%, rgba(6, 182, 212, 0.05) 0%, transparent 40%),
	            linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

/* Glassmorphism Command Header */
.governance-hero-banner {
	background: linear-gradient(135deg, #1e1b4b 0%, #312e81 50%, #4338ca 100%);
	color: #ffffff;
	border-radius: 24px;
	padding: 26px 32px;
	margin-bottom: 28px;
	box-shadow: 0 16px 36px rgba(49, 46, 129, 0.25);
	position: relative;
	overflow: hidden;
}
.governance-hero-banner::after {
	content: '';
	position: absolute;
	top: -50%;
	right: -20%;
	width: 380px;
	height: 380px;
	background: radial-gradient(circle, rgba(168, 85, 247, 0.25) 0%, transparent 70%);
	pointer-events: none;
}

.hero-top-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20px;
	flex-wrap: wrap;
	gap: 16px;
}

.hero-title-area h1 {
	font-size: 26px;
	font-weight: 800;
	letter-spacing: -0.5px;
	display: flex;
	align-items: center;
	gap: 12px;
}
.hero-title-area p {
	font-size: 13.5px;
	color: #c7d2fe;
	margin-top: 4px;
	font-weight: 500;
}

.status-live-tag {
	background: rgba(16, 185, 129, 0.2);
	border: 1px solid rgba(52, 211, 153, 0.4);
	color: #34d399;
	padding: 6px 16px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 800;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	letter-spacing: 0.5px;
}
.pulse-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: #34d399;
	box-shadow: 0 0 10px #34d399;
	animation: pulse 1.8s infinite;
}
@keyframes pulse { 0% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(1.3); } 100% { opacity: 1; transform: scale(1); } }

/* Quick KPI Header Ribbon */
.hero-kpi-ribbon {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 14px;
	padding-top: 18px;
	border-top: 1px solid rgba(255, 255, 255, 0.15);
}
.kpi-tile {
	background: rgba(255, 255, 255, 0.08);
	backdrop-filter: blur(10px);
	border: 1px solid rgba(255, 255, 255, 0.12);
	border-radius: 16px;
	padding: 12px 18px;
	display: flex;
	align-items: center;
	gap: 12px;
}
.kpi-tile i { font-size: 20px; color: #818cf8; }
.kpi-tile small { display: block; font-size: 10.5px; color: #a5b4fc; font-weight: 800; text-transform: uppercase; letter-spacing: 0.5px; }
.kpi-tile strong { font-size: 14.5px; font-weight: 800; color: #ffffff; }

/* Toast Notifications */
.alert-toast {
	padding: 14px 22px;
	border-radius: 16px;
	margin-bottom: 24px;
	font-size: 14px;
	font-weight: 700;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 6px 20px rgba(0, 0, 0, 0.06);
}
.alert-success { background: linear-gradient(135deg, #10b981, #059669); color: white; }
.alert-error { background: linear-gradient(135deg, #f43f5e, #e11d48); color: white; }

/* MAIN SPLIT COMMAND CENTER */
.settings-command-grid {
	display: grid;
	grid-template-columns: 1fr 380px;
	gap: 28px;
	align-items: start;
}
@media (max-width: 1120px) {
	.settings-command-grid { grid-template-columns: 1fr; }
}

/* LEFT FORM PANEL */
.config-form-card {
	background: #ffffff;
	border: 1px solid var(--card-border);
	border-radius: 24px;
	padding: 32px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.config-group-block {
	background: #f8fafc;
	border: 1px solid var(--card-border);
	border-radius: 20px;
	padding: 24px;
	margin-bottom: 22px;
	transition: all 0.25s ease;
}
.config-group-block:hover {
	border-color: #c7d2fe;
	box-shadow: 0 8px 24px rgba(99, 102, 241, 0.08);
}

.group-title-row {
	display: flex;
	align-items: center;
	gap: 12px;
	margin-bottom: 18px;
}
.group-icon-avatar {
	width: 38px;
	height: 38px;
	border-radius: 12px;
	background: linear-gradient(135deg, #6366f1, #4f46e5);
	color: white;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 16px;
	box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}
.group-title-row h3 { font-size: 16px; font-weight: 800; color: #0f172a; }
.group-title-row p { font-size: 12px; color: #64748b; font-weight: 600; }

.form-row-2col {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 18px;
}
@media (max-width: 700px) {
	.form-row-2col { grid-template-columns: 1fr; }
}

.input-field-wrap { display: flex; flex-direction: column; gap: 8px; margin-bottom: 14px; }
.input-field-wrap:last-child { margin-bottom: 0; }

.input-label {
	font-size: 12px;
	font-weight: 800;
	color: #334155;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	display: flex;
	align-items: center;
	gap: 8px;
}

.custom-input {
	width: 100%;
	padding: 13px 18px;
	border-radius: 14px;
	border: 1.5px solid #cbd5e1;
	background: #ffffff;
	font-size: 14.5px;
	font-weight: 700;
	color: #0f172a;
	outline: none;
	transition: all 0.2s ease;
}
.custom-input:focus {
	border-color: #6366f1;
	box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
}

/* Preset Buttons */
.preset-chips-row { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 6px; }
.btn-preset-chip {
	padding: 6px 14px;
	border-radius: 20px;
	border: 1px solid #cbd5e1;
	background: #ffffff;
	font-size: 11.5px;
	font-weight: 800;
	color: #475569;
	cursor: pointer;
	transition: all 0.2s;
}
.btn-preset-chip:hover, .btn-preset-chip.active {
	background: #6366f1;
	color: #ffffff;
	border-color: #6366f1;
	box-shadow: 0 3px 10px rgba(99, 102, 241, 0.3);
}

/* Shift Calculator Live Box */
.shift-live-banner {
	background: linear-gradient(135deg, #4f46e5 0%, #06b6d4 100%);
	color: white;
	padding: 14px 20px;
	border-radius: 16px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-top: 14px;
	box-shadow: 0 6px 20px rgba(79, 70, 229, 0.25);
}

/* Stepper Controls */
.stepper-flex { display: flex; align-items: center; gap: 12px; }
.btn-stepper {
	width: 44px;
	height: 44px;
	border-radius: 14px;
	border: 1px solid #cbd5e1;
	background: #ffffff;
	font-size: 16px;
	font-weight: 800;
	color: #0f172a;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;
}
.btn-stepper:hover { background: #6366f1; color: white; border-color: #6366f1; }

.btn-commit-settings {
	width: 100%;
	padding: 16px 28px;
	border-radius: 16px;
	border: none;
	background: linear-gradient(135deg, #6366f1, #4f46e5);
	color: white;
	font-size: 16px;
	font-weight: 800;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 12px;
	box-shadow: 0 8px 24px rgba(99, 102, 241, 0.4);
	transition: all 0.25s ease;
	margin-top: 10px;
}
.btn-commit-settings:hover {
	transform: translateY(-2px);
	box-shadow: 0 12px 30px rgba(99, 102, 241, 0.55);
}

/* RIGHT SIMULATOR CARD */
.right-simulator-card {
	background: #0f172a;
	color: #ffffff;
	border-radius: 24px;
	padding: 28px;
	box-shadow: 0 16px 40px rgba(15, 23, 42, 0.2);
	position: sticky;
	top: 24px;
}
.simulator-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 20px;
	padding-bottom: 16px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.12);
}
.simulator-header h4 { font-size: 16px; font-weight: 800; color: #38bdf8; display: flex; align-items: center; gap: 10px; }
.sim-badge { background: rgba(56, 189, 248, 0.15); color: #38bdf8; padding: 4px 10px; border-radius: 10px; font-size: 11px; font-weight: 800; }

.sim-preview-box {
	background: rgba(255, 255, 255, 0.05);
	border: 1px solid rgba(255, 255, 255, 0.1);
	border-radius: 18px;
	padding: 20px;
	margin-bottom: 18px;
}

.sim-item-row { margin-bottom: 16px; }
.sim-item-row:last-child { margin-bottom: 0; }
.sim-item-row label { font-size: 11px; font-weight: 800; text-transform: uppercase; color: #94a3b8; letter-spacing: 0.5px; display: block; margin-bottom: 6px; }
.sim-item-row strong { font-size: 16px; font-weight: 800; color: #ffffff; display: block; }
.sim-item-sub { font-size: 12px; color: #cbd5e1; margin-top: 2px; }

/* Visual Coffee Cup Break Counter */
.break-icons-bar { display: flex; gap: 8px; margin-top: 8px; }
.cup-icon { width: 32px; height: 32px; border-radius: 10px; background: rgba(245, 158, 11, 0.2); color: #f59e0b; display: flex; align-items: center; justify-content: center; font-size: 13px; border: 1px solid rgba(245, 158, 11, 0.4); }

.security-lock-card {
	background: linear-gradient(135deg, rgba(168, 85, 247, 0.15), rgba(99, 102, 241, 0.15));
	border: 1px solid rgba(168, 85, 247, 0.3);
	border-radius: 16px;
	padding: 16px;
	display: flex;
	align-items: center;
	gap: 14px;
}
.security-lock-card i { font-size: 24px; color: #c084fc; }
</style>
</head>

<body>
<div class="app-wrapper">

	<!-- Shared Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Area -->
	<div class="main-content">

		<!-- Notification Bar Header Component -->
		<div style="display: flex; justify-content: flex-end; margin-bottom: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>

		<!-- Toast Feedback -->
		<% if ("success".equalsIgnoreCase(msg)) { %>
		<div class="alert-toast alert-success">
			<span><i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> Application settings updated successfully and persisted across system!</span>
			<i class="fa-solid fa-xmark" style="cursor: pointer;" onclick="this.parentElement.style.display='none'"></i>
		</div>
		<% } else if ("error".equalsIgnoreCase(msg)) { %>
		<div class="alert-toast alert-error">
			<span><i class="fa-solid fa-triangle-exclamation" style="margin-right: 8px;"></i> Failed to update system configuration. Check audit logs.</span>
			<i class="fa-solid fa-xmark" style="cursor: pointer;" onclick="this.parentElement.style.display='none'"></i>
		</div>
		<% } %>

		<!-- Glassmorphism Executive Hero Banner -->
		<div class="governance-hero-banner">
			<div class="hero-top-row">
				<div class="hero-title-area">
					<h1><i class="fa-solid fa-sliders" style="color: #818cf8;"></i> General Application System Configuration</h1>
					<p>Executive parameter control hub for organization branding, work shift rules, daily break limits, and session policies</p>
				</div>
				<div class="status-live-tag">
					<span class="pulse-dot"></span> LIVE SYSTEM ACTIVE
				</div>
			</div>

			<div class="hero-kpi-ribbon">
				<div class="kpi-tile">
					<i class="fa-solid fa-building"></i>
					<div>
						<small>Organization</small>
						<strong id="kpiCompany"><%= companyName %></strong>
					</div>
				</div>

				<div class="kpi-tile">
					<i class="fa-solid fa-business-time"></i>
					<div>
						<small>Shift Window</small>
						<strong id="kpiShift"><%= workingStartTime %> - <%= workingEndTime %></strong>
					</div>
				</div>

				<div class="kpi-tile">
					<i class="fa-solid fa-mug-hot"></i>
					<div>
						<small>Break Allocation</small>
						<strong id="kpiBreaks"><%= maxBreaks %> Breaks/Day</strong>
					</div>
				</div>

				<div class="kpi-tile">
					<i class="fa-solid fa-hourglass-half"></i>
					<div>
						<small>Security Session</small>
						<strong id="kpiTimeout"><%= sessionTimeout %> Mins</strong>
					</div>
				</div>
			</div>
		</div>

		<!-- MAIN SPLIT COMMAND CENTER -->
		<div class="settings-command-grid">

			<!-- LEFT CONFIGURATION FORM PANEL -->
			<div class="config-form-card">
				<form action="${pageContext.request.contextPath}/systemSettings" method="post" id="settingsForm">

					<!-- GROUP 1: Company Branding & Identity -->
					<div class="config-group-block">
						<div class="group-title-row">
							<div class="group-icon-avatar"><i class="fa-solid fa-building"></i></div>
							<div>
								<h3>1. Organization Identity &amp; Branding</h3>
								<p>Configure company name shown on payslips, header title, and broadcast announcements</p>
							</div>
						</div>

						<div class="input-field-wrap">
							<label for="company_name" class="input-label"><i class="fa-solid fa-font"></i> Organization / Company Name</label>
							<input type="text" id="company_name" name="company_name" class="custom-input" value="<%= companyName %>" required placeholder="e.g. SmartOffice Solutions Pvt Ltd" oninput="syncLiveSimulator()">
						</div>
					</div>

					<!-- GROUP 2: Shift Operating Hours & Duration -->
					<div class="config-group-block">
						<div class="group-title-row">
							<div class="group-icon-avatar" style="background: linear-gradient(135deg, #06b6d4, #0891b2);"><i class="fa-solid fa-business-time"></i></div>
							<div>
								<h3>2. Shift Hours &amp; Workday Operating Window</h3>
								<p>Standard employee daily check-in start and check-out end times</p>
							</div>
						</div>

						<div class="form-row-2col">
							<div class="input-field-wrap">
								<label for="working_start_time" class="input-label"><i class="fa-solid fa-clock"></i> Shift Start Time</label>
								<input type="text" id="working_start_time" name="working_start_time" class="custom-input" value="<%= workingStartTime %>" required placeholder="09:00 AM" oninput="calculateShiftDuration(); syncLiveSimulator();">
							</div>

							<div class="input-field-wrap">
								<label for="working_end_time" class="input-label"><i class="fa-solid fa-clock-rotate-left"></i> Shift End Time</label>
								<input type="text" id="working_end_time" name="working_end_time" class="custom-input" value="<%= workingEndTime %>" required placeholder="06:00 PM" oninput="calculateShiftDuration(); syncLiveSimulator();">
							</div>
						</div>

						<div class="preset-chips-row">
							<span style="font-size: 11px; font-weight: 800; color: #64748b; align-self: center; margin-right: 4px;">QUICK SHIFT PRESETS:</span>
							<button type="button" class="btn-preset-chip" onclick="applyShiftPreset('09:00 AM', '06:00 PM')">9 AM - 6 PM (9h)</button>
							<button type="button" class="btn-preset-chip" onclick="applyShiftPreset('09:00 AM', '05:00 PM')">9 AM - 5 PM (8h)</button>
							<button type="button" class="btn-preset-chip" onclick="applyShiftPreset('10:00 AM', '07:00 PM')">10 AM - 7 PM (9h)</button>
							<button type="button" class="btn-preset-chip" onclick="applyShiftPreset('08:00 AM', '04:30 PM')">8 AM - 4:30 PM (8.5h)</button>
						</div>

						<div class="shift-live-banner">
							<div style="display: flex; align-items: center; gap: 10px; font-size: 14px; font-weight: 800;">
								<i class="fa-solid fa-stopwatch" style="font-size: 18px;"></i>
								<span>Calculated Daily Shift Duration:</span>
							</div>
							<div style="background: rgba(255, 255, 255, 0.25); padding: 5px 14px; border-radius: 12px; font-size: 13.5px; font-weight: 800;" id="shiftDurationBadge">
								9 Hours 0 Mins Shift
							</div>
						</div>
					</div>

					<!-- GROUP 3: Break Policy & Inactivity Timeout Rules -->
					<div class="config-group-block">
						<div class="group-title-row">
							<div class="group-icon-avatar" style="background: linear-gradient(135deg, #a855f7, #9333ea);"><i class="fa-solid fa-shield-cat"></i></div>
							<div>
								<h3>3. Break Limits &amp; Security Inactivity Policy</h3>
								<p>Maximum daily break allocation per workday and automatic session timeout limits</p>
							</div>
						</div>

						<div class="form-row-2col">
							<!-- Max Daily Breaks -->
							<div class="input-field-wrap">
								<label for="max_breaks" class="input-label"><i class="fa-solid fa-mug-hot"></i> Max Daily Breaks</label>
								<div class="stepper-flex">
									<button type="button" class="btn-stepper" onclick="adjustBreaks(-1)"><i class="fa-solid fa-minus"></i></button>
									<input type="number" id="max_breaks" name="max_breaks" class="custom-input" value="<%= maxBreaks %>" min="1" max="10" required style="text-align: center; font-size: 16px;" oninput="syncLiveSimulator()">
									<button type="button" class="btn-stepper" onclick="adjustBreaks(1)"><i class="fa-solid fa-plus"></i></button>
								</div>
								<div class="preset-chips-row" style="margin-top: 8px;">
									<button type="button" class="btn-preset-chip" onclick="setBreaksValue(1)">1 Break</button>
									<button type="button" class="btn-preset-chip" onclick="setBreaksValue(2)">2 Breaks</button>
									<button type="button" class="btn-preset-chip" onclick="setBreaksValue(3)">3 Breaks</button>
									<button type="button" class="btn-preset-chip" onclick="setBreaksValue(4)">4 Breaks</button>
								</div>
							</div>

							<!-- Session Timeout -->
							<div class="input-field-wrap">
								<label for="session_timeout" class="input-label"><i class="fa-solid fa-hourglass-half"></i> Session Timeout (Minutes)</label>
								<input type="number" id="session_timeout" name="session_timeout" class="custom-input" value="<%= sessionTimeout %>" min="5" max="480" required oninput="syncLiveSimulator()">
								<div class="preset-chips-row" style="margin-top: 8px;">
									<button type="button" class="btn-preset-chip" onclick="setTimeoutValue(15)">15 Min</button>
									<button type="button" class="btn-preset-chip" onclick="setTimeoutValue(30)">30 Min</button>
									<button type="button" class="btn-preset-chip" onclick="setTimeoutValue(60)">60 Min</button>
									<button type="button" class="btn-preset-chip" onclick="setTimeoutValue(120)">120 Min</button>
								</div>
							</div>
						</div>
					</div>

					<button type="submit" class="btn-commit-settings">
						<i class="fa-solid fa-floppy-disk"></i> Apply &amp; Save Application System Configuration
					</button>
				</form>
			</div>

			<!-- RIGHT REALTIME SYSTEM SIMULATOR CARD -->
			<div class="right-simulator-card">
				<div class="simulator-header">
					<h4><i class="fa-solid fa-desktop"></i> Realtime System Inspector</h4>
					<span class="sim-badge"><i class="fa-solid fa-bolt"></i> LIVE PREVIEW</span>
				</div>

				<div class="sim-preview-box">
					<div class="sim-item-row">
						<label>System Display Branding</label>
						<strong id="simCompany" style="color: #38bdf8;"><%= companyName %></strong>
						<div class="sim-item-sub">Appears on navigation header and employee payslips</div>
					</div>

					<div class="sim-item-row">
						<label>Daily Work Shift Window</label>
						<strong id="simShift" style="color: #ffffff;"><%= workingStartTime %> &ndash; <%= workingEndTime %></strong>
						<div class="sim-item-sub" id="simShiftSub">9 Hours 0 Mins Shift Window</div>
					</div>

					<div class="sim-item-row">
						<label>Daily Break Allocation</label>
						<strong id="simBreaks" style="color: #f59e0b;"><%= maxBreaks %> Allowed Breaks Per Workday</strong>
						<div class="break-icons-bar" id="simBreakIcons">
							<% int numB = Integer.parseInt(maxBreaks);
							   for(int b=0; b<numB; b++) { %>
							<div class="cup-icon"><i class="fa-solid fa-mug-hot"></i></div>
							<% } %>
						</div>
					</div>

					<div class="sim-item-row" style="margin-bottom: 0;">
						<label>Security Session Timeout</label>
						<strong id="simTimeout" style="color: #c084fc;"><%= sessionTimeout %> Minutes Inactivity Limit</strong>
						<div class="sim-item-sub">Users automatically logged out after inactivity</div>
					</div>
				</div>

				<div class="security-lock-card">
					<i class="fa-solid fa-shield-halved"></i>
					<div>
						<strong style="font-size: 13px; font-weight: 800; color: #ffffff; display: block;">Administrative Governance</strong>
						<span style="font-size: 11.5px; color: #e9d5ff;">Changes strictly persisted &amp; audited in Module 12</span>
					</div>
				</div>
			</div>

		</div>

	</div>
</div>

<script>
function adjustBreaks(delta) {
	var input = document.getElementById('max_breaks');
	if (input) {
		var val = parseInt(input.value) || 1;
		val = Math.max(1, Math.min(10, val + delta));
		input.value = val;
		syncLiveSimulator();
	}
}

function setBreaksValue(val) {
	var input = document.getElementById('max_breaks');
	if (input) {
		input.value = val;
		syncLiveSimulator();
	}
}

function setTimeoutValue(val) {
	var input = document.getElementById('session_timeout');
	if (input) {
		input.value = val;
		syncLiveSimulator();
	}
}

function applyShiftPreset(start, end) {
	document.getElementById('working_start_time').value = start;
	document.getElementById('working_end_time').value = end;
	calculateShiftDuration();
	syncLiveSimulator();
}

function calculateShiftDuration() {
	var startStr = document.getElementById('working_start_time').value.trim();
	var endStr = document.getElementById('working_end_time').value.trim();
	var badge = document.getElementById('shiftDurationBadge');
	var sub = document.getElementById('simShiftSub');

	try {
		var startMin = parseTimeToMinutes(startStr);
		var endMin = parseTimeToMinutes(endStr);

		if (startMin !== null && endMin !== null) {
			var diff = endMin - startMin;
			if (diff < 0) diff += 24 * 60; // Overnight shift
			var hrs = Math.floor(diff / 60);
			var mins = diff % 60;
			var txt = hrs + " Hours " + mins + " Mins Shift";
			if (badge) badge.innerText = txt;
			if (sub) sub.innerText = txt + " Operating Window";
			return;
		}
	} catch (e) {}

	if (badge) badge.innerText = "Standard 9 Hours Shift";
	if (sub) sub.innerText = "Standard Shift Window";
}

function parseTimeToMinutes(str) {
	if (!str) return null;
	var matches = str.match(/(\d+):(\d+)\s*(AM|PM)?/i);
	if (!matches) return null;

	var hrs = parseInt(matches[1]);
	var mins = parseInt(matches[2]);
	var ampm = matches[3] ? matches[3].toUpperCase() : null;

	if (ampm === "PM" && hrs < 12) hrs += 12;
	if (ampm === "AM" && hrs === 12) hrs = 0;

	return hrs * 60 + mins;
}

function syncLiveSimulator() {
	var comp = document.getElementById('company_name').value || "SmartOffice Solutions";
	var st = document.getElementById('working_start_time').value || "09:00 AM";
	var et = document.getElementById('working_end_time').value || "06:00 PM";
	var brk = document.getElementById('max_breaks').value || "2";
	var tout = document.getElementById('session_timeout').value || "30";

	// Top ribbon KPI
	document.getElementById('kpiCompany').innerText = comp;
	document.getElementById('kpiShift').innerText = st + " - " + et;
	document.getElementById('kpiBreaks').innerText = brk + " Breaks/Day";
	document.getElementById('kpiTimeout').innerText = tout + " Mins";

	// Right simulator
	document.getElementById('simCompany').innerText = comp;
	document.getElementById('simShift').innerText = st + " \u2013 " + et;
	document.getElementById('simBreaks').innerText = brk + " Allowed Breaks Per Workday";
	document.getElementById('simTimeout').innerText = tout + " Minutes Inactivity Limit";

	// Break Coffee Cups
	var iconsBar = document.getElementById('simBreakIcons');
	if (iconsBar) {
		var n = parseInt(brk) || 1;
		n = Math.max(1, Math.min(10, n));
		var html = "";
		for (var i = 0; i < n; i++) {
			html += '<div class="cup-icon"><i class="fa-solid fa-mug-hot"></i></div>';
		}
		iconsBar.innerHTML = html;
	}
}

document.addEventListener("DOMContentLoaded", function() {
	calculateShiftDuration();
	syncLiveSimulator();
});
</script>

</body>
</html>
