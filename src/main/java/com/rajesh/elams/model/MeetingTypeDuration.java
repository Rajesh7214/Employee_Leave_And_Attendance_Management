package com.rajesh.elams.model;

public class MeetingTypeDuration {

	private String meetingType;
	private int meetingCount;
	private double avgDurationMinutes;

	public MeetingTypeDuration() {
	}

	public MeetingTypeDuration(String meetingType, int meetingCount, double avgDurationMinutes) {
		this.meetingType = meetingType;
		this.meetingCount = meetingCount;
		this.avgDurationMinutes = avgDurationMinutes;
	}

	public String getMeetingType() {
		return meetingType;
	}

	public void setMeetingType(String meetingType) {
		this.meetingType = meetingType;
	}

	public int getMeetingCount() {
		return meetingCount;
	}

	public void setMeetingCount(int meetingCount) {
		this.meetingCount = meetingCount;
	}

	public double getAvgDurationMinutes() {
		return avgDurationMinutes;
	}

	public void setAvgDurationMinutes(double avgDurationMinutes) {
		this.avgDurationMinutes = avgDurationMinutes;
	}
}
