<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User, model.UploadedFile, model.Course, dao.UploadedFileDAO, dao.CourseDAO, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect("login.jsp"); return; }
    String username = user.getName();

    String message   = (String) session.getAttribute("message");
    String uploadErr = (String) session.getAttribute("uploadError");
    session.removeAttribute("message");
    session.removeAttribute("uploadError");

    String search     = request.getParameter("search");
    String typeFilter = request.getParameter("type");
    if (search == null)     search = "";
    if (typeFilter == null) typeFilter = "";

    // Load from DB — persists across restarts
    UploadedFileDAO fileDAO = new UploadedFileDAO();
    List<UploadedFile> files = fileDAO.search(
        search.isEmpty()     ? null : search,
        typeFilter.isEmpty() ? null : typeFilter
    );

    CourseDAO cDAO = new CourseDAO();
    List<Course> courses = cDAO.getAllCourses();

    // Build course lookup map
    Map<Integer,String> courseMap = new HashMap<>();
    for (Course c : courses) courseMap.put(c.getId(), c.getCode());

    Map<String,String> typeIcons = new LinkedHashMap<>();
    typeIcons.put("notes","📒");
    typeIcons.put("summary","📋");
    typeIcons.put("pastpaper","📝");
    typeIcons.put("cheatsheet","⚡");
    typeIcons.put("other","📦");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Resources — StudyPlatform</title>
<link rel="stylesheet" href="CSS/global.css">
<style>
.type-tab {
    padding: 6px 14px; border-radius: 20px; font-size: 12px; font-weight: 600;
    cursor: pointer; text-decoration: none; color: var(--muted);
    border: 1px solid transparent; transition: .2s;
}
.type-tab:hover, .type-tab.active {
    color: var(--orange); border-color: var(--orange); background: var(--orange-light);
}
.resource-card {
    background: var(--card); border: 1px solid var(--card-border);
    border-radius: var(--radius); padding: 16px 20px; margin-bottom: 12px;
    display: flex; align-items: center; gap: 16px; transition: .2s;
}
.resource-card:hover { border-color: var(--orange); }
.r-icon  { font-size: 30px; flex-shrink: 0; }
.r-title { font-size: 15px; font-weight: 700; }
.r-meta  { font-size: 12px; color: var(--muted); margin-top: 4px; display: flex; gap: 12px; flex-wrap: wrap; }
.r-actions { display: flex; gap: 8px; flex-shrink: 0; align-items: center; margin-left: auto; }

