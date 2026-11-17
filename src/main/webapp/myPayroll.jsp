<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Payroll"%>
<%@ page import="com.rajesh.elams.model.PayrollStatus"%>
<%@ page import="com.rajesh.elams.model.SalaryStructure"%>
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
String activePage = "myPayroll";

Employee employee = (Employee) request.getAttribute("employee");
SalaryStructure salaryStructure = (SalaryStructure) request.getAttribute("salaryStructure");
Payroll currentMonthPayroll = (Payroll) request.getAttribute("currentMonthPayroll");
@SuppressWarnings("unchecked")
List<Payroll> payrollHistory = (List<Payroll>) request.getAttribute("payrollHistory");

int currentMonth = request.getAttribute("currentMonth") != null ? (Integer) request.getAttribute("currentMonth") : 8;
int currentYear = request.getAttribute("currentYear") != null ? (Integer) request.getAttribute("currentYear") : 2026;
String currentMonthName = Month.of(currentMonth).getDisplayName(TextStyle.FULL, Locale.ENGLISH);

NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

String empName = employee != null && employee.getEmployee_name() != null ? employee.getEmployee_name() : displayName;
String empDept = employee != null && employee.getDepartment() != null ? employee.getDepartment() : "General";
String empDesig = employee != null && employee.getDesignation() != null ? employee.getDesignation() : "Staff";
String empCode = employee != null ? String.format("EMP%03d", employee.getEmployee_id()) : "EMP001";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Salary & Payslips | RChips Solutions ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700;800&display=swap" rel="stylesheet" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/theme.css">

<style>
:root {
	--brand-primary: #4f46e5;
	--brand-emerald: #10b981;
	--brand-amber: #f59e0b;
	--brand-violet: #8b5cf6;
	--surface-bg: #f8fafc;
	--card-bg: #ffffff;
	--text-primary: #0f172a;
	--text-secondary: #64748b;
	--sidebar-w: 252px;
}

body {
	background: var(--surface-bg);
	color: var(--text-primary);
	min-height: 100vh;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

.main-content {
	margin-left: var(--sidebar-w);
	padding: 32px 40px 60px 40px;
	min-height: 100vh;
	transition: margin 0.3s ease;
}

@media (max-width: 992px) {
	.main-content {
		margin-left: 0;
		padding: 20px;
	}
}

/* ================= Header Banner ================= */
.payroll-hero-header {
	background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #312e81 100%);
	border-radius: 24px;
	padding: 32px 36px;
	color: #ffffff;
	margin-bottom: 28px;
	position: relative;
	overflow: hidden;
	box-shadow: 0 20px 40px rgba(15, 23, 42, 0.25);
}

.payroll-hero-header::before {
	content: '';
	position: absolute;
	top: -50%;
	right: -10%;
	width: 450px;
	height: 450px;
	background: radial-gradient(circle, rgba(99, 102, 241, 0.22) 0%, rgba(255, 255, 255, 0) 70%);
	border-radius: 50%;
	pointer-events: none;
}

.hero-top {
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 20px;
	position: relative;
	z-index: 2;
}

.emp-profile-pill {
	display: flex;
	align-items: center;
	gap: 16px;
}

.emp-avatar-box {
	width: 56px;
	height: 56px;
	border-radius: 16px;
	background: linear-gradient(135deg, #6366f1, #4f46e5);
	color: white;
	font-weight: 800;
	font-size: 22px;
	display: flex;
	align-items: center;
	justify-content: center;
	box-shadow: 0 8px 20px rgba(79, 70, 229, 0.4);
}

.emp-title-info h1 {
	font-size: 26px;
	font-weight: 800;
	letter-spacing: -0.5px;
	margin-bottom: 4px;
}

.emp-title-info p {
	font-size: 13.5px;
	color: #c7d2fe;
	display: flex;
	align-items: center;
	gap: 8px;
}

.code-tag {
	background: rgba(255, 255, 255, 0.15);
	padding: 2px 8px;
	border-radius: 6px;
	font-family: 'JetBrains Mono', monospace;
	font-weight: 700;
	color: #38bdf8;
	font-size: 12px;
}

.btn-payslip-main {
	background: #ffffff;
	color: #1e1b4b;
	padding: 12px 24px;
	border-radius: 14px;
	font-weight: 800;
	font-size: 14px;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 10px;
	box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
	transition: all 0.25s ease;
}

.btn-payslip-main:hover {
	background: #f8fafc;
	transform: translateY(-2px);
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.25);
	color: #312e81;
}

/* ================= KPI Stat Cards ================= */
.kpi-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
	gap: 20px;
	margin-bottom: 32px;
}

