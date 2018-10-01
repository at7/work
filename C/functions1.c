#include <stdio.h>

// int *px decalared to be a pointer 
 void swap(int *px, int *py) {
 	printf("%d\n", *px); // contents of px
 	int temp;
 	temp = *px; // temp gets assigned to the content of px
 	printf("%d\n", temp);
 	*px = *py;
 	*py = temp;
 }

 int main() {
 	int a = 5;
 	int b = 12;
 	printf("%d\n", a);
 	printf("%p\n", &a);
 	printf("%d\n", b);
 	printf("%p\n", &b); // print pointer address
 	swap(&a, &b);
 	printf("%d\n", a);
 	printf("%d\n", b);
 }