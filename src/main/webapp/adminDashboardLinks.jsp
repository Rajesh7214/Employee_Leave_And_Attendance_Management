<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%
User loggedUser = (User) session.getAttribute("loggedUser");
String role = (String) session.getAttribute("role");
if (loggedUser == null || role == null || !"admin".equalsIgnoreCase(role)) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Navigation - ELAMS</title>

<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', "Segoe UI", sans-serif;
}

body {
	background: #f4f7fc;
	display: flex;
	justify-content: center;
	align-items: center;
	min-height: 100vh;
	padding: 20px;
}

.menu-container {
	width: 440px;
	background: #fff;
	border-radius: 18px;
	padding: 32px;
	box-shadow: 0 15px 35px rgba(15, 23, 42, 0.12), 0 0 0 1px rgba(226, 232, 240, 0.8);
}

.menu-title {
	text-align: center;
	color: #1e3a8a;
	margin-bottom: 25px;
	font-size: 26px;
	font-weight: 800;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
}

.menu {
	display: flex;
	flex-direction: column;
	gap: 14px;
}

.menu a {
	text-decoration: none;
	padding: 14px 18px;
	border-radius: 12px;
	font-size: 15px;
	font-weight: 700;
	display: flex;
	align-items: center;
	gap: 12px;
	color: white;
	transition: all 0.2s ease;
}

.menu a:hover {
	transform: translateX(6px);
	filter: brightness(1.05);
}

.dashboard { background: #4f46e5; }
.employee { background: #2563eb; }
.leave { background: #f59e0b; }
.attendance { background: #10b981; }
.meeting { background: #7c3aed; }
.logout { background: #ef4444; }

.footer {
	text-align: center;
	margin-top: 24px;
	color: #94a3b8;
	font-size: 13px;
	font-weight: 600;
}
</style>
</head>

<body>

	<div class="menu-container">

		<h2 class="menu-title">
			<i class="bi bi-speedometer2"></i> Admin Navigation
		</h2>

		<div class="menu">
			<a href="${pageContext.request.contextPath}/adminDashboardServlet" class="dashboard">
				<i class="bi bi-speedometer2"></i> Main Dashboard
			</a>
			<a href="${pageContext.request.contextPath}/hrDashboard" class="dashboard" style="background: #4338ca;">
				<i class="bi bi-shield-heart"></i> HR Command Hub
			</a>
			<a href="${pageContext.request.contextPath}/viewEmployeesServlet" class="employee">
				<i class="bi bi-people-fill"></i> Manage Employees
			</a>
			<a href="${pageContext.request.contextPath}/leaveRequests" class="leave">
				<i class="bi bi-calendar-check-fill"></i> Manage Leave Requests
			</a>
			<a href="${pageContext.request.contextPath}/attendance.jsp" class="attendance">
				<i class="bi bi-clock-history"></i> Attendance Management
			</a>
			<a href="${pageContext.request.contextPath}/attendanceHistory" class="attendance">
				<i class="bi bi-graph-up-arrow"></i> Attendance History
			</a>
			<a href="${pageContext.request.contextPath}/payrollDashboard" class="dashboard" style="background: #059669;">
				<i class="bi bi-cash-stack"></i> Payroll Executive Hub
			</a>
			<a href="${pageContext.request.contextPath}/manageSalary" class="employee" style="background: #0284c7;">
				<i class="bi bi-gear-fill"></i> Salary Structure Setup
			</a>
			<a href="${pageContext.request.contextPath}/payrollReport" class="leave" style="background: #7c3aed;">
				<i class="bi bi-file-earmark-bar-graph"></i> Payroll Reports
			</a>
			<a href="${pageContext.request.contextPath}/sendNotification" class="leave">
				<i class="bi bi-megaphone-fill"></i> Send Notifications
			</a>
			<a href="${pageContext.request.contextPath}/viewMeetings" class="meeting">
				<i class="bi bi-camera-video-fill"></i> Meetings Management
			</a>
			<a href="${pageContext.request.contextPath}/auditLogs" class="dashboard" style="background: #0f172a;">
				<i class="bi bi-shield-check"></i> System Audit Logs
			</a>
			<a href="${pageContext.request.contextPath}/systemSettings" class="employee" style="background: #4f46e5;">
				<i class="bi bi-sliders"></i> System Settings
			</a>

			<a href="${pageContext.request.contextPath}/logout" class="logout" onclick="return confirm('Are you sure you want to logout?');">
				<i class="bi bi-box-arrow-right"></i> Logout
			</a>
		</div>

		<div class="footer">Employee Leave & Attendance Management System</div>

	</div>

</body>
</html>
