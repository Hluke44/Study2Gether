package model;

public class Course {
    private int id;
    private String code;       // e.g. CS101
    private String name;       // e.g. Data Structures
    private String lecturer;
    private String semester;   // e.g. Semester 1 2024
    private String createdBy;
    private String description;

    public Course() {}

    public Course(int id, String code, String name, String lecturer, String semester, String createdBy, String description) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.lecturer = lecturer;
        this.semester = semester;
        this.createdBy = createdBy;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getLecturer() { return lecturer; }
    public void setLecturer(String lecturer) { this.lecturer = lecturer; }

    public String getSemester() { return semester; }
    public void setSemester(String semester) { this.semester = semester; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
