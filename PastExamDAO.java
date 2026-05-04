package dao;

import java.sql.*;
import java.util.*;
import model.PastExam;
import util.DBConnection;

public class PastExamDAO {

    public boolean upload(PastExam e) {
        String sql = "INSERT INTO past_exams(course_id, title, year, type, file_name, saved_name, uploaded_by) " +
                     "VALUES(?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, e.getCourseId());
            ps.setString(2, e.getTitle());
            ps.setString(3, e.getYear());
            ps.setString(4, e.getType());
            ps.setString(5, e.getFileName());    // original name
            ps.setString(6, e.getSavedName());   // disk name
            ps.setString(7, e.getUploadedBy());
            return ps.executeUpdate() > 0;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public List<PastExam> getByCourse(int courseId, String yearFilter, String typeFilter) {
        List<PastExam> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM past_exams WHERE course_id=?");
        if (yearFilter != null && !yearFilter.isEmpty()) sql.append(" AND year=?");
        if (typeFilter != null && !typeFilter.isEmpty()) sql.append(" AND type=?");
        sql.append(" ORDER BY upvotes DESC, upload_date DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, courseId);
            if (yearFilter != null && !yearFilter.isEmpty()) ps.setString(idx++, yearFilter);
            if (typeFilter != null && !typeFilter.isEmpty()) ps.setString(idx++, typeFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public PastExam getById(int id) {
        String sql = "SELECT * FROM past_exams WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void upvote(int examId, String username) {
        String check = "SELECT id FROM exam_upvotes WHERE exam_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(check)) {
            ps.setInt(1, examId);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return;
            }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO exam_upvotes(exam_id, username) VALUES(?,?)")) {
                ps2.setInt(1, examId);
                ps2.setString(2, username);
                ps2.executeUpdate();
            }
            try (PreparedStatement ps3 = con.prepareStatement(
                    "UPDATE past_exams SET upvotes=upvotes+1 WHERE id=?")) {
                ps3.setInt(1, examId);
                ps3.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void delete(int id, String username) {
        String sql = "DELETE FROM past_exams WHERE id=? AND uploaded_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private PastExam map(ResultSet rs) throws SQLException {
        // saved_name may not exist on older rows — fall back gracefully
        String savedName = "";
        try { savedName = rs.getString("saved_name"); } catch (SQLException ignored) {}

        return new PastExam(
            rs.getInt("id"),
            rs.getInt("course_id"),
            rs.getString("title"),
            rs.getString("year"),
            rs.getString("type"),
            rs.getString("file_name"),
            savedName,
            rs.getString("uploaded_by"),
            rs.getInt("upvotes"),
            rs.getString("upload_date")
        );
    }
}
