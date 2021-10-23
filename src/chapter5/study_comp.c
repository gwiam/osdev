// understanding C compilation

int ret_baba(){
	return 0xbaba;
}

int var_func(){
	int local_var = 0xbaba;
	return local_var;
}

// understanding translations of func calls
// x86 and x86-64 calling conventions in asm differ
// on Linux gcc for x86-64, the standard is
// System V AMD64 ABI, meaning
// registers RDI/RSI/RDX/RCX/R8/R9 are saved and used as paramter passing
// IA32 comp mode EDI/ESI/EDX/ECX

// compiling on Windows might yield different assembly code
// for IA-32 targeted translation, the convention is usually
// by default cdecl and more uniform between MSFT and the Linux world

int callee_func(int arg){
	return arg;
}

void caller_func(){
	callee_func(0xdede);
}

// dealing with pointers and addresses: how do they translate between
// C and asm?
void pointer_play(){
		char* video_addr = (char*)0xb8000;	// address for the video mem block
									// because we are now in protected mode,
									// BIOS 0x10 interrupts wouldn't work to
									// print stuff

		*video_addr = 'X';			// store an ASCII value at the given video address

		// dealing with strings in C: why char* for strings?
		// because char is 1-byte and since strings have an
		// unknown length, we cannot know beforehand how much space we need to
		// reserve. So the solution: categorize it as:
		// 'reserve an unknown amount of 1-byte memory chunks starting at the first character'
		// with the memory address of the first character being the reference point

		char* my_string = "Hello";
}
