package com.rajesh.elams.model;

public class MeetingAttendanceSummary {

	private int present;
	private int absent;
	private int late;
	private int excused;
	private int notMarked;

	public int getPresent() {
		return present;
	}

	public void setPresent(int present) {
		this.present = present;
	}

	public int getAbsent() {
		return absent;
	}

	public void setAbsent(int absent) {
		this.absent = absent;
	}

	public int getLate() {
		return late;
	}

	public void setLate(int late) {
		this.late = late;
	}

	public int getExcused() {
		return excused;
	}

	public void setExcused(int excused) {
		this.excused = excused;
	}

	public int getNotMarked() {
		return notMarked;
	}

	public void setNotMarked(int notMarked) {
		this.notMarked = notMarked;
	}

	public int getTotal() {
		return present + absent + late + excused + notMarked;
	}
}
