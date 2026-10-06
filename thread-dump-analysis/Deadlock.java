/** Two threads take two locks in opposite order and block each other forever. */
public class Deadlock {
    static final Object ORDERS = new Object(), PAYMENTS = new Object();

    static void lockBoth(Object first, Object second) throws InterruptedException {
        synchronized (first) {
            Thread.sleep(200); // widen the race window so the deadlock is deterministic
            synchronized (second) {
                System.out.println("never reached");
            }
        }
    }

    public static void main(String[] a) throws Exception {
        new Thread(() -> { try { lockBoth(ORDERS, PAYMENTS); } catch (InterruptedException e) { } }, "order-writer").start();
        new Thread(() -> { try { lockBoth(PAYMENTS, ORDERS); } catch (InterruptedException e) { } }, "payment-writer").start();
        System.out.println("started");
        Thread.sleep(60_000);
    }
}
