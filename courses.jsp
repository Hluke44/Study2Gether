<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User, model.Course, dao.CourseDAO, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    List<Course> courses = (List<Course>) request.getAttribute("courses");
    List<Course> myCourses = (List<Course>) request.getAttribute("myCourses");
    if (courses == null) courses = new ArrayList<>();
    if (myCourses == null) myCourses = new ArrayList<>();

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    String search = request.getParameter("search");
    if (search == null) search = "";

    CourseDAO dao = new CourseDAO();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Courses — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.enroll-badge { font-size:11px; background:rgba(76,175,80,.2); color:#a5d6a7;
    border:1px solid #4caf50; border-radius:20px; padding:2px 8px; }
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="page">

<% if (message != null) { %>
    <div class="msg-success">✅ <%= message %></div>
<% } %>

<div class="page-header">
    <div>
        <h1>🎓 Course Hubs</h1>
        <p>Browse courses, enroll, access past papers and Q&amp;A</p>
    </div>
</div>

<div style="display:grid;grid-template-columns:1fr 300px;gap:28px;align-items:start;">

    <!-- LEFT: ALL COURSES -->
    <div>
        <!-- SEARCH -->
        <form method="get" action="CourseServlet" class="search-box" style="margin-bottom:20px;">
            <input type="text" name="search" placeholder="Search by code or name..." value="<%= search %>">
            <button type="submit" class="btn btn-primary btn-sm">Search</button>
        </form>

        <div class="section-title" style="font-size:16px;font-weight:700;margin-bottom:14px;
            padding-bottom:6px;border-bottom:1px solid rgba(255,255,255,.07);">
            All Courses (<%= courses.size() %>)
        </div>

        <% if (courses.isEmpty()) { %>
            <div class="empty"><div class="icon">🎓</div><h3>No courses yet</h3><p>Be the first to create a course hub below.</p></div>
        <% } %>

        <div class="grid-3">
        <%
        for (Course c : courses) {
            if (!search.isEmpty() &&
                !c.getCode().toLowerCase().contains(search.toLowerCase()) &&
                !c.getName().toLowerCase().contains(search.toLowerCase())) continue;

            boolean enrolled = dao.isEnrolled(c.getId(), user.getName());
            int enrollCount = dao.getEnrollmentCount(c.getId());
        %>
            <a href="CourseServlet?view=detail&id=<%= c.getId() %>" class="course-card">
                <div class="course-code"><%= c.getCode() %></div>
                <div class="course-name"><%= c.getName() %></div>
                <div class="course-meta">
                    👨‍🏫 <%= c.getLecturer() != null && !c.getLecturer().isEmpty() ? c.getLecturer() : "—" %><br>
                    📅 <%= c.getSemester() != null && !c.getSemester().isEmpty() ? c.getSemester() : "—" %><br>
                    👥 <%= enrollCount %> enrolled
                </div>
                <div style="margin-top:10px;">
                    <% if (enrolled) { %>
                        <span class="enroll-badge">✔ Enrolled</span>
                    <% } %>
                    <% if (c.getCreatedBy().equals(user.getName())) { %>
                        <span class="badge badge-orange" style="margin-left:4px;">Owner</span>
                    <% } %>
                </div>
            </a>
        <% } %>
        </div>
    </div>

    <!-- RIGHT SIDEBAR -->
    <div>
        <!-- MY COURSES -->
        <div class="card" style="margin-bottom:20px;">
            <div class="card-title">📘 My Enrolled Courses</div>
            <% if (myCourses.isEmpty()) { %>
                <p style="color:var(--muted);font-size:13px;">You haven't enrolled in any courses yet.</p>
            <% } else { %>
                <% for (Course c : myCourses) { %>
                    <div style="padding:8px 0;border-bottom:1px solid rgba(255,255,255,.05);">
                        <a href="CourseServlet?view=detail&id=<%= c.getId() %>"
                           style="color:var(--orange);text-decoration:none;font-weight:600;font-size:14px;">
                           <%= c.getCode() %>
                        </a>
                        <span style="color:var(--muted);font-size:13px;"> — <%= c.getName() %></span>
                    </div>
                <% } %>
            <% } %>
        </div>

        <!-- CREATE COURSE FORM -->
        <div class="card">
            <div class="card-title">➕ Create Course Hub</div>
            <form method="post" action="CourseServlet">
                <input type="hidden" name="action" value="create">
                <div class="form-group">
                    <label>Course Code *</label>
                    <input type="text" name="code" placeholder="e.g. CS101" required>
                </div>
                <div class="form-group">
                    <label>Course Name *</label>
                    <input type="text" name="name" placeholder="e.g. Data Structures" required>
                </div>
                <div class="form-group">
                    <label>Lecturer</label>
                    <input type="text" name="lecturer" placeholder="e.g. Prof. Smith">
                </div>
                <div class="form-group">
                    <label>Semester</label>
                    <input type="text" name="semester" placeholder="e.g. Sem 1 2025">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" placeholder="Brief description..." rows="2"></textarea>
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%;">Create Course</button>
            </form>
        </div>
    </div>
</div>

</div>
</body>
</html>
