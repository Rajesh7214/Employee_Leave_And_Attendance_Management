<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Payroll"%>
<%@ page import="com.rajesh.elams.model.PayrollSummary"%>
<%@ page import="com.rajesh.elams.model.PayrollStatus"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Set"%>
<%@ page import="java.util.TreeSet"%>
<%@ page import="java.time.Month"%>
<%@ page import="java.time.format.TextStyle"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.text.NumberFormat"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || (!"admin".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role) && !"manager".equalsIgnoreCase(role))) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String displayName = loggedUser != null && loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "User";
displayName = Character.toUpperCase(displayName.charAt(0)) + (displayName.length() > 1 ? displayName.substring(1) : "");
String activePage = "payrollDashboard";

List<Payroll> payrollList = (List<Payroll>) request.getAttribute("payrollList");
PayrollSummary summary = (PayrollSummary) request.getAttribute("payrollSummary");
List<Employee> allEmployees = (List<Employee>) request.getAttribute("allEmployees");

int currentMonth = request.getAttribute("currentMonth") != null ? (Integer) request.getAttribute("currentMonth") : 8;
int currentYear = request.getAttribute("currentYear") != null ? (Integer) request.getAttribute("currentYear") : 2026;
String statusFilter = (String) request.getAttribute("statusFilter");
if (statusFilter == null) statusFilter = "ALL";

String currentMonthName = Month.of(currentMonth).getDisplayName(TextStyle.FULL, Locale.ENGLISH);
NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

String sessionMessage = (String) session.getAttribute("message");
if (sessionMessage != null) {
	session.removeAttribute("message");
}

// Categorize records by status for count pills
int calcCount = 0, pendingCount = 0, approvedCount = 0, paidCount = 0, totalLopDaysCount = 0;
if (payrollList != null) {
	for (Payroll p : payrollList) {
		String st = p.getStatus() != null ? p.getStatus().toUpperCase() : "";
		if ("PENDING_APPROVAL".equals(st)) pendingCount++;
		else if ("APPROVED".equals(st)) approvedCount++;
		else if ("PAID".equals(st)) paidCount++;
		else calcCount++;

		totalLopDaysCount += p.getUnpaidLeaveDays();
	}
}

// Financial Totals and Headcount Calculation
double totalGross = summary != null ? summary.getTotalGrossAmount() : 0.0;
double totalNet = summary != null ? summary.getTotalNetAmount() : 0.0;
double totalLop = summary != null ? summary.getTotalLopDeductionsAmount() : 0.0;

int totalEmpCount = allEmployees != null ? allEmployees.size() : (summary != null ? summary.getTotalEmployees() : 0);
int processedCount = (calcCount + pendingCount + approvedCount + paidCount);
if (totalEmpCount < processedCount) {
	totalEmpCount = processedCount;
}
int processedPct = totalEmpCount > 0 ? Math.min(100, (int) Math.round(((double) processedCount / totalEmpCount) * 100.0)) : 0;
int paidPct = processedCount > 0 ? Math.min(100, (int) Math.round(((double) paidCount / processedCount) * 100.0)) : 0;

