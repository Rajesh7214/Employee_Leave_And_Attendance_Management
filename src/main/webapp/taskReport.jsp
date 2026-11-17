<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.time.temporal.ChronoUnit"%>
<%@ page import="com.rajesh.elams.model.Task"%>
<%@ page import="com.rajesh.elams.model.Employee"%>

<%
List<Task> taskList = (List<Task>) request.getAttribute("taskList");
List<Employee> employeeList = (List<Employee>) request.getAttribute("employeeList");
if (employeeList == null) {
	try {
		com.rajesh.elams.dao.EmployeeDao empDao = new com.rajesh.elams.dao.EmployeeDaoImpl();
		employeeList = empDao.getAllEmployees();
	} catch (Exception ignored) {}
}

Map<Integer, Employee> employeeMap = new HashMap<>();
if (employeeList != null) {
	for (Employee emp : employeeList) {
		employeeMap.put(emp.getEmployee_id(), emp);
	}
}

String userRole = (String) session.getAttribute("role");
String backDashUrl = "admin".equalsIgnoreCase(userRole) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(userRole) ? "hrDashboard" : "managerDashboard";

Object totalObj = request.getAttribute("totalTasks");
Object compObj = request.getAttribute("completedTasks");
Object pendObj = request.getAttribute("pendingTasks");
Object progObj = request.getAttribute("inProgressTasks");
Object overObj = request.getAttribute("overdueTasks");

int totalCount = totalObj != null ? Integer.parseInt(totalObj.toString()) : (taskList != null ? taskList.size() : 0);
int completedCount = compObj != null ? Integer.parseInt(compObj.toString()) : 0;
int pendingCount = pendObj != null ? Integer.parseInt(pendObj.toString()) : 0;
int inProgressCount = progObj != null ? Integer.parseInt(progObj.toString()) : 0;
int overdueCount = overObj != null ? Integer.parseInt(overObj.toString()) : 0;

int completionRate = totalCount > 0 ? (int) Math.round(((double) completedCount / totalCount) * 100) : 0;
%>

<!DOCTYPE html>
<html lang="en" data-theme="white-blue-grey">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Task Management & Reports | ELAMS SmartOffice</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />

<style>
/* ========================================================= */
/* WHITE BLUE GREY DESIGN SYSTEM                             */
/* ========================================================= */

:root, [data-theme="white-blue-grey"] {
	--bg-dark: #f4f6fb;
	--bg-gradient: radial-gradient(at 15% 15%, rgba(37, 99, 235, 0.08) 0px, transparent 50%),
		radial-gradient(at 85% 85%, rgba(148, 163, 184, 0.14) 0px, transparent 50%),
		radial-gradient(at 50% 50%, rgba(2, 132, 199, 0.06) 0px, transparent 50%);
	--card-glass: #ffffff;
	--card-inner: #f8fafc;
	--border-glass: #cbd5e1;
	--neon-indigo: #2563eb;
	--neon-cyan: #0284c7;
	--neon-emerald: #059669;
	--neon-amber: #d97706;
	--neon-rose: #dc2626;
	--text-light: #0f172a;
	--text-muted: #64748b;
	--input-bg: #ffffff;
	--table-row-bg: #ffffff;
	--table-row-hover: #f1f5f9;
	--modal-bg: #ffffff;
}

* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
	transition: background-color 0.25s ease, border-color 0.25s ease, color 0.25s ease;
}

body {
	background-color: var(--bg-dark);
	background-image: var(--bg-gradient);
	background-attachment: fixed;
	color: var(--text-light);
	min-height: 100vh;
}

.container {
	max-width: 1460px;
	margin: 0 auto;
	padding: 30px 24px;
}

/* Header Navbar */
.page-header {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border-radius: 24px;
	padding: 22px 30px;
	border: 1px solid var(--border-glass);
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24px;
	flex-wrap: wrap;
	gap: 16px;
}

.page-title {
	display: flex;
	align-items: center;
	gap: 18px;
}

.title-icon {
	width: 56px;
	height: 56px;
	border-radius: 18px;
	background: linear-gradient(135deg, var(--neon-cyan) 0%, var(--neon-indigo) 100%);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24px;
	box-shadow: 0 10px 25px rgba(37, 99, 235, 0.3);
}

.page-title h1 {
	font-size: 22px;
	font-weight: 800;
	letter-spacing: -0.5px;
	color: var(--text-light);
}

.page-title p {
	font-size: 13px;
	color: var(--text-muted);
	margin-top: 4px;
}

.header-actions {
	display: flex;
	align-items: center;
	gap: 10px;
	flex-wrap: wrap;
}

.btn-action {
	padding: 10px 18px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
	cursor: pointer;
	border: none;
	outline: none;
}

.btn-create {
	background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
	color: #ffffff;
	box-shadow: 0 4px 15px rgba(37, 99, 235, 0.3);
}
.btn-create:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 25px rgba(37, 99, 235, 0.4);
}

.btn-export {
	background: rgba(2, 132, 199, 0.12);
	border: 1px solid rgba(2, 132, 199, 0.3);
	color: var(--neon-cyan);
}
.btn-export:hover {
	background: rgba(2, 132, 199, 0.2);
	transform: translateY(-2px);
}

.btn-print {
	background: rgba(217, 119, 6, 0.12);
	border: 1px solid rgba(217, 119, 6, 0.3);
	color: var(--neon-amber);
}
.btn-print:hover {
	background: rgba(217, 119, 6, 0.2);
	transform: translateY(-2px);
}

.btn-back {
	background: rgba(148, 163, 184, 0.12);
	border: 1px solid var(--border-glass);
	color: var(--text-light);
}
.btn-back:hover {
	background: rgba(148, 163, 184, 0.22);
	transform: translateY(-2px);
}

/* KPI Summary Cards & Analytics Grid */
.analytics-grid {
	display: grid;
	grid-template-columns: 1fr 340px;
	gap: 20px;
	margin-bottom: 24px;
}

@media (max-width: 1100px) {
	.analytics-grid {
		grid-template-columns: 1fr;
	}
}

.summary-grid {
	display: grid;
	grid-template-columns: repeat(5, 1fr);
	gap: 16px;
}

@media (max-width: 900px) {
	.summary-grid {
		grid-template-columns: repeat(2, 1fr);
	}
}

