import java.sql.*;
import java.nio.file.*;
import java.io.File;
import java.util.*;

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
            	String drop_file = "./drop.sql";
            	String[] drop = (new String(Files.readAllBytes(Paths.get(drop_file)))).split(";");
                for (String i: drop) {
                    st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("drop Exception");
            }
            try {
            	String create_file = "./create.sql";
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
            	String stored_file = "./stored_pro.sql";
            	String stored_pro = new String(Files.readAllBytes(Paths.get(stored_file)));
                st.execute(stored_pro);
            }
            catch (Exception e) {
                System.out.println("Stored pro Exception");
                System.out.println(e.getMessage());
            }
            try {
            	String create_file = "./triggers.sql";
                String[] create = (new String(Files.readAllBytes(Paths.get(create_file)))).split(";");
                for (String i: create) {
                	st.execute(i);
                }
            }
            catch (Exception e) {
                System.out.println("Trigger Exception");
                System.out.println(e.getMessage());
            }
            
            try {
            	File schedule_file = new File("../asset/trainschedule.txt");
            	Scanner sc = new Scanner(schedule_file);
            	while (sc.hasNextLine()) {
            		String[] schedule = (sc.nextLine()).split("\\s+");
            		String query = "insert into schedule values("+schedule[0]+",\'"+ schedule[1]+ "\',"+ schedule[2] + "," + schedule[3]+ ");";
//            		System.out.println(query);
            		st.execute(query);
            	}
            	sc.close();
            }
            catch (Exception e) {
                System.out.println("Schedule Exception");
                System.out.println(e.getMessage());
            }
            
            try {
            	File booking_file = new File ("../asset/bookings.txt");
            	Scanner sc = new Scanner(booking_file);
            	while (sc.hasNextLine()) {
            		String[] booking = (sc.nextLine()).split("[,]?\\s+");
            		int num = Integer.parseInt(booking[0]);
            		ArrayList<String> names = new ArrayList<String>();
            		for (int i = 1; i<=num; i++) {
            			names.add(booking[i]);
            		}
            		String train_num = booking[num+1];
            		String date = booking[num+2];
            		String type = booking[num+3];
            		String avail_seats_query = "Select get_avail_seats("+train_num+", \'"+date+"\', \'"+type+"\');";
//            		System.out.println(avail_seats);
            		ResultSet rs = st.executeQuery(avail_seats_query);
            		rs.next();
            		int avail_seats = rs.getInt(1);
            		if (avail_seats <num) {
            			System.out.println("Seats not available.");
            		}
            		else {
            			if (type == "AC") {
            				String query = "call update_curr_ac ("+train_num + ", \'"+ date + "\', "+ String.valueOf(num)+ ");";
            				System.out.println(query);
            			}
            			else {
            				String query = "call update_curr_sl ("+train_num + ", \'"+ date + "\', "+ String.valueOf(num)+ ");";
            				System.out.println(query);
            			}
            		}
            	}
            	sc.close();
            }
            catch (Exception e) {
                System.out.println("Booking Exception");
                System.out.println(e.getMessage());
            }
            
            st.close();
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        con.close();
        
        System.out.println("Done");
        
    }
}