package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.Priority;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.model.TaskStatus;
import com.rajesh.elams.util.DbUtil;

public class TaskDaoImpl implements TaskDao {

	public TaskDaoImpl() {
		ensureTableExists();
	}

	private void ensureTableExists() {
		String ddl = "CREATE TABLE IF NOT EXISTS tasks ("
				+ "task_id VARCHAR(50) PRIMARY KEY, "
				+ "task_name VARCHAR(255) NOT NULL, "
				+ "description TEXT, "
				+ "employee_id INT NOT NULL, "
				+ "manager_id VARCHAR(100) NOT NULL, "
				+ "priority VARCHAR(20) DEFAULT 'MEDIUM', "
				+ "status VARCHAR(30) DEFAULT 'PENDING', "
				+ "assigned_date DATE, "
				+ "due_date DATE, "
				+ "completion_date DATE"
				+ ")";
		try (Connection conn = DbUtil.getConnection(); java.sql.Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(ddl);
			try {
				stmt.executeUpdate("ALTER TABLE tasks MODIFY manager_id VARCHAR(100) NOT NULL");
			} catch (Exception ignored) {}
		} catch (Exception ignored) {}
	}

	@Override
	public boolean createTask(Task task) {

		String sql = "INSERT INTO tasks(task_id,task_name,description,employee_id,manager_id,priority,status,assigned_date,due_date,completion_date) VALUES(?,?,?,?,?,?,?,?,?,?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, task.getTaskId());
			ps.setString(2, task.getTaskName());
			ps.setString(3, task.getDescription());
			ps.setInt(4, task.getEmployeeId());
			ps.setString(5, task.getAssignedBy());
			ps.setString(6, task.getPriority().name());
			ps.setString(7, task.getStatus().name());
			ps.setDate(8, task.getAssignedDate());
			ps.setDate(9, task.getDueDate());
			ps.setDate(10, task.getCompletionDate());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean updateTask(Task task) {

		String sql = "UPDATE tasks SET task_name=?, description=?, priority=?, due_date=? WHERE task_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, task.getTaskName());
			ps.setString(2, task.getDescription());
			ps.setString(3, task.getPriority().name());
			ps.setDate(4, task.getDueDate());
			ps.setString(5, task.getTaskId());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean deleteTask(String taskId) {

		String sql = "DELETE FROM tasks WHERE task_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, taskId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	public boolean deleteTask(int taskId) {

		return deleteTask(String.valueOf(taskId));

	}

	@Override
	public Task getTaskById(String taskId) {

		Task task = null;

		String sql = "SELECT * FROM tasks WHERE task_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, taskId);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {

				task = mapRow(rs);

			}

		} catch (Exception e) {

			e.printStackTrace();

		}

		return task;
	}

	public Task getTaskById(int taskId) {

		return getTaskById(String.valueOf(taskId));

	}

	@Override
	public List<Task> getAllTasks() {

		List<Task> taskList = new ArrayList<>();

		String sql = "SELECT * FROM tasks ORDER BY assigned_date DESC";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {

				taskList.add(mapRow(rs));

			}

		} catch (Exception e) {

			e.printStackTrace();

		}

