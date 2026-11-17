package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.Task;

public interface TaskDao {

	boolean createTask(Task task);

	boolean updateTask(Task task);

	boolean deleteTask(String taskId);

	Task getTaskById(String taskId);

	List<Task> getAllTasks();

	List<Task> getTasksByEmployee(int employeeId);

	List<Task> getTasksByStatus(String status);

	List<Task> getTasksByPriority(String priority);

	boolean updateTaskStatus(String taskId, String status);

	boolean assignTask(String taskId, int employeeId);

	int totalTasks();

	int completedTasks();

	int pendingTasks();

	int inProgressTasks();

	int overdueTasks();

	boolean deleteTask(int taskId);

	Task getTaskById(int taskId);

	boolean assignTask(int taskId, int employeeId);

	boolean updateTaskStatus(int taskId, String status);

	int getTotalTaskCount();

	int getTaskCountByStatus(String status);

	int getOverdueTaskCount();

	List<Task> searchTasks(String taskId, String employeeId, String status, String priority);
}