package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.MeetingNote;

public interface MeetingNoteDao {

	boolean addNote(MeetingNote note);

	List<MeetingNote> getNotesByMeeting(int meetingId);
}
