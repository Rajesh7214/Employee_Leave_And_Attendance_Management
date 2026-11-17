<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<%@ page import="com.rajesh.elams.model.Employee"%>

<%
if (session == null || session.getAttribute("loggedUser") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String role = (String) session.getAttribute("role");
String backDashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";

Employee loggedEmp = (Employee) session.getAttribute("employee");
int empId = loggedEmp != null ? loggedEmp.getEmployee_id() : (session.getAttribute("employeeId") != null ? (Integer) session.getAttribute("employeeId") : 1);
String empName = loggedEmp != null && loggedEmp.getEmployee_name() != null ? loggedEmp.getEmployee_name() : "Employee";

Object sickObj = request.getAttribute("sickLeaveBalance");
Object casualObj = request.getAttribute("casualLeaveBalance");
Object earnedObj = request.getAttribute("earnedLeaveBalance");

String sickBal = sickObj != null ? sickObj.toString() : "12 Days";
String casualBal = casualObj != null ? casualObj.toString() : "10 Days";
String earnedBal = earnedObj != null ? earnedObj.toString() : "15 Days";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Apply for Leave | ELAMS Enterprise</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: linear-gradient(180deg, #f0f9ff 0%, #f4f6fb 100%);
	color: #0f172a;
	min-height: 100vh;
}

/* Header Navbar - Ocean Teal & Sky Blue */
.navbar {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	padding: 16px 35px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	box-shadow: 0 4px 20px rgba(13, 148, 136, 0.28);
	position: sticky;
	top: 0;
	z-index: 100;
}

.navbar-brand {
	display: flex;
	align-items: center;
	gap: 12px;
	text-decoration: none;
	color: white;
}

.navbar-brand i {
	font-size: 22px;
	background: rgba(255, 255, 255, 0.22);
	width: 42px;
	height: 42px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
}

.navbar-title {
	font-size: 22px;
	font-weight: 800;
}

/* Layout Container */
.layout-wrapper {
	max-width: 960px;
	margin: 0 auto;
	padding: 35px 24px;
}

.page-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 25px;
}

.page-header h1 {
	font-size: 28px;
	font-weight: 800;
	color: #0f172a;
}

.back-btn {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	text-decoration: none;
	color: #0284c7;
	background: #e0f2fe;
	border: 1px solid #bae6fd;
	padding: 10px 22px;
	border-radius: 30px;
	font-weight: 700;
	font-size: 14px;
	transition: all 0.25s;
}

.back-btn:hover {
	background: #0284c7;
	color: white;
}

/* Leave Balance KPI Row */
.balance-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 16px;
	margin-bottom: 26px;
}

.balance-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 18px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.03);
	display: flex;
	align-items: center;
	gap: 14px;
}

.balance-icon {
	width: 44px;
	height: 44px;
	border-radius: 14px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 18px;
	flex-shrink: 0;
}

.balance-icon.teal { background: #ccfbf1; color: #0f766e; }
.balance-icon.blue { background: #e0f2fe; color: #0284c7; }
.balance-icon.purple { background: #f3e8ff; color: #7e22ce; }
.balance-icon.amber { background: #fef3c7; color: #b45309; }

.balance-info {
	display: flex;
	flex-direction: column;
}

.balance-num {
	font-size: 20px;
	font-weight: 800;
	color: #0f172a;
}

.balance-label {
	font-size: 12px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
}

/* Main Form Card */
.form-card {
	background: #ffffff;
	border-radius: 24px;
	padding: 35px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04), 0 0 0 1px rgba(226, 232, 240, 0.9);
	position: relative;
	overflow: hidden;
}

.form-card::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	height: 5px;
	background: linear-gradient(90deg, #0284c7 0%, #0d9488 100%);
}

.form-group {
	margin-bottom: 22px;
}

.form-group label {
	display: block;
	font-size: 13.5px;
	font-weight: 700;
	color: #334155;
	margin-bottom: 8px;
}

.form-group input[type="text"],
.form-group input[type="number"],
.form-group input[type="date"],
.form-group select,
.form-group textarea {
	width: 100%;
	padding: 13px 16px;
	border: 1.8px solid #cbd5e1;
	border-radius: 14px;
	font-size: 14.5px;
	color: #0f172a;
	background: #f8fafc;
	outline: none;
	transition: all 0.25s;
}

.form-group textarea {
	min-height: 95px;
	resize: vertical;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
	background: #ffffff;
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.14);
}

/* Leave Category Pills Grid */
.category-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
	gap: 10px;
	margin-bottom: 22px;
}

.category-pill {
	padding: 12px;
	border-radius: 14px;
	border: 2px solid #cbd5e1;
	text-align: center;
	cursor: pointer;
	background: #f8fafc;
	transition: all 0.25s;
}

.category-pill:hover {
	border-color: #0284c7;
	background: #f0f9ff;
}

.category-pill.active {
	border-color: #0284c7;
	background: #e0f2fe;
	box-shadow: 0 4px 12px rgba(2, 132, 199, 0.16);
}

.category-pill i {
	font-size: 18px;
	color: #0284c7;
	display: block;
	margin-bottom: 4px;
}

.category-pill span {
	font-size: 12.5px;
	font-weight: 800;
	color: #0f172a;
	display: block;
}

/* Quick Reason Chips */
.reason-chips {
	display: flex;
	gap: 8px;
	flex-wrap: wrap;
	margin-top: 8px;
}

.reason-chip {
	font-size: 12px;
	font-weight: 700;
	background: #f1f5f9;
	color: #0284c7;
	padding: 5px 12px;
	border-radius: 20px;
	cursor: pointer;
	border: 1px solid #e2e8f0;
	transition: all 0.15s;
}

.reason-chip:hover {
	background: #0284c7;
	color: white;
}

/* Duration Summary Box */
.duration-summary {
	background: #f0fdf4;
	border: 1px solid #bbf7d0;
	color: #166534;
	padding: 14px 18px;
	border-radius: 14px;
	font-size: 14px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 10px;
	margin-bottom: 22px;
}

/* Alerts */
.alert {
	padding: 14px 20px;
	border-radius: 14px;
	margin-bottom: 22px;
	font-size: 14px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 10px;
}

.alert-success { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }
.alert-error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }

