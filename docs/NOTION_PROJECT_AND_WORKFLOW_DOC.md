# 🏢 Employee Leave & Attendance Management System (ELAMS)
> **Comprehensive System Documentation, Architecture & Operational Workflows**  
> *Ready to import or paste directly into your Notion workspace.*

---

## 📌 Executive Summary
**ELAMS (Employee Leave & Attendance Management System)** is an enterprise-grade web application built to streamline human resource operations, attendance tracking, multi-tier leave approval workflows, automated payroll computations, task allocations, and corporate meeting management.

### Key Highlights
* **Zero Overhead Stack**: Jakarta EE 10 (Servlet 6.0 / JSP), Apache Tomcat 10.1, MySQL 8.0+.
* **Security & Compliance**: BCrypt cryptographic hashing, session-based RBAC, real-time login audit trails, and enterprise IP/geo-logging.
* **Integrated Business Logic**: Attendance & unpaid leave (LOP) directly link into automated payroll calculations.

---

## 🏗️ Architecture & Technology Stack

```mermaid
graph TD
    Client["🌐 Client Browser (Desktop / Mobile)"]
    Tomcat["⚙️ Apache Tomcat 10.1 (Jakarta EE Container)"]
    Servlets["🚦 Controller Layer (Servlets & Filters)"]
    DAO["💾 Data Access Layer (DAO & DbUtil)"]
    DB[("🗄️ MySQL 8.0 Database (ELAMS)")]
    Mail["📧 SMTP / Jakarta Mail Service"]

    Client -->|HTTP / HTTPS Requests| Tomcat
    Tomcat --> Servlets
    Servlets --> DAO
    Servlets --> Mail
    DAO -->|JDBC Connection Pool| DB
```

| Layer | Technologies & Libraries |
| :--- | :--- |
| **Presentation Layer** | JSP 3.1, JSTL, HTML5, CSS3 Glassmorphism, FontAwesome 6.6, Vanilla JavaScript (Real-time timers) |
| **Controller Layer** | Jakarta EE 10 (`jakarta.servlet.http.HttpServlet`, `@WebServlet`), Dynamic Session Management |
| **Service & Business Layer** | `NotificationService`, `AuditService`, `PayrollCalculationService` |
| **Persistence Layer** | DAO Pattern (`*Dao` interfaces & `*DaoImpl` JDBC implementations), `DbUtil` connection management |
| **Database** | MySQL 8.0+ (InnoDB Engine, Foreign Key cascading, transaction integrity) |
| **Security & Utilities** | `jBCrypt-0.4` password hashing, `angus-mail-2.1.0` email dispatcher |

---

## 👥 Role-Based Access Control (RBAC) Matrix

| Feature / Module | Admin | HR Manager | Team Manager | Employee |
| :--- | :---: | :---: | :---: | :---: |
| **Punch In / Out & Break Tracking** | ✅ | ✅ | ✅ | ✅ |
| **View Personal Attendance History** | ✅ | ✅ | ✅ | ✅ |
| **View All Employees Attendance** | ✅ | ✅ | ✅ (Team) | ❌ |
| **Apply for Leave** | ✅ | ✅ | ✅ | ✅ |
| **Approve / Reject Leave Applications** | ✅ | ✅ | ✅ | ❌ |
| **Employee Directory (Create / Edit)** | ✅ | ✅ | ❌ | ❌ |
| **Task Assignment & Tracking** | ✅ | ❌ | ✅ | ✅ (View/Update) |
| **Schedule Meetings & Reserve Rooms** | ✅ | ✅ | ✅ | ❌ |
| **Generate & Process Payroll (with LOP)** | ✅ | ✅ | ❌ | ❌ |
| **View Personal Payslips** | ✅ | ✅ | ✅ | ✅ |
| **Audit Logs & System Settings** | ✅ | ❌ | ❌ | ❌ |

---

## 🔄 End-to-End System Workflows

### 1. Attendance & Duty Session Workflow
```mermaid
sequenceDiagram
    autonumber
    actor Emp as Employee
    participant UI as attendance.jsp
    participant Servlet as AttendanceServlet / MarkCheckout
    participant DAO as AttendanceDaoImpl
    participant DB as MySQL DB

    Emp->>UI: Opens Attendance Portal
    UI->>DAO: Check today's status
    DAO-->>UI: Return attendance record

    alt Punch In
        Emp->>UI: Clicks "Login"
        UI->>Servlet: POST /markAttendance (location, timestamp)
        Servlet->>DAO: markAttendance(attendance)
        Note over DAO: Validates duplicate & evaluates "Late" if after 10:00 AM
        DAO->>DB: INSERT into attendance
        Servlet-->>UI: Redirect to attendance.jsp (Status: Logged In)
    else Break Session
        Emp->>UI: Clicks "Start Break"
        UI->>Servlet: GET /startBreak
        Servlet->>DAO: startBreak(empId, date, time)
        DAO->>DB: UPDATE attendance SET break_start=NOW(), break_end=NULL
        Servlet-->>UI: Live timer pauses & Break timer activates
        Emp->>UI: Clicks "Resume"
        UI->>Servlet: GET /endBreak
        Servlet->>DAO: endBreak(empId, date, time)
        DAO->>DB: UPDATE break_end and accumulate total_break_minutes
    else Punch Out
        Emp->>UI: Clicks "Logout"
        UI->>Servlet: POST /markCheckout
        Servlet->>DAO: markCheckout(...)
        Note over DAO: Closes any active open break automatically
        DAO->>DB: UPDATE check_out, status (Overtime / Early Leave)
        Servlet-->>UI: Status updated to Logged Out
    end
```

