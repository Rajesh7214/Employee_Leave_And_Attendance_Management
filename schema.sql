-- ====================================================================
-- Complete Fresh Database Script for ELAMS (MySQL Workbench Ready)
-- Project: Employee Leave & Attendance Management System (SmartOffice)
-- RDBMS: MySQL 8.0+
-- Database Name: ELAMS
-- ====================================================================

-- 1. Disable foreign key checks to allow dropping/recreating tables safely
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS ELAMS;
USE ELAMS;

-- 2. Drop existing outdated tables so CREATE TABLE applies all new column definitions
DROP TABLE IF EXISTS `payrolls`;
DROP TABLE IF EXISTS `salary_structure`;
DROP TABLE IF EXISTS `meeting_attachments`;
DROP TABLE IF EXISTS `meeting_notes`;
DROP TABLE IF EXISTS `meeting_participants`;
DROP TABLE IF EXISTS `meetings`;
DROP TABLE IF EXISTS `meeting_rooms`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `tasks`;
DROP TABLE IF EXISTS `leaves`;
DROP TABLE IF EXISTS `attendance`;
DROP TABLE IF EXISTS `employees`;
DROP TABLE IF EXISTS `user`;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- --------------------------------------------------------------------
-- 1. Table: user
-- --------------------------------------------------------------------
CREATE TABLE `user` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `role` VARCHAR(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 2. Table: employees
-- --------------------------------------------------------------------
CREATE TABLE `employees` (
    `employee_id` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` BIGINT NULL,
    `department` VARCHAR(50) NULL,
    `designation` VARCHAR(50) NULL,
    `profile_photo` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 3. Table: attendance
-- --------------------------------------------------------------------
CREATE TABLE `attendance` (
    `attendance_id` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT NOT NULL,
    `attendance_date` DATE NOT NULL,
    `check_in` TIME NULL,
    `check_out` TIME NULL,
    `status` VARCHAR(20) DEFAULT 'Present',
    `location` VARCHAR(255) DEFAULT 'Office / Remote',
    `checkout_location` VARCHAR(255) NULL,
    `break_start` TIME NULL,
    `break_end` TIME NULL,
    `total_break_minutes` INT DEFAULT 0,
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 4. Table: leaves
-- --------------------------------------------------------------------
CREATE TABLE `leaves` (
    `leave_id` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT NOT NULL,
    `leave_type` VARCHAR(50) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `reason` TEXT NOT NULL,
    `status` VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 5. Table: tasks
-- --------------------------------------------------------------------
CREATE TABLE `tasks` (
    `task_id` VARCHAR(50) PRIMARY KEY,
    `task_name` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `employee_id` INT NOT NULL,
    `manager_id` VARCHAR(100) NOT NULL,
    `priority` VARCHAR(20) DEFAULT 'MEDIUM',
    `status` VARCHAR(20) DEFAULT 'PENDING',
    `assigned_date` DATE NOT NULL,
    `due_date` DATE NOT NULL,
    `completion_date` DATE NULL,
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 6. Table: notifications
-- --------------------------------------------------------------------
CREATE TABLE `notifications` (
    `notification_id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `sender_id` BIGINT NULL,
    `receiver_id` BIGINT NULL,
    `sender_name` VARCHAR(100) DEFAULT NULL,
    `recipient_type` VARCHAR(20) DEFAULT 'ALL',
    `target_employee_id` INT DEFAULT NULL,
    `title` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `category` VARCHAR(50) DEFAULT 'Announcement',
    `priority` VARCHAR(20) DEFAULT 'Medium',
    `status` VARCHAR(20) DEFAULT 'Unread',
    `is_read` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `read_at` TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 7. Table: meeting_rooms
-- --------------------------------------------------------------------
CREATE TABLE `meeting_rooms` (
    `room_id` INT AUTO_INCREMENT PRIMARY KEY,
    `room_name` VARCHAR(100) NOT NULL,
    `location` VARCHAR(150) NOT NULL,
    `capacity` INT NOT NULL,
    `status` VARCHAR(20) DEFAULT 'Available'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 8. Table: meetings
-- --------------------------------------------------------------------
CREATE TABLE `meetings` (
    `meeting_id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(150) NOT NULL,
    `description` TEXT NULL,
    `agenda` TEXT NULL,
    `organizer_id` INT NOT NULL,
    `meeting_date` DATE NOT NULL,
    `start_time` TIME NOT NULL,
    `end_time` TIME NOT NULL,
    `meeting_type` VARCHAR(50) DEFAULT 'Internal',
    `meeting_mode` VARCHAR(20) DEFAULT 'In-Person',
    `room` VARCHAR(100) NULL,
    `meeting_link` VARCHAR(255) NULL,
    `priority` VARCHAR(20) DEFAULT 'Medium',
    `status` VARCHAR(20) DEFAULT 'SCHEDULED',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`organizer_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 9. Table: meeting_participants
-- --------------------------------------------------------------------
CREATE TABLE `meeting_participants` (
    `participant_id` INT AUTO_INCREMENT PRIMARY KEY,
    `meeting_id` INT NOT NULL,
    `employee_id` INT NOT NULL,
    `invitation_status` VARCHAR(20) DEFAULT 'PENDING',
    `attendance` VARCHAR(20) DEFAULT 'UNKNOWN',
    FOREIGN KEY (`meeting_id`) REFERENCES `meetings`(`meeting_id`) ON DELETE CASCADE,
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 10. Table: meeting_notes
-- --------------------------------------------------------------------
CREATE TABLE `meeting_notes` (
    `note_id` INT AUTO_INCREMENT PRIMARY KEY,
    `meeting_id` INT NOT NULL,
    `author_id` INT NOT NULL,
    `note_content` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`meeting_id`) REFERENCES `meetings`(`meeting_id`) ON DELETE CASCADE,
    FOREIGN KEY (`author_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 11. Table: meeting_attachments
-- --------------------------------------------------------------------
CREATE TABLE `meeting_attachments` (
    `attachment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `meeting_id` INT NOT NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `file_path` VARCHAR(500) NOT NULL,
    `file_type` VARCHAR(50) DEFAULT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    `uploaded_by` INT DEFAULT NULL,
    `uploaded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`meeting_id`) REFERENCES `meetings`(`meeting_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 12. Table: salary_structure
-- --------------------------------------------------------------------
CREATE TABLE `salary_structure` (
    `salary_id` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT NOT NULL UNIQUE,
    `basic_salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `hra` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `transport_allowance` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `medical_allowance` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `other_allowances` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `pf` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `professional_tax` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `loan_deduction` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `other_deductions` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `effective_from` DATE NOT NULL,
    `status` VARCHAR(20) DEFAULT 'ACTIVE',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 13. Table: payrolls
-- --------------------------------------------------------------------
CREATE TABLE `payrolls` (
    `payroll_id` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_id` INT NOT NULL,
    `payroll_month` INT NOT NULL,
    `payroll_year` INT NOT NULL,
    `basic_salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `hra` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `transport_allowance` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `medical_allowance` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `bonus` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `other_allowances` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `gross_salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `pf` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `professional_tax` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `loan_deduction` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `advance_salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `other_deductions` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `working_days` INT NOT NULL DEFAULT 26,
    `present_days` INT NOT NULL DEFAULT 26,
    `paid_leaves` INT NOT NULL DEFAULT 0,
    `unpaid_leaves` INT NOT NULL DEFAULT 0,
    `lop_deduction` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `total_deductions` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `net_salary` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `payment_method` VARCHAR(50) DEFAULT 'Bank Transfer',
    `payment_date` DATE NULL,
    `status` VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    `processed_by` INT NULL,
    `approved_by` INT NULL,
    `remarks` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_emp_month_year` (`employee_id`, `payroll_month`, `payroll_year`),
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 14. Table: audit_logs
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `log_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL,
    `action` VARCHAR(50) NOT NULL,
    `module` VARCHAR(50) NOT NULL,
    `record_id` VARCHAR(50) NULL,
    `description` TEXT NULL,
    `ip_address` VARCHAR(50) NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 15. Table: login_logs
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `login_logs` (
    `login_id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL,
    `action` VARCHAR(20) NOT NULL DEFAULT 'LOGIN',
    `login_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `logout_time` TIMESTAMP NULL,
    `status` VARCHAR(20) DEFAULT 'SUCCESS',
    `ip_address` VARCHAR(50) NULL,
    `user_agent` VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------------------
-- 16. Table: system_settings
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `system_settings` (
    `setting_id` INT AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `setting_value` VARCHAR(255) NOT NULL,
    `description` VARCHAR(255) NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- Initial Seed Data
-- ====================================================================

-- Insert Default Admin & User Accounts (including HR)
INSERT INTO `user` (`email`, `password`, `role`) VALUES
('admin@elams.com', 'admin123', 'Admin'),
('hr@elams.com', 'hr123', 'HR'),
('manager@elams.com', 'manager123', 'Manager'),
('rajesh@elams.com', 'emp123', 'Employee')
ON DUPLICATE KEY UPDATE `email`=`email`;

-- Insert Corresponding Employee Records
INSERT INTO `employees` (`employee_name`, `email`, `phone`, `department`, `designation`) VALUES
('System Administrator', 'admin@elams.com', 9876543210, 'Administration', 'System Admin'),
('Sneha Sharma', 'hr@elams.com', 9876543213, 'Human Resources', 'HR Manager'),
('Project Manager', 'manager@elams.com', 9876543211, 'Engineering', 'Technical Manager'),
('Rajesh Kumar', 'rajesh@elams.com', 9876543212, 'Engineering', 'Software Engineer')
ON DUPLICATE KEY UPDATE `email`=`email`;

-- Insert Sample Salary Structures (Module 11 Example Data)
INSERT INTO `salary_structure` (`employee_id`, `basic_salary`, `hra`, `transport_allowance`, `medical_allowance`, `other_allowances`, `pf`, `professional_tax`, `loan_deduction`, `other_deductions`, `effective_from`, `status`)
SELECT employee_id, 30000.00, 10000.00, 3000.00, 2000.00, 0.00, 3600.00, 200.00, 0.00, 500.00, '2026-08-01', 'ACTIVE'
FROM employees WHERE email='rajesh@elams.com'
ON DUPLICATE KEY UPDATE `basic_salary`=VALUES(`basic_salary`);

INSERT INTO `salary_structure` (`employee_id`, `basic_salary`, `hra`, `transport_allowance`, `medical_allowance`, `other_allowances`, `pf`, `professional_tax`, `loan_deduction`, `other_deductions`, `effective_from`, `status`)
SELECT employee_id, 45000.00, 15000.00, 4000.00, 3000.00, 2000.00, 5400.00, 200.00, 0.00, 500.00, '2026-08-01', 'ACTIVE'
FROM employees WHERE email='manager@elams.com'
ON DUPLICATE KEY UPDATE `basic_salary`=VALUES(`basic_salary`);

INSERT INTO `salary_structure` (`employee_id`, `basic_salary`, `hra`, `transport_allowance`, `medical_allowance`, `other_allowances`, `pf`, `professional_tax`, `loan_deduction`, `other_deductions`, `effective_from`, `status`)
SELECT employee_id, 35000.00, 12000.00, 3500.00, 2500.00, 1000.00, 4200.00, 200.00, 0.00, 500.00, '2026-08-01', 'ACTIVE'
FROM employees WHERE email='hr@elams.com'
ON DUPLICATE KEY UPDATE `basic_salary`=VALUES(`basic_salary`);

-- Insert Sample Meeting Rooms
INSERT INTO `meeting_rooms` (`room_name`, `location`, `capacity`, `status`) VALUES
('Conference Room A', 'Floor 1, Block West', 12, 'Available'),
('Boardroom B', 'Floor 3, Executive Suite', 20, 'Available'),
('Innovation Lab', 'Floor 2, Tech Hub', 8, 'Available')
ON DUPLICATE KEY UPDATE `room_name`=`room_name`;

-- Insert Initial System Settings
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `description`) VALUES
('company_name', 'SmartOffice Pvt Ltd', 'Primary corporate organization name'),
('working_start_time', '09:00 AM', 'Standard business office check-in time'),
('working_end_time', '06:00 PM', 'Standard business office check-out time'),
('max_breaks', '2', 'Maximum permitted break sessions per employee daily'),
('session_timeout', '30', 'Session inactivity timeout limit in minutes')
ON DUPLICATE KEY UPDATE `setting_value`=VALUES(`setting_value`);

-- Select queries to display data immediately in MySQL Workbench
SELECT * FROM `salary_structure`;
SELECT * FROM `payrolls`;
SELECT * FROM `employees`;
