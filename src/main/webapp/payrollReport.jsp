<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Payroll"%>
<%@ page import="com.rajesh.elams.model.PayrollSummary"%>
<%@ page import="com.rajesh.elams.model.PayrollStatus"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
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
String activePage = "payrollReport";

List<Payroll> payrolls = (List<Payroll>) request.getAttribute("payrolls");
PayrollSummary summary = (PayrollSummary) request.getAttribute("summary");

int currentMonth = request.getAttribute("currentMonth") != null ? (Integer) request.getAttribute("currentMonth") : 8;
int currentYear = request.getAttribute("currentYear") != null ? (Integer) request.getAttribute("currentYear") : 2026;

String currentMonthName = Month.of(currentMonth).getDisplayName(TextStyle.FULL, Locale.ENGLISH);
NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

// Calculate Departmental Aggregates
Map<String, double[]> deptStats = new HashMap<>(); // [gross, ded, net, count]
if (payrolls != null) {
	for (Payroll p : payrolls) {
		String dName = p.getDepartment() != null && !p.getDepartment().isBlank() ? p.getDepartment() : "General";
		double[] stat = deptStats.computeIfAbsent(dName, k -> new double[4]);
		stat[0] += p.getGrossSalary();
		stat[1] += p.getTotalDeductions();
		stat[2] += p.getNetSalary();
		stat[3] += 1;
	}
}

double totalGross = summary != null ? summary.getTotalGrossAmount() : 0.0;
double totalNet = summary != null ? summary.getTotalNetAmount() : 0.0;
double totalLop = summary != null ? summary.getTotalLopDeductionsAmount() : 0.0;
double totalStatutory = Math.max(0.0, totalGross - totalNet - totalLop);

double netPct = totalGross > 0 ? (totalNet / totalGross) * 100.0 : 0.0;
double statPct = totalGross > 0 ? (totalStatutory / totalGross) * 100.0 : 0.0;
double lopPct = totalGross > 0 ? (totalLop / totalGross) * 100.0 : 0.0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Monthly Payroll Analytical Report | RChips Solutions ELAMS</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
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

.white-card {
	background: var(--card-bg);
	border: 1px solid var(--border-color);
	border-radius: 20px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.04);
}

.top-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 16px; }
.header-title h1 {
	font-size: 26px;
	font-weight: 800;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 12px;
}
.header-title p { font-size: 13.5px; color: var(--text-secondary); margin-top: 4px; }

.period-select-form {
	display: flex;
	align-items: center;
	gap: 8px;
	background: #ffffff;
	padding: 8px 16px;
	border-radius: 14px;
	border: 2px solid var(--blue-primary);
	box-shadow: 0 4px 14px rgba(37, 99, 235, 0.1);
}
.period-select-form select {
	background: transparent;
	color: #0f172a;
	border: none;
	font-weight: 700;
	font-size: 14px;
	outline: none;
	cursor: pointer;
}

.btn-blue {
	background: linear-gradient(135deg, var(--blue-primary), var(--blue-dark));
	color: white;
	border: none;
	padding: 10px 20px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 800;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	cursor: pointer;
	transition: all 0.2s;
	box-shadow: 0 4px 14px rgba(37, 99, 235, 0.3);
}
.btn-blue:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(37, 99, 235, 0.45); }

