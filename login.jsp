<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<%
    User existing = (User) session.getAttribute("user");
    if (existing != null) { response.sendRedirect("home.jsp"); return; }
    String error      = request.getParameter("error");
    String registered = request.getParameter("registered");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>StudyPlatform — Login</title>

<link rel="stylesheet" href="CSS/global.css">
<style>
    
body { display:flex; flex-direction:column; min-height:100vh; }
.auth-nav {
    display:flex; align-items:center; padding:0 48px; height:60px;
    background:rgba(0,0,0,.6); border-bottom:1px solid var(--card-border);
}
.auth-nav .logo { font-size:22px; font-weight:800; color:var(--orange); text-decoration:none; }
.auth-nav .logo span { color:#fff; }

.auth-wrap {
    flex:1; display:flex; align-items:center; justify-content:center; padding:40px 20px;
}

/* Flip card */
.scene { width:400px; perspective:1200px; }
.flip-card {
    width:100%; position:relative;
    transform-style:preserve-3d; transition:0.65s cubic-bezier(0.4,0,0.2,1);
}
.flip-card.flipped { transform:rotateY(180deg); }
.flip-face {
    width:100%; backface-visibility:hidden;
    background:rgba(10,10,10,.92); border:1px solid var(--card-border);
    border-radius:16px; padding:36px 32px;
}
.flip-face-back { transform:rotateY(180deg); position:absolute; top:0; left:0; }

.auth-title { font-size:22px; font-weight:800; color:var(--orange); margin-bottom:22px; }
.auth-title span { color:var(--text); font-weight:400; font-size:14px; display:block; margin-top:3px; }

.form-group { margin-bottom:16px; }
.form-group label { font-size:12px; color:var(--muted); display:block; margin-bottom:5px; text-transform:uppercase; letter-spacing:.5px; }
.form-group input { width:100%; }

.auth-btn {
    width:100%; padding:11px; background:var(--orange); color:#000;
    border:none; border-radius:8px; font-size:15px; font-weight:700;
    cursor:pointer; transition:.2s; margin-top:4px;
}
.auth-btn:hover { background:var(--orange-dark); color:#fff; }

.switch-link { margin-top:16px; font-size:13px; color:var(--muted); text-align:center; }
.switch-link a { color:var(--orange); cursor:pointer; text-decoration:none; font-weight:600; }
.switch-link a:hover { text-decoration:underline; }

.msg { font-size:13px; padding:10px 12px; border-radius:8px; margin-bottom:16px; }
.msg.error   { background:rgba(229,57,53,.15); border:1px solid var(--danger); color:#ef9a9a; }
.msg.success { background:rgba(76,175,80,.15);  border:1px solid var(--success); color:#a5d6a7; }

.feature-strip {
    display:flex; gap:20px; justify-content:center; flex-wrap:wrap;
    padding:20px 48px 32px; opacity:.7;
}
.feature-strip .f { font-size:12px; color:var(--muted); text-align:center; }
.feature-strip .f .fi { font-size:20px; margin-bottom:4px; }
</style>
</head>
<body>

<nav class="auth-nav">
    <a href="login.jsp" class="logo">STUDY<span>2GETHER</span></a>
</nav>

<div class="auth-wrap">
<div class="scene">
<div class="flip-card" id="flipCard">

<!-- LOGIN FACE -->
<div class="flip-face">
    <div class="auth-title">Welcome back 👋<span>Sign in to your account</span></div>

    <% if ("true".equals(registered)) { %>
        <div class="msg success">✅ Account created! Please log in.</div>
    <% } %>
    <% if ("invalid".equals(error)) { %>
        <div class="msg error">❌ Invalid email or password.</div>
    <% } else if ("empty".equals(error)) { %>
        <div class="msg error">⚠️ Please fill in all fields.</div>
    <% } %>

    <form action="LoginServlet" method="post">
        <div class="form-group">
            <label>Email</label>
            <input type="email" name="email" placeholder="student@university.ac.za" required>
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Your password" required>
        </div>
        <button type="submit" class="auth-btn">Login →</button>
    </form>
    <div class="switch-link">Don't have an account? <a onclick="flip()">Register here</a></div>
</div>

<!-- REGISTER FACE -->
<div class="flip-face flip-face-back">
    <div class="auth-title">Create Account 🎓<span>Join the study community</span></div>

    <% if ("taken".equals(error)) { %>
        <div class="msg error">❌ That email is already registered.</div>
    <% } else if ("empty".equals(error)) { %>
        <div class="msg error">⚠️ Please fill in all fields.</div>
    <% } %>

    <form action="RegisterServlet" method="post">
        <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="name" placeholder="Your full name" required>
        </div>
        <div class="form-group">
            <label>Email</label>
            <input type="email" name="email" placeholder="student@university.ac.za" required>
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" placeholder="Create a password" required>
        </div>
        <button type="submit" class="auth-btn">Create Account →</button>
    </form>
    <div class="switch-link">Already have an account? <a onclick="flip()">Login here</a></div>
</div>

</div><!-- flip-card -->
</div><!-- scene -->
</div><!-- auth-wrap -->

<div class="feature-strip">
    <div class="f"><div class="fi">🎓</div>Course Hubs</div>
    <div class="f"><div class="fi">📝</div>Past Exams</div>
    <div class="f"><div class="fi">💬</div>Q&amp;A Forum</div>
    <div class="f"><div class="fi">📅</div>Deadlines</div>
    <div class="f"><div class="fi">🃏</div>Flashcards</div>
    <div class="f"><div class="fi">👥</div>Study Groups</div>
</div>

<script>
// If register error, show the register face automatically
<% if ("taken".equals(error) || ("empty".equals(error) && request.getHeader("referer") != null && request.getHeader("referer").contains("Register"))) { %>
document.getElementById('flipCard').classList.add('flipped');
<% } %>
function flip() { document.getElementById('flipCard').classList.toggle('flipped'); }
</script>
</body>
</html>
