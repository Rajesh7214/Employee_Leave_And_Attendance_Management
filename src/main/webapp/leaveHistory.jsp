<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*"%>
<%@ page import="java.util.*"%>
<%@ page import="com.rajesh.elams.model.Leave"%>

<%
if (session == null || session.getAttribute("loggedUser") == null) {
	response.sendRedirect(request.getContextPath() + "/login.jsp");
	return;
}

String role = (String) session.getAttribute("role");
String backDashUrl = "admin".equalsIgnoreCase(role)
		? "adminDashboardServlet"
		: "hr".equalsIgnoreCase(role) ? "hrDashboard"
		: "manager".equalsIgnoreCase(role) ? "managerDashboard" : "employeeDashboardServlet";

List<Leave> leaves = (List<Leave>) request.getAttribute("leaves");

int totalLeaves = 0;
int pendingLeaves = 0;
int approvedLeaves = 0;
int rejectedLeaves = 0;

if (leaves != null) {
	totalLeaves = leaves.size();
	for (Leave leave : leaves) {
		String st = leave.getStatus() != null ? leave.getStatus() : "";
		if ("Pending".equalsIgnoreCase(st)) {
	pendingLeaves++;
		} else if ("Approved".equalsIgnoreCase(st)) {
	approvedLeaves++;
		} else if ("Rejected".equalsIgnoreCase(st) || "Cancelled".equalsIgnoreCase(st)) {
	rejectedLeaves++;
		}
	}
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Leave History &amp; Status Logs | ELAMS Enterprise</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
<link
	href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
	rel="stylesheet" />

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

/* Layout Wrapper */
.layout-wrapper {
	max-width: 1240px;
	margin: 0 auto;
	padding: 35px 24px;
}

.page-header {
	display: flex;
	align-items: center;
	justify-content: space-between;
	margin-bottom: 25px;
	flex-wrap: wrap;
	gap: 16px;
}

.page-header h1 {
	font-size: 28px;
	font-weight: 800;
	color: #0f172a;
}

.header-actions {
	display: flex;
	align-items: center;
	gap: 12px;
}

.btn-header {
	display: inline-flex;
	align-items: center;
	gap: 8px;
	text-decoration: none;
	padding: 10px 20px;
	border-radius: 30px;
	font-weight: 700;
	font-size: 13.5px;
	transition: all 0.25s;
	border: none;
	cursor: pointer;
}

.btn-primary {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	box-shadow: 0 4px 14px rgba(2, 132, 199, 0.3);
}

.btn-primary:hover {
	transform: translateY(-2px);
	box-shadow: 0 6px 18px rgba(2, 132, 199, 0.42);
}

.btn-outline {
	background: #ffffff;
	color: #0284c7;
	border: 1.8px solid #bae6fd;
}

.btn-outline:hover {
	background: #e0f2fe;
}

/* KPI Cards Grid */
.kpi-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 18px;
	margin-bottom: 30px;
}

.kpi-card {
	background: #ffffff;
	border-radius: 20px;
	padding: 20px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 14px rgba(0, 0, 0, 0.03);
	display: flex;
	align-items: center;
	gap: 16px;
	transition: all 0.25s;
}

.kpi-card:hover {
	transform: translateY(-3px);
	box-shadow: 0 8px 22px rgba(0, 0, 0, 0.08);
}

.kpi-icon {
	width: 48px;
	height: 48px;
	border-radius: 16px;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 20px;
	flex-shrink: 0;
}

.kpi-icon.blue {
	background: #e0f2fe;
	color: #0284c7;
}

.kpi-icon.amber {
	background: #fef3c7;
	color: #b45309;
}

.kpi-icon.green {
	background: #dcfce7;
	color: #15803d;
}

.kpi-icon.red {
	background: #fee2e2;
	color: #b91c1c;
}

.kpi-details {
	display: flex;
	flex-direction: column;
}

.kpi-value {
	font-size: 24px;
	font-weight: 800;
	color: #0f172a;
	line-height: 1.1;
}

.kpi-label {
	font-size: 12px;
	font-weight: 700;
	color: #64748b;
	text-transform: uppercase;
	margin-top: 4px;
}

/* Table Section Card */
.card-table {
	background: #ffffff;
	border-radius: 24px;
	padding: 30px;
	border: 1px solid #e2e8f0;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
}

