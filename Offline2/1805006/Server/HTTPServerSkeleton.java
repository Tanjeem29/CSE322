package Server;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Date;

public class HTTPServerSkeleton {
    static final int PORT = 5006;

    
    public static void main(String[] args) throws IOException {
        File log = new File("log.txt");
        log.createNewFile();
        log.delete();
        log.createNewFile();
        ServerSocket serverConnect = new ServerSocket(PORT);
        System.out.println("Server started.\nListening for connections on port : " + PORT + " ...\n");

        int id = 0;
        while(true)
        {
            id++;

            Socket s = serverConnect.accept();
            System.out.println("Connected. Serving Request# " + id);
            //System.out.println(s.getInputStream().read());
            Thread worker = new Worker(s, id, log);
            worker.start();
        }
        
    }
    
}
