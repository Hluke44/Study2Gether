package model;

public class StudyGroup {

    private int id;
    private String name;
    private String description;
    private int maxMembers;
    private String createdBy;

    public StudyGroup() {}

    public StudyGroup(int id, String name, String description, int maxMembers, String createdBy) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.maxMembers = maxMembers;
        this.createdBy = createdBy;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public int getMaxMembers() { return maxMembers; }
    public String getCreatedBy() { return createdBy; }

    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setDescription(String description) { this.description = description; }
    public void setMaxMembers(int maxMembers) { this.maxMembers = maxMembers; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
}