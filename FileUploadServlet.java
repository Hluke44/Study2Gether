package controller;

import dao.UploadedFileDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.UploadedFile;
import model.User;

import java.io.*;
import java.nio.file.*;

@WebServlet("/FileServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,       // 1 MB
    maxFileSize       = 20 * 1024 * 1024,  // 20 MB
    maxRequestSize    = 25 * 1024 * 1024   // 25 MB
)
public class FileUploadServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "studyplatform_uploads";
    private final UploadedFileDAO dao = new UploadedFileDAO();

    private Path getUploadPath() throws IOException {
        Path dir = Paths.get(System.getProperty("java.io.tmpdir"), UPLOAD_DIR);
        Files.createDirectories(dir);
        return dir;
    }

    // ── UPLOAD & DELETE ──────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp"); return;
        }
        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");

        if ("upload".equals(action)) {
            String title    = request.getParameter("title");
            String desc     = request.getParameter("description");
            String type     = request.getParameter("type");
            String cIdStr   = request.getParameter("courseId");
            Part   filePart = request.getPart("file");

            if (filePart == null || filePart.getSize() == 0 || title == null || title.isBlank()) {
                session.setAttribute("uploadError", "Please fill in a title and select a file.");
                response.sendRedirect("resources.jsp");
                return;
            }

            // Sanitise and save to disk
            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String safeName     = System.currentTimeMillis() + "_"
                                  + originalName.replaceAll("[^a-zA-Z0-9._-]", "_");

            Path dest = getUploadPath().resolve(safeName);
            try (InputStream in = filePart.getInputStream()) {
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }

            int courseId = 0;
            try { if (cIdStr != null && !cIdStr.isBlank()) courseId = Integer.parseInt(cIdStr); }
            catch (NumberFormatException ignored) {}

            // Persist metadata to DB
            UploadedFile f = new UploadedFile();
            f.setCourseId(courseId);
            f.setTitle(title.trim());
            f.setDescription(desc == null ? "" : desc.trim());
            f.setSavedName(safeName);
            f.setOriginalName(originalName);
            f.setFileSize(humanSize(filePart.getSize()));
            f.setFileType(type == null ? "other" : type);
            f.setUploadedBy(user.getName());

            dao.save(f);
            session.setAttribute("message", "✅ File uploaded: " + originalName);
            response.sendRedirect("resources.jsp");

        } else if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                int id = Integer.parseInt(idStr);
                UploadedFile f = dao.getById(id);
                if (f != null && f.getUploadedBy().equals(user.getName())) {
                    // Remove from disk
                    try { Files.deleteIfExists(getUploadPath().resolve(f.getSavedName())); }
                    catch (IOException ignored) {}
                    dao.delete(id, user.getName());
                    session.setAttribute("message", "File deleted.");
                }
            }
            response.sendRedirect("resources.jsp");
        }
    }

    // ── DOWNLOAD / VIEW ──────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp"); return;
        }

        String fileParam = request.getParameter("file");
        if (fileParam == null || fileParam.contains("..") || fileParam.contains("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request");
            return;
        }

        // Look up metadata from DB using saved_name
        UploadedFile meta = dao.getBySavedName(fileParam);
        String displayName = (meta != null) ? meta.getOriginalName() : fileParam;

        Path filePath = getUploadPath().resolve(fileParam);
        if (!Files.exists(filePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on server");
            return;
        }

        String mimeType = getServletContext().getMimeType(displayName);
        if (mimeType == null) mimeType = "application/octet-stream";

        response.setContentType(mimeType);
        response.setContentLengthLong(Files.size(filePath));

        boolean viewInBrowser = mimeType.startsWith("image/") || "application/pdf".equals(mimeType);
        response.setHeader("Content-Disposition",
            (viewInBrowser ? "inline" : "attachment")
            + "; filename=\"" + displayName.replace("\"", "") + "\"");

        Files.copy(filePath, response.getOutputStream());
    }

    private String humanSize(long bytes) {
        if (bytes < 1024)        return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return                          String.format("%.1f MB", bytes / (1024.0 * 1024));
    }
}
