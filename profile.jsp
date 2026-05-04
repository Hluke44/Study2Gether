<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, dao.*, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    CourseDAO cDAO = new CourseDAO();
    studyGroupDAO sgDAO = new studyGroupDAO();
    DeadlineDAO dlDAO = new DeadlineDAO();
    FlashcardDAO fcDAO = new FlashcardDAO();

    List<Course>        myCourses   = cDAO.getEnrolledCourses(user.getName());
    List<Deadline>      deadlines   = dlDAO.getByUser(user.getName());
    List<FlashcardDeck> myDecks     = fcDAO.getDecksByUser(user.getName());

    int pending = 0, done = 0;
    for (Deadline d : deadlines) { if (d.isDone()) done++; else pending++; }

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Profile — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.profile-header {
    display: flex;
    gap: 28px;
    align-items: center;
    background: linear-gradient(135deg,rgba(255,152,0,.1),transparent);
    border: 1px solid var(--card-border);
    border-radius: var(--radius);
    padding: 28px 32px;
    margin-bottom: 28px;
}
.avatar {
    width: 84px; height: 84px;
    border-radius: 50%;
    border: 3px solid var(--orange);
    background: rgba(255,152,0,.15);
    display: flex; align-items: center; justify-content: center;
    font-size: 38px; flex-shrink: 0;
}
.profile-name  { font-size: 24px; font-weight: 800; }
.profile-email { font-size: 14px; color: var(--muted); margin-top: 4px; }
.profile-id    { font-size: 12px; color: var(--muted); margin-top: 2px; }

.stat-row { display:flex; gap:16px; flex-wrap:wrap; margin-top:14px; }
.p-stat {
    background:rgba(0,0,0,.3); border:1px solid var(--card-border);
    border-radius:10px; padding:12px 18px; text-align:center; min-width:90px;
}
.p-stat .n { font-size:22px; font-weight:800; color:var(--orange); }
.p-stat .l { font-size:11px; color:var(--muted); }

.section-title {
    font-size:15px; font-weight:700; color:var(--text);
    margin:0 0 14px; padding-bottom:8px;
    border-bottom:1px solid rgba(255,255,255,.07);
}

.enrolled-course {
    display:flex; justify-content:space-between; align-items:center;
    padding:10px 0; border-bottom:1px solid rgba(255,255,255,.05);
    text-decoration:none; color:var(--text); transition:.2s;
}
.enrolled-course:last-child { border-bottom:none; }
.enrolled-course:hover .ec-code { color:var(--orange); }
.ec-code { font-weight:700; font-size:14px; color:var(--text); }
.ec-name { font-size:12px; color:var(--muted); }

