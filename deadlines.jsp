<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, dao.CourseDAO, java.util.*, java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    List<Deadline> deadlines = (List<Deadline>) request.getAttribute("deadlines");
    if (deadlines == null) deadlines = new ArrayList<>();

    CourseDAO cDAO = new CourseDAO();
    List<Course> courses = cDAO.getEnrolledCourses(user.getName());

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    String todayStr = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

    List<Deadline> pending  = new ArrayList<>();
    List<Deadline> done     = new ArrayList<>();
    int overdue = 0;
    for (Deadline d : deadlines) {
        if (d.isDone()) done.add(d);
        else {
            pending.add(d);
            if (d.getDueDate() != null && d.getDueDate().compareTo(todayStr) < 0) overdue++;
        }
    }

    // Build JSON for JS countdowns
    StringBuilder dlJson = new StringBuilder("[");
    for (int i = 0; i < pending.size(); i++) {
        Deadline d = pending.get(i);
        String title  = d.getTitle().replace("\\","\\\\").replace("\"","\\\"");
        String course = d.getCourseName() != null ? d.getCourseName().replace("\"","\\\"") : "General";
        String type   = d.getType() != null ? d.getType() : "assignment";
        if (i > 0) dlJson.append(",");
        dlJson.append("{")
              .append("\"id\":").append(d.getId()).append(",")
              .append("\"title\":\"").append(title).append("\",")
              .append("\"course\":\"").append(course).append("\",")
              .append("\"type\":\"").append(type).append("\",")
              .append("\"due\":\"").append(d.getDueDate() != null ? d.getDueDate() : "").append("\",")
              .append("\"done\":false")
              .append("}");
    }
    dlJson.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Deadlines — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>

/* ── STATS ── */
.stats-strip { display:flex; gap:14px; margin-bottom:28px; flex-wrap:wrap; }
.stat-pill {
    flex:1; min-width:90px;
    background:var(--card); border:1px solid var(--card-border);
    border-radius:12px; padding:16px 18px; text-align:center; transition:.2s;
}
.stat-pill.danger { border-color:var(--danger); background:rgba(229,57,53,.08); }
.stat-pill.success{ border-color:var(--success); background:rgba(76,175,80,.07); }
.stat-pill .n { font-size:28px; font-weight:900; color:var(--orange); }
.stat-pill.danger  .n { color:var(--danger); }
.stat-pill.success .n { color:var(--success); }
.stat-pill .l { font-size:11px; color:var(--muted); margin-top:2px; }

