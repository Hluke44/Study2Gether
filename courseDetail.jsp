<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.*, dao.CourseDAO, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }

    Course course = (Course) request.getAttribute("course");
    List<PastExam> exams = (List<PastExam>) request.getAttribute("exams");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    boolean enrolled = Boolean.TRUE.equals(request.getAttribute("enrolled"));
    int enrollCount = request.getAttribute("enrollCount") != null ? (int) request.getAttribute("enrollCount") : 0;

    if (course == null) { response.sendRedirect("CourseServlet"); return; }
    if (exams == null) exams = new ArrayList<>();
    if (questions == null) questions = new ArrayList<>();

    String message = (String) session.getAttribute("message");
    session.removeAttribute("message");

    String tab = request.getParameter("tab");
    if (tab == null) tab = "exams";

    String yearFilter = request.getParameter("year");
    String typeFilter = request.getParameter("type");
    if (yearFilter == null) yearFilter = "";
    if (typeFilter == null) typeFilter = "";

    boolean isOwner = course.getCreatedBy().equals(user.getName());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%= course.getCode() %> — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.course-header {
    background:linear-gradient(135deg,rgba(255,152,0,.1),transparent);
    border:1px solid var(--card-border); border-radius:var(--radius);
    padding:28px 32px; margin-bottom:24px;
    display:flex; justify-content:space-between; align-items:flex-start; gap:20px;
}
.course-header h1 { font-size:30px; font-weight:800; color:var(--orange); }
.course-header .sub { font-size:17px; color:var(--text); margin-top:4px; }
.course-header .meta-row { display:flex; gap:18px; margin-top:10px; flex-wrap:wrap; }
.course-header .meta-item { font-size:13px; color:var(--muted); }
.header-actions { display:flex; gap:8px; flex-wrap:wrap; }

.exam-card { background:var(--card); border:1px solid var(--card-border);
    border-radius:10px; padding:16px 20px; margin-bottom:14px;
    display:flex; justify-content:space-between; align-items:center; gap:16px; }
.exam-card:hover { border-color:var(--orange); }
.exam-title { font-weight:700; font-size:15px; }
.exam-meta  { font-size:12px; color:var(--muted); margin-top:4px; }
.exam-actions { display:flex; gap:8px; align-items:center; flex-shrink:0; }

.question-card { background:var(--card); border:1px solid var(--card-border);
    border-radius:10px; padding:16px 20px; margin-bottom:14px;
    transition:.2s; }
.question-card:hover { border-color:var(--orange); }
.question-title { font-weight:700; font-size:15px; text-decoration:none; color:var(--text); }
.question-title:hover { color:var(--orange); }
.question-meta  { font-size:12px; color:var(--muted); margin-top:6px; display:flex; gap:14px; flex-wrap:wrap; }

.filter-row { display:flex; gap:10px; margin-bottom:18px; flex-wrap:wrap; align-items:center; }
.filter-row select { width:auto; padding:7px 12px; }
.filter-row label { font-size:13px; color:var(--muted); }

/* File upload drop zone */
.drop-zone {
    border: 2px dashed rgba(255,152,0,.4); border-radius: 10px;
    padding: 22px 14px; text-align: center; cursor: pointer;
    transition: .2s; background: rgba(255,152,0,.03);
    margin-bottom: 14px; position: relative;
}
.drop-zone:hover, .drop-zone.drag-over { border-color: var(--orange); background: rgba(255,152,0,.08); }
.drop-zone input[type="file"] { position:absolute;inset:0;opacity:0;cursor:pointer;width:100%;height:100%; }
.dz-icon  { font-size: 28px; display: block; margin-bottom: 6px; }
.dz-text  { font-size: 12px; color: var(--muted); }
.dz-file  { font-size: 11px; color: var(--orange); margin-top: 5px; font-weight: 600; word-break: break-all; }
.up-prog  { display:none; font-size:12px; color:var(--orange); padding:8px 10px;
    background:rgba(255,152,0,.1); border:1px solid var(--orange); border-radius:7px; margin-top:8px; }
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="page">

<% if (message != null) { %>
    <div class="msg-success">✅ <%= message %></div>
<% } %>

