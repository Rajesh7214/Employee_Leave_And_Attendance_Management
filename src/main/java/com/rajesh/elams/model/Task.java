package com.rajesh.elams.model;

import java.sql.Date;

public class Task {
	private String task_id;
	private String task_name;
	private String description;
	private int employee_id;
	private String assigned_by;
	private Priority priority;
	private TaskStatus status;
	private Date assigned_date;
	private Date due_date;
	private Date completion_date;

	public Task() {

	}

	public Task(String task_id, String task_name, String description, int employee_id, String assigned_by,
			Priority priority, TaskStatus status, Date assigned_date, Date due_date, Date completion_date) {
		super();
		this.task_id = task_id;
		this.task_name = task_name;
		this.description = description;
		this.employee_id = employee_id;
		this.assigned_by = assigned_by;
		this.priority = priority;
		this.status = status;
		this.assigned_date = assigned_date;
		this.due_date = due_date;
		this.completion_date = completion_date;
	}

	public String getTaskId() {
		return task_id;
	}

	public void setTaskId(String task_id) {
		this.task_id = task_id;
	}

	public String getTaskName() {
		return task_name;
	}

	public void setTaskName(String task_name) {
		this.task_name = task_name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public int getEmployeeId() {
		return employee_id;
	}

	public void setEmployeeId(int employee_id) {
		this.employee_id = employee_id;
	}

	public String getAssignedBy() {
		return assigned_by;
	}

	public void setAssignedBy(String assigned_by) {
		this.assigned_by = assigned_by;
	}

	public Priority getPriority() {
		return priority;
	}

	public void setPriority(Priority priority) {
		this.priority = priority;
	}

	public TaskStatus getStatus() {
		return status;
	}

	public void setStatus(TaskStatus status) {
		this.status = status;
	}

	public Date getAssignedDate() {
		return assigned_date;
	}

	public void setAssignedDate(Date assigned_date) {
		this.assigned_date = assigned_date;
	}

	public Date getDueDate() {
		return due_date;
	}

	public void setDueDate(Date due_date) {
		this.due_date = due_date;
	}

	public Date getCompletionDate() {
		return completion_date;
	}

	public void setCompletionDate(Date completion_date) {
		this.completion_date = completion_date;
	}

	@Override
	public String toString() {
		return "Task [task_id=" + task_id + ", task_name=" + task_name + ", description=" + description
				+ ", employee_id=" + employee_id + ", assigned_by=" + assigned_by + ", priority=" + priority
				+ ", status=" + status + ", assigned_date=" + assigned_date + ", due_date=" + due_date
				+ ", completion_date=" + completion_date + "]";
	}

}
