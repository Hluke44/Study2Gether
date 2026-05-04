<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    FlashcardDeck deck = (FlashcardDeck) request.getAttribute("deck");
    List<Flashcard> cards = (List<Flashcard>) request.getAttribute("cards");
    if (deck == null) { response.sendRedirect("FlashcardServlet"); return; }
    if (cards == null) cards = new ArrayList<>();

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    boolean isOwner = deck.getCreatedBy().equals(user.getName());

    // Serialize cards to JSON for JS
    StringBuilder cardsJson = new StringBuilder("[");
    for (int i = 0; i < cards.size(); i++) {
        Flashcard c = cards.get(i);
        String q = c.getQuestion().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n");
        String a = c.getAnswer().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n");
        cardsJson.append("{\"id\":").append(c.getId())
                 .append(",\"q\":\"").append(q).append("\"")
                 .append(",\"a\":\"").append(a).append("\"}");
        if (i < cards.size() - 1) cardsJson.append(",");
    }
    cardsJson.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%= deck.getTitle() %> — Study</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.study-wrap {
    max-width: 680px;
    margin: 0 auto;
    padding: 36px 20px;
}
.deck-meta {
    text-align: center;
    margin-bottom: 32px;
}
.deck-meta h1 { font-size: 24px; font-weight: 800; color: var(--orange); }
.deck-meta p  { color: var(--muted); font-size: 14px; margin-top: 4px; }

/* Flashcard flip */
.flashcard-scene { perspective: 1200px; margin-bottom: 24px; cursor: pointer; }
.flashcard {
    width: 100%; height: 240px;
    position: relative;
    transform-style: preserve-3d;
    transition: transform 0.5s cubic-bezier(0.4,0,0.2,1);
}
.flashcard.flipped { transform: rotateY(180deg); }
.flashcard-face {
    position: absolute; inset: 0;
    backface-visibility: hidden;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    padding: 32px;
    text-align: center;
    border-radius: 16px;
    border: 1px solid var(--card-border);
    background: var(--card);
}
.flashcard-front .hint { font-size: 11px; color: var(--muted); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; }
.flashcard-front .card-text { font-size: 20px; font-weight: 700; line-height: 1.4; }
.flashcard-back {
    transform: rotateY(180deg);
    background: linear-gradient(135deg, rgba(255,152,0,.1), rgba(0,0,0,.3));
    border-color: var(--orange);
}
.flashcard-back .hint { font-size: 11px; color: var(--orange); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px; }
.flashcard-back .card-text { font-size: 18px; color: var(--orange); line-height: 1.5; }

/* Progress */
.progress-row { display: flex; align-items: center; gap: 12px; margin-bottom: 18px; }
.progress-bar-wrap { flex: 1; height: 6px; background: rgba(255,255,255,.1); border-radius: 3px; overflow: hidden; }
.progress-bar-fill { height: 100%; background: var(--orange); border-radius: 3px; transition: width .3s; }
.progress-text { font-size: 13px; color: var(--muted); white-space: nowrap; }

/* Controls */
.controls { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; margin-bottom: 24px; }

