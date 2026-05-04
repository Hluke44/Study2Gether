package dao;

import java.sql.*;
import java.util.*;
import model.Course;
import util.DBConnection;

public class CourseDAO {

    public boolean createCourse(Course c) {
        String sql = "INSERT INTO courses(code, name, lecturer, semester, created_by, description) VALUES(?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getCode());
            ps.setString(2, c.getName());
            ps.setString(3, c.getLecturer());
            ps.setString(4, c.getSemester());
            ps.setString(5, c.getCreatedBy());
            ps.setString(6, c.getDescription());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Course> getAllCourses() {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT * FROM courses ORDER BY code";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Course getCourseById(int id) {
        String sql = "SELECT * FROM courses WHERE id=?";
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

    public boolean enrollStudent(int courseId, String username) {
        String check = "SELECT id FROM course_enrollments WHERE course_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(check)) {
            ps.setInt(1, courseId);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return false; // already enrolled
            }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO course_enrollments(course_id, username) VALUES(?,?)")) {
                ps2.setInt(1, courseId);
                ps2.setString(2, username);
                ps2.executeUpdate();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void unenrollStudent(int courseId, String username) {
        String sql = "DELETE FROM course_enrollments WHERE course_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isEnrolled(int courseId, String username) {
        String sql = "SELECT id FROM course_enrollments WHERE course_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getEnrollmentCount(int courseId) {
        String sql = "SELECT COUNT(*) FROM course_enrollments WHERE course_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Course> getEnrolledCourses(String username) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.* FROM courses c JOIN course_enrollments e ON c.id=e.course_id WHERE e.username=? ORDER BY c.code";
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

    public void deleteCourse(int id, String username) {
        String sql = "DELETE FROM courses WHERE id=? AND created_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Course map(ResultSet rs) throws SQLException {
        return new Course(
            rs.getInt("id"),
            rs.getString("code"),
            rs.getString("name"),
            rs.getString("lecturer"),
            rs.getString("semester"),
            rs.getString("created_by"),
            rs.getString("description")
        );
    }
}
