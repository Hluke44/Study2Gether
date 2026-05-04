<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User, model.Deadline, dao.DeadlineDAO, dao.CourseDAO, java.util.*, java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    DeadlineDAO dlDAO = new DeadlineDAO();
    CourseDAO   cDAO  = new CourseDAO();

    List<Deadline> allDeadlines = dlDAO.getByUser(user.getName());
    int myCourses  = cDAO.getEnrolledCourses(user.getName()).size();

    // Compute upcoming & overdue counts
    String todayStr = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
    int upcomingDL = 0, overdueDL = 0;
    for (Deadline d : allDeadlines) {
        if (d.isDone()) continue;
        if (d.getDueDate() != null && d.getDueDate().compareTo(todayStr) < 0) overdueDL++;
        else upcomingDL++;
    }

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    // Build JSON of pending deadlines for JS countdown (max 8)
    StringBuilder dlJson = new StringBuilder("[");
    int dlCount = 0;
    for (Deadline d : allDeadlines) {
        if (d.isDone() || dlCount >= 8) continue;
        String title  = d.getTitle().replace("\\","\\\\").replace("\"","\\\"");
        String course = d.getCourseName() != null ? d.getCourseName().replace("\"","\\\"") : "General";
        String type   = d.getType() != null ? d.getType() : "assignment";
        if (dlCount > 0) dlJson.append(",");
        dlJson.append("{")
              .append("\"id\":").append(d.getId()).append(",")
              .append("\"title\":\"").append(title).append("\",")
              .append("\"course\":\"").append(course).append("\",")
              .append("\"type\":\"").append(type).append("\",")
              .append("\"due\":\"").append(d.getDueDate()).append("\"")
              .append("}");
        dlCount++;
    }
    dlJson.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>StudyPlatform — Home</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
/* ── HERO ── */
.hero {
    background: linear-gradient(135deg,rgba(255,152,0,.1),rgba(0,0,0,.25));
    border: 1px solid var(--card-border); border-radius: 16px;
    padding: 40px 48px; display: flex; align-items: center;
    justify-content: space-between; gap: 36px; margin-bottom: 32px;
    position: relative; overflow: hidden;
}
.hero::before {
    content:''; position:absolute; top:-80px; right:-80px;
    width:280px; height:280px;
    background: radial-gradient(circle,rgba(255,152,0,.15) 0%,transparent 70%);
    border-radius: 50%; pointer-events: none;
}
.hero h1 { font-size:34px; font-weight:900; line-height:1.15; }
.hero h1 span { color:var(--orange); }
.hero p { color:var(--muted); margin-top:10px; line-height:1.7; max-width:400px; }
.hero-actions { display:flex; gap:10px; margin-top:18px; flex-wrap:wrap; }
.hero-stats { display:flex; flex-direction:column; gap:10px; flex-shrink:0; }
.mini-stat {
    background:rgba(0,0,0,.45); border:1px solid var(--card-border);
    border-radius:12px; padding:14px 22px; text-align:center; min-width:120px;
    transition:.2s;
}
.mini-stat.danger { border-color:var(--danger); background:rgba(229,57,53,.1); }
.mini-stat .n { font-size:28px; font-weight:900; color:var(--orange); }
.mini-stat.danger .n { color:var(--danger); }
.mini-stat .l { font-size:11px; color:var(--muted); margin-top:2px; }

/* ── FEATURES ── */
.section-title { font-size:17px; font-weight:700; margin-bottom:14px;
    padding-bottom:8px; border-bottom:1px solid rgba(255,255,255,.07); }
.feature-card {
    background:var(--card); border:1px solid var(--card-border);
    border-radius:var(--radius); padding:20px; text-decoration:none;
    color:var(--text); display:block; transition:.25s; position:relative; overflow:hidden;
}
.feature-card:hover { border-color:var(--orange); transform:translateY(-3px);
    box-shadow:0 8px 28px rgba(255,152,0,.13); }
