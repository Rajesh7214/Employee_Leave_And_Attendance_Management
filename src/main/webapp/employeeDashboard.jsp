<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Attendance"%>
<%@ page import="com.rajesh.elams.model.Task"%>
<%@ page import="com.rajesh.elams.model.TaskStatus"%>
<%@ page import="com.rajesh.elams.model.Priority"%>
<%@ page import="com.rajesh.elams.model.Leave"%>
<%@ page import="com.rajesh.elams.model.Meeting"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
if (loggedUser == null) {
	response.sendRedirect("login.jsp");
	return;
}

if (request.getAttribute("workStatus") == null) {
	response.sendRedirect("employeeDashboardServlet");
	return;
}

Employee employee = (Employee) session.getAttribute("employee");
String empName = (employee != null && employee.getEmployee_name() != null && !employee.getEmployee_name().isBlank())
		? employee.getEmployee_name()
		: (loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "Employee");

if (empName != null && !empName.isBlank()) {
	empName = Character.toUpperCase(empName.charAt(0)) + (empName.length() > 1 ? empName.substring(1) : "");
} else {
	empName = "Employee";
}

int empId = employee != null ? employee.getEmployee_id() : (session.getAttribute("employeeId") != null ? (Integer)session.getAttribute("employeeId") : 0);
String empEmail = employee != null && employee.getEmail() != null ? employee.getEmail() : (loggedUser.getEmail() != null ? loggedUser.getEmail() : "");
String department = employee != null && employee.getDepartment() != null ? employee.getDepartment() : "Operations";
String designation = employee != null && employee.getDesignation() != null ? employee.getDesignation() : "Staff Associate";

String empPhoto = (employee != null && employee.getProfile_photo() != null && !employee.getProfile_photo().isBlank())
		? employee.getProfile_photo()
		: "https://ui-avatars.com/api/?name=" + empName.replace(" ", "+") + "&background=4f46e5&color=fff&bold=true&rounded=true";

Attendance todayAttendance = (Attendance) request.getAttribute("todayAttendance");
String workStatus = (String) request.getAttribute("workStatus");
if (workStatus == null) workStatus = "NOT_CHECKED_IN";

int totalPresentDays = request.getAttribute("totalPresentDays") != null ? (Integer) request.getAttribute("totalPresentDays") : 0;
int myTotalTasks = request.getAttribute("myTotalTasks") != null ? (Integer) request.getAttribute("myTotalTasks") : 0;
int myPendingTasks = request.getAttribute("myPendingTasks") != null ? (Integer) request.getAttribute("myPendingTasks") : 0;
int myInProgressTasks = request.getAttribute("myInProgressTasks") != null ? (Integer) request.getAttribute("myInProgressTasks") : 0;
int myCompletedTasks = request.getAttribute("myCompletedTasks") != null ? (Integer) request.getAttribute("myCompletedTasks") : 0;
int myOverdueTasks = request.getAttribute("myOverdueTasks") != null ? (Integer) request.getAttribute("myOverdueTasks") : 0;

int remainingLeaves = request.getAttribute("remainingLeaves") != null ? (Integer) request.getAttribute("remainingLeaves") : 24;
int leavesApprovedCount = request.getAttribute("leavesApprovedCount") != null ? (Integer) request.getAttribute("leavesApprovedCount") : 0;
int leavesPendingCount = request.getAttribute("leavesPendingCount") != null ? (Integer) request.getAttribute("leavesPendingCount") : 0;
int totalLeaveQuota = request.getAttribute("totalLeaveQuota") != null ? (Integer) request.getAttribute("totalLeaveQuota") : 24;

int leaveProgressPct = totalLeaveQuota > 0 ? Math.min(100, (remainingLeaves * 100) / totalLeaveQuota) : 100;
int activeTasksCount = myPendingTasks + myInProgressTasks;

@SuppressWarnings("unchecked")
List<Attendance> recentAttendance = (List<Attendance>) request.getAttribute("recentAttendance");

@SuppressWarnings("unchecked")
List<Task> myTasks = (List<Task>) request.getAttribute("myTasks");

@SuppressWarnings("unchecked")
List<Meeting> myDashboardMeetings = (List<Meeting>) request.getAttribute("myUpcomingMeetings");
if (myDashboardMeetings == null) {
	myDashboardMeetings = (List<Meeting>) request.getAttribute("myMeetings");
}

String role = (String) session.getAttribute("role");
if (role == null) role = "employee";
String activePage = "dashboard";
String todayFullDate = new SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ELAMS | Modern Employee Workspace</title>

<!-- Modern Typography & Icons -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;600;700&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
/* ==========================================================================
   Advanced CSS Design System & Theme Tokens
   ========================================================================== */
