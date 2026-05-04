package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.util.Random;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Validate empty fields
        if (name == null || name.isBlank() ||
            email == null || email.isBlank() ||
            password == null || password.isBlank() ||
            confirmPassword == null || confirmPassword.isBlank()) {

            response.sendRedirect("register.jsp?error=empty");
            return;
        }

        // 2. Check password match
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=nomatch");
            return;
        }

        // 3. Create user object (DO NOT SAVE YET)
        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim());
        user.setPassword(password);

        // 4. Generate OTP
        String otp = String.valueOf(100000 + new Random().nextInt(900000));

        // 5. Store temporarily in session
        HttpSession session = request.getSession();
        session.setAttribute("tempUser", user);
        session.setAttribute("otp", otp);
        session.setAttribute("email", email);

        // 6. Send OTP email
        try {
            sendOtpEmail(email, otp);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=emailfail");
            return;
        }

        // 7. Redirect to OTP page
        response.sendRedirect("verify.jsp");
    }

    // EMAIL SENDING METHOD
    private void sendOtpEmail(String to, String otp) throws Exception {

        String from = "your-email@gmail.com";
        String appPassword = "your-app-password";

        java.util.Properties props = new java.util.Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        jakarta.mail.Session mailSession = jakarta.mail.Session.getInstance(props,
            new jakarta.mail.Authenticator() {
                protected jakarta.mail.PasswordAuthentication getPasswordAuthentication() {
                    return new jakarta.mail.PasswordAuthentication(from, appPassword);
                }
            });

        jakarta.mail.Message message = new jakarta.mail.internet.MimeMessage(mailSession);
        message.setFrom(new jakarta.mail.internet.InternetAddress(from));
        message.setRecipients(jakarta.mail.Message.RecipientType.TO,
                jakarta.mail.internet.InternetAddress.parse(to));
        message.setSubject("Study2Gether OTP Verification");
        message.setText("Your OTP is: " + otp);

        jakarta.mail.Transport.send(message);
    }
}