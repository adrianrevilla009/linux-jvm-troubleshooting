import java.net.*;
import java.util.*;

/** Opens connections to a local server and never closes them. */
public class SocketLeak {
    public static void main(String[] a) throws Exception {
        int n = Integer.parseInt(a[0]);
        ServerSocket server = new ServerSocket(0, 1000, InetAddress.getLoopbackAddress());
        List<Socket> leaked = new ArrayList<>();
        Thread.ofPlatform().daemon().start(() -> {
            try { while (true) leaked.add(server.accept()); } catch (Exception e) { }
        });
        for (int i = 0; i < n; i++) {
            leaked.add(new Socket(InetAddress.getLoopbackAddress(), server.getLocalPort()));
        }
        System.out.println("port=" + server.getLocalPort());
        Thread.sleep(60_000);
    }
}