<!-- COURSE HEADER -->
<div class="course-header">
    <div>
        <div class="course-code" style="font-size:13px;color:var(--muted);margin-bottom:4px;">
            <a href="CourseServlet" style="color:var(--muted);text-decoration:none;">← All Courses</a>
        </div>
        <h1><%= course.getCode() %></h1>
        <div class="sub"><%= course.getName() %></div>
        <div class="meta-row">
            <% if (course.getLecturer() != null && !course.getLecturer().isEmpty()) { %>
                <span class="meta-item">👨‍🏫 <%= course.getLecturer() %></span>
            <% } %>
            <% if (course.getSemester() != null && !course.getSemester().isEmpty()) { %>
                <span class="meta-item">📅 <%= course.getSemester() %></span>
            <% } %>
            <span class="meta-item">👥 <%= enrollCount %> students enrolled</span>
            <span class="meta-item">Created by: <%= course.getCreatedBy() %></span>
        </div>
        <% if (course.getDescription() != null && !course.getDescription().isEmpty()) { %>
            <p style="color:var(--muted);font-size:13px;margin-top:8px;"><%= course.getDescription() %></p>
        <% } %>
    </div>
    <div class="header-actions">
        <% if (!enrolled) { %>
            <form method="post" action="CourseServlet">
                <input type="hidden" name="action" value="enroll">
                <input type="hidden" name="id" value="<%= course.getId() %>">
                <button type="submit" class="btn btn-primary">+ Enroll</button>
            </form>
        <% } %>
        <% if (enrolled && !isOwner) { %>
            <form method="post" action="CourseServlet">
                <input type="hidden" name="action" value="unenroll">
                <input type="hidden" name="id" value="<%= course.getId() %>">
                <button type="submit" class="btn btn-ghost">Leave</button>
            </form>
        <% } %>
        <% if (isOwner) { %>
            <form method="post" action="CourseServlet" onsubmit="return confirm('Delete this course?')">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= course.getId() %>">
                <button type="submit" class="btn btn-danger">Delete Course</button>
            </form>
        <% } %>
    </div>
</div>

<!-- TABS -->
<div class="tabs">
    <a class="tab <%= "exams".equals(tab) ? "active" : "" %>"
       href="CourseServlet?view=detail&id=<%= course.getId() %>&tab=exams">
       📝 Past Papers (<%= exams.size() %>)
    </a>
    <a class="tab <%= "qa".equals(tab) ? "active" : "" %>"
       href="CourseServlet?view=detail&id=<%= course.getId() %>&tab=qa">
       💬 Q&amp;A (<%= questions.size() %>)
    </a>
</div>