/* Action Buttons */
.form-actions {
	display: flex;
	gap: 14px;
	margin-top: 10px;
}

.btn-submit {
	flex: 2;
	padding: 16px;
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	border: none;
	border-radius: 16px;
	font-size: 16px;
	font-weight: 800;
	cursor: pointer;
	box-shadow: 0 4px 16px rgba(2, 132, 199, 0.3);
	transition: all 0.25s;
	display: inline-flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
}

.btn-submit:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 20px rgba(2, 132, 199, 0.4);
}

.btn-reset {
	flex: 1;
	padding: 16px;
	background: #f1f5f9;
	color: #475569;
	border: 1px solid #cbd5e1;
	border-radius: 16px;
	font-size: 15px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.2s;
}

.btn-reset:hover {
	background: #e2e8f0;
	color: #0f172a;
}
</style>
</head>
<body>

	<!-- Top Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand">
			<i class="fa-solid fa-plane-departure"></i>
			<span class="navbar-title">Apply for Leave</span>
		</a>
		<div style="display: flex; align-items: center; gap: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
		</div>
	</div>

	<div class="layout-wrapper">

		<!-- Page Title Header -->
		<div class="page-header">
			<div>
				<h1>✈️ Submit Leave Application</h1>
				<p style="color: #64748b; font-size: 14.5px; font-weight: 600; margin-top: 4px;">
					Request vacation, sick leave, or personal time off for approval
				</p>
			</div>
			<a href="<%=backDashUrl%>" class="back-btn">
				<i class="fa-solid fa-house"></i> Dashboard
			</a>
		</div>

		<!-- Alerts -->
		<%
		String successMsg = (String) session.getAttribute("successMessage");
		String errorMsg = (String) session.getAttribute("errorMessage");
		if (successMsg != null) {
			session.removeAttribute("successMessage");
		%>
		<div class="alert alert-success">
			<i class="fa-solid fa-circle-check"></i> <%=successMsg%>
		</div>
		<% } %>

		<%
		if (errorMsg != null) {
			session.removeAttribute("errorMessage");
		%>
		<div class="alert alert-error">
			<i class="fa-solid fa-circle-exclamation"></i> <%=errorMsg%>
		</div>
		<% } %>

		<!-- Leave Balance KPI Cards -->
		<div class="balance-grid">
			<div class="balance-card">
				<div class="balance-icon teal">
					<i class="fa-solid fa-notes-medical"></i>
				</div>
				<div class="balance-info">
					<span class="balance-num"><%=sickBal%></span>
					<span class="balance-label">Sick Leave</span>
				</div>
			</div>

			<div class="balance-card">
				<div class="balance-icon blue">
					<i class="fa-solid fa-user-clock"></i>
				</div>
				<div class="balance-info">
					<span class="balance-num"><%=casualBal%></span>
					<span class="balance-label">Casual Leave</span>
				</div>
			</div>

			<div class="balance-card">
				<div class="balance-icon purple">
					<i class="fa-solid fa-umbrella-beach"></i>
				</div>
				<div class="balance-info">
					<span class="balance-num"><%=earnedBal%></span>
					<span class="balance-label">Earned Leave</span>
				</div>
			</div>

			<div class="balance-card">
				<div class="balance-icon amber">
					<i class="fa-solid fa-triangle-exclamation"></i>
				</div>
				<div class="balance-info">
					<span class="balance-num">5 Days</span>
					<span class="balance-label">Emergency</span>
				</div>
			</div>
		</div>

		<!-- Main Application Card -->
		<div class="form-card">
			<form action="applyLeave" method="post" id="leaveForm" onsubmit="return validateForm()">

				<input type="hidden" name="leaveType" id="leaveTypeInput" value="Casual" />

				<!-- Employee ID (Pre-filled) -->
				<div class="form-group">
					<label for="employeeId">Employee ID &amp; Name</label>
					<div style="display: flex; gap: 12px;">
						<input type="number" id="employeeId" name="employeeId" value="<%=empId%>" required style="width: 140px; font-weight: 800; color: #0284c7;" />
						<input type="text" value="<%=empName%>" readonly style="flex: 1; font-weight: 700; background: #e0f2fe; border-color: #bae6fd; color: #0369a1;" />
					</div>
				</div>

				<!-- Visual Leave Type Pills Selector -->
				<label style="font-size: 13.5px; font-weight: 700; color: #334155; margin-bottom: 8px; display: block;">Select Leave Type</label>
				<div class="category-grid">
					<div class="category-pill active" onclick="selectType('Casual', this)">
						<i class="fa-solid fa-mug-hot"></i>
						<span>Casual</span>
					</div>
					<div class="category-pill" onclick="selectType('Sick', this)">
						<i class="fa-solid fa-house-medical"></i>
						<span>Sick</span>
					</div>
					<div class="category-pill" onclick="selectType('Earned', this)">
						<i class="fa-solid fa-plane"></i>
						<span>Earned</span>
					</div>
					<div class="category-pill" onclick="selectType('Emergency', this)">
						<i class="fa-solid fa-truck-medical"></i>
						<span>Emergency</span>
					</div>
				</div>

				<!-- Date Selection Grid -->
				<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
					<div class="form-group">
						<label for="startDate">Start Date</label>
						<input type="date" id="startDate" name="startDate" required />
					</div>

					<div class="form-group">
						<label for="endDate">End Date</label>
						<input type="date" id="endDate" name="endDate" required />
					</div>
				</div>

				<!-- Duration Summary Pill -->
				<div class="duration-summary" id="durationSummary">
					<i class="fa-solid fa-calendar-day" style="font-size: 18px;"></i>
					<span id="durationText">Select start and end dates to calculate duration</span>
				</div>

				<!-- Reason Input with Quick Templates -->
				<div class="form-group">
					<label for="reason">Reason for Leave Request</label>
					<textarea id="reason" name="reason" placeholder="Please describe the purpose of your leave request..." required minlength="10"></textarea>
					
					<div style="margin-top: 6px;">
						<span style="font-size: 12px; font-weight: 700; color: #64748b;">Quick Preset Templates:</span>
						<div class="reason-chips">
							<span class="reason-chip" onclick="applyTemplate('Medical appointment and doctor checkup.')">🩺 Doctor Checkup</span>
							<span class="reason-chip" onclick="applyTemplate('Attending personal family function.')">🎉 Family Function</span>
							<span class="reason-chip" onclick="applyTemplate('Urgent personal work at home.')">🏠 Personal Work</span>
							<span class="reason-chip" onclick="applyTemplate('Planned annual vacation leave.')">✈️ Annual Vacation</span>
						</div>
					</div>
				</div>

				<!-- Buttons -->
				<div class="form-actions">
					<button type="submit" class="btn-submit" id="submitBtn">
						<i class="fa-solid fa-paper-plane"></i> Submit Leave Request
					</button>
					<button type="reset" class="btn-reset">
						<i class="fa-solid fa-rotate-left"></i> Reset
					</button>
				</div>

			</form>
		</div>

	</div>

	<script>
	function selectType(type, element) {
		document.getElementById("leaveTypeInput").value = type;
		document.querySelectorAll(".category-pill").forEach(function(pill) {
			pill.classList.remove("active");
		});
		element.classList.add("active");
	}

	function applyTemplate(text) {
		document.getElementById("reason").value = text;
	}

	function calculateDays() {
		var s = document.getElementById("startDate").value;
		var e = document.getElementById("endDate").value;
		var summary = document.getElementById("durationSummary");
		var text = document.getElementById("durationText");

		if (s && e) {
			var start = new Date(s);
			var end = new Date(e);
			if (end >= start) {
				var diffTime = Math.abs(end - start);
				var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
				text.innerHTML = "Total Requested Duration: <strong>" + diffDays + " Day" + (diffDays > 1 ? "s" : "") + "</strong>";
				summary.style.display = "flex";
			} else {
				text.innerHTML = "⚠️ End date cannot be before start date.";
				summary.style.background = "#fee2e2";
				summary.style.color = "#991b1b";
			}
		}
	}

	document.getElementById("startDate").addEventListener("change", calculateDays);
	document.getElementById("endDate").addEventListener("change", calculateDays);

	// Set min date to today
	var todayStr = new Date().toISOString().split('T')[0];
	document.getElementById("startDate").setAttribute("min", todayStr);
	document.getElementById("endDate").setAttribute("min", todayStr);

	function validateForm() {
		var s = document.getElementById("startDate").value;
		var e = document.getElementById("endDate").value;
		if (new Date(e) < new Date(s)) {
			alert("End date must be on or after start date.");
			return false;
		}
		var btn = document.getElementById("submitBtn");
		btn.innerHTML = '<i class="fa-solid fa-circle-notch fa-spin"></i> Submitting...';
		btn.style.opacity = "0.85";
		btn.style.pointerEvents = "none";
		return true;
	}
	</script>
</body>
</html>
