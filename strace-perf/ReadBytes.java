import java.io.*;

/** Reads a file byte by byte; arg 2 = "buffered" wraps the stream in a 64 KiB buffer. */
public class ReadBytes {
    public static void main(String[] a) throws Exception {
        InputStream in = new FileInputStream(a[0]);
        if (a.length > 1 && a[1].equals("buffered")) in = new BufferedInputStream(in, 65536);
        int n = 0;
        try (in) {
            while (in.read() != -1) n++;
        }
        System.out.println("bytes=" + n);
    }
}
