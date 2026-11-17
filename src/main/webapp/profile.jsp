<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.User"%>
<%@ page import="com.rajesh.elams.model.Employee"%>
<%@ page import="com.rajesh.elams.dao.EmployeeDao"%>
<%@ page import="com.rajesh.elams.dao.EmployeeDaoImpl"%>
<%
User loggedUser = (User) session.getAttribute("loggedUser");
if (loggedUser == null) {
	response.sendRedirect("login.jsp");
	return;
}

String role = (String) session.getAttribute("role");
if (role == null) role = "employee";

Employee employee = (Employee) session.getAttribute("employee");
if (employee == null) {
	try {
		EmployeeDao empDao = new EmployeeDaoImpl();
		employee = empDao.getEmployeeByEmail(loggedUser.getEmail());
	} catch (Exception ignored) {}
}

String empName = (employee != null && employee.getEmployee_name() != null) ? employee.getEmployee_name() : loggedUser.getEmail().split("@")[0];
empName = Character.toUpperCase(empName.charAt(0)) + empName.substring(1);
int empId = (employee != null) ? employee.getEmployee_id() : 0;
String empEmail = (employee != null && employee.getEmail() != null) ? employee.getEmail() : loggedUser.getEmail();
String empPhone = (employee != null && employee.getPhone() != 0) ? String.valueOf(employee.getPhone()) : "";
String empDept = (employee != null && employee.getDepartment() != null) ? employee.getDepartment() : "General";
String empDesig = (employee != null && employee.getDesignation() != null) ? employee.getDesignation() : role.toUpperCase();
String initial = !empName.isEmpty() ? empName.substring(0, 1).toUpperCase() : "U";

String rawPhoto = (employee != null && employee.getProfile_photo() != null) ? employee.getProfile_photo() : "";
String customPhotoUrl = (rawPhoto.contains("ui-avatars.com")) ? "" : rawPhoto;

String profilePhoto = !rawPhoto.isBlank()
		? rawPhoto
		: "https://ui-avatars.com/api/?name=" + empName + "&background=4f46e5&color=fff&bold=true";

String dashboardUrl = "employeeDashboardServlet";
if ("admin".equalsIgnoreCase(role)) {
	dashboardUrl = "adminDashboardServlet";
} else if ("hr".equalsIgnoreCase(role)) {
	dashboardUrl = "hrDashboard";
} else if ("manager".equalsIgnoreCase(role)) {
	dashboardUrl = "managerDashboard";
}

boolean isUpdated = "true".equalsIgnoreCase(request.getParameter("updated"));
boolean isError = request.getParameter("error") != null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | ELAMS</title>

<!-- Fonts & FontAwesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Plus Jakarta Sans', -apple-system, sans-serif;
}

body {
	background: #f8fafc;
	color: #0f172a;
	display: flex;
	min-height: 100vh;
}

/* Main Content Area */
.main {
	margin-left: 0;
	width: 100%;
	min-height: 100vh;
	display: flex;
	flex-direction: column;
}

/* Topbar */
.topbar {
	height: 70px;
	background: #ffffff;
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 0 36px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05), 0 1px 2px rgba(0, 0, 0, 0.03);
	position: sticky;
	top: 0;
	z-index: 90;
}

.topbar h2 {
	color: #0f172a;
	font-size: 20px;
	font-weight: 800;
}

.right-icons {
	display: flex;
	align-items: center;
	gap: 18px;
}

.profile-avatar-pill {
	display: flex;
	align-items: center;
	gap: 10px;
	padding: 5px 14px 5px 6px;
	background: #f1f5f9;
	border-radius: 30px;
	text-decoration: none;
	color: #0f172a;
	font-weight: 700;
	font-size: 13px;
	transition: background 0.2s ease;
}
.profile-avatar-pill:hover {
	background: #e2e8f0;
}

