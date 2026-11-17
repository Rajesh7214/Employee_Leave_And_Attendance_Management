package com.rajesh.elams.model;

public class MeetingParticipant {
	private int participant_id;
	private int meeting_id;
	private int employee_id;
	private InvitationStatus invitation_status;
	private MeetingAttendanceStatus attendance;

	// Populated by joins, not stored on this table
	private String employee_name;
	private String employee_email;

	public MeetingParticipant() {

	}

	public MeetingParticipant(int participant_id, int meeting_id, int employee_id, InvitationStatus invitation_status,
			MeetingAttendanceStatus attendance) {
		super();
		this.participant_id = participant_id;
		this.meeting_id = meeting_id;
		this.employee_id = employee_id;
		this.invitation_status = invitation_status;
		this.attendance = attendance;
	}

	public int getParticipantId() {
		return participant_id;
	}

	public void setParticipantId(int participant_id) {
		this.participant_id = participant_id;
	}

	public int getMeetingId() {
		return meeting_id;
	}

	public void setMeetingId(int meeting_id) {
		this.meeting_id = meeting_id;
	}

	public int getEmployeeId() {
		return employee_id;
	}

	public void setEmployeeId(int employee_id) {
		this.employee_id = employee_id;
	}

	public InvitationStatus getInvitationStatus() {
		return invitation_status;
	}

	public void setInvitationStatus(InvitationStatus invitation_status) {
		this.invitation_status = invitation_status;
	}

	public MeetingAttendanceStatus getAttendance() {
		return attendance;
	}

	public void setAttendance(MeetingAttendanceStatus attendance) {
		this.attendance = attendance;
	}

	public String getEmployeeName() {
		return employee_name;
	}

	public void setEmployeeName(String employee_name) {
		this.employee_name = employee_name;
	}

	public String getEmployeeEmail() {
		return employee_email;
	}

	public void setEmployeeEmail(String employee_email) {
		this.employee_email = employee_email;
	}

	@Override
	public String toString() {
		return "MeetingParticipant [participant_id=" + participant_id + ", meeting_id=" + meeting_id + ", employee_id="
				+ employee_id + ", invitation_status=" + invitation_status + ", attendance=" + attendance + "]";
	}

}
