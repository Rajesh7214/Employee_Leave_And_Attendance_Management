package com.rajesh.elams.service;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.rajesh.elams.dao.EmployeeDao;
import com.rajesh.elams.dao.EmployeeDaoImpl;
import com.rajesh.elams.dao.NotificationDao;
import com.rajesh.elams.dao.NotificationDaoImpl;
import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.Notification;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.util.EmailService;
import com.rajesh.elams.util.SmsService;

/**
 * Notification Service Layer for RChips Solutions - Office Automation & Workforce Management System (v1.0).
 * Serves as the central business logic layer between controllers/servlets and database layer.
 */
public class NotificationService {

	private final NotificationDao notificationDao;
	private final EmployeeDao employeeDao;
	private static final ExecutorService asyncExecutor = Executors.newFixedThreadPool(5);

	public NotificationService() {
		this.notificationDao = new NotificationDaoImpl();
		this.employeeDao = new EmployeeDaoImpl();
	}

	public NotificationService(NotificationDao notificationDao, EmployeeDao employeeDao) {
		this.notificationDao = notificationDao;
		this.employeeDao = employeeDao;
	}

	/**
	 * Create and validate a notification, then persist and dispatch multi-channel alerts asynchronously.
	 */
	public boolean createNotification(Notification notification) {
		if (notification == null) return false;
		if (notification.getTitle() == null || notification.getTitle().isBlank()) return false;
		if (notification.getMessage() == null || notification.getMessage().isBlank()) return false;

		if (notification.getCategory() == null || notification.getCategory().isBlank()) {
			notification.setCategory(Notification.CAT_ANNOUNCEMENT);
		}
		if (notification.getPriority() == null || notification.getPriority().isBlank()) {
			notification.setPriority(Notification.PRIORITY_MEDIUM);
		}
		if (notification.getStatus() == null || notification.getStatus().isBlank()) {
			notification.setStatus(Notification.STATUS_UNREAD);
		}

		boolean success = notificationDao.createNotification(notification);

		if (success) {
			dispatchAsyncChannels(notification);
		}

		return success;
	}

	public List<Notification> getNotificationsByUser(long receiverId) {
		if (receiverId <= 0) return List.of();
		return notificationDao.getNotificationsByUser(receiverId);
	}

	public List<Notification> getUnreadNotifications(long receiverId) {
		if (receiverId <= 0) return List.of();
		return notificationDao.getUnreadNotifications(receiverId);
	}

	public int getUnreadCount(long receiverId) {
		if (receiverId <= 0) return 0;
		return notificationDao.getUnreadCount(receiverId);
	}

	public boolean markAsRead(long notificationId) {
		if (notificationId <= 0) return false;
		return notificationDao.markAsRead(notificationId);
	}

	public boolean archiveNotification(long notificationId) {
		if (notificationId <= 0) return false;
		return notificationDao.archiveNotification(notificationId);
	}

	public boolean deleteNotification(long notificationId) {
		if (notificationId <= 0) return false;
		return notificationDao.deleteNotification(notificationId);
	}

	public boolean deleteAllNotifications(long receiverId) {
		if (receiverId <= 0) return false;
		return notificationDao.deleteAllNotifications(receiverId);
	}

	public List<Notification> searchAndFilter(long receiverId, String category, String priority, String status, String keyword) {
		return notificationDao.getNotificationsFiltered(receiverId, category, priority, status, keyword);
	}

	// =========================================================================
	// SECTION 10: AUTOMATED NOTIFICATION SCENARIOS
	// =========================================================================

	/** 10.1 Task Assignment */
	public boolean notifyTaskAssignment(long senderId, String senderName, long recipientId, String taskTitle, String dueDateStr) {
		String title = "New Task Assigned";
		String message = "Task:\n" + taskTitle + "\n\nAssigned By:\n" + senderName + "\n\nDue Date:\n" + dueDateStr;
		Notification n = new Notification(senderId, recipientId, title, message, Notification.CAT_TASK, Notification.PRIORITY_HIGH);
		n.setSenderName(senderName);
		return createNotification(n);
	}

