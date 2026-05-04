# StudyPlatform — Campus Study Hub

A full-featured university study platform built with Jakarta EE (JSP + Servlets), MySQL and Maven.

---

## Features

| Feature | Description |
|---|---|
| 🎓 Course Hubs | Create courses by code (e.g. CS101), enroll students, browse by semester/lecturer |
| 📝 Past Exams | Upload & download past papers, tests, memos — filter by year and type, upvote helpful ones |
| 💬 Q&A Forum | Post urgent questions per course, threaded answers, upvotes, accept best answer |
| 📅 Deadline Tracker | Add tests/assignments/exams with due dates, mark done, overdue highlighting |
| 🃏 Flashcards | Create decks, interactive flip-card study mode with scoring + keyboard shortcuts |
| 👥 Study Groups | Create/join groups with member cap and live member count |
| 📁 Resources | Upload notes, summaries, cheat sheets, past papers with type filtering |
| 👤 Profile | Live dashboard — enrolled courses, pending deadlines, flashcard decks |

---

## Tech Stack

- **Backend:** Java 17, Jakarta EE 10 (Servlets, JSP)
- **Database:** MySQL 8
- **Build:** Maven 3
- **Server:** Apache Tomcat 10+

---

## Setup Instructions

### 1. Database

Open MySQL and run:

```sql
source /path/to/CampusMarket/database_setup.sql
```

This creates the `study_platform` database and all required tables.

### 2. Configure DB connection

Edit `src/main/java/util/DBConnection.java`:

```java
private static final String URL      = "jdbc:mysql://localhost:3306/study_platform?...";
private static final String USER     = "root";       // your MySQL user
private static final String PASSWORD = "yourpassword"; // your MySQL password
```

### 3. Build & Deploy

```bash
cd CampusMarket
mvn clean package
# Copy target/CampusMarket-1.0-SNAPSHOT.war to your Tomcat webapps folder
```

Or open in **NetBeans / IntelliJ** and run directly with the bundled Tomcat.

### 4. Access

Navigate to: `http://localhost:8080/CampusMarket/`

You'll land on the login page. Register an account and you're in.

---

## Database Tables

| Table | Purpose |
|---|---|
| `users` | Registered accounts |
| `courses` | Course hubs |
| `course_enrollments` | Student ↔ course enrolment |
| `past_exams` | Uploaded exam papers |
| `exam_upvotes` | One upvote per user per exam |
| `questions` | Q&A questions per course |
| `question_upvotes` | One upvote per user per question |
| `answers` | Threaded answers to questions |
| `answer_upvotes` | One upvote per user per answer |
| `deadlines` | Personal deadline tracker |
| `flashcard_decks` | Flashcard deck metadata |
| `flashcards` | Individual flashcards in decks |
| `study_group` | Study groups |
| `group_members` | Group ↔ member relationships |

---

## Navigation Map

```
login.jsp / register
    └── home.jsp                  (dashboard + upcoming deadlines)
        ├── CourseServlet         (course list)
        │   └── CourseServlet?view=detail&id=X
        │       ├── tab=exams     (past papers + upload)
        │       └── tab=qa        (questions list)
        │           └── QAServlet?id=X  (question thread + answers)
        ├── DeadlineServlet       (deadline tracker)
        ├── FlashcardServlet      (deck browser)
        │   └── FlashcardServlet?view=study&id=X  (study mode)
        ├── StudyGroupServlet     (study groups)
        ├── resources.jsp         (shared resources)
        └── profile.jsp           (live profile dashboard)
```

---

## Keyboard Shortcuts (Flashcard Study Mode)

| Key | Action |
|---|---|
| `Space` / `↑` / `↓` | Flip card |
| `→` | Next card |
| `←` | Previous card |
| `1` | Mark correct |
| `2` | Mark incorrect |
| `3` | Skip |
