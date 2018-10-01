#include <stdio.h>
 
// msg is a pointer variable, msg points to the message 
void fortune_cookie(char msg[]) {
	printf("Message reads: %s\n", msg);
	printf("msg occupies %i bytes\n", sizeof(msg)); // sizeof returns the size of a pointer to a string

}


 int main() {
 	char quote[] = "cookies make you fat";
 	// array variable can be used as a pointer to the start of the array in memory
 	// associate the address of the first character with the quote variable
 	// array variable is like a pointer
 	printf("This quote string is stored at: %p\n", quote);
 	// even though it looked like you were passing a string to the function, you were actually just passing a pointer to it
 	fortune_cookie(quote);

 	int contestants[] = {1, 2, 3};
 	int *choice = contestants; // choice is now the address of the contestants array
 	//contestants[2] == *choice == contestants[0]  == 2
 	contestants[0] = 2;
 	contestants[1] = contestants[2];
 	contestants[2] = *choice;
 	printf("I'm going to pick contestants number %i\n", contestants[2]);


 	char s[] = "How big is it?";
 	char *t = s;
 	printf("Sizeof array %i\n", sizeof(s));
 	printf("Sizeof pointer %i\n", sizeof(t));
 	// a pointer variable is just a variable thay stores a memory address

 	int drinks[] = {4, 2, 3};
 	printf("1st order: %i drinks\n", drinks[0]);
 	printf("1st order: %i drinks\n", *drinks);
 	printf("3rd order: %i drinks\n", drinks[2]);
 	printf("3rd order: %i drinks\n", *(drinks + 2));


 	return 0;

 }

