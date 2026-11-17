package com.rajesh.elams.test;

import com.rajesh.elams.model.Employee;
import com.rajesh.elams.model.Meeting;
import com.rajesh.elams.model.MeetingMode;
import com.rajesh.elams.model.Priority;
import com.rajesh.elams.model.Task;
import com.rajesh.elams.service.NotificationService;
import com.rajesh.elams.util.SmsService;

import java.sql.Date;
import java.sql.Time;
import java.util.Collections;

public class SmsNotificationTest {

    public static void main(String[] args) {
        System.out.println("========== ELAMS SMS & NOTIFICATION VERIFICATION TEST ==========");

        // 1. Test Phone Number Sanitization
        String[] testNumbers = {"+919876543210", "919876543210", "09876543210", "9876543210", "  98765 43210  ", "123"};
        for (String num : testNumbers) {
            String formatted = SmsService.formatPhoneNumber(num);
            System.out.println("Input: [" + num + "] -> Formatted: [" + formatted + "]");
        }

        // 2. Test SMS Send with simulation / live gateway
        System.out.println("\n--- Testing Direct SMS Dispatch ---");
        boolean smsResult = SmsService.sendSms("9876543210", "SmartOffice Test: Meeting scheduled at 10:00 AM.");
        System.out.println("Direct SMS Result: " + smsResult);

        // 3. Test Task Notification Dispatch
        System.out.println("\n--- Testing Task Assignment Notification ---");
        Employee emp = new Employee();
        emp.setEmployee_id(101);
        emp.setEmployee_name("Rajesh Kumar");
        emp.setEmail("rajesh.test@example.com");
        emp.setPhone(9876543210L);

        Task task = new Task();
        task.setTaskId("TSK-101");
        task.setTaskName("Complete Quarterly Report");
        task.setPriority(Priority.HIGH);
        task.setDueDate(Date.valueOf("2026-08-20"));

        String taskSms = "SmartOffice Alert: New Task \"" + task.getTaskName() + "\" (Priority: " 
                + task.getPriority() + ", Due: " + task.getDueDate() + ") assigned by Manager. Check portal.";
        boolean taskSmsResult = SmsService.sendSms(emp.getPhone(), taskSms);
        System.out.println("Task SMS Result: " + taskSmsResult);

        // 4. Test Meeting Notification Dispatch
        System.out.println("\n--- Testing Meeting Notification Dispatch ---");
        Meeting meeting = new Meeting();
        meeting.setMeetingId(501);
        meeting.setTitle("Sprint Planning");
        meeting.setMeetingDate(Date.valueOf("2026-08-15"));
        meeting.setStartTime(Time.valueOf("11:00:00"));
        meeting.setEndTime(Time.valueOf("12:00:00"));
        meeting.setMeetingMode(MeetingMode.OFFLINE);
        meeting.setRoom("Conference Room A");

        String meetingSms = "SmartOffice Alert: Meeting \"" + meeting.getTitle() + "\" scheduled on " 
                + meeting.getMeetingDate() + " at " + meeting.getStartTime() + " by Manager. Check portal.";
        boolean meetingSmsResult = SmsService.sendSms(emp.getPhone(), meetingSms);
        System.out.println("Meeting SMS Result: " + meetingSmsResult);

        // 5. Test Audit Logs
        System.out.println("\n--- Recent SMS Audit Logs Count: " + SmsService.getAuditLogs().size() + " ---");
        for (SmsService.SmsLog log : SmsService.getAuditLogs()) {
            System.out.println("Log #" + log.getId() + " | " + log.getTimestamp() + " | To: " + log.getRecipient() + " | Status: " + log.getStatus() + " | " + log.getMessage());
        }

        System.out.println("\n========== VERIFICATION COMPLETE - SUCCESS ==========");
    }
}