.type-notes      { border-left: 3px solid var(--info); }
.type-summary    { border-left: 3px solid #ab47bc; }
.type-pastpaper  { border-left: 3px solid var(--danger); }
.type-cheatsheet { border-left: 3px solid var(--orange); }
.type-other      { border-left: 3px solid #555; }

.drop-zone {
    border: 2px dashed rgba(255,152,0,.4); border-radius: 10px;
    padding: 28px 16px; text-align: center; cursor: pointer;
    transition: .2s; background: rgba(255,152,0,.03);
    margin-bottom: 14px; position: relative;
}
.drop-zone:hover, .drop-zone.drag-over { border-color: var(--orange); background: rgba(255,152,0,.08); }
.drop-zone input[type="file"] { position: absolute; inset: 0; opacity: 0; cursor: pointer; width: 100%; height: 100%; }
.drop-zone .dz-icon { font-size: 32px; display: block; margin-bottom: 8px; }
.drop-zone .dz-text { font-size: 13px; color: var(--muted); }
.drop-zone .dz-file { font-size: 12px; color: var(--orange); margin-top: 6px; font-weight: 600; }

.upload-progress {
    display: none; background: rgba(255,152,0,.1); border: 1px solid var(--orange);
    border-radius: 8px; padding: 10px 14px; font-size: 13px; color: var(--orange);
    margin-top: 10px; align-items: center; gap: 10px;
}
.spinner {
    width: 16px; height: 16px; border: 2px solid rgba(255,152,0,.3);
    border-top-color: var(--orange); border-radius: 50%;
    animation: spin .7s linear infinite; flex-shrink: 0;
}
@keyframes spin { to { transform: rotate(360deg); } }

.count-badge {
    background: var(--orange-light); color: var(--orange);
    border: 1px solid var(--card-border); border-radius: 20px;
    font-size: 11px; padding: 2px 10px; font-weight: 600;
}
</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>

<div class="page">

<% if (message != null) { %>
    <div class="msg-success"><%= message %></div>
<% } %>
<% if (uploadErr != null) { %>
    <div class="msg-error">⚠️ <%= uploadErr %></div>
<% } %>

<div class="page-header">
    <div>
        <h1>📁 Shared Resources <span class="count-badge"><%= files.size() %></span></h1>
        <p>Upload and share notes, summaries, past papers and cheat sheets ---</p>
    </div>
</div>

<div style="display:grid;grid-template-columns:1fr 320px;gap:28px;align-items:start;">

<!-- ── LEFT: RESOURCE LIST ── -->
<div>
    <!-- Search -->
    <form method="get" action="resources.jsp" class="search-box" style="margin-bottom:16px;">
        <input type="text" name="search" placeholder="Search by title, description or filename..." value="<%= search %>">
        <input type="hidden" name="type" value="<%= typeFilter %>">
        <button type="submit" class="btn btn-primary btn-sm">Search</button>
        <% if (!search.isEmpty() || !typeFilter.isEmpty()) { %>
            <a href="resources.jsp" class="btn btn-ghost btn-sm">Clear</a>
        <% } %>
    </form>

    <!-- Type filter tabs -->
    <div style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:20px;">
        <a href="resources.jsp?search=<%= search %>&type="           class="type-tab <%= typeFilter.isEmpty()           ? "active" : "" %>">All</a>
        <a href="resources.jsp?search=<%= search %>&type=notes"      class="type-tab <%= "notes".equals(typeFilter)      ? "active" : "" %>">📒 Notes</a>
        <a href="resources.jsp?search=<%= search %>&type=summary"    class="type-tab <%= "summary".equals(typeFilter)    ? "active" : "" %>">📋 Summaries</a>
        <a href="resources.jsp?search=<%= search %>&type=pastpaper"  class="type-tab <%= "pastpaper".equals(typeFilter)  ? "active" : "" %>">📝 Past Papers</a>
        <a href="resources.jsp?search=<%= search %>&type=cheatsheet" class="type-tab <%= "cheatsheet".equals(typeFilter) ? "active" : "" %>">⚡ Cheat Sheets</a>
        <a href="resources.jsp?search=<%= search %>&type=other"      class="type-tab <%= "other".equals(typeFilter)      ? "active" : "" %>">📦 Other</a>
    </div>

    <!-- File cards -->
    <% if (files.isEmpty()) { %>
        <div class="empty">
            <div class="icon">📁</div>
            <h3><%= (!search.isEmpty() || !typeFilter.isEmpty()) ? "No results found" : "No resources yet" %></h3>
            <p><%= (!search.isEmpty() || !typeFilter.isEmpty()) ? "Try a different search or filter" : "Upload the first one using the form →" %></p>
        </div>
    <% } %>

    <% for (UploadedFile f : files) {
        String icon = typeIcons.getOrDefault(f.getFileType(), "📦");
        String ext  = f.getOriginalName().contains(".")
            ? f.getOriginalName().substring(f.getOriginalName().lastIndexOf('.') + 1).toUpperCase()
            : "FILE";
        String courseLabel = f.getCourseId() > 0 ? courseMap.get(f.getCourseId()) : null;
        String dateStr = f.getUploadedAt() != null && f.getUploadedAt().length() >= 10
            ? f.getUploadedAt().substring(0, 10) : "";
    %>
    <div class="resource-card type-<%= f.getFileType() %>">
        <div class="r-icon"><%= icon %></div>
        <div style="flex:1;min-width:0;">
            <div class="r-title"><%= f.getTitle() %></div>
            <% if (f.getDescription() != null && !f.getDescription().isEmpty()) { %>
                <p style="font-size:13px;color:var(--muted);margin:3px 0;"><%= f.getDescription() %></p>
            <% } %>
            <div class="r-meta">
                <span>📎 <%= f.getOriginalName() %></span>
                <% if (f.getFileSize() != null && !f.getFileSize().isEmpty()) { %>
                    <span>💾 <%= f.getFileSize() %></span>
                <% } %>
                <span>👤 <%= f.getUploadedBy() %></span>
                <% if (courseLabel != null) { %>
                    <span>🎓 <%= courseLabel %></span>
                <% } %>
                <% if (!dateStr.isEmpty()) { %>
                    <span>📅 <%= dateStr %></span>
                <% } %>
                <span class="badge badge-orange"><%= ext %></span>
            </div>
        </div>
        <div class="r-actions">
            <a href="FileServlet?file=<%= java.net.URLEncoder.encode(f.getSavedName(), "UTF-8") %>"
               target="_blank" class="btn btn-ghost btn-sm">⬇ Download</a>
            <% if (f.getUploadedBy().equals(username)) { %>
                <form method="post" action="FileServlet">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%= f.getId() %>">
                    <button type="submit" class="btn btn-danger btn-xs"
                            onclick="return confirm('Delete this file permanently?')">✕</button>
                </form>
            <% } %>
        </div>
    </div>
    <% } %>
</div>

<!-- ── RIGHT: UPLOAD FORM ── -->
<div class="card" style="position:sticky;top:80px;">
    <div class="card-title">📤 Upload Resource</div>
    <p style="font-size:12px;color:var(--muted);margin-bottom:14px;">
        Files are saved permanently to the database — they survive server restarts.
    </p>

    <form method="post" action="FileServlet" enctype="multipart/form-data" id="uploadForm">
        <input type="hidden" name="action" value="upload">

        <!-- Drag-and-drop zone -->
        <div class="drop-zone" id="dropZone">
            <input type="file" name="file" id="fileInput" required
                   accept=".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.txt,.png,.jpg,.jpeg,.zip">
            <span class="dz-icon">☁️</span>
            <div class="dz-text">Drag &amp; drop your file here<br><small>or click to browse</small></div>
            <div class="dz-file" id="fileLabel"></div>
        </div>

        <div class="upload-progress" id="uploadProgress">
            <div class="spinner"></div>
            <span>Uploading and saving to database...</span>
        </div>

        <div class="form-group">
            <label>Title *</label>
            <input type="text" name="title" id="titleInput" placeholder="e.g. Week 3 Lecture Notes" required>
        </div>
        <div class="form-group">
            <label>Type</label>
            <select name="type">
                <option value="notes">📒 Notes</option>
                <option value="summary">📋 Summary</option>
                <option value="pastpaper">📝 Past Paper</option>
                <option value="cheatsheet">⚡ Cheat Sheet</option>
                <option value="other">📦 Other</option>
            </select>
        </div>
        <div class="form-group">
            <label>Description</label>
            <textarea name="description" placeholder="Brief description..." rows="2"></textarea>
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

        <button type="submit" class="btn btn-primary" style="width:100%;" id="submitBtn">
            ⬆ Upload File
        </button>
        <p style="font-size:11px;color:var(--muted);margin-top:8px;text-align:center;">
            Max 20 MB · PDF, Word, PPT, Excel, Images, ZIP
        </p>
    </form>
</div>

</div>
</div>

<script>
const dropZone   = document.getElementById('dropZone');
const fileInput  = document.getElementById('fileInput');
const fileLabel  = document.getElementById('fileLabel');
const titleInput = document.getElementById('titleInput');
const uploadForm = document.getElementById('uploadForm');
const progress   = document.getElementById('uploadProgress');
const submitBtn  = document.getElementById('submitBtn');

fileInput.addEventListener('change', () => {
    const f = fileInput.files[0];
    if (!f) return;
    fileLabel.textContent = '📎 ' + f.name + ' (' + humanSize(f.size) + ')';
    if (!titleInput.value)
        titleInput.value = f.name.replace(/\.[^.]+$/, '').replace(/[_-]/g, ' ');
});

dropZone.addEventListener('dragover', e => { e.preventDefault(); dropZone.classList.add('drag-over'); });
dropZone.addEventListener('dragleave', () => dropZone.classList.remove('drag-over'));
dropZone.addEventListener('drop', e => {
    e.preventDefault();
    dropZone.classList.remove('drag-over');
    if (e.dataTransfer.files.length) {
        fileInput.files = e.dataTransfer.files;
        fileInput.dispatchEvent(new Event('change'));
    }
});

uploadForm.addEventListener('submit', () => {
    if (!fileInput.files.length) return;
    progress.style.display = 'flex';
    submitBtn.disabled = true;
    submitBtn.textContent = 'Uploading...';
});

function humanSize(b) {
    if (b < 1024)    return b + ' B';
    if (b < 1048576) return (b/1024).toFixed(1) + ' KB';
    return                  (b/1048576).toFixed(1) + ' MB';
}
</script>
</body>
</html>
