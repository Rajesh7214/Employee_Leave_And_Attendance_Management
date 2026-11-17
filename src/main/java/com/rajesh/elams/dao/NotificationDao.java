package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.Notification;

public interface NotificationDao {
	// Standard Specification Methods (Section 14)
	boolean createNotification(Notification notification);

	List<Notification> getNotificationsByUser(long receiverId);

	List<Notification> getUnreadNotifications(long receiverId);

	int getUnreadCount(long receiverId);

	boolean markAsRead(long notificationId);

	boolean archiveNotification(long notificationId);

	boolean deleteNotification(long notificationId);

	boolean deleteAllNotifications(long receiverId);

	// Filtering & Searching
	List<Notification> getNotificationsFiltered(long receiverId, String category, String priority, String status, String keyword);

	// Legacy compatibility methods
	boolean sendNotification(Notification notification);

	List<Notification> getNotificationsForEmployee(int employeeId);

	List<Notification> getNotificationsSentBy(int senderId);

	List<Notification> getAllNotifications();

	Notification getNotificationById(long notificationId);

	Notification getNotificationById(int notificationId);

	boolean markAsRead(int notificationId);

	boolean markAllAsReadForEmployee(int employeeId);

	boolean deleteNotification(int notificationId);

	boolean clearAllNotifications();
}
