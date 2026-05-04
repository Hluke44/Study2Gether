package controller;

import dao.FlashcardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Flashcard;
import model.FlashcardDeck;
import model.User;

import java.io.IOException;

@WebServlet("/FlashcardServlet")
public class FlashcardServlet extends HttpServlet {

    FlashcardDAO dao = new FlashcardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");

        String view = request.getParameter("view");

        if ("study".equals(view)) {
            int deckId = Integer.parseInt(request.getParameter("id"));
            FlashcardDeck deck = dao.getDeckById(deckId);
            if (deck == null) { response.sendRedirect("FlashcardServlet"); return; }
            request.setAttribute("deck", deck);
            request.setAttribute("cards", dao.getCards(deckId));
            request.getRequestDispatcher("flashcardStudy.jsp").forward(request, response);
        } else {
            request.setAttribute("decks", dao.getAllDecks());
            request.getRequestDispatcher("flashcards.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        String username = user.getName();
        String action = request.getParameter("action");

        switch (action == null ? "" : action) {
            case "createDeck": {
                String title = request.getParameter("title");
                String courseIdStr = request.getParameter("courseId");
                int courseId = (courseIdStr != null && !courseIdStr.isBlank()) ? Integer.parseInt(courseIdStr) : 0;
                if (title != null && !title.isBlank()) {
                    FlashcardDeck deck = new FlashcardDeck(0, courseId, null, title.trim(), username, 0, null);
                    int deckId = dao.createDeck(deck);

                    // Add initial cards from the form
                    String[] questions = request.getParameterValues("cardQuestion");
                    String[] answers = request.getParameterValues("cardAnswer");
                    if (questions != null && answers != null) {
                        for (int i = 0; i < questions.length; i++) {
                            if (!questions[i].isBlank() && i < answers.length && !answers[i].isBlank()) {
                                dao.addCard(new Flashcard(0, deckId, questions[i].trim(), answers[i].trim(), i + 1));
                            }
                        }
                    }
                    session.setAttribute("message", "Flashcard deck created!");
                    response.sendRedirect("FlashcardServlet?view=study&id=" + deckId);
                    return;
                }
                break;
            }
            case "addCard": {
                int deckId = Integer.parseInt(request.getParameter("deckId"));
                String q = request.getParameter("question");
                String a = request.getParameter("answer");
                if (q != null && !q.isBlank() && a != null && !a.isBlank()) {
                    dao.addCard(new Flashcard(0, deckId, q.trim(), a.trim(), 999));
                    session.setAttribute("message", "Card added!");
                }
                response.sendRedirect("FlashcardServlet?view=study&id=" + deckId);
                return;
            }
            case "deleteDeck": {
                int deckId = Integer.parseInt(request.getParameter("deckId"));
                dao.deleteDeck(deckId, username);
                session.setAttribute("message", "Deck deleted.");
                break;
            }
            case "deleteCard": {
                int cardId = Integer.parseInt(request.getParameter("cardId"));
                int deckId = Integer.parseInt(request.getParameter("deckId"));
                dao.deleteCard(cardId, username);
                response.sendRedirect("FlashcardServlet?view=study&id=" + deckId);
                return;
            }
        }
        response.sendRedirect("FlashcardServlet");
    }
}
