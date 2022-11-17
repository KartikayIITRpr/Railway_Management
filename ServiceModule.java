import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.sql.*;
import java.nio.file.*;
import java.io.File;
import java.util.*;



class QueryRunner implements Runnable
{
    //  Declare socket for client access
    protected Socket socketConnection;
    // protected Statement stm ;
    static Statement st;
    static Connection con;

    public QueryRunner(Socket clientSocket )
    {
        this.socketConnection =  clientSocket;
        String url = "jdbc:postgresql://localhost:5432/Railway_Management", username = "postgres", password = "123456";

        try {
            this.con = DriverManager.getConnection(url,username,password);
            this.st = con.createStatement();
        }
        catch (SQLException ex) {
            System.out.println(ex.getMessage());
        }
    }

    public void run()
    {
        try
        {
            //  Reading data from client
            InputStreamReader inputStream = new InputStreamReader(socketConnection
                    .getInputStream()) ;
            BufferedReader bufferedInput = new BufferedReader(inputStream) ;
            OutputStreamWriter outputStream = new OutputStreamWriter(socketConnection
                    .getOutputStream()) ;
            BufferedWriter bufferedOutput = new BufferedWriter(outputStream) ;
            PrintWriter printWriter = new PrintWriter(bufferedOutput, true) ;
            String clientCommand = "" ;
            String responseQuery = "" ;
            // Read client query from the socket endpoint
            clientCommand = bufferedInput.readLine();
            while( ! clientCommand.equals("#"))
            {

                System.out.println("Recieved data <" + clientCommand + "> from client : "
                        + socketConnection.getRemoteSocketAddress().toString());

                /*******************************************
                 Your DB code goes here
                 ********************************************/
                // Class.forName("org.postgresql.Driver");





                String ret_val = book_ticket(clientCommand);
                responseQuery = "Ticket booked with pnr: " + ret_val;
                printWriter.println(responseQuery);
                // Read next client query
                clientCommand = bufferedInput.readLine();




            }
            inputStream.close();
            bufferedInput.close();
            outputStream.close();
            bufferedOutput.close();
            printWriter.close();
            socketConnection.close();
        }
        catch(Exception e)
        {
            return;
        }
    }

    static String book_ticket (String query) {
        String pnr ="";
        try {
            String[] booking = (query).split("[,]?\\s+");
            int num = Integer.parseInt(booking[0]);
            ArrayList<String> names = new ArrayList<String>();
            for (int i = 1; i<=num; i++) {
                names.add(booking[i]);
            }
            String train_num = booking[num+1];
            String date = booking[num+2];
            String type = booking[num+3];
            String avail_seats_query = "Select get_avail_seats("+train_num+", \'"+date+"\', \'"+type+"\', " + String.valueOf(num) + ");";
//        		System.out.println(avail_seats);
            ResultSet rs = st.executeQuery(avail_seats_query);
            rs.next();
            String[] ret = ((rs.getString(1)).replaceAll("[()]", "")).split(",\\s*");
            int remain_seat = Integer.parseInt(ret[0]), curr_coach = Integer.parseInt(ret[1]);

            if (remain_seat >0) {
                if (type == "AC") {
//                    ResultSet rsq ;
//                    rsq.next();
                    String berth = String.valueOf(18-remain_seat+1);
                    if (berth.length() == 1) berth = "0"+berth;
                    pnr = train_num+date.replaceAll("-", "")+String.valueOf(curr_coach)+berth;
                    System.out.println( pnr + " " + num);
                    String ins_pnr = "select get_ticket(\'"+ pnr + "\', " + train_num+", \'"+ date + "\', "+ String.valueOf(num)+ ", \'"+ type + "\');";
                    st.executeQuery(ins_pnr);

                    for (int num_booked = 0; num_booked<num; num_booked++) {
                        System.out.println("name " + names.get(num_booked));
                        if (remain_seat == 0) {
                            remain_seat = 18;
                            curr_coach++;
                        }
                        int x = 18-remain_seat+1;

                        String ins_pass = "select ins_pass (\'"+ pnr+ "\' , " + String.valueOf(curr_coach)+ ", " + String.valueOf(x) + ", '" + get_berth_type_ac(x) + "', '"+ names.get(num_booked) + "');";
//                        System.out.println(ins_pass);
                        st.executeQuery(ins_pass);
//                        rsq3.next();
//                        String res = rsq3.getString(1);
//                        System.out.println(res);
                        remain_seat--;

                    }
                }
                else {
//                    ResultSet rsq;
//                    String get_tick_num = "select get_ticket("+train_num+", \'"+ date + "\', "+ String.valueOf(num)+ ", \'"+ type + "\');";
//                    rsq = st.executeQuery(get_tick_num);
//                    rsq.next();
                    String berth = String.valueOf(24-remain_seat+1);
                    if (berth.length() == 1) berth = "0"+berth;
                    pnr = train_num+date.replaceAll("-", "")+String.valueOf(curr_coach)+berth;
                    System.out.println( pnr + " " + num);
                    String ins_pnr = "select get_ticket(\'"+ pnr + "\', " + train_num+", \'"+ date + "\', "+ String.valueOf(num)+ ", \'"+ type + "\');";
                    st.executeQuery(ins_pnr);

                    for (int num_booked = 0; num_booked<num; num_booked++) {
                        System.out.println("name " + names.get(num_booked));
                        if (remain_seat == 0) {
                            remain_seat = 24;
                            curr_coach++;
                        }
                        int x = 24-remain_seat+1;
                        String ins_pass = "select ins_pass ( \'"+ pnr+ "\' , " + String.valueOf(curr_coach)+ ", " + String.valueOf(x) + ", '" + get_berth_type_sl(x) + "', '"+ names.get(num_booked) + "');";
//                        System.out.println(ins_pass)
                        st.executeQuery(ins_pass);
//                        rsq2.next();
//                        String res = rsq2.getString(1);
//                        System.out.println(res);
                        remain_seat--;
                    }
                }
            }
            else {
                System.out.println("Seats not available");
            }
        }
        catch (Exception e) {
            System.out.println("Booking Exception");
            System.out.println(e.getMessage());
        }
        return pnr;
    }
    static String get_berth_type_ac (int berth_num) {
        int x = berth_num%6;
        switch(x) {
            case 1:
                return "LB";
            case 2:
                return "LB";
            case 3:
                return "UB";
            case 4:
                return "UB";
            case 5:
                return "SL";
            default:
                return "SU";
        }
    }

