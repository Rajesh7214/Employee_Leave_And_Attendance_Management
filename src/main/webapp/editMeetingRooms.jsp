<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="com.rajesh.elams.model.MeetingRoom"%>

<%
MeetingRoom room = (MeetingRoom) request.getAttribute("room");
String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Meeting Rooms | ELAMS</title>

<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">

<style>
body {
	font-family: Arial, Helvetica, sans-serif;
	background: #f4f6f9;
	margin: 0;
	padding: 0;
}

.container {
	width: 90%;
	max-width: 520px;
	margin: 50px auto;
}

h2 {
	text-align: center;
	color: #d6336c;
	margin-bottom: 25px;
}

.card {
	background: white;
	border-radius: 10px;
	padding: 25px;
	box-shadow: 0 0 12px rgba(0, 0, 0, .08);
}

.field {
	display: flex;
	flex-direction: column;
	font-size: 13px;
	color: #555;
	margin-bottom: 16px;
}

.field input, .field select {
	margin-top: 6px;
	padding: 9px;
	border: 1px solid #ccc;
	border-radius: 6px;
}

.btn {
	background: #d6336c;
	color: white;
	border: none;
	padding: 10px 18px;
	border-radius: 6px;
	font-weight: bold;
	cursor: pointer;
	text-decoration: none;
	display: inline-block;
}

.btn:hover {
	background: #b81f57;
}

.btn-outline {
	background: white;
	color: #555;
	border: 1px solid #ccc;
	margin-left: 10px;
}

.error-box {
	background: #ffe3e3;
	color: #c92a2a;
	padding: 12px 16px;
	border-radius: 8px;
	margin-bottom: 18px;
}
</style>

</head>
<body>

	<div class="container">

		<h2>
			<i class="fa-solid fa-pen"></i> Edit Meeting Room
		</h2>

		<div class="card">

			<%
			if (errorMessage != null) {
			%>
			<div class="error-box">
				<i class="fa-solid fa-triangle-exclamation"></i>
				<%=errorMessage%></div>
			<%
			}
			%>

			<%
			if (room != null) {
			%>
			<form action="editMeetingRoom" method="post">
				<input type="hidden" name="roomId" value="<%=room.getRoomId()%>">

				<div class="field">
					Room Name <input type="text" name="roomName"
						value="<%=room.getRoomName()%>" required>
				</div>

				<div class="field">
					Location <input type="text" name="location"
						value="<%=room.getLocation() == null ? "" : room.getLocation()%>">
				</div>

				<div class="field">
					Capacity <input type="number" name="capacity" min="1"
						value="<%=room.getCapacity() == null ? "" : room.getCapacity()%>">
				</div>

				<div class="field">
					Status <select name="status">
						<option value="ACTIVE"
							<%="ACTIVE".equalsIgnoreCase(room.getStatus()) ? "selected" : ""%>>Active</option>
						<option value="INACTIVE"
							<%="INACTIVE".equalsIgnoreCase(room.getStatus()) ? "selected" : ""%>>Inactive</option>
					</select>
				</div>

				<button type="submit" class="btn">
					<i class="fa-solid fa-floppy-disk"></i> Save Changes
				</button>
				<a href="manageMeetingRooms" class="btn btn-outline">Cancel</a>
			</form>
			<%
			}
			%>

		</div>

	</div>

</body>
</html>
