<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    Question question = (Question) request.getAttribute("question");
    List<Answer> answers = (List<Answer>) request.getAttribute("answers");
    if (question == null) { response.sendRedirect("CourseServlet"); return; }
    if (answers == null) answers = new ArrayList<>();

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    boolean isOwner = question.getAskedBy().equals(user.getName());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Q&A — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.question-body-card {
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: var(--radius);
    padding: 26px 30px;
    margin-bottom: 28px;
}
.question-body-card h1 { font-size: 22px; font-weight: 800; line-height: 1.3; margin-bottom: 12px; }
.question-body-text { color: #ccc; line-height: 1.7; font-size: 15px; }
.q-meta-row { display: flex; gap: 16px; flex-wrap: wrap; margin-top: 14px; font-size: 12px; color: var(--muted); align-items: center; }

.answer-card {
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: var(--radius);
    padding: 20px 24px;
    margin-bottom: 14px;
    transition: .2s;
}
.answer-card:hover { border-color: rgba(255,152,0,.5); }
.answer-body { color: #ddd; line-height: 1.7; font-size: 14px; white-space: pre-wrap; }
.answer-meta { display: flex; gap: 14px; flex-wrap: wrap; margin-top: 12px; font-size: 12px; color: var(--muted); align-items: center; }

.post-answer-card {
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: var(--radius);
    padding: 22px;
    margin-top: 28px;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="page" style="max-width: 860px;">

<% if (message != null) { %>
    <div class="msg-success">✅ <%= message %></div>
<% } %>

<p style="font-size:13px;color:var(--muted);margin-bottom:16px;">
    <a href="CourseServlet" style="color:var(--muted);text-decoration:none;">← Courses</a>
    &nbsp;/&nbsp;
    <a href="CourseServlet?view=detail&id=<%= question.getCourseId() %>&tab=qa"
       style="color:var(--muted);text-decoration:none;">← Q&amp;A</a>
</p>

<!-- QUESTION -->
<div class="question-body-card">
    <% if (question.isUrgent()) { %>
        <span class="urgent-tag" style="display:inline-block;margin-bottom:10px;">🔥 URGENT</span>
    <% } %>
    <h1><%= question.getTitle() %></h1>
    <% if (question.getBody() != null && !question.getBody().isEmpty()) { %>
        <p class="question-body-text"><%= question.getBody() %></p>
    <% } %>
    <div class="q-meta-row">
        <span>👤 Asked by <strong><%= question.getAskedBy() %></strong></span>
        <% if (question.getAskedDate() != null) { %>
            <span>🕐 <%= question.getAskedDate().substring(0,10) %></span>
        <% } %>
        <span>▲ <%= question.getUpvotes() %> upvotes</span>
        <span>💬 <%= answers.size() %> answers</span>

        <!-- Upvote question -->
        <form method="post" action="QAServlet" style="display:inline;">
            <input type="hidden" name="action" value="upvoteQ">
            <input type="hidden" name="questionId" value="<%= question.getId() %>">
            <button type="submit" class="upvote-btn">▲ Upvote</button>
        </form>

        <% if (isOwner) { %>
            <form method="post" action="QAServlet" style="display:inline;" onsubmit="return confirm('Delete this question?')">
                <input type="hidden" name="action" value="deleteQ">
                <input type="hidden" name="questionId" value="<%= question.getId() %>">
                <input type="hidden" name="courseId" value="<%= question.getCourseId() %>">
                <button type="submit" class="btn btn-danger btn-xs">Delete</button>
            </form>
        <% } %>
    </div>
</div>

<!-- ANSWERS -->
<div style="font-size:16px;font-weight:700;color:var(--text);margin-bottom:16px;">
    💬 <%= answers.size() %> Answer<%= answers.size() != 1 ? "s" : "" %>
</div>

<% if (answers.isEmpty()) { %>
    <div class="empty">
        <div class="icon">🤔</div>
        <h3>No answers yet</h3>
        <p>Be the first to help out!</p>
    </div>
<% } %>

<% for (Answer a : answers) { %>
<div class="answer-card <%= a.isAccepted() ? "answer-accepted" : "" %>">
    <% if (a.isAccepted()) { %>
        <div class="accepted-badge" style="margin-bottom:8px;">✅ Accepted Answer</div>
    <% } %>
    <div class="answer-body"><%= a.getBody() %></div>
    <div class="answer-meta">
        <span>👤 <strong><%= a.getAnsweredBy() %></strong></span>
        <% if (a.getAnsweredDate() != null) { %>
            <span>🕐 <%= a.getAnsweredDate().substring(0,10) %></span>
        <% } %>
        <span>▲ <%= a.getUpvotes() %> upvotes</span>

        <!-- Upvote answer -->
        <form method="post" action="QAServlet" style="display:inline;">
            <input type="hidden" name="action" value="upvoteA">
            <input type="hidden" name="answerId" value="<%= a.getId() %>">
            <input type="hidden" name="questionId" value="<%= question.getId() %>">
            <button type="submit" class="upvote-btn">▲ Helpful</button>
        </form>

        <!-- Accept answer (only question owner) -->
        <% if (isOwner && !a.isAccepted()) { %>
            <form method="post" action="QAServlet" style="display:inline;">
                <input type="hidden" name="action" value="accept">
                <input type="hidden" name="answerId" value="<%= a.getId() %>">
                <input type="hidden" name="questionId" value="<%= question.getId() %>">
                <button type="submit" class="btn btn-success btn-xs">✅ Accept</button>
            </form>
        <% } %>
    </div>
</div>
<% } %>

<!-- POST ANSWER -->
<div class="post-answer-card">
    <div class="card-title" style="margin-bottom:14px;">✍️ Post Your Answer</div>
    <form method="post" action="QAServlet">
        <input type="hidden" name="action" value="answer">
        <input type="hidden" name="questionId" value="<%= question.getId() %>">
        <div class="form-group">
            <textarea name="body" rows="5" placeholder="Write a clear, helpful answer..." required></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Post Answer</button>
    </form>
</div>

</div>
</body>
</html>
