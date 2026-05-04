package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/study_platform?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER = "root";
    private static final String PASSWORD = "202412";

    public static Connection getConnection() {
        try {
            Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("DATABASE CONNECTED SUCCESSFULLY");
            return con;
        } catch (Exception e) {
            System.out.println("DATABASE CONNECTION FAILED: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
}
