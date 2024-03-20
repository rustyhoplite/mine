import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class project {

    public static void main(String[] args) throws Exception {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        String line;
        ArrayList<Integer> numbers = new ArrayList<>();

        while ((line = reader.readLine()) != null && !line.isEmpty()) {
            for (String token : line.split("[ \\r\\n]+")) {
                int num = Integer.parseInt(token);
                if (num > 32767) num = 32767;
                else if (num < -32768) num = -32768;
                numbers.add(num);
            }
        }

        int[] array = numbers.stream().mapToInt(i -> i).toArray();
        mergeSort(array, array.length);

        double median = calculateMedian(array);
        double average = calculateAverage(array);

        System.out.println(Math.round(median));
        System.out.println(Math.round(average));
    }

    public static void mergeSort(int[] a, int n) {
        if (n < 2) {
            return;
        }
        int mid = n / 2;
        int[] l = new int[mid];
        int[] r = new int[n - mid];

        System.arraycopy(a, 0, l, 0, mid);
        System.arraycopy(a, mid, r, 0, n - mid);

        mergeSort(l, mid);
        mergeSort(r, n - mid);

        merge(a, l, r, mid, n - mid);
    }

    public static void merge(int[] a, int[] l, int[] r, int left, int right) {
        int i = 0, j = 0, k = 0;
        while (i < left && j < right) {
            if (l[i] <= r[j]) {
                a[k++] = l[i++];
            } else {
                a[k++] = r[j++];
            }
        }
        while (i < left) {
            a[k++] = l[i++];
        }
        while (j < right) {
            a[k++] = r[j++];
        }
    }

    public static double calculateMedian(int[] array) {
        int size = array.length;
        if (size % 2 == 0) {
            return (array[size / 2] + array[size / 2 - 1]) / 2.0;
        } else {
            return array[size / 2];
        }
    }

    public static double calculateAverage(int[] array) {
        long sum = 0;
        for (int j : array) {
            sum += j;
        }
        return (double) sum / array.length;
    }
}
