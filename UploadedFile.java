package model;

public class UploadedFile {
    private int id;
    private int courseId;
    private String title;
    private String description;
    private String savedName;
    private String originalName;
    private String fileSize;
    private String fileType;
    private String uploadedBy;
    private String uploadedAt;

    public UploadedFile() {}

    public UploadedFile(int id, int courseId, String title, String description,
                        String savedName, String originalName, String fileSize,
                        String fileType, String uploadedBy, String uploadedAt) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.description = description;
        this.savedName = savedName;
        this.originalName = originalName;
        this.fileSize = fileSize;
        this.fileType = fileType;
        this.uploadedBy = uploadedBy;
        this.uploadedAt = uploadedAt;
    }

    public int getId()             { return id; }
    public int getCourseId()       { return courseId; }
    public String getTitle()       { return title; }
    public String getDescription() { return description; }
    public String getSavedName()   { return savedName; }
    public String getOriginalName(){ return originalName; }
    public String getFileSize()    { return fileSize; }
    public String getFileType()    { return fileType; }
    public String getUploadedBy()  { return uploadedBy; }
    public String getUploadedAt()  { return uploadedAt; }

    public void setId(int id)                   { this.id = id; }
    public void setCourseId(int courseId)       { this.courseId = courseId; }
    public void setTitle(String title)          { this.title = title; }
    public void setDescription(String d)        { this.description = d; }
    public void setSavedName(String s)          { this.savedName = s; }
    public void setOriginalName(String o)       { this.originalName = o; }
    public void setFileSize(String fs)          { this.fileSize = fs; }
    public void setFileType(String ft)          { this.fileType = ft; }
    public void setUploadedBy(String u)         { this.uploadedBy = u; }
    public void setUploadedAt(String a)         { this.uploadedAt = a; }
}
