package dao;

import java.sql.*;
import java.util.*;
import model.Deadline;
import util.DBConnection;

public class DeadlineDAO {

    public boolean add(Deadline d) {
        String sql = "INSERT INTO deadlines(course_id, title, due_date, type, added_by) VALUES(?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, d.getCourseId());
            ps.setString(2, d.getTitle());
            ps.setString(3, d.getDueDate());
            ps.setString(4, d.getType());
            ps.setString(5, d.getAddedBy());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Deadline> getByUser(String username) {
        List<Deadline> list = new ArrayList<>();
        String sql = "SELECT d.*, c.name AS course_name FROM deadlines d " +
                     "LEFT JOIN courses c ON d.course_id=c.id " +
                     "WHERE d.added_by=? ORDER BY d.due_date ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void toggleDone(int id, String username) {
        String sql = "UPDATE deadlines SET done = NOT done WHERE id=? AND added_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id, String username) {
        String sql = "DELETE FROM deadlines WHERE id=? AND added_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Deadline map(ResultSet rs) throws SQLException {
        return new Deadline(
            rs.getInt("id"),
            rs.getInt("course_id"),
            rs.getString("course_name"),
            rs.getString("title"),
            rs.getString("due_date"),
            rs.getString("type"),
            rs.getString("added_by"),
            rs.getBoolean("done")
        );
    }
}
