import java.util.*;

/** Prints what the JVM sees, then touches 200 MB of heap so a smaller cgroup limit kills it. */
public class Hog {
    public static void main(String[] a) {
        Runtime rt = Runtime.getRuntime();
        System.out.println("cpus=" + rt.availableProcessors() + " maxHeapMB=" + rt.maxMemory() / (1 << 20));
        List<byte[]> keep = new ArrayList<>();
        for (int i = 0; i < 200; i++) {
            byte[] b = new byte[1 << 20];
            Arrays.fill(b, (byte) 1); // touch pages so they count as RSS
            keep.add(b);
        }
        System.out.println("allocated " + keep.size() + " MB");
    }
}
