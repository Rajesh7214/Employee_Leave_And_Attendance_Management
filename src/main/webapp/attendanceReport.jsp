<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="com.rajesh.elams.model.Attendance"%>
<%@ page import="java.util.List"%>

<%
Boolean isEmployeeView = (Boolean) request.getAttribute("isEmployeeView");
if (isEmployeeView == null) {
	isEmployeeView = false;
}
String backUrl = (String) request.getAttribute("backUrl");
if (backUrl == null) {
	backUrl = "login.jsp";
}
List<Attendance> records = (List<Attendance>) request.getAttribute("records");
%>
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Attendance Report | ELAMS</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<style>
* {
	margin: 0;
	padding: 0;
	box-sizing: border-box;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

body {
	background: #f4f6f9;
	min-height: 100vh;
}

.navbar {
	height: 70px;
	background: linear-gradient(135deg, #ee5a8a 0%, #d6336c 100%);
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 30px;
	box-shadow: 0 4px 15px rgba(214, 51, 108, .25);
}

.navbar .logo {
	color: white;
	font-size: 22px;
	font-weight: bold;
}

.back-btn {
	text-decoration: none;
	color: #d6336c;
	background: white;
	padding: 9px 20px;
	border-radius: 30px;
	font-weight: bold;
	font-size: 14px;
	transition: .3s;
}

.back-btn:hover {
	background: #2c3e50;
	color: white;
}

.container {
	width: 92%;
	max-width: 800px;
	margin: 40px auto;
}

h2.title {
	text-align: center;
	color: #2c3e50;
	margin-bottom: 8px;
	font-size: 30px;
}

.subtitle {
	text-align: center;
	color: #888;
	margin-bottom: 30px;
	font-size: 14px;
}

.card {
	background: white;
	border-radius: 16px;
	padding: 30px;
	box-shadow: 0 8px 25px rgba(0, 0, 0, .08);
	margin-bottom: 25px;
}

.summary-row {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 18px;
	margin-bottom: 10px;
}

.summary-box {
	text-align: center;
	padding: 22px 10px;
	border-radius: 14px;
	color: white;
}

.summary-box .count {
	font-size: 32px;
	font-weight: bold;
	margin-bottom: 4px;
}

.summary-box .label {
	font-size: 13px;
	text-transform: uppercase;
	letter-spacing: .5px;
	opacity: .9;
}

.box-present {
	background: linear-gradient(135deg, #2ecc71, #27ae60);
}

.box-absent {
	background: linear-gradient(135deg, #ff6b6b, #e74c3c);
}

.box-halfday {
	background: linear-gradient(135deg, #f6b93b, #f39c12);
}

table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 10px;
}

th, td {
	padding: 12px 10px;
	text-align: center;
	border-bottom: 1px solid #eee;
	font-size: 14px;
}

th {
	background: #fdf2f6;
	color: #d6336c;
	text-transform: uppercase;
	font-size: 12px;
	letter-spacing: .5px;
}

tr:hover td {
	background: #fbf7f9;
}

.status-pill {
	display: inline-block;
	padding: 4px 12px;
	border-radius: 20px;
	font-size: 12px;
	font-weight: bold;
	color: white;
}

.pill-present {
	background: #27ae60;
}

.pill-absent {
	background: #e74c3c;
}

.pill-halfday {
	background: #f39c12;
}

.empty-state {
	text-align: center;
	color: #999;
	padding: 30px 10px;
	font-size: 14px;
}

.action-row {
	display: flex;
	justify-content: center;
	gap: 15px;
	margin-top: 20px;
	flex-wrap: wrap;
}

.btn-action {
	border: none;
	padding: 12px 24px;
	border-radius: 30px;
	font-weight: bold;
	font-size: 14px;
	cursor: pointer;
	color: white;
	display: inline-flex;
	align-items: center;
	gap: 8px;
	text-decoration: none;
	transition: .3s;
}

.btn-download {
	background: #0284c7;
	box-shadow: 0 4px 14px rgba(2, 132, 199, 0.3);
}

.btn-print {
	background: linear-gradient(135deg, #6c5ce7, #4834d4);
}

.btn-action:hover {
	transform: translateY(-3px);
	box-shadow: 0 8px 18px rgba(0, 0, 0, .2);
}

@media print {
	.navbar, .action-row, .back-btn {
		display: none !important;
	}
	body {
		background: white;
	}
	.card {
		box-shadow: none;
	}
}

@media ( max-width : 600px) {
	.summary-row {
		grid-template-columns: 1fr;
	}
	.navbar {
		padding: 0 18px;
	}
}
</style>

</head>
<body>

	<div class="navbar">
		<div class="logo">ELAMS</div>
		<a href="<%=backUrl%>" class="back-btn"> <i
			class="fa-solid fa-arrow-left"></i> Back to Dashboard
		</a>
	</div>

	<div class="container">

		<h2 class="title">Attendance Report</h2>
		<p class="subtitle">
			<%
			if (isEmployeeView) {
			%>
			Your complete attendance summary
			<%
			} else {
			%>
			Today's attendance summary across all employees
			<%
			}
			%>
		</p>

		<div class="card" id="reportCard">

			<div class="summary-row">

				<div class="summary-box box-present">
					<div class="count"><%=request.getAttribute("present")%></div>
					<div class="label">Present</div>
				</div>

				<div class="summary-box box-absent">
					<div class="count"><%=request.getAttribute("absent")%></div>
					<div class="label">Absent</div>
				</div>

				<div class="summary-box box-halfday">
					<div class="count"><%=request.getAttribute("halfDay")%></div>
					<div class="label">Half Day</div>
				</div>

			</div>

			<%
			if (isEmployeeView) {
			%>

			<table id="reportTable">
				<tr>
					<th>Date</th>
					<th>Check-in</th>
					<th>Check-out</th>
					<th>Status</th>
				</tr>

				<%
				if (records == null || records.isEmpty()) {
				%>
				<tr>
					<td colspan="4" class="empty-state">No attendance records yet.</td>
				</tr>
				<%
				} else {
				for (Attendance a : records) {
					String pillClass = "Present".equalsIgnoreCase(a.getStatus())
					? "pill-present"
					: "Absent".equalsIgnoreCase(a.getStatus()) ? "pill-absent" : "pill-halfday";
				%>
				<tr>
					<td><%=a.getAttendance_date()%></td>
					<td><%=a.getCheck_in_time() != null ? a.getCheck_in_time() : "-"%></td>
					<td><%=a.getCheck_out_time() != null ? a.getCheck_out_time() : "-"%></td>
					<td><span class="status-pill <%=pillClass%>"><%=a.getStatus()%></span></td>
				</tr>
				<%
				}
				}
				%>

			</table>

			<%
			}
			%>

		</div>

		<div class="action-row">
			<button class="btn-action btn-download" onclick="downloadCSV()">
				<i class="fa-solid fa-file-csv"></i> Download CSV Attendance Report
			</button>
			<button class="btn-action btn-print" onclick="window.print()">
				<i class="fa-solid fa-print"></i> Print / Save as PDF
			</button>
		</div>

	</div>

	<script>
		function downloadCSV() {

			let rows = [];
			rows.push([ "Status", "Count" ]);
			rows.push([ "Present", "<%=request.getAttribute("present")%>" ]);
			rows.push([ "Absent", "<%=request.getAttribute("absent")%>" ]);
			rows.push([ "Half Day", "<%=request.getAttribute("halfDay")%>
		" ]);

			const table = document.getElementById("reportTable");
			if (table) {
				rows.push([]);
				rows.push([ "Date", "Check-in", "Check-out", "Status" ]);
				const trs = table.querySelectorAll("tr");
				trs.forEach(function(tr, index) {
					if (index === 0)
						return;
					const cells = tr.querySelectorAll("td");
					if (cells.length === 4) {
						const row = [];
						cells.forEach(function(td) {
							row.push(td.innerText.trim());
						});
						rows.push(row);
					}
				});
			}

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
			link.setAttribute("download", "attendance_report.csv");
			document.body.appendChild(link);
			link.click();
			document.body.removeChild(link);
			URL.revokeObjectURL(url);
		}
	</script>

</body>
</html>
