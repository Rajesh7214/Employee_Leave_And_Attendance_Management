<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.SalaryStructure"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Locale"%>
<%@ page import="java.time.Month"%>
<%@ page import="java.time.format.TextStyle"%>
<%@ page import="java.text.NumberFormat"%>

<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || (!"admin".equalsIgnoreCase(role) && !"hr".equalsIgnoreCase(role))) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String displayName = loggedUser != null && loggedUser.getEmail() != null ? loggedUser.getEmail().split("@")[0] : "User";
displayName = Character.toUpperCase(displayName.charAt(0)) + (displayName.length() > 1 ? displayName.substring(1) : "");
String activePage = "manageSalary";

List<Employee> allEmployees = (List<Employee>) request.getAttribute("allEmployees");
List<String> allDepartments = (List<String>) request.getAttribute("allDepartments");
String selectedDept = (String) request.getAttribute("selectedDept");
if (selectedDept == null) selectedDept = "ALL";

Employee selectedEmployee = (Employee) request.getAttribute("selectedEmployee");
SalaryStructure salaryStructure = (SalaryStructure) request.getAttribute("salaryStructure");

if (salaryStructure == null) {
	salaryStructure = new SalaryStructure();
}

int selectedMonth = request.getAttribute("selectedMonth") != null ? (Integer) request.getAttribute("selectedMonth") : 8;
int selectedYear = request.getAttribute("selectedYear") != null ? (Integer) request.getAttribute("selectedYear") : 2026;
int realLopDays = request.getAttribute("realLopDays") != null ? (Integer) request.getAttribute("realLopDays") : 0;
double realLopDeduction = request.getAttribute("realLopDeduction") != null ? (Double) request.getAttribute("realLopDeduction") : 0.0;
String monthName = Month.of(selectedMonth).getDisplayName(TextStyle.FULL, Locale.ENGLISH);

NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

