package model;

public class Answer {
    private int id;
    private int questionId;
    private String body;
    private String answeredBy;
    private int upvotes;
    private String answeredDate;
    private boolean accepted;

    public Answer() {}

    public Answer(int id, int questionId, String body, String answeredBy,
                  int upvotes, String answeredDate, boolean accepted) {
        this.id = id;
        this.questionId = questionId;
        this.body = body;
        this.answeredBy = answeredBy;
        this.upvotes = upvotes;
        this.answeredDate = answeredDate;
        this.accepted = accepted;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }

    public String getAnsweredBy() { return answeredBy; }
    public void setAnsweredBy(String answeredBy) { this.answeredBy = answeredBy; }

    public int getUpvotes() { return upvotes; }
    public void setUpvotes(int upvotes) { this.upvotes = upvotes; }

    public String getAnsweredDate() { return answeredDate; }
    public void setAnsweredDate(String answeredDate) { this.answeredDate = answeredDate; }

    public boolean isAccepted() { return accepted; }
    public void setAccepted(boolean accepted) { this.accepted = accepted; }
}