	public boolean notifyTaskAssignment(Task task, int senderId, String senderName, Employee emp) {
		if (task == null || emp == null) return false;

		String priorityStr = task.getPriority() != null ? task.getPriority().name() : Notification.PRIORITY_HIGH;
		String title = "📋 New Task Assigned: " + task.getTaskName();
		String messageText = "Hi " + emp.getEmployee_name() + ", a new task \"" + task.getTaskName() 
				+ "\" (Priority: " + priorityStr + ", Due: " + task.getDueDate() + ") was assigned to you by " + senderName + ".";

		Notification n = new Notification(senderId, senderName, "EMPLOYEE", emp.getEmployee_id(), title, messageText, priorityStr);
		n.setCategory(Notification.CAT_TASK);
		boolean success = notificationDao.createNotification(n);

		if (success) {
			asyncExecutor.submit(() -> {
				try {
					if (emp.getEmail() != null && !emp.getEmail().isBlank()) {
						String emailSubject = "📋 New Task Assignment: " + task.getTaskName();
						String emailBody = buildHtmlEmailCard(
								"📋 New Task Assigned",
								"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>You have been assigned a new task by <b>" + senderName + "</b>.",
								new String[][]{
										{"Task ID", task.getTaskId() != null ? task.getTaskId() : "TSK-GEN"},
										{"Task Name", task.getTaskName()},
										{"Priority", priorityStr},
										{"Due Date", String.valueOf(task.getDueDate())},
										{"Assigned By", senderName},
										{"Description", task.getDescription() != null ? task.getDescription() : "No additional description provided."}
								}
						);
						EmailService.sendEmail(emp.getEmail(), emailSubject, emailBody);
					}
					if (emp.getPhone() > 0) {
						String smsMsg = "SmartOffice Alert: New Task \"" + task.getTaskName() + "\" (Priority: " 
								+ priorityStr + ", Due: " + task.getDueDate() + ") assigned by " + senderName + ". Check portal.";
						if (smsMsg.length() > 155) smsMsg = smsMsg.substring(0, 152) + "...";
						SmsService.sendSms(String.valueOf(emp.getPhone()), smsMsg);
					}
				} catch (Exception e) {
					System.err.println("[NotificationService] Error sending task assignment email/SMS: " + e.getMessage());
				}
			});
		}
		return success;
	}

	public boolean notifyTaskUpdated(Task task, int senderId, String senderName, Employee emp) {
		if (task == null || emp == null) return false;

		String priorityStr = task.getPriority() != null ? task.getPriority().name() : Notification.PRIORITY_MEDIUM;
		String title = "📋 Task Updated: " + task.getTaskName();
		String messageText = "Hi " + emp.getEmployee_name() + ", task \"" + task.getTaskName() 
				+ "\" has been updated by " + senderName + ". (Priority: " + priorityStr + ", Due: " + task.getDueDate() + ")";

		Notification n = new Notification(senderId, senderName, "EMPLOYEE", emp.getEmployee_id(), title, messageText, priorityStr);
		n.setCategory(Notification.CAT_TASK);
		boolean success = notificationDao.createNotification(n);

		if (success) {
			asyncExecutor.submit(() -> {
				try {
					if (emp.getEmail() != null && !emp.getEmail().isBlank()) {
						String emailSubject = "📋 Task Updated: " + task.getTaskName();
						String emailBody = buildHtmlEmailCard(
								"📋 Task Details Updated",
								"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>The details for your task have been updated by <b>" + senderName + "</b>.",
								new String[][]{
										{"Task ID", task.getTaskId() != null ? task.getTaskId() : "TSK-GEN"},
										{"Task Name", task.getTaskName()},
										{"Priority", priorityStr},
										{"Due Date", String.valueOf(task.getDueDate())},
										{"Updated By", senderName},
										{"Description", task.getDescription() != null ? task.getDescription() : "No additional description provided."}
								}
						);
						EmailService.sendEmail(emp.getEmail(), emailSubject, emailBody);
					}
					if (emp.getPhone() > 0) {
						String smsMsg = "SmartOffice Alert: Task \"" + task.getTaskName() + "\" updated (Priority: " 
								+ priorityStr + ", Due: " + task.getDueDate() + ") by " + senderName + ". Check portal.";
						if (smsMsg.length() > 155) smsMsg = smsMsg.substring(0, 152) + "...";
						SmsService.sendSms(String.valueOf(emp.getPhone()), smsMsg);
					}
				} catch (Exception e) {
					System.err.println("[NotificationService] Error sending task update email/SMS: " + e.getMessage());
				}
			});
		}
		return success;
	}

