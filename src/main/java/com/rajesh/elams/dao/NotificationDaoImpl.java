package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.Notification;
import com.rajesh.elams.util.DbUtil;

public class NotificationDaoImpl implements NotificationDao {

	public NotificationDaoImpl() {
		createTableIfNotExists();
	}

	private void createTableIfNotExists() {
		String sql = "CREATE TABLE IF NOT EXISTS notifications ("
				+ "notification_id BIGINT PRIMARY KEY AUTO_INCREMENT, "
				+ "sender_id BIGINT, "
				+ "receiver_id BIGINT, "
				+ "title VARCHAR(100), "
				+ "message TEXT, "
				+ "category VARCHAR(50), "
				+ "priority VARCHAR(20), "
				+ "status VARCHAR(20) DEFAULT 'Unread', "
				+ "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "
				+ "read_at TIMESTAMP NULL"
				+ ")";
		try (Connection con = DbUtil.getConnection(); Statement stmt = con.createStatement()) {
			stmt.executeUpdate(sql);
			
			// Auto-migration: check if optional/legacy columns exist, add if missing
			alterTableIfColumnMissing(con, "receiver_id", "BIGINT DEFAULT NULL");
			alterTableIfColumnMissing(con, "category", "VARCHAR(50) DEFAULT 'Announcement'");
			alterTableIfColumnMissing(con, "status", "VARCHAR(20) DEFAULT 'Unread'");
			alterTableIfColumnMissing(con, "read_at", "TIMESTAMP NULL");
			alterTableIfColumnMissing(con, "sender_name", "VARCHAR(100) DEFAULT NULL");
			alterTableIfColumnMissing(con, "recipient_type", "VARCHAR(20) DEFAULT 'ALL'");
			alterTableIfColumnMissing(con, "target_employee_id", "INT DEFAULT NULL");
			alterTableIfColumnMissing(con, "is_read", "BOOLEAN DEFAULT FALSE");
		} catch (Exception e) {
			System.err.println("Error initializing notifications table: " + e.getMessage());
		}
	}

	private void alterTableIfColumnMissing(Connection con, String columnName, String columnDef) {
		try {
			String checkSql = "SELECT " + columnName + " FROM notifications LIMIT 1";
			try (Statement stmt = con.createStatement()) {
				stmt.executeQuery(checkSql);
			}
		} catch (Exception e) {
			// Column doesn't exist, alter table to add it
			try (Statement stmt = con.createStatement()) {
				stmt.executeUpdate("ALTER TABLE notifications ADD COLUMN " + columnName + " " + columnDef);
			} catch (Exception ex) {
				// Ignore if alter fails or already present
			}
		}
	}

	@Override
	public boolean createNotification(Notification notification) {
		if (notification == null) return false;

		String sql = "INSERT INTO notifications (sender_id, receiver_id, sender_name, recipient_type, target_employee_id, title, message, category, priority, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			if (notification.getSenderId() > 0) {
				ps.setLong(1, notification.getSenderId());
			} else {
				ps.setNull(1, Types.BIGINT);
			}

			if (notification.getReceiverId() > 0) {
				ps.setLong(2, notification.getReceiverId());
				ps.setNull(5, Types.INTEGER);
			} else if (notification.getTargetEmployeeId() != null && notification.getTargetEmployeeId() > 0) {
				ps.setLong(2, notification.getTargetEmployeeId());
				ps.setInt(5, notification.getTargetEmployeeId());
			} else {
				ps.setNull(2, Types.BIGINT);
				ps.setNull(5, Types.INTEGER);
			}

			ps.setString(3, notification.getSenderName());
			ps.setString(4, notification.getRecipientType() != null ? notification.getRecipientType() : (notification.getReceiverId() > 0 ? "EMPLOYEE" : "ALL"));
			ps.setString(6, notification.getTitle());
			ps.setString(7, notification.getMessage());
			ps.setString(8, notification.getCategory() != null ? notification.getCategory() : Notification.CAT_ANNOUNCEMENT);
			ps.setString(9, notification.getPriority() != null ? notification.getPriority() : Notification.PRIORITY_MEDIUM);
			ps.setString(10, notification.getStatus() != null ? notification.getStatus() : Notification.STATUS_UNREAD);

