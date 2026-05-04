package model;

public class Deadline {
    private int id;
    private int courseId;
    private String courseName;  // joined for display
    private String title;
    private String dueDate;     // stored as VARCHAR YYYY-MM-DD
    private String type;        // assignment, test, exam, project
    private String addedBy;
    private boolean done;

    public Deadline() {}

    public Deadline(int id, int courseId, String courseName, String title,
                    String dueDate, String type, String addedBy, boolean done) {
        this.id = id;
        this.courseId = courseId;
        this.courseName = courseName;
        this.title = title;
        this.dueDate = dueDate;
        this.type = type;
        this.addedBy = addedBy;
        this.done = done;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDueDate() { return dueDate; }
    public void setDueDate(String dueDate) { this.dueDate = dueDate; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getAddedBy() { return addedBy; }
    public void setAddedBy(String addedBy) { this.addedBy = addedBy; }

    public boolean isDone() { return done; }
    public void setDone(boolean done) { this.done = done; }
}
