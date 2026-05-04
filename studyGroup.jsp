<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, dao.studyGroupDAO, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    String username = user.getName();

    studyGroupDAO dao = new studyGroupDAO();
   List<StudyGroup> groups = dao.getAllGroups();
    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    String search = request.getParameter("search");
    if (search == null) search = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Study Groups — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.group-card {
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: var(--radius);
    padding: 20px 24px;
    margin-bottom: 14px;
    transition: .2s;
}
.group-card:hover { border-color: var(--orange); }
.group-name { font-size: 17px; font-weight: 800; color: var(--text); margin-bottom: 5px; }
.group-desc { font-size: 13px; color: var(--muted); margin-bottom: 12px; line-height: 1.5; }
.group-meta-row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-bottom: 12px; }
.group-actions { display: flex; gap: 8px; flex-wrap: wrap; }
.members-bar-wrap { background: rgba(255,255,255,.08); border-radius: 4px; height: 6px; width: 120px; overflow: hidden; display: inline-block; vertical-align: middle; margin-left: 6px; }
.members-bar-fill { height: 100%; border-radius: 4px; background: var(--orange); }
.full-tag { color: var(--danger); font-size: 12px; font-weight: 700; }
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
        <h1>👥 Study Groups</h1>
        <p>Create or join study groups to collaborate with classmates</p>
    </div>
</div>

<div style="display:grid;grid-template-columns:1fr 300px;gap:28px;align-items:start;">

<!-- LEFT: GROUP LIST -->
<div>
    <!-- Search -->
    <form method="get" action="StudyGroupServlet" class="search-box" style="margin-bottom:20px;">
        <input type="text" name="search" placeholder="Search study groups..." value="<%= search %>">
        <button type="submit" class="btn btn-primary btn-sm">Search</button>
    </form>

    <% if (groups.isEmpty()) { %>
        <div class="empty">
            <div class="icon">👥</div>
            <h3>No study groups yet</h3>
            <p>Create the first one using the form →</p>
        </div>
    <% } %>

    <%
    for (StudyGroup g : groups) {
        if (!search.isEmpty() && !g.getName().toLowerCase().contains(search.toLowerCase())) continue;
        int count = dao.getMemberCount(g.getId());
        boolean isMember = dao.isMember(g.getId(), username);
        boolean isOwner  = username.equals(g.getCreatedBy());
        boolean isFull   = count >= g.getMaxMembers();
        int pct = g.getMaxMembers() > 0 ? (count * 100 / g.getMaxMembers()) : 0;
    %>
    <div class="group-card">
        <div class="group-name"><%= g.getName() %></div>
        <% if (g.getDescription() != null && !g.getDescription().isEmpty()) { %>
            <div class="group-desc"><%= g.getDescription() %></div>
        <% } %>
        <div class="group-meta-row">
            <span class="badge badge-orange">👥 <%= count %> / <%= g.getMaxMembers() %></span>
            <div class="members-bar-wrap"><div class="members-bar-fill" style="width:<%= pct %>%"></div></div>
            <% if (isFull) { %><span class="full-tag">● FULL</span><% } %>
            <% if (isOwner) { %><span class="badge badge-orange">⭐ Owner</span><% } %>
            <% if (!isOwner && isMember) { %><span class="badge badge-green">✔ Member</span><% } %>
            <span class="badge badge-gray">by <%= g.getCreatedBy() %></span>
        </div>
        <div class="group-actions">
            <% if (!isMember && !isFull) { %>
                <form method="post" action="StudyGroupServlet">
                    <input type="hidden" name="action" value="join">
                    <input type="hidden" name="id" value="<%= g.getId() %>">
                    <button type="submit" class="btn btn-primary btn-sm">Join Group</button>
                </form>
            <% } %>
            <% if (isMember && !isOwner) { %>
                <form method="post" action="StudyGroupServlet">
                    <input type="hidden" name="action" value="leave">
                    <input type="hidden" name="id" value="<%= g.getId() %>">
                    <button type="submit" class="btn btn-ghost btn-sm">Leave</button>
                </form>
            <% } %>
            <% if (isOwner) { %>
                <form method="post" action="StudyGroupServlet" onsubmit="return confirm('Delete this group?')">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= g.getId() %>">
                    <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                </form>
            <% } %>
        </div>
    </div>
    <% } %>
</div>

<!-- RIGHT: CREATE FORM -->
<div class="card" style="position:sticky;top:80px;">
    <div class="card-title">➕ Create Study Group</div>
    <form method="post" action="StudyGroupServlet">
        <input type="hidden" name="action" value="create">
        <div class="form-group">
            <label>Group Name *</label>
            <input type="text" name="name" placeholder="e.g. CS101 Study Squad" required>
        </div>
        <div class="form-group">
            <label>Description</label>
            <textarea name="description" placeholder="What is this group for?" rows="3"></textarea>
        </div>
        <div class="form-group">
            <label>Max Members *</label>
            <input type="number" name="maxMembers" min="2" max="50" value="10" required>
        </div>
        <button type="submit" class="btn btn-primary" style="width:100%;">Create Group</button>
    </form>
</div>

</div>
</div>
</body>
</html>
