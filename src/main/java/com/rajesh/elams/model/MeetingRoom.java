package com.rajesh.elams.model;

public class MeetingRoom {

	private int roomId;
	private String roomName;
	private String location;
	private Integer capacity;
	private String status; // ACTIVE / INACTIVE

	public MeetingRoom() {
	}

	public MeetingRoom(int roomId, String roomName, String location, Integer capacity, String status) {
		this.roomId = roomId;
		this.roomName = roomName;
		this.location = location;
		this.capacity = capacity;
		this.status = status;
	}

	public int getRoomId() {
		return roomId;
	}

	public void setRoomId(int roomId) {
		this.roomId = roomId;
	}

	public String getRoomName() {
		return roomName;
	}

	public void setRoomName(String roomName) {
		this.roomName = roomName;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public Integer getCapacity() {
		return capacity;
	}

	public void setCapacity(Integer capacity) {
		this.capacity = capacity;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	@Override
	public String toString() {
		return "MeetingRoom [roomId=" + roomId + ", roomName=" + roomName + ", location=" + location + ", capacity="
				+ capacity + ", status=" + status + "]";
	}
}