.kpi-card {
	background: var(--card-bg);
	border-radius: 20px;
	padding: 22px 24px;
	box-shadow: 0 4px 20px rgba(15, 23, 42, 0.04);
	border: 1px solid #f1f5f9;
	position: relative;
	transition: all 0.25s ease;
}

.kpi-card:hover {
	transform: translateY(-4px);
	box-shadow: 0 16px 32px rgba(15, 23, 42, 0.09);
	border-color: #cbd5e1;
}

.kpi-label {
	font-size: 12px;
	font-weight: 700;
	color: var(--text-secondary);
	text-transform: uppercase;
	letter-spacing: 0.6px;
	margin-bottom: 10px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.kpi-value {
	font-size: 26px;
	font-weight: 800;
	color: var(--text-primary);
	font-family: 'JetBrains Mono', monospace;
	margin-bottom: 6px;
}

.kpi-foot {
	font-size: 12px;
	color: var(--text-secondary);
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 6px;
}

/* ================= 2-Column Main Layout ================= */
.payroll-body-grid {
	display: grid;
	grid-template-columns: 1.15fr 0.85fr;
	gap: 28px;
}

@media (max-width: 1100px) {
	.payroll-body-grid {
		grid-template-columns: 1fr;
	}
}

.card-panel {
	background: var(--card-bg);
	border-radius: 20px;
	padding: 26px;
	box-shadow: 0 4px 20px rgba(15, 23, 42, 0.04);
	border: 1px solid #f1f5f9;
	margin-bottom: 24px;
}

.panel-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 20px;
	padding-bottom: 14px;
	border-bottom: 1px solid #f1f5f9;
}

.panel-title {
	font-size: 16.5px;
	font-weight: 800;
	color: var(--text-primary);
	display: flex;
	align-items: center;
	gap: 10px;
}

/* Itemized Component Table */
.itemized-table {
	width: 100%;
	border-collapse: collapse;
	font-size: 13.5px;
}

