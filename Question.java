package model;

public class Question {
    private int id;
    private int courseId;
    private String title;
    private String body;
    private String askedBy;
    private int upvotes;
    private int answerCount;
    private String askedDate;
    private boolean urgent;

    public Question() {}

    public Question(int id, int courseId, String title, String body, String askedBy,
                    int upvotes, int answerCount, String askedDate, boolean urgent) {
        this.id = id;
        this.courseId = courseId;
        this.title = title;
        this.body = body;
        this.askedBy = askedBy;
        this.upvotes = upvotes;
        this.answerCount = answerCount;
        this.askedDate = askedDate;
        this.urgent = urgent;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public String getAskedBy() { return askedBy; }
    public void setAskedBy(String askedBy) { this.askedBy = askedBy; }

    public int getUpvotes() { return upvotes; }
    public void setUpvotes(int upvotes) { this.upvotes = upvotes; }

    public int getAnswerCount() { return answerCount; }
    public void setAnswerCount(int answerCount) { this.answerCount = answerCount; }

    public String getAskedDate() { return askedDate; }
    public void setAskedDate(String askedDate) { this.askedDate = askedDate; }

    public boolean isUrgent() { return urgent; }
    public void setUrgent(boolean urgent) { this.urgent = urgent; }
}
