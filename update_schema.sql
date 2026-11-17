-- ====================================================================
-- Database Schema Update Script for ELAMS
-- Updates existing database tables to include all new columns required by the application
-- ====================================================================

USE ELAMS;

DELIMITER //

DROP PROCEDURE IF EXISTS AddColumnIfNotExists //
CREATE PROCEDURE AddColumnIfNotExists(
    IN dbName VARCHAR(64),
    IN tableName VARCHAR(64),
    IN fieldName VARCHAR(64),
    IN fieldDef VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS
        WHERE table_schema = dbName
          AND table_name = tableName
          AND column_name = fieldName
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE `', tableName, '` ADD COLUMN `', fieldName, '` ', fieldDef);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END //

DELIMITER ;

-- 1. Update `attendance` table
CALL AddColumnIfNotExists('ELAMS', 'attendance', 'break_start', 'TIME NULL');
CALL AddColumnIfNotExists('ELAMS', 'attendance', 'break_end', 'TIME NULL');
CALL AddColumnIfNotExists('ELAMS', 'attendance', 'total_break_minutes', 'INT DEFAULT 0');
CALL AddColumnIfNotExists('ELAMS', 'attendance', 'location', 'VARCHAR(255) DEFAULT \'Office / Remote\'');
CALL AddColumnIfNotExists('ELAMS', 'attendance', 'checkout_location', 'VARCHAR(255) NULL');

-- 2. Update `employees` table
CALL AddColumnIfNotExists('ELAMS', 'employees', 'profile_photo', 'VARCHAR(255) NULL');

-- 3. Update `notifications` table
CALL AddColumnIfNotExists('ELAMS', 'notifications', 'read_at', 'TIMESTAMP NULL');
CALL AddColumnIfNotExists('ELAMS', 'notifications', 'category', 'VARCHAR(50) DEFAULT \'Announcement\'');
CALL AddColumnIfNotExists('ELAMS', 'notifications', 'status', 'VARCHAR(20) DEFAULT \'Unread\'');

-- 4. Create `salary_structure` table if not exists
CREATE TABLE IF NOT EXISTS `salary_structure` (
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

-- 5. Create `payrolls` table if not exists
CREATE TABLE IF NOT EXISTS `payrolls` (
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

-- 6. Create `audit_logs` table if not exists
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

-- 7. Create `login_logs` table if not exists
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

-- 8. Create `system_settings` table if not exists
CREATE TABLE IF NOT EXISTS `system_settings` (
    `setting_id` INT AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `setting_value` VARCHAR(255) NOT NULL,
    `description` VARCHAR(255) NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Insert default system settings if missing
INSERT INTO `system_settings` (`setting_key`, `setting_value`, `description`) VALUES
('company_name', 'SmartOffice Pvt Ltd', 'Primary corporate organization name'),
('working_start_time', '09:00 AM', 'Standard business office check-in time'),
('working_end_time', '06:00 PM', 'Standard business office check-out time'),
('max_breaks', '2', 'Maximum permitted break sessions per employee daily'),
('session_timeout', '30', 'Session inactivity timeout limit in minutes')
ON DUPLICATE KEY UPDATE `setting_value`=VALUES(`setting_value`);

-- 10. Insert HR user & default accounts if missing
INSERT INTO `user` (`email`, `password`, `role`) VALUES
('admin@elams.com', 'admin123', 'Admin'),
('hr@elams.com', 'hr123', 'HR'),
('manager@elams.com', 'manager123', 'Manager'),
('rajesh@elams.com', 'emp123', 'Employee')
ON DUPLICATE KEY UPDATE `email`=`email`;

-- 11. Insert corresponding employee records
INSERT INTO `employees` (`employee_name`, `email`, `phone`, `department`, `designation`) VALUES
('System Administrator', 'admin@elams.com', 9876543210, 'Administration', 'System Admin'),
('Sneha Sharma', 'hr@elams.com', 9876543213, 'Human Resources', 'HR Manager'),
('Project Manager', 'manager@elams.com', 9876543211, 'Engineering', 'Technical Manager'),
('Rajesh Kumar', 'rajesh@elams.com', 9876543212, 'Engineering', 'Software Engineer')
ON DUPLICATE KEY UPDATE `email`=`email`;

-- 12. Seed sample salary structures
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

-- 13. Clean up procedure
DROP PROCEDURE IF EXISTS AddColumnIfNotExists;

-- 14. Verification query
SELECT * FROM `user`;
SELECT * FROM `employees`;
SELECT * FROM `salary_structure`;
SELECT * FROM `payrolls`;
SELECT * FROM `audit_logs`;
SELECT * FROM `system_settings`;