.profile-avatar {
	width: 34px;
	height: 34px;
	border-radius: 50%;
	background: linear-gradient(135deg, #4f46e5, #7c3aed);
	display: flex;
	justify-content: center;
	align-items: center;
	color: #fff;
	font-weight: 800;
	font-size: 14px;
}

/* Content Container */
.content {
	padding: 36px 24px;
	flex: 1;
	width: 100%;
	max-width: 1050px;
	margin: 0 auto;
}

/* Profile Banner Card */
.profile-hero-card {
	background: #ffffff;
	border-radius: 24px;
	box-shadow: 0 10px 30px -5px rgba(15, 23, 42, 0.05), 0 0 0 1px rgba(226, 232, 240, 0.8);
	overflow: hidden;
	margin-bottom: 28px;
	position: relative;
}

.profile-cover {
	height: 160px;
	background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #ec4899 100%);
	position: relative;
	overflow: hidden;
}

.profile-cover::before {
	content: '';
	position: absolute;
	top: -50%;
	right: -20%;
	width: 400px;
	height: 400px;
	background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0) 70%);
	border-radius: 50%;
}

.profile-hero-body {
	padding: 0 32px 28px;
	display: flex;
	align-items: flex-end;
	justify-content: space-between;
	margin-top: -50px;
	flex-wrap: wrap;
	gap: 20px;
}

.profile-main-info {
	display: flex;
	align-items: flex-end;
	gap: 24px;
}

.avatar-wrapper {
	position: relative;
}

.avatar-large {
	width: 104px;
	height: 104px;
	border-radius: 24px;
	background: linear-gradient(135deg, #3b82f6 0%, #4f46e5 100%);
	color: white;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 42px;
	font-weight: 800;
	box-shadow: 0 12px 24px -4px rgba(79, 70, 229, 0.4), 0 0 0 4px #ffffff;
}

.active-dot {
	position: absolute;
	bottom: -2px;
	right: -2px;
	width: 18px;
	height: 18px;
	background: #10b981;
	border: 3px solid #ffffff;
	border-radius: 50%;
}

.hero-meta h1 {
	font-size: 26px;
	font-weight: 800;
	color: #0f172a;
	margin-bottom: 4px;
	letter-spacing: -0.5px;
}

.hero-sub {
	display: flex;
	align-items: center;
	gap: 12px;
	flex-wrap: wrap;
}

.role-badge {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 5px 14px;
	border-radius: 30px;
	background: #e0e7ff;
	color: #4338ca;
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.dept-tag {
	font-size: 13px;
	color: #64748b;
	font-weight: 600;
	display: flex;
	align-items: center;
	gap: 6px;
}

.hero-actions {
	display: flex;
	align-items: center;
	gap: 10px;
}

.btn-hero {
	padding: 10px 20px;
	border-radius: 12px;
	font-size: 13.5px;
	font-weight: 700;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	transition: all 0.2s ease;
	cursor: pointer;
	border: none;
}

.btn-primary-hero {
	background: #4f46e5;
	color: #ffffff;
	box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
}
.btn-primary-hero:hover {
	background: #4338ca;
	transform: translateY(-2px);
}

.btn-secondary-hero {
	background: #ffffff;
	color: #475569;
	border: 1px solid #cbd5e1;
}
.btn-secondary-hero:hover {
	background: #f8fafc;
	color: #0f172a;
}

/* Tabs Header */
.profile-tabs {
	display: flex;
	gap: 8px;
	border-bottom: 2px solid #e2e8f0;
	margin-bottom: 28px;
}

.tab-btn {
	background: none;
	border: none;
	padding: 12px 20px;
	font-size: 14px;
	font-weight: 700;
	color: #64748b;
	cursor: pointer;
	position: relative;
	transition: color 0.2s;
	display: flex;
	align-items: center;
	gap: 8px;
}

.tab-btn:hover {
	color: #0f172a;
}

.tab-btn.active {
	color: #4f46e5;
}

.tab-btn.active::after {
	content: '';
	position: absolute;
	bottom: -2px;
	left: 0;
	width: 100%;
	height: 3px;
	background: #4f46e5;
	border-radius: 3px 3px 0 0;
}

/* Tab Panels */
.tab-panel {
	display: none;
	animation: tabFadeIn 0.25s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
.tab-panel.active {
	display: block;
}

@keyframes tabFadeIn {
	from { opacity: 0; transform: translateY(8px); }
	to { opacity: 1; transform: translateY(0); }
}

/* Grid Cards */
.grid-2 {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
	gap: 20px;
}

.info-card {
	background: #ffffff;
	border-radius: 16px;
	padding: 22px 24px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03), 0 0 0 1px rgba(226, 232, 240, 0.8);
	transition: all 0.2s ease;
	display: flex;
	align-items: flex-start;
	justify-content: space-between;
}
.info-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.08), 0 0 0 1px rgba(99, 102, 241, 0.3);
}