		return taskList;
	}

	@Override
	public List<Task> getTasksByEmployee(int employeeId) {

		List<Task> taskList = new ArrayList<>();

		String sql = "SELECT * FROM tasks WHERE employee_id=? ORDER BY due_date";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, employeeId);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				taskList.add(mapRow(rs));

			}

		} catch (Exception e) {

			e.printStackTrace();

		}

		return taskList;
	}

	@Override
	public List<Task> getTasksByStatus(String status) {

		List<Task> taskList = new ArrayList<>();

		String sql = "SELECT * FROM tasks WHERE UPPER(status)=UPPER(?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, status);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				taskList.add(mapRow(rs));

			}

		} catch (Exception e) {

			e.printStackTrace();

		}

		return taskList;
	}

	@Override
	public List<Task> getTasksByPriority(String priority) {

		List<Task> taskList = new ArrayList<>();

		String sql = "SELECT * FROM tasks WHERE UPPER(priority)=UPPER(?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, priority);

			ResultSet rs = ps.executeQuery();

			while (rs.next()) {

				taskList.add(mapRow(rs));

			}

		} catch (Exception e) {

			e.printStackTrace();

		}

		return taskList;
	}

	@Override
	public boolean assignTask(String taskId, int employeeId) {

		String sql = "UPDATE tasks SET employee_id=? WHERE task_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, employeeId);
			ps.setString(2, taskId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	public boolean assignTask(int taskId, int employeeId) {

		return assignTask(String.valueOf(taskId), employeeId);

	}

	@Override
	public boolean updateTaskStatus(String taskId, String status) {

		String sql = "UPDATE tasks SET status=?, completion_date=? WHERE task_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			String upperStatus = "PENDING";
			if (status != null) {
				String s = status.trim().toUpperCase();
				if ("COMPLETED".equals(s) || "COMPLETE".equals(s) || "DONE".equals(s)) {
					upperStatus = "COMPLETED";
				} else if ("IN_PROGRESS".equals(s) || "IN PROGRESS".equals(s) || "PROGRESS".equals(s)) {
					upperStatus = "IN_PROGRESS";
				} else {
					upperStatus = "PENDING";
				}
			}

			ps.setString(1, upperStatus);

			if ("COMPLETED".equals(upperStatus)) {
				ps.setDate(2, new Date(System.currentTimeMillis()));
			} else {
				ps.setNull(2, java.sql.Types.DATE);
			}

			ps.setString(3, taskId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean updateTaskStatus(int taskId, String status) {

		return updateTaskStatus(String.valueOf(taskId), status);

	}

	@Override
	public int totalTasks() {

		String sql = "SELECT COUNT(*) FROM tasks";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int completedTasks() {

		String sql = "SELECT COUNT(*) FROM tasks WHERE UPPER(status)='COMPLETED'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int pendingTasks() {

		String sql = "SELECT COUNT(*) FROM tasks WHERE UPPER(status)='PENDING'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int inProgressTasks() {

		String sql = "SELECT COUNT(*) FROM tasks WHERE UPPER(status)='IN_PROGRESS'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int overdueTasks() {

		String sql = "SELECT COUNT(*) FROM tasks WHERE due_date < CURDATE() AND UPPER(status)<>'COMPLETED'";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int getTotalTaskCount() {
		return totalTasks();
	}

	@Override
	public int getTaskCountByStatus(String status) {

		String sql = "SELECT COUNT(*) FROM tasks WHERE UPPER(status)=UPPER(?)";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, status);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				return rs.getInt(1);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return 0;
	}

	@Override
	public int getOverdueTaskCount() {
		return overdueTasks();
	}

	@Override
	public List<Task> searchTasks(String taskId, String employeeId, String status, String priority) {
		List<Task> list = new ArrayList<>();
		StringBuilder sql = new StringBuilder("SELECT * FROM tasks WHERE 1=1");
		List<Object> params = new ArrayList<>();

		if (taskId != null && !taskId.trim().isEmpty()) {
			sql.append(" AND task_id LIKE ?");
			params.add("%" + taskId.trim() + "%");
		}
		if (employeeId != null && !employeeId.trim().isEmpty()) {
			try {
				int empId = Integer.parseInt(employeeId.trim().replaceAll("[^0-9]", ""));
				sql.append(" AND employee_id = ?");
				params.add(empId);
			} catch (Exception ignored) {}
		}
		if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status)) {
			sql.append(" AND status = ?");
			params.add(status.trim().toUpperCase());
		}
		if (priority != null && !priority.trim().isEmpty() && !"ALL".equalsIgnoreCase(priority)) {
			sql.append(" AND priority = ?");
			params.add(priority.trim().toUpperCase());
		}
		sql.append(" ORDER BY assigned_date DESC");

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++) {
				ps.setObject(i + 1, params.get(i));
			}
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapRow(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}


	private Task mapRow(ResultSet rs) throws Exception {

		Task task = new Task();

		task.setTaskId(rs.getString("task_id"));
		task.setTaskName(rs.getString("task_name"));
		task.setDescription(rs.getString("description"));
		task.setEmployeeId(rs.getInt("employee_id"));
		task.setAssignedBy(rs.getString("manager_id"));

		String priorityStr = rs.getString("priority");
		Priority priority = Priority.MEDIUM;
		if (priorityStr != null) {
			try {
				priority = Priority.valueOf(priorityStr.trim().toUpperCase());
			} catch (Exception ignored) {}
		}
		task.setPriority(priority);

		String statusStr = rs.getString("status");
		TaskStatus status = TaskStatus.PENDING;
		if (statusStr != null) {
			String cleanStatus = statusStr.trim().toUpperCase();
			if ("ASSIGNED".equals(cleanStatus) || "OPEN".equals(cleanStatus) || "INCOMPLETE".equals(cleanStatus)) {
				cleanStatus = "PENDING";
			} else if ("IN PROGRESS".equals(cleanStatus) || "IN-PROGRESS".equals(cleanStatus) || "PROGRESS".equals(cleanStatus)) {
				cleanStatus = "IN_PROGRESS";
			} else if ("COMPLETE".equals(cleanStatus) || "DONE".equals(cleanStatus)) {
				cleanStatus = "COMPLETED";
			}
			try {
				status = TaskStatus.valueOf(cleanStatus);
			} catch (Exception ignored) {}
		}
		task.setStatus(status);

		task.setAssignedDate(rs.getDate("assigned_date"));
		task.setDueDate(rs.getDate("due_date"));
		task.setCompletionDate(rs.getDate("completion_date"));

		return task;
	}

}