	public boolean notifyTaskDeleted(Task task, int senderId, String senderName, Employee emp) {
		if (task == null || emp == null) return false;

		String title = "❌ Task Removed: " + task.getTaskName();
		String messageText = "Hi " + emp.getEmployee_name() + ", task \"" + task.getTaskName() 
				+ "\" assigned to you has been removed/cancelled by " + senderName + ".";

		Notification n = new Notification(senderId, senderName, "EMPLOYEE", emp.getEmployee_id(), title, messageText, Notification.PRIORITY_HIGH);
		n.setCategory(Notification.CAT_TASK);
		boolean success = notificationDao.createNotification(n);

		if (success) {
			asyncExecutor.submit(() -> {
				try {
					if (emp.getEmail() != null && !emp.getEmail().isBlank()) {
						String emailSubject = "❌ Task Cancelled: " + task.getTaskName();
						String emailBody = buildHtmlEmailCard(
								"❌ Task Removed",
								"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>The following task assigned to you has been removed by <b>" + senderName + "</b>.",
								new String[][]{
										{"Task Name", task.getTaskName()},
										{"Removed By", senderName},
										{"Status", "Removed / Cancelled"}
								}
						);
						EmailService.sendEmail(emp.getEmail(), emailSubject, emailBody);
					}
					if (emp.getPhone() > 0) {
						String smsMsg = "SmartOffice Alert: Task \"" + task.getTaskName() + "\" assigned to you has been REMOVED by " + senderName + ".";
						if (smsMsg.length() > 155) smsMsg = smsMsg.substring(0, 152) + "...";
						SmsService.sendSms(String.valueOf(emp.getPhone()), smsMsg);
					}
				} catch (Exception e) {
					System.err.println("[NotificationService] Error sending task delete email/SMS: " + e.getMessage());
				}
			});
		}
		return success;
	}

	/** 10.2 Leave Application */
	public boolean notifyLeaveApplication(long employeeId, String employeeName, long managerId, int daysCount, String reason) {
		String title = employeeName + " has applied for Leave";
		String message = "Duration: " + daysCount + " Days | Reason: " + reason;
		Notification n = new Notification(employeeId, managerId, title, message, Notification.CAT_LEAVE, Notification.PRIORITY_MEDIUM);
		n.setSenderName(employeeName);
		return createNotification(n);
	}

	/** 10.3 Leave Approval / Rejection */
	public boolean notifyLeaveApproval(long managerId, String managerName, long employeeId, boolean isApproved, String note) {
		String title = isApproved ? "Your Leave Request has been Approved" : "Your Leave Request has been Rejected";
		String message = isApproved 
				? "Your leave request was approved by " + managerName + "." 
				: "Your leave request was rejected by " + managerName + ". Reason: " + (note != null ? note : "Not specified");
		String priority = isApproved ? Notification.PRIORITY_MEDIUM : Notification.PRIORITY_HIGH;
		Notification n = new Notification(managerId, employeeId, title, message, Notification.CAT_LEAVE, priority);
		n.setSenderName(managerName);
		return createNotification(n);
	}

	/** 10.4 Meeting Scheduled */
	public boolean notifyMeetingScheduled(long organizerId, String organizerName, List<Long> participantIds, String meetingTitle, String timeStr, String location) {
		String title = "Meeting Scheduled";
		String message = "Title:\n" + meetingTitle + "\n\nTime:\n" + timeStr + "\n\nLocation:\n" + location;
		boolean allSuccess = true;
		for (Long pId : participantIds) {
			Notification n = new Notification(organizerId, pId, title, message, Notification.CAT_MEETING, Notification.PRIORITY_HIGH);
			n.setSenderName(organizerName);
			allSuccess &= createNotification(n);
		}
		return allSuccess;
	}

