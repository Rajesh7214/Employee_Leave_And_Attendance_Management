<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.model.Notification"%>
<%
String role = (String) session.getAttribute("role");
if (role == null) role = "admin";
String displayName = (String) session.getAttribute("userEmail");
if (displayName == null) displayName = "Admin";

List<Employee> employeeList = (List<Employee>) request.getAttribute("employeeList");
if (employeeList == null) {
	employeeList = (List<Employee>) request.getAttribute("employees");
}
List<Notification> sentNotifications = (List<Notification>) request.getAttribute("sentNotifications");

String flashSuccess = (String) session.getAttribute("flashSuccess");
if (flashSuccess != null) session.removeAttribute("flashSuccess");

String backDashUrl = "admin".equalsIgnoreCase(role) ? "adminDashboardServlet" : "hr".equalsIgnoreCase(role) ? "hrDashboard" : "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";
int totalSent = sentNotifications != null ? sentNotifications.size() : 0;
int unreadCount = 0;
if (sentNotifications != null) {
	for (Notification n : sentNotifications) {
		if ("Unread".equalsIgnoreCase(n.getStatus()) || !n.isRead()) {
			unreadCount++;
		}
	}
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Notification Command Center | RChips Solutions</title>

<!-- Fonts & Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet" />
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
body { background: var(--surface-bg); color: var(--text-primary); min-height: 100vh; display: flex; }
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

.page-header {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 20px;
	padding: 22px 28px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24px;
	flex-wrap: wrap;
	gap: 12px;
	box-shadow: 0 4px 18px rgba(15, 23, 42, 0.03);
}

.title-icon {
	width: 52px;
	height: 52px;
	border-radius: 14px;
	background: linear-gradient(135deg, #2563eb, #1d4ed8);
	color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 22px;
	box-shadow: 0 4px 14px rgba(37, 99, 235, 0.3);
}

.page-title { display: flex; align-items: center; gap: 16px; }
.page-title h1 { font-size: 22px; font-weight: 800; color: #0f172a; }
.page-title p { font-size: 13px; color: var(--text-secondary); margin-top: 2px; }

.btn-header {
	padding: 10px 18px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	background: #ffffff;
	border: 1px solid var(--border-color);
	color: #334155;
	transition: all 0.2s ease;
}
.btn-header:hover { transform: translateY(-2px); border-color: var(--blue-primary); color: var(--blue-primary); box-shadow: 0 6px 18px rgba(37, 99, 235, 0.12); }

.alert-success {
	background: #f0fdf4;
	border: 1px solid #bbf7d0;
	color: #15803d;
	padding: 16px 20px;
	border-radius: 16px;
	margin-bottom: 22px;
	display: flex;
	align-items: center;
	gap: 12px;
	font-weight: 700;
	font-size: 14px;
}

/* 4 KPI Grid Cards */
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 24px; }
@media (max-width: 950px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }

.stat-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 20px;
	border: 1px solid var(--border-color);
	box-shadow: 0 4px 18px rgba(15, 23, 42, 0.03);
	display: flex;
	align-items: center;
	gap: 16px;
	transition: all 0.25s ease;
}
.stat-card:hover { transform: translateY(-3px); border-color: #bfdbfe; box-shadow: 0 10px 25px rgba(37, 99, 235, 0.08); }

.stat-icon { width: 46px; height: 46px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 20px; color: white; }
.icon-blue { background: linear-gradient(135deg, #2563eb, #1d4ed8); box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3); }
.icon-emerald { background: linear-gradient(135deg, #10b981, #059669); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); }
.icon-amber { background: linear-gradient(135deg, #f59e0b, #d97706); box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3); }
.icon-purple { background: linear-gradient(135deg, #8b5cf6, #7c3aed); box-shadow: 0 4px 12px rgba(139, 92, 246, 0.3); }

.stat-info h4 { font-size: 24px; font-weight: 800; color: #0f172a; font-family: 'JetBrains Mono', monospace; }
.stat-info p { font-size: 11.5px; font-weight: 700; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; margin-top: 2px; }

/* Content Split Layout */
.content-grid { display: grid; grid-template-columns: 1.05fr 0.95fr; gap: 24px; }
@media (max-width: 1100px) { .content-grid { grid-template-columns: 1fr; } }

.glass-card { padding: 26px; }
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 14px; border-bottom: 1px solid var(--border-color); }
.card-header h3 { font-size: 16px; font-weight: 800; color: #0f172a; display: flex; align-items: center; gap: 10px; }

.form-group { margin-bottom: 18px; }
.form-label { font-size: 12px; font-weight: 800; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; display: block; }

.form-control, .form-select {
	width: 100%;
	padding: 12px 16px;
	border-radius: 12px;
	border: 1px solid var(--border-color);
	background: #ffffff;
	color: #0f172a;
	font-size: 13.5px;
	font-weight: 600;
	outline: none;
	transition: all 0.2s ease;
}
.form-control:focus, .form-select:focus { border-color: var(--blue-primary); box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15); }
textarea.form-control { min-height: 110px; resize: vertical; }

.channel-box {
	background: #f8fafc;
	border: 1px solid var(--border-color);
	border-radius: 16px;
	padding: 18px;
	margin-bottom: 20px;
}
.channel-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin-top: 10px; }
.channel-option {
	background: #ffffff;
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 12px;
	display: flex;
	align-items: center;
	gap: 10px;
	cursor: pointer;
	transition: all 0.2s ease;
}
.channel-option:hover, .channel-option.selected { background: #eff6ff; border-color: var(--blue-primary); }
.channel-option input[type="checkbox"] { width: 16px; height: 16px; accent-color: var(--blue-primary); cursor: pointer; }

.btn-submit {
	width: 100%;
	padding: 14px;
	border-radius: 12px;
	background: linear-gradient(135deg, #2563eb, #1d4ed8);
	color: #ffffff;
	font-size: 14.5px;
	font-weight: 800;
	border: none;
	cursor: pointer;
	box-shadow: 0 6px 18px rgba(37, 99, 235, 0.25);
	transition: all 0.2s ease;
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 10px;
}
.btn-submit:hover { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(37, 99, 235, 0.35); }

/* Sent Feed Logs */
.notif-feed { display: flex; flex-direction: column; gap: 12px; max-height: 600px; overflow-y: auto; padding-right: 4px; }
.feed-item { background: #f8fafc; border: 1px solid var(--border-color); border-radius: 14px; padding: 16px; transition: all 0.2s ease; }
.feed-item:hover { background: #ffffff; border-color: #bfdbfe; transform: translateY(-2px); box-shadow: 0 6px 18px rgba(37, 99, 235, 0.08); }
.feed-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
.feed-title { font-size: 14px; font-weight: 800; color: #0f172a; }
.feed-desc { font-size: 12.5px; color: #475569; margin-bottom: 10px; line-height: 1.4; }
.feed-meta { font-size: 11.5px; color: var(--text-secondary); display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f1f5f9; padding-top: 8px; }

.badge-cat { padding: 3px 10px; border-radius: 12px; font-size: 10.5px; font-weight: 800; text-transform: uppercase; }
.cat-announcement { background: #e0f2fe; color: #0369a1; }
.cat-task { background: #f3e8ff; color: #7e22ce; }
.cat-meeting { background: #eff6ff; color: #1d4ed8; }
.cat-alert { background: #fee2e2; color: #b91c1c; }
</style>
</head>

<body>
<div class="app-wrapper">
	<!-- Unified Sidebar Navigation -->
	<%@ include file="/WEB-INF/jspf/sidebar.jspf" %>

	<!-- Main Content Workspace -->
	<div class="main-content">

		<!-- Page Header Navigation -->
		<div class="page-header">
			<div class="page-title">
				<div class="title-icon"><i class="fa-solid fa-paper-plane"></i></div>
				<div>
					<h1>Notification Command Center</h1>
					<p>RChips Solutions Multi-Channel Broadcast & Announcement Engine</p>
				</div>
			</div>
			<div style="display: flex; gap: 12px; align-items: center;">
				<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
				<a href="<%=backDashUrl%>" class="btn-header">
					<i class="fa-solid fa-arrow-left"></i> Dashboard
				</a>
			</div>
		</div>

		<!-- Flash Success Banner -->
		<% if (flashSuccess != null && !flashSuccess.isBlank()) { %>
		<div class="alert-success">
			<i class="fa-solid fa-circle-check" style="font-size: 20px;"></i>
			<span><%=flashSuccess%></span>
		</div>
		<% } %>

		<!-- 4 KPI Stat Cards -->
		<div class="stats-grid">
			<div class="stat-card" style="border-left: 4px solid #2563eb;">
				<div class="stat-icon icon-blue"><i class="fa-solid fa-bullhorn"></i></div>
				<div class="stat-info">
					<h4><%=totalSent%></h4>
					<p>Total Sent Alerts</p>
				</div>
			</div>
			<div class="stat-card" style="border-left: 4px solid #f59e0b;">
				<div class="stat-icon icon-amber"><i class="fa-solid fa-envelope-open"></i></div>
				<div class="stat-info">
					<h4><%=unreadCount%></h4>
					<p>Unread Inbound Alerts</p>
				</div>
			</div>
			<div class="stat-card" style="border-left: 4px solid #10b981;">
				<div class="stat-icon icon-emerald"><i class="fa-solid fa-paper-plane"></i></div>
				<div class="stat-info">
					<h4 style="color: #10b981;">ACTIVE</h4>
					<p>Email SMTP Dispatcher</p>
				</div>
			</div>
			<div class="stat-card" style="border-left: 4px solid #8b5cf6;">
				<div class="stat-icon icon-purple"><i class="fa-solid fa-comment-sms"></i></div>
				<div class="stat-info">
					<h4 style="color: #8b5cf6;">READY</h4>
					<p>Fast2SMS SMS Gateway</p>
				</div>
			</div>
		</div>

		<!-- Main Split Content Grid -->
		<div class="content-grid">

			<!-- LEFT: Send Notification Form Card -->
			<div class="white-card glass-card">
				<div class="card-header">
					<h3><i class="fa-solid fa-paper-plane" style="color: #2563eb;"></i> Broadcast New Notification</h3>
					<span style="font-size: 11.5px; font-weight: 800; padding: 4px 10px; border-radius: 12px; background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe;">Multi-Channel</span>
				</div>

				<form action="${pageContext.request.contextPath}/sendNotification" method="POST">
					<div class="form-group">
						<label class="form-label">Notification Title / Subject *</label>
						<input type="text" name="title" class="form-control" placeholder="e.g. Mandatory Team Meeting Tomorrow at 10:00 AM" required />
					</div>

					<div class="form-group">
						<label class="form-label">Notification Message Content *</label>
						<textarea name="message" class="form-control" placeholder="Type notification details, instructions, or agenda..." required></textarea>
					</div>

					<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 16px;">
						<div class="form-group" style="margin-bottom: 0;">
							<label class="form-label">Category</label>
							<select name="category" class="form-select">
								<option value="ANNOUNCEMENT">Announcement</option>
								<option value="TASK">Task Update</option>
								<option value="MEETING">Meeting Alert</option>
								<option value="LEAVE">Leave Update</option>
								<option value="PAYROLL">Payroll &amp; Salary</option>
								<option value="SECURITY">Security Alert</option>
							</select>
						</div>

						<div class="form-group" style="margin-bottom: 0;">
							<label class="form-label">Priority Level</label>
							<select name="priority" class="form-select">
								<option value="MEDIUM">Medium Priority</option>
								<option value="HIGH">High Priority</option>
								<option value="CRITICAL">Critical / Urgent</option>
								<option value="LOW">Low Priority</option>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label class="form-label">Target Audience / Recipient</label>
						<select name="targetAudience" class="form-select" id="targetAudienceSelect" onchange="toggleEmployeeDropdown()">
							<option value="ALL">All Employees (Company-wide Broadcast)</option>
							<option value="SPECIFIC">Specific Employee</option>
							<option value="MANAGER">All Managers &amp; Team Leads</option>
							<option value="HR">HR Team</option>
						</select>
					</div>

					<div class="form-group" id="employeeSelectBox" style="display: none;">
						<label class="form-label">Select Employee</label>
						<select name="recipientId" class="form-select">
							<% if (employeeList != null) {
								for (Employee emp : employeeList) { %>
							<option value="<%=emp.getEmployee_id()%>"><%=emp.getEmployee_name()%> (<%=emp.getDepartment() != null ? emp.getDepartment() : "General"%>)</option>
							<% } } %>
						</select>
					</div>

					<!-- Delivery Channel Selection -->
					<div class="channel-box">
						<label class="form-label" style="margin-bottom: 6px;">Select Delivery Channels</label>
						<div class="channel-grid">
							<label class="channel-option selected">
								<input type="checkbox" name="channelApp" value="true" checked />
								<span style="font-size: 12.5px; font-weight: 700; color: #0f172a;"><i class="fa-solid fa-desktop" style="color: #2563eb;"></i> In-App</span>
							</label>
							<label class="channel-option selected">
								<input type="checkbox" name="channelEmail" value="true" checked />
								<span style="font-size: 12.5px; font-weight: 700; color: #0f172a;"><i class="fa-solid fa-envelope" style="color: #10b981;"></i> Email</span>
							</label>
							<label class="channel-option">
								<input type="checkbox" name="channelSms" value="true" />
								<span style="font-size: 12.5px; font-weight: 700; color: #0f172a;"><i class="fa-solid fa-comment-sms" style="color: #8b5cf6;"></i> SMS</span>
							</label>
						</div>
					</div>

					<button type="submit" class="btn-submit">
						<i class="fa-solid fa-paper-plane"></i> Broadcast Notification Now
					</button>
				</form>
			</div>

			<!-- RIGHT: Recent Sent Feed Cards -->
			<div class="white-card glass-card">
				<div class="card-header">
					<h3><i class="fa-solid fa-clock-rotate-left" style="color: #2563eb;"></i> Broadcast Log &amp; Feed</h3>
					<span style="font-size: 12px; font-weight: 700; color: var(--text-secondary);"><%=totalSent%> Records</span>
				</div>

				<div class="notif-feed">
					<% if (sentNotifications != null && !sentNotifications.isEmpty()) {
						for (Notification n : sentNotifications) {
							String catClass = "cat-announcement";
							if ("TASK".equalsIgnoreCase(n.getCategory())) catClass = "cat-task";
							else if ("MEETING".equalsIgnoreCase(n.getCategory())) catClass = "cat-meeting";
							else if ("SECURITY".equalsIgnoreCase(n.getCategory()) || "CRITICAL".equalsIgnoreCase(n.getPriority())) catClass = "cat-alert";
					%>
					<div class="feed-item">
						<div class="feed-top">
							<span class="badge-cat <%=catClass%>"><%=n.getCategory() != null ? n.getCategory() : "ANNOUNCEMENT"%></span>
							<span style="font-size: 11px; font-weight: 700; color: var(--text-secondary);"><%=n.getCreatedAt() != null ? n.getCreatedAt().toString() : "Recent"%></span>
						</div>
						<div class="feed-title"><%=n.getTitle()%></div>
						<div class="feed-desc"><%=n.getMessage()%></div>
						<div class="feed-meta">
							<span><i class="fa-solid fa-user" style="color: #2563eb;"></i> To: <%=n.getReceiverId() > 0 ? "Employee #" + n.getReceiverId() : "Company-Wide Broadcast"%></span>
							<span style="font-weight: 800; color: #10b981;"><i class="fa-solid fa-circle-check"></i> Dispatched</span>
						</div>
					</div>
					<% } } else { %>
					<div style="text-align: center; padding: 40px; color: var(--text-secondary);">
						<i class="fa-solid fa-bell-slash" style="font-size: 36px; margin-bottom: 12px; color: #cbd5e1; display: block;"></i>
						No notification broadcast logs found yet.
					</div>
					<% } %>
				</div>
			</div>

		</div>

	</div>
</div>

<script>
function toggleEmployeeDropdown() {
	var select = document.getElementById("targetAudienceSelect");
	var box = document.getElementById("employeeSelectBox");
	if (select && box) {
		if (select.value === "SPECIFIC") {
			box.style.display = "block";
		} else {
			box.style.display = "none";
		}
	}
}
</script>
</body>
</html>