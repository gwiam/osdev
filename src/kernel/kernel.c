/*

A basic kernel

*/
int add_int(int a, int b){
	return a + b;
}
// loading address will be determined by the linker to be 0x1000
void main(){
	char* video_mem = (char*) 0xb8000;	// define start addr for video memory
	*video_mem = 'X';					// kernel just displays X on the top-left
										// corner of the screen
	add_int(2,5);
}

