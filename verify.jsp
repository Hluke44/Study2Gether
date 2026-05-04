<h2>Verify OTP</h2>

<form action="VerifyOtpServlet" method="post">
    <input type="text" name="otp" placeholder="Enter OTP" required />
    <button type="submit">Verify</button>
</form>

<% if ("invalid".equals(request.getParameter("error"))) { %>
    <p style="color:red;">Invalid OTP</p>
<% } %>