	public boolean notifyMeetingScheduled(Meeting meeting, String senderName, List<Employee> participants) {
		if (meeting == null || participants == null || participants.isEmpty()) return false;

		String locationDetails = "";
		if (meeting.getMeetingMode() != null) {
			locationDetails += "Mode: " + meeting.getMeetingMode().name();
		}
		if (meeting.getRoom() != null && !meeting.getRoom().isBlank()) {
			locationDetails += (locationDetails.isEmpty() ? "" : " | ") + "Room: " + meeting.getRoom();
		}
		if (meeting.getMeetingLink() != null && !meeting.getMeetingLink().isBlank()) {
			locationDetails += (locationDetails.isEmpty() ? "" : " | ") + "Link: " + meeting.getMeetingLink();
		}

		String notifTitle = "📅 Meeting Scheduled: " + meeting.getTitle();
		String priorityStr = meeting.getPriority() != null ? meeting.getPriority().toUpperCase() : Notification.PRIORITY_HIGH;
		boolean allSuccess = true;

		for (Employee emp : participants) {
			if (emp == null) continue;
			String messageText = "Hi " + emp.getEmployee_name() + ", you have been scheduled for meeting \"" 
					+ meeting.getTitle() + "\" on " + meeting.getMeetingDate() + " (" + meeting.getStartTime() 
					+ " - " + meeting.getEndTime() + ") by " + senderName + ". " 
					+ (locationDetails.isEmpty() ? "" : "[" + locationDetails + "]");

			Notification n = new Notification(meeting.getOrganizerId(), senderName, "EMPLOYEE", emp.getEmployee_id(), notifTitle, messageText, priorityStr);
			n.setCategory(Notification.CAT_MEETING);
			boolean success = notificationDao.createNotification(n);
			allSuccess &= success;

			if (success) {
				final String loc = locationDetails;
				asyncExecutor.submit(() -> {
					try {
						if (emp.getEmail() != null && !emp.getEmail().isBlank()) {
							String emailSubject = "📅 Meeting Invitation: " + meeting.getTitle();
							String emailBody = buildHtmlEmailCard(
									"📅 Scheduled Meeting Notice",
									"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>You are invited to attend the following meeting scheduled by <b>" + senderName + "</b>.",
									new String[][]{
											{"Meeting Title", meeting.getTitle()},
											{"Date", String.valueOf(meeting.getMeetingDate())},
											{"Time Slot", meeting.getStartTime() + " - " + meeting.getEndTime()},
											{"Meeting Type", meeting.getMeetingType() != null ? meeting.getMeetingType() : "General"},
											{"Location / Link", loc.isEmpty() ? "Standard Meeting Room" : loc},
											{"Agenda", meeting.getAgenda() != null && !meeting.getAgenda().isBlank() ? meeting.getAgenda() : "General Discussion"}
									}
							);
							EmailService.sendEmail(emp.getEmail(), emailSubject, emailBody);
						}
						if (emp.getPhone() > 0) {
							String smsMsg = "SmartOffice Alert: Meeting \"" + meeting.getTitle() + "\" scheduled on " 
									+ meeting.getMeetingDate() + " at " + meeting.getStartTime() + " by " + senderName + ". Check portal.";
							if (smsMsg.length() > 155) smsMsg = smsMsg.substring(0, 152) + "...";
							SmsService.sendSms(String.valueOf(emp.getPhone()), smsMsg);
						}
					} catch (Exception e) {
						System.err.println("[NotificationService] Error sending meeting email/SMS: " + e.getMessage());
					}
				});
			}
		}
		return allSuccess;
	}