    static String get_berth_type_sl (int berth_num) {
        int x = berth_num%8;
        switch(x) {
            case 1:
                return "LB";
            case 2:
                return "MB";
            case 3:
                return "UB";
            case 4:
                return "LB";
            case 5:
                return "MB";
            case 6:
                return "UB";
            case 7:
                return "SL";
            default:
                return "SU";
        }
    }


}

/**
 * Main Class to controll the program flow
 */
public class ServiceModule
{
    // Server listens to port
    static int serverPort = 7008;
    // Max no of parallel requests the server can process
    static int numServerCores = 5;
    //------------ Main----------------------


    public static void main(String[] args) throws IOException
    {

        Connection con = null;
        Statement st;
        try{
            String url = "jdbc:postgresql://localhost:5432/Railway_Management", username = "postgres", password = "123456";

            try {
                con = DriverManager.getConnection(url,username,password);
            }
            catch (SQLException ex) {
                System.out.println(ex.getMessage());
            }
            try {
                st = con.createStatement();
                drop_table(st);
                create_table(st);
                create_stored_pro(st);
                create_trigger(st);
                schedule_train(st);

                st.close();
            }
            catch (Exception e) {
                System.out.println(e.getMessage());
            }

            con.close();
        }
        catch(Exception e){
            System.out.println(e.getMessage());
        }

        System.out.println("Done");
        // Creating a thread pool
        ExecutorService executorService = Executors.newFixedThreadPool(numServerCores);

        try (//Creating a server socket to listen for clients
             ServerSocket serverSocket = new ServerSocket(serverPort)) {
            Socket socketConnection = null;

            // Always-ON server
            while(true)
            {
                System.out.println("Listening port : " + serverPort
                        + "\nWaiting for clients...");
                socketConnection = serverSocket.accept();   // Accept a connection from a client
                System.out.println("Accepted client :"
                        + socketConnection.getRemoteSocketAddress().toString()
                        + "\n");
                //  Create a runnable task
                Runnable runnableTask = new QueryRunner(socketConnection);
                //  Submit task for execution   
                executorService.submit(runnableTask);
            }
        }

    }
    static void drop_table (Statement st) {
        try {
            String drop_file = "src/drop.sql";
            String drop = new String(Files.readAllBytes(Paths.get(drop_file)));
            st.execute(drop);
        }
        catch (Exception e) {
            System.out.println("drop Exception");
        }
    }

    static void create_table (Statement st) {
        try {
            String create_file = "src/create.sql";
            String create = new String(Files.readAllBytes(Paths.get(create_file)));
            st.execute(create);
        }
        catch (Exception e) {
            System.out.println("Create Exception");
            System.out.println(e.getMessage());
        }
    }

    static void create_stored_pro ( Statement st) {
        try {
            String stored_file = "src/stored_pro.sql";
            String stored_pro = new String(Files.readAllBytes(Paths.get(stored_file)));
            st.execute(stored_pro);
        }
        catch (Exception e) {
            System.out.println("Stored pro Exception");
            System.out.println(e.getMessage());
        }
    }

    static void create_trigger (Statement st) {
        try {
            String trigger_file = "src/triggers.sql";
            String trigger = new String(Files.readAllBytes(Paths.get(trigger_file)));

            st.execute(trigger);
        }
        catch (Exception e) {
            System.out.println("Trigger Exception");
            System.out.println(e.getMessage());
        }
    }

    static void schedule_train (Statement st) {
        try {
            File schedule_file = new File("asset/trainschedule.txt");
            Scanner sc = new Scanner(schedule_file);
            while (sc.hasNextLine()) {
                String[] schedule = (sc.nextLine()).split("\\s+");
                if (schedule.length < 4) {
                    System.out.println("out");
                    break;
                }
                String query = "insert into schedule values("+schedule[0]+",\'"+ schedule[1]+ "\',"+ schedule[2] + "," + schedule[3]+ ");";
//        		System.out.println(query);
                st.execute(query);
            }
            sc.close();
        }
        catch (Exception e) {
            System.out.println("Schedule Exception");
            System.out.println(e.getMessage());
        }
    }

}