/* ── DEADLINE CARD ── */
.dl-card {
    border-radius:var(--radius); padding:16px 20px; margin-bottom:10px;
    border:1px solid var(--card-border); background:var(--card);
    display:flex; align-items:center; gap:14px; transition:.2s; position:relative;
    overflow:hidden;
}
.dl-card::before {
    content:''; position:absolute; left:0; top:0; bottom:0; width:4px;
}
.dl-card.urgency-overdue::before  { background:var(--danger); }
.dl-card.urgency-critical::before { background:#ff7043; }
.dl-card.urgency-soon::before     { background:var(--orange); }
.dl-card.urgency-ok::before       { background:var(--success); }
.dl-card.done-card { opacity:.4; }
.dl-card.done-card::before { background:#555; }

.dl-card:hover { border-color:var(--orange); }

.dl-type-icon { font-size:22px; flex-shrink:0; width:36px; text-align:center; }
.dl-info { flex:1; min-width:0; }
.dl-title { font-size:15px; font-weight:700; }
.dl-title.strikethrough { text-decoration:line-through; color:var(--muted); }
.dl-meta  { font-size:12px; color:var(--muted); margin-top:3px; display:flex; gap:10px; flex-wrap:wrap; }

.dl-countdown {
    text-align:right; flex-shrink:0; min-width:110px;
}
.dl-countdown .cd-label { font-size:10px; color:var(--muted); text-transform:uppercase; letter-spacing:.5px; }
.dl-countdown .cd-value {
    font-size:13px; font-weight:700; font-variant-numeric:tabular-nums;
    margin-top:2px; white-space:nowrap;
}
.urgency-overdue  .cd-value { color:var(--danger); }
.urgency-critical .cd-value { color:#ff7043; }
.urgency-soon     .cd-value { color:var(--orange); }
.urgency-ok       .cd-value { color:var(--success); }

.dl-actions { display:flex; gap:6px; flex-shrink:0; }

/* ── URGENCY LABEL ── */
.urgency-pill {
    font-size:10px; font-weight:700; padding:2px 7px; border-radius:20px;
    text-transform:uppercase; letter-spacing:.5px;
}
.pill-overdue  { background:rgba(229,57,53,.2);  color:#ef9a9a; border:1px solid var(--danger); }
.pill-critical { background:rgba(255,112,67,.2); color:#ffab91; border:1px solid #ff7043; }
.pill-soon     { background:rgba(255,152,0,.15); color:var(--orange); border:1px solid var(--orange); }
.pill-ok       { background:rgba(76,175,80,.15); color:#a5d6a7; border:1px solid var(--success); }

/* ── SECTION LABEL ── */
.section-label {
    font-size:12px; font-weight:700; color:var(--muted);
    text-transform:uppercase; letter-spacing:1px;
    margin:20px 0 10px; display:flex; align-items:center; gap:8px;
}
.section-label::after { content:''; flex:1; height:1px; background:rgba(255,255,255,.07); }

/* ── PROGRESS BAR ── */
.progress-wrap { margin-bottom:20px; }
.progress-bar-bg { height:8px; background:rgba(255,255,255,.08); border-radius:4px; overflow:hidden; }
.progress-bar-fill { height:100%; background:linear-gradient(90deg,var(--orange),#ff6f00); border-radius:4px; transition:width .4s; }
.progress-label { display:flex; justify-content:space-between; font-size:12px; color:var(--muted); margin-bottom:6px; }

/* ── TYPE ICONS ── */
.type-icon-exam       { color:var(--danger); }
.type-icon-test       { color:var(--orange); }
.type-icon-assignment { color:var(--info); }
.type-icon-project    { color:#ab47bc; }
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
        <h1>📅 Deadline Tracker</h1>
        <p>Live countdowns for all your assignments, tests, exams and projects</p>
    </div>
</div>

<!-- STATS -->
<div class="stats-strip">
    <div class="stat-pill <%= overdue > 0 ? "danger" : "" %>">
        <div class="n"><%= overdue %></div>
        <div class="l"><%= overdue > 0 ? "⚠️ Overdue" : "Overdue" %></div>
    </div>
    <div class="stat-pill">
        <div class="n"><%= pending.size() - overdue %></div>
        <div class="l">Upcoming</div>
    </div>
    <div class="stat-pill success">
        <div class="n"><%= done.size() %></div>
        <div class="l">✅ Completed</div>
    </div>
    <div class="stat-pill">
        <div class="n"><%= deadlines.size() %></div>
        <div class="l">Total</div>
    </div>
</div>

<!-- COMPLETION PROGRESS -->
<% if (!deadlines.isEmpty()) {
    int pct = (int)((done.size() * 100.0) / deadlines.size());
%>
<div class="progress-wrap">
    <div class="progress-label">
        <span>Overall Progress</span>
        <span><%= done.size() %> / <%= deadlines.size() %> completed (<%= pct %>%)</span>
    </div>
    <div class="progress-bar-bg">
        <div class="progress-bar-fill" style="width:<%= pct %>%"></div>
    </div>
</div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 300px;gap:28px;align-items:start;">

<!-- LEFT: DEADLINE LIST -->
<div>

<% if (pending.isEmpty() && done.isEmpty()) { %>
    <div class="empty">
        <div class="icon">🎉</div>
        <h3>No deadlines yet</h3>
        <p>Add your first deadline using the form →</p>
    </div>
<% } %>

<!-- PENDING (rendered by JS for live countdowns) -->
<% if (!pending.isEmpty()) { %>
<div class="section-label">⏳ Pending (<%= pending.size() %>)</div>
<div id="pendingList">
    <%-- Static fallback, replaced by JS --%>
    <% for (Deadline d : pending) {
        String type = d.getType() != null ? d.getType() : "assignment";
        String emoji = "exam".equals(type) ? "📝" : "test".equals(type) ? "🧪" : "project".equals(type) ? "🗂️" : "📋";
        boolean isOverdue = d.getDueDate() != null && d.getDueDate().compareTo(todayStr) < 0;
        boolean isToday   = d.getDueDate() != null && d.getDueDate().equals(todayStr);
        String urgClass   = isOverdue ? "urgency-overdue" : isToday ? "urgency-critical" : "urgency-soon";
    %>
    <div class="dl-card <%= urgClass %>" id="dl-<%= d.getId() %>">
        <div class="dl-type-icon type-icon-<%= type %>"><%= emoji %></div>
        <div class="dl-info">
            <div class="dl-title"><%= d.getTitle() %></div>
            <div class="dl-meta">
                <span><%= d.getCourseName() != null ? d.getCourseName() : "General" %></span>
                <span class="badge badge-<%= "exam".equals(type) ? "red" : "test".equals(type) ? "orange" : "blue" %>"><%= type %></span>
                <% if (isOverdue) { %><span class="urgency-pill pill-overdue">Overdue</span><% } %>
                <% if (!isOverdue && isToday) { %><span class="urgency-pill pill-critical">Due Today!</span><% } %>
            </div>
        </div>
        <div class="dl-countdown">
            <div class="cd-label">Time left</div>
            <div class="cd-value" data-due="<%= d.getDueDate() %>">
                <%= isOverdue ? "⚠️ OVERDUE" : "Loading..." %>
            </div>
        </div>
        <div class="dl-actions">
            <form method="post" action="DeadlineServlet">
                <input type="hidden" name="action" value="toggle">
                <input type="hidden" name="id" value="<%= d.getId() %>">
                <button type="submit" class="btn btn-success btn-xs" title="Mark done">✔</button>
            </form>
            <form method="post" action="DeadlineServlet">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= d.getId() %>">
                <button type="submit" class="btn btn-danger btn-xs"
                        onclick="return confirm('Delete this deadline?')" title="Delete">✕</button>
            </form>
        </div>
    </div>
    <% } %>
</div>
<% } %>

<!-- DONE -->
<% if (!done.isEmpty()) { %>
<div class="section-label">✅ Completed (<%= done.size() %>)</div>
<% for (Deadline d : done) {
    String type = d.getType() != null ? d.getType() : "assignment";
    String emoji = "exam".equals(type) ? "📝" : "test".equals(type) ? "🧪" : "project".equals(type) ? "🗂️" : "📋";
%>
<div class="dl-card done-card">
    <div class="dl-type-icon" style="opacity:.5"><%= emoji %></div>
    <div class="dl-info">
        <div class="dl-title strikethrough"><%= d.getTitle() %></div>
        <div class="dl-meta">
            <span><%= d.getCourseName() != null ? d.getCourseName() : "General" %></span>
            <span>📅 <%= d.getDueDate() %></span>
        </div>
    </div>
    <div class="dl-actions">
        <form method="post" action="DeadlineServlet">
            <input type="hidden" name="action" value="toggle">
            <input type="hidden" name="id" value="<%= d.getId() %>">
            <button type="submit" class="btn btn-ghost btn-xs" title="Mark undone">↩</button>
        </form>
        <form method="post" action="DeadlineServlet">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= d.getId() %>">
            <button type="submit" class="btn btn-danger btn-xs"
                    onclick="return confirm('Delete?')" title="Delete">✕</button>
        </form>
    </div>
</div>
<% } %>
<% } %>

</div><!-- end left -->

<!-- RIGHT: ADD FORM -->
<div>
    <div class="card" style="position:sticky;top:80px;">
        <div class="card-title">➕ Add Deadline</div>
        <form method="post" action="DeadlineServlet">
            <input type="hidden" name="action" value="add">
            <div class="form-group">
                <label>Title *</label>
                <input type="text" name="title" placeholder="e.g. Java Assignment 2" required>
            </div>
            <div class="form-group">
                <label>Due Date *</label>
                <input type="date" name="dueDate" required
                       min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            </div>
            <div class="form-group">
                <label>Type</label>
                <select name="type">
                    <option value="assignment">📋 Assignment</option>
                    <option value="test">🧪 Test</option>
                    <option value="exam">📝 Exam</option>
                    <option value="project">🗂️ Project</option>
                </select>
            </div>
            <div class="form-group">
                <label>Course (optional)</label>
                <select name="courseId">
                    <option value="">— General —</option>
                    <% for (Course c : courses) { %>
                        <option value="<%= c.getId() %>"><%= c.getCode() %> – <%= c.getName() %></option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;">Add Deadline</button>
        </form>
    </div>

    <!-- Urgency legend -->
    <div class="card" style="margin-top:16px;">
        <div class="card-title" style="margin-bottom:12px;">🎨 Colour Guide</div>
        <div style="display:flex;flex-direction:column;gap:8px;font-size:13px;">
            <div style="display:flex;align-items:center;gap:10px;">
                <div style="width:14px;height:14px;border-radius:3px;background:var(--danger);flex-shrink:0;"></div>
                <span style="color:var(--muted);">Overdue — past due date</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <div style="width:14px;height:14px;border-radius:3px;background:#ff7043;flex-shrink:0;"></div>
                <span style="color:var(--muted);">Critical — due within 3 days</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <div style="width:14px;height:14px;border-radius:3px;background:var(--orange);flex-shrink:0;"></div>
                <span style="color:var(--muted);">Soon — due within 7 days</span>
            </div>
            <div style="display:flex;align-items:center;gap:10px;">
                <div style="width:14px;height:14px;border-radius:3px;background:var(--success);flex-shrink:0;"></div>
                <span style="color:var(--muted);">OK — more than 7 days away</span>
            </div>
        </div>
    </div>
</div>

</div><!-- end grid -->
</div><!-- end page -->

<script>
// ── COUNTDOWN ENGINE ──────────────────────────────────────────────────────────
function getUrgencyClass(due) {
    if (!due) return 'urgency-ok';
    const now  = new Date();
    const end  = new Date(due + 'T23:59:59');
    const diff = end - now;
    const days = diff / 86400000;
    if (diff < 0)    return 'urgency-overdue';
    if (days <= 3)   return 'urgency-critical';
    if (days <= 7)   return 'urgency-soon';
    return 'urgency-ok';
}

function formatCountdown(due) {
    if (!due) return '—';
    const now  = new Date();
    const end  = new Date(due + 'T23:59:59');
    const diff = end - now;
    if (diff < 0) return '⚠️ OVERDUE';
    const d = Math.floor(diff / 86400000);
    const h = Math.floor((diff % 86400000) / 3600000);
    const m = Math.floor((diff % 3600000)  / 60000);
    const s = Math.floor((diff % 60000)    / 1000);
    if (d > 7)  return d + ' days left';
    if (d >= 1) return d + 'd ' + h + 'h ' + m + 'm';
    if (h >= 1) return h + 'h ' + m + 'm ' + s + 's';
    return m + 'm ' + s + 's';
}

function tick() {
    document.querySelectorAll('.cd-value[data-due]').forEach(el => {
        const due = el.dataset.due;
        if (!due) return;
        el.textContent = formatCountdown(due);
        // Update card urgency class
        const card = el.closest('.dl-card');
        if (card) {
            ['urgency-overdue','urgency-critical','urgency-soon','urgency-ok']
                .forEach(c => card.classList.remove(c));
            card.classList.add(getUrgencyClass(due));
        }
    });
}

tick();
setInterval(tick, 1000);
</script>
</body>
</html>
