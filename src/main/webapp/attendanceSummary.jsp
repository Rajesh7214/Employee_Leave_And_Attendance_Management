<%@ page import="com.rajesh.elams.dao.AttendanceDao"%>
<%@ page import="com.rajesh.elams.dao.AttendanceDaoImpl"%>
<%@ page import="com.rajesh.elams.model.Attendance"%>
<%@ page import="java.util.List"%>
<%@ page import="java.sql.Date"%>

<%
AttendanceDao attendanceDao = new AttendanceDaoImpl();
Date today = new Date(System.currentTimeMillis());
List<Attendance> records = attendanceDao.getAttendanceByDate(today);
%>

<!DOCTYPE html>
<html>
<head>
<title>Attendance Summary</title>
<style>
table {
	width: 100%;
	border-collapse: collapse;
	margin-top: 20px;
}

th, td {
	border: 1px solid #ccc;
	padding: 10px;
	text-align: center;
}

th {
	background: #f2f2f2;
}
</style>
</head>
<body>
	<h1>
		Attendance Summary -
		<%=today.toString()%></h1>
	<table>
		<tr>
			<th>Employee ID</th>
			<th>Date</th>
			<th>Check-in</th>
			<th>Check-out</th>
			<th>Status</th>
		</tr>
		<%
		for (Attendance a : records) {
		%>
		<tr>
			<td><%=a.getEmployee_id()%></td>
			<td><%=a.getAttendance_date()%></td>
			<td><%=(a.getCheck_in_time() != null) ? a.getCheck_in_time() : "-"%></td>
			<td><%=(a.getCheck_out_time() != null) ? a.getCheck_out_time() : "-"%></td>
			<td><%=a.getStatus()%></td>
		</tr>
		<%
		}
		%>
	</table>
</body>
</html>
