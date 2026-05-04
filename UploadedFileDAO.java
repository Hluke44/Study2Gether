package dao;

import model.UploadedFile;
import util.DBConnection;

import java.sql.*;
import java.util.*;

public class UploadedFileDAO {

    public boolean save(UploadedFile f) {
        String sql = "INSERT INTO uploaded_files " +
                     "(course_id, title, description, saved_name, original_name, file_size, file_type, uploaded_by) " +
                     "VALUES (?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, f.getCourseId());
            ps.setString(2, f.getTitle());
            ps.setString(3, f.getDescription());
            ps.setString(4, f.getSavedName());
            ps.setString(5, f.getOriginalName());
            ps.setString(6, f.getFileSize());
            ps.setString(7, f.getFileType());
            ps.setString(8, f.getUploadedBy());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<UploadedFile> getAll() {
        List<UploadedFile> list = new ArrayList<>();
        String sql = "SELECT * FROM uploaded_files ORDER BY uploaded_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<UploadedFile> search(String keyword, String type) {
        List<UploadedFile> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT * FROM uploaded_files WHERE 1=1");
        if (keyword != null && !keyword.isBlank())
            sql.append(" AND (title LIKE ? OR description LIKE ? OR original_name LIKE ?)");
        if (type != null && !type.isBlank())
            sql.append(" AND file_type = ?");
        sql.append(" ORDER BY uploaded_at DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.isBlank()) {
                String k = "%" + keyword + "%";
                ps.setString(idx++, k);
                ps.setString(idx++, k);
                ps.setString(idx++, k);
            }
            if (type != null && !type.isBlank())
                ps.setString(idx++, type);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public UploadedFile getBySavedName(String savedName) {
        String sql = "SELECT * FROM uploaded_files WHERE saved_name = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, savedName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean delete(int id, String username) {
        String sql = "DELETE FROM uploaded_files WHERE id = ? AND uploaded_by = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public UploadedFile getById(int id) {
        String sql = "SELECT * FROM uploaded_files WHERE id = ?";
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

    private UploadedFile map(ResultSet rs) throws SQLException {
        return new UploadedFile(
            rs.getInt("id"),
            rs.getInt("course_id"),
            rs.getString("title"),
            rs.getString("description"),
            rs.getString("saved_name"),
            rs.getString("original_name"),
            rs.getString("file_size"),
            rs.getString("file_type"),
            rs.getString("uploaded_by"),
            rs.getString("uploaded_at")
        );
    }
}