.feature-card .icon { font-size:30px; margin-bottom:8px; display:block; }
.feature-card h3 { font-size:14px; font-weight:700; color:var(--orange); margin-bottom:4px; }
.feature-card p  { font-size:12px; color:var(--muted); line-height:1.5; }
.feature-card .hot { position:absolute; top:10px; right:10px; background:rgba(229,57,53,.2);
    color:#ef9a9a; border:1px solid var(--danger); font-size:10px; font-weight:700;
    padding:1px 7px; border-radius:20px; }

/* ── DEADLINE SIDEBAR ── */
.two-col { display:grid; grid-template-columns:1fr 340px; gap:24px; align-items:start; }
@media(max-width:920px){ .two-col{grid-template-columns:1fr;} .hero{flex-direction:column;} }

.dl-item {
    padding: 12px 14px;
    border-radius: 10px;
    margin-bottom: 8px;
    border-left: 4px solid #555;
    background: rgba(255,255,255,.03);
    transition: .2s;
    cursor: default;
}
.dl-item:hover { background: rgba(255,255,255,.06); }

/* urgency colours */
.dl-item.urgency-overdue  { border-left-color:#e53935; background:rgba(229,57,53,.07); }
.dl-item.urgency-critical { border-left-color:#ff7043; background:rgba(255,112,67,.07); }
.dl-item.urgency-soon     { border-left-color:#FF9800; background:rgba(255,152,0,.06); }
.dl-item.urgency-ok       { border-left-color:#4caf50; background:rgba(76,175,80,.05); }

.dl-item-top { display:flex; justify-content:space-between; align-items:flex-start; gap:8px; }
.dl-item-title  { font-size:14px; font-weight:700; line-height:1.3; }
.dl-item-course { font-size:11px; color:var(--muted); margin-top:2px; }

.countdown-badge {
    font-size:11px; font-weight:700; white-space:nowrap;
    padding:3px 8px; border-radius:20px; flex-shrink:0;
}
.urgency-overdue  .countdown-badge { background:rgba(229,57,53,.25); color:#ef9a9a; }
.urgency-critical .countdown-badge { background:rgba(255,112,67,.25); color:#ffab91; }
.urgency-soon     .countdown-badge { background:rgba(255,152,0,.2);   color:var(--orange); }
.urgency-ok       .countdown-badge { background:rgba(76,175,80,.2);   color:#a5d6a7; }

.dl-item-bar {
    height: 3px; border-radius: 2px; margin-top: 8px;
    background: rgba(255,255,255,.07); overflow:hidden;
}
.dl-item-bar-fill { height:100%; border-radius:2px; transition:width .3s; }
.urgency-overdue  .dl-item-bar-fill { background:#e53935; }
.urgency-critical .dl-item-bar-fill { background:#ff7043; }
.urgency-soon     .dl-item-bar-fill { background:#FF9800; }
.urgency-ok       .dl-item-bar-fill { background:#4caf50; }

.type-dot {
    display:inline-block; width:7px; height:7px; border-radius:50%;
    margin-right:5px; vertical-align:middle;
}
.dot-exam       { background:var(--danger); }
.dot-test       { background:var(--orange); }
.dot-assignment { background:var(--info); }
.dot-project    { background:#ab47bc; }

.live-clock {
    font-size:22px; font-weight:900; color:var(--orange);
    font-variant-numeric:tabular-nums; letter-spacing:1px;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="page">

<% if (message != null) { %>
    <div class="msg-success">✅ <%= message %></div>
<% } %>

<!-- HERO -->
<div class="hero">
    <div>
        <h1>Welcome back, <span><%= user.getName().split(" ")[0] %></span> 👋</h1>
        <p>Your all-in-one campus study hub — courses, past papers, Q&amp;A, deadlines and flashcards.</p>
        <div class="hero-actions">
            <a href="CourseServlet"  class="btn btn-primary">🎓 Browse Courses</a>
            <a href="DeadlineServlet" class="btn btn-ghost">📅 My Deadlines</a>
        </div>
    </div>
    <div class="hero-stats">
        <div class="mini-stat">
            <div class="n"><%= myCourses %></div>
            <div class="l">Enrolled Courses</div>
        </div>
        <div class="mini-stat">
            <div class="n"><%= upcomingDL %></div>
            <div class="l">Upcoming Tasks</div>
        </div>
        <% if (overdueDL > 0) { %>
        <div class="mini-stat danger">
            <div class="n"><%= overdueDL %></div>
            <div class="l">⚠️ Overdue</div>
        </div>
        <% } %>
    </div>
</div>

<!-- TWO COLUMN -->
<div class="two-col">

    <!-- LEFT: FEATURE GRID -->
    <div>
        <div class="section-title">📚 Features</div>
        <div class="grid-3" style="gap:14px;">
            <a href="CourseServlet" class="feature-card">
                <span class="icon">🎓</span><h3>Course Hubs</h3>
                <p>Browse courses, enroll and access all material in one hub.</p>
            </a>
            <a href="CourseServlet" class="feature-card">
                <span class="icon">📝</span><h3>Past Exams</h3>
                <p>Upload and download past papers filtered by year and type.</p>
                <span class="hot">🔥 Hot</span>
            </a>
            <a href="CourseServlet" class="feature-card">
                <span class="icon">💬</span><h3>Q&amp;A Forum</h3>
                <p>Ask urgent questions and get threaded, upvoted answers.</p>
            </a>
            <a href="DeadlineServlet" class="feature-card">
                <span class="icon">📅</span><h3>Deadline Tracker</h3>
                <p>Live countdown timers — never miss a due date again.</p>
            </a>
            <a href="FlashcardServlet" class="feature-card">
                <span class="icon">🃏</span><h3>Flashcards</h3>
                <p>Create decks and study with flip-card mode + keyboard shortcuts.</p>
            </a>
            <a href="StudyGroupServlet" class="feature-card">
                <span class="icon">👥</span><h3>Study Groups</h3>
                <p>Create or join groups to collaborate with classmates.</p>
            </a>
            <a href="resources.jsp" class="feature-card">
                <span class="icon">📁</span><h3>Resources</h3>
                <p>Upload and share notes, summaries and cheat sheets.</p>
            </a>
            <a href="profile.jsp" class="feature-card">
                <span class="icon">👤</span><h3>Profile</h3>
                <p>View enrolled courses, decks and pending deadlines.</p>
            </a>
        </div>
    </div>

    <!-- RIGHT: DEADLINE SIDEBAR -->
    <div>
        <!-- Live clock card -->
        <div class="card" style="text-align:center;margin-bottom:16px;padding:18px;">
            <div style="font-size:11px;color:var(--muted);text-transform:uppercase;letter-spacing:1px;margin-bottom:6px;">
                <%= new SimpleDateFormat("EEEE, dd MMMM yyyy").format(new Date()) %>
            </div>
            <div class="live-clock" id="liveClock">00:00:00</div>
        </div>

        <!-- Deadline countdown list -->
        <div class="card" style="padding:16px;">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
                <span style="font-size:15px;font-weight:700;">⏰ Upcoming Deadlines</span>
                <a href="DeadlineServlet" style="font-size:12px;color:var(--orange);text-decoration:none;">View all →</a>
            </div>

            <% if (dlCount == 0) { %>
                <div style="text-align:center;padding:24px 0;color:var(--muted);font-size:13px;">
                    🎉 No upcoming deadlines!
                </div>
            <% } else { %>
                <!-- JS will render countdown items here -->
                <div id="deadlineList"></div>
            <% } %>

            <% if (dlCount > 0) { %>
            <div style="margin-top:12px;border-top:1px solid rgba(255,255,255,.07);padding-top:12px;">
                <a href="DeadlineServlet" class="btn btn-ghost btn-sm" style="width:100%;text-align:center;display:block;">
                    ➕ Add Deadline
                </a>
            </div>
            <% } %>
        </div>
    </div>

</div><!-- end two-col -->
</div><!-- end page -->

<script>
// ── LIVE CLOCK ────────────────────────────────────────────────────────────────
function updateClock() {
    const now = new Date();
    const h = String(now.getHours()).padStart(2,'0');
    const m = String(now.getMinutes()).padStart(2,'0');
    const s = String(now.getSeconds()).padStart(2,'0');
    const el = document.getElementById('liveClock');
    if (el) el.textContent = h + ':' + m + ':' + s;
}
updateClock();
setInterval(updateClock, 1000);

// ── DEADLINE COUNTDOWNS ───────────────────────────────────────────────────────
const DEADLINES = <%= dlJson.toString() %>;

function getUrgency(due) {
    if (!due) return { cls:'urgency-ok', label:'No date', pct:0 };
    const now      = new Date();
    const dueDate  = new Date(due + 'T23:59:59');
    const diffMs   = dueDate - now;
    const diffDays = diffMs / (1000 * 60 * 60 * 24);

    if (diffMs < 0)       return { cls:'urgency-overdue',  label:'OVERDUE',      pct:100 };
    if (diffDays <= 1)    return { cls:'urgency-critical', label:null,            pct:95  };
    if (diffDays <= 3)    return { cls:'urgency-critical', label:null,            pct:80  };
    if (diffDays <= 7)    return { cls:'urgency-soon',     label:null,            pct:50  };
    return                       { cls:'urgency-ok',       label:null,            pct:20  };
}

function formatCountdown(due) {
    if (!due) return '—';
    const now     = new Date();
    const dueDate = new Date(due + 'T23:59:59');
    const diffMs  = dueDate - now;

    if (diffMs < 0) return '⚠️ OVERDUE';

    const days    = Math.floor(diffMs / 86400000);
    const hours   = Math.floor((diffMs % 86400000) / 3600000);
    const minutes = Math.floor((diffMs % 3600000)  / 60000);
    const seconds = Math.floor((diffMs % 60000)    / 1000);

    if (days > 7)  return days + 'd remaining';
    if (days >= 1) return days + 'd ' + hours + 'h ' + minutes + 'm';
    if (hours >= 1)return hours + 'h ' + minutes + 'm ' + seconds + 's';
    return minutes + 'm ' + seconds + 's';
}

function typeColor(type) {
    return { exam:'#e53935', test:'#FF9800', assignment:'#29b6f6', project:'#ab47bc' }[type] || '#555';
}

function getUrgency(due) {
    if (!due) return { cls:'urgency-ok', label:'No date', pct:0 };

    const now = new Date();
    const dueDate = new Date(due + 'T23:59:59');
    const diffMs = dueDate - now;
    const diffDays = diffMs / (1000 * 60 * 60 * 24);

    if (diffMs < 0)
        return { cls:'urgency-overdue', label:'OVERDUE', pct:100 };

    if (diffDays <= 1)
        return { cls:'urgency-critical', label:'DUE SOON', pct:95 };

    if (diffDays <= 3)
        return { cls:'urgency-critical', label:'URGENT', pct:80 };

    if (diffDays <= 7)
        return { cls:'urgency-soon', label:'SOON', pct:50 };

    return { cls:'urgency-ok', label:'ON TRACK', pct:20 };
}

function renderDeadlines() {
    const container = document.getElementById('deadlineList');
    if (!container) return;

    container.innerHTML = DEADLINES.map(d => {
        const urg = getUrgency(d.due);
        const cd  = formatCountdown(d.due);
        const col = typeColor(d.type);

        return `
        <div class="dl-item ${urg.cls}">
            <div class="dl-item-top">

                <div>
                    <div class="dl-item-title">
                        <span class="type-dot" style="background:${col}"></span>
                        ${d.title}
                    </div>

                    <div class="dl-item-course">
                        ${d.course} · ${d.type}
                    </div>
                </div>

                <!-- ✅ URGENCY LABEL ALWAYS VISIBLE -->
                <div class="countdown-badge">
                    ${urg.label}
                </div>

            </div>

            <div style="font-size:11px; color:var(--muted); margin-top:6px;">
                ⏳ ${cd}
            </div>

            <div class="dl-item-bar">
                <div class="dl-item-bar-fill" style="width:${urg.pct}%"></div>
            </div>
        </div>`;
    }).join('');
}

// Update countdowns every second
function tickCountdowns() {
    document.querySelectorAll('.countdown-badge[data-due]').forEach(el => {
        el.textContent = formatCountdown(el.dataset.due);
    });
}

if (DEADLINES.length > 0) {
    renderDeadlines();
    setInterval(tickCountdowns, 1000);
}
</script>
</body>
</html>