.info-icon {
	width: 44px;
	height: 44px;
	border-radius: 12px;
	background: #eef2ff;
	color: #4f46e5;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 18px;
	flex-shrink: 0;
}

.info-details {
	flex: 1;
	margin-left: 16px;
}

.info-label {
	font-size: 11.5px;
	font-weight: 800;
	text-transform: uppercase;
	color: #64748b;
	letter-spacing: 0.5px;
	margin-bottom: 4px;
}

.info-val {
	font-size: 16px;
	font-weight: 700;
	color: #0f172a;
	word-break: break-all;
}

.btn-copy {
	background: none;
	border: none;
	color: #94a3b8;
	cursor: pointer;
	padding: 6px;
	border-radius: 6px;
	transition: color 0.15s;
}
.btn-copy:hover {
	color: #4f46e5;
}

/* Shortcut Banner Cards */
.shortcuts-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
	gap: 18px;
}

.shortcut-card {
	background: #ffffff;
	border-radius: 16px;
	padding: 20px;
	border: 1px solid #e2e8f0;
	text-decoration: none;
	color: #0f172a;
	display: flex;
	align-items: center;
	gap: 14px;
	transition: all 0.2s ease;
}
.shortcut-card:hover {
	transform: translateY(-3px);
	border-color: #818cf8;
	box-shadow: 0 10px 20px -5px rgba(79, 70, 229, 0.12);
}

.shortcut-icon {
	width: 42px;
	height: 42px;
	border-radius: 12px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 18px;
	color: white;
}