// Unique departments list
Set<String> departments = new TreeSet<>();
if (allEmployees != null) {
	for (Employee e : allEmployees) {
		if (e.getDepartment() != null && !e.getDepartment().isBlank()) {
			departments.add(e.getDepartment());
		}
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Executive Payroll Command Hub | RChips Solutions ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<style>
:root {
	--blue-primary: #2563eb;
	--blue-dark: #1d4ed8;
	--blue-light: #eff6ff;
	--emerald-primary: #10b981;
	--emerald-dark: #059669;
	--amber-primary: #f59e0b;
	--rose-primary: #f43f5e;
	--purple-primary: #8b5cf6;
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
	padding: 28px 34px;
	overflow-y: auto;
	background: radial-gradient(circle at 10% 10%, rgba(37, 99, 235, 0.05) 0%, transparent 45%),
	            linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

.white-card {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 20px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

/* Header Navbar Banner */
.top-header-banner {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 24px;
	flex-wrap: wrap;
	gap: 16px;
	background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
	border: 1px solid var(--border-color);
	border-radius: 24px;
	padding: 22px 28px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.header-title-block h1 {
	font-size: 25px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 12px;
	letter-spacing: -0.5px;
}
.header-title-block p { font-size: 13.5px; color: var(--text-secondary); margin-top: 4px; font-weight: 500; }

.header-actions-group {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
}

.month-selector-form {
	display: flex;
	align-items: center;
	gap: 8px;
	background: linear-gradient(135deg, #eff6ff, #dbeafe);
	padding: 8px 16px;
	border-radius: 14px;
	border: 1px solid #bfdbfe;
	box-shadow: 0 2px 8px rgba(37, 99, 235, 0.08);
}
.month-selector-form select {
	background: transparent;
	color: #1e40af;
	border: none;
	outline: none;
	font-weight: 800;
	font-size: 13.5px;
	cursor: pointer;
}

/* Toast Alert */
.alert-toast {
	background: linear-gradient(135deg, #10b981 0%, #059669 100%);
	color: #ffffff;
	padding: 14px 22px;
	border-radius: 16px;
	margin-bottom: 24px;
	font-weight: 700;
	font-size: 14px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 6px 20px rgba(16, 185, 129, 0.35);
}

/* 4 Executive Financial Metrics Cards */
.fin-metrics-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
	gap: 20px;
	margin-bottom: 24px;
}
.fin-metric-card {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 20px;
	padding: 22px 24px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 6px 20px rgba(15, 23, 42, 0.03);
	transition: all 0.25s ease;
	position: relative;
	overflow: hidden;
}
.fin-metric-card:hover { transform: translateY(-3px); box-shadow: 0 12px 28px rgba(37, 99, 235, 0.12); }

.fin-metric-card small { display: block; font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
.fin-metric-card span { font-size: 24px; font-weight: 800; font-family: 'JetBrains Mono', monospace; }
.fin-metric-icon { width: 48px; height: 48px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 20px; color: white; box-shadow: 0 4px 14px rgba(0, 0, 0, 0.15); }

/* Lifecycle Visual Distribution Bar */
.payroll-flow-banner {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 20px;
	padding: 20px 24px;
	margin-bottom: 28px;
	box-shadow: 0 6px 20px rgba(15, 23, 42, 0.03);
}
.flow-banner-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.flow-banner-header h3 { font-size: 14px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px; }

.multi-progress-bar {
	height: 12px;
	border-radius: 20px;
	background: #f1f5f9;
	display: flex;
	overflow: hidden;
	margin-bottom: 12px;
}
.prog-seg { height: 100%; transition: width 0.4s ease; }
.seg-calc { background: #3b82f6; }
.seg-pending { background: #f59e0b; }
.seg-approved { background: #8b5cf6; }
.seg-paid { background: #10b981; }

.flow-legend-row { display: flex; gap: 18px; flex-wrap: wrap; }
.legend-item { display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: #475569; }
.dot-legend { width: 10px; height: 10px; border-radius: 50%; display: inline-block; }

/* 2-COLUMN SPLIT DASHBOARD LAYOUT */
.split-dashboard-container {
	display: grid;
	grid-template-columns: 340px 1fr;
	gap: 24px;
	align-items: start;
}
@media (max-width: 1100px) {
	.split-dashboard-container { grid-template-columns: 1fr; }
}

/* LEFT CONTROL PANEL */
.left-control-panel { display: flex; flex-direction: column; gap: 20px; }

/* Vertical Lifecycle Stepper */
.vertical-stepper { padding: 22px; }
.v-step-item { display: flex; align-items: center; gap: 14px; margin-bottom: 16px; position: relative; cursor: pointer; transition: all 0.2s; }
.v-step-item:last-child { margin-bottom: 0; }
.v-step-icon {
	width: 38px;
	height: 38px;
	border-radius: 12px;
	background: #f1f5f9;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 14px;
	color: var(--text-secondary);
	border: 1px solid var(--border-color);
	transition: all 0.2s;
}
.v-step-item.completed .v-step-icon { background: #10b981; color: white; border-color: #10b981; }
.v-step-item.active .v-step-icon { background: var(--blue-primary); color: white; border-color: var(--blue-primary); box-shadow: 0 0 14px rgba(37, 99, 235, 0.45); }
.v-step-label { font-size: 13px; font-weight: 800; color: #0f172a; }
.v-step-sub { font-size: 11.5px; color: var(--text-secondary); font-weight: 700; margin-top: 1px; }

/* Action Buttons Group */
.action-buttons-group { display: flex; flex-direction: column; gap: 10px; }

.btn-action {
	padding: 13px 20px;
	border-radius: 14px;
	font-size: 13.5px;
	font-weight: 800;
	border: none;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
	transition: all 0.25s ease;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
	width: 100%;
}
.btn-primary { background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; }
.btn-primary:hover { transform: translateY(-2px); box-shadow: 0 6px 22px rgba(37, 99, 235, 0.45); }
.btn-success { background: linear-gradient(135deg, #10b981, #059669); color: white; }
.btn-success:hover { transform: translateY(-2px); box-shadow: 0 6px 22px rgba(16, 185, 129, 0.45); }
.btn-warning { background: linear-gradient(135deg, #f59e0b, #d97706); color: white; }
.btn-warning:hover { transform: translateY(-2px); box-shadow: 0 6px 22px rgba(245, 158, 11, 0.45); }
.btn-outline { background: #ffffff; color: var(--blue-primary); border: 1.5px solid #bfdbfe; }
.btn-outline:hover { background: var(--blue-light); border-color: var(--blue-primary); transform: translateY(-1px); }

/* RIGHT PAYROLL FEED PANEL */
.right-feed-panel { display: flex; flex-direction: column; gap: 20px; }

.feed-toolbar { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 16px; }

.status-chips { display: flex; background: #ffffff; padding: 5px; border-radius: 16px; gap: 5px; border: 1px solid var(--border-color); flex-wrap: wrap; box-shadow: 0 4px 14px rgba(15, 23, 42, 0.03); }
.chip-btn { padding: 8px 16px; border-radius: 12px; font-size: 12px; font-weight: 800; color: var(--text-secondary); border: none; background: transparent; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 6px; }
.chip-btn.active { background: var(--blue-primary); color: white; box-shadow: 0 4px 14px rgba(37, 99, 235, 0.35); }
.chip-count { background: rgba(0, 0, 0, 0.08); padding: 2px 8px; border-radius: 10px; font-size: 10.5px; font-weight: 800; }
.chip-btn.active .chip-count { background: rgba(255, 255, 255, 0.25); color: white; }

.toolbar-controls-right { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

.view-mode-toggle { display: flex; background: #ffffff; border: 1px solid var(--border-color); border-radius: 12px; padding: 3px; }
.btn-view-mode { padding: 6px 12px; border-radius: 9px; border: none; background: transparent; color: #64748b; font-size: 13px; cursor: pointer; transition: all 0.2s; }
.btn-view-mode.active { background: #2563eb; color: #ffffff; font-weight: 700; box-shadow: 0 2px 8px rgba(37, 99, 235, 0.3); }

.search-input-box { position: relative; width: 240px; }
.search-input-box input { width: 100%; padding: 9px 14px 9px 36px; border-radius: 12px; background: #ffffff; border: 1px solid var(--border-color); color: #0f172a; outline: none; font-size: 12.5px; font-weight: 600; }
.search-input-box input:focus { border-color: var(--blue-primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); }
.search-input-box i { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #64748b; font-size: 12px; }

/* PAYROLL FEED CARDS */
.feed-cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 18px; }

.payroll-feed-card {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 20px;
	padding: 20px;
	transition: all 0.25s ease;
	position: relative;
	box-shadow: 0 4px 16px rgba(15, 23, 42, 0.04);
}
.payroll-feed-card:hover {
	transform: translateY(-3px);
	border-color: #3b82f6;
	box-shadow: 0 12px 28px rgba(37, 99, 235, 0.14);
}

.card-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
.card-user-info { display: flex; align-items: center; gap: 12px; }
.avatar-box { width: 42px; height: 42px; border-radius: 12px; background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 15px; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }

.card-name { font-size: 14px; font-weight: 800; color: #0f172a; line-height: 1.2; }
.card-meta { font-size: 11.5px; color: #64748b; font-weight: 700; margin-top: 3px; }
.dept-badge { background: var(--blue-light); color: var(--blue-dark); padding: 2px 8px; border-radius: 6px; font-size: 10.5px; font-weight: 700; }

.badge-status { padding: 5px 12px; border-radius: 20px; font-size: 10.5px; font-weight: 800; display: inline-flex; align-items: center; gap: 6px; text-transform: uppercase; letter-spacing: 0.3px; }
.badge-draft { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
.badge-calculated { background: #e0f2fe; color: #0369a1; border: 1px solid #7dd3fc; }
.badge-pending { background: #fef3c7; color: #b45309; border: 1px solid #fcd34d; }
.badge-approved { background: #f3e8ff; color: #7e22ce; border: 1px solid #d8b4fe; }
.badge-paid, .badge-processed { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }

.card-financial-box {
	background: #f8fafc;
	border: 1px solid var(--border-color);
	border-radius: 14px;
	padding: 12px 14px;
	margin-bottom: 14px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}
.fin-item small { display: block; font-size: 10px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 3px; }
.fin-item strong { font-size: 16px; font-family: 'JetBrains Mono', monospace; }

.card-actions-row { display: flex; align-items: center; justify-content: space-between; gap: 8px; padding-top: 10px; border-top: 1px solid var(--border-color); }
.btn-card-action { padding: 6px 12px; border-radius: 10px; font-size: 11.5px; font-weight: 700; border: none; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; gap: 5px; }

/* MASTER DATA TABLE VIEW */
.master-table-card {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 20px;
	box-shadow: 0 6px 20px rgba(15, 23, 42, 0.03);
	overflow: hidden;
	display: none;
}
.master-payroll-table { width: 100%; border-collapse: collapse; text-align: left; }
.master-payroll-table th { background: #f8fafc; padding: 14px 18px; font-size: 11.5px; font-weight: 800; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; border-bottom: 1px solid var(--border-color); }
.master-payroll-table td { padding: 14px 18px; border-bottom: 1px solid #f1f5f9; font-size: 13.5px; vertical-align: middle; }
.master-payroll-table tr:hover td { background: #f8fafc; }

.empty-feed-card { grid-column: 1 / -1; padding: 50px 20px; text-align: center; color: var(--text-secondary); background: #ffffff; }

/* Modal Base */
.modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(8px); display: none; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
.modal-overlay.active { display: flex; }
.modal-card { background: #ffffff; border: 1px solid var(--border-color); border-radius: 24px; padding: 28px; width: 100%; max-width: 620px; box-shadow: 0 25px 60px rgba(15, 23, 42, 0.25); }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
.modal-header h3 { font-size: 19px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 10px; }
.modal-close { background: transparent; border: none; color: #94a3b8; font-size: 22px; cursor: pointer; }

.modal-nav-tabs { display: flex; background: #f1f5f9; padding: 4px; border-radius: 12px; gap: 4px; margin-bottom: 20px; }
.modal-tab-btn { flex: 1; text-align: center; padding: 8px 12px; border-radius: 10px; font-size: 12.5px; font-weight: 800; color: var(--text-secondary); border: none; background: transparent; cursor: pointer; transition: all 0.2s; }
.modal-tab-btn.active { background: var(--blue-primary); color: white; box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }

.calc-preview-card { background: var(--blue-light); border: 1px solid #bfdbfe; border-radius: 16px; padding: 16px 20px; margin-bottom: 20px; }
.calc-preview-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
.calc-preview-user { display: flex; align-items: center; gap: 12px; }
.calc-preview-avatar { width: 38px; height: 38px; border-radius: 10px; background: linear-gradient(135deg, var(--blue-primary), var(--blue-dark)); color: white; font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 15px; }

.calc-preview-stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; background: #ffffff; border-radius: 12px; padding: 10px 12px; border: 1px solid var(--border-color); text-align: center; }
.calc-preview-stats small { display: block; font-size: 10px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; margin-bottom: 2px; }
.calc-preview-stats span { font-size: 14.5px; font-weight: 800; font-family: 'JetBrains Mono', monospace; }

.audit-step-card { background: #f8fafc; border: 1px solid var(--border-color); border-radius: 14px; padding: 14px 18px; margin-bottom: 12px; }
.audit-step-title { font-size: 12px; font-weight: 800; color: var(--blue-primary); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; display: flex; justify-content: space-between; }
.audit-step-row { display: flex; justify-content: space-between; font-size: 13px; color: #334155; margin-bottom: 4px; }
.audit-step-row strong { font-family: 'JetBrains Mono', monospace; color: #0f172a; }
</style>
</head>

<body>
<div class="app-wrapper">

	<!-- Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Area -->
	<div class="main-content">

		<!-- Integrated SmartOffice Notification Bar Component -->
		<div style="display: flex; justify-content: flex-end; margin-bottom: 14px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf"%>
		</div>

		<!-- Toast Message -->
		<% if (sessionMessage != null) { %>
		<div class="alert-toast">
			<span><i class="fa-solid fa-circle-check" style="margin-right: 8px;"></i> <%=sessionMessage%></span>
			<i class="fa-solid fa-xmark" style="cursor: pointer;" onclick="this.parentElement.style.display='none'"></i>
		</div>
		<% } %>

		<!-- Executive Top Header Banner -->
		<div class="top-header-banner">
			<div class="header-title-block">
				<h1><i class="fa-solid fa-money-check-dollar" style="color: #2563eb;"></i> Executive Payroll Command Hub</h1>
				<p>Monthly salary processing, attendance LOP audit, and executive disbursals for <strong><%=currentMonthName%> <%=currentYear%></strong></p>
			</div>

			<div class="header-actions-group">
				<!-- Month/Year Selector -->
				<form action="${pageContext.request.contextPath}/payrollDashboard" method="get" class="month-selector-form">
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

				<a href="${pageContext.request.contextPath}/manageSalary" class="btn-action btn-outline" style="width: auto; padding: 9px 18px;">
					<i class="fa-solid fa-gears"></i> Salary Structures
				</a>
				<a href="${pageContext.request.contextPath}/payrollReport?month=<%=currentMonth%>&year=<%=currentYear%>" class="btn-action btn-primary" style="width: auto; padding: 9px 18px;">
					<i class="fa-solid fa-chart-column"></i> Analytical Report
				</a>
			</div>
		</div>

		<!-- 4 Executive Financial Metric Cards -->
		<div class="fin-metrics-grid">
			<div class="fin-metric-card" style="border-left: 5px solid #10b981;">
				<div>
					<small>Disbursable Net Payroll</small>
					<span style="color: #059669;"><%=currencyFmt.format(totalNet)%></span>
					<div style="font-size: 11px; color: #10b981; font-weight: 700; margin-top: 4px;"><i class="fa-solid fa-circle-check"></i> <%=paidPct%>% Salaries Disbursed</div>
				</div>
				<div class="fin-metric-icon" style="background: linear-gradient(135deg, #10b981, #059669);"><i class="fa-solid fa-coins"></i></div>
			</div>

			<div class="fin-metric-card" style="border-left: 5px solid #2563eb;">
				<div>
					<small>Gross Salary Budget</small>
					<span style="color: #1d4ed8;"><%=currencyFmt.format(totalGross)%></span>
					<div style="font-size: 11px; color: #2563eb; font-weight: 700; margin-top: 4px;"><i class="fa-solid fa-wallet"></i> Gross Allocation</div>
				</div>
				<div class="fin-metric-icon" style="background: linear-gradient(135deg, #2563eb, #1d4ed8);"><i class="fa-solid fa-wallet"></i></div>
			</div>

			<div class="fin-metric-card" style="border-left: 5px solid #f59e0b;">
				<div>
					<small>Processed Personnel</small>
					<span style="color: #b45309;"><%=processedCount%> / <%=totalEmpCount%></span>
					<div style="font-size: 11px; color: #d97706; font-weight: 700; margin-top: 4px;"><i class="fa-solid fa-users"></i> <%=processedPct%>% Headcount Complete</div>
				</div>
				<div class="fin-metric-icon" style="background: linear-gradient(135deg, #f59e0b, #d97706);"><i class="fa-solid fa-users"></i></div>
			</div>

			<div class="fin-metric-card" style="border-left: 5px solid #ef4444;">
				<div>
					<small>Attendance LOP Deductions</small>
					<span style="color: #dc2626;"><%=currencyFmt.format(totalLop)%></span>
					<div style="font-size: 11px; color: #ef4444; font-weight: 700; margin-top: 4px;"><i class="fa-solid fa-user-minus"></i> <%=totalLopDaysCount%> Days Total LOP</div>
				</div>
				<div class="fin-metric-icon" style="background: linear-gradient(135deg, #ef4444, #dc2626);"><i class="fa-solid fa-user-minus"></i></div>
			</div>
		</div>

		<!-- Lifecycle Visual Distribution Bar -->
		<div class="payroll-flow-banner">
			<div class="flow-banner-header">
				<h3><i class="fa-solid fa-sliders" style="color: #2563eb;"></i> Payroll Processing Distribution &amp; Status Pipeline</h3>
				<span style="font-size: 12px; font-weight: 700; color: #64748b;"><%=processedCount%> of <%=totalEmpCount%> Processed</span>
			</div>
			
			<div class="multi-progress-bar">
				<div class="prog-seg seg-calc" style="width: <%= totalEmpCount > 0 ? (calcCount * 100.0 / totalEmpCount) : 0 %>%;" title="Calculated: <%=calcCount%>"></div>
				<div class="prog-seg seg-pending" style="width: <%= totalEmpCount > 0 ? (pendingCount * 100.0 / totalEmpCount) : 0 %>%;" title="Pending HR: <%=pendingCount%>"></div>
				<div class="prog-seg seg-approved" style="width: <%= totalEmpCount > 0 ? (approvedCount * 100.0 / totalEmpCount) : 0 %>%;" title="Approved: <%=approvedCount%>"></div>
				<div class="prog-seg seg-paid" style="width: <%= totalEmpCount > 0 ? (paidCount * 100.0 / totalEmpCount) : 0 %>%;" title="Paid: <%=paidCount%>"></div>
			</div>

			<div class="flow-legend-row">
				<div class="legend-item"><span class="dot-legend" style="background: #3b82f6;"></span> Calculated (<%=calcCount%>)</div>
				<div class="legend-item"><span class="dot-legend" style="background: #f59e0b;"></span> Pending HR Approval (<%=pendingCount%>)</div>
				<div class="legend-item"><span class="dot-legend" style="background: #8b5cf6;"></span> Executive Approved (<%=approvedCount%>)</div>
				<div class="legend-item"><span class="dot-legend" style="background: #10b981;"></span> Disbursed &amp; Paid (<%=paidCount%>)</div>
			</div>
		</div>

		<!-- 2-COLUMN SPLIT DASHBOARD LAYOUT -->
		<div class="split-dashboard-container">

			<!-- LEFT CONTROL & FINANCIAL PANEL -->
			<div class="left-control-panel">

				<!-- Vertical Stepper Pipeline -->
				<div class="white-card vertical-stepper">
					<h3 style="font-size: 13.5px; font-weight: 800; color: #1e40af; margin-bottom: 16px;"><i class="fa-solid fa-diagram-project"></i> Workflow Lifecycle</h3>
					
					<div class="v-step-item <%= calcCount > 0 ? "completed" : "active" %>" onclick="filterStatus('CALCULATED')">
						<div class="v-step-icon"><i class="fa-solid fa-calculator"></i></div>
						<div><div class="v-step-label">1. Batch Calculation</div><div class="v-step-sub"><%=calcCount%> Personnel Calculated</div></div>
					</div>
					<div class="v-step-item <%= totalLop > 0 ? "completed" : "active" %>" onclick="filterStatus('ALL')">
						<div class="v-step-icon"><i class="fa-solid fa-user-minus"></i></div>
						<div><div class="v-step-label">2. Attendance LOP Audit</div><div class="v-step-sub"><%=currencyFmt.format(totalLop)%> Deducted</div></div>
					</div>
					<div class="v-step-item <%= pendingCount > 0 ? "active" : (approvedCount > 0 || paidCount > 0 ? "completed" : "") %>" onclick="filterStatus('PENDING_APPROVAL')">
						<div class="v-step-icon"><i class="fa-solid fa-paper-plane"></i></div>
						<div><div class="v-step-label">3. HR Approval Queue</div><div class="v-step-sub"><%=pendingCount%> Pending Approval</div></div>
					</div>
					<div class="v-step-item <%= approvedCount > 0 ? "active" : (paidCount > 0 ? "completed" : "") %>" onclick="filterStatus('APPROVED')">
						<div class="v-step-icon"><i class="fa-solid fa-stamp"></i></div>
						<div><div class="v-step-label">4. Executive Stamp</div><div class="v-step-sub"><%=approvedCount%> Approved</div></div>
					</div>
					<div class="v-step-item <%= paidCount > 0 && paidCount == totalEmpCount ? "completed" : (paidCount > 0 ? "active" : "") %>" onclick="filterStatus('PAID')">
						<div class="v-step-icon"><i class="fa-solid fa-wallet"></i></div>
						<div><div class="v-step-label">5. Disbursed Payout</div><div class="v-step-sub"><%=paidCount%> Paid</div></div>
					</div>
				</div>

				<!-- Workflow Quick Action Buttons -->
				<div class="action-buttons-group">
					<button type="button" onclick="openSingleCalcModal()" class="btn-action btn-primary">
						<i class="fa-solid fa-user-gear"></i> Calculate Employee Salary
					</button>

					<form action="${pageContext.request.contextPath}/processPayroll" method="post">
						<input type="hidden" name="action" value="calculateBatch">
						<input type="hidden" name="month" value="<%=currentMonth%>">
						<input type="hidden" name="year" value="<%=currentYear%>">
						<button type="submit" class="btn-action btn-outline" onclick="return confirm('Run batch calculation for all active personnel for <%=currentMonthName%> <%=currentYear%>?');">
							<i class="fa-solid fa-bolt" style="color: #2563eb;"></i> Run Batch Calculation
						</button>
					</form>

					<% if (calcCount > 0) { %>
					<form action="${pageContext.request.contextPath}/processPayroll" method="post">
						<input type="hidden" name="action" value="submitApproval">
						<input type="hidden" name="month" value="<%=currentMonth%>">
						<input type="hidden" name="year" value="<%=currentYear%>">
						<button type="submit" class="btn-action btn-warning">
							<i class="fa-solid fa-paper-plane"></i> Submit All HR (<%=calcCount%>)
						</button>
					</form>
					<% } %>

					<% if (pendingCount > 0 || calcCount > 0) { %>
					<form action="${pageContext.request.contextPath}/processPayroll" method="post">
						<input type="hidden" name="action" value="approveMonth">
						<input type="hidden" name="month" value="<%=currentMonth%>">
						<input type="hidden" name="year" value="<%=currentYear%>">
						<button type="submit" class="btn-action btn-success" onclick="return confirm('Grant Executive Approval for monthly payroll?');">
							<i class="fa-solid fa-stamp"></i> Executive Approve All
						</button>
					</form>
					<% } %>

					<% if (approvedCount > 0) { %>
					<form action="${pageContext.request.contextPath}/processPayroll" method="post">
						<input type="hidden" name="action" value="processPayment">
						<input type="hidden" name="month" value="<%=currentMonth%>">
						<input type="hidden" name="year" value="<%=currentYear%>">
						<button type="submit" class="btn-action btn-success" style="background: linear-gradient(135deg, #059669, #047857);" onclick="return confirm('Disburse final salaries for approved personnel?');">
							<i class="fa-solid fa-wallet"></i> Disburse Payments (<%=approvedCount%>)
						</button>
					</form>
					<% } %>

					<div style="display: flex; gap: 10px;">
						<a href="${pageContext.request.contextPath}/exportPayroll?month=<%=currentMonth%>&year=<%=currentYear%>" class="btn-action btn-outline" style="flex: 1;" title="Export CSV">
							<i class="fa-solid fa-file-csv"></i> Export CSV
						</a>
					</div>
				</div>

			</div>

			<!-- RIGHT PAYROLL FEED PANEL -->
			<div class="right-feed-panel">

				<!-- Toolbar -->
				<div class="feed-toolbar">
					<div class="status-chips">
						<button class="chip-btn <%= "ALL".equals(statusFilter) ? "active" : "" %>" onclick="filterStatus('ALL')">
							All <span class="chip-count"><%=payrollList != null ? payrollList.size() : 0%></span>
						</button>
						<button class="chip-btn <%= "CALCULATED".equals(statusFilter) ? "active" : "" %>" onclick="filterStatus('CALCULATED')">
							Calculated <span class="chip-count"><%=calcCount%></span>
						</button>
						<button class="chip-btn <%= "PENDING_APPROVAL".equals(statusFilter) ? "active" : "" %>" onclick="filterStatus('PENDING_APPROVAL')">
							Pending HR <span class="chip-count"><%=pendingCount%></span>
						</button>
						<button class="chip-btn <%= "APPROVED".equals(statusFilter) ? "active" : "" %>" onclick="filterStatus('APPROVED')">
							Approved <span class="chip-count"><%=approvedCount%></span>
						</button>
						<button class="chip-btn <%= "PAID".equals(statusFilter) ? "active" : "" %>" onclick="filterStatus('PAID')">
							Paid <span class="chip-count"><%=paidCount%></span>
						</button>
					</div>

					<div class="toolbar-controls-right">
						<!-- View Mode Toggle -->
						<div class="view-mode-toggle">
							<button type="button" id="btnGridMode" class="btn-view-mode active" onclick="switchViewMode('grid')" title="Grid Cards View"><i class="fa-solid fa-grip"></i> Grid</button>
							<button type="button" id="btnTableMode" class="btn-view-mode" onclick="switchViewMode('table')" title="Master Data Table View"><i class="fa-solid fa-table"></i> Table</button>
						</div>

						<div class="search-input-box">
							<i class="fa-solid fa-magnifying-glass"></i>
							<input type="text" id="feedSearchInput" onkeyup="searchFeed()" placeholder="Search name, ID, dept..." />
						</div>
					</div>
				</div>

				<!-- Payroll Feed Grid View -->
				<div class="feed-cards-grid" id="payrollFeedGrid">
					<%
					if (payrollList != null && !payrollList.isEmpty()) {
						int renderCount = 0;
						for (Payroll p : payrollList) {
							if (!"ALL".equals(statusFilter) && !statusFilter.equalsIgnoreCase(p.getStatus())) {
								continue;
							}
							renderCount++;
							PayrollStatus statusEnum = PayrollStatus.fromString(p.getStatus());
							String initial = p.getEmployeeName() != null && p.getEmployeeName().length() > 0 ? String.valueOf(p.getEmployeeName().charAt(0)).toUpperCase() : "E";
					%>
					<div class="payroll-feed-card" data-search="<%= (p.getEmployeeName() + " " + p.getDepartment() + " EMP" + String.format("%03d", p.getEmployeeId())).toLowerCase() %>">
						<div class="card-top">
							<div class="card-user-info">
								<div class="avatar-box"><%=initial%></div>
								<div>
									<div class="card-name"><%=p.getEmployeeName() != null ? p.getEmployeeName() : "Employee #" + p.getEmployeeId()%></div>
									<div class="card-meta">
										<strong style="color: #2563eb;">EMP<%=String.format("%03d", p.getEmployeeId())%></strong> &bull; <span class="dept-badge"><%=p.getDepartment() != null ? p.getDepartment() : "General"%></span>
									</div>
								</div>
							</div>
							<span class="badge-status <%=statusEnum.getCssClass()%>">
								<i class="fa-solid fa-circle" style="font-size: 7px;"></i> <%=statusEnum.getDisplayName()%>
							</span>
						</div>

						<div class="card-financial-box">
							<div class="fin-item">
								<small>Gross Salary</small>
								<strong style="color: #334155;"><%=currencyFmt.format(p.getGrossSalary())%></strong>
							</div>
							<div class="fin-item" style="text-align: right;">
								<small style="color: #059669;">Net Payable</small>
								<strong style="color: #059669;"><%=currencyFmt.format(p.getNetSalary())%></strong>
							</div>
						</div>

						<% if (p.getUnpaidLeaveDays() > 0) { %>
						<div style="margin-bottom: 12px; font-size: 11.5px; color: #dc2626; background: #fee2e2; padding: 6px 12px; border-radius: 10px; font-weight: 700; display: flex; justify-content: space-between; border: 1px solid #fecaca;">
							<span><i class="fa-solid fa-user-minus"></i> Attendance LOP:</span>
							<strong><%=currencyFmt.format(p.getUnpaidLeaveDeduction())%> (<%=p.getUnpaidLeaveDays()%>d)</strong>
						</div>
						<% } %>

						<div class="card-actions-row">
							<button type="button" class="btn-card-action btn-outline" style="color: #2563eb;" 
							        onclick="inspectPayrollMath('<%=p.getEmployeeName()%>', 'EMP<%=String.format("%03d", p.getEmployeeId())%>', '<%=currencyFmt.format(p.getBasicSalary())%>', '<%=currencyFmt.format(p.getHra() + p.getTransportAllowance() + p.getMedicalAllowance() + p.getOtherAllowances() + p.getBonus())%>', '<%=currencyFmt.format(p.getGrossSalary())%>', '<%=p.getWorkingDays()%>', '<%=p.getUnpaidLeaveDays()%>', '<%=currencyFmt.format(p.getBasicSalary() / (p.getWorkingDays() > 0 ? p.getWorkingDays() : 26))%>', '<%=currencyFmt.format(p.getUnpaidLeaveDeduction())%>', '<%=currencyFmt.format(p.getPf() + p.getProfessionalTax() + p.getLoanDeduction() + p.getAdvanceSalary() + p.getOtherDeductions())%>', '<%=currencyFmt.format(p.getTotalDeductions())%>', '<%=currencyFmt.format(p.getNetSalary())%>')" title="Inspect Math Calculation">
								<i class="fa-solid fa-square-poll-vertical"></i> Inspect Math
							</button>

							<a href="${pageContext.request.contextPath}/payslip?id=<%=p.getPayrollId()%>" class="btn-card-action btn-outline" title="View Payslip">
								<i class="fa-solid fa-file-invoice"></i> Payslip
							</a>

							<% if (!"APPROVED".equalsIgnoreCase(p.getStatus()) && !"PAID".equalsIgnoreCase(p.getStatus())) { %>
							<form action="${pageContext.request.contextPath}/processPayroll" method="post" style="display:inline;">
								<input type="hidden" name="action" value="updateStatus">
								<input type="hidden" name="payrollId" value="<%=p.getPayrollId()%>">
								<input type="hidden" name="status" value="APPROVED">
								<input type="hidden" name="month" value="<%=p.getMonth()%>">
								<input type="hidden" name="year" value="<%=p.getYear()%>">
								<button type="submit" class="btn-card-action btn-success" title="Approve Employee Salary">
									<i class="fa-solid fa-check"></i> Approve
								</button>
							</form>
							<% } else if ("APPROVED".equalsIgnoreCase(p.getStatus())) { %>
							<form action="${pageContext.request.contextPath}/processPayroll" method="post" style="display:inline;">
								<input type="hidden" name="action" value="updateStatus">
								<input type="hidden" name="payrollId" value="<%=p.getPayrollId()%>">
								<input type="hidden" name="status" value="PAID">
								<input type="hidden" name="month" value="<%=p.getMonth()%>">
								<input type="hidden" name="year" value="<%=p.getYear()%>">
								<button type="submit" class="btn-card-action btn-success" style="background: linear-gradient(135deg, #059669, #047857);" title="Mark Salary Paid">
									<i class="fa-solid fa-wallet"></i> Pay
								</button>
							</form>
							<% } %>
						</div>
					</div>
					<%
						}
						if (renderCount == 0) {
					%>
					<div class="white-card empty-feed-card">
						<i class="fa-solid fa-calculator" style="font-size: 36px; margin-bottom: 14px; display: block; color: #94a3b8;"></i>
						No payroll records matching filter <strong><%=statusFilter%></strong> for <%=currentMonthName%> <%=currentYear%>.<br/>
						Click <strong>Calculate Employee Salary</strong> or <strong>Run Batch Calculation</strong> on the left panel.
					</div>
					<%
						}
					} else {
					%>
					<div class="white-card empty-feed-card">
						<i class="fa-solid fa-calculator" style="font-size: 36px; margin-bottom: 14px; display: block; color: #94a3b8;"></i>
						No payroll records calculated for <%=currentMonthName%> <%=currentYear%> yet.<br/>
						Click <strong>Calculate Employee Salary</strong> or <strong>Run Batch Calculation</strong> on the left panel.
					</div>
					<% } %>
				</div>

				<!-- Master Data Table View -->
				<div class="master-table-card" id="payrollMasterTableCard">
					<table class="master-payroll-table">
						<thead>
							<tr>
								<th>Employee</th>
								<th>Code</th>
								<th>Department</th>
								<th>Gross Salary</th>
								<th>LOP Days / Ded</th>
								<th>Net Payable</th>
								<th>Status</th>
								<th>Actions</th>
							</tr>
						</thead>
						<tbody id="masterTableBody">
							<%
							if (payrollList != null && !payrollList.isEmpty()) {
								for (Payroll p : payrollList) {
									if (!"ALL".equals(statusFilter) && !statusFilter.equalsIgnoreCase(p.getStatus())) {
										continue;
									}
									PayrollStatus statusEnum = PayrollStatus.fromString(p.getStatus());
									String initial = p.getEmployeeName() != null && p.getEmployeeName().length() > 0 ? String.valueOf(p.getEmployeeName().charAt(0)).toUpperCase() : "E";
							%>
							<tr data-search="<%= (p.getEmployeeName() + " " + p.getDepartment() + " EMP" + String.format("%03d", p.getEmployeeId())).toLowerCase() %>">
								<td>
									<div style="display: flex; align-items: center; gap: 10px;">
										<div class="avatar-box" style="width: 32px; height: 32px; font-size: 13px;"><%=initial%></div>
										<strong style="color: #0f172a;"><%=p.getEmployeeName()%></strong>
									</div>
								</td>
								<td><span style="font-family: 'JetBrains Mono', monospace; font-weight: 700; color: #2563eb;">EMP<%=String.format("%03d", p.getEmployeeId())%></span></td>
								<td><span class="dept-badge"><%=p.getDepartment() != null ? p.getDepartment() : "General"%></span></td>
								<td><strong style="font-family: 'JetBrains Mono', monospace; color: #334155;"><%=currencyFmt.format(p.getGrossSalary())%></strong></td>
								<td>
									<% if (p.getUnpaidLeaveDays() > 0) { %>
									<span style="color: #dc2626; font-weight: 700;"><%=p.getUnpaidLeaveDays()%>d (<%=currencyFmt.format(p.getUnpaidLeaveDeduction())%>)</span>
									<% } else { %>
									<span style="color: #64748b;">0 Days</span>
									<% } %>
								</td>
								<td><strong style="font-family: 'JetBrains Mono', monospace; color: #059669;"><%=currencyFmt.format(p.getNetSalary())%></strong></td>
								<td>
									<span class="badge-status <%=statusEnum.getCssClass()%>">
										<i class="fa-solid fa-circle" style="font-size: 6px;"></i> <%=statusEnum.getDisplayName()%>
									</span>
								</td>
								<td>
									<div style="display: flex; gap: 6px;">
										<button type="button" class="btn-card-action btn-outline" style="color: #2563eb;" 
										        onclick="inspectPayrollMath('<%=p.getEmployeeName()%>', 'EMP<%=String.format("%03d", p.getEmployeeId())%>', '<%=currencyFmt.format(p.getBasicSalary())%>', '<%=currencyFmt.format(p.getHra() + p.getTransportAllowance() + p.getMedicalAllowance() + p.getOtherAllowances() + p.getBonus())%>', '<%=currencyFmt.format(p.getGrossSalary())%>', '<%=p.getWorkingDays()%>', '<%=p.getUnpaidLeaveDays()%>', '<%=currencyFmt.format(p.getBasicSalary() / (p.getWorkingDays() > 0 ? p.getWorkingDays() : 26))%>', '<%=currencyFmt.format(p.getUnpaidLeaveDeduction())%>', '<%=currencyFmt.format(p.getPf() + p.getProfessionalTax() + p.getLoanDeduction() + p.getAdvanceSalary() + p.getOtherDeductions())%>', '<%=currencyFmt.format(p.getTotalDeductions())%>', '<%=currencyFmt.format(p.getNetSalary())%>')">
											<i class="fa-solid fa-square-poll-vertical"></i> Inspect
										</button>
										<a href="${pageContext.request.contextPath}/payslip?id=<%=p.getPayrollId()%>" class="btn-card-action btn-outline">
											<i class="fa-solid fa-file-invoice"></i> Payslip
										</a>
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

			</div>

		</div>

	</div>
</div>

<!-- Calculate Employee Salary Modal -->
<div class="modal-overlay" id="singleCalcModal">
	<div class="modal-card">
		<div class="modal-header">
			<h3><i class="fa-solid fa-calculator" style="color: #2563eb;"></i> Calculate Employee Salary</h3>
			<button class="modal-close" onclick="closeSingleCalcModal()">&times;</button>
		</div>

		<!-- Nav Tabs in Modal -->
		<div class="modal-nav-tabs">
			<button type="button" class="modal-tab-btn active" id="tabBtnSingle" onclick="switchCalcTab('single')"><i class="fa-solid fa-user"></i> Single Personnel</button>
			<button type="button" class="modal-tab-btn" id="tabBtnBatch" onclick="switchCalcTab('batch')"><i class="fa-solid fa-building"></i> Department Batch</button>
		</div>

		<!-- Single Personnel Form -->
		<form action="${pageContext.request.contextPath}/processPayroll" method="post" id="singleCalcForm">
			<input type="hidden" name="action" value="calculateSingle">
			<input type="hidden" name="month" value="<%=currentMonth%>">
			<input type="hidden" name="year" value="<%=currentYear%>">

			<div style="margin-bottom: 18px;">
				<label style="display: block; font-size: 12.5px; font-weight: 800; color: #334155; margin-bottom: 8px;">Select Target Employee</label>
				<select name="employeeId" id="modalEmpSelect" required onchange="updateCalcModalPreview()" style="width: 100%; padding: 12px 16px; border-radius: 14px; background: #ffffff; border: 2px solid #2563eb; color: #0f172a; font-size: 14px; outline: none; font-weight: 700;">
					<% if (allEmployees != null) { 
						for (Employee emp : allEmployees) { %>
						<option value="<%=emp.getEmployee_id()%>"><%=emp.getEmployee_name()%> (<%=emp.getDepartment()%>) - EMP<%=String.format("%03d", emp.getEmployee_id())%></option>
					<% } } %>
				</select>
			</div>

			<!-- Live Calculation Preview Panel -->
			<div class="calc-preview-card" id="calcPreviewCard">
				<div class="calc-preview-header">
					<div class="calc-preview-user">
						<div class="calc-preview-avatar" id="prevAvatar">E</div>
						<div>
							<strong id="prevName" style="color: #0f172a; font-size: 15px; display: block;">Employee Name</strong>
							<span id="prevSub" style="font-size: 12px; color: #64748b;">Department &bull; Designation</span>
						</div>
					</div>
					<span id="prevStatusPill" class="badge-status badge-draft">NEW</span>
				</div>

				<div class="calc-preview-stats">
					<div>
						<small>Gross Base</small>
						<span id="prevGross" style="color: #0f172a;">₹0.00</span>
					</div>
					<div>
						<small style="color: #dc2626;">Attendance LOP</small>
						<span id="prevLop" style="color: #dc2626;">0d (₹0)</span>
					</div>
					<div>
						<small style="color: #059669;">Est. Net Payable</small>
						<span id="prevNet" style="color: #059669;">₹0.00</span>
					</div>
				</div>
			</div>

			<div style="display: flex; gap: 10px; justify-content: flex-end; flex-wrap: wrap;">
				<button type="button" class="btn-action btn-outline" onclick="closeSingleCalcModal()">Cancel</button>
				<button type="submit" class="btn-action btn-warning" title="Calculate salary and set status to CALCULATED">
					<i class="fa-solid fa-file-pen"></i> Save Draft
				</button>
				<button type="submit" name="subAction" value="submitForApproval" class="btn-action btn-primary" title="Calculate salary and submit for HR approval">
					<i class="fa-solid fa-paper-plane"></i> Calculate &amp; Submit HR
				</button>
				<button type="submit" name="subAction" value="approveDirect" class="btn-action btn-success" title="Calculate salary and grant Executive Approval">
					<i class="fa-solid fa-stamp"></i> Executive Approve
				</button>
			</div>
		</form>

		<!-- Department Batch Form -->
		<form action="${pageContext.request.contextPath}/processPayroll" method="post" id="deptBatchForm" style="display: none;">
			<input type="hidden" name="action" value="calculateBatch">
			<input type="hidden" name="month" value="<%=currentMonth%>">
			<input type="hidden" name="year" value="<%=currentYear%>">

			<div style="margin-bottom: 20px;">
				<label style="display: block; font-size: 12.5px; font-weight: 800; color: #334155; margin-bottom: 8px;">Select Target Department</label>
				<select name="department" style="width: 100%; padding: 12px 16px; border-radius: 14px; background: #ffffff; border: 1px solid var(--border-color); color: #0f172a; font-size: 14px; outline: none; font-weight: 700;">
					<option value="ALL">All Active Departments (<%=totalEmpCount%> Employees)</option>
					<% for (String dept : departments) { %>
					<option value="<%=dept%>"><%=dept%> Department</option>
					<% } %>
				</select>
			</div>

			<div style="background: var(--blue-light); padding: 16px 20px; border-radius: 16px; border: 1px solid #bfdbfe; margin-bottom: 22px;">
				<div style="font-size: 13.5px; font-weight: 800; color: var(--blue-dark); margin-bottom: 4px;"><i class="fa-solid fa-bolt" style="color: #f59e0b;"></i> Automated Attendance &amp; LOP Audit</div>
				<p style="font-size: 12.5px; color: #334155; line-height: 1.4;">Running batch calculation will automatically fetch leave records, unexcused absent attendance entries, calculate daily rates, apply statutory deductions, and update monthly salary totals for <%=currentMonthName%> <%=currentYear%>.</p>
			</div>

			<div style="display: flex; gap: 12px; justify-content: flex-end;">
				<button type="button" class="btn-action btn-outline" onclick="closeSingleCalcModal()">Cancel</button>
				<button type="submit" class="btn-action btn-primary">
					<i class="fa-solid fa-bolt"></i> Run Batch Calculation
				</button>
			</div>
		</form>
	</div>
</div>

<!-- Calculation Audit / Inspector Modal -->
<div class="modal-overlay" id="calcInspectModal">
	<div class="modal-card">
		<div class="modal-header">
			<h3><i class="fa-solid fa-square-poll-vertical" style="color: #2563eb;"></i> Salary Calculation Audit Breakdown</h3>
			<button class="modal-close" onclick="closeCalcInspectModal()">&times;</button>
		</div>
		<div style="margin-bottom: 18px; background: var(--blue-light); padding: 12px 18px; border-radius: 14px; border: 1px solid #bfdbfe; display: flex; justify-content: space-between; align-items: center;">
			<div>
				<strong id="modalEmpName" style="color: #0f172a; font-size: 15.5px;">Employee Name</strong>
				<div id="modalEmpId" style="font-size: 12.5px; color: var(--blue-primary); font-weight: 800; margin-top: 1px;">EMP000</div>
			</div>
			<span style="font-size: 12.5px; background: #ffffff; padding: 5px 12px; border-radius: 10px; color: #0f172a; font-weight: 800; border: 1px solid #cbd5e1;"><%=currentMonthName%> <%=currentYear%></span>
		</div>

		<div class="audit-step-card">
			<div class="audit-step-title"><span>1. Gross Salary Components</span><i class="fa-solid fa-plus-minus"></i></div>
			<div class="audit-step-row"><span>Basic Monthly Salary</span><strong id="modalBasic">₹0.00</strong></div>
			<div class="audit-step-row"><span>Allowances &amp; Bonus Sum</span><strong id="modalAllow">₹0.00</strong></div>
			<div class="audit-step-row" style="border-top: 1px solid var(--border-color); padding-top: 6px; margin-top: 6px; color: #2563eb; font-weight: 800;">
				<span>Calculated Gross Salary</span><strong id="modalGross" style="color: #2563eb;">₹0.00</strong>
			</div>
		</div>

		<div class="audit-step-card" style="border-color: #fca5a5; background: #fff5f5;">
			<div class="audit-step-title" style="color: #dc2626;"><span>2. Attendance &amp; LOP Deduction Math</span><i class="fa-solid fa-calculator"></i></div>
			<div class="audit-step-row"><span>Standard Working Days</span><strong id="modalWorkDays">26 Days</strong></div>
			<div class="audit-step-row"><span>Per-Day Basic Rate (Basic / 26)</span><strong id="modalDailyRate">₹0.00</strong></div>
			<div class="audit-step-row"><span>Unpaid Leave / Absent LOP Days</span><strong id="modalLopDays" style="color: #dc2626;">0 Days</strong></div>
			<div class="audit-step-row" style="border-top: 1px solid #fca5a5; padding-top: 6px; margin-top: 6px; color: #dc2626; font-weight: 800;">
				<span>Attendance LOP Deduction Amount</span><strong id="modalLopDed" style="color: #dc2626;">₹0.00</strong>
			</div>
		</div>

		<div class="audit-step-card">
			<div class="audit-step-title"><span>3. Total Deductions Breakdown</span><i class="fa-solid fa-file-invoice-dollar"></i></div>
			<div class="audit-step-row"><span>Statutory PF, PT &amp; Direct Deductions</span><strong id="modalStatDed">₹0.00</strong></div>
			<div class="audit-step-row"><span>Attendance LOP Deduction</span><strong id="modalLopDed2">₹0.00</strong></div>
			<div class="audit-step-row" style="border-top: 1px solid var(--border-color); padding-top: 6px; margin-top: 6px; color: #b91c1c; font-weight: 800;">
				<span>Total Deductions Sum</span><strong id="modalTotalDed" style="color: #b91c1c;">₹0.00</strong>
			</div>
		</div>

		<div style="background: linear-gradient(135deg, #10b981, #059669); padding: 16px 22px; border-radius: 18px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 6px 20px rgba(16, 185, 129, 0.35);">
			<div>
				<small style="display: block; font-size: 11px; font-weight: 800; color: #ecfdf5; text-transform: uppercase; letter-spacing: 0.5px;">Final Net Payable Salary</small>
				<span style="font-size: 12px; color: #d1fae5; font-weight: 600;">Gross Salary &minus; Total Deductions</span>
			</div>
			<strong id="modalNet" style="font-size: 24px; color: white; font-family: 'JetBrains Mono', monospace;">₹0.00</strong>
		</div>

		<div style="margin-top: 22px; text-align: right;">
			<button type="button" class="btn-action btn-outline" onclick="closeCalcInspectModal()">Close Audit</button>
		</div>
	</div>
</div>

<script>
// Employee Data Dictionary for Modal Preview
var empDataMap = {
<%
if (allEmployees != null) {
	for (int i = 0; i < allEmployees.size(); i++) {
		Employee emp = allEmployees.get(i);
		Payroll pRec = null;
		if (payrollList != null) {
			for (Payroll p : payrollList) {
				if (p.getEmployeeId() == emp.getEmployee_id()) {
					pRec = p;
					break;
				}
			}
		}
%>
	"<%=emp.getEmployee_id()%>": {
		id: "<%=emp.getEmployee_id()%>",
		empCode: "EMP<%=String.format("%03d", emp.getEmployee_id())%>",
		name: "<%=emp.getEmployee_name() != null ? emp.getEmployee_name().replace("\"", "\\\"") : ""%>",
		dept: "<%=emp.getDepartment() != null ? emp.getDepartment().replace("\"", "\\\"") : "General"%>",
		desig: "<%=emp.getDesignation() != null ? emp.getDesignation().replace("\"", "\\\"") : "Staff"%>",
		email: "<%=emp.getEmail() != null ? emp.getEmail().replace("\"", "\\\"") : ""%>",
		hasRecord: <%=pRec != null%>,
		gross: "<%=pRec != null ? currencyFmt.format(pRec.getGrossSalary()) : "Configured Base"%>",
		net: "<%=pRec != null ? currencyFmt.format(pRec.getNetSalary()) : "Estimated"%>",
		lopDays: "<%=pRec != null ? pRec.getUnpaidLeaveDays() : 0%>",
		lopDed: "<%=pRec != null ? currencyFmt.format(pRec.getUnpaidLeaveDeduction()) : "₹0.00"%>",
		status: "<%=pRec != null ? pRec.getStatus() : "NEW"%>"
	}<%=(i < allEmployees.size() - 1) ? "," : ""%>
<%
	}
}
%>
};

function openSingleCalcModal() {
	document.getElementById("singleCalcModal").classList.add("active");
	updateCalcModalPreview();
}

function openSingleCalcForEmp(empId) {
	document.getElementById("modalEmpSelect").value = empId;
	openSingleCalcModal();
}

function closeSingleCalcModal() { document.getElementById("singleCalcModal").classList.remove("active"); }

function switchCalcTab(type) {
	if (type === 'single') {
		document.getElementById("tabBtnSingle").classList.add("active");
		document.getElementById("tabBtnBatch").classList.remove("active");
		document.getElementById("singleCalcForm").style.display = "block";
		document.getElementById("deptBatchForm").style.display = "none";
	} else {
		document.getElementById("tabBtnBatch").classList.add("active");
		document.getElementById("tabBtnSingle").classList.remove("active");
		document.getElementById("singleCalcForm").style.display = "none";
		document.getElementById("deptBatchForm").style.display = "block";
	}
}

function updateCalcModalPreview() {
	var empId = document.getElementById("modalEmpSelect").value;
	var info = empDataMap[empId];
	if (!info) return;

	document.getElementById("prevAvatar").innerText = info.name ? info.name.charAt(0).toUpperCase() : "E";
	document.getElementById("prevName").innerText = info.name + " (" + info.empCode + ")";
	document.getElementById("prevSub").innerText = info.dept + " \u2022 " + info.desig;

	document.getElementById("prevGross").innerText = info.gross;
	document.getElementById("prevLop").innerText = info.lopDays + "d LOP (" + info.lopDed + ")";
	document.getElementById("prevNet").innerText = info.net;

	var statusPill = document.getElementById("prevStatusPill");
	statusPill.innerText = info.status;

	if (info.status === 'PAID') {
		statusPill.className = "badge-status badge-paid";
	} else if (info.status === 'APPROVED') {
		statusPill.className = "badge-status badge-approved";
	} else if (info.status === 'PENDING_APPROVAL') {
		statusPill.className = "badge-status badge-pending";
	} else if (info.status === 'CALCULATED') {
		statusPill.className = "badge-status badge-calculated";
	} else {
		statusPill.className = "badge-status badge-draft";
	}
}

function openCalcInspectModal() { document.getElementById("calcInspectModal").classList.add("active"); }
function closeCalcInspectModal() { document.getElementById("calcInspectModal").classList.remove("active"); }

function inspectPayrollMath(name, empId, basic, allow, gross, workDays, lopDays, dailyRate, lopDed, statDed, totalDed, net) {
	document.getElementById("modalEmpName").innerText = name;
	document.getElementById("modalEmpId").innerText = empId;
	document.getElementById("modalBasic").innerText = basic;
	document.getElementById("modalAllow").innerText = allow;
	document.getElementById("modalGross").innerText = gross;
	document.getElementById("modalWorkDays").innerText = workDays + " Days";
	document.getElementById("modalDailyRate").innerText = dailyRate + " /day";
	document.getElementById("modalLopDays").innerText = lopDays + " Days";
	document.getElementById("modalLopDed").innerText = lopDed;
	document.getElementById("modalStatDed").innerText = statDed;
	document.getElementById("modalLopDed2").innerText = lopDed;
	document.getElementById("modalTotalDed").innerText = totalDed;
	document.getElementById("modalNet").innerText = net;
	openCalcInspectModal();
}

function filterStatus(status) {
	window.location.href = "${pageContext.request.contextPath}/payrollDashboard?month=<%=currentMonth%>&year=<%=currentYear%>&status=" + status;
}

function switchViewMode(mode) {
	var gridView = document.getElementById("payrollFeedGrid");
	var tableView = document.getElementById("payrollMasterTableCard");
	var btnGrid = document.getElementById("btnGridMode");
	var btnTable = document.getElementById("btnTableMode");

	if (mode === 'grid') {
		gridView.style.display = "grid";
		tableView.style.display = "none";
		btnGrid.classList.add("active");
		btnTable.classList.remove("active");
	} else {
		gridView.style.display = "none";
		tableView.style.display = "block";
		btnTable.classList.add("active");
		btnGrid.classList.remove("active");
	}
}

function searchFeed() {
	var input = document.getElementById("feedSearchInput").value.toLowerCase();
	var cards = document.querySelectorAll("#payrollFeedGrid .payroll-feed-card");
	var rows = document.querySelectorAll("#masterTableBody tr");

	cards.forEach(function(card) {
		var text = card.getAttribute("data-search") || card.innerText.toLowerCase();
		card.style.display = text.indexOf(input) !== -1 ? "" : "none";
	});

	rows.forEach(function(row) {
		var text = row.getAttribute("data-search") || row.innerText.toLowerCase();
		row.style.display = text.indexOf(input) !== -1 ? "" : "none";
	});
}
</script>
</body>
</html>