.dl-row {
    display:flex; align-items:center; gap:12px;
    padding:9px 0; border-bottom:1px solid rgba(255,255,255,.05);
}
.dl-row:last-child { border-bottom:none; }
.dl-dot { width:8px;height:8px;border-radius:50%;flex-shrink:0; }
.dot-exam{background:var(--danger);}
.dot-test{background:var(--orange);}
.dot-assignment{background:var(--info);}
.dot-project{background:#ab47bc;}
.dl-title-sm { font-size:14px; font-weight:600; flex:1; }
.dl-due-sm   { font-size:12px; color:var(--orange); white-space:nowrap; }

.deck-row {
    display:flex; justify-content:space-between; align-items:center;
    padding:9px 0; border-bottom:1px solid rgba(255,255,255,.05);
    text-decoration:none; color:var(--text);
}
.deck-row:last-child { border-bottom:none; }
.deck-row:hover .dr-title { color:var(--orange); }
.dr-title { font-size:14px; font-weight:600; }
.dr-count  { font-size:12px; color:var(--muted); }

.two-col { display:grid; grid-template-columns:1fr 1fr; gap:20px; }
@media(max-width:700px){ .two-col{grid-template-columns:1fr;} .profile-header{flex-direction:column;text-align:center;} }
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="page">

<% if (message != null) { %>
    <div class="msg-success">✅ <%= message %></div>
<% } %>

<!-- PROFILE HEADER -->
<div class="profile-header">
    <div class="avatar">👤</div>
    <div style="flex:1;">
        <div class="profile-name"><%= user.getName() %></div>
        <div class="profile-email">📧 <%= user.getEmail() %></div>
        <div class="profile-id">🆔 Account #<%= user.getId() %></div>
        <div class="stat-row">
            <div class="p-stat"><div class="n"><%= myCourses.size() %></div><div class="l">Courses</div></div>
            <div class="p-stat"><div class="n"><%= pending %></div><div class="l">Pending</div></div>
            <div class="p-stat"><div class="n"><%= done %></div><div class="l">Done</div></div>
            <div class="p-stat"><div class="n"><%= myDecks.size() %></div><div class="l">Decks</div></div>
        </div>
    </div>
    <a href="logout.jsp" class="btn btn-danger">🚪 Logout</a>
</div>

<div class="two-col">

<!-- LEFT COL -->
<div>
    <!-- ENROLLED COURSES -->
    <div class="card">
        <div class="section-title">🎓 Enrolled Courses (<%= myCourses.size() %>)</div>
        <% if (myCourses.isEmpty()) { %>
            <p style="color:var(--muted);font-size:13px;">No courses yet. <a href="CourseServlet" style="color:var(--orange);">Browse courses →</a></p>
        <% } %>
        <% for (Course c : myCourses) { %>
            <a href="CourseServlet?view=detail&id=<%= c.getId() %>" class="enrolled-course">
                <div>
                    <div class="ec-code"><%= c.getCode() %></div>
                    <div class="ec-name"><%= c.getName() %></div>
                </div>
                <span class="badge badge-orange" style="font-size:11px;">Open →</span>
            </a>
        <% } %>
    </div>

    <!-- FLASHCARD DECKS -->
    <div class="card">
        <div class="section-title">🃏 My Flashcard Decks (<%= myDecks.size() %>)</div>
        <% if (myDecks.isEmpty()) { %>
            <p style="color:var(--muted);font-size:13px;">No decks yet. <a href="FlashcardServlet" style="color:var(--orange);">Create one →</a></p>
        <% } %>
        <% for (FlashcardDeck d : myDecks) { %>
            <a href="FlashcardServlet?view=study&id=<%= d.getId() %>" class="deck-row">
                <div>
                    <div class="dr-title"><%= d.getTitle() %></div>
                    <% if (d.getCourseName() != null) { %><div class="dr-count">🎓 <%= d.getCourseName() %></div><% } %>
                </div>
                <div class="dr-count">🃏 <%= d.getCardCount() %> cards</div>
            </a>
        <% } %>
    </div>
</div>

<!-- RIGHT COL -->
<div>
    <!-- UPCOMING DEADLINES -->
    <div class="card">
        <div class="section-title">📅 My Deadlines</div>
        <% 
        String today2 = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
        int shownDL = 0;
        for (Deadline d : deadlines) {
            if (d.isDone()) continue;
            shownDL++;
            String t = d.getType() != null ? d.getType().toLowerCase() : "assignment";
            boolean overdue = d.getDueDate() != null && d.getDueDate().compareTo(today2) < 0;
        %>
            <div class="dl-row">
                <div class="dl-dot dot-<%= t %>"></div>
                <div style="flex:1;">
                    <div class="dl-title-sm"><%= d.getTitle() %></div>
                    <div style="font-size:12px;color:var(--muted);"><%= d.getCourseName() != null ? d.getCourseName() : "General" %></div>
                </div>
                <div class="dl-due-sm" style="<%= overdue ? "color:var(--danger);" : "" %>">
                    <%= overdue ? "⚠️ " : "📅 " %><%= d.getDueDate() %>
                </div>
            </div>
        <% } %>
        <% if (shownDL == 0) { %>
            <p style="color:var(--muted);font-size:13px;text-align:center;padding:16px 0;">No pending deadlines 🎉</p>
        <% } %>
        <div class="mt-12">
            <a href="DeadlineServlet" class="btn btn-ghost btn-sm" style="display:block;text-align:center;">View All →</a>
        </div>
    </div>

    <!-- QUICK LINKS -->
    <div class="card">
        <div class="section-title">⚡ Quick Links</div>
        <div style="display:flex;flex-direction:column;gap:8px;">
            <a href="CourseServlet"     class="btn btn-ghost btn-sm" style="text-align:left;">🎓 Browse Courses</a>
            <a href="DeadlineServlet"   class="btn btn-ghost btn-sm" style="text-align:left;">📅 Add Deadline</a>
            <a href="FlashcardServlet"  class="btn btn-ghost btn-sm" style="text-align:left;">🃏 My Flashcards</a>
            <a href="StudyGroupServlet" class="btn btn-ghost btn-sm" style="text-align:left;">👥 Study Groups</a>
            <a href="resources.jsp"     class="btn btn-ghost btn-sm" style="text-align:left;">📁 Resources</a>
        </div>
    </div>
</div>

</div><!-- end two-col -->
</div><!-- end page -->
</body>
</html>
