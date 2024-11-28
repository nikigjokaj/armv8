import java.util.Scanner;

public class Task2 {

	public static void analizeString(String str) {
		int uppercase = 0, lowercase = 0, digits = 0, special = 0;
		
		for(int i = 0; i<str.length(); i++) {
			char c = str.charAt(i);
			
			if('A' <= c && c <= 'Z') {
				uppercase++;
			} else if('a' <= c && c <= 'z') {
				lowercase++;
			} else if('0' <= c && c <= '9') {
				digits++;
			} else {
				special++;
			}
			
		}
		
		System.out.println("The string contains");
		System.out.println("Uppercase letters: "+uppercase);
		System.out.println("Lowercase letters: "+lowercase);
		System.out.println("Digits: " + digits);
		System.out.println("Special characters: "+special);
	}
	
	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		
		System.out.println("Please enter a string");
		
		String str = sc.nextLine();
		
		analizeString(str);
	}

}