.summary-card {
	background: var(--card-glass);
	backdrop-filter: blur(16px);
	border: 1px solid var(--border-glass);
	border-radius: 20px;
	padding: 18px 20px;
	display: flex;
	align-items: center;
	gap: 14px;
	transition: all 0.25s ease;
	position: relative;
	overflow: hidden;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.summary-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

.card-icon {
	width: 46px;
	height: 46px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	flex-shrink: 0;
}

.card-total .card-icon { background: rgba(37, 99, 235, 0.12); color: var(--neon-indigo); }
.card-comp .card-icon { background: rgba(5, 150, 105, 0.12); color: var(--neon-emerald); }
.card-pend .card-icon { background: rgba(217, 119, 6, 0.12); color: var(--neon-amber); }
.card-prog .card-icon { background: rgba(2, 132, 199, 0.12); color: var(--neon-cyan); }
.card-over .card-icon { background: rgba(220, 38, 38, 0.12); color: var(--neon-rose); }

.card-info h4 {
	font-size: 24px;
	font-weight: 800;
	font-family: 'JetBrains Mono', monospace;
	line-height: 1.1;
	color: var(--text-light);
}

.card-info p {
	font-size: 11.5px;
	color: var(--text-muted);
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-top: 4px;
}

/* Completion Rate Widget */
.progress-widget-card {
	background: var(--card-glass);
	backdrop-filter: blur(16px);
	border: 1px solid var(--border-glass);
	border-radius: 20px;
	padding: 18px 22px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.progress-ring-container {
	position: relative;
	width: 72px;
	height: 72px;
	flex-shrink: 0;
}
.progress-ring-circle {
	transform: rotate(-90deg);
	transform-origin: 50% 50%;
}
.progress-ring-text {
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	font-size: 15px;
	font-weight: 800;
	font-family: 'JetBrains Mono';
	color: var(--neon-emerald);
}

.progress-widget-info h5 {
	font-size: 14px;
	font-weight: 700;
	color: var(--text-light);
	margin-bottom: 4px;
}
.progress-widget-info p {
	font-size: 12px;
	color: var(--text-muted);
	line-height: 1.4;
}

/* Distribution Progress Bar */
.dist-bar-wrapper {
	margin-top: 8px;
	width: 100%;
	height: 7px;
	background: rgba(148, 163, 184, 0.18);
	border-radius: 999px;
	overflow: hidden;
	display: flex;
}
.dist-comp { background: var(--neon-emerald); }
.dist-prog { background: var(--neon-cyan); }
.dist-pend { background: var(--neon-amber); }
.dist-over { background: var(--neon-rose); }

/* Control & Filter Bar */
.control-bar {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border: 1px solid var(--border-glass);
	border-radius: 20px;
	padding: 16px 20px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20px;
	flex-wrap: wrap;
	gap: 14px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.filter-left {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
	flex: 1;
}

.search-box {
	position: relative;
	min-width: 260px;
	flex: 1;
	max-width: 380px;
}
.search-box i {
	position: absolute;
	left: 14px;
	top: 50%;
	transform: translateY(-50%);
	color: var(--text-muted);
	font-size: 13px;
}
.search-input {
	width: 100%;
	background: var(--input-bg);
	border: 1px solid var(--border-glass);
	padding: 9px 14px 9px 36px;
	border-radius: 12px;
	color: var(--text-light);
	font-size: 13px;
	outline: none;
	transition: all 0.2s;
}
.search-input:focus {
	border-color: var(--neon-indigo);
	box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
}

.filter-pills {
	display: flex;
	gap: 6px;
	flex-wrap: wrap;
}
.filter-pill {
	background: rgba(148, 163, 184, 0.1);
	border: 1px solid var(--border-glass);
	color: var(--text-muted);
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.15s ease;
}
.filter-pill:hover {
	color: var(--text-light);
	border-color: var(--neon-indigo);
}
.filter-pill.active {
	background: var(--neon-indigo);
	color: #ffffff;
	border-color: var(--neon-indigo);
}

/* View Switcher Controls (Table / Kanban / Analytics / Calendar) */
.view-switcher {
	display: flex;
	background: var(--card-inner);
	border: 1px solid var(--border-glass);
	border-radius: 14px;
	padding: 4px;
	gap: 4px;
	flex-wrap: wrap;
}
.btn-view-toggle {
	background: transparent;
	border: none;
	color: var(--text-muted);
	padding: 7px 14px;
	border-radius: 10px;
	font-size: 12.5px;
	font-weight: 700;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.15s ease;
}
.btn-view-toggle.active {
	background: var(--neon-indigo);
	color: #ffffff;
	box-shadow: 0 2px 8px rgba(37, 99, 235, 0.3);
}

/* ========================================================= */
/* VIEW 1: DATA TABLE STYLING                                */
/* ========================================================= */
.glass-card {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border: 1px solid var(--border-glass);
	border-radius: 24px;
	padding: 24px;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
	margin-bottom: 24px;
	overflow: hidden;
}

.table-responsive {
	overflow-x: auto;
}

table {
	width: 100%;
	border-collapse: separate;
	border-spacing: 0 8px;
	text-align: left;
}

th {
	padding: 12px 16px;
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.6px;
	color: var(--text-muted);
	border: none;
}

tbody tr {
	background: var(--table-row-bg);
	border: 1px solid var(--border-glass);
	border-radius: 16px;
	transition: all 0.2s ease;
	cursor: pointer;
}

tbody tr:hover {
	background: var(--table-row-hover);
	transform: translateY(-2px);
	box-shadow: 0 6px 16px rgba(0, 0, 0, 0.05);
}

td {
	padding: 16px;
	font-size: 13.5px;
	vertical-align: middle;
	border-top: 1px solid var(--border-glass);
	border-bottom: 1px solid var(--border-glass);
	color: var(--text-light);
}

td:first-child {
	border-left: 1px solid var(--border-glass);
	border-top-left-radius: 16px;
	border-bottom-left-radius: 16px;
}

td:last-child {
	border-right: 1px solid var(--border-glass);
	border-top-right-radius: 16px;
	border-bottom-right-radius: 16px;
}

/* Badges & Chips */
.badge {
	font-size: 11px;
	font-weight: 800;
	padding: 4px 10px;
	border-radius: 20px;
	text-transform: uppercase;
	letter-spacing: 0.4px;
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

.badge-low { background: rgba(2, 132, 199, 0.12); color: var(--neon-cyan); border: 1px solid rgba(2, 132, 199, 0.25); }
.badge-medium { background: rgba(37, 99, 235, 0.12); color: var(--neon-indigo); border: 1px solid rgba(37, 99, 235, 0.25); }
.badge-high { background: rgba(217, 119, 6, 0.12); color: var(--neon-amber); border: 1px solid rgba(217, 119, 6, 0.25); }
.badge-critical { background: rgba(220, 38, 38, 0.12); color: var(--neon-rose); border: 1px solid rgba(220, 38, 38, 0.25); }

.badge-completed { background: rgba(5, 150, 105, 0.12); color: var(--neon-emerald); border: 1px solid rgba(5, 150, 105, 0.3); }
.badge-progress { background: rgba(2, 132, 199, 0.12); color: var(--neon-cyan); border: 1px solid rgba(2, 132, 199, 0.3); }
.badge-pending { background: rgba(217, 119, 6, 0.12); color: var(--neon-amber); border: 1px solid rgba(217, 119, 6, 0.3); }
.badge-overdue { background: rgba(220, 38, 38, 0.12); color: var(--neon-rose); border: 1px solid rgba(220, 38, 38, 0.3); }

.emp-badge {
	display: inline-flex;
	align-items: center;
	gap: 8px;
}
.emp-avatar {
	width: 30px;
	height: 30px;
	border-radius: 50%;
	background: linear-gradient(135deg, var(--neon-indigo), var(--neon-cyan));
	color: #fff;
	font-size: 11px;
	font-weight: 800;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.countdown-chip {
	font-size: 11px;
	font-weight: 700;
	padding: 2px 8px;
	border-radius: 10px;
	display: inline-block;
	margin-top: 4px;
}
.countdown-overdue { background: rgba(220, 38, 38, 0.12); color: var(--neon-rose); }
.countdown-today { background: rgba(217, 119, 6, 0.12); color: var(--neon-amber); }
.countdown-future { background: rgba(2, 132, 199, 0.12); color: var(--neon-cyan); }

/* ========================================================= */
/* VIEW 2: KANBAN BOARD WITH DRAG & DROP                     */
/* ========================================================= */
.kanban-board {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	gap: 18px;
	margin-bottom: 24px;
}

@media (max-width: 1024px) {
	.kanban-board {
		grid-template-columns: repeat(2, 1fr);
	}
}
@media (max-width: 640px) {
	.kanban-board {
		grid-template-columns: 1fr;
	}
}

.kanban-col {
	background: var(--card-glass);
	border: 1px solid var(--border-glass);
	border-radius: 20px;
	padding: 16px;
	display: flex;
	flex-direction: column;
	min-height: 520px;
	transition: all 0.2s ease;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
}

.kanban-col.drag-over {
	border-color: var(--neon-indigo);
	background: rgba(37, 99, 235, 0.08);
	box-shadow: 0 0 20px rgba(37, 99, 235, 0.2);
}

.kanban-col-head {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding-bottom: 12px;
	margin-bottom: 14px;
	border-bottom: 1px solid var(--border-glass);
}
.kanban-col-title {
	font-size: 13.5px;
	font-weight: 800;
	display: flex;
	align-items: center;
	gap: 8px;
}

.col-pending .kanban-col-title { color: var(--neon-amber); }
.col-progress .kanban-col-title { color: var(--neon-cyan); }
.col-completed .kanban-col-title { color: var(--neon-emerald); }
.col-overdue .kanban-col-title { color: var(--neon-rose); }

.kanban-col-count {
	font-size: 11.5px;
	font-weight: 800;
	padding: 2px 8px;
	border-radius: 12px;
	background: rgba(148, 163, 184, 0.15);
	color: var(--text-light);
}

.kanban-card-list {
	display: flex;
	flex-direction: column;
	gap: 12px;
	flex: 1;
	overflow-y: auto;
	max-height: 70vh;
	padding: 4px;
}

.kanban-card {
	background: var(--card-inner);
	border: 1px solid var(--border-glass);
	border-radius: 16px;
	padding: 14px;
	transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
	cursor: grab;
	position: relative;
}

.kanban-card:active {
	cursor: grabbing;
}

.kanban-card.dragging {
	opacity: 0.4;
	transform: scale(0.95);
}

.kanban-card:hover {
	transform: translateY(-2px);
	border-color: var(--neon-indigo);
	box-shadow: 0 6px 16px rgba(37, 99, 235, 0.12);
}

.kanban-card-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 8px;
}

.kanban-card-title {
	font-size: 14px;
	font-weight: 700;
	color: var(--text-light);
	margin-bottom: 6px;
	line-height: 1.35;
}

.kanban-card-desc {
	font-size: 12.5px;
	color: var(--text-muted);
	line-height: 1.4;
	margin-bottom: 12px;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.kanban-card-footer {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding-top: 10px;
	border-top: 1px solid var(--border-glass);
	font-size: 11.5px;
}

/* ========================================================= */
/* VIEW 3: VISUAL ANALYTICS DASHBOARD                        */
/* ========================================================= */
.analytics-view-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 20px;
	margin-bottom: 24px;
}

@media (max-width: 1024px) {
	.analytics-view-grid {
		grid-template-columns: 1fr;
	}
}

.chart-card {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border: 1px solid var(--border-glass);
	border-radius: 24px;
	padding: 24px;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
}

.chart-card-title {
	font-size: 16px;
	font-weight: 800;
	color: var(--text-light);
	display: flex;
	align-items: center;
	gap: 10px;
	margin-bottom: 20px;
}

.priority-bar-row {
	margin-bottom: 16px;
}
.priority-bar-label {
	display: flex;
	justify-content: space-between;
	font-size: 12.5px;
	font-weight: 700;
	color: var(--text-light);
	margin-bottom: 6px;
}
.priority-bar-track {
	height: 10px;
	background: rgba(148, 163, 184, 0.15);
	border-radius: 999px;
	overflow: hidden;
}
.priority-bar-fill {
	height: 100%;
	border-radius: 999px;
	transition: width 0.6s ease;
}

.emp-workload-grid {
	display: grid;
	grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
	gap: 16px;
}

.emp-workload-card {
	background: var(--card-inner);
	border: 1px solid var(--border-glass);
	border-radius: 16px;
	padding: 16px;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

/* ========================================================= */
/* VIEW 4: INTERACTIVE TASK CALENDAR VIEW                    */
/* ========================================================= */
.calendar-card {
	background: var(--card-glass);
	backdrop-filter: blur(20px);
	border: 1px solid var(--border-glass);
	border-radius: 24px;
	padding: 24px;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.04);
	margin-bottom: 24px;
}

.calendar-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 20px;
	flex-wrap: wrap;
	gap: 12px;
}

.calendar-controls {
	display: flex;
	align-items: center;
	gap: 10px;
}

.calendar-title-text {
	font-size: 18px;
	font-weight: 800;
	color: var(--text-light);
	font-family: 'JetBrains Mono', monospace;
}

.calendar-grid {
	display: grid;
	grid-template-columns: repeat(7, 1fr);
	gap: 8px;
}

.cal-day-head {
	text-align: center;
	font-size: 12px;
	font-weight: 800;
	color: var(--text-muted);
	text-transform: uppercase;
	padding: 8px;
}

.cal-day-cell {
	background: var(--card-inner);
	border: 1px solid var(--border-glass);
	border-radius: 14px;
	min-height: 100px;
	padding: 8px;
	display: flex;
	flex-direction: column;
	gap: 4px;
	position: relative;
}

.cal-day-cell.today-cell {
	border-color: var(--neon-indigo);
	box-shadow: inset 0 0 0 1px var(--neon-indigo);
}

.cal-day-num {
	font-size: 12px;
	font-weight: 800;
	color: var(--text-muted);
	margin-bottom: 4px;
}

.cal-task-chip {
	font-size: 11px;
	font-weight: 700;
	padding: 3px 6px;
	border-radius: 6px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	cursor: pointer;
	display: flex;
	align-items: center;
	gap: 4px;
}

/* ========================================================= */
/* TASK DETAIL MODAL                                         */
/* ========================================================= */
.task-modal-backdrop {
	position: fixed;
	top: 0;
	left: 0;
	width: 100vw;
	height: 100vh;
	background: rgba(15, 23, 42, 0.6);
	backdrop-filter: blur(14px);
	z-index: 999999;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20px;
}

.task-modal-card {
	background: var(--modal-bg);
	border: 1px solid var(--border-glass);
	border-radius: 24px;
	box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
	width: 100%;
	max-width: 580px;
	overflow: hidden;
	display: flex;
	flex-direction: column;
	color: var(--text-light);
	text-align: left;
	animation: modalPop 0.2s ease-out;
}

@keyframes modalPop {
	from { transform: scale(0.92); opacity: 0; }
	to { transform: scale(1); opacity: 1; }
}

.task-modal-head {
	padding: 20px 24px;
	border-bottom: 1px solid var(--border-glass);
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.task-modal-body {
	padding: 24px;
	display: flex;
	flex-direction: column;
	gap: 18px;
	max-height: 65vh;
	overflow-y: auto;
}

.task-meta-grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 12px;
	background: var(--card-inner);
	border: 1px solid var(--border-glass);
	border-radius: 14px;
	padding: 14px;
	font-size: 12.5px;
}

.task-status-control {
	background: rgba(37, 99, 235, 0.08);
	border: 1px solid rgba(37, 99, 235, 0.25);
	border-radius: 14px;
	padding: 14px 16px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 12px;
}

.task-modal-footer {
	padding: 16px 24px;
	border-top: 1px solid var(--border-glass);
	display: flex;
	justify-content: space-between;
	align-items: center;
}

/* Toast Feedback */
.task-toast {
	position: fixed;
	bottom: 24px;
	right: 24px;
	background: var(--neon-emerald);
	color: #ffffff;
	padding: 10px 18px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 700;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
	z-index: 9999999;
	display: flex;
	align-items: center;
	gap: 8px;
}

/* PRINT STYLES */
@media print {
	body { background: #ffffff !important; color: #000000 !important; }
	.header-actions, .control-bar, .kanban-board, .btn-tbl, .analytics-view-grid, .calendar-card { display: none !important; }
	.container { max-width: 100% !important; padding: 0 !important; }
	.page-header { background: none !important; border: none !important; box-shadow: none !important; color: #000 !important; }
	.glass-card { background: none !important; border: 1px solid #ccc !important; box-shadow: none !important; }
	table { border-collapse: collapse !important; }
	th, td { border: 1px solid #ccc !important; color: #000 !important; padding: 8px !important; }
}
</style>
</head>

<body>

	<div class="container">

		<!-- 1. Header Bar -->
		<div class="page-header">
			<div class="page-title">
				<div class="title-icon">
					<i class="fa-solid fa-list-check"></i>
				</div>
				<div>
					<h1>Task Management & Reports</h1>
					<p>White Blue & Grey Suite • Kanban ⇄ Data Table ⇄ Analytics ⇄ Calendar</p>
				</div>
			</div>
			<div class="header-actions">
				<a href="createTask" class="btn-action btn-create">
					<i class="fa-solid fa-plus"></i> Create New Task
				</a>
				<a href="exportTaskReport" class="btn-action btn-export" title="Export CSV">
					<i class="fa-solid fa-file-csv"></i> Export CSV
				</a>
				<button type="button" class="btn-action btn-print" onclick="window.print()" title="Print Summary Report">
					<i class="fa-solid fa-print"></i> Print Report
				</button>
				<a href="<%=backDashUrl%>" class="btn-action btn-back">
					<i class="fa-solid fa-arrow-left"></i> Dashboard
				</a>
				<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
			</div>
		</div>

		<!-- 2. Visual Analytics & KPI Metric Cards Grid -->
		<div class="analytics-grid">
			<div class="summary-grid">
				<div class="summary-card card-total">
					<div class="card-icon"><i class="fa-solid fa-list-check"></i></div>
					<div class="card-info">
						<h4 id="statTotal"><%=totalCount%></h4>
						<p>Total Tasks</p>
					</div>
				</div>
				<div class="summary-card card-comp">
					<div class="card-icon"><i class="fa-solid fa-circle-check"></i></div>
					<div class="card-info">
						<h4 id="statComp"><%=completedCount%></h4>
						<p>Completed</p>
					</div>
				</div>
				<div class="summary-card card-pend">
					<div class="card-icon"><i class="fa-solid fa-hourglass-half"></i></div>
					<div class="card-info">
						<h4 id="statPend"><%=pendingCount%></h4>
						<p>Pending</p>
					</div>
				</div>
				<div class="summary-card card-prog">
					<div class="card-icon"><i class="fa-solid fa-spinner"></i></div>
					<div class="card-info">
						<h4 id="statProg"><%=inProgressCount%></h4>
						<p>In Progress</p>
					</div>
				</div>
				<div class="summary-card card-over">
					<div class="card-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
					<div class="card-info">
						<h4 id="statOver"><%=overdueCount%></h4>
						<p>Overdue</p>
					</div>
				</div>
			</div>

			<!-- Completion Rate Gauge Card -->
			<div class="progress-widget-card">
				<div class="progress-ring-container">
					<svg width="72" height="72">
						<circle stroke="rgba(148,163,184,0.2)" stroke-width="6" fill="transparent" r="30" cx="36" cy="36" />
						<circle class="progress-ring-circle" stroke="var(--neon-emerald)" stroke-width="6" stroke-linecap="round" fill="transparent" r="30" cx="36" cy="36"
							stroke-dasharray="188.4" stroke-dashoffset="<%= 188.4 - (188.4 * completionRate / 100) %>" id="rateCircle" />
					</svg>
					<span class="progress-ring-text" id="rateText"><%=completionRate%>%</span>
				</div>
				<div class="progress-widget-info" style="flex: 1;">
					<h5>Completion Velocity</h5>
					<p><span id="rateSummary"><%=completedCount%> of <%=totalCount%></span> tasks accomplished</p>
					<div class="dist-bar-wrapper">
						<div class="dist-comp" id="distCompBar" style="width: <%= totalCount > 0 ? (completedCount * 100 / totalCount) : 0 %>%;"></div>
						<div class="dist-prog" id="distProgBar" style="width: <%= totalCount > 0 ? (inProgressCount * 100 / totalCount) : 0 %>%;"></div>
						<div class="dist-pend" id="distPendBar" style="width: <%= totalCount > 0 ? (pendingCount * 100 / totalCount) : 0 %>%;"></div>
						<div class="dist-over" id="distOverBar" style="width: <%= totalCount > 0 ? (overdueCount * 100 / totalCount) : 0 %>%;"></div>
					</div>
				</div>
			</div>
		</div>

		<!-- 3. Control & Filter Bar (Search, Filters, 4-View Switcher) -->
		<div class="control-bar">
			<div class="filter-left">
				<div class="search-box">
					<i class="fa-solid fa-magnifying-glass"></i>
					<input type="text" id="taskSearchInput" class="search-input" placeholder="Search task name, employee, or ID..." onkeyup="applyTaskFilters()">
				</div>
				<div class="filter-pills">
					<button type="button" class="filter-pill active" data-filter="all" onclick="setTaskFilter('all', this)">All Tasks</button>
					<button type="button" class="filter-pill" data-filter="pending" onclick="setTaskFilter('pending', this)">⏳ Pending</button>
					<button type="button" class="filter-pill" data-filter="in_progress" onclick="setTaskFilter('in_progress', this)">🔄 In Progress</button>
					<button type="button" class="filter-pill" data-filter="completed" onclick="setTaskFilter('completed', this)">✅ Completed</button>
					<button type="button" class="filter-pill" data-filter="overdue" onclick="setTaskFilter('overdue', this)">⚠️ Overdue</button>
					<button type="button" class="filter-pill" data-filter="high" onclick="setTaskFilter('high', this)">🔥 High/Critical</button>
				</div>
			</div>

			<!-- Multi-View Suite Switcher -->
			<div class="view-switcher">
				<button type="button" id="btnViewTable" class="btn-view-toggle active" onclick="switchView('table')">
					<i class="fa-solid fa-table-list"></i> Table View
				</button>
				<button type="button" id="btnViewKanban" class="btn-view-toggle" onclick="switchView('kanban')">
					<i class="fa-solid fa-table-columns"></i> Kanban Board
				</button>
				<button type="button" id="btnViewAnalytics" class="btn-view-toggle" onclick="switchView('analytics')">
					<i class="fa-solid fa-chart-pie"></i> Analytics
				</button>
				<button type="button" id="btnViewCalendar" class="btn-view-toggle" onclick="switchView('calendar')">
					<i class="fa-solid fa-calendar-days"></i> Calendar
				</button>
			</div>
		</div>

		<!-- 4. VIEW 1: Interactive Data Table (Clean Rows — Click row to open details modal) -->
		<div id="tableViewSection" class="glass-card">
			<div class="table-responsive">
				<table>
					<thead>
						<tr>
							<th>Task ID</th>
							<th>Task Name & Overview</th>
							<th>Assigned Employee</th>
							<th>Priority</th>
							<th>Status</th>
							<th>Assigned Date</th>
							<th>Due Date</th>
							<th>Completed Date</th>
						</tr>
					</thead>
					<tbody id="taskTableBody">
						<%
						if (taskList != null && !taskList.isEmpty()) {
							LocalDate today = LocalDate.now();
							for (Task task : taskList) {
								String prioStr = task.getPriority() != null ? task.getPriority().name() : "MEDIUM";
								String prioBadge = "badge-medium";
								if ("HIGH".equalsIgnoreCase(prioStr) || "CRITICAL".equalsIgnoreCase(prioStr)) prioBadge = "badge-high";
								else if ("LOW".equalsIgnoreCase(prioStr)) prioBadge = "badge-low";

								String statusStr = task.getStatus() != null ? task.getStatus().name() : "PENDING";
								String statusBadge = "badge-pending";
								if ("COMPLETED".equalsIgnoreCase(statusStr)) statusBadge = "badge-completed";
								else if ("IN_PROGRESS".equalsIgnoreCase(statusStr)) statusBadge = "badge-progress";
								else if ("OVERDUE".equalsIgnoreCase(statusStr)) statusBadge = "badge-overdue";

								Employee assignedEmp = employeeMap.get(task.getEmployeeId());
								String empName = assignedEmp != null && assignedEmp.getEmployee_name() != null ? assignedEmp.getEmployee_name() : "Emp #" + task.getEmployeeId();
								String empDept = assignedEmp != null && assignedEmp.getDepartment() != null ? assignedEmp.getDepartment() : "General";
								String empInitials = empName.length() >= 2 ? empName.substring(0, 2).toUpperCase() : "EM";

								String countdownHtml = "";
								if (task.getDueDate() != null) {
									try {
										LocalDate dueDate = task.getDueDate().toLocalDate();
										long daysDiff = ChronoUnit.DAYS.between(today, dueDate);
										if ("COMPLETED".equalsIgnoreCase(statusStr)) {
											countdownHtml = "<span class=\"countdown-chip countdown-future\">Finished</span>";
										} else if (daysDiff < 0) {
											countdownHtml = "<span class=\"countdown-chip countdown-overdue\">" + Math.abs(daysDiff) + "d overdue</span>";
										} else if (daysDiff == 0) {
											countdownHtml = "<span class=\"countdown-chip countdown-today\">Due today</span>";
										} else {
											countdownHtml = "<span class=\"countdown-chip countdown-future\">" + daysDiff + "d left</span>";
										}
									} catch (Exception ignored) {}
								}
						%>
						<tr class="task-row"
							data-id="<%=task.getTaskId()%>"
							data-name="<%=task.getTaskName() != null ? task.getTaskName().replace("\"", "&quot;") : ""%>"
							data-desc="<%=task.getDescription() != null ? task.getDescription().replace("\"", "&quot;") : ""%>"
							data-empid="<%=task.getEmployeeId()%>"
							data-empname="<%=empName.replace("\"", "&quot;")%>"
							data-empdept="<%=empDept.replace("\"", "&quot;")%>"
							data-assignedby="<%=task.getAssignedBy() != null ? task.getAssignedBy().replace("\"", "&quot;") : "Management"%>"
							data-prio="<%=prioStr%>"
							data-status="<%=statusStr%>"
							data-assigneddate="<%=task.getAssignedDate() != null ? task.getAssignedDate().toString() : ""%>"
							data-duedate="<%=task.getDueDate() != null ? task.getDueDate().toString() : ""%>"
							data-compdate="<%=task.getCompletionDate() != null ? task.getCompletionDate().toString() : ""%>"
							onclick="openTaskModalFromElement(this)"
							title="Click to view task details">
							
							<td style="font-family: 'JetBrains Mono', monospace; font-weight: 700; color: var(--neon-indigo);">#<%=task.getTaskId()%></td>
							
							<td>
								<div style="font-weight: 700; color: var(--text-light); font-size: 14px; margin-bottom: 2px;"><%=task.getTaskName()%></div>
								<div style="font-size: 12px; color: var(--text-muted); max-width: 320px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"><%=task.getDescription()%></div>
							</td>
							
							<td>
								<div class="emp-badge">
									<div class="emp-avatar"><%=empInitials%></div>
									<div>
										<div style="font-weight: 600; color: var(--text-light);"><%=empName%></div>
										<div style="font-size: 11px; color: var(--text-muted);"><%=empDept%></div>
									</div>
								</div>
							</td>
							
							<td><span class="badge <%=prioBadge%>"><%=prioStr%></span></td>
							
							<td>
								<span id="table-status-badge-<%=task.getTaskId()%>" class="badge <%=statusBadge%>"><%=statusStr%></span>
							</td>
							
							<td style="font-size: 12.5px; color: var(--text-muted);"><%=task.getAssignedDate()%></td>
							
							<td style="font-size: 13px;">
								<div style="font-weight: 600; color: var(--neon-amber);"><%=task.getDueDate()%></div>
								<%=countdownHtml%>
							</td>
							
							<td style="font-size: 12.5px; color: var(--text-muted);"><%=task.getCompletionDate() == null ? "--" : task.getCompletionDate()%></td>
						</tr>
						<%
							}
						} else {
						%>
						<tr>
							<td colspan="8" style="text-align: center; padding: 50px; color: var(--text-muted);">
								<i class="fa-solid fa-inbox" style="font-size: 40px; margin-bottom: 12px; opacity: 0.5; display: block;"></i>
								<div style="font-size: 15px; font-weight: 600;">No Tasks Found</div>
								<p style="font-size: 13px; margin-top: 4px;">Click "Create New Task" to assign assignments to your workforce.</p>
							</td>
						</tr>
						<% } %>
					</tbody>
				</table>
			</div>
		</div>

		<!-- 5. VIEW 2: Interactive Kanban Board with Drag & Drop -->
		<div id="kanbanViewSection" class="kanban-board" style="display: none;">
			<!-- Pending Column -->
			<div class="kanban-col col-pending" ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" ondrop="handleDrop(event, 'PENDING')">
				<div class="kanban-col-head">
					<span class="kanban-col-title"><i class="fa-solid fa-hourglass-half"></i> Pending</span>
					<span id="kanbanCountPending" class="kanban-col-count">0</span>
				</div>
				<div id="kanbanColPending" class="kanban-card-list"></div>
			</div>

			<!-- In Progress Column -->
			<div class="kanban-col col-progress" ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" ondrop="handleDrop(event, 'IN_PROGRESS')">
				<div class="kanban-col-head">
					<span class="kanban-col-title"><i class="fa-solid fa-spinner"></i> In Progress</span>
					<span id="kanbanCountProgress" class="kanban-col-count">0</span>
				</div>
				<div id="kanbanColProgress" class="kanban-card-list"></div>
			</div>

			<!-- Completed Column -->
			<div class="kanban-col col-completed" ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" ondrop="handleDrop(event, 'COMPLETED')">
				<div class="kanban-col-head">
					<span class="kanban-col-title"><i class="fa-solid fa-circle-check"></i> Completed</span>
					<span id="kanbanCountCompleted" class="kanban-col-count">0</span>
				</div>
				<div id="kanbanColCompleted" class="kanban-card-list"></div>
			</div>

			<!-- Overdue Column -->
			<div class="kanban-col col-overdue" ondragover="handleDragOver(event)" ondragleave="handleDragLeave(event)" ondrop="handleDrop(event, 'OVERDUE')">
				<div class="kanban-col-head">
					<span class="kanban-col-title"><i class="fa-solid fa-triangle-exclamation"></i> Overdue</span>
					<span id="kanbanCountOverdue" class="kanban-col-count">0</span>
				</div>
				<div id="kanbanColOverdue" class="kanban-card-list"></div>
			</div>
		</div>

		<!-- 6. VIEW 3: Visual Analytics Dashboard -->
		<div id="analyticsViewSection" style="display: none;">
			<div class="analytics-view-grid">
				<!-- Priority Breakdown Card -->
				<div class="chart-card">
					<div class="chart-card-title">
						<i class="fa-solid fa-fire" style="color: var(--neon-amber);"></i> Task Priority Breakdown
					</div>
					<div id="priorityBarsContainer">
						<!-- Rendered dynamically by JS -->
					</div>
				</div>

				<!-- Status Distribution Chart Card -->
				<div class="chart-card">
					<div class="chart-card-title">
						<i class="fa-solid fa-chart-pie" style="color: var(--neon-cyan);"></i> Task Status Ratio
					</div>
					<div style="display: flex; align-items: center; justify-content: space-around; gap: 20px; flex-wrap: wrap;">
						<svg width="160" height="160" viewBox="0 0 100 100">
							<circle cx="50" cy="50" r="40" fill="transparent" stroke="rgba(148,163,184,0.18)" stroke-width="15" />
							<!-- Dynamic SVG Doughnut Segments -->
							<circle id="donutComp" cx="50" cy="50" r="40" fill="transparent" stroke="var(--neon-emerald)" stroke-width="15" stroke-dasharray="0 251.2" transform="rotate(-90 50 50)" />
							<circle id="donutProg" cx="50" cy="50" r="40" fill="transparent" stroke="var(--neon-cyan)" stroke-width="15" stroke-dasharray="0 251.2" transform="rotate(-90 50 50)" />
							<circle id="donutPend" cx="50" cy="50" r="40" fill="transparent" stroke="var(--neon-amber)" stroke-width="15" stroke-dasharray="0 251.2" transform="rotate(-90 50 50)" />
							<circle id="donutOver" cx="50" cy="50" r="40" fill="transparent" stroke="var(--neon-rose)" stroke-width="15" stroke-dasharray="0 251.2" transform="rotate(-90 50 50)" />
						</svg>
						<div style="display: flex; flex-direction: column; gap: 10px; font-size: 13px; font-weight: 700;">
							<div style="display: flex; align-items: center; gap: 8px;">
								<span style="width: 12px; height: 12px; border-radius: 50%; background: var(--neon-emerald);"></span>
								<span>Completed: <strong id="legendComp">0</strong></span>
							</div>
							<div style="display: flex; align-items: center; gap: 8px;">
								<span style="width: 12px; height: 12px; border-radius: 50%; background: var(--neon-cyan);"></span>
								<span>In Progress: <strong id="legendProg">0</strong></span>
							</div>
							<div style="display: flex; align-items: center; gap: 8px;">
								<span style="width: 12px; height: 12px; border-radius: 50%; background: var(--neon-amber);"></span>
								<span>Pending: <strong id="legendPend">0</strong></span>
							</div>
							<div style="display: flex; align-items: center; gap: 8px;">
								<span style="width: 12px; height: 12px; border-radius: 50%; background: var(--neon-rose);"></span>
								<span>Overdue: <strong id="legendOver">0</strong></span>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- Employee Workload Distribution -->
			<div class="chart-card">
				<div class="chart-card-title">
					<i class="fa-solid fa-users-gear" style="color: var(--neon-indigo);"></i> Employee Workload & Execution Summary
				</div>
				<div id="empWorkloadContainer" class="emp-workload-grid">
					<!-- Rendered dynamically by JS -->
				</div>
			</div>
		</div>

		<!-- 7. VIEW 4: Interactive Task Calendar View -->
		<div id="calendarViewSection" class="calendar-card" style="display: none;">
			<div class="calendar-header">
				<div class="calendar-title-text" id="calendarMonthTitle">September 2026</div>
				<div class="calendar-controls">
					<button type="button" class="btn-action btn-back" onclick="changeCalendarMonth(-1)" style="padding: 6px 12px;">
						<i class="fa-solid fa-chevron-left"></i> Prev
					</button>
					<button type="button" class="btn-action btn-export" onclick="resetCalendarToCurrent()" style="padding: 6px 12px;">
						Today
					</button>
					<button type="button" class="btn-action btn-back" onclick="changeCalendarMonth(1)" style="padding: 6px 12px;">
						Next <i class="fa-solid fa-chevron-right"></i>
					</button>
				</div>
			</div>

			<div class="calendar-grid">
				<div class="cal-day-head">Sun</div>
				<div class="cal-day-head">Mon</div>
				<div class="cal-day-head">Tue</div>
				<div class="cal-day-head">Wed</div>
				<div class="cal-day-head">Thu</div>
				<div class="cal-day-head">Fri</div>
				<div class="cal-day-head">Sat</div>
			</div>
			<div id="calendarGridDays" class="calendar-grid" style="margin-top: 6px;">
				<!-- Rendered dynamically by JS -->
			</div>
		</div>

	</div>

	<!-- ========================================================= -->
	<!-- TASK DETAIL & INSTANT STATUS MODAL                        -->
	<!-- ========================================================= -->
	<div id="taskDetailModal" class="task-modal-backdrop" style="display: none;" onclick="handleModalBackdropClick(event)">
		<div class="task-modal-card" onclick="event.stopPropagation()">
			<div class="task-modal-head">
				<div style="display: flex; align-items: center; gap: 8px;">
					<span id="modalTaskId" class="badge badge-low">#TASK</span>
					<span id="modalTaskPrio" class="badge badge-medium">MEDIUM</span>
					<span id="modalTaskStatus" class="badge badge-pending">PENDING</span>
				</div>
				<button type="button" onclick="closeTaskModal()" style="background: rgba(148,163,184,0.15); border: 1px solid var(--border-glass); color: var(--text-light); width: 32px; height: 32px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center;">&times;</button>
			</div>
			<div class="task-modal-body">
				<div>
					<h3 id="modalTaskName" style="font-size: 18px; font-weight: 800; color: var(--text-light); line-height: 1.35;">Task Name</h3>
					<div id="modalTaskDesc" style="margin-top: 8px; background: var(--card-inner); border: 1px solid var(--border-glass); border-radius: 14px; padding: 14px; font-size: 13.5px; color: var(--text-light); line-height: 1.6; white-space: pre-line;">Task description details...</div>
				</div>

				<div class="task-meta-grid">
					<div>
						<span style="color: var(--text-muted); font-size: 11px; text-transform: uppercase;">Assigned Employee</span>
						<div id="modalTaskEmp" style="font-weight: 700; color: var(--text-light); margin-top: 2px;">Employee Name</div>
					</div>
					<div>
						<span style="color: var(--text-muted); font-size: 11px; text-transform: uppercase;">Department</span>
						<div id="modalTaskDept" style="font-weight: 600; color: var(--neon-indigo); margin-top: 2px;">Engineering</div>
					</div>
					<div>
						<span style="color: var(--text-muted); font-size: 11px; text-transform: uppercase;">Assigned Date</span>
						<div id="modalTaskAssignedDate" style="color: var(--text-light); margin-top: 2px;">2026-08-10</div>
					</div>
					<div>
						<span style="color: var(--text-muted); font-size: 11px; text-transform: uppercase;">Due Date</span>
						<div id="modalTaskDueDate" style="color: var(--neon-amber); font-weight: 700; margin-top: 2px;">2026-08-15</div>
					</div>
					<div>
						<span style="color: var(--text-muted); font-size: 11px; text-transform: uppercase;">Assigned By</span>
						<div id="modalTaskAssignedBy" style="color: var(--text-light); margin-top: 2px;">Manager</div>
					</div>
					<div>
						<span style="color: var(--text-muted); font-size: 11px; text-transform: uppercase;">Completion Date</span>
						<div id="modalTaskCompDate" style="color: var(--neon-emerald); margin-top: 2px;">--</div>
					</div>
				</div>

				<!-- Quick Status Changer inside Modal -->
				<div class="task-status-control">
					<div>
						<span style="font-size: 12px; color: var(--text-muted); display: block;">Quick Status Transition</span>
						<strong style="font-size: 13px; color: var(--text-light);">Change Current State</strong>
					</div>
					<select id="modalStatusSelect" onchange="updateTaskStatusFromModal(this.value)" style="background: var(--input-bg); border: 1px solid var(--neon-indigo); color: var(--text-light); padding: 7px 12px; border-radius: 10px; font-size: 12.5px; font-weight: 700; outline: none; cursor: pointer;">
						<option value="PENDING">⏳ PENDING</option>
						<option value="IN_PROGRESS">🔄 IN PROGRESS</option>
						<option value="COMPLETED">✅ COMPLETED</option>
						<option value="OVERDUE">⚠️ OVERDUE</option>
					</select>
				</div>
			</div>
			<div class="task-modal-footer">
				<div style="display: flex; gap: 8px;">
					<button type="button" class="btn-action btn-export" onclick="copyTaskModalInfo()" style="padding: 8px 14px; font-size: 12px;">
						<i class="fa-regular fa-copy"></i> Copy Info
					</button>
					<a id="modalEditLink" href="#" class="btn-action btn-print" style="padding: 8px 14px; font-size: 12px;">
						<i class="fa-solid fa-pen"></i> Edit
					</a>
				</div>
				<button type="button" class="btn-action btn-create" onclick="closeTaskModal()" style="padding: 8px 18px; font-size: 12.5px;">
					<i class="fa-solid fa-check"></i> Done
				</button>
			</div>
		</div>
	</div>

	<!-- ========================================================= -->
	<!-- JAVASCRIPT LOGIC ENGINE                                   -->
	<!-- ========================================================= -->
	<script>
	var activeFilter = "all";
	var currentView = "table";
	var currentModalTaskId = null;
	var contextPath = "<%=request.getContextPath()%>";
	var draggedTaskId = null;
	var calCurrentDate = new Date();

	document.addEventListener("DOMContentLoaded", function() {
		buildKanbanCards();
		renderAnalyticsView();
		renderCalendarView();
	});

	// --- View Mode Switching ---
	function switchView(view) {
		currentView = view;
		var tableSec = document.getElementById("tableViewSection");
		var kanbanSec = document.getElementById("kanbanViewSection");
		var analyticsSec = document.getElementById("analyticsViewSection");
		var calendarSec = document.getElementById("calendarViewSection");

		var btnTable = document.getElementById("btnViewTable");
		var btnKanban = document.getElementById("btnViewKanban");
		var btnAnalytics = document.getElementById("btnViewAnalytics");
		var btnCalendar = document.getElementById("btnViewCalendar");

		// Hide all
		tableSec.style.display = "none";
		kanbanSec.style.display = "none";
		analyticsSec.style.display = "none";
		calendarSec.style.display = "none";

		btnTable.classList.remove("active");
		btnKanban.classList.remove("active");
		btnAnalytics.classList.remove("active");
		btnCalendar.classList.remove("active");

		if (view === "kanban") {
			kanbanSec.style.display = "grid";
			btnKanban.classList.add("active");
			buildKanbanCards();
		} else if (view === "analytics") {
			analyticsSec.style.display = "block";
			btnAnalytics.classList.add("active");
			renderAnalyticsView();
		} else if (view === "calendar") {
			calendarSec.style.display = "block";
			btnCalendar.classList.add("active");
			renderCalendarView();
		} else {
			tableSec.style.display = "block";
			btnTable.classList.add("active");
		}
	}

	// --- Filters & Searching ---
	function setTaskFilter(filter, btn) {
		activeFilter = filter;
		document.querySelectorAll(".filter-pill").forEach(function(p) {
			p.classList.remove("active");
		});
		if (btn) btn.classList.add("active");
		applyTaskFilters();
	}

	function applyTaskFilters() {
		var q = (document.getElementById("taskSearchInput").value || "").toLowerCase().trim();
		var rows = document.querySelectorAll("#taskTableBody .task-row");

		rows.forEach(function(row) {
			var name = (row.getAttribute("data-name") || "").toLowerCase();
			var desc = (row.getAttribute("data-desc") || "").toLowerCase();
			var emp = (row.getAttribute("data-empname") || "").toLowerCase();
			var id = (row.getAttribute("data-id") || "").toLowerCase();
			var status = (row.getAttribute("data-status") || "").toLowerCase();
			var prio = (row.getAttribute("data-prio") || "").toLowerCase();

			var matchesQuery = !q || name.includes(q) || desc.includes(q) || emp.includes(q) || id.includes(q);

			var matchesFilter = true;
			if (activeFilter === "pending") matchesFilter = status === "pending";
			else if (activeFilter === "in_progress") matchesFilter = status === "in_progress";
			else if (activeFilter === "completed") matchesFilter = status === "completed";
			else if (activeFilter === "overdue") matchesFilter = status === "overdue";
			else if (activeFilter === "high") matchesFilter = (prio === "high" || prio === "critical");

			row.style.display = (matchesQuery && matchesFilter) ? "" : "none";
		});

		// Filter Kanban cards
		document.querySelectorAll(".kanban-card").forEach(function(card) {
			var text = card.innerText.toLowerCase();
			var prio = (card.getAttribute("data-prio") || "").toLowerCase();
			var status = (card.getAttribute("data-status") || "").toLowerCase();

			var matchesQuery = !q || text.includes(q);
			var matchesFilter = true;
			if (activeFilter === "pending") matchesFilter = status === "pending";
			else if (activeFilter === "in_progress") matchesFilter = status === "in_progress";
			else if (activeFilter === "completed") matchesFilter = status === "completed";
			else if (activeFilter === "overdue") matchesFilter = status === "overdue";
			else if (activeFilter === "high") matchesFilter = (prio === "high" || prio === "critical");

			card.style.display = (matchesQuery && matchesFilter) ? "block" : "none";
		});
	}

	// --- HTML5 Drag & Drop for Kanban ---
	function handleDragStart(e, id) {
		draggedTaskId = id;
		e.target.classList.add("dragging");
		e.dataTransfer.setData("text/plain", id);
	}

	function handleDragOver(e) {
		e.preventDefault();
		var col = e.currentTarget;
		col.classList.add("drag-over");
	}

	function handleDragLeave(e) {
		var col = e.currentTarget;
		col.classList.remove("drag-over");
	}

	function handleDrop(e, targetStatus) {
		e.preventDefault();
		var col = e.currentTarget;
		col.classList.remove("drag-over");
		var taskId = e.dataTransfer.getData("text/plain") || draggedTaskId;
		if (!taskId) return;

		var card = document.getElementById("kanban-card-" + taskId);
		if (card) card.classList.remove("dragging");

		// Trigger AJAX status update
		updateTaskStatusAjax(taskId, targetStatus);
	}

	function buildKanbanCards() {
		var colPending = document.getElementById("kanbanColPending");
		var colProgress = document.getElementById("kanbanColProgress");
		var colCompleted = document.getElementById("kanbanColCompleted");
		var colOverdue = document.getElementById("kanbanColOverdue");

		colPending.innerHTML = "";
		colProgress.innerHTML = "";
		colCompleted.innerHTML = "";
		colOverdue.innerHTML = "";

		var countPend = 0, countProg = 0, countComp = 0, countOver = 0;

		document.querySelectorAll("#taskTableBody .task-row").forEach(function(row) {
			var id = row.getAttribute("data-id");
			var name = row.getAttribute("data-name");
			var desc = row.getAttribute("data-desc");
			var empName = row.getAttribute("data-empname");
			var prio = row.getAttribute("data-prio");
			var status = (row.getAttribute("data-status") || "PENDING").toUpperCase();
			var due = row.getAttribute("data-duedate");

			var prioBadge = "badge-medium";
			if (prio === "HIGH" || prio === "CRITICAL") prioBadge = "badge-high";
			else if (prio === "LOW") prioBadge = "badge-low";

			var cardHtml = '<div class="kanban-card" id="kanban-card-' + id + '" data-id="' + id + '" data-status="' + status + '" data-prio="' + prio + '" draggable="true" ondragstart="handleDragStart(event, \'' + id + '\')" onclick="openTaskModalFromId(\'' + id + '\')">'
				+ '<div class="kanban-card-top">'
				+ '<span style="font-family: \'JetBrains Mono\'; font-weight:700; color:var(--neon-indigo); font-size:11.5px;">#' + id + '</span>'
				+ '<span class="badge ' + prioBadge + '">' + prio + '</span>'
				+ '</div>'
				+ '<div class="kanban-card-title">' + escapeHtml(name) + '</div>'
				+ '<div class="kanban-card-desc">' + escapeHtml(desc) + '</div>'
				+ '<div class="kanban-card-footer">'
				+ '<span style="font-weight:600; color:var(--text-light);"><i class="fa-regular fa-user" style="color:var(--neon-indigo)"></i> ' + escapeHtml(empName) + '</span>'
				+ '<span style="color:var(--neon-amber); font-weight:700;"><i class="fa-regular fa-calendar"></i> ' + escapeHtml(due) + '</span>'
				+ '</div>'
				+ '</div>';

			if (status === "COMPLETED") {
				colCompleted.innerHTML += cardHtml;
				countComp++;
			} else if (status === "IN_PROGRESS") {
				colProgress.innerHTML += cardHtml;
				countProg++;
			} else if (status === "OVERDUE") {
				colOverdue.innerHTML += cardHtml;
				countOver++;
			} else {
				colPending.innerHTML += cardHtml;
				countPend++;
			}
		});

		document.getElementById("kanbanCountPending").innerText = countPend;
		document.getElementById("kanbanCountProgress").innerText = countProg;
		document.getElementById("kanbanCountCompleted").innerText = countComp;
		document.getElementById("kanbanCountOverdue").innerText = countOver;

		if (countPend === 0) colPending.innerHTML = '<div style="text-align:center; padding:30px 10px; color:var(--text-muted); font-size:12.5px;">No pending tasks</div>';
		if (countProg === 0) colProgress.innerHTML = '<div style="text-align:center; padding:30px 10px; color:var(--text-muted); font-size:12.5px;">No in-progress tasks</div>';
		if (countComp === 0) colCompleted.innerHTML = '<div style="text-align:center; padding:30px 10px; color:var(--text-muted); font-size:12.5px;">No completed tasks</div>';
		if (countOver === 0) colOverdue.innerHTML = '<div style="text-align:center; padding:30px 10px; color:var(--text-muted); font-size:12.5px;">No overdue tasks</div>';
	}

	// --- AJAX Status Updater ---
	function updateTaskStatusAjax(id, newStatus) {
		fetch(contextPath + "/updateTaskStatus?taskId=" + id + "&status=" + newStatus + "&format=json", { method: "POST" })
			.then(function(res) { return res.json(); })
			.then(function(data) {
				if (data.success) {
					var row = document.querySelector('#taskTableBody .task-row[data-id="' + id + '"]');
					if (row) {
						row.setAttribute("data-status", newStatus);
						var badge = document.getElementById("table-status-badge-" + id);
						if (badge) {
							badge.innerText = newStatus;
							badge.className = "badge " + getStatusBadgeClass(newStatus);
						}
					}
					var modalStatus = document.getElementById("modalTaskStatus");
					if (modalStatus) modalStatus.innerText = newStatus;

					showTaskToast("Task #" + id + " moved to " + newStatus + "!");
					buildKanbanCards();
					recalcMetrics();
					if (currentView === "analytics") renderAnalyticsView();
					if (currentView === "calendar") renderCalendarView();
				}
			})
			.catch(function(err) {
				console.error("Error updating status:", err);
			});
	}

	function openTaskModalFromElement(row) {
		var id = row.getAttribute("data-id");
		openTaskModalFromId(id);
	}

	function openTaskModalFromId(id, e) {
		if (e) e.stopPropagation();
		currentModalTaskId = id;
		var row = document.querySelector('#taskTableBody .task-row[data-id="' + id + '"]');
		if (!row) return;

		var name = row.getAttribute("data-name");
		var desc = row.getAttribute("data-desc");
		var emp = row.getAttribute("data-empname");
		var dept = row.getAttribute("data-empdept");
		var prio = row.getAttribute("data-prio") || "MEDIUM";
		var status = row.getAttribute("data-status") || "PENDING";
		var assignedDate = row.getAttribute("data-assigneddate") || "--";
		var dueDate = row.getAttribute("data-duedate") || "--";
		var compDate = row.getAttribute("data-compdate") || "--";
		var assignedBy = row.getAttribute("data-assignedby") || "Management";

		document.getElementById("modalTaskId").innerText = "#TASK-" + id;
		document.getElementById("modalTaskPrio").innerText = prio;
		document.getElementById("modalTaskStatus").innerText = status;
		document.getElementById("modalTaskName").innerText = name;
		document.getElementById("modalTaskDesc").innerText = desc || "No description provided.";
		document.getElementById("modalTaskEmp").innerText = emp;
		document.getElementById("modalTaskDept").innerText = dept;
		document.getElementById("modalTaskAssignedDate").innerText = assignedDate;
		document.getElementById("modalTaskDueDate").innerText = dueDate;
		document.getElementById("modalTaskCompDate").innerText = compDate || "--";
		document.getElementById("modalTaskAssignedBy").innerText = assignedBy;
		document.getElementById("modalEditLink").href = "editTaskServlet?taskId=" + id;

		document.getElementById("modalStatusSelect").value = status.toUpperCase();
		document.getElementById("taskDetailModal").style.display = "flex";
	}

	function closeTaskModal() {
		document.getElementById("taskDetailModal").style.display = "none";
		currentModalTaskId = null;
	}

	function handleModalBackdropClick(e) {
		if (e.target.id === "taskDetailModal") closeTaskModal();
	}

	function updateTaskStatusFromModal(newStatus) {
		if (!currentModalTaskId) return;
		updateTaskStatusAjax(currentModalTaskId, newStatus);
	}

	function getStatusBadgeClass(status) {
		var s = (status || "").toUpperCase();
		if (s === "COMPLETED") return "badge-completed";
		if (s === "IN_PROGRESS") return "badge-progress";
		if (s === "OVERDUE") return "badge-overdue";
		return "badge-pending";
	}

	function recalcMetrics() {
		var rows = document.querySelectorAll("#taskTableBody .task-row");
		var comp = 0, pend = 0, prog = 0, over = 0, total = rows.length;

		rows.forEach(function(r) {
			var st = (r.getAttribute("data-status") || "").toUpperCase();
			if (st === "COMPLETED") comp++;
			else if (st === "IN_PROGRESS") prog++;
			else if (st === "OVERDUE") over++;
			else pend++;
		});

		document.getElementById("statComp").innerText = comp;
		document.getElementById("statPend").innerText = pend;
		document.getElementById("statProg").innerText = prog;
		document.getElementById("statOver").innerText = over;
		document.getElementById("statTotal").innerText = total;

		var rate = total > 0 ? Math.round((comp / total) * 100) : 0;
		document.getElementById("rateText").innerText = rate + "%";
		document.getElementById("rateSummary").innerText = comp + " of " + total;
		var circle = document.getElementById("rateCircle");
		if (circle) {
			circle.style.strokeDashoffset = 188.4 - (188.4 * rate / 100);
		}

		// Update Top Bar Dist
		if (total > 0) {
			document.getElementById("distCompBar").style.width = (comp * 100 / total) + "%";
			document.getElementById("distProgBar").style.width = (prog * 100 / total) + "%";
			document.getElementById("distPendBar").style.width = (pend * 100 / total) + "%";
			document.getElementById("distOverBar").style.width = (over * 100 / total) + "%";
		}
	}

	// --- Render Analytics Dashboard View ---
	function renderAnalyticsView() {
		var rows = document.querySelectorAll("#taskTableBody .task-row");
		var prioCounts = { LOW: 0, MEDIUM: 0, HIGH: 0, CRITICAL: 0 };
		var statusCounts = { COMPLETED: 0, IN_PROGRESS: 0, PENDING: 0, OVERDUE: 0 };
		var empMap = {};

		rows.forEach(function(r) {
			var p = (r.getAttribute("data-prio") || "MEDIUM").toUpperCase();
			var s = (r.getAttribute("data-status") || "PENDING").toUpperCase();
			var emp = r.getAttribute("data-empname") || "Unassigned";

			prioCounts[p] = (prioCounts[p] || 0) + 1;
			statusCounts[s] = (statusCounts[s] || 0) + 1;

			if (!empMap[emp]) empMap[emp] = { total: 0, comp: 0, prog: 0, pend: 0, over: 0 };
			empMap[emp].total++;
			if (s === "COMPLETED") empMap[emp].comp++;
			else if (s === "IN_PROGRESS") empMap[emp].prog++;
			else if (s === "OVERDUE") empMap[emp].over++;
			else empMap[emp].pend++;
		});

		var total = rows.length || 1;

		// 1. Priority Bars
		var prioContainer = document.getElementById("priorityBarsContainer");
		var prioColors = { LOW: 'var(--neon-cyan)', MEDIUM: 'var(--neon-indigo)', HIGH: 'var(--neon-amber)', CRITICAL: 'var(--neon-rose)' };
		var prioHtml = "";
		['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'].forEach(function(pKey) {
			var cnt = prioCounts[pKey] || 0;
			var pct = Math.round((cnt / total) * 100);
			prioHtml += '<div class="priority-bar-row">'
				+ '<div class="priority-bar-label"><span>' + pKey + ' Priority</span><span>' + cnt + ' tasks (' + pct + '%)</span></div>'
				+ '<div class="priority-bar-track"><div class="priority-bar-fill" style="width:' + pct + '%; background:' + prioColors[pKey] + ';"></div></div>'
				+ '</div>';
		});
		prioContainer.innerHTML = prioHtml;

		// 2. Status Doughnut Chart
		document.getElementById("legendComp").innerText = statusCounts.COMPLETED;
		document.getElementById("legendProg").innerText = statusCounts.IN_PROGRESS;
		document.getElementById("legendPend").innerText = statusCounts.PENDING;
		document.getElementById("legendOver").innerText = statusCounts.OVERDUE;

		var circ = 251.2;
		var cLen = (statusCounts.COMPLETED / total) * circ;
		var prLen = (statusCounts.IN_PROGRESS / total) * circ;
		var peLen = (statusCounts.PENDING / total) * circ;
		var oLen = (statusCounts.OVERDUE / total) * circ;

		document.getElementById("donutComp").setAttribute("stroke-dasharray", cLen + " " + (circ - cLen));
		document.getElementById("donutProg").setAttribute("stroke-dasharray", prLen + " " + (circ - prLen));
		document.getElementById("donutProg").setAttribute("transform", "rotate(" + (-90 + (cLen * 360 / circ)) + " 50 50)");

		document.getElementById("donutPend").setAttribute("stroke-dasharray", peLen + " " + (circ - peLen));
		document.getElementById("donutPend").setAttribute("transform", "rotate(" + (-90 + ((cLen + prLen) * 360 / circ)) + " 50 50)");

		document.getElementById("donutOver").setAttribute("stroke-dasharray", oLen + " " + (circ - oLen));
		document.getElementById("donutOver").setAttribute("transform", "rotate(" + (-90 + ((cLen + prLen + peLen) * 360 / circ)) + " 50 50)");

		// 3. Employee Workload Grid
		var empContainer = document.getElementById("empWorkloadContainer");
		var empHtml = "";
		Object.keys(empMap).forEach(function(eName) {
			var eData = empMap[eName];
			var eRate = Math.round((eData.comp / eData.total) * 100);
			empHtml += '<div class="emp-workload-card">'
				+ '<div style="display:flex; justify-content:space-between; align-items:center;">'
				+ '<strong style="font-size:14px; color:var(--text-light);"><i class="fa-solid fa-user-circle" style="color:var(--neon-indigo)"></i> ' + escapeHtml(eName) + '</strong>'
				+ '<span class="badge badge-medium">' + eData.total + ' Tasks</span>'
				+ '</div>'
				+ '<div style="font-size:12px; color:var(--text-muted); display:flex; gap:12px; margin-top:4px;">'
				+ '<span style="color:var(--neon-emerald)">' + eData.comp + ' Done</span>'
				+ '<span style="color:var(--neon-cyan)">' + eData.prog + ' Progress</span>'
				+ '<span style="color:var(--neon-rose)">' + eData.over + ' Overdue</span>'
				+ '</div>'
				+ '<div class="priority-bar-track" style="margin-top:6px;"><div class="priority-bar-fill" style="width:' + eRate + '%; background:var(--neon-emerald);"></div></div>'
				+ '</div>';
		});
		if (!empHtml) empHtml = '<div style="color:var(--text-muted); font-size:13px;">No employee task records found.</div>';
		empContainer.innerHTML = empHtml;
	}

	// --- Render Task Calendar View ---
	function renderCalendarView() {
		var year = calCurrentDate.getFullYear();
		var month = calCurrentDate.getMonth();
		var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		document.getElementById("calendarMonthTitle").innerText = monthNames[month] + " " + year;

		var firstDay = new Date(year, month, 1).getDay();
		var daysInMonth = new Date(year, month + 1, 0).getDate();

		var gridDays = document.getElementById("calendarGridDays");
		gridDays.innerHTML = "";

		var todayStr = new Date().toISOString().split('T')[0];

		// Blank cells before day 1
		for (var i = 0; i < firstDay; i++) {
			gridDays.innerHTML += '<div class="cal-day-cell" style="opacity:0.3; background:transparent; border:none;"></div>';
		}

		// Days of month
		for (var day = 1; day <= daysInMonth; day++) {
			var dayNumStr = (day < 10 ? '0' : '') + day;
			var monthNumStr = ((month + 1) < 10 ? '0' : '') + (month + 1);
			var dateStr = year + "-" + monthNumStr + "-" + dayNumStr;

			var isToday = (dateStr === todayStr);
			var cellClass = "cal-day-cell" + (isToday ? " today-cell" : "");

			var dayTasksHtml = "";
			document.querySelectorAll("#taskTableBody .task-row").forEach(function(r) {
				var due = r.getAttribute("data-duedate");
				if (due === dateStr) {
					var id = r.getAttribute("data-id");
					var name = r.getAttribute("data-name");
					var prio = r.getAttribute("data-prio");
					var prioBg = "var(--neon-cyan)";
					if (prio === "HIGH" || prio === "CRITICAL") prioBg = "var(--neon-amber)";

					dayTasksHtml += '<div class="cal-task-chip" style="background:rgba(37,99,235,0.12); border:1px solid ' + prioBg + '; color:var(--text-light);" onclick="openTaskModalFromId(\'' + id + '\')">'
						+ '<span style="width:6px; height:6px; border-radius:50%; background:' + prioBg + ';"></span>'
						+ escapeHtml(name)
						+ '</div>';
				}
			});

			gridDays.innerHTML += '<div class="' + cellClass + '">'
				+ '<div class="cal-day-num">' + day + '</div>'
				+ dayTasksHtml
				+ '</div>';
		}
	}

	function changeCalendarMonth(offset) {
		calCurrentDate.setMonth(calCurrentDate.getMonth() + offset);
		renderCalendarView();
	}

	function resetCalendarToCurrent() {
		calCurrentDate = new Date();
		renderCalendarView();
	}

	function copyTaskModalInfo() {
		var title = document.getElementById("modalTaskName").innerText;
		var desc = document.getElementById("modalTaskDesc").innerText;
		var emp = document.getElementById("modalTaskEmp").innerText;
		var due = document.getElementById("modalTaskDueDate").innerText;
		var text = "Task: " + title + "\nAssigned to: " + emp + "\nDue Date: " + due + "\n\nDescription:\n" + desc;
		navigator.clipboard.writeText(text).then(function() {
			showTaskToast("Task details copied to clipboard!");
		});
	}

	function showTaskToast(msg) {
		var toast = document.createElement("div");
		toast.className = "task-toast";
		toast.innerHTML = '<i class="fa-solid fa-circle-check"></i> ' + escapeHtml(msg);
		document.body.appendChild(toast);
		setTimeout(function() {
			toast.style.transition = "all 0.3s ease";
			toast.style.opacity = "0";
			toast.style.transform = "translateY(20px)";
			setTimeout(function() { toast.remove(); }, 300);
		}, 2500);
	}

	function escapeHtml(str) {
		if (!str) return "";
		return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
	}

	document.addEventListener("keydown", function(e) {
		if (e.key === "Escape") closeTaskModal();
	});
	</script>

</body>
</html>