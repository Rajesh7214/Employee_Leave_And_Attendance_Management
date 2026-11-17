# SmartOffice Project Documentation
## Notification Module

| Item | Details |
| --- | --- |
| **Module Name** | Notification Module |
| **Project** | SmartOffice – Office Automation & Workforce Management System |
| **Version** | 1.0 |
| **Prepared By** | Development Team |
| **Status** | Design & Implementation Documentation |

---

## 1. Introduction
The Notification Module is responsible for delivering important system updates and alerts to users based on events occurring within the SmartOffice application. It ensures that employees, managers, HR personnel, accountants, and administrators remain informed about tasks, meetings, attendance, leave requests, payroll updates, announcements, and other critical activities.
The module improves communication, enhances productivity, and minimizes the possibility of users missing important actions through multi-channel dispatch (In-App Dashboard, HTML Email Cards, and Mobile SMS alerts).

---

## 2. Objectives
The Notification Module aims to:
- Provide timely updates for important system events across multiple delivery channels (In-App, Email, SMS).
- Improve communication between employees and management.
- Reduce manual follow-ups through automated multi-channel notifications.
- Increase employee productivity with reminders and alerts.
- Maintain notification history for future reference.
- Support production-ready Email (Gmail SMTP with HTML cards) and SMS (Fast2SMS / Twilio / REST Gateway / GSM).

---

## 3. Scope
The Notification Module is integrated with multiple SmartOffice modules, including:
- Authentication
- Employee Management
- Task Management
- Attendance Management
- Leave Management
- Meeting Scheduler
- Payroll Management
- Project Management
- Document Management
- Announcement Management

---

## 4. User Roles
| Role | Responsibilities |
| --- | --- |
| **Admin** | Receives all important system notifications and announcements. |
| **HR** | Receives leave requests, employee updates, attendance alerts, and HR announcements. |
| **Manager** | Receives team-related notifications such as tasks, meetings, approvals, and deadlines. |
| **Employee** | Receives personal notifications related to tasks, attendance, meetings, and leave status. |
| **Team Lead** | Receives project updates and team activity notifications. |
| **Accountant** | Receives payroll-related notifications. |

---

## 5. Functional Requirements
The system shall:
- Automatically generate notifications based on system events.
- Concurrently dispatch alerts via **In-App Database**, **HTML Email Card (Gmail SMTP)**, and **Mobile SMS (Fast2SMS/Twilio)**.
- Display unread notification count on user headers/dashboards.
- Allow users to mark notifications as read.
- Store notification history in database.
- Allow users to delete or archive notifications.
- Categorize notifications by module.
- Assign priority levels.
- Support reminder notifications.
- Allow searching and filtering notifications.
- Support environment variable fallback (`EMAIL_USERNAME`, `EMAIL_APP_PASSWORD`, `FAST2SMS_API_KEY`).

---

## 6. Notification Categories
| Category | Description |
| --- | --- |
| **Task** | Task assignment and completion updates |
| **Leave** | Leave application and approval notifications |
| **Meeting** | Meeting schedules and reminders |
| **Attendance** | Check-in, checkout, and attendance reminders |
| **Payroll** | Salary and payslip notifications |
| **Announcement** | Company-wide announcements |
| **Project** | Project milestones and deadlines |
| **Reminder** | Scheduled reminders |
| **Holiday** | Holiday announcements |
| **Security** | Login alerts and password updates |
| **Documents** | Document uploads and approvals |
| **Performance** | Performance review notifications |

---

## 7. Notification Priority
| Priority | Description |
| --- | --- |
| **Low** | Informational notifications |
| **Medium** | Standard business notifications |
| **High** | Notifications requiring user action |
| **Critical** | Security and emergency notifications |

---

## 8. Notification Status
| Status | Description |
| --- | --- |
| **Unread** | Notification has not been viewed. |
| **Read** | Notification has been opened. |
| **Archived** | Notification has been archived by the user. |

---

## 9. Multi-Channel Notification Workflow

```
                  ┌────────────────────────┐
                  │      System Event      │
                  └───────────┬────────────┘
                              │
                              ▼
                  ┌────────────────────────┐
                  │    Business Service    │
                  └───────────┬────────────┘
                              │
                              ▼
                  ┌────────────────────────┐
                  │  Notification Service  │
                  └───────────┬────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  In-App DB Table │ │ HTML Email Card  │ │ Mobile SMS Alert │
│  (notifications) │ │   (Gmail SMTP)   │ │ (Fast2SMS/Twilio)│
└────────┬─────────┘ └──────────────────┘ └──────────────────┘
         │
         ▼
 ┌───────────────┐
 │ User Bell Icon│
 └───────────────┘
```

