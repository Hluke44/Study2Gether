package controller;

import dao.PastExamDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.PastExam;
import model.User;

import java.io.*;
import java.nio.file.*;

@WebServlet("/PastExamServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB
    maxFileSize       = 50 * 1024 * 1024,  // 50 MB — exams can be large
    maxRequestSize    = 55 * 1024 * 1024
)
public class PastExamServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "studyplatform_exams";
    private final PastExamDAO dao = new PastExamDAO();

    private Path getUploadPath() throws IOException {
        Path dir = Paths.get(System.getProperty("java.io.tmpdir"), UPLOAD_DIR);
        Files.createDirectories(dir);
        return dir;
    }

    // ── UPLOAD / UPVOTE / DELETE ─────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        User user = (User) session.getAttribute("user");
        String username = user.getName();
        String action   = request.getParameter("action");
        String courseId = request.getParameter("courseId");

        if ("upload".equals(action)) {
            String title  = request.getParameter("title");
            String year   = request.getParameter("year");
            String type   = request.getParameter("type");
            Part   file   = request.getPart("file");

            if (file == null || file.getSize() == 0) {
                session.setAttribute("examError", "Please select a file to upload.");
                response.sendRedirect("CourseServlet?view=detail&id=" + courseId + "&tab=exams");
                return;
            }
            if (title == null || title.isBlank()) {
                session.setAttribute("examError", "Please enter a title.");
                response.sendRedirect("CourseServlet?view=detail&id=" + courseId + "&tab=exams");
                return;
            }

            // Sanitise filename and save to disk
            String originalName = Paths.get(file.getSubmittedFileName()).getFileName().toString();
            String safeName     = System.currentTimeMillis() + "_"
                                  + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");

            Path dest = getUploadPath().resolve(safeName);
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }

            PastExam exam = new PastExam(
                0, Integer.parseInt(courseId),
                title.trim(), year, type,
                originalName, safeName,
                username, 0, null
            );
            dao.upload(exam);
            session.setAttribute("message", "✅ Past paper uploaded: " + originalName);

        } else if ("upvote".equals(action)) {
            int examId = Integer.parseInt(request.getParameter("examId"));
            dao.upvote(examId, username);

        } else if ("delete".equals(action)) {
            int examId = Integer.parseInt(request.getParameter("examId"));
            PastExam exam = dao.getById(examId);
            if (exam != null && exam.getUploadedBy().equals(username)) {
                // Delete file from disk
                if (exam.getSavedName() != null && !exam.getSavedName().isEmpty()) {
                    try { Files.deleteIfExists(getUploadPath().resolve(exam.getSavedName())); }
                    catch (IOException ignored) {}
                }
                dao.delete(examId, username);
                session.setAttribute("message", "Paper deleted.");
            }
        }

        response.sendRedirect("CourseServlet?view=detail&id=" + courseId + "&tab=exams");
    }

    // ── DOWNLOAD ─────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp"); return;
        }

        String idStr = request.getParameter("download");
        if (idStr == null) { response.sendError(400, "Missing id"); return; }

        PastExam exam = dao.getById(Integer.parseInt(idStr));
        if (exam == null || exam.getSavedName() == null || exam.getSavedName().isEmpty()) {
            response.sendError(404, "File not found"); return;
        }

        Path filePath = getUploadPath().resolve(exam.getSavedName());
        if (!Files.exists(filePath)) {
            response.sendError(404, "File not on server"); return;
        }

        String mime = getServletContext().getMimeType(exam.getFileName());
        if (mime == null) mime = "application/octet-stream";

        response.setContentType(mime);
        response.setContentLengthLong(Files.size(filePath));

        // PDFs and images open inline; everything else downloads
        boolean inline = mime.startsWith("image/") || "application/pdf".equals(mime);
        response.setHeader("Content-Disposition",
            (inline ? "inline" : "attachment")
            + "; filename=\"" + exam.getFileName().replace("\"", "") + "\"");

        Files.copy(filePath, response.getOutputStream());
    }
}
