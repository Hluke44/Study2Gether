package model;

public class FlashcardDeck {
    private int id;
    private int courseId;
    private String courseName;
    private String title;
    private String createdBy;
    private int cardCount;
    private String createdDate;

    public FlashcardDeck() {}

    public FlashcardDeck(int id, int courseId, String courseName, String title,
                         String createdBy, int cardCount, String createdDate) {
        this.id = id;
        this.courseId = courseId;
        this.courseName = courseName;
        this.title = title;
        this.createdBy = createdBy;
        this.cardCount = cardCount;
        this.createdDate = createdDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }

    public int getCardCount() { return cardCount; }
    public void setCardCount(int cardCount) { this.cardCount = cardCount; }

    public String getCreatedDate() { return createdDate; }
    public void setCreatedDate(String createdDate) { this.createdDate = createdDate; }
}
