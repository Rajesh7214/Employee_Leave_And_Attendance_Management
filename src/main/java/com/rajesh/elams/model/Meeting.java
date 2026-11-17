package com.rajesh.elams.model;

import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;

public class Meeting {
	private int meeting_id;
	private String title;
	private String description;
	private String agenda;
	private int organizer_id;
	private Date meeting_date;
	private Time start_time;
	private Time end_time;
	private String meeting_type;
	private MeetingMode meeting_mode;
	private String room;
	private String meeting_link;
	private String priority;
	private MeetingStatus status;
	private Timestamp created_at;

	// Populated by joins, not stored on this table
	private String organizer_name;

	public Meeting() {

	}

	public Meeting(int meeting_id, String title, String description, String agenda, int organizer_id, Date meeting_date,
			Time start_time, Time end_time, String meeting_type, MeetingMode meeting_mode, String room,
			String meeting_link, String priority, MeetingStatus status) {
		super();
		this.meeting_id = meeting_id;
		this.title = title;
		this.description = description;
		this.agenda = agenda;
		this.organizer_id = organizer_id;
		this.meeting_date = meeting_date;
		this.start_time = start_time;
		this.end_time = end_time;
		this.meeting_type = meeting_type;
		this.meeting_mode = meeting_mode;
		this.room = room;
		this.meeting_link = meeting_link;
		this.priority = priority;
		this.status = status;
	}

	public int getMeetingId() {
		return meeting_id;
	}

	public void setMeetingId(int meeting_id) {
		this.meeting_id = meeting_id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getAgenda() {
		return agenda;
	}

	public void setAgenda(String agenda) {
		this.agenda = agenda;
	}

	public int getOrganizerId() {
		return organizer_id;
	}

	public void setOrganizerId(int organizer_id) {
		this.organizer_id = organizer_id;
	}

	public Date getMeetingDate() {
		return meeting_date;
	}

	public void setMeetingDate(Date meeting_date) {
		this.meeting_date = meeting_date;
	}

	public Time getStartTime() {
		return start_time;
	}

	public void setStartTime(Time start_time) {
		this.start_time = start_time;
	}

	public Time getEndTime() {
		return end_time;
	}

	public void setEndTime(Time end_time) {
		this.end_time = end_time;
	}

	public String getMeetingType() {
		return meeting_type;
	}

	public void setMeetingType(String meeting_type) {
		this.meeting_type = meeting_type;
	}

	public MeetingMode getMeetingMode() {
		return meeting_mode;
	}

	public void setMeetingMode(MeetingMode meeting_mode) {
		this.meeting_mode = meeting_mode;
	}

	public String getRoom() {
		return room;
	}

	public void setRoom(String room) {
		this.room = room;
	}

	public String getMeetingLink() {
		return meeting_link;
	}

	public void setMeetingLink(String meeting_link) {
		this.meeting_link = meeting_link;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(String priority) {
		this.priority = priority;
	}

	public MeetingStatus getStatus() {
		return status;
	}

	public void setStatus(MeetingStatus status) {
		this.status = status;
	}

	public Timestamp getCreatedAt() {
		return created_at;
	}

	public void setCreatedAt(Timestamp created_at) {
		this.created_at = created_at;
	}

	public String getOrganizerName() {
		return organizer_name;
	}

	public void setOrganizerName(String organizer_name) {
		this.organizer_name = organizer_name;
	}

	@Override
	public String toString() {
		return "Meeting [meeting_id=" + meeting_id + ", title=" + title + ", organizer_id=" + organizer_id
				+ ", meeting_date=" + meeting_date + ", start_time=" + start_time + ", end_time=" + end_time
				+ ", meeting_type=" + meeting_type + ", meeting_mode=" + meeting_mode + ", status=" + status + "]";
	}

}
