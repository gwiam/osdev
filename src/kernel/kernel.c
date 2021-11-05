/*

A basic kernel

*/
#include "drivers/screen.h"
#include "utils.h"

// loading address will be determined by the linker to be 0x1000
void main(){
	print("\n");
	print("We are running a simple kernel!\n");
	int i;
	for(i=0; i < 3; i++){
		char* num = int2str(i);
		print("Line ");
		print(num);
		print("\n");
	}
}

