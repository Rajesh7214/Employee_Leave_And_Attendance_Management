<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Payroll"%>
<%@ page import="com.rajesh.elams.model.PayrollStatus"%>
<%@ page import="java.util.List"%>
<%@ page import="java.time.Month"%>
<%@ page import="java.time.format.TextStyle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.text.NumberFormat"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
if (loggedUser == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String role = (String) session.getAttribute("role");
if (role == null && loggedUser != null) role = loggedUser.getRole();
String displayName = loggedUser != null && loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "User";
displayName = Character.toUpperCase(displayName.charAt(0)) + (displayName.length() > 1 ? displayName.substring(1) : "");
String activePage = "teamPayroll";

List<Payroll> teamPayrolls = (List<Payroll>) request.getAttribute("teamPayrolls");
String department = (String) request.getAttribute("department");
if (department == null || department.isBlank()) department = "Engineering";

int currentMonth = request.getAttribute("currentMonth") != null ? (Integer) request.getAttribute("currentMonth") : 8;
int currentYear = request.getAttribute("currentYear") != null ? (Integer) request.getAttribute("currentYear") : 2026;

String currentMonthName = Month.of(currentMonth).getDisplayName(TextStyle.FULL, Locale.ENGLISH);
NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

double totalGross = 0.0, totalNet = 0.0, totalLop = 0.0, totalBasic = 0.0, totalDeductions = 0.0;
int teamCount = 0;
int paidCount = 0;
if (teamPayrolls != null) {
	teamCount = teamPayrolls.size();
	for (Payroll p : teamPayrolls) {
		totalGross += p.getGrossSalary();
		totalNet += p.getNetSalary();
		totalLop += p.getUnpaidLeaveDeduction();
		totalBasic += p.getBasicSalary();
		totalDeductions += p.getTotalDeductions();
		if ("PAID".equalsIgnoreCase(p.getStatus())) {
			paidCount++;
		}
	}
}

double retentionRate = totalGross > 0 ? (totalNet / totalGross) * 100.0 : 100.0;
double avgSalary = teamCount > 0 ? totalNet / teamCount : 0.0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Team Payroll Hub | RChips Solutions ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<style>
:root {
	--blue-primary: #2563eb;
	--blue-dark: #1d4ed8;
	--blue-light: #eff6ff;
	--text-primary: #0f172a;
	--text-secondary: #64748b;
	--card-bg: #ffffff;
	--surface-bg: #f8fafc;
	--border-color: #e2e8f0;
}

* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', -apple-system, sans-serif; }
body { background: var(--surface-bg); color: var(--text-primary); min-height: 100vh; display: flex; overflow-x: hidden; }
a { text-decoration: none; color: inherit; }

.app-wrapper { display: flex; width: 100%; min-height: 100vh; }
.main-content {
	flex: 1;
	margin-left: var(--sidebar-w, 252px);
	padding: 32px;
	overflow-y: auto;
	background: radial-gradient(circle at 10% 10%, rgba(37, 99, 235, 0.05) 0%, transparent 45%),
	            linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

/* Sticky Top Header Bar with Right Aligned Notification Bell */
.top-header-bar {
	height: 72px;
	background: rgba(255, 255, 255, 0.92);
	backdrop-filter: blur(16px);
	-webkit-backdrop-filter: blur(16px);
	border-bottom: 1px solid var(--border-color);
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 32px;
	position: sticky;
	top: 0;
	z-index: 90;
	margin: -32px -32px 28px -32px;
	box-shadow: 0 4px 20px rgba(15, 23, 42, 0.04);
}

.top-header-left {
	display: flex;
	align-items: center;
	gap: 16px;
}

.top-header-brand {
	display: flex;
	align-items: center;
	gap: 10px;
	font-size: 18px;
	font-weight: 800;
	color: #0f172a;
	letter-spacing: -0.4px;
}

.top-header-brand i {
	color: var(--blue-primary);
	font-size: 18px;
	background: #eff6ff;
	width: 38px;
	height: 38px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	border: 1px solid #bfdbfe;
}

.top-header-badge {
	font-size: 11px;
	font-weight: 800;
	color: #059669;
	background: #ecfdf5;
	border: 1px solid #a7f3d0;
	padding: 4px 12px;
	border-radius: 20px;
	display: flex;
	align-items: center;
	gap: 6px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.live-pulse-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: #10b981;
	display: inline-block;
	box-shadow: 0 0 8px #10b981;
}

.top-header-right {
	display: flex;
	align-items: center;
	gap: 14px;
}

.period-select-form {
	display: flex;
	align-items: center;
	gap: 6px;
	background: #ffffff;
	padding: 6px 14px;
	border-radius: 14px;
	border: 1.5px solid #cbd5e1;
	box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
}

.period-select-form select {
	background: transparent;
	color: #0f172a;
	border: none;
	font-weight: 700;
	font-size: 13px;
	outline: none;
	cursor: pointer;
}

.header-clock-pill {
	background: #f1f5f9;
	border: 1px solid #e2e8f0;
	padding: 7px 14px;
	border-radius: 50px;
	display: flex;
	align-items: center;
	gap: 8px;
	font-size: 12.5px;
	font-weight: 700;
	color: #0f172a;
	font-family: 'JetBrains Mono', monospace;
}

.topbar-notif-container .notif-bell-btn {
	background: #f1f5f9 !important;
	border-color: #cbd5e1 !important;
	color: #0f172a !important;
}

.topbar-notif-container .notif-bell-btn:hover,
.topbar-notif-container .notif-bell-btn.active {
	background: var(--blue-primary) !important;
	color: #ffffff !important;
	border-color: var(--blue-primary) !important;
}

/* Department Hero Banner */
.hero-banner {
	background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #1e3a8a 100%);
	border-radius: 24px;
	padding: 28px 32px;
	color: #ffffff;
	margin-bottom: 28px;
	position: relative;
	overflow: hidden;
	box-shadow: 0 16px 36px rgba(15, 23, 42, 0.15);
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 20px;
}

.hero-left h1 { font-size: 24px; font-weight: 800; letter-spacing: -0.5px; margin-bottom: 4px; display: flex; align-items: center; gap: 10px; }
.hero-left p { font-size: 13.5px; color: #94a3b8; font-weight: 500; }

.dept-pill-tag {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 12px;
	border-radius: 20px;
	background: rgba(255, 255, 255, 0.15);
	backdrop-filter: blur(8px);
	font-size: 11.5px;
	font-weight: 800;
	color: #60a5fa;
	border: 1px solid rgba(96, 165, 250, 0.3);
	margin-bottom: 8px;
	text-transform: uppercase;
}

.hero-quick-stats {
	display: flex;
	gap: 16px;
}

.hero-stat-box {
	background: rgba(255, 255, 255, 0.08);
	border: 1px solid rgba(255, 255, 255, 0.15);
	padding: 12px 18px;
	border-radius: 16px;
	text-align: right;
}
.hero-stat-box small { display: block; font-size: 10.5px; font-weight: 800; color: #94a3b8; text-transform: uppercase; }
.hero-stat-box strong { font-size: 18px; font-weight: 800; color: #ffffff; font-family: 'JetBrains Mono', monospace; }

/* KPI Cards Grid */
.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 28px; }
.kpi-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 22px;
	border: 1px solid var(--border-color);
	box-shadow: 0 4px 18px rgba(15, 23, 42, 0.03);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	transition: all 0.25s ease;
}
.kpi-card:hover { transform: translateY(-4px); border-color: #bfdbfe; box-shadow: 0 10px 25px rgba(37, 99, 235, 0.08); }

.kpi-head { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 10px; }
.kpi-title { font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }
.kpi-icon { width: 42px; height: 42px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 17px; color: white; }

.icon-emerald { background: linear-gradient(135deg, #10b981, #059669); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
.icon-blue { background: linear-gradient(135deg, #2563eb, #1d4ed8); box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }
.icon-amber { background: linear-gradient(135deg, #f59e0b, #d97706); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3); }
.icon-rose { background: linear-gradient(135deg, #ef4444, #dc2626); box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3); }

.kpi-value { font-size: 26px; font-weight: 800; color: #0f172a; font-family: 'JetBrains Mono', monospace; margin-top: 4px; }
.kpi-sub { font-size: 11.5px; font-weight: 700; color: var(--text-secondary); margin-top: 6px; }

/* Table Toolbar Card */
.table-card {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 24px;
	padding: 24px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.table-toolbar {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 16px;
	margin-bottom: 20px;
	flex-wrap: wrap;
}

.search-filter-box {
	position: relative;
	flex: 1;
	max-width: 380px;
}

.search-filter-box i {
	position: absolute;
	left: 14px;
	top: 50%;
	transform: translateY(-50%);
	color: #94a3b8;
	font-size: 14px;
}

.search-filter-box input {
	width: 100%;
	padding: 10px 14px 10px 40px;
	border-radius: 12px;
	border: 1px solid var(--border-color);
	font-size: 13.5px;
	font-weight: 600;
	outline: none;
	transition: all 0.2s;
	background: #f8fafc;
}
.search-filter-box input:focus {
	background: #ffffff;
	border-color: var(--blue-primary);
	box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
}

.filter-chips-row {
	display: flex;
	gap: 8px;
}

.btn-filter-chip {
	padding: 7px 14px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 700;
	border: 1px solid var(--border-color);
	background: #ffffff;
	color: var(--text-secondary);
	cursor: pointer;
	transition: all 0.2s;
}
.btn-filter-chip:hover, .btn-filter-chip.active {
	background: var(--blue-primary);
	color: #ffffff;
	border-color: var(--blue-primary);
	box-shadow: 0 4px 12px rgba(37, 99, 235, 0.25);
}

/* Data Table */
.data-table { width: 100%; border-collapse: separate; border-spacing: 0 6px; }
.data-table th { padding: 12px 16px; text-align: left; font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }
.data-table tbody tr { background: #f8fafc; border-radius: 14px; transition: all 0.2s; }
.data-table tbody tr:hover { background: #eff6ff; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(37, 99, 235, 0.05); }
.data-table td { padding: 14px 16px; font-size: 13.5px; color: #0f172a; vertical-align: middle; }
.data-table td:first-child { border-top-left-radius: 14px; border-bottom-left-radius: 14px; }
.data-table td:last-child { border-top-right-radius: 14px; border-bottom-right-radius: 14px; }

.emp-avatar-cell { display: flex; align-items: center; gap: 12px; }
.avatar-circle { width: 38px; height: 38px; border-radius: 12px; background: linear-gradient(135deg, var(--blue-primary), var(--blue-dark)); color: white; font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 14px; box-shadow: 0 3px 8px rgba(37, 99, 235, 0.25); }

.badge-status { padding: 4px 12px; border-radius: 20px; font-size: 10.5px; font-weight: 800; display: inline-flex; align-items: center; gap: 5px; text-transform: uppercase; }
.badge-calculated { background: #e0f2fe; color: #0369a1; border: 1px solid #7dd3fc; }
.badge-pending { background: #fef3c7; color: #b45309; border: 1px solid #fcd34d; }
.badge-approved { background: #f3e8ff; color: #7e22ce; border: 1px solid #d8b4fe; }
.badge-paid, .badge-processed { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }

.btn-action-view {
	padding: 6px 12px;
	border-radius: 10px;
	background: #eff6ff;
	color: #1d4ed8;
	border: 1px solid #bfdbfe;
	font-size: 11.5px;
	font-weight: 700;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s;
}
.btn-action-view:hover {
	background: #2563eb;
	color: #ffffff;
	border-color: #2563eb;
	box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
}

.tfoot-summary-row {
	background: #f1f5f9;
	font-weight: 800;
	border-radius: 14px;
}
.tfoot-summary-row td {
	padding: 14px 16px;
	font-size: 13.5px;
	color: #0f172a;
}
</style>
</head>

<body>
<div class="app-wrapper">
	<!-- Unified Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Workspace -->
	<div class="main-content">

		<!-- Sticky Top Header Bar with Right Aligned Notification Bar -->
		<header class="top-header-bar">
			<div class="top-header-left">
				<div class="top-header-brand">
					<i class="fa-solid fa-money-check-dollar"></i>
					<span>Team Payroll Command Hub</span>
				</div>
				<div class="top-header-badge">
					<span class="live-pulse-dot"></span> DEPARTMENT OVERHEAD
				</div>
			</div>

			<div class="top-header-right">
				<!-- Period Selector Form -->
				<form method="get" action="${pageContext.request.contextPath}/teamPayroll" class="period-select-form">
					<i class="fa-solid fa-calendar-days" style="color: #2563eb;"></i>
					<select name="month" onchange="this.form.submit()">
						<% for (int m = 1; m <= 12; m++) { %>
						<option value="<%=m%>" <%=m == currentMonth ? "selected" : ""%>><%=Month.of(m).getDisplayName(TextStyle.FULL, Locale.ENGLISH)%></option>
						<% } %>
					</select>
					<select name="year" onchange="this.form.submit()">
						<% for (int y = 2024; y <= 2030; y++) { %>
						<option value="<%=y%>" <%=y == currentYear ? "selected" : ""%>><%=y%></option>
						<% } %>
					</select>
				</form>

				<div class="header-clock-pill">
					<i class="fa-regular fa-clock" style="color: #2563eb;"></i>
					<span id="topLiveClock">--:--:--</span>
				</div>

				<!-- Right Aligned Notification Bell Component -->
				<div class="topbar-notif-container">
					<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
				</div>
			</div>
		</header>

		<!-- Department Hero Banner -->
		<div class="hero-banner">
			<div class="hero-left">
				<div class="dept-pill-tag">
					<i class="fa-solid fa-building"></i> <%=department%> Department
				</div>
				<h1>Team Compensation & Payroll Audit</h1>
				<p>Monthly Disbursal, Statutory Deductions, and Net Retention Oversight for <%=currentMonthName%> <%=currentYear%></p>
			</div>

			<div class="hero-quick-stats">
				<div class="hero-stat-box">
					<small>Total Net Disbursable</small>
					<strong><%=currencyFmt.format(totalNet)%></strong>
				</div>
				<div class="hero-stat-box">
					<small>Team Retention</small>
					<strong><%=String.format(Locale.US, "%.1f", retentionRate)%>%</strong>
				</div>
			</div>
		</div>

		<!-- 4 Visualizer KPI Cards -->
		<div class="kpi-grid">
			<div class="kpi-card" style="border-left: 4px solid #10b981;">
				<div class="kpi-head">
					<span class="kpi-title">Net Disbursable</span>
					<div class="kpi-icon icon-emerald"><i class="fa-solid fa-coins"></i></div>
				</div>
				<div class="kpi-value" style="color: #059669;"><%=currencyFmt.format(totalNet)%></div>
				<div class="kpi-sub"><%=paidCount%> of <%=teamCount%> Paid Out</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #2563eb;">
				<div class="kpi-head">
					<span class="kpi-title">Gross Salary Budget</span>
					<div class="kpi-icon icon-blue"><i class="fa-solid fa-wallet"></i></div>
				</div>
				<div class="kpi-value" style="color: #1d4ed8;"><%=currencyFmt.format(totalGross)%></div>
				<div class="kpi-sub">Avg <%=currencyFmt.format(avgSalary)%>/member</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #f59e0b;">
				<div class="kpi-head">
					<span class="kpi-title">Department Personnel</span>
					<div class="kpi-icon icon-amber"><i class="fa-solid fa-users"></i></div>
				</div>
				<div class="kpi-value" style="color: #b45309;"><%=teamCount%> Members</div>
				<div class="kpi-sub"><%=department%> Team</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #ef4444;">
				<div class="kpi-head">
					<span class="kpi-title">Attendance LOP Deductions</span>
					<div class="kpi-icon icon-rose"><i class="fa-solid fa-user-minus"></i></div>
				</div>
				<div class="kpi-value" style="color: #dc2626;"><%=currencyFmt.format(totalLop)%></div>
				<div class="kpi-sub">Unpaid Leave Days Sum</div>
			</div>
		</div>

		<!-- Executive Team Summary Breakdown Card Panel -->
		<div class="white-card" style="margin-bottom: 28px; padding: 24px; background: #ffffff; border: 1px solid var(--border-color); border-radius: 24px; box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);">
			<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; padding-bottom: 12px; border-bottom: 1px solid #f1f5f9;">
				<h3 style="font-size: 16px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 10px;">
					<i class="fa-solid fa-chart-pie" style="color: #2563eb;"></i> Team Payroll Executive Summary (<%=department%> Department &bull; <%=currentMonthName%> <%=currentYear%>)
				</h3>
				<span style="font-size: 12px; font-weight: 800; color: #059669; background: #ecfdf5; border: 1px solid #a7f3d0; padding: 4px 12px; border-radius: 20px;">
					<i class="fa-solid fa-shield-check"></i> Audit Verified Summary
				</span>
			</div>

			<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 16px;">
				<div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 18px; padding: 18px; text-align: center;">
					<small style="display: block; font-size: 11px; font-weight: 800; color: #166534; text-transform: uppercase; margin-bottom: 6px;">Total Net Disbursable</small>
					<span style="font-size: 22px; font-weight: 800; color: #15803d; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(totalNet)%></span>
				</div>
				<div style="background: #eff6ff; border: 1px solid #bfdbfe; border-radius: 18px; padding: 18px; text-align: center;">
					<small style="display: block; font-size: 11px; font-weight: 800; color: #1e40af; text-transform: uppercase; margin-bottom: 6px;">Total Gross Budget</small>
					<span style="font-size: 22px; font-weight: 800; color: #1d4ed8; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(totalGross)%></span>
				</div>
				<div style="background: #fcf6e8; border: 1px solid #fde68a; border-radius: 18px; padding: 18px; text-align: center;">
					<small style="display: block; font-size: 11px; font-weight: 800; color: #92400e; text-transform: uppercase; margin-bottom: 6px;">Total Basic Base</small>
					<span style="font-size: 22px; font-weight: 800; color: #b45309; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(totalBasic)%></span>
				</div>
				<div style="background: #fff5f5; border: 1px solid #fca5a5; border-radius: 18px; padding: 18px; text-align: center;">
					<small style="display: block; font-size: 11px; font-weight: 800; color: #991b1b; text-transform: uppercase; margin-bottom: 6px;">Deductions &amp; LOP Sum</small>
					<span style="font-size: 22px; font-weight: 800; color: #dc2626; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(totalDeductions + totalLop)%></span>
				</div>
			</div>
		</div>

		<!-- Analytical Data Table Card -->
		<div class="table-card">

			<!-- Toolbar with Live Filter & Chips -->
			<div class="table-toolbar">
				<div class="search-filter-box">
					<i class="fa-solid fa-magnifying-glass"></i>
					<input type="text" id="payrollSearchInput" placeholder="Filter team member by name or ID..." onkeyup="filterPayrollTable()">
				</div>

				<div class="filter-chips-row">
					<button type="button" class="btn-filter-chip active" onclick="filterByStatus('ALL', this)">All (<%=teamCount%>)</button>
					<button type="button" class="btn-filter-chip" onclick="filterByStatus('PAID', this)">Paid</button>
					<button type="button" class="btn-filter-chip" onclick="filterByStatus('APPROVED', this)">Approved</button>
					<button type="button" class="btn-filter-chip" onclick="filterByStatus('CALCULATED', this)">Calculated</button>
				</div>
			</div>

			<table class="data-table" id="teamPayrollTable">
				<thead>
					<tr>
						<th>Employee</th>
						<th>Designation</th>
						<th>Basic Salary</th>
						<th>Gross Salary</th>
						<th>Attendance LOP</th>
						<th>Net Payable</th>
						<th>Status</th>
						<th>Action</th>
					</tr>
				</thead>
				<tbody>
					<%
					if (teamPayrolls != null && !teamPayrolls.isEmpty()) {
						for (Payroll p : teamPayrolls) {
							PayrollStatus sEnum = PayrollStatus.fromString(p.getStatus());
							String initial = p.getEmployeeName() != null && p.getEmployeeName().length() > 0 ? String.valueOf(p.getEmployeeName().charAt(0)).toUpperCase() : "E";
							String badgeCss = "badge-calculated";
							if ("PAID".equalsIgnoreCase(p.getStatus())) badgeCss = "badge-paid";
							else if ("APPROVED".equalsIgnoreCase(p.getStatus())) badgeCss = "badge-approved";
							else if ("PENDING_APPROVAL".equalsIgnoreCase(p.getStatus())) badgeCss = "badge-pending";
							
							String empNameClean = p.getEmployeeName() != null ? p.getEmployeeName() : "Employee #" + p.getEmployeeId();
					%>
					<tr data-status="<%=p.getStatus() != null ? p.getStatus().toUpperCase() : "CALCULATED"%>">
						<td>
							<div class="emp-avatar-cell">
								<div class="avatar-circle"><%=initial%></div>
								<div>
									<div class="emp-name-text" style="font-weight: 800; color: #0f172a;"><%=empNameClean%></div>
									<div style="font-size: 11px; color: #64748b;"><strong style="color: #2563eb;">EMP<%=String.format("%03d", p.getEmployeeId())%></strong></div>
								</div>
							</div>
						</td>
						<td><strong style="color: #334155;"><%=p.getDesignation() != null ? p.getDesignation() : "Team Member"%></strong></td>
						<td style="font-family: 'JetBrains Mono', monospace; font-weight: 600; color: #475569;"><%=currencyFmt.format(p.getBasicSalary())%></td>
						<td style="font-family: 'JetBrains Mono', monospace; font-weight: 700; color: #1d4ed8;"><%=currencyFmt.format(p.getGrossSalary())%></td>
						<td style="font-family: 'JetBrains Mono', monospace; color: #dc2626;"><%=currencyFmt.format(p.getUnpaidLeaveDeduction())%> (<%=p.getUnpaidLeaveDays()%>d)</td>
						<td><strong style="color: #059669; font-family: 'JetBrains Mono', monospace; font-size: 15px;"><%=currencyFmt.format(p.getNetSalary())%></strong></td>
						<td>
							<span class="badge-status <%=badgeCss%>">
								<i class="fa-solid fa-circle" style="font-size: 7px;"></i> <%=sEnum.getDisplayName()%>
							</span>
						</td>
						<td>
							<a href="payslip?payrollId=<%=p.getPayrollId()%>" class="btn-action-view" title="View Payslip Slip">
								<i class="fa-solid fa-file-invoice-dollar"></i> Payslip
							</a>
						</td>
					</tr>
					<%
						}
					} else {
					%>
					<tr id="emptyTableRow">
						<td colspan="8" style="text-align: center; padding: 40px; color: #64748b;">
							<i class="fa-solid fa-users-slash" style="font-size: 36px; margin-bottom: 12px; color: #94a3b8; display: block;"></i>
							No payroll records found for <%=department%> team for <%=currentMonthName%> <%=currentYear%>.
						</td>
					</tr>
					<% } %>
				</tbody>
				<% if (teamPayrolls != null && !teamPayrolls.isEmpty()) { %>
				<tfoot>
					<tr class="tfoot-summary-row" style="background: #1e293b; color: #ffffff; font-weight: 800;">
						<td colspan="2" style="border-top-left-radius: 16px; border-bottom-left-radius: 16px; color: #ffffff; padding: 18px 16px;">
							<div style="display: flex; align-items: center; gap: 8px;">
								<i class="fa-solid fa-calculator" style="color: #38bdf8; font-size: 16px;"></i>
								<span>Team Summary Total (<%=teamCount%> Members)</span>
							</div>
						</td>
						<td style="font-family: 'JetBrains Mono', monospace; color: #cbd5e1; font-weight: 700; padding: 18px 16px;"><%=currencyFmt.format(totalBasic)%></td>
						<td style="font-family: 'JetBrains Mono', monospace; color: #60a5fa; font-weight: 800; padding: 18px 16px;"><%=currencyFmt.format(totalGross)%></td>
						<td style="font-family: 'JetBrains Mono', monospace; color: #f87171; font-weight: 700; padding: 18px 16px;"><%=currencyFmt.format(totalLop)%></td>
						<td style="font-family: 'JetBrains Mono', monospace; color: #4ade80; font-weight: 800; font-size: 16px; padding: 18px 16px;"><%=currencyFmt.format(totalNet)%></td>
						<td colspan="2" style="border-top-right-radius: 16px; border-bottom-right-radius: 16px; text-align: right; padding: 18px 16px;">
							<span style="background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.2); color: #e2e8f0; padding: 4px 12px; border-radius: 20px; font-size: 11.5px;">
								<i class="fa-solid fa-circle-check" style="color: #4ade80; margin-right: 4px;"></i> <%=paidCount%>/<%=teamCount%> Disbursed
							</span>
						</td>
					</tr>
				</tfoot>
				<% } %>
			</table>
		</div>

	</div>
</div>

<script>
function updateClock() {
	const now = new Date();
	let hours = now.getHours();
	const minutes = String(now.getMinutes()).padStart(2, '0');
	const seconds = String(now.getSeconds()).padStart(2, '0');
	const ampm = hours >= 12 ? 'pm' : 'am';
	hours = hours % 12;
	hours = hours ? hours : 12;
	const hoursStr = String(hours).padStart(2, '0');

	const timeFormatted = hoursStr + ":" + minutes + ":" + seconds + " " + ampm;
	const topClockEl = document.getElementById("topLiveClock");
	if (topClockEl) topClockEl.innerText = timeFormatted;
}

updateClock();
setInterval(updateClock, 1000);

function filterPayrollTable() {
	var input = document.getElementById("payrollSearchInput");
	var filter = input.value.toUpperCase();
	var table = document.getElementById("teamPayrollTable");
	var tr = table.getElementsByTagName("tr");

	for (var i = 1; i < tr.length; i++) {
		var row = tr[i];
		if (row.id === "emptyTableRow" || row.parentElement.tagName === "TFOOT") continue;
		var txtValue = row.textContent || row.innerText;
		if (txtValue.toUpperCase().indexOf(filter) > -1) {
			row.style.display = "";
		} else {
			row.style.display = "none";
		}
	}
}

function filterByStatus(status, btn) {
	var chips = document.querySelectorAll(".btn-filter-chip");
	chips.forEach(function(c) { c.classList.remove("active"); });
	if (btn) btn.classList.add("active");

	var table = document.getElementById("teamPayrollTable");
	var tr = table.getElementsByTagName("tr");

	for (var i = 1; i < tr.length; i++) {
		var row = tr[i];
		if (row.id === "emptyTableRow" || row.parentElement.tagName === "TFOOT") continue;
		var rowStatus = row.getAttribute("data-status");
		if (status === "ALL" || (rowStatus && rowStatus.indexOf(status) > -1)) {
			row.style.display = "";
		} else {
			row.style.display = "none";
		}
	}
}
</script>
</body>
</html>