/* KPI Visualizers Grid */
.kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(230px, 1fr)); gap: 20px; margin-bottom: 24px; }
.kpi-card {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 20px;
	padding: 22px;
	box-shadow: 0 10px 25px rgba(15, 23, 42, 0.04);
	transition: all 0.25s ease;
}
.kpi-card:hover { transform: translateY(-3px); border-color: #bfdbfe; box-shadow: 0 14px 30px rgba(37, 99, 235, 0.1); }
.kpi-title { font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
.kpi-value { font-size: 25px; font-weight: 800; color: #0f172a; font-family: 'JetBrains Mono', monospace; }

/* Financial Distribution Stacked Bar */
.financial-bar-card { padding: 20px 24px; margin-bottom: 26px; }
.fin-bar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.fin-bar-title { font-size: 14px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.fin-stacked-bar { height: 14px; width: 100%; background: #f1f5f9; border-radius: 10px; overflow: hidden; display: flex; gap: 2px; margin-bottom: 12px; border: 1px solid var(--border-color); }
.fin-seg { height: 100%; transition: width 0.6s ease; }
.fin-seg-net { background: linear-gradient(90deg, #10b981, #34d399); }
.fin-seg-stat { background: linear-gradient(90deg, #ef4444, #f87171); }
.fin-seg-lop { background: linear-gradient(90deg, #f59e0b, #fbbf24); }

.fin-legends { display: flex; gap: 24px; flex-wrap: wrap; }
.fin-legend-item { display: flex; align-items: center; gap: 8px; font-size: 12.5px; font-weight: 700; color: #475569; }
.fin-legend-dot { width: 10px; height: 10px; border-radius: 3px; }

/* Department Breakdown Section */
.dept-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 18px; margin-bottom: 26px; }
.dept-card { padding: 20px; }
.dept-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.dept-name { font-size: 15px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 8px; }
.dept-count-badge { background: var(--blue-light); color: var(--blue-dark); padding: 3px 10px; border-radius: 12px; font-size: 11.5px; font-weight: 800; }

.dept-stat-row { display: flex; justify-content: space-between; font-size: 12.5px; color: #475569; margin-bottom: 4px; }
.dept-stat-row strong { font-family: 'JetBrains Mono', monospace; color: #0f172a; }

/* Main Table Panel */
.table-card {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 24px;
	padding: 24px;
	box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
}
.data-table { width: 100%; border-collapse: separate; border-spacing: 0 6px; }
.data-table th { padding: 12px 16px; text-align: left; font-size: 11.5px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; }
.data-table tbody tr { background: #f8fafc; border-radius: 12px; transition: all 0.2s; }
.data-table tbody tr:hover { background: #eff6ff; }
.data-table td { padding: 14px 16px; font-size: 13.5px; color: #0f172a; vertical-align: middle; }
.data-table td:first-child { border-top-left-radius: 12px; border-bottom-left-radius: 12px; }
.data-table td:last-child { border-top-right-radius: 12px; border-bottom-right-radius: 12px; }

.emp-avatar-cell { display: flex; align-items: center; gap: 10px; }
.avatar-circle { width: 34px; height: 34px; border-radius: 10px; background: linear-gradient(135deg, var(--blue-primary), var(--blue-dark)); color: white; font-weight: 800; display: flex; align-items: center; justify-content: center; font-size: 13.5px; }

.badge-status { padding: 4px 10px; border-radius: 16px; font-size: 10.5px; font-weight: 800; display: inline-flex; align-items: center; gap: 5px; text-transform: uppercase; }
.badge-calculated { background: #e0f2fe; color: #0369a1; border: 1px solid #7dd3fc; }
.badge-pending { background: #fef3c7; color: #b45309; border: 1px solid #fcd34d; }
.badge-approved { background: #f3e8ff; color: #7e22ce; border: 1px solid #d8b4fe; }
.badge-paid { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
</style>
</head>

<body>
<div class="app-wrapper">
	<!-- Unified Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Area -->
	<div class="main-content">

		<!-- Top Header Navbar -->
		<div class="top-header">
			<div class="header-title">
				<h1><i class="fa-solid fa-chart-column" style="color: #2563eb;"></i> Monthly Payroll Analytical Report</h1>
				<p><%=currentMonthName%> <%=currentYear%> Executive Payroll Audit Breakdown & Departmental Analytics</p>
			</div>
			<div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
				<form method="get" action="${pageContext.request.contextPath}/payrollReport" class="period-select-form">
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
				<button type="button" class="btn-blue" onclick="window.print()" style="background: #ffffff; color: var(--blue-primary); border: 1px solid var(--blue-primary);">
					<i class="fa-solid fa-print"></i> Print Report
				</button>
				<a href="${pageContext.request.contextPath}/exportPayroll?month=<%=currentMonth%>&year=<%=currentYear%>" class="btn-blue">
					<i class="fa-solid fa-file-csv"></i> Export CSV Report
				</a>
			</div>
		</div>

		<!-- SECTION 1: KPI Visualizers Bar (4 Executive Pillars) -->
		<div class="kpi-grid">
			<div class="kpi-card" style="border-left: 4px solid #10b981;">
				<div class="kpi-title">Disbursable Net Payroll</div>
				<div class="kpi-value" style="color: #059669;"><%=currencyFmt.format(totalNet)%></div>
			</div>
			<div class="kpi-card" style="border-left: 4px solid #2563eb;">
				<div class="kpi-title">Gross Salary Budget</div>
				<div class="kpi-value" style="color: #1d4ed8;"><%=currencyFmt.format(totalGross)%></div>
			</div>
			<div class="kpi-card" style="border-left: 4px solid #ef4444;">
				<div class="kpi-title">Statutory Taxes & PF Deductions</div>
				<div class="kpi-value" style="color: #dc2626;"><%=currencyFmt.format(totalStatutory)%></div>
			</div>
			<div class="kpi-card" style="border-left: 4px solid #f59e0b;">
				<div class="kpi-title">Attendance LOP Deductions</div>
				<div class="kpi-value" style="color: #b45309;"><%=currencyFmt.format(totalLop)%></div>
			</div>
		</div>

		<!-- SECTION 2: Financial Expenditure Stacked Ratio Bar -->
		<div class="white-card financial-bar-card">
			<div class="fin-bar-header">
				<div class="fin-bar-title"><i class="fa-solid fa-chart-pie" style="color: #2563eb;"></i> Expenditure Distribution Ratio</div>
				<div style="font-size: 13px; font-weight: 800; color: #1e40af; font-family: 'JetBrains Mono', monospace;">
					Total Gross: <%=currencyFmt.format(totalGross)%>
				</div>
			</div>
			<div class="fin-stacked-bar">
				<div class="fin-seg fin-seg-net" style="width: <%=totalGross > 0 ? netPct : 100%>%;" title="Net Salary: <%=String.format(Locale.US, "%.1f", netPct)%>%"></div>
				<div class="fin-seg fin-seg-stat" style="width: <%=statPct%>%;" title="Statutory Taxes: <%=String.format(Locale.US, "%.1f", statPct)%>%"></div>
				<div class="fin-seg fin-seg-lop" style="width: <%=lopPct%>%;" title="Attendance LOP: <%=String.format(Locale.US, "%.1f", lopPct)%>%"></div>
			</div>
			<div class="fin-legends">
				<div class="fin-legend-item">
					<div class="fin-legend-dot" style="background: #10b981;"></div>
					Net Disbursable (<%=String.format(Locale.US, "%.1f", netPct)%>%)
				</div>
				<div class="fin-legend-item">
					<div class="fin-legend-dot" style="background: #ef4444;"></div>
					Statutory PF & Taxes (<%=String.format(Locale.US, "%.1f", statPct)%>%)
				</div>
				<div class="fin-legend-item">
					<div class="fin-legend-dot" style="background: #f59e0b;"></div>
					Attendance LOP Deductions (<%=String.format(Locale.US, "%.1f", lopPct)%>%)
				</div>
			</div>
		</div>

		<!-- SECTION 3: Departmental Expenditure Breakdown Cards -->
		<h2 style="font-size: 17px; font-weight: 800; color: #0f172a; margin-bottom: 16px; display: flex; align-items: center; gap: 10px;">
			<i class="fa-solid fa-building-user" style="color: #2563eb;"></i> Departmental Payroll Breakdown
		</h2>
		<div class="dept-grid">
			<%
			if (deptStats != null && !deptStats.isEmpty()) {
				for (Map.Entry<String, double[]> entry : deptStats.entrySet()) {
					String dName = entry.getKey();
					double[] st = entry.getValue();
			%>
			<div class="white-card dept-card">
				<div class="dept-header">
					<div class="dept-name"><i class="fa-solid fa-building" style="color: #2563eb;"></i> <%=dName%></div>
					<span class="dept-count-badge"><%=(int)st[3]%> Personnel</span>
				</div>
				<div class="dept-stat-row"><span>Gross Expenditure:</span><strong><%=currencyFmt.format(st[0])%></strong></div>
				<div class="dept-stat-row"><span>Total Deductions:</span><strong style="color: #dc2626;"><%=currencyFmt.format(st[1])%></strong></div>
				<div class="dept-stat-row" style="border-top: 1px solid var(--border-color); padding-top: 6px; margin-top: 6px;">
					<span style="font-weight: 800; color: #15803d;">Net Disbursable:</span>
					<strong style="color: #15803d; font-size: 15px;"><%=currencyFmt.format(st[2])%></strong>
				</div>
			</div>
			<%
				}
			} else {
			%>
			<div class="white-card dept-card" style="grid-column: 1 / -1; text-align: center; color: #64748b;">
				No departmental breakdown available for <%=currentMonthName%> <%=currentYear%>.
			</div>
			<% } %>
		</div>

		<!-- SECTION 4: Detailed Employee Audit Ledger Table -->
		<h2 style="font-size: 17px; font-weight: 800; color: #0f172a; margin-bottom: 16px; display: flex; align-items: center; gap: 10px;">
			<i class="fa-solid fa-list-check" style="color: #2563eb;"></i> Detailed Employee Audit Ledger
		</h2>
		<div class="table-card">
			<table class="data-table">
				<thead>
					<tr>
						<th>Employee</th>
						<th>Department</th>
						<th>Basic Salary</th>
						<th>Gross Salary</th>
						<th>Attendance LOP</th>
						<th>Total Deductions</th>
						<th>Net Salary</th>
						<th>Status</th>
					</tr>
				</thead>
				<tbody>
					<%
					if (payrolls != null && !payrolls.isEmpty()) {
						for (Payroll p : payrolls) {
							PayrollStatus sEnum = PayrollStatus.fromString(p.getStatus());
							String badgeCss = "badge-calculated";
							if ("PAID".equalsIgnoreCase(p.getStatus())) badgeCss = "badge-paid";
							else if ("APPROVED".equalsIgnoreCase(p.getStatus())) badgeCss = "badge-approved";
							else if ("PENDING_APPROVAL".equalsIgnoreCase(p.getStatus())) badgeCss = "badge-pending";

							String initial = p.getEmployeeName() != null && p.getEmployeeName().length() > 0 ? String.valueOf(p.getEmployeeName().charAt(0)).toUpperCase() : "E";
					%>
					<tr>
						<td>
							<div class="emp-avatar-cell">
								<div class="avatar-circle"><%=initial%></div>
								<div>
									<div style="font-weight: 800; color: #0f172a;"><%=p.getEmployeeName() != null ? p.getEmployeeName() : "Employee #" + p.getEmployeeId()%></div>
									<div style="font-size: 11px; color: #64748b;">
										<strong style="color: #2563eb;">EMP<%=String.format("%03d", p.getEmployeeId())%></strong> &bull; <%=p.getEmail() != null ? p.getEmail() : ""%>
									</div>
								</div>
							</div>
						</td>
						<td><span style="background: #eff6ff; color: #1e40af; padding: 3px 8px; border-radius: 6px; font-size: 11.5px; font-weight: 700;"><%=p.getDepartment() != null ? p.getDepartment() : "General"%></span></td>
						<td style="font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(p.getBasicSalary())%></td>
						<td style="font-family: 'JetBrains Mono', monospace; font-weight: 700;"><%=currencyFmt.format(p.getGrossSalary())%></td>
						<td>
							<% if (p.getUnpaidLeaveDays() > 0) { %>
							<span style="color: #dc2626; font-weight: 700; font-family: 'JetBrains Mono', monospace;">
								<%=currencyFmt.format(p.getUnpaidLeaveDeduction())%> (<%=p.getUnpaidLeaveDays()%>d)
							</span>
							<% } else { %>
							<span style="color: #94a3b8; font-size: 12px;">₹0.00 (0d)</span>
							<% } %>
						</td>
						<td style="color: #dc2626; font-family: 'JetBrains Mono', monospace;"><%=currencyFmt.format(p.getTotalDeductions())%></td>
						<td><strong style="color: #059669; font-family: 'JetBrains Mono', monospace; font-size: 15px;"><%=currencyFmt.format(p.getNetSalary())%></strong></td>
						<td>
							<span class="badge-status <%=badgeCss%>">
								<i class="fa-solid fa-circle" style="font-size: 7px;"></i> <%=sEnum.getDisplayName()%>
							</span>
						</td>
					</tr>
					<%
						}
					} else {
					%>
					<tr>
						<td colspan="8" style="text-align: center; padding: 40px; color: #64748b;">
							<i class="fa-solid fa-chart-line" style="font-size: 36px; margin-bottom: 12px; color: #94a3b8; display: block;"></i>
							No payroll report data available for <%=currentMonthName%> <%=currentYear%>.
						</td>
					</tr>
					<% } %>
				</tbody>
			</table>
		</div>

	</div>
</div>
</body>
</html>
