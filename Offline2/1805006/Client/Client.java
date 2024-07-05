package Client;

import Server.Worker;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    static final int PORT = 5006;
    public static void main(String[] args) throws IOException, InterruptedException {

        //ServerSocket serverConnect = new ServerSocket(PORT);

        String filepath;
        Scanner in = new Scanner(System.in);
        int id = 0;
        while(true)
        {
            id++;
            //Thread.sleep(200);
            System.out.println("Waiting for Upload Request #" + id);
            filepath = in.nextLine();
            //System.out.println(filepath);


            Socket s = new Socket("localhost", PORT);
            System.out.println("Client req#"+ id + " started.\nConnected to port : " + PORT + " ...\n");
            //Socket s = serverConnect.accept();
            //System.out.println(s.getInputStream().read());
            Thread cw = new ClientWorker(s, filepath, id);
            cw.start();
        }

    }
}