	public boolean notifyMeetingUpdated(Meeting meeting, String senderName, List<Employee> participants) {
		if (meeting == null || participants == null || participants.isEmpty()) return false;

		String locationDetails = "";
		if (meeting.getMeetingMode() != null) {
			locationDetails += "Mode: " + meeting.getMeetingMode().name();
		}
		if (meeting.getRoom() != null && !meeting.getRoom().isBlank()) {
			locationDetails += (locationDetails.isEmpty() ? "" : " | ") + "Room: " + meeting.getRoom();
		}
		if (meeting.getMeetingLink() != null && !meeting.getMeetingLink().isBlank()) {
			locationDetails += (locationDetails.isEmpty() ? "" : " | ") + "Link: " + meeting.getMeetingLink();
		}

		String notifTitle = "📝 Meeting Updated: " + meeting.getTitle();
		String priorityStr = meeting.getPriority() != null ? meeting.getPriority().toUpperCase() : Notification.PRIORITY_MEDIUM;
		boolean allSuccess = true;

		for (Employee emp : participants) {
			if (emp == null) continue;
			String messageText = "Hi " + emp.getEmployee_name() + ", meeting \"" + meeting.getTitle() 
					+ "\" details have been updated by " + senderName + ". New Schedule: " 
					+ meeting.getMeetingDate() + " (" + meeting.getStartTime() + " - " + meeting.getEndTime() + "). "
					+ (locationDetails.isEmpty() ? "" : "[" + locationDetails + "]");

			Notification n = new Notification(meeting.getOrganizerId(), senderName, "EMPLOYEE", emp.getEmployee_id(), notifTitle, messageText, priorityStr);
			n.setCategory(Notification.CAT_MEETING);
			boolean success = notificationDao.createNotification(n);
			allSuccess &= success;

			if (success) {
				final String loc = locationDetails;
				asyncExecutor.submit(() -> {
					try {
						if (emp.getEmail() != null && !emp.getEmail().isBlank()) {
							String emailSubject = "📝 Meeting Updated: " + meeting.getTitle();
							String emailBody = buildHtmlEmailCard(
									"📝 Meeting Details Updated",
									"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>The following meeting has been updated/rescheduled by <b>" + senderName + "</b>.",
									new String[][]{
											{"Meeting Title", meeting.getTitle()},
											{"Date", String.valueOf(meeting.getMeetingDate())},
											{"Time Slot", meeting.getStartTime() + " - " + meeting.getEndTime()},
											{"Meeting Type", meeting.getMeetingType() != null ? meeting.getMeetingType() : "General"},
											{"Location / Link", loc.isEmpty() ? "Standard Meeting Room" : loc},
											{"Status", String.valueOf(meeting.getStatus())}
									}
							);
							EmailService.sendEmail(emp.getEmail(), emailSubject, emailBody);
						}
						if (emp.getPhone() > 0) {
							String smsMsg = "SmartOffice Alert: Meeting \"" + meeting.getTitle() + "\" updated to " 
									+ meeting.getMeetingDate() + " at " + meeting.getStartTime() + " by " + senderName + ". Check portal.";
							if (smsMsg.length() > 155) smsMsg = smsMsg.substring(0, 152) + "...";
							SmsService.sendSms(String.valueOf(emp.getPhone()), smsMsg);
						}
					} catch (Exception e) {
						System.err.println("[NotificationService] Error sending meeting update email/SMS: " + e.getMessage());
					}
				});
			}
		}
		return allSuccess;
	}

	public boolean notifyMeetingCancelled(Meeting meeting, String senderName, List<Employee> participants) {
		if (meeting == null || participants == null || participants.isEmpty()) return false;

		String notifTitle = "❌ Meeting Cancelled: " + meeting.getTitle();
		boolean allSuccess = true;

		for (Employee emp : participants) {
			if (emp == null) continue;
			String messageText = "Hi " + emp.getEmployee_name() + ", the meeting \"" + meeting.getTitle() 
					+ "\" scheduled for " + meeting.getMeetingDate() + " has been CANCELLED by " + senderName + ".";

			Notification n = new Notification(meeting.getOrganizerId(), senderName, "EMPLOYEE", emp.getEmployee_id(), notifTitle, messageText, Notification.PRIORITY_HIGH);
			n.setCategory(Notification.CAT_MEETING);
			boolean success = notificationDao.createNotification(n);
			allSuccess &= success;

			if (success) {
				asyncExecutor.submit(() -> {
					try {
						if (emp.getEmail() != null && !emp.getEmail().isBlank()) {
							String emailSubject = "❌ Meeting Cancelled: " + meeting.getTitle();
							String emailBody = buildHtmlEmailCard(
									"❌ Meeting Cancelled Notice",
									"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>The following scheduled meeting has been cancelled by <b>" + senderName + "</b>.",
									new String[][]{
											{"Meeting Title", meeting.getTitle()},
											{"Original Date", String.valueOf(meeting.getMeetingDate())},
											{"Cancelled By", senderName},
											{"Status", "Cancelled"}
									}
							);
							EmailService.sendEmail(emp.getEmail(), emailSubject, emailBody);
						}
						if (emp.getPhone() > 0) {
							String smsMsg = "SmartOffice Alert: Meeting \"" + meeting.getTitle() + "\" on " 
									+ meeting.getMeetingDate() + " has been CANCELLED by " + senderName + ".";
							if (smsMsg.length() > 155) smsMsg = smsMsg.substring(0, 152) + "...";
							SmsService.sendSms(String.valueOf(emp.getPhone()), smsMsg);
						}
					} catch (Exception e) {
						System.err.println("[NotificationService] Error sending meeting cancel email/SMS: " + e.getMessage());
					}
				});
			}
		}
		return allSuccess;
	}

