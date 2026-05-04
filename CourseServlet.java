package controller;

import dao.CourseDAO;
import dao.PastExamDAO;
import dao.QuestionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Course;
import model.User;

import java.io.IOException;

@WebServlet("/CourseServlet")
public class CourseServlet extends HttpServlet {

    CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");

        String view = request.getParameter("view");

        if ("detail".equals(view)) {
            // Show a single course hub with past exams and Q&A
            int courseId = Integer.parseInt(request.getParameter("id"));
            Course course = courseDAO.getCourseById(courseId);
            if (course == null) {
                response.sendRedirect("CourseServlet");
                return;
            }
            String yearFilter = request.getParameter("year");
            String typeFilter = request.getParameter("type");

            PastExamDAO examDAO = new PastExamDAO();
            QuestionDAO qaDAO = new QuestionDAO();

            request.setAttribute("course", course);
            request.setAttribute("exams", examDAO.getByCourse(courseId, yearFilter, typeFilter));
            request.setAttribute("questions", qaDAO.getByCourse(courseId));
            request.setAttribute("enrolled", courseDAO.isEnrolled(courseId, user.getName()));
            request.setAttribute("enrollCount", courseDAO.getEnrollmentCount(courseId));
            request.getRequestDispatcher("courseDetail.jsp").forward(request, response);
        } else {
            // List all courses
            request.setAttribute("courses", courseDAO.getAllCourses());
            request.setAttribute("myCourses", courseDAO.getEnrolledCourses(user.getName()));
            request.getRequestDispatcher("courses.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        User user = (User) session.getAttribute("user");
        String username = user.getName();
        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("CourseServlet");
            return;
        }

        switch (action) {
            case "create": {
                String code = request.getParameter("code");
                String name = request.getParameter("name");
                String lecturer = request.getParameter("lecturer");
                String semester = request.getParameter("semester");
                String desc = request.getParameter("description");
                if (code != null && !code.isBlank() && name != null && !name.isBlank()) {
                    Course c = new Course(0, code.trim().toUpperCase(), name.trim(), lecturer, semester, username, desc);
                    courseDAO.createCourse(c);
                    session.setAttribute("message", "Course '" + code.toUpperCase() + "' created!");
                }
                response.sendRedirect("CourseServlet");
                break;
            }
            case "enroll": {
                int id = Integer.parseInt(request.getParameter("id"));
                courseDAO.enrollStudent(id, username);
                session.setAttribute("message", "Enrolled in course!");
                response.sendRedirect("CourseServlet?view=detail&id=" + id);
                break;
            }
            case "unenroll": {
                int id = Integer.parseInt(request.getParameter("id"));
                courseDAO.unenrollStudent(id, username);
                session.setAttribute("message", "Unenrolled from course.");
                response.sendRedirect("CourseServlet?view=detail&id=" + id);
                break;
            }
            case "delete": {
                int id = Integer.parseInt(request.getParameter("id"));
                courseDAO.deleteCourse(id, username);
                session.setAttribute("message", "Course deleted.");
                response.sendRedirect("CourseServlet");
                break;
            }
            default:
                response.sendRedirect("CourseServlet");
        }
    }
}