---

### 2. Leave Request & Approval Lifecycle
```mermaid
flowchart TD
    A["Employee submits Leave Request<br/>(Dates, Type: Casual/Sick/LOP, Reason)"] --> B{"Manager / HR Review"}
    B -->|Approved| C["Status updated to 'Approved'"]
    B -->|Rejected| D["Status updated to 'Rejected' (Reason recorded)"]
    C --> E["Deduct from Leave Balance"]
    C --> F{"Is Leave Type 'Loss of Pay' (LOP)?"}
    F -->|Yes| G["Flag unpaid days for current Payroll Cycle"]
    F -->|No| H["Standard paid leave logged"]
    G --> I["Payroll Engine auto-deducts LOP per-day salary"]
    D --> J["Notify Employee via System & Email"]
    E --> J
```

---

### 3. Payroll Calculation & Deduction Flow
* **Gross Salary Formula**:
  $$\text{Gross Salary} = \text{Basic} + \text{HRA} + \text{Transport} + \text{Medical} + \text{Other Allowances}$$
* **Loss of Pay (LOP) Deduction**:
  $$\text{Per Day Salary} = \frac{\text{Gross Salary}}{\text{Working Days in Month (e.g. 26)}}$$
  $$\text{LOP Deduction} = \text{Per Day Salary} \times \text{Approved Unpaid Leave Days}$$
* **Statutory Deductions**:
  $$\text{Total Deductions} = \text{PF} + \text{Professional Tax} + \text{LOP Deduction} + \text{Loan Deductions}$$
* **Net Salary Paid**:
  $$\text{Net Salary} = \text{Gross Salary} - \text{Total Deductions}$$

---

## 🗄️ Database Schema Overview (Core Tables)

```mermaid
erDiagram
    USER ||--|| EMPLOYEES : "has profile"
    EMPLOYEES ||--o{ ATTENDANCE : "logs daily"
    EMPLOYEES ||--o{ LEAVES : "applies"
    EMPLOYEES ||--o{ TASKS : "assigned to"
    EMPLOYEES ||--o{ PAYROLLS : "receives"
    EMPLOYEES ||--o{ SALARY_STRUCTURE : "configured"
    MEETINGS ||--o{ MEETING_PARTICIPANTS : "attends"
    EMPLOYEES ||--o{ MEETING_PARTICIPANTS : "participates"

    EMPLOYEES {
        int employee_id PK
        string employee_name
        string email
        string phone
        string department
        string designation
    }

    ATTENDANCE {
        int attendance_id PK
        int employee_id FK
        date attendance_date
        time check_in
        time check_out
        time break_start
        time break_end
        int total_break_minutes
        string status
        string location
        string checkout_location
    }

    LEAVES {
        int leave_id PK
        int employee_id FK
        date start_date
        date end_date
        string leave_type
        string status
        string reason
    }

    PAYROLLS {
        int payroll_id PK
        int employee_id FK
        int salary_month
        int salary_year
        decimal gross_salary
        decimal net_salary
        decimal unpaid_leave_deduction
        string status
    }
```

---

## 🚀 Deployment & Local Execution Guide

### Prerequisites
* Java JDK 17+ (or JDK 21 / 26)
* Apache Tomcat 10.1+
* MySQL Server 8.0+

### Step-by-Step Setup
1. **Database Setup**:
   ```sql
   CREATE DATABASE ELAMS;
   USE ELAMS;
   SOURCE schema.sql;
   ```
2. **Database Credentials**:
   Verify `src/main/java/com/rajesh/elams/util/DbUtil.java`:
   ```java
   url = "jdbc:mysql://localhost:3306/ELAMS";
   user = "root";
   pwd  = "root"; // your mysql password
   ```
3. **Run via Eclipse / IDE**:
   * Right-click `Employee_Leave_And_Attendance_Management` → **Run As** → **Run on Server** (Apache Tomcat v10.1).
   * URL: `http://localhost:8080/Employee_Leave_And_Attendance_Management/login.jsp`

---

## 📋 Recommended Notion Structure
When importing this document into Notion:
1. **Create a Top-Level Page**: `ELAMS - Engineering & Product Wiki`.
2. **Sub-Pages**:
   * 📊 **Dashboard & Metrics Tracker**
   * ⏱️ **Attendance & Break Engine Spec**
   * 🌴 **Leave & LOP Policy Guide**
   * 💰 **Payroll Math & Statutory Formulas**
   * 🗃️ **Database Dictionary (DDL & ERD)**