---

## 10. Notification Scenarios & Audit Matrix

| Scenario | Trigger | Recipient | Channels Supported | Trigger Site / Method |
| --- | --- | --- | --- | --- |
| **10.1 Task Assignment** | Manager assigns a new task | Employee | In-App, Email, SMS | `CreateTaskServlet`, `AssignTaskServlet` -> `notifyTaskAssignment` |
| **10.2 Leave Application** | Employee submits leave request | Manager | In-App, Email, SMS | `LeaveServlet` -> `notifyLeaveApplication` |
| **10.3 Leave Approval / Rejection** | Manager approves or rejects leave | Employee | In-App, Email, SMS | `ApproveLeaveServlet`, `RejectLeaveServlet` -> `notifyLeaveApproval` |
| **10.4 Meeting Scheduled** | Organizer schedules meeting | Invited Participants | In-App, Email, SMS | `ScheduleMeetingServlet` -> `notifyMeetingScheduled` |
| **10.5 Meeting Reminder** | 30 minutes before meeting | Participants | In-App, Email, SMS | `NotificationService.notifyMeetingReminder` |
| **10.6 Attendance Reminder** | Employee has not checked in | Employee | In-App, Email, SMS | `NotificationService.notifyAttendanceReminder` |
| **10.7 Checkout Reminder** | Employee forgets to checkout | Employee | In-App, Email, SMS | `NotificationService.notifyCheckoutReminder` |
| **10.8 Break Reminder** | Break exceeds maximum limit | Employee | In-App, Email, SMS | `NotificationService.notifyBreakReminder` |
| **10.9 Project Deadline** | 1 day before project deadline | Team / Employee | In-App, Email, SMS | `NotificationService.notifyProjectDeadline` |
| **10.10 Payroll Notification** | Salary processed | Employee | In-App, Email, SMS | `NotificationService.notifyPayroll` |
| **10.11 Holiday Announcement** | HR posts holiday | All Employees | In-App, Email, SMS | `NotificationService.notifyHolidayAnnouncement` |
| **10.12 Company Announcement** | Admin posts announcement | Target / All Employees | In-App, Email, SMS | `SendNotificationServlet` -> `notifyCompanyAnnouncement` |
| **10.13 Password Changed** | User changes password | User | In-App, Email, SMS | `ChangePasswordServlet` -> `notifyPasswordChanged` |
| **10.14 Login Alert** | Login from new device | User | In-App, Email, SMS | `NotificationService.notifyLoginAlert` |
| **10.15 Birthday Notification** | Employee birthday | All Employees | In-App, Email, SMS | `NotificationService.notifyBirthday` |
| **10.16 Work Anniversary** | Employee work anniversary | Employee | In-App, Email, SMS | `NotificationService.notifyWorkAnniversary` |
| **10.17 Document Upload** | Document uploaded for employee | Employee | In-App, Email, SMS | `NotificationService.notifyDocumentUpload` |
| **10.18 Performance Review** | Performance review scheduled | Employee | In-App, Email, SMS | `NotificationService.notifyPerformanceReview` |

---

## 11. Database Design

### Table: `notifications`
| Column Name | Data Type | Description |
| --- | --- | --- |
| `notification_id` | BIGINT | Primary Key (AUTO_INCREMENT) |
| `sender_id` | BIGINT | Sender User/Employee ID |
| `receiver_id` | BIGINT | Receiver User/Employee ID |
| `sender_name` | VARCHAR(100) | Full Name of Notification Sender |
| `recipient_type` | VARCHAR(20) | Recipient Type (`ALL` or `EMPLOYEE`) |
| `target_employee_id` | INT | Target Employee ID (for specific alerts) |
| `title` | VARCHAR(100) | Notification Title / Subject |
| `message` | TEXT | Notification Detailed Content |
| `category` | VARCHAR(50) | Notification Category (Task, Leave, Meeting, etc.) |
| `priority` | VARCHAR(20) | Priority Level (`Low`, `Medium`, `High`, `Critical`) |
| `status` | VARCHAR(20) | Status (`Unread`, `Read`, `Archived`) |
| `is_read` | BOOLEAN | Legacy Boolean Read Flag (`TRUE`/`FALSE`) |
| `created_at` | TIMESTAMP | Timestamp of creation (`DEFAULT CURRENT_TIMESTAMP`) |
| `read_at` | TIMESTAMP | Timestamp when opened/read (`NULL` if unread) |

---

