/*

A basic kernel

*/
#include "drivers/screen.h"

// loading address will be determined by the linker to be 0x1000
void main(){
	print("\n");
	print("We are running a simple kernel!");	
}