	/** 10.5 Meeting Reminder */
	public boolean notifyMeetingReminder(long receiverId, String meetingTitle, int minutesBefore) {
		String title = "Reminder";
		String message = meetingTitle + " starts in " + minutesBefore + " minutes.";
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_REMINDER, Notification.PRIORITY_HIGH);
		n.setSenderName("System Scheduler");
		return createNotification(n);
	}

	/** 10.6 Attendance Reminder */
	public boolean notifyAttendanceReminder(long receiverId) {
		String title = "Reminder";
		String message = "You haven't marked today's attendance.";
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_ATTENDANCE, Notification.PRIORITY_HIGH);
		n.setSenderName("System Scheduler");
		return createNotification(n);
	}

	/** 10.7 Checkout Reminder */
	public boolean notifyCheckoutReminder(long receiverId) {
		String title = "Reminder";
		String message = "Please checkout before leaving office.";
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_ATTENDANCE, Notification.PRIORITY_MEDIUM);
		n.setSenderName("System Scheduler");
		return createNotification(n);
	}

	/** 10.8 Break Reminder */
	public boolean notifyBreakReminder(long receiverId, int breakMinutes) {
		String title = "Break Exceeded";
		String message = "Your break exceeds " + breakMinutes + " minutes.\n\nPlease return to work.";
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_ATTENDANCE, Notification.PRIORITY_HIGH);
		n.setSenderName("System Scheduler");
		return createNotification(n);
	}

	/** 10.9 Project Deadline Reminder */
	public boolean notifyProjectDeadline(long receiverId, String taskName, String deadlineStr) {
		String title = "Reminder";
		String message = "Task:\n" + taskName + "\n\nDeadline " + deadlineStr;
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_PROJECT, Notification.PRIORITY_HIGH);
		n.setSenderName("System Scheduler");
		return createNotification(n);
	}

	/** 10.10 Payroll Notification */
	public boolean notifyPayroll(long accountantId, long receiverId, String monthName) {
		String title = "Salary Slip Available";
		String message = "Month:\n" + monthName + "\n\nClick to Download";
		Notification n = new Notification(accountantId, receiverId, title, message, Notification.CAT_PAYROLL, Notification.PRIORITY_MEDIUM);
		n.setSenderName("Payroll Department");
		return createNotification(n);
	}

	/** 10.11 Holiday Announcement */
	public boolean notifyHolidayAnnouncement(long hrId, String holidayDate, String holidayTitle) {
		String title = "Office Holiday";
		String message = holidayDate + "\n\n" + holidayTitle;
		Notification n = new Notification(hrId, 0, title, message, Notification.CAT_HOLIDAY, Notification.PRIORITY_LOW);
		n.setRecipientType("ALL");
		n.setSenderName("HR Department");
		return createNotification(n);
	}

	/** 10.12 Company Announcement */
	public boolean notifyCompanyAnnouncement(long adminId, String senderName, String subject, String details) {
		String title = subject;
		String message = details;
		Notification n = new Notification(adminId, 0, title, message, Notification.CAT_ANNOUNCEMENT, Notification.PRIORITY_MEDIUM);
		n.setRecipientType("ALL");
		n.setSenderName(senderName != null ? senderName : "Admin");
		return createNotification(n);
	}

	/** 10.13 Password Changed */
	public boolean notifyPasswordChanged(long receiverId) {
		String title = "Security Alert";
		String message = "Your password has been changed successfully.";
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_SECURITY, Notification.PRIORITY_CRITICAL);
		n.setSenderName("Security System");
		return createNotification(n);
	}

	/** 10.14 Login Alert */
	public boolean notifyLoginAlert(long receiverId, String browser, String location) {
		String title = "New Login Detected";
		String message = "Browser:\n" + browser + "\n\nLocation:\n" + location;
		Notification n = new Notification(0, receiverId, title, message, Notification.CAT_SECURITY, Notification.PRIORITY_CRITICAL);
		n.setSenderName("Security System");
		return createNotification(n);
	}

	/** 10.15 Birthday Notification */
	public boolean notifyBirthday(long employeeId, String empName, int age) {
		String title = "Wish Happy Birthday";
		String message = empName + " turns " + age + " today.";
		Notification n = new Notification(0, 0, title, message, Notification.CAT_ANNOUNCEMENT, Notification.PRIORITY_LOW);
		n.setRecipientType("ALL");
		n.setSenderName("SmartOffice Celebrations");
		return createNotification(n);
	}

	/** 10.16 Work Anniversary */
	public boolean notifyWorkAnniversary(long employeeId, int yearsCount) {
		String title = "Congratulations!";
		String message = "Today is your " + getOrdinal(yearsCount) + " Work Anniversary.";
		Notification n = new Notification(0, employeeId, title, message, Notification.CAT_PERFORMANCE, Notification.PRIORITY_MEDIUM);
		n.setSenderName("HR Department");
		return createNotification(n);
	}

	/** 10.17 Document Upload */
	public boolean notifyDocumentUpload(long senderId, String senderName, long receiverId, String docName) {
		String title = "New Document Uploaded";
		String message = docName;
		Notification n = new Notification(senderId, receiverId, title, message, Notification.CAT_DOCUMENTS, Notification.PRIORITY_MEDIUM);
		n.setSenderName(senderName != null ? senderName : "HR");
		return createNotification(n);
	}

	/** 10.18 Performance Review */
	public boolean notifyPerformanceReview(long managerId, String managerName, long receiverId, String reviewDateStr) {
		String title = "Performance Review Scheduled";
		String message = "Your Performance Review has been scheduled for " + reviewDateStr + " by " + managerName + ".";
		Notification n = new Notification(managerId, receiverId, title, message, Notification.CAT_PERFORMANCE, Notification.PRIORITY_HIGH);
		n.setSenderName(managerName);
		return createNotification(n);
	}

	// Private Helper: Async dispatch to Email and SMS
	private void dispatchAsyncChannels(Notification notification) {
		asyncExecutor.submit(() -> {
			try {
				if (notification.getReceiverId() > 0) {
					Employee emp = employeeDao.getEmployeeById((int) notification.getReceiverId());
					if (emp != null) {
						sendEmailAndSms(emp, notification);
					}
				} else if ("ALL".equalsIgnoreCase(notification.getRecipientType())) {
					List<Employee> allEmployees = employeeDao.getAllEmployees();
					if (allEmployees != null) {
						for (Employee emp : allEmployees) {
							sendEmailAndSms(emp, notification);
						}
					}
				}
			} catch (Exception e) {
				System.err.println("[NotificationService] Error sending async email/SMS: " + e.getMessage());
			}
		});
	}

	public boolean createNotification(Notification notification, boolean sendEmailAlert, boolean sendSmsAlert, String customPhone) {
		if (notification == null) return false;
		if (notification.getTitle() == null || notification.getTitle().isBlank()) return false;
		if (notification.getMessage() == null || notification.getMessage().isBlank()) return false;

		if (notification.getCategory() == null || notification.getCategory().isBlank()) {
			notification.setCategory(Notification.CAT_ANNOUNCEMENT);
		}
		if (notification.getPriority() == null || notification.getPriority().isBlank()) {
			notification.setPriority(Notification.PRIORITY_MEDIUM);
		}
		if (notification.getStatus() == null || notification.getStatus().isBlank()) {
			notification.setStatus(Notification.STATUS_UNREAD);
		}

		boolean success = notificationDao.createNotification(notification);

		if (success) {
			dispatchAsyncChannelsCustom(notification, sendEmailAlert, sendSmsAlert, customPhone);
		}

		return success;
	}

	private void dispatchAsyncChannelsCustom(Notification notification, boolean sendEmailAlert, boolean sendSmsAlert, String customPhone) {
		asyncExecutor.submit(() -> {
			try {
				if (customPhone != null && !customPhone.isBlank() && sendSmsAlert) {
					String sms = "SmartOffice [" + (notification.getCategory() != null ? notification.getCategory() : "Alert") + "]: " + notification.getTitle() + " - " + notification.getMessage();
					if (sms.length() > 155) sms = sms.substring(0, 152) + "...";
					SmsService.sendSms(customPhone.trim(), sms);
				}

				if (notification.getReceiverId() > 0) {
					Employee emp = employeeDao.getEmployeeById((int) notification.getReceiverId());
					if (emp != null) {
						sendEmailAndSmsCustom(emp, notification, sendEmailAlert, sendSmsAlert);
					}
				} else if ("ALL".equalsIgnoreCase(notification.getRecipientType())) {
					List<Employee> allEmployees = employeeDao.getAllEmployees();
					if (allEmployees != null) {
						for (Employee emp : allEmployees) {
							sendEmailAndSmsCustom(emp, notification, sendEmailAlert, sendSmsAlert);
						}
					}
				}
			} catch (Exception e) {
				System.err.println("[NotificationService] Error sending async email/SMS: " + e.getMessage());
			}
		});
	}

	private void sendEmailAndSms(Employee emp, Notification n) {
		sendEmailAndSmsCustom(emp, n, true, true);
	}

	private void sendEmailAndSmsCustom(Employee emp, Notification n, boolean sendEmailAlert, boolean sendSmsAlert) {
		if (emp == null) return;
		if (sendEmailAlert && emp.getEmail() != null && !emp.getEmail().isBlank()) {
			String subject = "[" + (n.getCategory() != null ? n.getCategory() : "Notification") + "] " + n.getTitle();
			String body = buildHtmlEmailCard(
					n.getTitle() != null ? n.getTitle() : "Notification",
					"Hello <b>" + emp.getEmployee_name() + "</b>,<br><br>You have received a new notification in SmartOffice ELAMS.",
					new String[][]{
							{"Category", n.getCategory() != null ? n.getCategory() : "General"},
							{"Priority", n.getPriority() != null ? n.getPriority() : "NORMAL"},
							{"Sender", n.getSenderName() != null ? n.getSenderName() : "System"},
							{"Details", n.getMessage() != null ? n.getMessage() : ""}
					}
			);
			EmailService.sendEmail(emp.getEmail(), subject, body);
		}
		if (sendSmsAlert) {
			String phoneStr = emp.getPhone() > 0 ? String.valueOf(emp.getPhone()) : null;
			if (phoneStr != null && !phoneStr.isBlank()) {
				String sms = "SmartOffice [" + n.getCategory() + "]: " + n.getTitle() + " - " + n.getMessage();
				if (sms.length() > 155) sms = sms.substring(0, 152) + "...";
				SmsService.sendSms(phoneStr, sms);
			}
		}
	}

	private static String buildHtmlEmailCard(String cardHeader, String introText, String[][] tableData) {
		StringBuilder rows = new StringBuilder();
		if (tableData != null) {
			for (String[] row : tableData) {
				if (row.length >= 2) {
					rows.append("<tr>")
						.append("<td style='padding: 10px; border-bottom: 1px solid #e2e8f0; font-weight: 600; color: #4a5568; width: 35%;'>")
						.append(row[0]).append("</td>")
						.append("<td style='padding: 10px; border-bottom: 1px solid #e2e8f0; color: #2d3748;'>")
						.append(row[1]).append("</td>")
						.append("</tr>");
				}
			}
		}

		return "<!DOCTYPE html>"
				+ "<html>"
				+ "<head><meta charset='UTF-8'></head>"
				+ "<body style='font-family: Arial, sans-serif; background-color: #f7fafc; margin: 0; padding: 20px;'>"
				+ "<div style='max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); overflow: hidden; border: 1px solid #e2e8f0;'>"
				+ "<div style='background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%); color: #ffffff; padding: 20px; text-align: center;'>"
				+ "<h2 style='margin: 0; font-size: 20px; font-weight: 600;'>" + cardHeader + "</h2>"
				+ "</div>"
				+ "<div style='padding: 24px; color: #2d3748; line-height: 1.6;'>"
				+ "<p style='margin-top: 0; font-size: 15px;'>" + introText + "</p>"
				+ "<table style='width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px;'>"
				+ rows.toString()
				+ "</table>"
				+ "<div style='margin-top: 25px; padding-top: 15px; border-top: 1px solid #edf2f7; text-align: center; color: #718096; font-size: 12px;'>"
				+ "<p style='margin: 0;'>Employee Leave & Attendance Management System (ELAMS)</p>"
				+ "<p style='margin: 5px 0 0 0;'>This is an automated notification. Please do not reply directly to this email.</p>"
				+ "</div>"
				+ "</div>"
				+ "</div>"
				+ "</body>"
				+ "</html>";
	}

	private String getOrdinal(int n) {
		if (n >= 11 && n <= 13) return n + "th";
		switch (n % 10) {
			case 1:  return n + "st";
			case 2:  return n + "nd";
			case 3:  return n + "rd";
			default: return n + "th";
		}
	}
}
