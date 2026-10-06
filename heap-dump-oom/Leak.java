import java.util.*;

/** Caches every order forever: a classic unbounded static map. */
public class Leak {
    record Order(int id, byte[] payload) { }

    static final Map<Integer, Order> CACHE = new HashMap<>();

    public static void main(String[] a) {
        for (int i = 0; ; i++) {
            CACHE.put(i, new Order(i, new byte[10_000]));
        }
    }
}