.itemized-table th {
	background: #f8fafc;
	color: #475569;
	font-weight: 700;
	text-align: left;
	padding: 10px 14px;
	border-bottom: 1px solid #e2e8f0;
	font-size: 12px;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.itemized-table td {
	padding: 11px 14px;
	border-bottom: 1px solid #f1f5f9;
	color: #334155;
}

.itemized-table td:last-child {
	text-align: right;
	font-weight: 700;
	font-family: 'JetBrains Mono', monospace;
}

.itemized-table tr.total-row td {
	background: #f8fafc;
	font-weight: 800;
	font-size: 14px;
	color: #0f172a;
	border-top: 2px solid #e2e8f0;
}

/* Status Badges */
.badge-status {
	padding: 4px 12px;
	border-radius: 20px;
	font-size: 11.5px;
	font-weight: 800;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	text-transform: uppercase;
}

.badge-draft { background: #f1f5f9; color: #64748b; }
.badge-calculated { background: #e0f2fe; color: #0284c7; }
.badge-pending { background: #fef3c7; color: #b45309; }
.badge-approved { background: #f3e8ff; color: #7e22ce; }
.badge-paid, .badge-processed { background: #dcfce7; color: #15803d; }

/* History List Items */
.history-card-item {
	background: #f8fafc;
	border: 1px solid #e2e8f0;
	border-radius: 16px;
	padding: 16px 20px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 12px;
	transition: all 0.2s ease;
}

.history-card-item:hover {
	background: #ffffff;
	border-color: #cbd5e1;
	transform: translateY(-2px);
	box-shadow: 0 6px 16px rgba(15, 23, 42, 0.05);
}

.btn-action-sm {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 8px 14px;
	border-radius: 10px;
	font-size: 12.5px;
	font-weight: 700;
	text-decoration: none;
	transition: all 0.15s ease;
}

.btn-view-slip {
	background: #e0e7ff;
	color: #4338ca;
}

.btn-view-slip:hover {
	background: #4338ca;
	color: #ffffff;
}
</style>
</head>

<body>

	<!-- Include Unified Sidebar -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf"%>

	<div class="main-content">

		<!-- Include Notification Bar -->
		<%@ include file="/WEB-INF/jspf/notificationBar.jspf"%>

		<%
		double basicVal = currentMonthPayroll != null ? currentMonthPayroll.getBasicSalary() : (salaryStructure != null ? salaryStructure.getBasicSalary() : 0.0);
		double hraVal = currentMonthPayroll != null ? currentMonthPayroll.getHra() : (salaryStructure != null ? salaryStructure.getHra() : 0.0);
		double transportVal = currentMonthPayroll != null ? currentMonthPayroll.getTransportAllowance() : (salaryStructure != null ? salaryStructure.getTransportAllowance() : 0.0);
		double medicalVal = currentMonthPayroll != null ? currentMonthPayroll.getMedicalAllowance() : (salaryStructure != null ? salaryStructure.getMedicalAllowance() : 0.0);
		double bonusVal = currentMonthPayroll != null ? currentMonthPayroll.getBonus() : (salaryStructure != null ? salaryStructure.getBonus() : 0.0);
		double otherAllowVal = currentMonthPayroll != null ? currentMonthPayroll.getOtherAllowances() : (salaryStructure != null ? salaryStructure.getOtherAllowances() : 0.0);
		double grossVal = currentMonthPayroll != null ? currentMonthPayroll.getGrossSalary() : (salaryStructure != null ? salaryStructure.getGrossSalary() : 0.0);

		double pfVal = currentMonthPayroll != null ? currentMonthPayroll.getPf() : (salaryStructure != null ? salaryStructure.getPf() : 0.0);
		double ptVal = currentMonthPayroll != null ? currentMonthPayroll.getProfessionalTax() : (salaryStructure != null ? salaryStructure.getProfessionalTax() : 0.0);
		double loanVal = currentMonthPayroll != null ? currentMonthPayroll.getLoanDeduction() : (salaryStructure != null ? salaryStructure.getLoanDeduction() : 0.0);
		double advanceVal = currentMonthPayroll != null ? currentMonthPayroll.getAdvanceSalary() : (salaryStructure != null ? salaryStructure.getAdvanceSalary() : 0.0);
		double otherDedVal = currentMonthPayroll != null ? currentMonthPayroll.getOtherDeductions() : (salaryStructure != null ? salaryStructure.getOtherDeductions() : 0.0);
		double lopVal = currentMonthPayroll != null ? currentMonthPayroll.getUnpaidLeaveDeduction() : 0.0;
		int lopDays = currentMonthPayroll != null ? currentMonthPayroll.getUnpaidLeaveDays() : 0;
		double totalDedVal = currentMonthPayroll != null ? currentMonthPayroll.getTotalDeductions() : (salaryStructure != null ? salaryStructure.getTotalDeductions() : 0.0);

		double netVal = currentMonthPayroll != null ? currentMonthPayroll.getNetSalary() : (salaryStructure != null ? salaryStructure.getNetSalary() : 0.0);
		String status = currentMonthPayroll != null ? currentMonthPayroll.getStatus() : "CALCULATED";
		PayrollStatus statusEnum = PayrollStatus.fromString(status);
		%>

		<!-- Hero Profile Header Banner -->
		<div class="payroll-hero-header">
			<div class="hero-top">
				<div class="emp-profile-pill">
					<div class="emp-avatar-box">
						<%=!empName.isEmpty() ? String.valueOf(empName.charAt(0)).toUpperCase() : "U"%>
					</div>
					<div class="emp-title-info">
						<h1><%=empName%></h1>
						<p>
							<span class="code-tag"><%=empCode%></span> &bull; 
							<i class="fa-solid fa-briefcase" style="color: #a5b4fc;"></i> <%=empDesig%> &bull; 
							<i class="fa-solid fa-building" style="color: #38bdf8;"></i> <%=empDept%>
						</p>
					</div>
				</div>

				<div>
					<% if (currentMonthPayroll != null) { %>
					<a href="${pageContext.request.contextPath}/payslip?id=<%=currentMonthPayroll.getPayrollId()%>" class="btn-payslip-main" target="_blank">
						<i class="fa-solid fa-file-invoice-dollar" style="color: #4f46e5;"></i> Download <%=currentMonthName%> Payslip
					</a>
					<% } else { %>
					<a href="${pageContext.request.contextPath}/payslip" class="btn-payslip-main" target="_blank">
						<i class="fa-solid fa-file-invoice-dollar" style="color: #4f46e5;"></i> View Payslip
					</a>
					<% } %>
				</div>
			</div>
		</div>

		<!-- 4 KPI Stat Cards Row -->
		<div class="kpi-grid">
			<div class="kpi-card" style="border-left: 4px solid #10b981;">
				<div class="kpi-label">
					<span>Estimated Net Payable</span>
					<i class="fa-solid fa-coins" style="color: #10b981;"></i>
				</div>
				<div class="kpi-value" style="color: #059669;"><%=currencyFmt.format(netVal)%></div>
				<div class="kpi-foot">
					<i class="fa-solid fa-calendar-check" style="color: #10b981;"></i> <%=currentMonthName%> <%=currentYear%> Disbursable
				</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #4f46e5;">
				<div class="kpi-label">
					<span>Monthly Gross Earnings</span>
					<i class="fa-solid fa-wallet" style="color: #4f46e5;"></i>
				</div>
				<div class="kpi-value" style="color: #4338ca;"><%=currencyFmt.format(grossVal)%></div>
				<div class="kpi-foot">
					<i class="fa-solid fa-circle-info" style="color: #6366f1;"></i> Before statutory deductions
				</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #ef4444;">
				<div class="kpi-label">
					<span>Total Deductions &amp; LOP</span>
					<i class="fa-solid fa-user-minus" style="color: #ef4444;"></i>
				</div>
				<div class="kpi-value" style="color: #dc2626;"><%=currencyFmt.format(totalDedVal)%></div>
				<div class="kpi-foot">
					<% if (lopDays > 0) { %>
					<span style="color: #b91c1c; font-weight: 700;"><i class="fa-solid fa-triangle-exclamation"></i> Includes <%=lopDays%> days LOP</span>
					<% } else { %>
					<i class="fa-solid fa-check" style="color: #10b981;"></i> Statutory PF &amp; Tax sum
					<% } %>
				</div>
			</div>

			<div class="kpi-card" style="border-left: 4px solid #8b5cf6;">
				<div class="kpi-label">
					<span>Payout Status</span>
					<i class="fa-solid fa-shield-check" style="color: #8b5cf6;"></i>
				</div>
				<div style="margin-top: 6px; margin-bottom: 8px;">
					<span class="badge-status <%=statusEnum.getCssClass()%>" style="font-size: 13px; padding: 6px 14px;">
						<i class="fa-solid fa-circle" style="font-size: 8px;"></i> <%=statusEnum.getDisplayName()%>
					</span>
				</div>
				<div class="kpi-foot">
					<i class="fa-solid fa-clock-rotate-left"></i> Period: <%=currentMonthName%> <%=currentYear%>
				</div>
			</div>
		</div>

		<!-- 2-Column Main Layout -->
		<div class="payroll-body-grid">

			<!-- LEFT COLUMN: Itemized 12-Component Compensation Matrix -->
			<div>
				<!-- Earnings Breakdown Panel -->
				<div class="card-panel">
					<div class="panel-header">
						<div class="panel-title"><i class="fa-solid fa-hand-holding-dollar" style="color: #10b981;"></i> Monthly Earnings Breakdown</div>
						<span style="font-size: 12px; font-weight: 800; background: #dcfce7; color: #15803d; padding: 4px 10px; border-radius: 8px;">+ Earnings</span>
					</div>
					<table class="itemized-table">
						<thead>
							<tr>
								<th>Component</th>
								<th style="text-align: right;">Amount (₹)</th>
							</tr>
						</thead>
						<tbody>
							<tr><td>Basic Salary</td><td><%=currencyFmt.format(basicVal)%></td></tr>
							<tr><td>House Rent Allowance (HRA)</td><td><%=currencyFmt.format(hraVal)%></td></tr>
							<tr><td>Transport Allowance</td><td><%=currencyFmt.format(transportVal)%></td></tr>
							<tr><td>Medical Allowance</td><td><%=currencyFmt.format(medicalVal)%></td></tr>
							<% if (bonusVal > 0) { %>
							<tr><td>Performance Bonus</td><td><%=currencyFmt.format(bonusVal)%></td></tr>
							<% } %>
							<% if (otherAllowVal > 0) { %>
							<tr><td>Other Special Allowances</td><td><%=currencyFmt.format(otherAllowVal)%></td></tr>
							<% } %>
							<tr class="total-row">
								<td>Total Gross Monthly Earnings</td>
								<td style="color: #047857;"><%=currencyFmt.format(grossVal)%></td>
							</tr>
						</tbody>
					</table>
				</div>

				<!-- Deductions Breakdown Panel -->
				<div class="card-panel">
					<div class="panel-header">
						<div class="panel-title"><i class="fa-solid fa-file-invoice" style="color: #ef4444;"></i> Deductions &amp; LOP Breakdown</div>
						<span style="font-size: 12px; font-weight: 800; background: #fee2e2; color: #b91c1c; padding: 4px 10px; border-radius: 8px;">- Deductions</span>
					</div>
					<table class="itemized-table">
						<thead>
							<tr>
								<th>Component</th>
								<th style="text-align: right;">Amount (₹)</th>
							</tr>
						</thead>
						<tbody>
							<tr><td>Provident Fund (PF)</td><td style="color: #dc2626;"><%=currencyFmt.format(pfVal)%></td></tr>
							<tr><td>Professional Tax (PT)</td><td style="color: #dc2626;"><%=currencyFmt.format(ptVal)%></td></tr>
							<% if (loanVal > 0) { %>
							<tr><td>Loan Deduction</td><td style="color: #dc2626;"><%=currencyFmt.format(loanVal)%></td></tr>
							<% } %>
							<% if (advanceVal > 0) { %>
							<tr><td>Advance Salary Deduction</td><td style="color: #dc2626;"><%=currencyFmt.format(advanceVal)%></td></tr>
							<% } %>
							<% if (lopVal > 0 || lopDays > 0) { %>
							<tr style="background: #fff1f2;">
								<td><strong style="color: #b91c1c;"><i class="fa-solid fa-user-minus"></i> Unpaid Leave (LOP <%=lopDays%> Days)</strong></td>
								<td style="color: #b91c1c;"><%=currencyFmt.format(lopVal)%></td>
							</tr>
							<% } else { %>
							<tr>
								<td><span style="color: var(--text-muted);"><i class="fa-solid fa-user-minus"></i> Unpaid Leave (LOP 0 Days)</span></td>
								<td style="color: var(--text-muted);">₹0.00</td>
							</tr>
							<% } %>
							<% if (otherDedVal > 0) { %>
							<tr><td>Other Deductions</td><td style="color: #dc2626;"><%=currencyFmt.format(otherDedVal)%></td></tr>
							<% } %>
							<tr class="total-row">
								<td>Total Monthly Deductions</td>
								<td style="color: #b91c1c;"><%=currencyFmt.format(totalDedVal)%></td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

			<!-- RIGHT COLUMN: Historical Payslips Ledger -->
			<div>
				<div class="card-panel">
					<div class="panel-header">
						<div class="panel-title"><i class="fa-solid fa-clock-rotate-left" style="color: #4f46e5;"></i> Payslips History &amp; Archives</div>
						<span style="font-size: 12px; font-weight: 700; color: #64748b;"><%=payrollHistory != null ? payrollHistory.size() : 0%> Records</span>
					</div>

					<% if (payrollHistory != null && !payrollHistory.isEmpty()) { 
						for (Payroll p : payrollHistory) {
							PayrollStatus sEnum = PayrollStatus.fromString(p.getStatus());
					%>
					<div class="history-card-item">
						<div style="display: flex; align-items: center; gap: 14px;">
							<div style="width: 40px; height: 40px; border-radius: 12px; background: #e0e7ff; color: #4338ca; display: flex; align-items: center; justify-content: center; font-size: 16px;">
								<i class="fa-solid fa-file-invoice-dollar"></i>
							</div>
							<div>
								<div style="font-size: 14.5px; font-weight: 800; color: #0f172a;"><%=p.getMonthName()%> <%=p.getYear()%></div>
								<div style="font-size: 11.5px; color: #64748b;">Pay Date: <%=p.getPaymentDate() != null ? p.getPaymentDate().toString() : "End of Month"%></div>
							</div>
						</div>

						<div style="display: flex; align-items: center; gap: 14px;">
							<div style="text-align: right;">
								<div style="font-size: 15px; font-weight: 800; color: #059669; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(p.getNetSalary())%></div>
								<span class="badge-status <%=sEnum.getCssClass()%>"><%=sEnum.getDisplayName()%></span>
							</div>
							<a href="${pageContext.request.contextPath}/payslip?id=<%=p.getPayrollId()%>" class="btn-action-sm btn-view-slip" target="_blank" title="View Payslip">
								<i class="fa-solid fa-print"></i> Payslip
							</a>
						</div>
					</div>
					<% } } else { %>
					<div style="text-align: center; padding: 40px 20px; color: #64748b;">
						<i class="fa-solid fa-receipt" style="font-size: 36px; color: #cbd5e1; margin-bottom: 10px; display: block;"></i>
						<h4>No Historical Payslips Found</h4>
						<p style="font-size: 12.5px;">Your monthly payslip archives will appear here after payroll calculations.</p>
					</div>
					<% } %>
				</div>
			</div>

		</div>

	</div>

</body>
</html>
