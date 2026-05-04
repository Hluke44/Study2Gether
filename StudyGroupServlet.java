package controller;

import dao.studyGroupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.StudyGroup;
import model.User;

import java.io.IOException;

@WebServlet("/StudyGroupServlet")
public class StudyGroupServlet extends HttpServlet {

    studyGroupDAO dao = new studyGroupDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        User user = (User) session.getAttribute("user");
        String username = user.getName();
        String action = request.getParameter("action");

        if (action == null) { response.sendRedirect("StudyGroupServlet"); return; }

        switch (action) {
            case "create": {
                String name    = request.getParameter("name");
                String desc    = request.getParameter("description");
                String maxStr  = request.getParameter("maxMembers");
                if (name != null && !name.isBlank() && maxStr != null) {
                    int max = Integer.parseInt(maxStr);
                    dao.createGroup(new StudyGroup(0, name.trim(), desc, max, username));
                    session.setAttribute("message", "Study group created!");
                }
                break;
            }
            case "delete": {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.deleteGroup(id, username);
                session.setAttribute("message", "Group deleted.");
                break;
            }
            case "join": {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.joinGroup(id, username);
                session.setAttribute("message", "Joined group!");
                break;
            }
            case "leave": {
                int id = Integer.parseInt(request.getParameter("id"));
                dao.leaveGroup(id, username);
                session.setAttribute("message", "Left group.");
                break;
            }
        }
        response.sendRedirect("StudyGroupServlet");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        request.setAttribute("groups", dao.getAllGroups());
        request.getRequestDispatcher("studyGroup.jsp").forward(request, response);
    }
}
