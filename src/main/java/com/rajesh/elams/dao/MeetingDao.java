package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.Meeting;

public interface MeetingDao {

	int createMeeting(Meeting meeting);

	boolean updateMeeting(Meeting meeting);

	boolean deleteMeeting(int meetingId);

	Meeting getMeetingById(int meetingId);

	List<Meeting> getAllMeetings();

	List<Meeting> searchMeetings(String search, String status, String meetingType, String priority, String date);

	List<Meeting> getMeetingsByEmployee(int employeeId);

	List<Meeting> getMeetingsByOrganizer(int organizerId);

	boolean updateMeetingStatus(int meetingId, String status);

	boolean hasRoomConflict(String room, String meetingDate, String startTime, String endTime,
			Integer excludeMeetingId);

	int totalMeetings();

	int upcomingMeetingsCount();

	int completedMeetingsCount();

	int cancelledMeetingsCount();

	List<Meeting> getMeetingsBetweenDates(String fromDate, String toDate);

	List<Meeting> getMissedMeetings();

	List<com.rajesh.elams.model.MeetingTypeDuration> getDurationAnalysis();
}
