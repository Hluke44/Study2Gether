package dao;

import java.sql.*;
import java.util.*;
import model.StudyGroup;
import util.DBConnection;

public class studyGroupDAO {

    public void createGroup(StudyGroup g) {
        String sql = "INSERT INTO study_group(name, description, max_members, created_by) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, g.getName());
            ps.setString(2, g.getDescription());
            ps.setInt(3, g.getMaxMembers());
            ps.setString(4, g.getCreatedBy());
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public int getMemberCount(int groupId) {
        String sql = "SELECT COUNT(*) FROM group_members WHERE group_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public List<StudyGroup> getAllGroups() {
        List<StudyGroup> list = new ArrayList<>();
        String sql = "SELECT * FROM study_group ORDER BY created DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new StudyGroup(
                    rs.getInt("id"), rs.getString("name"),
                    rs.getString("description"), rs.getInt("max_members"),
                    rs.getString("created_by")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public void deleteGroup(int id, String user) {
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM group_members WHERE group_id=?")) {
                ps.setInt(1, id); ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM study_group WHERE id=? AND created_by=?")) {
                ps.setInt(1, id); ps.setString(2, user); ps.executeUpdate();
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void joinGroup(int groupId, String user) {
        String check = "SELECT id FROM group_members WHERE group_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(check)) {
            ps.setInt(1, groupId); ps.setString(2, user);
            try (ResultSet rs = ps.executeQuery()) { if (rs.next()) return; }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO group_members(group_id, username) VALUES(?,?)")) {
                ps2.setInt(1, groupId); ps2.setString(2, user); ps2.executeUpdate();
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void leaveGroup(int groupId, String user) {
        String sql = "DELETE FROM group_members WHERE group_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId); ps.setString(2, user); ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public boolean isMember(int groupId, String user) {
        String sql = "SELECT id FROM group_members WHERE group_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, groupId); ps.setString(2, user);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
}