## 12. SQL Table Definition (Complete Production Schema)

```sql
CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    sender_id BIGINT NULL,
    receiver_id BIGINT NULL,
    sender_name VARCHAR(100) DEFAULT NULL,
    recipient_type VARCHAR(20) DEFAULT 'ALL',
    target_employee_id INT DEFAULT NULL,
    title VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    category VARCHAR(50) DEFAULT 'Announcement',
    priority VARCHAR(20) DEFAULT 'Medium',
    status VARCHAR(20) DEFAULT 'Unread',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL
);
```

---

## 13. Java Model

```java
public class Notification {
    private long notificationId;
    private long senderId;
    private long receiverId;

    private String senderName;
    private String recipientType = "ALL"; // "ALL" or "EMPLOYEE"
    private Integer targetEmployeeId;

    private String title;
    private String message;
    private String category; // Task, Leave, Meeting, Attendance, Payroll, Announcement, etc.
    private String priority; // Low, Medium, High, Critical
    private String status;   // Unread, Read, Archived

    private Timestamp createdAt;
    private Timestamp readAt;

    // Category & Priority Constants
    public static final String CAT_TASK = "Task";
    public static final String CAT_LEAVE = "Leave";
    public static final String CAT_MEETING = "Meeting";
    public static final String CAT_ATTENDANCE = "Attendance";
    public static final String CAT_PAYROLL = "Payroll";
    public static final String CAT_ANNOUNCEMENT = "Announcement";
    public static final String CAT_PROJECT = "Project";
    public static final String CAT_REMINDER = "Reminder";
    public static final String CAT_HOLIDAY = "Holiday";
    public static final String CAT_SECURITY = "Security";
    public static final String CAT_DOCUMENTS = "Documents";
    public static final String CAT_PERFORMANCE = "Performance";

    public static final String PRIORITY_LOW = "Low";
    public static final String PRIORITY_MEDIUM = "Medium";
    public static final String PRIORITY_HIGH = "High";
    public static final String PRIORITY_CRITICAL = "Critical";

    public static final String STATUS_UNREAD = "Unread";
    public static final String STATUS_READ = "Read";
    public static final String STATUS_ARCHIVED = "Archived";

    // Getters, Setters, and Legacy Compat Helpers
}
```

---

## 14. DAO Layer (`NotificationDao`)

| Method | Description |
| --- | --- |
| `createNotification(Notification n)` | Insert new notification row into database |
| `sendNotification(Notification n)` | Alias for `createNotification` |
| `getNotificationsByUser(long receiverId)` | Fetch all notifications for specific employee |
| `getUnreadNotifications(long receiverId)` | Fetch unread notifications for specific employee |
| `getUnreadCount(long receiverId)` | Get total unread count for badge/bell icon |
| `markAsRead(long notificationId)` | Update status to `Read` and set `read_at = CURRENT_TIMESTAMP` |
| `archiveNotification(long notificationId)`| Update status to `Archived` |
| `deleteNotification(long notificationId)` | Delete notification row |
| `deleteAllNotifications(long receiverId)` | Bulk delete notifications for user |
| `getNotificationsFiltered(...)` | Search and filter notifications by category, priority, status, keyword |

---

## 15. Service Layer (`NotificationService`)

The Central Business Service layer (`com.rajesh.elams.service.NotificationService`) manages DB persistence and dispatches multi-channel alerts concurrently without blocking servlet threads.

### Key Responsibilities
- Create and validate notification objects.
- Persist in-app notification rows via `NotificationDao`.
- Asynchronously dispatch **HTML Email Cards** via `EmailService`.
- Asynchronously dispatch **Mobile SMS Alerts** via `SmsService`.
- Provide automated scenario methods (`notifyMeetingScheduled`, `notifyTaskAssignment`, `notifyLeaveApplication`, `notifyLeaveApproval`, `notifyPasswordChanged`, etc.).

---

## 16. REST API Endpoints

| Method | Endpoint | Description | Query / Body Params |
| --- | --- | --- | --- |
| `GET` | `/notifications` | Get user notifications | `userId`, `category`, `status` |
| `GET` | `/notifications/unread` | Get unread notifications | `userId` |
| `GET` | `/notifications/count` | Get unread notification count | `userId` |
| `POST` | `/notifications` | Create & dispatch notification | JSON Notification Object |
| `PUT` | `/notifications/read/{id}` | Mark notification as read | `id` path variable |
| `PUT` | `/notifications/archive/{id}`| Archive notification | `id` path variable |
| `DELETE` | `/notifications/{id}` | Delete notification | `id` path variable |
