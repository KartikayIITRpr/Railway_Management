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
            try {
            	String drop_file = "src/drop.sql";
            	String[] drop = (new String(Files.readAllBytes(Paths.get(drop_file)))).split(";");
                for (String i: drop) {
                    st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("drop Exception");
            }
            try {
            	String create_file = "src/create.sql";
                String[] create = (new String(Files.readAllBytes(Paths.get(create_file)))).split(";");
                for (String i: create) {
                    st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("Create Exception");
                System.out.println(e.getMessage());
            }
            try {
            	String stored_file = "src/stored_pro.sql";
            	String stored_pro = new String(Files.readAllBytes(Paths.get(stored_file)));
                st.execute(stored_pro);
            }
            catch (Exception e) {
                System.out.println("Stored pro Exception");
                System.out.println(e.getMessage());
            }
            try {
            	String create_file = "src/triggers.sql";
                String[] create = (new String(Files.readAllBytes(Paths.get(create_file)))).split(";");
                for (String i: create) {
                	st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("Trigger Exception");
                System.out.println(e.getMessage());
            }
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        System.out.println("Done");
        
    }
}