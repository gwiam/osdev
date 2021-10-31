/*
 *
 *	Dealing with low-level IO port access
*/

// Reading 1byte content on given port and return it
// port: 2 byte number
unsigned char port_byte_in(unsigned short port){
	// usage of inline assembly required
	unsigned char result;	//1 byte memory reservation

	//inline assembly
	//__asm__ built-in function
	//syntax __asm__(ASM CODE: OUTPUT OPERANDS: INPUT_OPERANDS)
	// '=' sign specifies that the output operand is write-only
	// =r means any gp register
	// specific register names with a, b,c,d,S,D
	// '=a' (result) here means that register AL value gets put into result in the end
	// 'd' (port) here means load edx with value port
	// GCC needs GAS assembly syntax, so OP SOURCE, DESTINATION
	// instead of intel assembly which is OP DESTINATION, SOURCE
	__asm__("in %%dx, %%al": "=a" (result): "d" (port));
	return result;
}

// Write given byte through port
void port_byte_out(unsigned short port, unsigned char data){
	// usage of double %% here necessary because we want to escape the % character
	// otherwise % is a key symbol that gets interpreted
	__asm__("out %%al, %%dx":: "a" (data), "d" (port));
}

// Reading a word(2 bytes) from port
unsigned short port_word_in(unsigned short port){
	unsigned short result;
	__asm__("in %%dx, %%al": "=a" (result): "d" (port));
	return result;
}

// Writing 2 bytes through port
void port_word_out(unsigned short port, unsigned short data){
	__asm__("out %%al, %%dx":: "a" (data), "d" (port));
}