/* Toolbar & Filters */
.toolbar {
	display: flex;
	align-items: center;
	justify-content: space-between;
	gap: 16px;
	margin-bottom: 24px;
	flex-wrap: wrap;
}

.search-box {
	position: relative;
	flex: 1;
	min-width: 260px;
}

.search-box i {
	position: absolute;
	left: 16px;
	top: 50%;
	transform: translateY(-50%);
	color: #0284c7;
	font-size: 15px;
}

.search-box input {
	width: 100%;
	padding: 12px 18px 12px 46px;
	border: 1.8px solid #cbd5e1;
	border-radius: 14px;
	font-size: 14px;
	color: #0f172a;
	outline: none;
	background: #f8fafc;
	transition: all 0.25s;
}

.search-box input:focus {
	background: #ffffff;
	border-color: #0284c7;
	box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.14);
}

.filter-pills {
	display: flex;
	gap: 8px;
	flex-wrap: wrap;
}

.filter-pill {
	padding: 8px 16px;
	border-radius: 20px;
	font-size: 12.5px;
	font-weight: 700;
	background: #f1f5f9;
	color: #475569;
	cursor: pointer;
	border: 1px solid #cbd5e1;
	transition: all 0.2s;
}

.filter-pill:hover {
	background: #e2e8f0;
	color: #0f172a;
}

