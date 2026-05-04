<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>

<%
    User __navUser = (User) session.getAttribute("user");
    String __navName = (__navUser != null) ? __navUser.getName() : "";
    String __current = request.getServletPath();
%>

<style>
nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 18px 60px;
    background: rgba(0,0,0,0.85);
    border-bottom: 1px solid rgba(255,255,255,0.1);
}

.logo {
    font-size: 24px;
    font-weight: bold;
    color: orange;
    text-decoration: none;
}

.logo span {
    color: white;
}

.nav-links {
    display: flex;
    gap: 20px;
}

.nav-links a {
    color: white;
    text-decoration: none;
    font-size: 14px;
    transition: 0.3s;
}

.nav-links a:hover,
.nav-links .active {
    color: orange;
}

.nav-right {
    display: flex;
    gap: 15px;
    align-items: center;
}

.nav-user {
    color: white;
    text-decoration: none;
}

.nav-logout {
    color: red;
    text-decoration: none;
}
</style>

<nav>
    <a href="home.jsp" class="logo">STUDY<span>2GETHER</span></a>

    <div class="nav-links">
        <a href="CourseServlet"
           class="<%= __current.contains("Course") ? "active" : "" %>">🎓 Courses</a>

        <a href="StudyGroupServlet"
           class="<%= __current.contains("StudyGroup") ? "active" : "" %>">👥 Groups</a>

        <a href="DeadlineServlet"
           class="<%= __current.contains("Deadline") ? "active" : "" %>">📅 Deadlines</a>

        <a href="FlashcardServlet"
           class="<%= __current.contains("Flashcard") ? "active" : "" %>">🃏 Flashcards</a>

        <a href="resources.jsp"
           class="<%= __current.contains("resources") ? "active" : "" %>">📁 Resources</a>
    </div>

    <div class="nav-right">
        <a href="profile.jsp" class="nav-user">👤 <%= __navName %></a>
        <a href="logout.jsp" class="nav-logout">🚪</a>
    </div>
</nav>