import java.util.Scanner;

public class Task1 {

	public static void printAutomorficNumbersUntilN(int n) {
		int base = 10;
		
		for(int i = 1; i<=n; i++) {
			if(i % base == 0) {
				base *= 10;
			}
			
			if((i*i) % base == i) {
				if(i > 1) {
					System.out.print(", ");
				}
				System.out.print(i);
			}
		}
	}
	
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		
		System.out.println("Enter a positive integer:");
		
		int n = sc.nextInt();
		
		if(n < 1) {
			System.out.println("Error: number must be a positive integer");
		} else {
			printAutomorficNumbersUntilN(n);
		}
	}

}
