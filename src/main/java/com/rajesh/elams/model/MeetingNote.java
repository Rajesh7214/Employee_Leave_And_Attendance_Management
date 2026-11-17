package com.rajesh.elams.model;

import java.sql.Timestamp;

public class MeetingNote {
	private int note_id;
	private int meeting_id;
	private String summary;
	private String action_items;
	private int uploaded_by;
	private Timestamp uploaded_at;

	// Populated by joins, not stored on this table
	private String uploaded_by_name;

	public MeetingNote() {

	}

	public MeetingNote(int note_id, int meeting_id, String summary, String action_items, int uploaded_by) {
		super();
		this.note_id = note_id;
		this.meeting_id = meeting_id;
		this.summary = summary;
		this.action_items = action_items;
		this.uploaded_by = uploaded_by;
	}

	public int getNoteId() {
		return note_id;
	}

	public void setNoteId(int note_id) {
		this.note_id = note_id;
	}

	public int getMeetingId() {
		return meeting_id;
	}

	public void setMeetingId(int meeting_id) {
		this.meeting_id = meeting_id;
	}

	public String getSummary() {
		return summary;
	}

	public void setSummary(String summary) {
		this.summary = summary;
	}

	public String getActionItems() {
		return action_items;
	}

	public void setActionItems(String action_items) {
		this.action_items = action_items;
	}

	public int getUploadedBy() {
		return uploaded_by;
	}

	public void setUploadedBy(int uploaded_by) {
		this.uploaded_by = uploaded_by;
	}

	public Timestamp getUploadedAt() {
		return uploaded_at;
	}

	public void setUploadedAt(Timestamp uploaded_at) {
		this.uploaded_at = uploaded_at;
	}

	public String getUploadedByName() {
		return uploaded_by_name;
	}

	public void setUploadedByName(String uploaded_by_name) {
		this.uploaded_by_name = uploaded_by_name;
	}

	@Override
	public String toString() {
		return "MeetingNote [note_id=" + note_id + ", meeting_id=" + meeting_id + ", uploaded_by=" + uploaded_by + "]";
	}

}
