package controller;

import dao.QuestionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Answer;
import model.Question;
import model.User;

import java.io.IOException;

@WebServlet("/QAServlet")
public class QAServlet extends HttpServlet {

    QuestionDAO dao = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int questionId = Integer.parseInt(request.getParameter("id"));
        Question q = dao.getById(questionId);
        if (q == null) {
            response.sendRedirect("CourseServlet");
            return;
        }
        request.setAttribute("question", q);
        request.setAttribute("answers", dao.getAnswers(questionId));
        request.getRequestDispatcher("questionDetail.jsp").forward(request, response);
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
            case "ask": {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                String title = request.getParameter("title");
                String body = request.getParameter("body");
                boolean urgent = "on".equals(request.getParameter("urgent"));
                if (title != null && !title.isBlank()) {
                    Question q = new Question(0, courseId, title.trim(), body, username, 0, 0, null, urgent);
                    dao.postQuestion(q);
                    session.setAttribute("message", "Question posted!");
                }
                response.sendRedirect("CourseServlet?view=detail&id=" + courseId);
                break;
            }
            case "answer": {
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                String body = request.getParameter("body");
                if (body != null && !body.isBlank()) {
                    Answer a = new Answer(0, questionId, body.trim(), username, 0, null, false);
                    dao.postAnswer(a);
                    session.setAttribute("message", "Answer posted!");
                }
                response.sendRedirect("QAServlet?id=" + questionId);
                break;
            }
            case "upvoteQ": {
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                dao.upvoteQuestion(questionId, username);
                response.sendRedirect("QAServlet?id=" + questionId);
                break;
            }
            case "upvoteA": {
                int answerId = Integer.parseInt(request.getParameter("answerId"));
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                dao.upvoteAnswer(answerId, username);
                response.sendRedirect("QAServlet?id=" + questionId);
                break;
            }
            case "accept": {
                int answerId = Integer.parseInt(request.getParameter("answerId"));
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                dao.acceptAnswer(answerId, questionId, username);
                response.sendRedirect("QAServlet?id=" + questionId);
                break;
            }
            case "deleteQ": {
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                dao.deleteQuestion(questionId, username);
                response.sendRedirect("CourseServlet?view=detail&id=" + courseId);
                break;
            }
            default:
                response.sendRedirect("CourseServlet");
        }
    }
}
