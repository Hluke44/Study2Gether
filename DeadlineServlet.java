package controller;

import dao.DeadlineDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Deadline;
import model.User;

import java.io.IOException;

@WebServlet("/DeadlineServlet")
public class DeadlineServlet extends HttpServlet {

    DeadlineDAO dao = new DeadlineDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        request.setAttribute("deadlines", dao.getByUser(user.getName()));
        request.getRequestDispatcher("deadlines.jsp").forward(request, response);
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
            case "add": {
                String title = request.getParameter("title");
                String dueDate = request.getParameter("dueDate");
                String type = request.getParameter("type");
                String courseIdStr = request.getParameter("courseId");
                int courseId = (courseIdStr != null && !courseIdStr.isBlank()) ? Integer.parseInt(courseIdStr) : 0;
                if (title != null && !title.isBlank() && dueDate != null && !dueDate.isBlank()) {
                    Deadline d = new Deadline(0, courseId, null, title.trim(), dueDate, type, username, false);
                    dao.add(d);
                    session.setAttribute("message", "Deadline added!");
                }
                break;
            }
            case "toggle": {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.toggleDone(id, username);
                break;
            }
            case "delete": {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.delete(id, username);
                session.setAttribute("message", "Deadline removed.");
                break;
            }
        }

        response.sendRedirect("DeadlineServlet");
    }
}