:root {
	/* Backgrounds & Surfaces */
	--bg-body: #f8fafc;
	--bg-sidebar: #090d16;
	--bg-sidebar-card: #111827;
	--card-surface: #ffffff;
	--card-muted: #f8fafc;
	--card-subtle: #f1f5f9;

	/* Brand & Accent Palette */
	--primary-indigo: #4f46e5;
	--primary-indigo-light: #6366f1;
	--primary-violet: #7c3aed;
	--accent-emerald: #10b981;
	--accent-emerald-dark: #059669;
	--accent-amber: #f59e0b;
	--accent-amber-dark: #d97706;
	--accent-rose: #f43f5e;
	--accent-rose-dark: #e11d48;
	--accent-cyan: #0284c7;
	--accent-cyan-dark: #0369a1;
	--accent-purple: #8b5cf6;
	--accent-pink: #ec4899;

	/* Text Colors */
	--text-main: #0f172a;
	--text-secondary: #475569;
	--text-muted: #64748b;
	--text-light: #94a3b8;
	--text-white: #ffffff;

	/* Borders */
	--border-light: #e2e8f0;
	--border-subtle: #f1f5f9;
	--border-focus: #c7d2fe;

	/* Layout & Elevation */
	--sidebar-w: 260px;
	--topbar-h: 74px;
	--radius-sm: 8px;
	--radius-md: 14px;
	--radius-lg: 20px;
	--radius-xl: 24px;
	--shadow-card: 0 4px 20px -2px rgba(15, 23, 42, 0.05), 0 2px 6px -1px rgba(15, 23, 42, 0.02);
	--shadow-card-hover: 0 16px 32px -4px rgba(15, 23, 42, 0.09), 0 6px 12px -2px rgba(15, 23, 42, 0.04);
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

body {
	background: var(--bg-body);
	color: var(--text-main);
	min-height: 100vh;
	display: flex;
	-webkit-font-smoothing: antialiased;
	overflow-x: hidden;
}

/* ==========================================================================
   1. Left Sidebar Navigation
   ========================================================================== */
.sidebar {
	width: var(--sidebar-w);
	background: linear-gradient(180deg, #090d16 0%, #0f172a 100%);
	position: fixed;
	left: 0;
	top: 0;
	bottom: 0;
	overflow-y: auto;
	z-index: 100;
	display: flex;
	flex-direction: column;
	padding: 24px 16px;
	border-right: 1px solid rgba(255, 255, 255, 0.06);
	transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.sidebar-brand {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 8px 12px 24px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.08);
	margin-bottom: 18px;
}

.brand-icon {
	width: 42px;
	height: 42px;
	border-radius: 12px;
	background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	box-shadow: 0 4px 14px rgba(79, 70, 229, 0.45);
}

.brand-title {
	font-size: 19px;
	font-weight: 800;
	color: #ffffff;
	letter-spacing: -0.5px;
	line-height: 1.1;
}

.brand-title span {
	background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
	-webkit-background-clip: text;
	-webkit-text-fill-color: transparent;
}

.brand-subtitle {
	font-size: 10.5px;
	font-weight: 600;
	color: #94a3b8;
	text-transform: uppercase;
	letter-spacing: 0.6px;
}

.nav-section-label {
	font-size: 11px;
	font-weight: 800;
	text-transform: uppercase;
	color: #64748b;
	letter-spacing: 0.8px;
	padding: 14px 12px 6px;
}

.sidebar-menu {
	display: flex;
	flex-direction: column;
	gap: 4px;
	flex: 1;
}

.nav-item {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 11px 16px;
	border-radius: 12px;
	color: #94a3b8;
	font-size: 13.5px;
	font-weight: 600;
	text-decoration: none;
	transition: all 0.2s ease;
	position: relative;
}

.nav-item i {
	font-size: 15px;
	width: 20px;
	text-align: center;
	color: #64748b;
	transition: color 0.2s ease;
}

.nav-item:hover {
	background: rgba(255, 255, 255, 0.06);
	color: #f8fafc;
}

.nav-item:hover i {
	color: #ffffff;
}

.nav-item.active {
	background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
	color: #ffffff;
	font-weight: 700;
	box-shadow: 0 4px 16px rgba(79, 70, 229, 0.35);
}

.nav-item.active i {
	color: #ffffff;
}

.nav-badge {
	margin-left: auto;
	padding: 2px 7px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 700;
	background: rgba(255, 255, 255, 0.12);
	color: #ffffff;
}

.sidebar-footer {
	margin-top: auto;
	padding-top: 16px;
	border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.user-quick-card {
	display: flex;
	align-items: center;
	gap: 12px;
	padding: 10px 12px;
	border-radius: 12px;
	background: rgba(255, 255, 255, 0.04);
	margin-bottom: 10px;
	text-decoration: none;
}

.uqc-avatar {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	object-fit: cover;
	border: 1px solid rgba(255, 255, 255, 0.15);
}

.uqc-info {
	overflow: hidden;
}

.uqc-name {
	font-size: 13px;
	font-weight: 700;
	color: #ffffff;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.uqc-role {
	font-size: 11px;
	color: #94a3b8;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.btn-sidebar-logout {
	display: flex;
	align-items: center;
	gap: 10px;
	width: 100%;
	padding: 10px 14px;
	border-radius: 10px;
	background: rgba(244, 63, 94, 0.1);
	color: #f87171;
	border: 1px solid rgba(244, 63, 94, 0.2);
	font-size: 13px;
	font-weight: 700;
	text-decoration: none;
	transition: all 0.2s ease;
	cursor: pointer;
}

.btn-sidebar-logout:hover {
	background: #f43f5e;
	color: #ffffff;
	border-color: #f43f5e;
}

/* ==========================================================================
   2. Main Content Wrapper & Topbar
   ========================================================================== */
.main-wrapper {
	margin-left: var(--sidebar-w);
	width: calc(100% - var(--sidebar-w));
	display: flex;
	flex-direction: column;
	min-height: 100vh;
	background: var(--bg-body);
}

.topbar {
	height: var(--topbar-h);
	background: rgba(255, 255, 255, 0.9);
	backdrop-filter: blur(12px);
	-webkit-backdrop-filter: blur(12px);
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 36px;
	border-bottom: 1px solid var(--border-light);
	position: sticky;
	top: 0;
	z-index: 90;
}

.topbar-left {
	display: flex;
	align-items: center;
	gap: 16px;
}

.mobile-menu-toggle {
	display: none;
	background: transparent;
	border: none;
	color: var(--text-main);
	font-size: 20px;
	cursor: pointer;
	padding: 6px;
	border-radius: 8px;
}

.topbar-greeting-wrap {
	display: flex;
	flex-direction: column;
}

.topbar-title {
	font-size: 18px;
	font-weight: 800;
	color: var(--text-main);
	letter-spacing: -0.3px;
	display: flex;
	align-items: center;
	gap: 8px;
}

.topbar-breadcrumb {
	font-size: 12px;
	color: var(--text-muted);
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 6px;
}

.topbar-right {
	display: flex;
	align-items: center;
	gap: 16px;
}

/* Bell button light mode override */
.topbar .notif-bell-btn {
	background: #f1f5f9;
	border: 1px solid var(--border-light);
	color: var(--text-main) !important;
	box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.topbar .notif-bell-btn:hover, .topbar .notif-bell-btn.active {
	background: var(--primary-indigo);
	color: #ffffff !important;
	border-color: var(--primary-indigo);
}

/* Live Interactive Clock Widget */
.clock-widget-box {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 8px 14px;
	background: #f1f5f9;
	border: 1px solid var(--border-light);
	border-radius: 12px;
	font-family: 'JetBrains Mono', monospace;
	font-size: 12.5px;
	font-weight: 600;
	color: var(--text-secondary);
}

.clock-widget-box i {
	color: var(--primary-indigo);
	font-size: 14px;
}

.topbar-profile-pill {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 4px 14px 4px 4px;
	background: #f8fafc;
	border: 1px solid var(--border-light);
	border-radius: 30px;
	text-decoration: none;
	transition: all 0.2s ease;
}

.topbar-profile-pill:hover {
	background: #f1f5f9;
	border-color: #cbd5e1;
}

.topbar-avatar {
	width: 34px;
	height: 34px;
	border-radius: 50%;
	object-fit: cover;
	border: 1.5px solid var(--primary-indigo);
}

.topbar-user-name {
	font-size: 13px;
	font-weight: 700;
	color: var(--text-main);
}

.topbar-user-dept {
	font-size: 10.5px;
	color: var(--text-muted);
	font-weight: 600;
}

/* Dashboard Viewport */
.dashboard-viewport {
	padding: 28px 36px 48px;
	flex: 1;
	display: flex;
	flex-direction: column;
	gap: 26px;
}

/* ==========================================================================
   3. Hero Workstation Command Banner
   ========================================================================== */
.hero-workstation-card {
	position: relative;
	overflow: hidden;
	background: linear-gradient(135deg, #1e1b4b 0%, #312e81 50%, #4338ca 100%);
	border-radius: var(--radius-xl);
	padding: 28px 32px;
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 24px;
	box-shadow: 0 10px 30px -5px rgba(49, 46, 129, 0.35);
	border: 1px solid rgba(255, 255, 255, 0.12);
}

.hero-workstation-card::before {
	content: '';
	position: absolute;
	top: -60px;
	right: -60px;
	width: 240px;
	height: 240px;
	background: radial-gradient(circle, rgba(129, 140, 248, 0.3) 0%, rgba(129, 140, 248, 0) 70%);
	pointer-events: none;
}

.hero-workstation-card::after {
	content: '';
	position: absolute;
	bottom: -60px;
	left: 30%;
	width: 200px;
	height: 200px;
	background: radial-gradient(circle, rgba(236, 72, 153, 0.2) 0%, rgba(236, 72, 153, 0) 70%);
	pointer-events: none;
}

.hero-profile-info {
	display: flex;
	align-items: center;
	gap: 20px;
	z-index: 2;
}

.hero-avatar-wrap {
	position: relative;
}

.hero-avatar-img {
	width: 72px;
	height: 72px;
	border-radius: 20px;
	object-fit: cover;
	background: #ffffff;
	padding: 3px;
	border: 2px solid rgba(255, 255, 255, 0.4);
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.hero-online-status {
	position: absolute;
	bottom: -2px;
	right: -2px;
	width: 16px;
	height: 16px;
	border-radius: 50%;
	border: 2.5px solid #1e1b4b;
}

.status-working { background: var(--accent-emerald); box-shadow: 0 0 10px var(--accent-emerald); }
.status-break { background: var(--accent-amber); box-shadow: 0 0 10px var(--accent-amber); }
.status-out { background: #94a3b8; }

.hero-text-details {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.hero-badges-row {
	display: flex;
	align-items: center;
	gap: 8px;
	flex-wrap: wrap;
}

.badge-pill-light {
	display: inline-flex;
	align-items: center;
	gap: 5px;
	background: rgba(255, 255, 255, 0.15);
	backdrop-filter: blur(6px);
	padding: 3px 10px;
	border-radius: 20px;
	font-size: 11px;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	color: #e0e7ff;
	border: 1px solid rgba(255, 255, 255, 0.15);
}

.hero-title-name {
	font-size: 24px;
	font-weight: 800;
	letter-spacing: -0.4px;
	display: flex;
	align-items: center;
	gap: 10px;
}

.hero-subtext {
	font-size: 13.5px;
	color: #cbd5e1;
	font-weight: 500;
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
}

.hero-subtext span {
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

/* Duty Punch Station on Right */
.duty-station-box {
	z-index: 2;
	background: rgba(255, 255, 255, 0.08);
	backdrop-filter: blur(16px);
	-webkit-backdrop-filter: blur(16px);
	border: 1px solid rgba(255, 255, 255, 0.18);
	border-radius: 18px;
	padding: 16px 22px;
	display: flex;
	flex-direction: column;
	gap: 12px;
	min-width: 280px;
}

.duty-status-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.duty-live-badge {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	font-size: 13px;
	font-weight: 700;
}

.pulse-indicator {
	width: 9px;
	height: 9px;
	border-radius: 50%;
	display: inline-block;
}

.pulse-green { background: #10b981; box-shadow: 0 0 10px #10b981; animation: pulse 2s infinite; }
.pulse-amber { background: #f59e0b; box-shadow: 0 0 10px #f59e0b; animation: pulse 2s infinite; }
.pulse-grey { background: #94a3b8; }

@keyframes pulse {
	0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
	70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
	100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
}

.duty-actions-wrap {
	display: flex;
	align-items: center;
	gap: 10px;
	flex-wrap: wrap;
}

.btn-duty-action {
	padding: 9px 18px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 700;
	text-decoration: none;
	border: none;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
}

.btn-punch-in {
	background: #10b981;
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4);
}

.btn-punch-in:hover {
	background: #059669;
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(16, 185, 129, 0.5);
}

.btn-punch-out {
	background: #f43f5e;
	color: #ffffff;
	box-shadow: 0 4px 14px rgba(244, 63, 94, 0.35);
}

.btn-punch-out:hover {
	background: #e11d48;
	transform: translateY(-2px);
}

.btn-break {
	background: rgba(255, 255, 255, 0.15);
	color: #fde68a;
	border: 1px solid rgba(253, 230, 138, 0.3);
}

.btn-break:hover {
	background: rgba(255, 255, 255, 0.25);
	transform: translateY(-2px);
}

/* ==========================================================================
   4. KPI Summary Metric Cards (4 Cards)
   ========================================================================== */
.metrics-row-grid {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 20px;
}

@media (max-width: 1200px) {
	.metrics-row-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 640px) {
	.metrics-row-grid { grid-template-columns: 1fr; }
}

.metric-kpi-card {
	background: var(--card-surface);
	border-radius: var(--radius-lg);
	padding: 22px 24px;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-card);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	gap: 16px;
	transition: all 0.25s ease;
	position: relative;
	overflow: hidden;
}

.metric-kpi-card:hover {
	transform: translateY(-3px);
	box-shadow: var(--shadow-card-hover);
	border-color: #cbd5e1;
}

.metric-top {
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.metric-icon-box {
	width: 48px;
	height: 48px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	color: #ffffff;
}

.grad-emerald { background: linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow: 0 4px 14px rgba(16, 185, 129, 0.35); }
.grad-amber   { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); box-shadow: 0 4px 14px rgba(245, 158, 11, 0.35); }
.grad-purple  { background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%); box-shadow: 0 4px 14px rgba(139, 92, 246, 0.35); }
.grad-cyan    { background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); box-shadow: 0 4px 14px rgba(2, 132, 199, 0.35); }

.metric-tag-pill {
	font-size: 11.5px;
	font-weight: 700;
	padding: 3px 10px;
	border-radius: 20px;
}

.tag-emerald { background: #ecfdf5; color: #047857; }
.tag-amber   { background: #fffbeb; color: #b45309; }
.tag-purple  { background: #f5f3ff; color: #6d28d9; }
.tag-cyan    { background: #f0f9ff; color: #0369a1; }

.metric-middle {
	display: flex;
	flex-direction: column;
	gap: 4px;
}

.metric-label {
	font-size: 13px;
	font-weight: 600;
	color: var(--text-muted);
}

.metric-value-row {
	display: flex;
	align-items: baseline;
	gap: 6px;
}

.metric-number {
	font-size: 28px;
	font-weight: 800;
	color: var(--text-main);
	letter-spacing: -0.5px;
	line-height: 1.1;
}

.metric-unit {
	font-size: 13px;
	font-weight: 700;
	color: var(--text-muted);
}

.metric-progress-wrap {
	display: flex;
	flex-direction: column;
	gap: 6px;
}

.progress-track {
	width: 100%;
	height: 6px;
	background: #f1f5f9;
	border-radius: 6px;
	overflow: hidden;
}

.progress-fill {
	height: 100%;
	border-radius: 6px;
	transition: width 0.6s ease;
}

.fill-emerald { background: #10b981; }
.fill-amber   { background: #f59e0b; }
.fill-purple  { background: #8b5cf6; }
.fill-cyan    { background: #0284c7; }

.metric-sub-note {
	font-size: 11.5px;
	color: var(--text-muted);
	font-weight: 600;
	display: flex;
	justify-content: space-between;
}

/* ==========================================================================
   5. Section Header & Quick Workspace Action Cards (4x2 Grid)
   ========================================================================== */
.section-header-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 16px;
}

.section-title {
	font-size: 17px;
	font-weight: 800;
	color: var(--text-main);
	display: flex;
	align-items: center;
	gap: 10px;
	letter-spacing: -0.3px;
}

.section-title i {
	color: var(--primary-indigo);
}

.section-action-link {
	font-size: 13px;
	font-weight: 700;
	color: var(--primary-indigo);
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
}

.section-action-link:hover {
	color: var(--primary-violet);
	transform: translateX(2px);
}

.quick-actions-grid {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 20px;
}

@media (max-width: 1200px) {
	.quick-actions-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 640px) {
	.quick-actions-grid { grid-template-columns: 1fr; }
}

.qa-card {
	background: var(--card-surface);
	border-radius: var(--radius-lg);
	padding: 22px;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-card);
	text-decoration: none;
	color: inherit;
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	gap: 14px;
	transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
	position: relative;
	overflow: hidden;
}

.qa-card:hover {
	transform: translateY(-4px);
	box-shadow: var(--shadow-card-hover);
	border-color: #cbd5e1;
}

.qa-card-top {
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
}

.qa-icon-box {
	width: 50px;
	height: 50px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 21px;
	color: #ffffff;
	transition: transform 0.25s ease;
}

.qa-card:hover .qa-icon-box {
	transform: scale(1.06);
}

/* Card Icons */
.icon-emerald { background: linear-gradient(135deg, #10b981 0%, #059669 100%); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
.icon-amber   { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3); }
.icon-purple  { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3); }
.icon-cyan    { background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3); }
.icon-blue    { background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3); }
.icon-rose    { background: linear-gradient(135deg, #f43f5e 0%, #be123c 100%); box-shadow: 0 4px 12px rgba(244, 63, 94, 0.3); }
.icon-pink    { background: linear-gradient(135deg, #ec4899 0%, #be185d 100%); box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3); }
.icon-indigo  { background: linear-gradient(135deg, #6366f1 0%, #4338ca 100%); box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3); }

.qa-badge {
	font-size: 11px;
	font-weight: 700;
	padding: 3px 9px;
	border-radius: 12px;
	background: #f8fafc;
	color: var(--text-secondary);
	border: 1px solid var(--border-light);
}

.qa-card-body h3 {
	font-size: 15.5px;
	font-weight: 800;
	color: var(--text-main);
	margin-bottom: 5px;
	letter-spacing: -0.2px;
}

.qa-card-body p {
	font-size: 12.5px;
	color: var(--text-muted);
	line-height: 1.45;
}

.qa-arrow-btn {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	font-size: 12px;
	font-weight: 700;
	color: var(--primary-indigo);
	margin-top: 6px;
	transition: transform 0.2s ease;
}

.qa-card:hover .qa-arrow-btn {
	transform: translateX(4px);
}

/* ==========================================================================
   6. Dual Feed Panels: Live Meetings & Priority Tasks
   ========================================================================== */
.dual-feeds-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 22px;
}

@media (max-width: 1024px) {
	.dual-feeds-grid { grid-template-columns: 1fr; }
}

.feed-box-card {
	background: var(--card-surface);
	border-radius: var(--radius-lg);
	padding: 24px;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-card);
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.feed-box-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding-bottom: 16px;
	border-bottom: 1px solid var(--border-subtle);
	margin-bottom: 16px;
}

.feed-box-title {
	font-size: 16px;
	font-weight: 800;
	color: var(--text-main);
	display: flex;
	align-items: center;
	gap: 10px;
}

.feed-items-list {
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.feed-item-row {
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 12px 14px;
	border-radius: 12px;
	background: var(--card-muted);
	border: 1px solid var(--border-subtle);
	transition: all 0.2s ease;
}

.feed-item-row:hover {
	background: #ffffff;
	border-color: #cbd5e1;
	box-shadow: 0 4px 12px rgba(15, 23, 42, 0.04);
}

.fir-left {
	display: flex;
	align-items: center;
	gap: 14px;
	overflow: hidden;
}

/* Calendar Date Tag */
.cal-date-chip {
	width: 44px;
	height: 44px;
	border-radius: 10px;
	background: #e0f2fe;
	color: #0369a1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	font-weight: 800;
	flex-shrink: 0;
	border: 1px solid #bae6fd;
}

.cal-date-chip small {
	font-size: 9px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.cal-date-chip span {
	font-size: 15px;
	line-height: 1.1;
}

.fir-details {
	overflow: hidden;
}

.fir-details h4 {
	font-size: 13.5px;
	font-weight: 700;
	color: var(--text-main);
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	margin-bottom: 2px;
}

.fir-details p {
	font-size: 12px;
	color: var(--text-muted);
	display: flex;
	align-items: center;
	gap: 8px;
}

.btn-join-meeting {
	padding: 6px 14px;
	background: var(--primary-indigo);
	color: #ffffff;
	border-radius: 8px;
	font-size: 12px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s ease;
	flex-shrink: 0;
}

.btn-join-meeting:hover {
	background: var(--primary-indigo-light);
	transform: translateY(-1px);
}

.btn-meeting-details {
	padding: 6px 12px;
	background: #f1f5f9;
	color: var(--text-secondary);
	border-radius: 8px;
	font-size: 12px;
	font-weight: 700;
	text-decoration: none;
	flex-shrink: 0;
}

.btn-meeting-details:hover {
	background: #e2e8f0;
}

/* Priority Indicators for Tasks */
.priority-dot-indicator {
	width: 10px;
	height: 10px;
	border-radius: 50%;
	flex-shrink: 0;
}

.prio-high { background: #f43f5e; box-shadow: 0 0 8px rgba(244, 63, 94, 0.5); }
.prio-med  { background: #f59e0b; box-shadow: 0 0 8px rgba(245, 158, 11, 0.5); }
.prio-low  { background: #10b981; box-shadow: 0 0 8px rgba(16, 185, 129, 0.5); }

.task-status-chip {
	font-size: 11px;
	font-weight: 800;
	padding: 4px 10px;
	border-radius: 10px;
	text-transform: uppercase;
	flex-shrink: 0;
}

.chip-done { background: #dcfce7; color: #15803d; }
.chip-prog { background: #e0e7ff; color: #3730a3; }
.chip-pend { background: #fef3c7; color: #b45309; }

.feed-empty-state {
	text-align: center;
	padding: 32px 16px;
	color: var(--text-muted);
	display: flex;
	flex-direction: column;
	align-items: center;
	gap: 10px;
}

.feed-empty-state i {
	font-size: 32px;
	color: #cbd5e1;
}

.feed-empty-state p {
	font-size: 13px;
	font-weight: 600;
}

/* ==========================================================================
   7. Recent Attendance Mini Activity Table
   ========================================================================== */
.activity-card {
	background: var(--card-surface);
	border-radius: var(--radius-lg);
	padding: 24px;
	border: 1px solid var(--border-light);
	box-shadow: var(--shadow-card);
}

.custom-table-wrap {
	width: 100%;
	overflow-x: auto;
}

.modern-data-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 13px;
	text-align: left;
}

.modern-data-table th {
	background: var(--card-muted);
	color: var(--text-secondary);
	font-weight: 700;
	padding: 12px 16px;
	text-transform: uppercase;
	font-size: 11.5px;
	letter-spacing: 0.5px;
	border-bottom: 1px solid var(--border-light);
}

.modern-data-table th:first-child { border-top-left-radius: 10px; border-bottom-left-radius: 10px; }
.modern-data-table th:last-child { border-top-right-radius: 10px; border-bottom-right-radius: 10px; }

.modern-data-table td {
	padding: 14px 16px;
	border-bottom: 1px solid var(--border-subtle);
	color: var(--text-main);
	font-weight: 500;
}

.modern-data-table tr:last-child td {
	border-bottom: none;
}

.status-badge-table {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 4px 10px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 700;
}

.sbadge-present { background: #ecfdf5; color: #047857; }
.sbadge-late    { background: #fffbeb; color: #b45309; }
.sbadge-half    { background: #f5f3ff; color: #6d28d9; }
.sbadge-absent  { background: #fef2f2; color: #b91c1c; }

/* Responsive adjustments */
@media (max-width: 900px) {
	.sidebar {
		transform: translateX(-100%);
	}

	.sidebar.mobile-open {
		transform: translateX(0);
	}

	.main-wrapper {
		margin-left: 0;
		width: 100%;
	}

	.mobile-menu-toggle {
		display: block;
	}

	.topbar {
		padding: 0 20px;
	}

	.dashboard-viewport {
		padding: 20px 16px 40px;
	}

	.hero-workstation-card {
		padding: 22px 20px;
	}
}
</style>
</head>
<body>

	<!-- ==========================================================================
	     1. Modern Sidebar Navigation
	     ========================================================================== -->
	<aside class="sidebar" id="appSidebar">
		<!-- Brand Logo -->
		<div class="sidebar-brand">
			<div class="brand-icon">
				<i class="fa-solid fa-shield-halved"></i>
			</div>
			<div>
				<div class="brand-title">ELAMS<span>.</span></div>
				<div class="brand-subtitle">Workforce Portal</div>
			</div>
		</div>

		<!-- Nav Menu -->
		<nav class="sidebar-menu">
			<div class="nav-section-label">Main Menu</div>
			<a href="employeeDashboardServlet" class="nav-item active">
				<i class="fa-solid fa-gauge-high"></i>
				<span>Dashboard</span>
			</a>

			<div class="nav-section-label">Attendance &amp; Leave</div>
			<a href="attendance.jsp" class="nav-item">
				<i class="fa-regular fa-calendar-check"></i>
				<span>Mark Attendance</span>
			</a>
			<a href="applyLeave.jsp" class="nav-item">
				<i class="fa-solid fa-paper-plane"></i>
				<span>Apply Leave</span>
			</a>
			<a href="leaveHistory" class="nav-item">
				<i class="fa-solid fa-clock-rotate-left"></i>
				<span>Leave History</span>
				<% if (leavesPendingCount > 0) { %>
					<span class="nav-badge"><%=leavesPendingCount%></span>
				<% } %>
			</a>
			<a href="attendanceHistory" class="nav-item">
				<i class="fa-solid fa-chart-simple"></i>
				<span>Attendance Report</span>
			</a>

			<div class="nav-section-label">Collaboration &amp; Tasks</div>
			<a href="myMeetings" class="nav-item">
				<i class="fa-solid fa-video"></i>
				<span>My Meetings</span>
				<% if (myDashboardMeetings != null && !myDashboardMeetings.isEmpty()) { %>
					<span class="nav-badge"><%=myDashboardMeetings.size()%></span>
				<% } %>
			</a>
			<a href="myTasks" class="nav-item">
				<i class="fa-solid fa-list-check"></i>
				<span>My Tasks</span>
				<% if (activeTasksCount > 0) { %>
					<span class="nav-badge"><%=activeTasksCount%></span>
				<% } %>
			</a>

			<div class="nav-section-label">Payroll &amp; Compensation</div>
			<a href="myPayroll" class="nav-item">
				<i class="fa-solid fa-receipt"></i>
				<span>My Payslips</span>
			</a>

			<div class="nav-section-label">Account Profile</div>
			<a href="employeeProfile.jsp" class="nav-item">
				<i class="fa-regular fa-id-card"></i>
				<span>My Profile</span>
			</a>
		</nav>

		<!-- Sidebar Footer User Card & Logout -->
		<div class="sidebar-footer">
			<a href="employeeProfile.jsp" class="user-quick-card">
				<img src="<%=empPhoto%>" alt="Photo" class="uqc-avatar" />
				<div class="uqc-info">
					<div class="uqc-name"><%=empName%></div>
					<div class="uqc-role"><%=designation%></div>
				</div>
			</a>
			<a href="logout" class="btn-sidebar-logout" onclick="return confirm('Are you sure you want to sign out?');">
				<i class="fa-solid fa-arrow-right-from-bracket"></i>
				<span>Sign Out</span>
			</a>
		</div>
	</aside>

	<!-- ==========================================================================
	     2. Main Application Wrapper
	     ========================================================================== -->
	<div class="main-wrapper">

		<!-- Sticky Top Navigation Bar -->
		<header class="topbar">
			<div class="topbar-left">
				<button class="mobile-menu-toggle" id="mobileMenuBtn" aria-label="Toggle navigation menu">
					<i class="fa-solid fa-bars"></i>
				</button>
				<div class="topbar-greeting-wrap">
					<div class="topbar-title">
						<span id="dynamicGreetingIcon"><i class="fa-solid fa-sun" style="color:#f59e0b;"></i></span>
						<span id="dynamicGreetingText">Welcome</span>, <%=empName%>
					</div>
					<div class="topbar-breadcrumb">
						<span>ELAMS Enterprise</span> &bull; <span><%=todayFullDate%></span>
					</div>
				</div>
			</div>

			<div class="topbar-right">
				<!-- Live Digital Clock Widget -->
				<div class="clock-widget-box" title="Local Time">
					<i class="fa-regular fa-clock"></i>
					<span id="liveClockDisplay">--:--:--</span>
				</div>

				<!-- Shared Notification Bar Component -->
				<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>

				<!-- Profile Dropdown Badge -->
				<a href="employeeProfile.jsp" class="topbar-profile-pill" title="View Profile">
					<img src="<%=empPhoto%>" alt="Photo" class="topbar-avatar" />
					<div>
						<div class="topbar-user-name"><%=empName%></div>
						<div class="topbar-user-dept"><%=department%></div>
					</div>
				</a>
			</div>
		</header>

		<!-- Main Dashboard Viewport -->
		<main class="dashboard-viewport">

			<!-- ==========================================================================
			     3. Hero Workstation Command Banner
			     ========================================================================== -->
			<div class="hero-workstation-card">
				<div class="hero-profile-info">
					<div class="hero-avatar-wrap">
						<img src="<%=empPhoto%>" alt="Avatar" class="hero-avatar-img" />
						<% if ("WORKING".equals(workStatus)) { %>
							<span class="hero-online-status status-working" title="On Duty"></span>
						<% } else if ("ON_BREAK".equals(workStatus)) { %>
							<span class="hero-online-status status-break" title="On Break"></span>
						<% } else { %>
							<span class="hero-online-status status-out" title="Offline / Not checked in"></span>
						<% } %>
					</div>

					<div class="hero-text-details">
						<div class="hero-badges-row">
							<div class="badge-pill-light">
								<i class="fa-solid fa-circle-check"></i> Employee Hub
							</div>
							<div class="badge-pill-light">
								<i class="fa-solid fa-id-badge"></i> ID: #<%=empId > 0 ? empId : "EMP"%>
							</div>
						</div>
						<h1 class="hero-title-name">Welcome back, <%=empName%> 👋</h1>
						<div class="hero-subtext">
							<span><i class="fa-solid fa-briefcase"></i> <%=designation%></span>
							<span>&bull;</span>
							<span><i class="fa-solid fa-building"></i> <%=department%> Department</span>
							<span>&bull;</span>
							<span><i class="fa-regular fa-envelope"></i> <%=empEmail%></span>
						</div>
					</div>
				</div>

				<!-- Duty Workstation Action Hub -->
				<div class="duty-station-box">
					<div class="duty-status-header">
						<div class="duty-live-badge">
							<% if ("WORKING".equals(workStatus)) { %>
								<span class="pulse-indicator pulse-green"></span>
								<span>Currently Working</span>
							<% } else if ("ON_BREAK".equals(workStatus)) { %>
								<span class="pulse-indicator pulse-amber"></span>
								<span>On Work Break</span>
							<% } else if ("CHECKED_OUT".equals(workStatus)) { %>
								<span class="pulse-indicator pulse-grey"></span>
								<span>Shift Completed</span>
							<% } else { %>
								<span class="pulse-indicator pulse-grey"></span>
								<span>Not Checked In</span>
							<% } %>
						</div>

						<div style="font-size: 11.5px; font-weight: 700; color: #cbd5e1;">
							<% if (todayAttendance != null && todayAttendance.getCheck_in_time() != null) { %>
								In: <%=todayAttendance.getCheck_in_time()%>
							<% } else { %>
								Today
							<% } %>
						</div>
					</div>

					<div class="duty-actions-wrap">
						<% if ("NOT_CHECKED_IN".equals(workStatus)) { %>
							<a href="attendance.jsp" class="btn-duty-action btn-punch-in" style="width: 100%; justify-content: center;">
								<i class="fa-solid fa-fingerprint"></i> Punch In Shift
							</a>
						<% } else if ("WORKING".equals(workStatus)) { %>
							<form action="startBreak" method="POST" style="display:inline;">
								<button type="submit" class="btn-duty-action btn-break">
									<i class="fa-solid fa-mug-hot"></i> Take Break
								</button>
							</form>
							<a href="attendance.jsp" class="btn-duty-action btn-punch-out">
								<i class="fa-solid fa-right-from-bracket"></i> Punch Out
							</a>
						<% } else if ("ON_BREAK".equals(workStatus)) { %>
							<form action="endBreak" method="POST" style="display:inline; width: 100%;">
								<button type="submit" class="btn-duty-action btn-punch-in" style="width: 100%; justify-content: center;">
									<i class="fa-solid fa-play"></i> Resume Working
								</button>
							</form>
						<% } else { %>
							<div style="font-size: 12.5px; font-weight: 700; color: #a7f3d0; display: flex; align-items: center; gap: 8px;">
								<i class="fa-solid fa-circle-check"></i> Shift logged successfully for today!
							</div>
						<% } %>
					</div>
				</div>
			</div>

			<!-- ==========================================================================
			     4. KPI Summary Metric Cards (4 Cards)
			     ========================================================================== -->
			<div class="metrics-row-grid">
				<!-- Card 1: Attendance Presence -->
				<div class="metric-kpi-card">
					<div class="metric-top">
						<div class="metric-icon-box grad-emerald">
							<i class="fa-regular fa-calendar-check"></i>
						</div>
						<span class="metric-tag-pill tag-emerald">Monthly Log</span>
					</div>
					<div class="metric-middle">
						<div class="metric-label">Total Days Present</div>
						<div class="metric-value-row">
							<span class="metric-number"><%=totalPresentDays%></span>
							<span class="metric-unit">Days</span>
						</div>
					</div>
					<div class="metric-progress-wrap">
						<div class="progress-track">
							<div class="progress-fill fill-emerald" style="width: <%=Math.min(100, totalPresentDays * 4)%>%;"></div>
						</div>
						<div class="metric-sub-note">
							<span>Active streak</span>
							<span>Good Standing</span>
						</div>
					</div>
				</div>

				<!-- Card 2: Annual Leave Balance -->
				<div class="metric-kpi-card">
					<div class="metric-top">
						<div class="metric-icon-box grad-amber">
							<i class="fa-solid fa-plane-departure"></i>
						</div>
						<span class="metric-tag-pill tag-amber">Quota Hub</span>
					</div>
					<div class="metric-middle">
						<div class="metric-label">Leave Balance Remaining</div>
						<div class="metric-value-row">
							<span class="metric-number"><%=remainingLeaves%></span>
							<span class="metric-unit">/ <%=totalLeaveQuota%> Days</span>
						</div>
					</div>
					<div class="metric-progress-wrap">
						<div class="progress-track">
							<div class="progress-fill fill-amber" style="width: <%=leaveProgressPct%>%;"></div>
						</div>
						<div class="metric-sub-note">
							<span><%=leavesApprovedCount%> approved</span>
							<span><%=leavesPendingCount%> pending</span>
						</div>
					</div>
				</div>

				<!-- Card 3: Active Tasks & Deliverables -->
				<div class="metric-kpi-card">
					<div class="metric-top">
						<div class="metric-icon-box grad-purple">
							<i class="fa-solid fa-list-check"></i>
						</div>
						<span class="metric-tag-pill tag-purple">Execution</span>
					</div>
					<div class="metric-middle">
						<div class="metric-label">Active Deliverables</div>
						<div class="metric-value-row">
							<span class="metric-number"><%=activeTasksCount%></span>
							<span class="metric-unit">Active</span>
						</div>
					</div>
					<div class="metric-progress-wrap">
						<div class="progress-track">
							<div class="progress-fill fill-purple" style="width: <%=myTotalTasks > 0 ? (myCompletedTasks * 100 / myTotalTasks) : 0%>%;"></div>
						</div>
						<div class="metric-sub-note">
							<span><%=myCompletedTasks%> completed</span>
							<% if (myOverdueTasks > 0) { %>
								<span style="color: #ef4444; font-weight:700;"><%=myOverdueTasks%> overdue</span>
							<% } else { %>
								<span>0 overdue</span>
							<% } %>
						</div>
					</div>
				</div>

				<!-- Card 4: Upcoming Meetings & Syncs -->
				<div class="metric-kpi-card">
					<div class="metric-top">
						<div class="metric-icon-box grad-cyan">
							<i class="fa-solid fa-video"></i>
						</div>
						<span class="metric-tag-pill tag-cyan">Schedule</span>
					</div>
					<div class="metric-middle">
						<div class="metric-label">Upcoming Meetings</div>
						<div class="metric-value-row">
							<span class="metric-number"><%= (myDashboardMeetings != null ? myDashboardMeetings.size() : 0) %></span>
							<span class="metric-unit">Events</span>
						</div>
					</div>
					<div class="metric-progress-wrap">
						<div class="progress-track">
							<div class="progress-fill fill-cyan" style="width: 100%;"></div>
						</div>
						<div class="metric-sub-note">
							<span>Scheduled Syncs</span>
							<span>Connect Online</span>
						</div>
					</div>
				</div>
			</div>

			<!-- ==========================================================================
			     5. Quick Workspace Action Cards (4x2 Grid)
			     ========================================================================== -->
			<div>
				<div class="section-header-row">
					<div class="section-title">
						<i class="fa-solid fa-shapes"></i> Quick Workspace Actions
					</div>
				</div>

				<div class="quick-actions-grid">
					<!-- 1. Mark Attendance -->
					<a href="attendance.jsp" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-emerald">
									<i class="fa-regular fa-calendar-check"></i>
								</div>
								<span class="qa-badge"><%=totalPresentDays%> Days Present</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>Mark Attendance</h3>
								<p>Check in/out quickly, take breaks, and record daily work hours.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>Go to Attendance</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 2. Apply Leave -->
					<a href="applyLeave.jsp" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-amber">
									<i class="fa-solid fa-paper-plane"></i>
								</div>
								<span class="qa-badge"><%=remainingLeaves%> Days Available</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>Apply For Leave</h3>
								<p>Submit casual, sick, or privilege leave requests seamlessly.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>Submit Request</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 3. Leave History -->
					<a href="leaveHistory" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-purple">
									<i class="fa-solid fa-clock-rotate-left"></i>
								</div>
								<span class="qa-badge">
									<% if (leavesPendingCount > 0) { %>
										<%=leavesPendingCount%> Pending
									<% } else { %>
										<%=leavesApprovedCount%> Taken
									<% } %>
								</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>Leave History</h3>
								<p>Review leave applications, manager approvals, and rejection notes.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>View History</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 4. Attendance Report -->
					<a href="attendanceHistory" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-indigo">
									<i class="fa-solid fa-chart-simple"></i>
								</div>
								<span class="qa-badge">Monthly Log</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>Attendance Report</h3>
								<p>Track your monthly attendance records, check-in timestamps, and totals.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>View Logs</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 5. My Tasks -->
					<a href="myTasks" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-cyan">
									<i class="fa-solid fa-list-check"></i>
								</div>
								<span class="qa-badge"><%=activeTasksCount%> In Progress</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>My Assigned Tasks</h3>
								<p>Manage assigned deliverables, update status, and meet project deadlines.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>Manage Tasks</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 6. My Meetings -->
					<a href="myMeetings" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-blue">
									<i class="fa-solid fa-video"></i>
								</div>
								<span class="qa-badge"><%= (myDashboardMeetings != null ? myDashboardMeetings.size() : 0) %> Events</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>My Meetings</h3>
								<p>View conference invitations, accept schedules, and join video calls.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>View Meetings</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 7. My Payslips -->
					<a href="myPayroll" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-emerald">
									<i class="fa-solid fa-receipt"></i>
								</div>
								<span class="qa-badge">Salary Slip</span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>My Payslips</h3>
								<p>View monthly remuneration, earnings, deductions, and download slips.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>View Payslips</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>

					<!-- 8. My Profile -->
					<a href="employeeProfile.jsp" class="qa-card">
						<div>
							<div class="qa-card-top">
								<div class="qa-icon-box icon-pink">
									<i class="fa-regular fa-id-card"></i>
								</div>
								<span class="qa-badge"><%=designation%></span>
							</div>
							<div class="qa-card-body" style="margin-top: 14px;">
								<h3>My Employee Profile</h3>
								<p>View your employee credentials, contact records, and job parameters.</p>
							</div>
						</div>
						<div class="qa-arrow-btn">
							<span>Update Profile</span> <i class="fa-solid fa-arrow-right"></i>
						</div>
					</a>
				</div>
			</div>

			<!-- ==========================================================================
			     6. Dual Live Feeds: Meetings & Priority Tasks
			     ========================================================================== -->
			<div class="dual-feeds-grid">

				<!-- Left Panel: Scheduled Meetings -->
				<div class="feed-box-card">
					<div>
						<div class="feed-box-header">
							<div class="feed-box-title">
								<i class="fa-solid fa-calendar-day" style="color: var(--accent-cyan);"></i> My Scheduled Meetings
							</div>
							<a href="myMeetings" class="section-action-link">
								<span>View All</span> <i class="fa-solid fa-arrow-right"></i>
							</a>
						</div>

						<div class="feed-items-list">
							<%
							if (myDashboardMeetings != null && !myDashboardMeetings.isEmpty()) {
								int mCount = 0;
								for (Meeting m : myDashboardMeetings) {
									if (mCount++ >= 3) break;
									String dayNum = "Today";
									String monthStr = "NOW";
									if (m.getMeetingDate() != null) {
										dayNum = new SimpleDateFormat("dd").format(m.getMeetingDate());
										monthStr = new SimpleDateFormat("MMM").format(m.getMeetingDate());
									}
							%>
							<div class="feed-item-row">
								<div class="fir-left">
									<div class="cal-date-chip">
										<small><%=monthStr%></small>
										<span><%=dayNum%></span>
									</div>
									<div class="fir-details">
										<h4><%=m.getTitle() != null ? m.getTitle() : "Team Sync"%></h4>
										<p>
											<span><i class="fa-regular fa-clock"></i> <%=m.getStartTime() != null ? m.getStartTime().toString() : "TBD"%></span>
											<span>&bull;</span>
											<span><i class="fa-solid fa-location-dot"></i> <%=m.getMeetingMode() != null ? m.getMeetingMode() : "Online"%></span>
										</p>
									</div>
								</div>
								<div>
									<% if (m.getMeetingLink() != null && !m.getMeetingLink().isBlank()) { %>
										<a href="<%=m.getMeetingLink()%>" target="_blank" class="btn-join-meeting">
											<i class="fa-solid fa-video"></i> Join
										</a>
									<% } else { %>
										<a href="meetingDetail?meetingId=<%=m.getMeetingId()%>" class="btn-meeting-details">
											Details
										</a>
									<% } %>
								</div>
							</div>
							<%
								}
							} else {
							%>
							<div class="feed-empty-state">
								<i class="fa-regular fa-calendar-check"></i>
								<p>No meetings scheduled for today.</p>
							</div>
							<% } %>
						</div>
					</div>
				</div>

				<!-- Right Panel: Active Tasks & Deliverables -->
				<div class="feed-box-card">
					<div>
						<div class="feed-box-header">
							<div class="feed-box-title">
								<i class="fa-solid fa-list-check" style="color: var(--primary-indigo);"></i> My Active Deliverables
							</div>
							<a href="myTasks" class="section-action-link">
								<span>View All</span> <i class="fa-solid fa-arrow-right"></i>
							</a>
						</div>

						<div class="feed-items-list">
							<%
							if (myTasks != null && !myTasks.isEmpty()) {
								int tCount = 0;
								for (Task t : myTasks) {
									if (tCount++ >= 3) break;
									String prioDotClass = "prio-med";
									if (t.getPriority() == Priority.HIGH) prioDotClass = "prio-high";
									else if (t.getPriority() == Priority.LOW) prioDotClass = "prio-low";

									String chipClass = "chip-pend";
									if (t.getStatus() == TaskStatus.COMPLETED) chipClass = "chip-done";
									else if (t.getStatus() == TaskStatus.IN_PROGRESS) chipClass = "chip-prog";
							%>
							<div class="feed-item-row">
								<div class="fir-left">
									<div class="priority-dot-indicator <%=prioDotClass%>" title="Priority: <%=t.getPriority()%>"></div>
									<div class="fir-details">
										<h4><%=t.getTaskName() != null ? t.getTaskName() : "Task #" + t.getTaskId()%></h4>
										<p>
											<span><i class="fa-regular fa-clock"></i> Due: <%=t.getDueDate() != null ? t.getDueDate().toString() : "No deadline"%></span>
										</p>
									</div>
								</div>
								<div>
									<span class="task-status-chip <%=chipClass%>"><%=t.getStatus()%></span>
								</div>
							</div>
							<%
								}
							} else {
							%>
							<div class="feed-empty-state">
								<i class="fa-solid fa-circle-check" style="color: var(--accent-emerald);"></i>
								<p>You have no active tasks pending. Great work!</p>
							</div>
							<% } %>
						</div>
					</div>
				</div>

			</div>

			<!-- ==========================================================================
			     7. Recent Attendance Activity Table
			     ========================================================================== -->
			<div class="activity-card">
				<div class="section-header-row" style="margin-bottom: 14px;">
					<div class="section-title">
						<i class="fa-solid fa-clock-rotate-left"></i> Recent Attendance Records
					</div>
					<a href="attendanceHistory" class="section-action-link">
						<span>Full Attendance Report</span> <i class="fa-solid fa-arrow-right"></i>
					</a>
				</div>

				<div class="custom-table-wrap">
					<table class="modern-data-table">
						<thead>
							<tr>
								<th>Date</th>
								<th>Check In</th>
								<th>Check Out</th>
								<th>Break Details</th>
								<th>Status</th>
							</tr>
						</thead>
						<tbody>
							<%
							if (recentAttendance != null && !recentAttendance.isEmpty()) {
								int rCount = 0;
								for (Attendance att : recentAttendance) {
									if (rCount++ >= 4) break;
									String badgeClass = "sbadge-present";
									String st = att.getStatus() != null ? att.getStatus() : "Present";
									if ("Late".equalsIgnoreCase(st)) badgeClass = "sbadge-late";
									else if ("Half Day".equalsIgnoreCase(st)) badgeClass = "sbadge-half";
									else if ("Absent".equalsIgnoreCase(st)) badgeClass = "sbadge-absent";
							%>
							<tr>
								<td><strong><%=att.getAttendance_date() != null ? att.getAttendance_date().toString() : "-"%></strong></td>
								<td><%=att.getCheck_in_time() != null ? att.getCheck_in_time().toString() : "--:--"%></td>
								<td><%=att.getCheck_out_time() != null ? att.getCheck_out_time().toString() : "--:--"%></td>
								<td>
									<% if (att.getBreak_start_time() != null) { %>
										<%=att.getBreak_start_time()%> - <%=att.getBreak_end_time() != null ? att.getBreak_end_time().toString() : "Active"%>
									<% } else { %>
										<span style="color: var(--text-light);">No break recorded</span>
									<% } %>
								</td>
								<td>
									<span class="status-badge-table <%=badgeClass%>">
										<i class="fa-solid fa-circle" style="font-size: 7px;"></i> <%=st%>
									</span>
								</td>
							</tr>
							<%
								}
							} else {
							%>
							<tr>
								<td colspan="5" style="text-align: center; color: var(--text-muted); padding: 24px;">
									No recent attendance records found.
								</td>
							</tr>
							<% } %>
						</tbody>
					</table>
				</div>
			</div>

		</main>
	</div>

	<!-- ==========================================================================
	     8. Real-time Clock & Dynamic Greeting Scripts
	     ========================================================================== -->
	<script>
		// Live Real-Time Clock
		function updateLiveClock() {
			const now = new Date();
			let hours = now.getHours();
			let minutes = now.getMinutes();
			let seconds = now.getSeconds();
			const ampm = hours >= 12 ? 'PM' : 'AM';

			hours = hours % 12;
			hours = hours ? hours : 12; // 12-hour format
			const strHours = hours < 10 ? '0' + hours : hours;
			const strMinutes = minutes < 10 ? '0' + minutes : minutes;
			const strSeconds = seconds < 10 ? '0' + seconds : seconds;

			const clockElem = document.getElementById('liveClockDisplay');
			if (clockElem) {
				clockElem.textContent = strHours + ':' + strMinutes + ':' + strSeconds + ' ' + ampm;
			}

			// Dynamic Greeting
			const rawHour = now.getHours();
			const greetingText = document.getElementById('dynamicGreetingText');
			const greetingIcon = document.getElementById('dynamicGreetingIcon');

			if (greetingText && greetingIcon) {
				if (rawHour >= 5 && rawHour < 12) {
					greetingText.textContent = 'Good morning';
					greetingIcon.innerHTML = '<i class="fa-solid fa-sun" style="color:#f59e0b;"></i>';
				} else if (rawHour >= 12 && rawHour < 17) {
					greetingText.textContent = 'Good afternoon';
					greetingIcon.innerHTML = '<i class="fa-solid fa-cloud-sun" style="color:#0284c7;"></i>';
				} else {
					greetingText.textContent = 'Good evening';
					greetingIcon.innerHTML = '<i class="fa-solid fa-moon" style="color:#6366f1;"></i>';
				}
			}
		}

		setInterval(updateLiveClock, 1000);
		updateLiveClock();

		// Mobile Sidebar Toggle
		const mobileBtn = document.getElementById('mobileMenuBtn');
		const sidebar = document.getElementById('appSidebar');

		if (mobileBtn && sidebar) {
			mobileBtn.addEventListener('click', function(e) {
				e.stopPropagation();
				sidebar.classList.toggle('mobile-open');
			});

			document.addEventListener('click', function(e) {
				if (sidebar.classList.contains('mobile-open') && !sidebar.contains(e.target) && e.target !== mobileBtn) {
					sidebar.classList.remove('mobile-open');
				}
			});
		}
	</script>

</body>
</html>