<!-- ══════════ PAST EXAMS TAB ══════════ -->
<% if ("exams".equals(tab)) { %>

<!-- Filter + Upload side by side -->
<div style="display:grid;grid-template-columns:1fr 300px;gap:24px;align-items:start;">
    <div>
        <!-- Filters -->
        <form method="get" action="CourseServlet" class="filter-row">
            <input type="hidden" name="view" value="detail">
            <input type="hidden" name="id" value="<%= course.getId() %>">
            <input type="hidden" name="tab" value="exams">
            <label>Year:</label>
            <select name="year">
                <option value="">All Years</option>
                <% for (int y = 2025; y >= 2018; y--) { %>
                    <option value="<%= y %>" <%= String.valueOf(y).equals(yearFilter) ? "selected" : "" %>><%= y %></option>
                <% } %>
            </select>
            <label>Type:</label>
            <select name="type">
                <option value="">All Types</option>
                <option value="exam"       <%= "exam".equals(typeFilter) ? "selected" : "" %>>Exam</option>
                <option value="test"       <%= "test".equals(typeFilter) ? "selected" : "" %>>Test</option>
                <option value="memo"       <%= "memo".equals(typeFilter) ? "selected" : "" %>>Memo</option>
                <option value="assignment" <%= "assignment".equals(typeFilter) ? "selected" : "" %>>Assignment</option>
            </select>
            <button type="submit" class="btn btn-ghost btn-sm">Filter</button>
            <a href="CourseServlet?view=detail&id=<%= course.getId() %>&tab=exams" class="btn btn-ghost btn-sm">Clear</a>
        </form>

        <!-- Exam list -->
        <% if (exams.isEmpty()) { %>
            <div class="empty"><div class="icon">📝</div><h3>No past papers yet</h3>
                <p>Be the first to upload one →</p></div>
        <% } %>

        <% for (PastExam e : exams) {
            boolean hasFile = e.getSavedName() != null && !e.getSavedName().isEmpty();
        %>
        <div class="exam-card">
            <div style="flex:1;min-width:0;">
                <div class="exam-title"><%= e.getTitle() %></div>
                <div class="exam-meta">
                    <span class="badge <%= "exam".equals(e.getType()) ? "badge-red" : "memo".equals(e.getType()) ? "badge-green" : "badge-orange" %>">
                        <%= e.getType() %>
                    </span>
                    &nbsp;📅 <%= e.getYear() %>
                    &nbsp;👤 <%= e.getUploadedBy() %>
                    &nbsp;📎 <%= e.getFileName() %>
                    <% if (e.getUploadDate() != null) { %>
                        &nbsp;· <%= e.getUploadDate().substring(0, 10) %>
                    <% } %>
                </div>
            </div>
            <div class="exam-actions">
                <!-- Download button — only shown if a real file was uploaded -->
                <% if (hasFile) { %>
                    <a href="PastExamServlet?download=<%= e.getId() %>"
                       target="_blank" class="btn btn-ghost btn-sm">⬇ Download</a>
                <% } %>

                <!-- Upvote -->
                <span style="color:var(--orange);font-size:13px;font-weight:700;">▲ <%= e.getUpvotes() %></span>
                <form method="post" action="PastExamServlet" style="display:inline;">
                    <input type="hidden" name="action"   value="upvote">
                    <input type="hidden" name="examId"   value="<%= e.getId() %>">
                    <input type="hidden" name="courseId" value="<%= course.getId() %>">
                    <button type="submit" class="upvote-btn">👍 Helpful</button>
                </form>

                <!-- Delete (owner only) -->
                <% if (e.getUploadedBy().equals(user.getName())) { %>
                <form method="post" action="PastExamServlet" style="display:inline;"
                      onsubmit="return confirm('Delete this paper?')">
                    <input type="hidden" name="action"   value="delete">
                    <input type="hidden" name="examId"   value="<%= e.getId() %>">
                    <input type="hidden" name="courseId" value="<%= course.getId() %>">
                    <button type="submit" class="btn btn-danger btn-xs">Delete</button>
                </form>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>

    <!-- Upload sidebar -->
    <div class="card" style="position:sticky;top:80px;">
        <div class="card-title">📤 Upload Past Paper</div>

        <%
        String examError = (String) session.getAttribute("examError");
        session.removeAttribute("examError");
        if (examError != null) { %>
            <div class="msg-error" style="margin-bottom:12px;">⚠️ <%= examError %></div>
        <% } %>

        <form method="post" action="PastExamServlet"
              enctype="multipart/form-data" id="examUploadForm">
            <input type="hidden" name="action"   value="upload">
            <input type="hidden" name="courseId" value="<%= course.getId() %>">

            <!-- Drag-and-drop file zone -->
            <div class="drop-zone" id="examDropZone">
                <input type="file" name="file" id="examFileInput" required
                       accept=".pdf,.doc,.docx,.ppt,.pptx,.zip,.png,.jpg,.jpeg">
                <span class="dz-icon">📄</span>
                <div class="dz-text">Drop file here or click to browse</div>
                <div class="dz-file" id="examFileLabel"></div>
            </div>
            <div class="up-prog" id="examProgress">⏳ Uploading, please wait...</div>

            <div class="form-group">
                <label>Title *</label>
                <input type="text" name="title" id="examTitleInput"
                       placeholder="e.g. June 2023 Final Exam" required>
            </div>
            <div class="form-group">
                <label>Year *</label>
                <select name="year" required>
                    <% for (int y = 2025; y >= 2018; y--) { %>
                        <option value="<%= y %>"><%= y %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label>Type *</label>
                <select name="type" required>
                    <option value="exam">Exam</option>
                    <option value="test">Test</option>
                    <option value="memo">Memo / Solutions</option>
                    <option value="assignment">Assignment</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;" id="examSubmitBtn">
                ⬆ Upload Paper
            </button>
            <p style="font-size:11px;color:var(--muted);margin-top:8px;text-align:center;">
                Max 50 MB · PDF, Word, PPT, Images, ZIP
            </p>
        </form>
    </div>
</div>

<% } %>

<!-- ══════════ Q&A TAB ══════════ -->
<% if ("qa".equals(tab)) { %>

<div style="display:grid;grid-template-columns:1fr 300px;gap:24px;align-items:start;">
    <div>
        <!-- Question list -->
        <% if (questions.isEmpty()) { %>
            <div class="empty"><div class="icon">💬</div><h3>No questions yet</h3>
                <p>Be the first to ask one →</p></div>
        <% } %>

        <% for (Question q : questions) { %>
        <div class="question-card">
            <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;">
                <div style="flex:1;">
                    <% if (q.isUrgent()) { %><span class="urgent-tag">🔥 URGENT</span>&nbsp;<% } %>
                    <a href="QAServlet?id=<%= q.getId() %>" class="question-title"><%= q.getTitle() %></a>
                    <% if (q.getBody() != null && !q.getBody().isEmpty()) { %>
                        <p style="color:var(--muted);font-size:13px;margin-top:5px;"><%= q.getBody().length() > 100 ? q.getBody().substring(0, 100) + "…" : q.getBody() %></p>
                    <% } %>
                    <div class="question-meta">
                        <span>👤 <%= q.getAskedBy() %></span>
                        <span>💬 <%= q.getAnswerCount() %> answers</span>
                        <span>▲ <%= q.getUpvotes() %> upvotes</span>
                        <% if (q.getAskedDate() != null) { %><span>🕐 <%= q.getAskedDate().substring(0, 10) %></span><% } %>
                    </div>
                </div>
                <% if (q.getAnswerCount() > 0) { %>
                    <span class="badge badge-green" style="flex-shrink:0;"><%= q.getAnswerCount() %> ans</span>
                <% } else { %>
                    <span class="badge badge-gray" style="flex-shrink:0;">Unanswered</span>
                <% } %>
            </div>
            <% if (q.getAskedBy().equals(user.getName())) { %>
            <div style="margin-top:10px;">
                <form method="post" action="QAServlet" style="display:inline;">
                    <input type="hidden" name="action" value="deleteQ">
                    <input type="hidden" name="questionId" value="<%= q.getId() %>">
                    <input type="hidden" name="courseId" value="<%= course.getId() %>">
                    <button type="submit" class="btn btn-danger btn-xs">Delete</button>
                </form>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- Ask Question sidebar -->
    <div class="card" style="position:sticky;top:80px;">
        <div class="card-title">❓ Ask a Question</div>
        <form method="post" action="QAServlet">
            <input type="hidden" name="action" value="ask">
            <input type="hidden" name="courseId" value="<%= course.getId() %>">
            <div class="form-group">
                <label>Question Title *</label>
                <input type="text" name="title" placeholder="Short, clear summary" required>
            </div>
            <div class="form-group">
                <label>Details (optional)</label>
                <textarea name="body" placeholder="Add more context..."></textarea>
            </div>
            <div class="form-group" style="display:flex;align-items:center;gap:10px;">
                <input type="checkbox" name="urgent" id="urgent" style="width:auto;padding:0;margin:0;">
                <label for="urgent" style="margin:0;text-transform:none;letter-spacing:0;font-size:13px;color:var(--muted);">🔥 Mark as Urgent</label>
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;">Post Question</button>
        </form>
    </div>
</div>

<% } %>

</div>

<script>
(function() {
    const dropZone  = document.getElementById('examDropZone');
    const fileInput = document.getElementById('examFileInput');
    const fileLabel = document.getElementById('examFileLabel');
    const titleInp  = document.getElementById('examTitleInput');
    const form      = document.getElementById('examUploadForm');
    const progress  = document.getElementById('examProgress');
    const submitBtn = document.getElementById('examSubmitBtn');

    if (!dropZone) return; // not on exams tab

    function onFileChosen(file) {
        if (!file) return;
        fileLabel.textContent = '📎 ' + file.name + ' (' + humanSize(file.size) + ')';
        if (titleInp && !titleInp.value)
            titleInp.value = file.name.replace(/\.[^.]+$/, '').replace(/[_-]/g, ' ');
    }

    fileInput.addEventListener('change', () => onFileChosen(fileInput.files[0]));

    dropZone.addEventListener('dragover',  e => { e.preventDefault(); dropZone.classList.add('drag-over'); });
    dropZone.addEventListener('dragleave', ()  => dropZone.classList.remove('drag-over'));
    dropZone.addEventListener('drop', e => {
        e.preventDefault();
        dropZone.classList.remove('drag-over');
        if (e.dataTransfer.files.length) {
            fileInput.files = e.dataTransfer.files;
            onFileChosen(e.dataTransfer.files[0]);
        }
    });

    form.addEventListener('submit', () => {
        if (!fileInput.files.length) return;
        progress.style.display = 'block';
        submitBtn.disabled = true;
        submitBtn.textContent = 'Uploading...';
    });

    function humanSize(b) {
        if (b < 1024)    return b + ' B';
        if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
        return                  (b / 1048576).toFixed(1) + ' MB';
    }
})();
</script>
</body>
</html>
