# 多线程socket

```
//因为是多线程，所以不在服务端直接做业务处理，而是在线程类里处理
public class NetServer {

    public static void go(){
        int PORT=7775;
        try {
            //指定端口专门处理这件事
            ServerSocket ss = new ServerSocket(PORT);
            System.out.println("服务器已启动");
            //死循环，目的是一直保持监听状态
            while (true) {
                //开启监听
                Socket s = ss.accept();
                //将连接的客户端交给一个线程去处理
                Thread t = new Thread(new ClentThread(s));
                //开启线程
                t.start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public static void main(String[] args){
        go();
    }
}
```

```
public class ClentThread implements Runnable {
    private Socket socket = null;
    public ClentThread(Socket s) {
        this.socket = s;
    }

    @Override
    public void run() {
        try {
            //接收客户端消息
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            //按行读取客户端的消息内容，并且拼接在一起
            StringBuffer sb=new StringBuffer();
            String tmp="";
            while((tmp=in.readLine())!=null){
                sb.append(tmp);
            }
            System.out.println("客户端发送的是："+sb.toString());
            //转码
            String rc=new String(sb.toString().getBytes(),"UTF-8");
            
            //将消息返回给客户端
            PrintWriter out = new PrintWriter(new BufferedWriter(new OutputStreamWriter(socket.getOutputStream())), true);
            out.print(rc);
            //该关的都关掉
            out.close();
            in.close();
        } catch (Exception e) {
            System.out.println(e.toString());
        } finally {
            try {
                socket.close();
            } catch (Exception e) {
                System.out.println(e.toString());
            }
        }
    }
}
```