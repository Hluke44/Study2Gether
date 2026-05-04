package controller;

import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

public class VerifyOtpServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String enteredOtp = request.getParameter("otp");
        String sessionOtp = (String) session.getAttribute("otp");

        User user = (User) session.getAttribute("tempUser");

        if (enteredOtp != null && enteredOtp.equals(sessionOtp)) {

            UserDAO dao = new UserDAO();
            dao.register(user); // SAVE TO DB NOW

            session.removeAttribute("otp");
            session.removeAttribute("tempUser");

            response.sendRedirect("login.jsp?verified=true");

        } else {
            response.sendRedirect("verify.jsp?error=invalid");
        }
    }
}