.filter-pill.active {
	background: linear-gradient(135deg, #0284c7 0%, #0d9488 100%);
	color: white;
	border-color: transparent;
	box-shadow: 0 2px 8px rgba(2, 132, 199, 0.3);
}

/* High Visibility Table */
.table-responsive {
	overflow-x: auto;
}

table {
	width: 100%;
	border-collapse: collapse;
	text-align: left;
}

thead tr {
	background: #f8fafc;
	border-bottom: 2px solid #e2e8f0;
}

th {
	padding: 14px 18px;
	font-size: 12.5px;
	font-weight: 800;
	color: #475569;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

td {
	padding: 16px 18px;
	font-size: 14px;
	color: #1e293b;
	border-bottom: 1px solid #f1f5f9;
}

tbody tr {
	transition: background 0.2s;
}

tbody tr:hover {
	background: #f8fafc;
}

/* Status Badges */
.status-tag {
	display: inline-flex;
	align-items: center;
	gap: 6px;
	padding: 6px 14px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: 800;
	text-transform: uppercase;
}

.status-tag.pending {
	background: #fef3c7;
	color: #b45309;
	border: 1px solid #fde68a;
}

.status-tag.approved {
	background: #dcfce7;
	color: #15803d;
	border: 1px solid #bbf7d0;
}

.status-tag.rejected {
	background: #fee2e2;
	color: #b91c1c;
	border: 1px solid #fecaca;
}

.btn-cancel-leave {
	background: #fee2e2;
	color: #b91c1c;
	border: 1px solid #fecaca;
	padding: 6px 14px;
	border-radius: 10px;
	font-size: 12.5px;
	font-weight: 700;
	cursor: pointer;
	text-decoration: none;
	display: inline-flex;
	align-items: center;
	gap: 6px;
	transition: all 0.2s;
}

.btn-cancel-leave:hover {
	background: #ef4444;
	color: white;
}

.empty-state {
	text-align: center;
	padding: 50px 20px;
	color: #64748b;
}

.empty-state i {
	font-size: 48px;
	color: #cbd5e1;
	margin-bottom: 14px;
}

@media print {
	.navbar, .header-actions, .toolbar {
		display: none !important;
	}
	.card-table {
		border: none;
		box-shadow: none;
		padding: 0;
	}
}
</style>
</head>
<body>

	<!-- Top Navbar -->
	<div class="navbar">
		<a href="<%=backDashUrl%>" class="navbar-brand"> <i
			class="fa-solid fa-list-check"></i> <span class="navbar-title">Leave
				History &amp; Status Logs</span>
		</a>
		<div style="display: flex; align-items: center; gap: 16px;">
			<%@ include file="/WEB-INF/jspf/notificationBar.jspf"%>
		</div>
	</div>

	<!-- Main Wrapper -->
	<div class="layout-wrapper">

		<!-- Page Header -->
		<div class="page-header">
			<div>
				<h1>📋 My Leave Application History</h1>
				<p
					style="color: #64748b; font-size: 14.5px; font-weight: 600; margin-top: 4px;">
					Track the real-time status of your submitted leave requests</p>
			</div>

			<div class="header-actions">

				<a href="<%=backDashUrl%>" class="btn-header btn-outline"> <i
					class="fa-solid fa-house"></i> Back to Dashboard
				</a>
			</div>
		</div>

		<!-- Alerts -->
		<%
		String succMsg = (String) session.getAttribute("successMessage");
		String errMsg = (String) session.getAttribute("errorMessage");
		if (succMsg != null) {
			session.removeAttribute("successMessage");
		%>
		<div
			style="background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; padding: 14px 20px; border-radius: 14px; margin-bottom: 22px; font-weight: 700; display: flex; align-items: center; gap: 10px;">
			<i class="fa-solid fa-circle-check"></i>
			<%=succMsg%>
		</div>
		<%
		}
		%>

		<%
		if (errMsg != null) {
			session.removeAttribute("errorMessage");
		%>
		<div
			style="background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; padding: 14px 20px; border-radius: 14px; margin-bottom: 22px; font-weight: 700; display: flex; align-items: center; gap: 10px;">
			<i class="fa-solid fa-triangle-exclamation"></i>
			<%=errMsg%>
		</div>
		<%
		}
		%>

		<!-- KPI Stat Cards -->
		<div class="kpi-grid">
			<div class="kpi-card">
				<div class="kpi-icon blue">
					<i class="fa-solid fa-file-invoice"></i>
				</div>
				<div class="kpi-details">
					<span class="kpi-value"><%=totalLeaves%></span> <span
						class="kpi-label">Total Requests</span>
				</div>
			</div>

			<div class="kpi-card">
				<div class="kpi-icon amber">
					<i class="fa-solid fa-hourglass-half"></i>
				</div>
				<div class="kpi-details">
					<span class="kpi-value"><%=pendingLeaves%></span> <span
						class="kpi-label">Pending Review</span>
				</div>
			</div>

			<div class="kpi-card">
				<div class="kpi-icon green">
					<i class="fa-solid fa-circle-check"></i>
				</div>
				<div class="kpi-details">
					<span class="kpi-value"><%=approvedLeaves%></span> <span
						class="kpi-label">Approved</span>
				</div>
			</div>

			<div class="kpi-card">
				<div class="kpi-icon red">
					<i class="fa-solid fa-circle-xmark"></i>
				</div>
				<div class="kpi-details">
					<span class="kpi-value"><%=rejectedLeaves%></span> <span
						class="kpi-label">Rejected / Cancelled</span>
				</div>
			</div>
		</div>

		<!-- Table Card -->
		<div class="card-table">

			<!-- Toolbar & Search -->
			<div class="toolbar">
				<div class="search-box">
					<i class="fa-solid fa-magnifying-glass"></i> <input type="text"
						id="leaveSearch"
						placeholder="Search by Leave ID, Type, Date, Reason..."
						onkeyup="filterLeaveTable()" />
				</div>

				<div class="filter-pills">
					<div class="filter-pill active"
						onclick="filterByStatus('ALL', this)">
						All Requests (<%=totalLeaves%>)
					</div>
					<div class="filter-pill" onclick="filterByStatus('PENDING', this)">
						Pending (<%=pendingLeaves%>)
					</div>
					<div class="filter-pill" onclick="filterByStatus('APPROVED', this)">
						Approved (<%=approvedLeaves%>)
					</div>
					<div class="filter-pill" onclick="filterByStatus('REJECTED', this)">Rejected/Cancelled</div>
				</div>
			</div>

			<!-- Leave Table -->
			<div class="table-responsive">
				<table id="leaveTable">
					<thead>
						<tr>
							<th>Leave ID</th>
							<th>Leave Type</th>
							<th>Start Date</th>
							<th>End Date</th>
							<th>Reason</th>
							<th>Status</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
						if (leaves != null && !leaves.isEmpty()) {
							for (Leave leave : leaves) {
								String statusRaw = leave.getStatus() != null ? leave.getStatus().trim() : "Pending";
								String badgeClass = "pending";
								String icon = "fa-clock";

								if ("Approved".equalsIgnoreCase(statusRaw)) {
							badgeClass = "approved";
							icon = "fa-circle-check";
								} else if ("Rejected".equalsIgnoreCase(statusRaw) || "Cancelled".equalsIgnoreCase(statusRaw)) {
							badgeClass = "rejected";
							icon = "fa-circle-xmark";
								}
						%>
						<tr data-status="<%=statusRaw.toUpperCase()%>">
							<td><strong>#<%=leave.getLeaveId()%></strong></td>
							<td><span
								style="background: #e0f2fe; color: #0284c7; padding: 4px 12px; border-radius: 12px; font-weight: 700; font-size: 12.5px;">
									<%=leave.getLeaveType()%>
							</span></td>
							<td><strong><%=leave.getStartDate()%></strong></td>
							<td><strong><%=leave.getEndDate()%></strong></td>
							<td style="max-width: 280px;"><%=leave.getReason() != null ? leave.getReason() : "-"%></td>
							<td><span class="status-tag <%=badgeClass%>"> <i
									class="fa-solid <%=icon%>"></i> <%=statusRaw%>
							</span></td>
							<td>
								<%
								if ("Pending".equalsIgnoreCase(statusRaw)) {
								%> <a
								href="cancelLeave?leaveId=<%=leave.getLeaveId()%>&employeeId=<%=leave.getEmployeeId()%>"
								class="btn-cancel-leave"
								onclick="return confirm('Are you sure you want to cancel this leave request?');">
									<i class="fa-solid fa-xmark"></i> Cancel
							</a> <%
 } else {
 %> <span
								style="color: #94a3b8; font-size: 13px; font-weight: 600;">--</span>
								<%
								}
								%>
							</td>
						</tr>
						<%
						}
						}
						%>
					</tbody>
				</table>

				<%
				if (leaves == null || leaves.isEmpty()) {
				%>
				<div class="empty-state">
					<i class="fa-solid fa-folder-open"></i>
					<h3>No Leave Requests Found</h3>
					<p style="margin-top: 4px; font-size: 14px;">You haven't
						submitted any leave applications yet.</p>
					<a href="applyLeave.jsp" class="btn-header btn-primary"
						style="margin-top: 14px;"> <i class="fa-solid fa-paper-plane"></i>
						Apply for Leave Now
					</a>
				</div>
				<%
				}
				%>
			</div>

		</div>

	</div>

	<script>
		function filterLeaveTable() {
			var input = document.getElementById("leaveSearch").value
					.toUpperCase();
			var trs = document.querySelectorAll("#leaveTable tbody tr");
			trs.forEach(function(tr) {
				var text = tr.innerText.toUpperCase();
				tr.style.display = text.indexOf(input) > -1 ? "" : "none";
			});
		}

		function filterByStatus(status, element) {
			document.querySelectorAll(".filter-pill").forEach(function(pill) {
				pill.classList.remove("active");
			});
			element.classList.add("active");

			var trs = document.querySelectorAll("#leaveTable tbody tr");
			trs.forEach(function(tr) {
				var rowStatus = tr.getAttribute("data-status") || "";
				if (status === 'ALL') {
					tr.style.display = "";
				} else if (status === 'PENDING'
						&& rowStatus.includes('PENDING')) {
					tr.style.display = "";
				} else if (status === 'APPROVED'
						&& rowStatus.includes('APPROVED')) {
					tr.style.display = "";
				} else if (status === 'REJECTED'
						&& (rowStatus.includes('REJECTED') || rowStatus
								.includes('CANCELLED'))) {
					tr.style.display = " ";
				} else {
					tr.style.display = "none";
				}
			});
		}

		function downloadLeaveCSV() {
			let rows = [ [ "Leave ID", "Leave Type", "Start Date", "End Date",
					"Reason", "Status" ] ];
			const trs = document.querySelectorAll("#leaveTable tbody tr");
			trs.forEach(function(tr) {
				if (tr.style.display !== "none") {
					const cells = tr.querySelectorAll("td");
					if (cells.length >= 6) {
						rows.push([ cells[0].innerText.trim(),
								cells[1].innerText.trim(),
								cells[2].innerText.trim(),
								cells[3].innerText.trim(),
								cells[4].innerText.trim(),
								cells[5].innerText.trim() ]);
					}
				}
			});

			const csvContent = rows.map(function(r) {
				return r.map(function(v) {
					return '"' + String(v).replace(/"/g, '""') + '"';
				}).join(",");
			}).join("\n");

			const blob = new Blob([ csvContent ], {
				type : "text/csv;charset=utf-8;"
			});
			const url = URL.createObjectURL(blob);
			const link = document.createElement("a");
			link.href = url;
			link.setAttribute("download", "leave_history_report.csv");
			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
			URL.revokeObjectURL(url);
		}
	</script>
</body>
</html>