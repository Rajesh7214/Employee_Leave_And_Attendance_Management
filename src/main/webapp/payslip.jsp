<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.Payroll"%>
<%@ page import="com.rajesh.elams.model.PayrollStatus"%>
<%@ page import="java.text.NumberFormat"%>
<%@ page import="java.util.Locale"%>

<%
Payroll p = (Payroll) request.getAttribute("payroll");
if (p == null) {
	p = new Payroll();
}
NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
PayrollStatus statusEnum = PayrollStatus.fromString(p.getStatus());
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Official Payslip - EMP<%=String.format("%03d", p.getEmployeeId())%> | SmartOffice</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Plus Jakarta Sans', sans-serif; }
body { background: #f1f5f9; color: #0f172a; padding: 40px 20px; display: flex; justify-content: center; }

.payslip-container { background: white; width: 100%; max-width: 800px; border-radius: 20px; box-shadow: 0 10px 35px rgba(0, 0, 0, 0.1); border: 1px solid #e2e8f0; overflow: hidden; position: relative; }

.payslip-header { background: linear-gradient(135deg, #1e1b4b 0%, #312e81 100%); color: white; padding: 32px; display: flex; align-items: center; justify-content: space-between; }
.payslip-brand { display: flex; align-items: center; gap: 14px; }
.payslip-brand i { font-size: 28px; background: rgba(255, 255, 255, 0.15); width: 50px; height: 50px; border-radius: 14px; display: flex; align-items: center; justify-content: center; color: #38bdf8; }
.payslip-brand h2 { font-size: 22px; font-weight: 800; letter-spacing: -0.5px; }
.payslip-brand p { font-size: 12.5px; color: #a5b4fc; margin-top: 2px; }

.pay-period-badge { text-align: right; }
.pay-period-badge small { font-size: 11px; text-transform: uppercase; letter-spacing: 1px; color: #a5b4fc; font-weight: 700; }
.pay-period-badge h3 { font-size: 18px; font-weight: 800; color: white; margin-top: 2px; }

.payslip-body { padding: 32px; }

/* Employee Details Grid */
.emp-details-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 16px; padding: 20px; margin-bottom: 28px; }
.detail-item small { display: block; font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; }
.detail-item strong { display: block; font-size: 14px; font-weight: 800; color: #0f172a; margin-top: 2px; }

/* Earnings & Deductions Tables */
.tables-row { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 28px; }
.component-table { width: 100%; border-collapse: collapse; }
.component-table th { background: #f1f5f9; padding: 10px 14px; text-align: left; font-size: 12px; font-weight: 800; color: #475569; text-transform: uppercase; border-bottom: 2px solid #cbd5e1; }
.component-table td { padding: 10px 14px; font-size: 13px; color: #334155; border-bottom: 1px solid #e2e8f0; }
.component-table td:last-child { text-align: right; font-weight: 700; font-family: monospace; }
.component-table tr.total-row td { background: #f8fafc; font-weight: 800; font-size: 13.5px; color: #0f172a; border-top: 2px solid #cbd5e1; }

/* Net Pay Highlight Banner */
.net-pay-banner { background: linear-gradient(135deg, #ecfdf5, #d1fae5); border: 2px solid #6ee7b7; border-radius: 16px; padding: 20px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 28px; }
.net-pay-banner small { font-size: 12px; font-weight: 800; color: #047857; text-transform: uppercase; }
.net-pay-banner h1 { font-size: 28px; font-weight: 800; color: #065f46; font-family: monospace; }

/* Watermark Stamp */
.watermark-stamp { position: absolute; bottom: 80px; right: 60px; transform: rotate(-15deg); opacity: 0.15; border: 4px solid #10b981; color: #10b981; font-weight: 900; font-size: 32px; padding: 8px 24px; border-radius: 12px; text-transform: uppercase; pointer-events: none; }

/* Actions Bar */
.actions-bar { display: flex; align-items: center; justify-content: space-between; margin-top: 20px; }
.btn-print { background: #4f46e5; color: white; border: none; padding: 12px 24px; border-radius: 12px; font-weight: 800; font-size: 14px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; }

@media print {
	body { background: white; padding: 0; }
	.actions-bar { display: none; }
	.payslip-container { box-shadow: none; border: none; }
}
</style>
</head>

<body>
<div class="payslip-container">
	<!-- Header -->
	<div class="payslip-header">
		<div class="payslip-brand">
			<i class="fa-solid fa-building-columns"></i>
			<div>
				<h2>RChips Solutions</h2>
				<p>Monthly Employee Salary Slip</p>
			</div>
		</div>
		<div class="pay-period-badge">
			<small>Pay Period</small>
			<h3><%=p.getMonthName()%> <%=p.getYear()%></h3>
		</div>
	</div>

	<div class="payslip-body">
		<!-- Employee Details -->
		<div class="emp-details-grid">
			<div class="detail-item">
				<small>Employee Name</small>
				<strong><%=p.getEmployeeName() != null ? p.getEmployeeName() : "Employee #" + p.getEmployeeId()%></strong>
			</div>
			<div class="detail-item">
				<small>Employee ID</small>
				<strong>EMP<%=String.format("%03d", p.getEmployeeId())%></strong>
			</div>
			<div class="detail-item">
				<small>Department</small>
				<strong><%=p.getDepartment() != null ? p.getDepartment() : "N/A"%></strong>
			</div>
			<div class="detail-item">
				<small>Designation</small>
				<strong><%=p.getDesignation() != null ? p.getDesignation() : "N/A"%></strong>
			</div>
			<div class="detail-item">
				<small>Working Days / Present</small>
				<strong><%=p.getWorkingDays()%> Days / <%=p.getPresentDays()%> Days</strong>
			</div>
			<div class="detail-item">
				<small>Unpaid Leave (LOP)</small>
				<strong style="color: #dc2626;"><%=p.getUnpaidLeaveDays()%> Days LOP</strong>
			</div>
		</div>

		<!-- Earnings & Deductions -->
		<div class="tables-row">
			<div>
				<table class="component-table">
					<thead>
						<tr><th>Earnings Component</th><th style="text-align: right;">Amount (₹)</th></tr>
					</thead>
					<tbody>
						<tr><td>Basic Salary</td><td><%=currencyFmt.format(p.getBasicSalary())%></td></tr>
						<tr><td>House Rent Allowance (HRA)</td><td><%=currencyFmt.format(p.getHra())%></td></tr>
						<tr><td>Transport Allowance</td><td><%=currencyFmt.format(p.getTransportAllowance())%></td></tr>
						<tr><td>Medical Allowance</td><td><%=currencyFmt.format(p.getMedicalAllowance())%></td></tr>
						<% if (p.getBonus() > 0) { %>
						<tr><td>Performance Bonus</td><td><%=currencyFmt.format(p.getBonus())%></td></tr>
						<% } %>
						<% if (p.getOtherAllowances() > 0) { %>
						<tr><td>Other Special Allowances</td><td><%=currencyFmt.format(p.getOtherAllowances())%></td></tr>
						<% } %>
						<tr class="total-row"><td>Total Gross Earnings</td><td><%=currencyFmt.format(p.getGrossSalary())%></td></tr>
					</tbody>
				</table>
			</div>

			<div>
				<table class="component-table">
					<thead>
						<tr><th>Deductions Component</th><th style="text-align: right;">Amount (₹)</th></tr>
					</thead>
					<tbody>
						<tr><td>Provident Fund (PF)</td><td><%=currencyFmt.format(p.getPf())%></td></tr>
						<tr><td>Professional Tax (PT)</td><td><%=currencyFmt.format(p.getProfessionalTax())%></td></tr>
						<tr style="<%= (p.getUnpaidLeaveDeduction() > 0 || p.getUnpaidLeaveDays() > 0) ? "color: #dc2626; font-weight: 700;" : "" %>">
							<td>Unpaid Leave LOP (<%=p.getUnpaidLeaveDays()%> Days)</td>
							<td><%=currencyFmt.format(p.getUnpaidLeaveDeduction())%></td>
						</tr>
						<% if (p.getLoanDeduction() > 0) { %>
						<tr><td>Loan Deduction</td><td><%=currencyFmt.format(p.getLoanDeduction())%></td></tr>
						<% } %>
						<% if (p.getAdvanceSalary() > 0) { %>
						<tr><td>Advance Salary Deduction</td><td><%=currencyFmt.format(p.getAdvanceSalary())%></td></tr>
						<% } %>
						<% if (p.getOtherDeductions() > 0) { %>
						<tr><td>Other Deductions</td><td><%=currencyFmt.format(p.getOtherDeductions())%></td></tr>
						<% } %>
						<tr class="total-row"><td>Total Deductions</td><td style="color: #dc2626;"><%=currencyFmt.format(p.getTotalDeductions())%></td></tr>
					</tbody>
				</table>
			</div>
		</div>

		<!-- Net Payable Banner -->
		<div class="net-pay-banner">
			<div>
				<small>Net Disbursable Salary</small>
				<h1><%=currencyFmt.format(p.getNetSalary())%></h1>
			</div>
			<div style="text-align: right;">
				<small>Status</small>
				<div style="font-weight: 800; color: #047857; font-size: 16px;"><%=statusEnum.getDisplayName()%></div>
			</div>
		</div>

		<!-- Watermark Stamp -->
		<div class="watermark-stamp"><%=p.getStatus()%></div>

		<!-- Footer Actions Bar -->
		<div class="actions-bar">
			<a href="javascript:history.back()" style="color: #64748b; font-weight: 700; font-size: 13.5px;"><i class="fa-solid fa-arrow-left"></i> Back</a>
			<button onclick="window.print()" class="btn-print"><i class="fa-solid fa-print"></i> Print / Download Payslip PDF</button>
		</div>
	</div>
</div>
</body>
</html>
