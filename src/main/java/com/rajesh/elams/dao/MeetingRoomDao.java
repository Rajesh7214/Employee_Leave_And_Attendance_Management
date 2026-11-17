package com.rajesh.elams.dao;

import java.util.List;

import com.rajesh.elams.model.MeetingRoom;

public interface MeetingRoomDao {

	int createRoom(MeetingRoom room);

	boolean updateRoom(MeetingRoom room);

	boolean deleteRoom(int roomId);

	MeetingRoom getRoomById(int roomId);

	List<MeetingRoom> getAllRooms();

	List<MeetingRoom> getActiveRooms();

	boolean isDuplicateRoomName(String roomName, Integer excludeRoomId);
}
