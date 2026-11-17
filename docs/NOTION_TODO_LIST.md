# ✅ ELAMS — Project Master To-Do List & Roadmap
> **Target Notion Page**: [To Do List](https://app.notion.com/p/To-Do-List-41b783681a9f808bb62efb6b08db5bdf)  
> *Copy and paste directly into your Notion To-Do List page. Notion will render these as native interactive checkboxes, tags, and callouts.*

---

## 🎯 High-Priority Overview
- **Project**: Employee Leave & Attendance Management System (SmartOffice)
- **Status**: Core Attendance & Backend Lifecycle Verified (Zero Errors)
- **Next Phase**: End-to-end integration testing and production packaging

---

## ⏱️ 1. Attendance & Duty Session Engine

- [x] **Check-in Timestamp Recording**: Capture login time with dynamic location capture (`Office / Remote` / Geolocation).
- [x] **Duplicate Check-in Prevention**: Guard against accidental double submissions on the same calendar date.
- [x] **Late Arrival Threshold**: Automatically mark attendance as `"Late"` if check-in is after 10:00 AM.
- [x] **Break Tracking Session**: Implement `startBreak` and `endBreak` with cumulative duration accumulation.
- [x] **Auto-Close Break on Logout**: Ensure active breaks are cleanly closed and recorded if employee clicks Logout while on break.
- [x] **Shift Duration Evaluation**: Automatically classify completed shifts as `"Early Leave"` (< 6:00 PM), `"Overtime"` (> 6:00 PM), or `"Present"`.
- [x] **Live Frontend Active Duration Timer**: Real-time timer in `attendance.jsp` that pauses accurately during break intervals.
- [ ] **Monthly Attendance Summary Export**: Add PDF / Excel export button on `attendanceHistory.jsp`.
- [ ] **Biometric / QR Code Check-in**: Optional extension for on-premise tablet scanning.

---

## 🌴 2. Leave Management & Approval Lifecycle

- [x] **Leave Application Form**: Employee applies with start date, end date, leave type, and reason.
- [x] **Multi-Tier Review (HR / Manager)**: Approval and rejection action workflows with status updates.
- [x] **Leave Balance Counter**: Deduct approved paid leaves (Casual, Sick) from the employee's yearly quota.
- [x] **Loss of Pay (LOP) Flagging**: Mark unpaid leave days to automatically flow into the Payroll calculation engine.
- [ ] **Email Notification on Approval/Rejection**: Dispatch automatic email alerts to employees when leave status changes.
- [ ] **Team Absence Calendar View**: Shared calendar on `calendarView.jsp` showing approved team leaves.

---

## 💰 3. Payroll Calculation & Payslip Engine

- [x] **Salary Structure Configuration**: Basic pay, HRA, Transport, Medical, and Other Allowances per employee.
- [x] **Automated Statutory Deductions**: Provident Fund (PF) and Professional Tax calculations.
- [x] **Loss of Pay (LOP) Math**: Exact deduction calculation based on working days (`(Gross / Working Days) * Unpaid Days`).
- [x] **Payslip Generation**: Generate formatted monthly payslips on `payslip.jsp`.
- [ ] **Bulk Monthly Payroll Processing**: One-click "Process All Active Employees" button for HR/Admin.
- [ ] **Download Payslip as PDF**: Client-side or server-side PDF generator for employee payslips.

---

## 👥 4. Workforce & Employee Directory

- [x] **Employee Profiles**: Name, email, phone, designation, and department management.
- [x] **Role-Based Access Control (RBAC)**: Secure access routes for Admin, HR, Manager, and Employee.
- [x] **Self-Service Profile Page**: Employee view and edit personal contact info on `profile.jsp`.
- [ ] **Department Transfer History**: Audit trail when an employee changes departments or designations.
- [ ] **Profile Picture Upload**: Allow employees to upload avatar images to their profile.

---

## 📋 5. Task Allocation & Tracking

- [x] **Task Creation & Assignment**: Managers assign tasks with title, description, priority, and deadline.
- [x] **Status Progression**: Move tasks from `Pending` → `In Progress` → `Completed`.
- [x] **Employee Task Board**: Dedicated dashboard cards on `employeeDashboard.jsp` showing assigned tasks.
- [ ] **Overdue Task Reminders**: Automatic alerts for tasks nearing or past their due date.
- [ ] **Kanban Board View**: Drag-and-drop task workflow view on `tasks.jsp`.

---

## 📅 6. Meeting & Room Booking Management

- [x] **Meeting Room Scheduling**: Room capacity check, time slots, and agenda setting.
- [x] **Participant Invitations & RSVP**: Invite employees and record Accept / Decline status.
- [x] **Meeting Minutes & Notes**: Collaborative meeting notes attachment on `meetingDetails.jsp`.
- [x] **Meeting Attendance Verification**: Mark participant attendance status during the meeting.
- [ ] **Google Calendar / Outlook Sync (.ics Export)**: Generate calendar invite links for participants.

---

## 🔒 7. Security, Auditing & System Settings

- [x] **BCrypt Password Encryption**: Strong hashing for all user credentials in database.
- [x] **Session Authentication Guards**: Automatic redirect to `login.jsp` if session is missing or expired.
- [x] **Login Audit Logs**: Record IP address, timestamp, device/browser, and status (`SUCCESS` / `FAILED`).
- [x] **Security Login Alerts**: Notification sent upon login from a new IP/browser.
- [ ] **Two-Factor Authentication (2FA)**: Optional OTP verification via email for Admin logins.
- [ ] **System Settings UI**: Editable company working hours, late arrival grace period, and default leave quotas.

---

## 🚀 8. Testing, Deployment & Documentation

- [x] **End-to-End Attendance Lifecycle Test**: Automated script verifying Check-in, Break, Resume, and Checkout.
- [x] **Notion Project & Workflow Documentation**: Full engineering wiki ready in `docs/NOTION_PROJECT_AND_WORKFLOW_DOC.md`.
- [ ] **Clean Eclipse Build & Tomcat Deployment**: Clean workspace and verify all JSP views on port 8080.
- [ ] **Database Backup Script**: Automated weekly `mysqldump` script for the `ELAMS` database.
- [ ] **Docker Containerization**: Create `Dockerfile` and `docker-compose.yml` for zero-configuration deployment.
