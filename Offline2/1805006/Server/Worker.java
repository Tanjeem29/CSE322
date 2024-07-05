package Server;

import java.io.*;
import java.net.Socket;
import java.nio.file.*;
import java.util.Date;

public class Worker extends Thread {
    Socket s;
    int id;
    int CHUNKSIZE = 4096;
    File log;

    public Worker(Socket socket, int i, File l)
    {
        this.s = socket;    id = i;     log = l;
    }

    public void run()
    {

        //System.out.println("id: " + id);


        try {

            StringBuilder logStr = new StringBuilder();
            logStr.append("--------------\n").append("Log# ").append(id).append("\n");

            BufferedReader in = new BufferedReader(new InputStreamReader(s.getInputStream()));
            PrintWriter pr = new PrintWriter(s.getOutputStream());
            String input = null;

            input = in.readLine();
            //System.out.println();
            //System.out.println("input : "+input);
            String[] splitInput;
            if(input == null) {
                System.out.println("Null input");
                logStr.append("Error : Null Request\n");
                return;
            }
            if(input.length() > 0) {
                splitInput = input.split(" ");

                if(splitInput[0].equals("GET")) {
                    logStr.append("Request:\n" + input + "\n");
                    logStr.append("Response:\n");
                    String[] filepath = splitInput[1].split("/");

                    StringBuilder sb = new StringBuilder();

                    sb.append("<html>\n");
                    sb.append("\t<head><link rel=\"icon\" href=\"data:,\">\n");
                    sb.append("\t\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n");
                    sb.append("\t</head>\n");
                    sb.append("\t<body>\n");
                    sb.append("\t\t<h1> Welcome to CSE 322 Offline 2 </h1>\n");


                    Path dir = Path.of("root");

                    sb.append("\t\t<ul>\n");

                    if (filepath.length > 0) {
                        dir = Paths.get(dir.toAbsolutePath().toString() + splitInput[1]);
                    }

                    System.out.println(dir.toAbsolutePath().toString());
                    if (filepath.length > 0 && !(dir.toFile().exists())) {
                        System.out.println("ERROR 404");
                        sb.append("\tERROR404: Page not found\n");
                        sb.append("\t</body>\n");
                        sb.append("</html>\n");
                        String content = sb.toString();
                        pr.write("HTTP/1.1 404 PAGE_NOT_FOUND\r\n");
                        pr.write("Server: Java HTTP Server: 1.0\r\n");
                        pr.write("Date: " + new Date() + "\r\n");
                        pr.write("Content-Type: text/html\r\n");
                        pr.write("Content-Length: " + content.length() + "\r\n");
                        pr.write("\r\n");

                        pr.write(content);
                        pr.flush();
                        //System.out.println(content);

                        pr.write("HTTP/1.1 404 PAGE_NOT_FOUND\r\n");
                        pr.write("Server: Java HTTP Server: 1.0\r\n");
                        pr.write("Date: " + new Date() + "\r\n");
                        pr.write("Content-Type: text/html\r\n");
                        pr.write("Content-Length: " + content.length() + "\r\n");
                        pr.write("\r\n");

                        logStr.append("HTTP/1.1 404 PAGE_NOT_FOUND\n");
                        logStr.append("Server: Java HTTP Server: 1.0\n");
                        logStr.append("Date: " + new Date() + "\n");
                        logStr.append("Content-Type: text/html\n");
                        logStr.append("Content-Length: " + content.length() + "\n");
                        logStr.append("\n");
                    }

                    else if (filepath.length > 0 && (dir.toFile().isFile())) {
                        //System.out.println("FILEEEE");


                        String ext = filepath[filepath.length - 1].split("\\.")[1];
                        int type = 0;
                        if(ext.equals("txt")){
                            type = 1;
                        }
                        else if(ext.equals("jpeg") || ext.equals("jpg")){
                            type = 2;
                        }
                        else if(ext.equals("png")){
                            type = 3;
                        }
                        File fp = new File(dir.toString());
                        FileInputStream fin = new FileInputStream(fp);
                        DataOutputStream dout = new DataOutputStream(s.getOutputStream());

                        pr.write("HTTP/1.1 200 OK\r\n");
                        pr.write("Server: Java HTTP Server: 1.0\r\n");
                        pr.write("Date: " + new Date() + "\r\n");

                        logStr.append("HTTP/1.1 200 OK\n");
                        logStr.append("Server: Java HTTP Server: 1.0\n");
                        logStr.append("Date: " + new Date() + "\n");



                        if(type == 1){
                            pr.write("Content-Type: text/plain\r\n");
                            logStr.append("Content-Type: text/plain\n");
                        }
                        else if(type == 2){
                            pr.write("Content-Type: image/jpg\r\n");
                            logStr.append("Content-Type: image/jpg\n");
                        }
                        else if(type == 3){
                            pr.write("Content-Type: image/png\r\n");
                            logStr.append("Content-Type: image/png\n");
                        }
                        else {
                            pr.write("Content-Disposition: attachment\r\n");
                            pr.write("Content-Type: "+ ext + "\r\n");
                            logStr.append("Content-Disposition: attachment\n");
                            logStr.append("Content-Type: attachment/"+ ext + "\n");
                        }

                        pr.write("Content-Length: " + fp.length() + "\r\n");
                        pr.write("\r\n");
                        pr.flush();

                        logStr.append("Content-Length: " + fp.length() + "\n");
                        logStr.append("\n");

                        //dout.writeLong(txt.length());
                        //pr.write(content);
                        byte[] chunk = new byte[CHUNKSIZE];
                        int count;
                        while ((count = fin.read(chunk)) != -1) {
                            dout.write(chunk, 0, count);
                            ;
                            dout.flush();
                        }
                        fin.close();

                    }
                    else {

                        try (DirectoryStream<Path> stream = Files.newDirectoryStream(dir)) {
                            for (Path filename : stream) {
                                boolean isDir = filename.toFile().isDirectory();
                                sb.append("\t\t\t<li>");
                                if (isDir) {
                                    sb.append("<i><b>");
                                }
                                if (filepath.length > 0) {
                                    sb.append("<a href = \"" + splitInput[1] + "/" + filename.getFileName() + "\">");
                                } else {
                                    sb.append("<a href = \"" + "/" + filename.getFileName() + "\">");
                                }


                                sb.append(filename.getFileName());
                                sb.append("</a>");
                                if (isDir) {
                                    sb.append("</i></b>");
                                }
                                sb.append("</li>\n");

                            }
                        } catch (IOException | DirectoryIteratorException x) {

                            System.err.println(x);
                        }
                        sb.append("\t\t<ul>\n");

                        sb.append("\t</body>\n");
                        sb.append("</html>\n");


                        String content = sb.toString();
                        //System.out.println(content);

                        pr.write("HTTP/1.1 200 OK\r\n");
                        pr.write("Server: Java HTTP Server: 1.0\r\n");
                        pr.write("Date: " + new Date() + "\r\n");
                        pr.write("Content-Type: text/html\r\n");
                        pr.write("Content-Length: " + content.length() + "\r\n");
                        pr.write("\r\n");
                        pr.write(content);
                        pr.flush();

                        logStr.append("HTTP/1.1 200 OK\n");
                        logStr.append("Server: Java HTTP Server: 1.0\n");
                        logStr.append("Date: " + new Date() + "\n");
                        logStr.append("Content-Type: text/html\n");
                        logStr.append("Content-Length: " + content.length() + "\n");
                        logStr.append("\n");
                    }
                }
                else if(splitInput[0].equals("UPLOAD"))
                {
                    //System.out.println("0123456789");
                    logStr.append("Request:\n" + input + "\n");

                        if (splitInput[1].endsWith(".txt") || splitInput[1].endsWith(".png") || splitInput[1].endsWith(".jpg") || splitInput[1].endsWith(".mp4")) {
                            //System.out.println("File FOUND!");

                            Path dir = Path.of("root");
                            File folder = new File(dir.toString() + "/uploaded");
                            folder.mkdir();
                            dir = Path.of("root/uploaded");
                            //String delim = "\\\\";
                            String[] temp = splitInput[1].split("\\\\");
                            String filename = temp[temp.length-1];
                            File newfile = new File(dir.toString() +"/"+ filename);
                            newfile.createNewFile();

                            byte[] chunk = new byte[CHUNKSIZE];
                            int count;

                            FileOutputStream fout = new FileOutputStream(newfile);
                            //in.close();
                            DataInputStream bin = new DataInputStream(s.getInputStream());

                            while((count = bin.read(chunk))!=-1){
                                fout.write(chunk, 0, count);
                                fout.flush();
                            }

                            fout.close();

                            logStr.append("Successfully Handled request# " + id);
                        }
                        else{
                            System.out.println("Invalid file extension");
                            logStr.append("Invalid file extension");
                        }

                    //System.out.println("Request:\n" + input + "\n");

                }
                else{
                    logStr.append("*Not a GET or UPLOAD Request*\n");
                    logStr.append("Request: " + input + "\n");
                    System.out.println("*Not a GET or UPLOAD Request*\n");
                    System.out.println("Request:\n" + input + "\n");
                }
            }


            Files.write(Paths.get("log.txt"), logStr.toString().getBytes(), StandardOpenOption.APPEND);


            System.out.println("Closing Socket for req# " + id);
            s.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }
    }
}

//D:\L3T2\CSE322\Offline2\Final\log.txt
//F:\Pictures\Quotes.txt
//F:\Pictures\Trips\India2022\GOPRO.mp4
//D:\L3T2\CSE322\Offline2\Final\index.html