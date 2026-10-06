/** CPU-bound workload with an obvious hot method (priceOrder) for JFR to find. */
public class Busy {
    static double priceOrder(int n) {
        double sum = 0;
        for (int i = 1; i < 2_000; i++) sum += Math.sqrt(n * i) / Math.log(i + 1);
        return sum;
    }

    public static void main(String[] a) {
        long end = System.nanoTime() + 6_000_000_000L;
        double total = 0;
        for (int n = 0; System.nanoTime() < end; n++) total += priceOrder(n);
        System.out.println(total > 0);
    }
}
