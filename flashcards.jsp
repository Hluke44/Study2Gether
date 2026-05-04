<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, dao.CourseDAO, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    List<FlashcardDeck> decks = (List<FlashcardDeck>) request.getAttribute("decks");
    if (decks == null) decks = new ArrayList<>();

    CourseDAO cDAO = new CourseDAO();
    List<Course> courses = cDAO.getEnrolledCourses(user.getName());

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    String search = request.getParameter("search");
    if (search == null) search = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Flashcards — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.deck-card {
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: var(--radius);
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    transition: .25s;
}
.deck-card:hover { border-color: var(--orange); transform: translateY(-2px); box-shadow: 0 6px 22px rgba(255,152,0,.12); }
.deck-title { font-size: 16px; font-weight: 700; color: var(--text); }
.deck-course { font-size: 12px; color: var(--orange); }
.deck-count  { font-size: 13px; color: var(--muted); }
.deck-by     { font-size: 12px; color: var(--muted); }
.deck-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 4px; }

/* Dynamic card builder */
#card-list { margin-top: 12px; }
.card-row { display: grid; grid-template-columns: 1fr 1fr auto; gap: 8px; margin-bottom: 8px; align-items: start; }
.card-row input { margin: 0; }
.remove-row-btn { background: none; border: 1px solid #444; color: var(--muted); border-radius: 6px; padding: 8px 10px; cursor: pointer; font-size: 14px; transition:.2s; }
.remove-row-btn:hover { border-color: var(--danger); color: var(--danger); }
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
        <h1>🃏 Flashcard Decks</h1>
        <p>Create and study flashcard decks to memorise key concepts fast</p>
    </div>
</div>

<div style="display:grid;grid-template-columns:1fr 340px;gap:28px;align-items:start;">

<!-- LEFT: DECK LIST -->
<div>
    <!-- Search -->
    <form method="get" action="FlashcardServlet" class="search-box" style="margin-bottom:20px;">
        <input type="text" name="search" placeholder="Search decks..." value="<%= search %>">
        <button type="submit" class="btn btn-primary btn-sm">Search</button>
    </form>

    <% if (decks.isEmpty()) { %>
        <div class="empty">
            <div class="icon">🃏</div>
            <h3>No flashcard decks yet</h3>
            <p>Create the first deck using the form →</p>
        </div>
    <% } %>

    <div class="grid-3">
    <% for (FlashcardDeck deck : decks) {
        if (!search.isEmpty() && !deck.getTitle().toLowerCase().contains(search.toLowerCase())) continue;
        boolean myDeck = deck.getCreatedBy().equals(user.getName());
    %>
        <div class="deck-card">
            <div>
                <div class="deck-title"><%= deck.getTitle() %></div>
                <% if (deck.getCourseName() != null) { %>
                    <div class="deck-course">🎓 <%= deck.getCourseName() %></div>
                <% } %>
                <div class="deck-count">🃏 <%= deck.getCardCount() %> cards</div>
                <div class="deck-by">👤 <%= deck.getCreatedBy() %></div>
                <% if (deck.getCreatedDate() != null) { %>
                    <div class="deck-by">📅 <%= deck.getCreatedDate().substring(0,10) %></div>
                <% } %>
            </div>
            <div class="deck-actions">
                <a href="FlashcardServlet?view=study&id=<%= deck.getId() %>" class="btn btn-primary btn-sm">▶ Study</a>
                <% if (myDeck) { %>
                    <form method="post" action="FlashcardServlet" onsubmit="return confirm('Delete this deck?')">
                        <input type="hidden" name="action" value="deleteDeck">
                        <input type="hidden" name="deckId" value="<%= deck.getId() %>">
                        <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                    </form>
                <% } %>
            </div>
        </div>
    <% } %>
    </div>
</div>

<!-- RIGHT: CREATE DECK FORM -->
<div class="card" style="position:sticky;top:80px;">
    <div class="card-title">➕ Create New Deck</div>
    <form method="post" action="FlashcardServlet" id="createDeckForm">
        <input type="hidden" name="action" value="createDeck">
        <div class="form-group">
            <label>Deck Title *</label>
            <input type="text" name="title" placeholder="e.g. Java OOP Key Terms" required>
        </div>
        <div class="form-group">
            <label>Course (optional)</label>
            <select name="courseId">
                <option value="">— No Course —</option>
                <% for (Course c : courses) { %>
                    <option value="<%= c.getId() %>"><%= c.getCode() %> – <%= c.getName() %></option>
                <% } %>
            </select>
        </div>

        <div style="margin-bottom:10px;">
            <label style="font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;">Cards</label>
        </div>

        <div id="card-list">
            <div class="card-row">
                <input type="text" name="cardQuestion" placeholder="Question / Term" required>
                <input type="text" name="cardAnswer"   placeholder="Answer / Definition" required>
                <button type="button" class="remove-row-btn" onclick="removeRow(this)" title="Remove">✕</button>
            </div>
        </div>

        <button type="button" class="btn btn-ghost btn-sm" style="width:100%;margin-bottom:12px;" onclick="addRow()">+ Add Card</button>
        <button type="submit" class="btn btn-primary" style="width:100%;">Create Deck</button>
    </form>
</div>

</div>
</div>

<script>
function addRow() {
    const list = document.getElementById('card-list');
    const row = document.createElement('div');
    row.className = 'card-row';
    row.innerHTML = `
        <input type="text" name="cardQuestion" placeholder="Question / Term">
        <input type="text" name="cardAnswer"   placeholder="Answer / Definition">
        <button type="button" class="remove-row-btn" onclick="removeRow(this)" title="Remove">✕</button>
    `;
    list.appendChild(row);
    row.querySelector('input').focus();
}

function removeRow(btn) {
    const rows = document.querySelectorAll('.card-row');
    if (rows.length <= 1) return; // keep at least one
    btn.closest('.card-row').remove();
}
</script>
</body>
</html>