			int affected = ps.executeUpdate();
			if (affected > 0) {
				try (ResultSet rs = ps.getGeneratedKeys()) {
					if (rs.next()) {
						notification.setNotificationId(rs.getLong(1));
					}
				}
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean sendNotification(Notification notification) {
		return createNotification(notification);
	}

	@Override
	public List<Notification> getNotificationsByUser(long receiverId) {
		List<Notification> list = new ArrayList<>();
		String sql = "SELECT * FROM notifications WHERE (receiver_id = ? OR target_employee_id = ? OR ((receiver_id IS NULL OR receiver_id = 0) AND (recipient_type = 'ALL' OR recipient_type IS NULL OR recipient_type = '')) OR recipient_type = 'ALL') AND status != 'Archived' ORDER BY created_at DESC LIMIT 50";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, receiverId);
			ps.setLong(2, receiverId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToNotification(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Notification> getUnreadNotifications(long receiverId) {
		List<Notification> list = new ArrayList<>();
		String sql = "SELECT * FROM notifications WHERE (receiver_id = ? OR target_employee_id = ? OR ((receiver_id IS NULL OR receiver_id = 0) AND (recipient_type = 'ALL' OR recipient_type IS NULL OR recipient_type = '')) OR recipient_type = 'ALL') AND (status = 'Unread' OR is_read = FALSE) ORDER BY created_at DESC";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, receiverId);
			ps.setLong(2, receiverId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToNotification(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public int getUnreadCount(long receiverId) {
		String sql = "SELECT COUNT(*) FROM notifications WHERE (receiver_id = ? OR target_employee_id = ? OR ((receiver_id IS NULL OR receiver_id = 0) AND (recipient_type = 'ALL' OR recipient_type IS NULL OR recipient_type = '')) OR recipient_type = 'ALL') AND (status = 'Unread' OR is_read = FALSE)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, receiverId);
			ps.setLong(2, receiverId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return rs.getInt(1);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

	@Override
	public boolean markAsRead(long notificationId) {
		String sql = "UPDATE notifications SET status = 'Read', is_read = TRUE, read_at = CURRENT_TIMESTAMP WHERE notification_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, notificationId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean markAsRead(int notificationId) {
		return markAsRead((long) notificationId);
	}

	@Override
	public boolean archiveNotification(long notificationId) {
		String sql = "UPDATE notifications SET status = 'Archived' WHERE notification_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, notificationId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean deleteNotification(long notificationId) {
		String sql = "DELETE FROM notifications WHERE notification_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, notificationId);
			return ps.executeUpdate() > 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean deleteNotification(int notificationId) {
		return deleteNotification((long) notificationId);
	}

	@Override
	public boolean deleteAllNotifications(long receiverId) {
		String sql = "DELETE FROM notifications WHERE receiver_id = ? OR target_employee_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, receiverId);
			ps.setLong(2, receiverId);
			return ps.executeUpdate() >= 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public List<Notification> getNotificationsFiltered(long receiverId, String category, String priority, String status, String keyword) {
		List<Notification> list = new ArrayList<>();
		StringBuilder sql = new StringBuilder("SELECT * FROM notifications WHERE (receiver_id = ? OR target_employee_id = ? OR ((receiver_id IS NULL OR receiver_id = 0) AND (recipient_type = 'ALL' OR recipient_type IS NULL OR recipient_type = '')) OR recipient_type = 'ALL')");

		List<Object> params = new ArrayList<>();
		params.add(receiverId);
		params.add(receiverId);

		if (category != null && !category.isBlank() && !"ALL".equalsIgnoreCase(category)) {
			sql.append(" AND category = ?");
			params.add(category);
		}
		if (priority != null && !priority.isBlank() && !"ALL".equalsIgnoreCase(priority)) {
			sql.append(" AND priority = ?");
			params.add(priority);
		}
		if (status != null && !status.isBlank() && !"ALL".equalsIgnoreCase(status)) {
			sql.append(" AND status = ?");
			params.add(status);
		}
		if (keyword != null && !keyword.isBlank()) {
			sql.append(" AND (title LIKE ? OR message LIKE ?)");
			params.add("%" + keyword.trim() + "%");
			params.add("%" + keyword.trim() + "%");
		}

		sql.append(" ORDER BY created_at DESC LIMIT 100");

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql.toString())) {
			for (int i = 0; i < params.size(); i++) {
				ps.setObject(i + 1, params.get(i));
			}
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToNotification(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Notification> getNotificationsForEmployee(int employeeId) {
		return getNotificationsByUser((long) employeeId);
	}

	@Override
	public List<Notification> getNotificationsSentBy(int senderId) {
		List<Notification> list = new ArrayList<>();
		String sql = "SELECT * FROM notifications WHERE sender_id = ? ORDER BY created_at DESC LIMIT 50";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, senderId);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					list.add(mapResultSetToNotification(rs));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public List<Notification> getAllNotifications() {
		List<Notification> list = new ArrayList<>();
		String sql = "SELECT * FROM notifications ORDER BY created_at DESC LIMIT 100";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				list.add(mapResultSetToNotification(rs));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}

	@Override
	public Notification getNotificationById(long notificationId) {
		String sql = "SELECT * FROM notifications WHERE notification_id = ?";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, notificationId);
			try (ResultSet rs = ps.executeQuery()) {
				if (rs.next()) {
					return mapResultSetToNotification(rs);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	@Override
	public Notification getNotificationById(int notificationId) {
		return getNotificationById((long) notificationId);
	}

	@Override
	public boolean markAllAsReadForEmployee(int employeeId) {
		String sql = "UPDATE notifications SET status = 'Read', is_read = TRUE, read_at = CURRENT_TIMESTAMP WHERE (receiver_id = ? OR target_employee_id = ? OR recipient_type = 'ALL') AND (status = 'Unread' OR is_read = FALSE)";
		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setLong(1, employeeId);
			ps.setLong(2, employeeId);
			return ps.executeUpdate() >= 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	@Override
	public boolean clearAllNotifications() {
		String sql = "DELETE FROM notifications";
		try (Connection con = DbUtil.getConnection(); Statement stmt = con.createStatement()) {
			return stmt.executeUpdate(sql) >= 0;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	private Notification mapResultSetToNotification(ResultSet rs) throws Exception {
		Notification n = new Notification();
		n.setNotificationId(rs.getLong("notification_id"));
		n.setSenderId(rs.getLong("sender_id"));
		
		long receiverId = rs.getLong("receiver_id");
		if (rs.wasNull()) {
			int targetEmp = rs.getInt("target_employee_id");
			if (!rs.wasNull()) {
				n.setReceiverId(targetEmp);
			}
		} else {
			n.setReceiverId(receiverId);
		}

		try { n.setSenderName(rs.getString("sender_name")); } catch (Exception ignored) {}
		try { n.setRecipientType(rs.getString("recipient_type")); } catch (Exception ignored) {}
		try {
			int targetEmp = rs.getInt("target_employee_id");
			if (!rs.wasNull()) n.setTargetEmployeeId(targetEmp);
		} catch (Exception ignored) {}

		n.setTitle(rs.getString("title"));
		n.setMessage(rs.getString("message"));
		
		String cat = null;
		try { cat = rs.getString("category"); } catch (Exception ignored) {}
		n.setCategory(cat != null ? cat : Notification.CAT_ANNOUNCEMENT);

		String prio = null;
		try { prio = rs.getString("priority"); } catch (Exception ignored) {}
		n.setPriority(prio != null ? prio : Notification.PRIORITY_MEDIUM);

		String st = null;
		try { st = rs.getString("status"); } catch (Exception ignored) {}
		if (st == null) {
			boolean isRead = false;
			try { isRead = rs.getBoolean("is_read"); } catch (Exception ignored) {}
			st = isRead ? Notification.STATUS_READ : Notification.STATUS_UNREAD;
		}
		n.setStatus(st);

		n.setCreatedAt(rs.getTimestamp("created_at"));
		try { n.setReadAt(rs.getTimestamp("read_at")); } catch (Exception ignored) {}

		return n;
	}
}
