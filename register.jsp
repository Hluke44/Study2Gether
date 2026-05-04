<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User existing = (User) session.getAttribute("user");
    if (existing != null) {
        response.sendRedirect("home.jsp");
        return;
    }
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>CampusMarket - Register</title>
    </head>
    <body>
        <h2>Register</h2>

        <% if ("taken".equals(error)) { %>
            <p style="color:red;">That email is already registered.</p>
        <% } else if ("empty".equals(error)) { %>
            <p style="color:red;">Please fill in all fields.</p>
        <% } %>

        <form action="RegisterServlet" method="post">
    <input type="text" name="name" placeholder="Name" required /><br><br>

    <input type="email" name="email" placeholder="Email" required /><br><br>

    <input type="password" name="password" placeholder="Password" required /><br><br>

    <input type="password" name="confirmPassword"
           placeholder="Confirm Password" required /><br><br>

    <button type="submit">Register</button>
</form>
        <br>
        <a href="login.jsp">Already have an account? Login</a>
    </body>
</html>