.sc-purple { background: linear-gradient(135deg, #6366f1, #8b5cf6); }
.sc-emerald { background: linear-gradient(135deg, #10b981, #059669); }
.sc-amber { background: linear-gradient(135deg, #f59e0b, #d97706); }
.sc-sky { background: linear-gradient(135deg, #0284c7, #2563eb); }

.shortcut-title {
	font-size: 14px;
	font-weight: 700;
}
.shortcut-desc {
	font-size: 12px;
	color: #64748b;
}

/* Toast Notice */
.toast-notice {
	position: fixed;
	bottom: 24px;
	right: 24px;
	background: #0f172a;
	color: #ffffff;
	padding: 12px 20px;
	border-radius: 12px;
	font-size: 13px;
	font-weight: 700;
	box-shadow: 0 10px 30px rgba(0,0,0,0.25);
	display: none;
	align-items: center;
	gap: 8px;
	z-index: 10000;
	animation: toastSlideUp 0.2s ease-out forwards;
}

@keyframes toastSlideUp {
	from { opacity: 0; transform: translateY(20px); }
	to { opacity: 1; transform: translateY(0); }
}
</style>
</head>
<body>

	<!-- Main Content Area -->
	<div class="main">
		<!-- Topbar -->
		<div class="topbar">
			<div style="display: flex; align-items: center; gap: 16px;">
				<h2>My Profile</h2>
			</div>
			<div class="right-icons">
				<%@ include file="/WEB-INF/jspf/notificationBar.jspf" %>
				<a href="profile.jsp" class="profile-avatar-pill" title="View Profile" style="display:inline-flex; align-items:center; gap:10px; padding:4px 14px 4px 5px; background:#f1f5f9; border-radius:30px; text-decoration:none; color:#0f172a; font-weight:700; font-size:13px; border:1px solid #cbd5e1;">
					<div style="position:relative; width:34px; height:34px; min-width:34px; max-width:34px; min-height:34px; max-height:34px; display:flex; border-radius:50%;">
						<img src="<%=profilePhoto%>" alt="Photo" style="width:34px; height:34px; min-width:34px; max-width:34px; min-height:34px; max-height:34px; border-radius:50%; object-fit:cover; display:block;" />
					</div>
					<span><%=empName%></span>
				</a>
			</div>
		</div>

		<!-- Content Container -->
		<div class="content">

			<% if (isUpdated) { %>
			<div style="background: #dcfce7; border: 1px solid #86efac; color: #166534; padding: 14px 20px; border-radius: 14px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; font-weight: 700; font-size: 14px;">
				<i class="fa-solid fa-circle-check" style="font-size: 18px;"></i> Profile & Photo updated successfully!
			</div>
			<% } else if (isError) { %>
			<div style="background: #fee2e2; border: 1px solid #fca5a5; color: #991b1b; padding: 14px 20px; border-radius: 14px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; font-weight: 700; font-size: 14px;">
				<i class="fa-solid fa-circle-exclamation" style="font-size: 18px;"></i> Failed to update profile. Please try again.
			</div>
			<% } %>

			<!-- Hero Card -->
			<div class="profile-hero-card">
				<div class="profile-cover"></div>
				<div class="profile-hero-body">
					<div class="profile-main-info">
						<div class="avatar-wrapper" style="cursor: pointer;" onclick="openModal()" title="Click to Change Photo">
							<img src="<%=profilePhoto%>" id="heroAvatarImg" style="width:104px; height:104px; border-radius:24px; object-fit:cover; box-shadow:0 12px 24px -4px rgba(79, 70, 229, 0.4), 0 0 0 4px #ffffff;" alt="Profile Photo" />
							<div style="position: absolute; bottom: 4px; right: 4px; background: #4f46e5; color: white; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid #fff; font-size: 12px;">
								<i class="fa-solid fa-camera"></i>
							</div>
						</div>
						<div class="hero-meta">
							<h1><%=empName%></h1>
							<div class="hero-sub">
								<span class="role-badge">
									<i class="fa-solid fa-shield-halved"></i> <%=role.toUpperCase()%> ACCOUNT
								</span>
								<span class="dept-tag">
									<i class="fa-solid fa-building"></i> <%=empDept%> Department
								</span>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- Interactive Tabs -->
			<div class="profile-tabs">
				<button type="button" class="tab-btn active" onclick="switchTab(event, 'detailsTab')">
					<i class="fa-solid fa-id-card"></i> Personal Details
				</button>
				<button type="button" class="tab-btn" onclick="switchTab(event, 'actionsTab')">
					<i class="fa-solid fa-bolt"></i> Quick Actions
				</button>
				<button type="button" class="tab-btn" onclick="switchTab(event, 'securityTab')">
					<i class="fa-solid fa-lock"></i> Security & Role
				</button>
			</div>

			<!-- Tab 1: Personal Details -->
			<div id="detailsTab" class="tab-panel active">
				<div class="grid-2">
					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-fingerprint"></i></div>
						<div class="info-details">
							<div class="info-label">Employee ID</div>
							<div class="info-val">#<%=empId > 0 ? empId : "EMP-01"%></div>
						</div>
						<button type="button" class="btn-copy" onclick="copyText('#<%=empId > 0 ? empId : "EMP-01"%>')" title="Copy Employee ID">
							<i class="fa-regular fa-copy"></i>
						</button>
					</div>

					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-user"></i></div>
						<div class="info-details">
							<div class="info-label">Full Name</div>
							<div class="info-val"><%=empName%></div>
						</div>
					</div>

					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-envelope"></i></div>
						<div class="info-details">
							<div class="info-label">Email Address</div>
							<div class="info-val"><%=empEmail%></div>
						</div>
						<button type="button" class="btn-copy" onclick="copyText('<%=empEmail%>')" title="Copy Email">
							<i class="fa-regular fa-copy"></i>
						</button>
					</div>

					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-phone"></i></div>
						<div class="info-details">
							<div class="info-label">Phone Number</div>
							<div class="info-val"><%=empPhone%></div>
						</div>
					</div>

					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-building"></i></div>
						<div class="info-details">
							<div class="info-label">Department</div>
							<div class="info-val"><%=empDept%></div>
						</div>
					</div>

					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-briefcase"></i></div>
						<div class="info-details">
							<div class="info-label">Designation</div>
							<div class="info-val"><%=empDesig%></div>
						</div>
					</div>
				</div>
			</div>

			<!-- Tab 2: Quick Actions -->
			<div id="actionsTab" class="tab-panel">
				<div class="shortcuts-grid">
					<a href="<%=dashboardUrl%>" class="shortcut-card">
						<div class="shortcut-icon sc-purple"><i class="fa-solid fa-gauge-high"></i></div>
						<div>
							<div class="shortcut-title">Main Dashboard</div>
							<div class="shortcut-desc">Return to operational hub</div>
						</div>
					</a>

					<a href="attendance.jsp" class="shortcut-card">
						<div class="shortcut-icon sc-emerald"><i class="fa-solid fa-calendar-check"></i></div>
						<div>
							<div class="shortcut-title">Mark Attendance</div>
							<div class="shortcut-desc">Check in or log daily hours</div>
						</div>
					</a>

					<a href="applyLeave.jsp" class="shortcut-card">
						<div class="shortcut-icon sc-amber"><i class="fa-solid fa-file-circle-plus"></i></div>
						<div>
							<div class="shortcut-title">Apply Leave</div>
							<div class="shortcut-desc">Submit new leave request</div>
						</div>
					</a>

					<a href="viewMeetings" class="shortcut-card">
						<div class="shortcut-icon sc-sky"><i class="fa-solid fa-video"></i></div>
						<div>
							<div class="shortcut-title">My Meetings</div>
							<div class="shortcut-desc">View scheduled sessions</div>
						</div>
					</a>
				</div>
			</div>

			<!-- Tab 3: Security & Role -->
			<div id="securityTab" class="tab-panel">
				<div class="grid-2">
					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-user-shield"></i></div>
						<div class="info-details">
							<div class="info-label">Current Role</div>
							<div class="info-val" style="text-transform: capitalize;"><%=role%></div>
						</div>
					</div>

					<div class="info-card">
						<div class="info-icon"><i class="fa-solid fa-key"></i></div>
						<div class="info-details">
							<div class="info-label">Account Security</div>
							<div class="info-val" style="font-size:14px; color:#10b981;"><i class="fa-solid fa-circle-check"></i> Active & Protected</div>
						</div>
						<a href="forgotPassword.jsp" class="btn-hero btn-secondary-hero" style="font-size:12px; padding:6px 12px;">Reset Password</a>
					</div>
				</div>
			</div>

			<!-- Downside Dashboard Navigation -->
			<div style="margin-top: 36px; padding-top: 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: center; align-items: center;">
				<a href="<%=dashboardUrl%>" style="display: inline-flex; align-items: center; gap: 10px; padding: 14px 32px; background: linear-gradient(135deg, #4f46e5, #4338ca); color: #ffffff; text-decoration: none; font-weight: 800; font-size: 15px; border-radius: 16px; box-shadow: 0 4px 14px rgba(79, 70, 229, 0.3); transition: all 0.2s ease;">
					<i class="fa-solid fa-house"></i> Back to Dashboard
				</a>
			</div>
		</div>
	</div>

	<!-- Edit Profile & Photo Modal -->
	<div id="editProfileModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 9999; justify-content: center; align-items: center; padding: 20px;">
		<div style="background: #ffffff; width: 100%; max-width: 540px; border-radius: 24px; box-shadow: 0 20px 40px rgba(0,0,0,0.2); overflow: hidden; animation: modalPop 0.25s ease-out forwards;">
			<div style="padding: 24px 28px; background: linear-gradient(135deg, #4f46e5, #7c3aed); color: white; display: flex; justify-content: space-between; align-items: center;">
				<h3 style="font-size: 18px; font-weight: 800; display: flex; align-items: center; gap: 10px;">
					<i class="fa-solid fa-user-pen"></i> Edit Profile & Photo
				</h3>
				<button type="button" onclick="closeModal()" style="background: none; border: none; color: white; font-size: 20px; cursor: pointer;">
					<i class="fa-solid fa-xmark"></i>
				</button>
			</div>

			<form action="updateProfile" method="POST" enctype="multipart/form-data" style="padding: 28px;">
				<!-- Photo Upload -->
				<div style="margin-bottom: 20px; text-align: center;">
					<div style="position: relative; display: inline-block; margin-bottom: 12px;">
						<img src="<%=profilePhoto%>" id="modalPhotoPreview" style="width: 84px; height: 84px; border-radius: 20px; object-fit: cover; border: 3px solid #e0e7ff; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.2);" alt="Preview" />
					</div>
					<div style="font-size: 13px; font-weight: 700; color: #475569; margin-bottom: 8px;">Upload Profile Photo</div>
					<input type="file" name="profile_photo_file" accept="image/*" onchange="previewFile(this)" style="font-size: 13px; width: 100%; padding: 10px 14px; border: 1px dashed #cbd5e1; border-radius: 12px; background: #f8fafc; margin-bottom: 8px;" />
					<% if (!rawPhoto.isBlank()) { %>
					<button type="submit" name="remove_photo" value="true" onclick="return confirm('Are you sure you want to remove your profile photo?');" style="background: #fee2e2; color: #dc2626; border: 1px solid #fca5a5; border-radius: 10px; padding: 6px 14px; font-size: 12px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;">
						<i class="fa-solid fa-trash-can"></i> Remove Current Photo
					</button>
					<% } %>
				</div>

				<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px; margin-bottom: 14px;">
					<div>
						<label style="display: block; font-size: 12px; font-weight: 800; text-transform: uppercase; color: #64748b; margin-bottom: 4px;">Full Name</label>
						<input type="text" name="employee_name" value="<%=empName%>" required style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid #cbd5e1; font-size: 14px; font-weight: 600;" />
					</div>
					<div>
						<label style="display: block; font-size: 12px; font-weight: 800; text-transform: uppercase; color: #64748b; margin-bottom: 4px;">Phone Number</label>
						<input type="text" name="phone" value="<%=empPhone%>" placeholder="e.g. 9876543210" style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid #cbd5e1; font-size: 14px; font-weight: 600;" />
					</div>
				</div>

				<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px; margin-bottom: 24px;">
					<div>
						<label style="display: block; font-size: 12px; font-weight: 800; text-transform: uppercase; color: #64748b; margin-bottom: 4px;">Department</label>
						<input type="text" name="department" value="<%=empDept%>" placeholder="Engineering, HR, Sales..." style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid #cbd5e1; font-size: 14px; font-weight: 600;" />
					</div>
					<div>
						<label style="display: block; font-size: 12px; font-weight: 800; text-transform: uppercase; color: #64748b; margin-bottom: 4px;">Designation</label>
						<input type="text" name="designation" value="<%=empDesig%>" placeholder="Software Engineer, Manager..." style="width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid #cbd5e1; font-size: 14px; font-weight: 600;" />
					</div>
				</div>

				<div style="display: flex; justify-content: flex-end; gap: 12px;">
					<button type="button" onclick="closeModal()" style="padding: 10px 20px; border-radius: 12px; font-size: 13.5px; font-weight: 700; background: #f1f5f9; color: #475569; border: none; cursor: pointer;">
						Cancel
					</button>
					<button type="submit" style="padding: 10px 24px; border-radius: 12px; font-size: 13.5px; font-weight: 700; background: #4f46e5; color: white; border: none; cursor: pointer; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);">
						<i class="fa-solid fa-floppy-disk"></i> Save Profile
					</button>
				</div>
			</form>
		</div>
	</div>

	<!-- Copy Notification Toast -->
	<div class="toast-notice" id="copyToast">
		<i class="fa-solid fa-circle-check" style="color: #10b981;"></i>
		<span id="toastMsg">Copied to clipboard!</span>
	</div>

<script>
function openModal() {
	var modal = document.getElementById("editProfileModal");
	if (modal) modal.style.display = "flex";
}

function closeModal() {
	var modal = document.getElementById("editProfileModal");
	if (modal) modal.style.display = "none";
}

function previewFile(input) {
	if (input.files && input.files[0]) {
		var reader = new FileReader();
		reader.onload = function(e) {
			var preview = document.getElementById("modalPhotoPreview");
			if (preview) preview.src = e.target.result;
		};
		reader.readAsDataURL(input.files[0]);
	}
}

function switchTab(evt, tabId) {
	var tabs = document.querySelectorAll(".tab-btn");
	var panels = document.querySelectorAll(".tab-panel");

	tabs.forEach(function(t) { t.classList.remove("active"); });
	panels.forEach(function(p) { p.classList.remove("active"); });

	evt.currentTarget.classList.add("active");
	var target = document.getElementById(tabId);
	if (target) {
		target.classList.add("active");
	}
}

function copyText(str) {
	if (!str) return;
	navigator.clipboard.writeText(str).then(function() {
		showToast("Copied: " + str);
	}).catch(function() {
		var input = document.createElement("input");
		input.value = str;
		document.body.appendChild(input);
		input.select();
		document.execCommand("copy");
		document.body.removeChild(input);
		showToast("Copied: " + str);
	});
}

function showToast(msg) {
	var toast = document.getElementById("copyToast");
	var toastMsg = document.getElementById("toastMsg");
	if (toast && toastMsg) {
		toastMsg.innerText = msg;
		toast.style.display = "flex";
		setTimeout(function() {
			toast.style.display = "none";
		}, 2500);
	}
}
</script>

</body>
</html>