String selectedEmpName = selectedEmployee != null && selectedEmployee.getEmployee_name() != null ? selectedEmployee.getEmployee_name() : "Select Employee";
String empInitial = !selectedEmpName.isEmpty() ? selectedEmpName.substring(0, 1).toUpperCase() : "E";
String empCode = selectedEmployee != null ? "EMP" + String.format("%03d", selectedEmployee.getEmployee_id()) : "EMP---";
String empDept = selectedEmployee != null && selectedEmployee.getDepartment() != null ? selectedEmployee.getDepartment() : "General";
String structStatus = salaryStructure != null && salaryStructure.getStatus() != null ? salaryStructure.getStatus() : "ACTIVE";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Salary Setup Centre | RChips Solutions ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<style>
:root {
	--blue-primary: #2563eb;
	--blue-dark: #1d4ed8;
	--blue-light: #eff6ff;
	--blue-accent: #3b82f6;
	--text-primary: #0f172a;
	--text-secondary: #475569;
	--text-muted: #64748b;
	--card-bg: #ffffff;
	--surface-bg: #f8fafc;
	--border-color: #e2e8f0;
	--emerald-color: #10b981;
	--amber-color: #f59e0b;
	--rose-color: #ef4444;
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
	            radial-gradient(circle at 90% 90%, rgba(79, 70, 229, 0.04) 0%, transparent 45%),
	            linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

.white-card {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 24px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

/* Header Topbar */
.top-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
.header-title h1 {
	font-size: 26px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 12px;
	letter-spacing: -0.5px;
}
.header-title p { font-size: 13.5px; color: var(--text-secondary); margin-top: 4px; font-weight: 500; }

.btn-outline-blue {
	background: var(--card-bg);
	color: var(--blue-primary);
	border: 1px solid var(--blue-primary);
	padding: 10px 20px;
	border-radius: 14px;
	font-size: 13px;
	font-weight: 800;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	cursor: pointer;
	transition: all 0.2s;
	box-shadow: 0 2px 10px rgba(37, 99, 235, 0.06);
}
.btn-outline-blue:hover { background: var(--blue-light); transform: translateY(-1px); }

/* Employee Target Banner & Selector Card */
.emp-target-banner {
	background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
	border-radius: 24px;
	padding: 24px 32px;
	color: #ffffff;
	margin-bottom: 24px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 20px;
	box-shadow: 0 15px 35px rgba(15, 23, 42, 0.12);
}

.emp-profile-group {
	display: flex;
	align-items: center;
	gap: 18px;
}

.emp-avatar-circle {
	width: 58px;
	height: 58px;
	border-radius: 18px;
	background: linear-gradient(135deg, #2563eb 0%, #4f46e5 100%);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24px;
	font-weight: 800;
	box-shadow: 0 6px 18px rgba(37, 99, 235, 0.35);
	border: 2px solid rgba(255, 255, 255, 0.2);
}

.emp-meta-info h2 {
	font-size: 20px;
	font-weight: 800;
	letter-spacing: -0.4px;
	margin-bottom: 4px;
}

.emp-sub-tags {
	display: flex;
	align-items: center;
	gap: 10px;
	font-size: 12.5px;
	color: #94a3b8;
	font-weight: 600;
}

.emp-sub-tags span {
	display: flex;
	align-items: center;
	gap: 5px;
}

.status-tag {
	padding: 4px 12px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.status-tag.active { background: rgba(16, 185, 129, 0.2); color: #34d399; border: 1px solid rgba(52, 211, 153, 0.3); }
.status-tag.draft { background: rgba(245, 158, 11, 0.2); color: #fbbf24; border: 1px solid rgba(251, 191, 36, 0.3); }

/* Selector Toolbar */
.selector-toolbar {
	display: flex;
	align-items: center;
	gap: 10px;
	flex-wrap: wrap;
}

.selector-toolbar select {
	background: rgba(255, 255, 255, 0.1);
	backdrop-filter: blur(8px);
	color: #ffffff;
	border: 1px solid rgba(255, 255, 255, 0.25);
	padding: 10px 16px;
	border-radius: 14px;
	font-size: 13px;
	font-weight: 700;
	outline: none;
	cursor: pointer;
	transition: all 0.2s;
}

.selector-toolbar select:hover {
	background: rgba(255, 255, 255, 0.18);
	border-color: rgba(255, 255, 255, 0.4);
}

.selector-toolbar select option {
	background: #0f172a;
	color: #ffffff;
}

/* Search Box & Button Styles */
.search-box-group {
	display: flex;
	align-items: center;
	gap: 6px;
	background: rgba(255, 255, 255, 0.1);
	backdrop-filter: blur(8px);
	border: 1px solid rgba(255, 255, 255, 0.25);
	border-radius: 14px;
	padding: 3px 4px 3px 12px;
	transition: all 0.2s;
}

.search-box-group:focus-within {
	background: rgba(255, 255, 255, 0.18);
	border-color: #60a5fa;
	box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.2);
}

.search-box-group input {
	background: transparent;
	border: none;
	outline: none;
	color: #ffffff;
	font-size: 13px;
	font-weight: 600;
	width: 170px;
}

.search-box-group input::placeholder {
	color: rgba(255, 255, 255, 0.6);
}

.btn-search-trigger {
	background: rgba(255, 255, 255, 0.12);
	backdrop-filter: blur(12px);
	color: #ffffff;
	border: 1px solid rgba(255, 255, 255, 0.25);
	padding: 10px 18px;
	border-radius: 16px;
	font-size: 13px;
	font-weight: 700;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.btn-search-trigger:hover {
	background: rgba(255, 255, 255, 0.22);
	border-color: rgba(96, 165, 250, 0.6);
	transform: translateY(-1px);
	box-shadow: 0 6px 20px rgba(37, 99, 235, 0.25);
}

.search-kbd-badge {
	background: rgba(15, 23, 42, 0.6);
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 6px;
	padding: 2px 7px;
	font-size: 10.5px;
	font-weight: 800;
	color: #93c5fd;
	margin-left: 4px;
}

/* Modal Overlay Styles */
.modal-overlay {
	position: fixed;
	top: 0; left: 0; right: 0; bottom: 0;
	background: rgba(15, 23, 42, 0.75);
	backdrop-filter: blur(8px);
	z-index: 9999;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20px;
	opacity: 0;
	visibility: hidden;
	transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-overlay.active {
	opacity: 1;
	visibility: visible;
}

.modal-card {
	background: #0f172a;
	color: #f8fafc;
	border: 1px solid rgba(255, 255, 255, 0.15);
	border-radius: 24px;
	width: 100%;
	max-width: 740px;
	max-height: 85vh;
	display: flex;
	flex-direction: column;
	box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
	transform: scale(0.95);
	transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-overlay.active .modal-card {
	transform: scale(1);
}

.modal-header {
	padding: 20px 24px;
	border-bottom: 1px solid rgba(255, 255, 255, 0.1);
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.modal-header h3 {
	font-size: 18px;
	font-weight: 800;
	display: flex;
	align-items: center;
	gap: 10px;
	color: #ffffff;
}

.modal-close-btn {
	background: rgba(255, 255, 255, 0.1);
	border: none;
	color: #94a3b8;
	width: 32px;
	height: 32px;
	border-radius: 10px;
	font-size: 16px;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;
}

.modal-close-btn:hover {
	background: rgba(239, 68, 68, 0.2);
	color: #f87171;
}

.modal-body {
	padding: 20px 24px;
	overflow-y: auto;
	flex: 1;
}

.modal-search-bar {
	position: relative;
	margin-bottom: 16px;
}

.modal-search-bar i {
	position: absolute;
	left: 16px;
	top: 50%;
	transform: translateY(-50%);
	color: #60a5fa;
	font-size: 16px;
}

.modal-search-bar input {
	width: 100%;
	padding: 14px 16px 14px 46px;
	border-radius: 16px;
	background: rgba(30, 41, 59, 0.8);
	border: 1px solid rgba(255, 255, 255, 0.15);
	color: #ffffff;
	font-size: 14px;
	font-weight: 600;
	outline: none;
	transition: all 0.2s;
}

.modal-search-bar input:focus {
	border-color: #3b82f6;
	background: #1e293b;
	box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.25);
}

.dept-filter-chips {
	display: flex;
	gap: 8px;
	margin-bottom: 16px;
	flex-wrap: wrap;
}

.dept-chip {
	padding: 5px 12px;
	border-radius: 20px;
	background: rgba(255, 255, 255, 0.08);
	border: 1px solid rgba(255, 255, 255, 0.12);
	color: #cbd5e1;
	font-size: 12px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.2s;
}

.dept-chip:hover, .dept-chip.active {
	background: #2563eb;
	color: #ffffff;
	border-color: #3b82f6;
}

.search-results-table {
	width: 100%;
	border-collapse: separate;
	border-spacing: 0 8px;
}

.search-results-table th {
	text-align: left;
	font-size: 11px;
	font-weight: 800;
	text-transform: uppercase;
	color: #64748b;
	padding: 0 12px 6px;
	letter-spacing: 0.5px;
}

.search-result-row {
	background: rgba(30, 41, 59, 0.5);
	border: 1px solid rgba(255, 255, 255, 0.08);
	transition: all 0.2s;
}

.search-result-row:hover {
	background: rgba(37, 99, 235, 0.15);
	border-color: rgba(59, 130, 246, 0.4);
}

.search-result-row td {
	padding: 12px;
}

.search-result-row td:first-child {
	border-top-left-radius: 14px;
	border-bottom-left-radius: 14px;
}

.search-result-row td:last-child {
	border-top-right-radius: 14px;
	border-bottom-right-radius: 14px;
}

.result-emp-info {
	display: flex;
	align-items: center;
	gap: 12px;
}

.result-emp-avatar {
	width: 36px;
	height: 36px;
	border-radius: 10px;
	background: linear-gradient(135deg, #2563eb 0%, #4f46e5 100%);
	color: #ffffff;
	font-weight: 800;
	font-size: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.btn-select-emp {
	background: #2563eb;
	color: #ffffff;
	border: none;
	padding: 6px 14px;
	border-radius: 10px;
	font-size: 12px;
	font-weight: 800;
	cursor: pointer;
	transition: all 0.2s;
}

.btn-select-emp:hover {
	background: #1d4ed8;
	transform: scale(1.05);
}

/* 2-COLUMN SPLIT AUDITOR LAYOUT */
.split-auditor-container {
	display: grid;
	grid-template-columns: 370px 1fr;
	gap: 24px;
	align-items: start;
}

@media (max-width: 1150px) {
	.split-auditor-container { grid-template-columns: 1fr; }
}

/* LEFT STICKY AUDITOR PANEL */
.sticky-auditor-panel {
	position: sticky;
	top: 20px;
	display: flex;
	flex-direction: column;
	gap: 18px;
}

.auditor-card-panel { padding: 24px; background: #ffffff; }

.auditor-header {
	margin-bottom: 18px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding-bottom: 12px;
	border-bottom: 1px solid var(--border-color);
}
.auditor-header h3 { font-size: 16px; font-weight: 800; color: var(--blue-primary); display: flex; align-items: center; gap: 8px; }

.real-lop-badge-card {
	background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 100%);
	border: 1px solid #bbf7d0;
	border-radius: 18px;
	padding: 16px 20px;
	margin-bottom: 18px;
	box-shadow: 0 4px 14px rgba(16, 185, 129, 0.06);
}
.real-lop-badge-card small { display: block; font-size: 11px; font-weight: 800; color: #166534; text-transform: uppercase; margin-bottom: 4px; }
.real-lop-badge-card strong { font-size: 18px; font-weight: 800; color: #15803d; font-family: 'JetBrains Mono', monospace; }

.formula-select-box {
	background: var(--blue-light);
	border: 1px solid #bfdbfe;
	border-radius: 16px;
	padding: 14px;
	margin-bottom: 16px;
}
.formula-select-box label { font-size: 12px; font-weight: 800; color: #1e40af; display: block; margin-bottom: 6px; }

.lop-simulator-box {
	background: #fff5f5;
	border: 1px solid #fca5a5;
	border-radius: 16px;
	padding: 16px;
	margin-bottom: 18px;
}
.lop-simulator-box label { display: block; font-size: 12px; font-weight: 800; color: #b91c1c; margin-bottom: 10px; }

.lop-stepper-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }

.stepper-btn {
	width: 32px;
	height: 32px;
	border-radius: 8px;
	background: #ffffff;
	border: 1px solid #fca5a5;
	color: #dc2626;
	font-weight: 800;
	font-size: 14px;
	cursor: pointer;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: all 0.2s;
}
.stepper-btn:hover { background: #dc2626; color: #ffffff; }

.lop-stepper-row input {
	width: 64px;
	padding: 6px 10px;
	border-radius: 10px;
	background: #ffffff;
	border: 2px solid #ef4444;
	color: #dc2626;
	font-weight: 800;
	font-size: 14px;
	outline: none;
	text-align: center;
	font-family: 'JetBrains Mono', monospace;
}

.btn-lop-chip {
	padding: 6px 10px;
	border-radius: 8px;
	background: #ffffff;
	border: 1px solid #cbd5e1;
	color: var(--text-secondary);
	font-size: 11px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.2s;
}
.btn-lop-chip:hover { background: #fee2e2; color: #dc2626; border-color: #fca5a5; }

.btn-save-lop {
	background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
	color: white;
	border: none;
	padding: 12px 20px;
	border-radius: 14px;
	font-weight: 800;
	font-size: 13.5px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	width: 100%;
	justify-content: center;
	box-shadow: 0 4px 16px rgba(239, 68, 68, 0.3);
	transition: all 0.25s;
}
.btn-save-lop:hover {
	transform: translateY(-2px);
	box-shadow: 0 8px 22px rgba(239, 68, 68, 0.45);
	background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
}

.math-steps-stack { display: flex; flex-direction: column; gap: 10px; }
.math-step-item {
	background: #f8fafc;
	border: 1px solid var(--border-color);
	border-radius: 14px;
	padding: 12px 16px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	transition: all 0.2s;
}
.math-step-item small { display: block; font-size: 10.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; }
.math-step-item strong { font-size: 15px; font-family: 'JetBrains Mono', monospace; }

.retention-progress-bar {
	height: 6px;
	background: #e2e8f0;
	border-radius: 10px;
	overflow: hidden;
	margin-top: 12px;
}
.retention-progress-fill {
	height: 100%;
	background: linear-gradient(90deg, #10b981, #059669);
	width: 100%;
	border-radius: 10px;
	transition: width 0.3s ease;
}

/* RIGHT FORM PANEL */
.form-panel { padding: 32px; background: #ffffff; }

.section-container {
	border-radius: 20px;
	padding: 24px;
	margin-bottom: 24px;
	border: 1px solid var(--border-color);
}
.section-container.earnings { background: #f0fdf4; border-color: #bbf7d0; }
.section-container.deductions { background: #fef2f2; border-color: #fecaca; }
.section-container.config { background: #eff6ff; border-color: #bfdbfe; }

.section-title { font-size: 15px; font-weight: 800; margin-bottom: 18px; display: flex; align-items: center; justify-content: space-between; }
.section-title.earnings { color: #166534; }
.section-title.deductions { color: #991b1b; }
.section-title.config { color: #1e40af; }

.form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; }
.form-group label { display: block; font-size: 12px; font-weight: 800; color: #334155; margin-bottom: 6px; }
.form-group input, .form-group select {
	width: 100%;
	padding: 11px 14px;
	border-radius: 12px;
	background: #ffffff;
	border: 1px solid #cbd5e1;
	color: #0f172a;
	outline: none;
	font-size: 14px;
	font-weight: 700;
	font-family: 'JetBrains Mono', monospace;
	transition: all 0.2s;
}
.form-group input:focus, .form-group select:focus { border-color: var(--blue-primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); }

.summary-banner {
	background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
	color: white;
	border-radius: 20px;
	padding: 22px;
	margin-bottom: 24px;
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	text-align: center;
	gap: 12px;
	box-shadow: 0 12px 30px rgba(15, 23, 42, 0.2);
}
.summary-banner small { display: block; font-size: 11px; font-weight: 800; color: #93c5fd; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
.summary-banner span { font-size: 22px; font-weight: 800; font-family: 'JetBrains Mono', monospace; }

.btn-save {
	background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
	color: white;
	border: none;
	padding: 16px 32px;
	border-radius: 16px;
	font-weight: 800;
	font-size: 15px;
	cursor: pointer;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	width: 100%;
	justify-content: center;
	box-shadow: 0 8px 24px rgba(37, 99, 235, 0.35);
	transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}
.btn-save:hover { transform: translateY(-2px); box-shadow: 0 12px 30px rgba(37, 99, 235, 0.45); }

.alert-success {
	background: #dcfce7;
	color: #15803d;
	border: 1px solid #86efac;
	padding: 14px 20px;
	border-radius: 16px;
	margin-bottom: 24px;
	font-weight: 700;
	font-size: 14px;
	display: flex;
	align-items: center;
	gap: 10px;
}
</style>
</head>

<body>
<div class="app-wrapper">
	<!-- Unified Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Area -->
	<div class="main-content">

		<!-- Header -->
		<div class="top-header">
			<div class="header-title">
				<h1><i class="fa-solid fa-gears" style="color: #2563eb;"></i> Salary Setup Centre</h1>
				<p>Configure base salary components, inspect real monthly LOP deductions, and verify net payouts in one unified setup hub</p>
			</div>
			<a href="${pageContext.request.contextPath}/payrollDashboard" class="btn-outline-blue">
				<i class="fa-solid fa-arrow-left"></i> Back to Payroll Hub
			</a>
		</div>

		<% String successMsg = (String) request.getAttribute("successMessage");
		   if (successMsg != null) { %>
		<div class="alert-success"><i class="fa-solid fa-circle-check"></i> <%=successMsg%></div>
		<% } %>

		<!-- Target Employee Hero Banner & Selector Toolbar -->
		<section class="emp-target-banner">
			<div class="emp-profile-group">
				<div class="emp-avatar-circle"><%=empInitial%></div>
				<div class="emp-meta-info">
					<h2><%=selectedEmpName%></h2>
					<div class="emp-sub-tags">
						<span><i class="fa-solid fa-id-badge"></i> <%=empCode%></span>
						<span>•</span>
						<span><i class="fa-solid fa-building"></i> <%=empDept%></span>
						<span>•</span>
						<span class="status-tag <%=structStatus.toLowerCase()%>"><%=structStatus%></span>
					</div>
				</div>
			</div>

			<!-- Selector Toolbar: Command Palette Search Button, Month, Year -->
			<form action="${pageContext.request.contextPath}/manageSalary" method="get" id="selectEmpForm" class="selector-toolbar">
				<input type="hidden" name="employeeId" id="employeeSelectDropdown" value="<%=selectedEmployee != null ? selectedEmployee.getEmployee_id() : 0%>">

				<!-- 1. Premium Search Button / Trigger Pill -->
				<button type="button" class="btn-search-trigger" onclick="openSearchModal()" title="Search Employee (Ctrl+K)">
					<i class="fa-solid fa-magnifying-glass" style="color: #60a5fa;"></i>
					<span>Search Employee (Name, ID, Dept)...</span>
					<span class="search-kbd-badge">Ctrl K</span>
				</button>

				<!-- 2. Month Select Dropdown -->
				<select name="month" onchange="document.getElementById('selectEmpForm').submit()">
					<% for (int m = 1; m <= 12; m++) { %>
					<option value="<%=m%>" <%=m == selectedMonth ? "selected" : ""%>><%=Month.of(m).getDisplayName(TextStyle.FULL, Locale.ENGLISH)%></option>
					<% } %>
				</select>

				<!-- 3. Year Select Dropdown -->
				<select name="year" onchange="document.getElementById('selectEmpForm').submit()">
					<% for (int y = 2024; y <= 2030; y++) { %>
					<option value="<%=y%>" <%=y == selectedYear ? "selected" : ""%>><%=y%></option>
					<% } %>
				</select>
			</form>
		</section>

		<!-- 2-COLUMN SPLIT AUDITOR LAYOUT -->
		<div class="split-auditor-container">

			<!-- LEFT STICKY LIVE MATH AUDITOR PANEL -->
			<div class="sticky-auditor-panel">

				<!-- Real Monthly LOP System Card -->
				<div class="real-lop-badge-card">
					<small><i class="fa-solid fa-calendar-check"></i> System Logged LOP for <%=monthName%> <%=selectedYear%></small>
					<div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 4px;">
						<strong><%=realLopDays%> Days LOP</strong>
						<span style="font-size: 16px; font-weight: 800; color: #dc2626; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(realLopDeduction)%></span>
					</div>
				</div>

				<!-- Auditor Control Panel -->
				<div class="white-card auditor-card-panel">
					<div class="auditor-header">
						<h3><i class="fa-solid fa-calculator"></i> Live LOP Math Inspector</h3>
						<span id="lopBasisTag" style="font-size: 10.5px; background: #dbeafe; color: #1e40af; padding: 4px 10px; border-radius: 6px; font-weight: 800;">26 DAYS BASIC STD</span>
					</div>

					<!-- Calculation Basis Mode Toggle -->
					<div class="formula-select-box">
						<label><i class="fa-solid fa-square-poll-vertical"></i> LOP Formula Basis:</label>
						<select id="lopBasisSelect" onchange="calcPreview()" style="width: 100%; padding: 8px 12px; border-radius: 10px; border: 1px solid #bfdbfe; font-size: 12.5px; font-weight: 700; color: #0f172a; background: #ffffff;">
							<option value="basic26" selected>Standard Statutory (Basic / 26 Days)</option>
							<option value="gross30">Gross Salary Basis (Gross / 30 Days)</option>
							<option value="gross26">Gross Salary Basis (Gross / 26 Days)</option>
						</select>
					</div>

					<!-- LOP Simulator Box -->
					<div class="lop-simulator-box">
						<label><i class="fa-solid fa-user-minus"></i> Test LOP / Absent Days Simulator:</label>
						<div class="lop-stepper-row">
							<button type="button" class="stepper-btn" onclick="stepLop(-1)">-</button>
							<input type="number" id="testLopInput" value="<%=realLopDays%>" min="0" max="31" oninput="calcPreview()">
							<button type="button" class="stepper-btn" onclick="stepLop(1)">+</button>

							<button type="button" class="btn-lop-chip" onclick="setLop(0)">0d</button>
							<button type="button" class="btn-lop-chip" onclick="setLop(<%=realLopDays%>)">Sys (<%=realLopDays%>d)</button>
							<button type="button" class="btn-lop-chip" onclick="setLop(5)">5d</button>
						</div>
					</div>

					<!-- Math Breakdown Stack -->
					<div class="math-steps-stack">
						<div class="math-step-item">
							<div><small id="auditRateLabel">Daily Basic Rate (Basic / 26)</small><strong id="auditDailyRate" style="color: #0f172a;">₹0.00 /day</strong></div>
							<i class="fa-solid fa-calculator" style="color: #2563eb;"></i>
						</div>

						<div class="math-step-item" style="border-color: #fca5a5; background: #fff5f5;">
							<div><small style="color: #dc2626;">Simulated LOP Deduction</small><strong id="auditLopDed" style="color: #dc2626;">₹0.00</strong></div>
							<i class="fa-solid fa-user-minus" style="color: #dc2626;"></i>
						</div>

						<div class="math-step-item">
							<div><small style="color: #b91c1c;">Total Deductions Sum</small><strong id="auditTotalDed" style="color: #b91c1c;">₹0.00</strong></div>
							<i class="fa-solid fa-file-invoice-dollar" style="color: #b91c1c;"></i>
						</div>

						<div class="math-step-item" style="border-color: #86efac; background: #f0fdf4;">
							<div><small style="color: #15803d;">Simulated Net Salary</small><strong id="auditNet" style="color: #15803d; font-size: 18px;">₹0.00</strong></div>
							<i class="fa-solid fa-coins" style="color: #15803d;"></i>
						</div>
					</div>

					<!-- Net Retention Progress Bar -->
					<div style="margin-top: 14px;">
						<div style="display: flex; justify-content: space-between; font-size: 11px; font-weight: 700; color: #64748b;">
							<span>Net Retention Rate</span>
							<span id="retentionPercent">100%</span>
						</div>
						<div class="retention-progress-bar">
							<div class="retention-progress-fill" id="retentionBar"></div>
						</div>
					</div>

					<!-- Save LOP Math Action Form -->
					<form action="${pageContext.request.contextPath}/manageSalary" method="post" id="saveLopForm" style="margin-top: 18px;">
						<input type="hidden" name="action" value="saveLop">
						<input type="hidden" name="employeeId" value="<%=selectedEmployee != null ? selectedEmployee.getEmployee_id() : 0%>">
						<input type="hidden" name="month" value="<%=selectedMonth%>">
						<input type="hidden" name="year" value="<%=selectedYear%>">
						<input type="hidden" id="customLopDaysHidden" name="customLopDays" value="<%=realLopDays%>">
						<input type="hidden" id="formulaBasisHidden" name="formulaBasis" value="basic26">

						<button type="submit" class="btn-save-lop">
							<i class="fa-solid fa-floppy-disk"></i> Save LOP Math Calculation
						</button>
					</form>

				</div>
			</div>

			<!-- RIGHT SALARY STRUCTURE FORM PANEL -->
			<div class="white-card form-panel">
				<form action="${pageContext.request.contextPath}/manageSalary" method="post">
					<input type="hidden" name="employeeId" value="<%=selectedEmployee != null ? selectedEmployee.getEmployee_id() : 0%>">

					<!-- Earnings Section -->
					<div class="section-container earnings">
						<div class="section-title earnings">
							<span><i class="fa-solid fa-coins"></i> Monthly Earnings Components</span>
							<span id="liveEarningsTag" style="font-size: 13px; font-family: 'JetBrains Mono', monospace;">₹0.00</span>
						</div>
						<div class="form-grid">
							<div class="form-group">
								<label>Basic Salary (₹)</label>
								<input type="number" step="0.01" id="basicSalary" name="basicSalary" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getBasicSalary())%>" oninput="calcPreview()" required>
							</div>
							<div class="form-group">
								<label>HRA (House Rent) (₹)</label>
								<input type="number" step="0.01" id="hra" name="hra" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getHra())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Transport Allowance (₹)</label>
								<input type="number" step="0.01" id="transportAllowance" name="transportAllowance" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getTransportAllowance())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Medical Allowance (₹)</label>
								<input type="number" step="0.01" id="medicalAllowance" name="medicalAllowance" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getMedicalAllowance())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Performance Bonus (₹)</label>
								<input type="number" step="0.01" id="bonus" name="bonus" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getBonus())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Other Special Allowances (₹)</label>
								<input type="number" step="0.01" id="otherAllowances" name="otherAllowances" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getOtherAllowances())%>" oninput="calcPreview()">
							</div>
						</div>
					</div>

					<!-- Deductions Section -->
					<div class="section-container deductions">
						<div class="section-title deductions">
							<span><i class="fa-solid fa-file-invoice-dollar"></i> Monthly Statutory Deductions</span>
							<span id="liveDeductionsTag" style="font-size: 13px; font-family: 'JetBrains Mono', monospace;">₹0.00</span>
						</div>
						<div class="form-grid">
							<div class="form-group">
								<label>Provident Fund (PF) (₹)</label>
								<input type="number" step="0.01" id="pf" name="pf" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getPf())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Professional Tax (PT) (₹)</label>
								<input type="number" step="0.01" id="professionalTax" name="professionalTax" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getProfessionalTax())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Loan Deduction (₹)</label>
								<input type="number" step="0.01" id="loanDeduction" name="loanDeduction" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getLoanDeduction())%>" oninput="calcPreview()">
							</div>
							<div class="form-group">
								<label>Advance Salary Deduction (₹)</label>
								<input type="number" step="0.01" id="advanceSalary" name="advanceSalary" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getAdvanceSalary())%>" oninput="calcPreview()">
							</div>
							<div class="form-group" style="grid-column: 1 / -1;">
								<label>Other Statutory / Direct Deductions (₹)</label>
								<input type="number" step="0.01" id="otherDeductions" name="otherDeductions" value="<%=String.format(Locale.US, "%.2f", salaryStructure.getOtherDeductions())%>" oninput="calcPreview()">
							</div>
						</div>
					</div>

					<!-- Structure Settings & Effective Date Section -->
					<div class="section-container config">
						<div class="section-title config">
							<span><i class="fa-solid fa-sliders"></i> Structure Configuration &amp; Status</span>
						</div>
						<div class="form-grid">
							<div class="form-group">
								<label>Effective Date</label>
								<input type="date" id="effectiveFrom" name="effectiveFrom" value="<%=salaryStructure.getEffectiveFrom() != null ? salaryStructure.getEffectiveFrom().toString() : java.time.LocalDate.now().toString()%>">
							</div>
							<div class="form-group">
								<label>Structure Status</label>
								<select name="status">
									<option value="ACTIVE" <%="ACTIVE".equalsIgnoreCase(structStatus) ? "selected" : ""%>>ACTIVE</option>
									<option value="INACTIVE" <%="INACTIVE".equalsIgnoreCase(structStatus) ? "selected" : ""%>>INACTIVE</option>
									<option value="DRAFT" <%="DRAFT".equalsIgnoreCase(structStatus) ? "selected" : ""%>>DRAFT</option>
								</select>
							</div>
						</div>
					</div>

					<!-- Live Summary Banner -->
					<div class="summary-banner">
						<div><small>Calculated Gross Salary</small><span id="liveGross" style="color: white;">₹0.00</span></div>
						<div><small>Fixed Statutory Deductions</small><span id="liveDed" style="color: #fca5a5;">₹0.00</span></div>
						<div><small>Base Estimated Net Salary</small><span id="liveNet" style="color: #86efac;">₹0.00</span></div>
					</div>

					<button type="submit" class="btn-save">
						<i class="fa-solid fa-floppy-disk"></i> Save Employee Salary Structure
					</button>
				</form>
			</div>

		</div>

	</div>
</div>

<!-- EMPLOYEE QUICK SEARCH MODAL OVERLAY -->
<div class="modal-overlay" id="employeeSearchModal" onclick="closeSearchModalOnBackdrop(event)">
	<div class="modal-card">
		<div class="modal-header">
			<h3><i class="fa-solid fa-users-viewfinder" style="color: #3b82f6;"></i> Employee Salary Setup Search</h3>
			<button type="button" class="modal-close-btn" onclick="closeSearchModal()"><i class="fa-solid fa-xmark"></i></button>
		</div>
		<div class="modal-body">
			<div class="modal-search-bar">
				<i class="fa-solid fa-magnifying-glass"></i>
				<input type="text" id="modalSearchInput" placeholder="Search by Employee Name, ID (e.g., EMP001), or Department..." oninput="renderModalSearchResults()">
			</div>

			<!-- Department Quick Filter Badges -->
			<div class="dept-filter-chips" id="deptFilterChips">
				<!-- Populated dynamically -->
			</div>

			<!-- Search Results Table -->
			<table class="search-results-table">
				<thead>
					<tr>
						<th>Employee</th>
						<th>Emp ID</th>
						<th>Department</th>
						<th style="text-align: right;">Action</th>
					</tr>
				</thead>
				<tbody id="modalSearchResultsBody">
					<!-- Populated by JS -->
				</tbody>
			</table>
		</div>
	</div>
</div>

<script>
var empDataList = [
<% if (allEmployees != null) { 
	for (int i = 0; i < allEmployees.size(); i++) {
		Employee e = allEmployees.get(i);
		String codeStr = "EMP" + String.format("%03d", e.getEmployee_id());
		String eName = e.getEmployee_name() != null ? e.getEmployee_name().replace("\"", "\\\"").replace("\n", "") : "";
		String eDept = e.getDepartment() != null ? e.getDepartment().replace("\"", "\\\"").replace("\n", "") : "General";
		String eInit = !eName.isEmpty() ? eName.substring(0, 1).toUpperCase() : "E";
%>
	{
		id: <%=e.getEmployee_id()%>,
		name: "<%=eName%>",
		code: "<%=codeStr%>",
		department: "<%=eDept%>",
		initial: "<%=eInit%>"
	}<%=i < allEmployees.size() - 1 ? "," : ""%>
<% 	} 
} %>
];

var selectedModalDept = "<%=selectedDept%>";

function openSearchModal() {
	var modal = document.getElementById("employeeSearchModal");
	if (modal) {
		modal.classList.add("active");
		var modalInput = document.getElementById("modalSearchInput");
		if (modalInput) {
			setTimeout(function() { modalInput.focus(); }, 100);
		}
		initDeptChips();
		renderModalSearchResults();
	}
}

function closeSearchModal() {
	var modal = document.getElementById("employeeSearchModal");
	if (modal) {
		modal.classList.remove("active");
	}
}

function closeSearchModalOnBackdrop(e) {
	if (e.target && e.target.id === "employeeSearchModal") {
		closeSearchModal();
	}
}

function initDeptChips() {
	var container = document.getElementById("deptFilterChips");
	if (!container) return;

	var depts = ["All Departments"];
	empDataList.forEach(function(e) {
		if (e.department && !depts.includes(e.department)) {
			depts.push(e.department);
		}
	});

	var html = "";
	depts.forEach(function(d) {
		var activeClass = (d === selectedModalDept || (selectedModalDept === "ALL" && d === "All Departments")) ? "active" : "";
		html += '<button type="button" class="dept-chip ' + activeClass + '" onclick="filterModalByDept(\'' + d.replace(/'/g, "\\'") + '\', this)">' + d + '</button>';
	});

	container.innerHTML = html;
}

function filterModalByDept(dept, btnEl) {
	selectedModalDept = dept;
	var chips = document.querySelectorAll(".dept-chip");
	chips.forEach(function(c) { c.classList.remove("active"); });
	if (btnEl) btnEl.classList.add("active");
	renderModalSearchResults();
}

function renderModalSearchResults() {
	var tbody = document.getElementById("modalSearchResultsBody");
	var q = (document.getElementById("modalSearchInput").value || "").toLowerCase().trim();
	if (!tbody) return;

	var filtered = empDataList.filter(function(e) {
		var matchesQuery = !q ||
			e.name.toLowerCase().includes(q) ||
			e.code.toLowerCase().includes(q) ||
			e.department.toLowerCase().includes(q) ||
			String(e.id) === q;

		var matchesDept = (selectedModalDept === "ALL" || selectedModalDept === "All Departments") || (e.department.toLowerCase() === selectedModalDept.toLowerCase());

		return matchesQuery && matchesDept;
	});

	if (filtered.length === 0) {
		tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; padding: 30px; color: #64748b; font-weight: 600;"><i class="fa-solid fa-user-slash" style="font-size: 24px; margin-bottom: 8px; display: block;"></i>No matching employees found</td></tr>';
		return;
	}

	var currentSelectedId = "<%=selectedEmployee != null ? selectedEmployee.getEmployee_id() : 0%>";
	var html = "";

	filtered.forEach(function(e) {
		var isCurrent = String(e.id) === String(currentSelectedId);
		html += '<tr class="search-result-row" onclick="selectEmployeeAndSubmit(' + e.id + ')">';
		html += '  <td>';
		html += '    <div class="result-emp-info">';
		html += '      <div class="result-emp-avatar">' + e.initial + '</div>';
		html += '      <div>';
		html += '        <div style="font-weight: 800; color: #ffffff; font-size: 13.5px;">' + e.name + '</div>';
		html += '        <small style="color: #94a3b8; font-size: 11px;">' + e.department + '</small>';
		html += '      </div>';
		html += '    </div>';
		html += '  </td>';
		html += '  <td><span style="font-family: \'JetBrains Mono\', monospace; font-weight: 700; color: #60a5fa; font-size: 12.5px;">' + e.code + '</span></td>';
		html += '  <td><span style="font-size: 12px; color: #cbd5e1; font-weight: 600;">' + e.department + '</span></td>';
		html += '  <td style="text-align: right;">';
		if (isCurrent) {
			html += '    <span style="background: rgba(16, 185, 129, 0.2); color: #34d399; border: 1px solid rgba(52, 211, 153, 0.3); padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 800;"><i class="fa-solid fa-check"></i> Selected</span>';
		} else {
			html += '    <button type="button" class="btn-select-emp" onclick="event.stopPropagation(); selectEmployeeAndSubmit(' + e.id + ')"><i class="fa-solid fa-sliders"></i> Setup Salary</button>';
		}
		html += '  </td>';
		html += '</tr>';
	});

	tbody.innerHTML = html;
}

function selectEmployeeAndSubmit(empId) {
	var input = document.getElementById("employeeSelectDropdown");
	if (input) {
		input.value = empId;
	}
	document.getElementById("selectEmpForm").submit();
}

// Global Keyboard Shortcut: Ctrl + K or Cmd + K to open search modal, Esc to close
document.addEventListener("keydown", function(e) {
	if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") {
		e.preventDefault();
		openSearchModal();
	} else if (e.key === "Escape") {
		closeSearchModal();
	}
});

function setLop(days) {
	document.getElementById("testLopInput").value = days;
	calcPreview();
}

function stepLop(delta) {
	var input = document.getElementById("testLopInput");
	var current = parseInt(input.value) || 0;
	var nextVal = Math.max(0, current + delta);
	input.value = nextVal;
	calcPreview();
}

function calcPreview() {
	var basic = parseFloat(document.getElementById("basicSalary").value) || 0;
	var hra = parseFloat(document.getElementById("hra").value) || 0;
	var trans = parseFloat(document.getElementById("transportAllowance").value) || 0;
	var med = parseFloat(document.getElementById("medicalAllowance").value) || 0;
	var bonus = parseFloat(document.getElementById("bonus").value) || 0;
	var otherAllow = parseFloat(document.getElementById("otherAllowances").value) || 0;

	var pf = parseFloat(document.getElementById("pf").value) || 0;
	var pt = parseFloat(document.getElementById("professionalTax").value) || 0;
	var loan = parseFloat(document.getElementById("loanDeduction").value) || 0;
	var adv = parseFloat(document.getElementById("advanceSalary").value) || 0;
	var otherDed = parseFloat(document.getElementById("otherDeductions").value) || 0;

	var testLopDays = parseInt(document.getElementById("testLopInput").value) || 0;
	var gross = basic + hra + trans + med + bonus + otherAllow;
	var fixedDed = pf + pt + loan + adv + otherDed;

	var basisSelect = document.getElementById("lopBasisSelect");
	var basis = basisSelect ? basisSelect.value : "basic26";

	var dailyRate = 0;
	var rateLabel = "Daily Basic Rate (Basic / 26)";
	var tagText = "26 DAYS BASIC STD";

	if (basis === "gross30") {
		dailyRate = gross / 30.0;
		rateLabel = "Daily Rate (Gross / 30 Days)";
		tagText = "30 DAYS GROSS";
	} else if (basis === "gross26") {
		dailyRate = gross / 26.0;
		rateLabel = "Daily Rate (Gross / 26 Days)";
		tagText = "26 DAYS GROSS";
	} else {
		dailyRate = basic / 26.0;
		rateLabel = "Daily Basic Rate (Basic / 26)";
		tagText = "26 DAYS BASIC STD";
	}

	var lopDeduction = Math.round(dailyRate * testLopDays * 100.0) / 100.0;
	var totalDeductionsWithLop = fixedDed + lopDeduction;
	var simulatedNet = Math.max(0, Math.round((gross - totalDeductionsWithLop) * 100.0) / 100.0);

	var retentionPct = gross > 0 ? Math.max(0, Math.min(100, Math.round((simulatedNet / gross) * 100))) : 100;

	var tagEl = document.getElementById("lopBasisTag");
	if (tagEl) tagEl.innerText = tagText;

	var rateLabelEl = document.getElementById("auditRateLabel");
	if (rateLabelEl) rateLabelEl.innerText = rateLabel;

	document.getElementById("auditDailyRate").innerText = "₹" + dailyRate.toFixed(2) + " /day";
	document.getElementById("auditLopDed").innerText = "₹" + lopDeduction.toFixed(2);
	document.getElementById("auditTotalDed").innerText = "₹" + totalDeductionsWithLop.toFixed(2);
	document.getElementById("auditNet").innerText = "₹" + simulatedNet.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});

	document.getElementById("retentionPercent").innerText = retentionPct + "%";
	var barEl = document.getElementById("retentionBar");
	if (barEl) barEl.style.width = retentionPct + "%";

	document.getElementById("liveGross").innerText = "₹" + Math.round(gross).toLocaleString('en-IN');
	document.getElementById("liveDed").innerText = "₹" + Math.round(fixedDed).toLocaleString('en-IN');
	document.getElementById("liveNet").innerText = "₹" + Math.round(Math.max(0, gross - fixedDed)).toLocaleString('en-IN');

	document.getElementById("liveEarningsTag").innerText = "Sum: ₹" + Math.round(gross).toLocaleString('en-IN');
	document.getElementById("liveDeductionsTag").innerText = "Sum: ₹" + Math.round(fixedDed).toLocaleString('en-IN');

	var customHidden = document.getElementById("customLopDaysHidden");
	if (customHidden) customHidden.value = testLopDays;

	var basisHidden = document.getElementById("formulaBasisHidden");
	if (basisHidden) basisHidden.value = basis;
}

window.onload = function() {
	calcPreview();
};
</script>
</body>
</html>
