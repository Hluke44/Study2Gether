package dao;

import java.sql.*;
import java.util.*;
import model.Answer;
import model.Question;
import util.DBConnection;

public class QuestionDAO {

    // ── QUESTIONS ──────────────────────────────────────────────────────────────

    public int postQuestion(Question q) {
        String sql = "INSERT INTO questions(course_id, title, body, asked_by, urgent) VALUES(?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, q.getCourseId());
            ps.setString(2, q.getTitle());
            ps.setString(3, q.getBody());
            ps.setString(4, q.getAskedBy());
            ps.setBoolean(5, q.isUrgent());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<Question> getByCourse(int courseId) {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q.*, (SELECT COUNT(*) FROM answers a WHERE a.question_id=q.id) AS ans_count " +
                     "FROM questions q WHERE q.course_id=? ORDER BY q.urgent DESC, q.upvotes DESC, q.asked_date DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Question q = mapQ(rs);
                    q.setAnswerCount(rs.getInt("ans_count"));
                    list.add(q);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Question> getAllRecent() {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q.*, (SELECT COUNT(*) FROM answers a WHERE a.question_id=q.id) AS ans_count " +
                     "FROM questions q ORDER BY q.urgent DESC, q.asked_date DESC LIMIT 20";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Question q = mapQ(rs);
                q.setAnswerCount(rs.getInt("ans_count"));
                list.add(q);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Question getById(int id) {
        String sql = "SELECT q.*, (SELECT COUNT(*) FROM answers a WHERE a.question_id=q.id) AS ans_count FROM questions q WHERE q.id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Question q = mapQ(rs);
                    q.setAnswerCount(rs.getInt("ans_count"));
                    return q;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void upvoteQuestion(int questionId, String username) {
        String check = "SELECT id FROM question_upvotes WHERE question_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(check)) {
            ps.setInt(1, questionId);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return;
            }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO question_upvotes(question_id,username) VALUES(?,?)")) {
                ps2.setInt(1, questionId);
                ps2.setString(2, username);
                ps2.executeUpdate();
            }
            try (PreparedStatement ps3 = con.prepareStatement(
                    "UPDATE questions SET upvotes=upvotes+1 WHERE id=?")) {
                ps3.setInt(1, questionId);
                ps3.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteQuestion(int id, String username) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM questions WHERE id=? AND asked_by=?")) {
            ps.setInt(1, id);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── ANSWERS ────────────────────────────────────────────────────────────────

    public void postAnswer(Answer a) {
        String sql = "INSERT INTO answers(question_id, body, answered_by) VALUES(?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, a.getQuestionId());
            ps.setString(2, a.getBody());
            ps.setString(3, a.getAnsweredBy());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Answer> getAnswers(int questionId) {
        List<Answer> list = new ArrayList<>();
        String sql = "SELECT * FROM answers WHERE question_id=? ORDER BY accepted DESC, upvotes DESC, answered_date ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapA(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void upvoteAnswer(int answerId, String username) {
        String check = "SELECT id FROM answer_upvotes WHERE answer_id=? AND username=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(check)) {
            ps.setInt(1, answerId);
            ps.setString(2, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return;
            }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO answer_upvotes(answer_id,username) VALUES(?,?)")) {
                ps2.setInt(1, answerId);
                ps2.setString(2, username);
                ps2.executeUpdate();
            }
            try (PreparedStatement ps3 = con.prepareStatement(
                    "UPDATE answers SET upvotes=upvotes+1 WHERE id=?")) {
                ps3.setInt(1, answerId);
                ps3.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void acceptAnswer(int answerId, int questionId, String questionOwner) {
        // Only question asker can accept
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE answers SET accepted=0 WHERE question_id=?")) {
                ps.setInt(1, questionId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "UPDATE answers SET accepted=1 WHERE id=? AND question_id IN (SELECT id FROM questions WHERE id=? AND asked_by=?)")) {
                ps2.setInt(1, answerId);
                ps2.setInt(2, questionId);
                ps2.setString(3, questionOwner);
                ps2.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Question mapQ(ResultSet rs) throws SQLException {
        return new Question(
            rs.getInt("id"),
            rs.getInt("course_id"),
            rs.getString("title"),
            rs.getString("body"),
            rs.getString("asked_by"),
            rs.getInt("upvotes"),
            0,
            rs.getString("asked_date"),
            rs.getBoolean("urgent")
        );
    }

    private Answer mapA(ResultSet rs) throws SQLException {
        return new Answer(
            rs.getInt("id"),
            rs.getInt("question_id"),
            rs.getString("body"),
            rs.getString("answered_by"),
            rs.getInt("upvotes"),
            rs.getString("answered_date"),
            rs.getBoolean("accepted")
        );
    }
}
