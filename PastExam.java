package model;

public class PastExam {
    private int id;
    private int courseId;
    private String title;
    private String year;
    private String type;         // exam, test, assignment, memo
    private String fileName;     // original filename shown to user
    private String savedName;    // timestamped name stored on disk
    private String uploadedBy;
    private int upvotes;
    private String uploadDate;

    public PastExam() {}

    public PastExam(int id, int courseId, String title, String year, String type,
                    String fileName, String savedName, String uploadedBy, int upvotes, String uploadDate) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.year = year;
        this.type = type;
        this.fileName = fileName;
        this.savedName = savedName;
        this.uploadedBy = uploadedBy;
        this.upvotes = upvotes;
        this.uploadDate = uploadDate;
    }

    public int getId()              { return id; }
    public void setId(int id)       { this.id = id; }

    public int getCourseId()                { return courseId; }
    public void setCourseId(int courseId)   { this.courseId = courseId; }

    public String getTitle()                { return title; }
    public void setTitle(String title)      { this.title = title; }

    public String getYear()                 { return year; }
    public void setYear(String year)        { this.year = year; }

    public String getType()                 { return type; }
    public void setType(String type)        { this.type = type; }

    public String getFileName()                  { return fileName; }
    public void setFileName(String fileName)     { this.fileName = fileName; }

    public String getSavedName()                 { return savedName; }
    public void setSavedName(String savedName)   { this.savedName = savedName; }

    public String getUploadedBy()                   { return uploadedBy; }
    public void setUploadedBy(String uploadedBy)    { this.uploadedBy = uploadedBy; }

    public int getUpvotes()                 { return upvotes; }
    public void setUpvotes(int upvotes)     { this.upvotes = upvotes; }

    public String getUploadDate()                   { return uploadDate; }
    public void setUploadDate(String uploadDate)    { this.uploadDate = uploadDate; }
}
