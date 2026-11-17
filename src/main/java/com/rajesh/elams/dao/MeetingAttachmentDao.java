package com.rajesh.elams.dao;

import java.util.List;
import com.rajesh.elams.model.MeetingAttachment;

public interface MeetingAttachmentDao {
	boolean addAttachment(MeetingAttachment attachment);
	List<MeetingAttachment> getAttachmentsByMeeting(int meetingId);
	boolean deleteAttachment(int attachmentId);
}