/* Score buttons */
.score-row { display: flex; gap: 10px; justify-content: center; margin-bottom: 28px; }
.score-btn {
    padding: 10px 22px; border: none; border-radius: 10px;
    font-size: 14px; font-weight: 700; cursor: pointer; transition: .2s;
}
.score-btn.correct  { background: rgba(76,175,80,.2); color: #a5d6a7; border: 1px solid #4caf50; }
.score-btn.incorrect{ background: rgba(229,57,53,.2); color: #ef9a9a;  border: 1px solid #e53935; }
.score-btn.skip     { background: rgba(255,255,255,.07); color: var(--muted); border: 1px solid #444; }
.score-btn:hover { transform: translateY(-2px); }

/* Results */
#results-panel {
    display: none;
    text-align: center;
    padding: 40px 20px;
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: 16px;
}
#results-panel .big-score { font-size: 56px; font-weight: 900; color: var(--orange); }
#results-panel .sub { color: var(--muted); font-size: 15px; margin-top: 6px; }
#results-panel .breakdown { display: flex; gap: 24px; justify-content: center; margin: 24px 0; flex-wrap: wrap; }
#results-panel .bd-item .n { font-size: 26px; font-weight: 800; }
#results-panel .bd-item .l { font-size: 12px; color: var(--muted); }
.correct-n  { color: var(--success); }
.incorrect-n{ color: var(--danger); }
.skip-n     { color: var(--muted); }

/* Card list below */
.card-list-section { margin-top: 40px; }
.card-list-item {
    background: var(--card);
    border: 1px solid var(--card-border);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 10px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
}
.card-list-item:hover { border-color: var(--orange); }
.cl-q { font-weight: 600; font-size: 14px; }
.cl-a { font-size: 13px; color: var(--muted); margin-top: 3px; }
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="study-wrap">

<% if (message != null) { %>
    <div class="msg-success">✅ <%= message %></div>
<% } %>

<p style="font-size:13px;color:var(--muted);margin-bottom:18px;">
    <a href="FlashcardServlet" style="color:var(--muted);text-decoration:none;">← All Decks</a>
</p>

<div class="deck-meta">
    <h1>🃏 <%= deck.getTitle() %></h1>
    <p>
        <% if (deck.getCourseName() != null) { %>🎓 <%= deck.getCourseName() %> &nbsp;·&nbsp;<% } %>
        👤 <%= deck.getCreatedBy() %> &nbsp;·&nbsp;
        🃏 <%= cards.size() %> card<%= cards.size() != 1 ? "s" : "" %>
    </p>
</div>

<% if (cards.isEmpty()) { %>
    <div class="empty">
        <div class="icon">🃏</div>
        <h3>No cards in this deck yet</h3>
        <p>Add your first card below.</p>
    </div>
<% } else { %>

<!-- PROGRESS -->
<div class="progress-row">
    <div class="progress-bar-wrap">
        <div class="progress-bar-fill" id="progressBar" style="width:0%"></div>
    </div>
    <div class="progress-text" id="progressText">1 / <%= cards.size() %></div>
</div>

<!-- FLASHCARD -->
<div class="flashcard-scene" onclick="flipCard()">
    <div class="flashcard" id="flashcard">
        <div class="flashcard-face flashcard-front">
            <div class="hint">Question — tap to reveal answer</div>
            <div class="card-text" id="cardQuestion">...</div>
        </div>
        <div class="flashcard-face flashcard-back">
            <div class="hint">Answer</div>
            <div class="card-text" id="cardAnswer">...</div>
        </div>
    </div>
</div>

<!-- SCORE BUTTONS -->
<div class="score-row" id="scoreRow" style="display:none;">
    <button class="score-btn correct"   onclick="score('correct')">✅ Got it</button>
    <button class="score-btn incorrect" onclick="score('incorrect')">❌ Missed</button>
    <button class="score-btn skip"      onclick="score('skip')">⏭ Skip</button>
</div>

<!-- NAV CONTROLS -->
<div class="controls">
    <button class="btn btn-ghost" onclick="prevCard()">← Prev</button>
    <button class="btn btn-primary" id="flipBtn" onclick="flipCard()">🔄 Flip Card</button>
    <button class="btn btn-ghost" onclick="nextCard()">Next →</button>
</div>

<div style="text-align:center;margin-bottom:8px;">
    <button class="btn btn-ghost btn-sm" onclick="shuffleCards()">🔀 Shuffle</button>
    <button class="btn btn-ghost btn-sm" onclick="resetStudy()">↺ Restart</button>
</div>

<!-- RESULTS PANEL (hidden until complete) -->
<div id="results-panel">
    <div class="big-score" id="scorePercent">—</div>
    <div class="sub" id="scoreLabel">Study session complete!</div>
    <div class="breakdown">
        <div class="bd-item"><div class="n correct-n"  id="rCorrect">0</div><div class="l">Correct</div></div>
        <div class="bd-item"><div class="n incorrect-n"id="rIncorrect">0</div><div class="l">Missed</div></div>
        <div class="bd-item"><div class="n skip-n"     id="rSkip">0</div><div class="l">Skipped</div></div>
    </div>
    <button class="btn btn-primary" onclick="resetStudy()">↺ Study Again</button>
</div>

<% } /* end if cards not empty */ %>

<!-- ADD CARD (owner only) -->
<% if (isOwner) { %>
<div class="card-list-section">
    <div class="card-title" style="margin-bottom:14px;">✏️ Manage Cards</div>

    <!-- Add Card form -->
    <div class="card" style="margin-bottom:20px;">
        <div style="font-size:14px;font-weight:600;margin-bottom:10px;">+ Add a Card</div>
        <form method="post" action="FlashcardServlet">
            <input type="hidden" name="action" value="addCard">
            <input type="hidden" name="deckId" value="<%= deck.getId() %>">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:10px;">
                <input type="text" name="question" placeholder="Question / Term" required>
                <input type="text" name="answer"   placeholder="Answer / Definition" required>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Add Card</button>
        </form>
    </div>

    <!-- Card list -->
    <% for (Flashcard c : cards) { %>
    <div class="card-list-item">
        <div>
            <div class="cl-q"><%= c.getQuestion() %></div>
            <div class="cl-a"><%= c.getAnswer() %></div>
        </div>
        <form method="post" action="FlashcardServlet">
            <input type="hidden" name="action" value="deleteCard">
            <input type="hidden" name="cardId" value="<%= c.getId() %>">
            <input type="hidden" name="deckId" value="<%= deck.getId() %>">
            <button type="submit" class="btn btn-danger btn-xs">✕</button>
        </form>
    </div>
    <% } %>
</div>
<% } %>

</div><!-- end study-wrap -->

<script>
const CARDS = <%= cardsJson.toString() %>;
let deck = [...CARDS];
let idx = 0;
let flipped = false;
let scores = { correct: 0, incorrect: 0, skip: 0 };

function render() {
    if (deck.length === 0) return;
    const card = deck[idx];
    document.getElementById('cardQuestion').textContent = card.q;
    document.getElementById('cardAnswer').textContent   = card.a;
    document.getElementById('progressText').textContent = (idx + 1) + ' / ' + deck.length;
    document.getElementById('progressBar').style.width  = ((idx + 1) / deck.length * 100) + '%';

    // Reset flip
    const fc = document.getElementById('flashcard');
    fc.classList.remove('flipped');
    flipped = false;
    document.getElementById('scoreRow').style.display = 'none';
}

function flipCard() {
    const fc = document.getElementById('flashcard');
    flipped = !flipped;
    fc.classList.toggle('flipped', flipped);
    if (flipped) {
        document.getElementById('scoreRow').style.display = 'flex';
    }
}

function nextCard() {
    if (idx < deck.length - 1) { idx++; render(); }
    else showResults();
}

function prevCard() {
    if (idx > 0) { idx--; render(); }
}

function score(type) {
    scores[type]++;
    nextCard();
}

function shuffleCards() {
    for (let i = deck.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [deck[i], deck[j]] = [deck[j], deck[i]];
    }
    idx = 0; scores = { correct: 0, incorrect: 0, skip: 0 };
    document.getElementById('results-panel').style.display = 'none';
    render();
}

function resetStudy() {
    deck = [...CARDS]; idx = 0;
    scores = { correct: 0, incorrect: 0, skip: 0 };
    document.getElementById('results-panel').style.display = 'none';
    // show study UI
    document.querySelector('.flashcard-scene').style.display = '';
    document.querySelector('.controls').style.display = '';
    document.querySelector('.progress-row').style.display = '';
    const sr = document.getElementById('scoreRow');
    if (sr) sr.style.display = 'none';
    render();
}

function showResults() {
    document.querySelector('.flashcard-scene').style.display = 'none';
    document.querySelector('.controls').style.display = 'none';
    document.querySelector('.progress-row').style.display = 'none';
    const sr = document.getElementById('scoreRow');
    if (sr) sr.style.display = 'none';

    const total = scores.correct + scores.incorrect;
    const pct = total > 0 ? Math.round(scores.correct / total * 100) : 0;
    document.getElementById('scorePercent').textContent = pct + '%';
    document.getElementById('scoreLabel').textContent =
        pct >= 80 ? '🎉 Excellent work!' : pct >= 50 ? '👍 Good effort!' : '💪 Keep practising!';
    document.getElementById('rCorrect').textContent   = scores.correct;
    document.getElementById('rIncorrect').textContent = scores.incorrect;
    document.getElementById('rSkip').textContent      = scores.skip;
    document.getElementById('results-panel').style.display = 'block';
}

// Keyboard shortcuts
document.addEventListener('keydown', e => {
    if (e.key === ' ' || e.key === 'ArrowUp' || e.key === 'ArrowDown') { e.preventDefault(); flipCard(); }
    if (e.key === 'ArrowRight') nextCard();
    if (e.key === 'ArrowLeft')  prevCard();
    if (e.key === '1') score('correct');
    if (e.key === '2') score('incorrect');
    if (e.key === '3') score('skip');
});

// Boot
if (CARDS.length > 0) render();
</script>
</body>
</html>
