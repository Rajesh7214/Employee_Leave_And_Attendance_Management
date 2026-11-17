package com.rajesh.elams.service;

import java.util.List;

import com.rajesh.elams.dao.TaskDao;
import com.rajesh.elams.dao.TaskDaoImpl;
import com.rajesh.elams.model.Priority;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.model.TaskStatus;
import com.rajesh.elams.util.ValidationUtil;

public class TaskService {

	private final TaskDao taskDao;

	public TaskService() {
		this.taskDao = new TaskDaoImpl();
	}

	public boolean createTask(Task task) {
		if (task == null || !ValidationUtil.isNotEmpty(task.getTaskName())) {
			return false;
		}
		if (task.getPriority() == null) {
			task.setPriority(Priority.MEDIUM);
		}
		if (task.getStatus() == null) {
			task.setStatus(TaskStatus.PENDING);
		}
		return taskDao.createTask(task);
	}

	public List<Task> getAllTasks() {
		return taskDao.getAllTasks();
	}

	public Task getTaskById(String taskId) {
		if (!ValidationUtil.isNotEmpty(taskId)) return null;
		return taskDao.getTaskById(taskId);
	}

	public List<Task> searchTasks(String taskId, Integer empId, String status, String priority) {
		String empIdStr = empId != null ? String.valueOf(empId) : null;
		return taskDao.searchTasks(taskId, empIdStr, status, priority);
	}

	public boolean assignTask(String taskId, int employeeId) {
		if (!ValidationUtil.isNotEmpty(taskId) || employeeId <= 0) return false;
		return taskDao.assignTask(taskId, employeeId);
	}

	public boolean updateTaskStatus(String taskId, String status) {
		if (!ValidationUtil.isNotEmpty(taskId) || !ValidationUtil.isNotEmpty(status)) return false;
		return taskDao.updateTaskStatus(taskId, status);
	}

	public boolean deleteTask(String taskId) {
		if (!ValidationUtil.isNotEmpty(taskId)) return false;
		return taskDao.deleteTask(taskId);
	}
}
