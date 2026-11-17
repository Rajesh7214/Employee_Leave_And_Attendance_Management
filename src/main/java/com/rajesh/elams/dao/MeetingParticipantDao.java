package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.MeetingParticipant;

public interface MeetingParticipantDao {

	boolean addParticipant(int meetingId, int employeeId);

	List<MeetingParticipant> getParticipantsByMeeting(int meetingId);

	MeetingParticipant getParticipant(int meetingId, int employeeId);

	boolean updateInvitationStatus(int participantId, String invitationStatus);

	boolean updateAttendance(int participantId, String attendance);

	boolean isDuplicateParticipant(int meetingId, int employeeId);

	List<com.rajesh.elams.model.EmployeeMeetingCount> getEmployeeWiseMeetingCounts();

	List<com.rajesh.elams.model.DepartmentMeetingCount> getDepartmentWiseMeetingCounts();

	com.rajesh.elams.model.MeetingAttendanceSummary getAttendanceSummary();
}
