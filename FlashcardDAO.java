package dao;

import java.sql.*;
import java.util.*;
import model.Flashcard;
import model.FlashcardDeck;
import util.DBConnection;

public class FlashcardDAO {

    public int createDeck(FlashcardDeck deck) {
        String sql = "INSERT INTO flashcard_decks(course_id, title, created_by) VALUES(?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, deck.getCourseId());
            ps.setString(2, deck.getTitle());
            ps.setString(3, deck.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void addCard(Flashcard card) {
        String sql = "INSERT INTO flashcards(deck_id, question, answer, position) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, card.getDeckId());
            ps.setString(2, card.getQuestion());
            ps.setString(3, card.getAnswer());
            ps.setInt(4, card.getPosition());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<FlashcardDeck> getAllDecks() {
        List<FlashcardDeck> list = new ArrayList<>();
        String sql = "SELECT d.*, c.name AS course_name, " +
                     "(SELECT COUNT(*) FROM flashcards f WHERE f.deck_id=d.id) AS card_count " +
                     "FROM flashcard_decks d LEFT JOIN courses c ON d.course_id=c.id " +
                     "ORDER BY d.created_date DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapDeck(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<FlashcardDeck> getDecksByUser(String username) {
        List<FlashcardDeck> list = new ArrayList<>();
        String sql = "SELECT d.*, c.name AS course_name, " +
                     "(SELECT COUNT(*) FROM flashcards f WHERE f.deck_id=d.id) AS card_count " +
                     "FROM flashcard_decks d LEFT JOIN courses c ON d.course_id=c.id " +
                     "WHERE d.created_by=? ORDER BY d.created_date DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDeck(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public FlashcardDeck getDeckById(int id) {
        String sql = "SELECT d.*, c.name AS course_name, " +
                     "(SELECT COUNT(*) FROM flashcards f WHERE f.deck_id=d.id) AS card_count " +
                     "FROM flashcard_decks d LEFT JOIN courses c ON d.course_id=c.id WHERE d.id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapDeck(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Flashcard> getCards(int deckId) {
        List<Flashcard> list = new ArrayList<>();
        String sql = "SELECT * FROM flashcards WHERE deck_id=? ORDER BY position";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, deckId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCard(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public void deleteDeck(int id, String username) {
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement("DELETE FROM flashcards WHERE deck_id=?")) {
                ps.setInt(1, id);
                ps.executeUpdate();
            }
            try (PreparedStatement ps2 = con.prepareStatement(
                    "DELETE FROM flashcard_decks WHERE id=? AND created_by=?")) {
                ps2.setInt(1, id);
                ps2.setString(2, username);
                ps2.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteCard(int cardId, String username) {
        // Only deck owner can delete
        String sql = "DELETE FROM flashcards WHERE id=? AND deck_id IN (SELECT id FROM flashcard_decks WHERE created_by=?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cardId);
            ps.setString(2, username);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private FlashcardDeck mapDeck(ResultSet rs) throws SQLException {
        return new FlashcardDeck(
            rs.getInt("id"),
            rs.getInt("course_id"),
            rs.getString("course_name"),
            rs.getString("title"),
            rs.getString("created_by"),
            rs.getInt("card_count"),
            rs.getString("created_date")
        );
    }

    private Flashcard mapCard(ResultSet rs) throws SQLException {
        return new Flashcard(
            rs.getInt("id"),
            rs.getInt("deck_id"),
            rs.getString("question"),
            rs.getString("answer"),
            rs.getInt("position")
        );
    }
}
