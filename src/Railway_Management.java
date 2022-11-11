import java.sql.*;
import java.nio.file.*;

public class Railway_Management  {
    public static void main(String[] args) throws Exception {
        // Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost:5432/Railway_Management", username = "postgres", password = "Kart1923@1";
        Connection con = null;
        try {
            con = DriverManager.getConnection(url,username,password);
        }
        catch (SQLException ex) {
            System.out.println(ex.getMessage());
        }
        try {
            Statement st = con.createStatement();
            String drop_file = "/Users/kbsingh296/eclipse-workspace/Railway_Management/src/drop.sql", query_file = "/Users/kbsingh296/eclipse-workspace/Railway_Management/src/query.sql";
            String[] drop = (new String(Files.readAllBytes(Paths.get(drop_file)))).split(";"), q = (new String(Files.readAllBytes(Paths.get(query_file)))).split(";");
            try {
                for (String i: drop) {
                    st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("drop Exception");
            }
            try {
                for (String i: q) {
                    st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("Query Exception");
                System.out.println(e.getMessage());
            }
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        System.out.println("Done");
        
    }
}