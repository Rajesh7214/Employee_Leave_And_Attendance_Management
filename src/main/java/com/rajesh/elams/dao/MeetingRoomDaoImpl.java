package com.rajesh.elams.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.rajesh.elams.model.MeetingRoom;
import com.rajesh.elams.util.DbUtil;

public class MeetingRoomDaoImpl implements MeetingRoomDao {

	public MeetingRoomDaoImpl() {
		ensureTableExists();
	}

	private void ensureTableExists() {
		String ddl = "CREATE TABLE IF NOT EXISTS meeting_rooms ("
				+ "room_id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "room_name VARCHAR(100) NOT NULL, "
				+ "location VARCHAR(150), "
				+ "capacity INT DEFAULT 10, "
				+ "status VARCHAR(30) DEFAULT 'AVAILABLE'"
				+ ")";
		try (Connection conn = DbUtil.getConnection(); java.sql.Statement stmt = conn.createStatement()) {
			stmt.executeUpdate(ddl);
		} catch (Exception ignored) {}
	}

	@Override
	public int createRoom(MeetingRoom room) {

		String sql = "INSERT INTO meeting_rooms(room_name, location, capacity, status) VALUES(?,?,?,?)";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

			ps.setString(1, room.getRoomName());
			ps.setString(2, room.getLocation());

			if (room.getCapacity() != null) {
				ps.setInt(3, room.getCapacity());
			} else {
				ps.setNull(3, java.sql.Types.INTEGER);
			}

			ps.setString(4, room.getStatus() == null ? "ACTIVE" : room.getStatus());

			int affected = ps.executeUpdate();

			if (affected > 0) {
				ResultSet keys = ps.getGeneratedKeys();
				if (keys.next()) {
					return keys.getInt(1);
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return -1;
	}

	@Override
	public boolean updateRoom(MeetingRoom room) {

		String sql = "UPDATE meeting_rooms SET room_name=?, location=?, capacity=?, status=? WHERE room_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, room.getRoomName());
			ps.setString(2, room.getLocation());

			if (room.getCapacity() != null) {
				ps.setInt(3, room.getCapacity());
			} else {
				ps.setNull(3, java.sql.Types.INTEGER);
			}

			ps.setString(4, room.getStatus());
			ps.setInt(5, room.getRoomId());

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public boolean deleteRoom(int roomId) {

		String sql = "DELETE FROM meeting_rooms WHERE room_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, roomId);

			return ps.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	@Override
	public MeetingRoom getRoomById(int roomId) {

		MeetingRoom room = null;

		String sql = "SELECT * FROM meeting_rooms WHERE room_id=?";

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, roomId);

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				room = mapRow(rs);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return room;
	}

	@Override
	public List<MeetingRoom> getAllRooms() {

		List<MeetingRoom> list = new ArrayList<>();

		String sql = "SELECT * FROM meeting_rooms ORDER BY room_name";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				list.add(mapRow(rs));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public List<MeetingRoom> getActiveRooms() {

		List<MeetingRoom> list = new ArrayList<>();

		String sql = "SELECT * FROM meeting_rooms WHERE status='ACTIVE' ORDER BY room_name";

		try (Connection con = DbUtil.getConnection();
				PreparedStatement ps = con.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				list.add(mapRow(rs));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return list;
	}

	@Override
	public boolean isDuplicateRoomName(String roomName, Integer excludeRoomId) {

		String sql = "SELECT COUNT(*) FROM meeting_rooms WHERE room_name=?"
				+ (excludeRoomId != null ? " AND room_id <> ?" : "");

		try (Connection con = DbUtil.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setString(1, roomName);

			if (excludeRoomId != null) {
				ps.setInt(2, excludeRoomId);
			}

			ResultSet rs = ps.executeQuery();

			if (rs.next()) {
				return rs.getInt(1) > 0;
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return false;
	}

	private MeetingRoom mapRow(ResultSet rs) throws Exception {

		MeetingRoom room = new MeetingRoom();

		room.setRoomId(rs.getInt("room_id"));
		room.setRoomName(rs.getString("room_name"));
		room.setLocation(rs.getString("location"));

		int capacity = rs.getInt("capacity");
		room.setCapacity(rs.wasNull() ? null : capacity);

		room.setStatus(rs.getString("status"));

		return room;
	}
}