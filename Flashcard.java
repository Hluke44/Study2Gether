package model;

public class Flashcard {
    private int id;
    private int deckId;
    private String question;
    private String answer;
    private int position;

    public Flashcard() {}

    public Flashcard(int id, int deckId, String question, String answer, int position) {
        this.id = id;
        this.deckId = deckId;
        this.question = question;
        this.answer = answer;
        this.position = position;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getDeckId() { return deckId; }
    public void setDeckId(int deckId) { this.deckId = deckId; }

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }

    public int getPosition() { return position; }
    public void setPosition(int position) { this.position = position; }
}
