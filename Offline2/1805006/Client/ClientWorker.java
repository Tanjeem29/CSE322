package Client;

import java.io.*;
import java.net.Socket;
import java.nio.Buffer;
import java.nio.file.Path;
import java.util.Date;

public class ClientWorker extends Thread {
    Socket s;
    String filePathStr;
    int CHUNKSIZE = 4096;
    int id;
    public ClientWorker(Socket socket, String path, int i)
    {
        this.s = socket;
        filePathStr = path;
        id = i;
    }

    public void run()
    {
        // buffers
        try {

            PrintWriter pr = new PrintWriter(s.getOutputStream());
            Path dir = Path.of(filePathStr);
            if(dir.toFile().isFile()){
                pr.write("UPLOAD " + filePathStr + "\r\n");
                pr.flush();
                if (filePathStr.endsWith(".txt") || filePathStr.endsWith(".png") || filePathStr.endsWith(".jpg") || filePathStr.endsWith(".mp4")) {

                    DataOutputStream bos = new DataOutputStream(s.getOutputStream());

                    System.out.println("Req#" + id + ": File Found. Starting Upload.");

                    byte[] chunk = new byte[CHUNKSIZE];
                    int count;
                    File fp = new File(dir.toString());
                    FileInputStream fin = new FileInputStream(fp);
                    while ((count = fin.read(chunk)) > 0) {
                        bos.write(chunk, 0, count);
                        bos.flush();

                    }

                    fin.close();
                    System.out.println("Req#" + id + ": Upload Finished");

                }
                else{
                    System.out.println("Req#" + id + ": Invalid file extension.");
                }
            } else{
                System.out.println("Req#" + id + ": File not found. Request not sent to server");

            }


            s.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
