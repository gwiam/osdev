/*
 * Low-level driver for the framebuffer in VGA text mode
 *
*/
#include "screen.h"
#include "kernel/utils.h"

extern unsigned char port_byte_in(unsigned short port);
extern void port_byte_out(unsigned short port, unsigned char data);
/*
 Print a character onto the screen at coordinate COL, ROW or at the current cursor pos
*/
void print_char(char c, int col, int row, char attr){
	//create a pointer of 1 byte to the starting position in memory
	unsigned char *vid_mem = (unsigned char*) VIDEO_MEM;
	
	//check if attr is 0, then it is default white char on black background
	if(!attr){
		attr = WHITE_ON_BLACK;
	}
	
	// calculate the offset from base address
	// if one of col or row is negative, just get the current position of blinking cursor
	int offset = (col >= 0 && row >= 0) ? get_screen_offset(col, row) : get_cursor();
	
	// if its a '\n' character, set offset to end of current row so the next print
	// happens in a new row on col 0
	if (c == '\n'){
		int rows = offset / (2* MAX_COLS);
		offset = get_screen_offset(79,rows);	// set to last char in the row		
	} else{
		// normal case where we just want to print at offset
		vid_mem[offset] = c;
		vid_mem[offset+1] = attr;
	}
	
	offset += 2;	// go to the next cell
	offset = handle_scrolling(offset);	// in case we run out of screen, deal with scrolling action
	set_cursor(offset);	//set cursor to the next cell
}

/*
Get the offset in linear spaces from base address
*/
int get_screen_offset(int col, int row){
	return 2 * (row * MAX_COLS + col); // number of rows * 80 characters (line width) + col
									  // *2 because each cell is 2 bytes long
}

/*
Get the cursor offset in video memory
*/
int get_cursor(){
	// screen device uses control register as an index to select
	// the internal registers of the VGA controller
	// of which there are over 300!
	// all VGA registers are a single byte

	// 'Indexing' the register means you put the number of the register in one field
	// and the value to write in another field and same for reading
	
	// for us, the cursor location high and low registers are revelant
	// cursor location is encoded in 2 bytes
	// they come by
	//	1. setting port to 0x3d5
	//	2. setting index to 0xE (14) or 0xF (15)
	// reg 0xE (14): cursor location higher 8bits
	// reg 0xF (15): cursor location lower 8bits

	// other registers include:
	// underline location register 0x3d5 index 0x14 

	port_byte_out(REG_SCREEN_CTRL, 0xe);	// selecte 0xE index for higher 8bit
	int cursor_offset = port_byte_in(REG_SCREEN_DATA) << 8; //port_byte_in = reading out
	// what is read out is the higher 8 bits, we need to put it in the 8-16 position
	port_byte_out(REG_SCREEN_CTRL, 0xf);	// select 0xF index for lower 8bit
	cursor_offset += port_byte_in(REG_SCREEN_DATA);	//put in the lower 8bits by adding them onto
	// the offset
	
	// since each cell is 2bytes long and not just 1byte as reported by the VGA controller
	// since it only counts how many characters off the cursor is, we need to multiply by 2
	return cursor_offset*2;
}

/*
Set cursor to the given offset
*/
void set_cursor(int offset){
	offset /= 2;	// convert from cell memory offset back to character offset needed
					// for the VGA controller
	//similar procedure to get_cursor but instead of reading, we write
	port_byte_out(REG_SCREEN_CTRL, 0xe);	// select index for high bits
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));	//fit bits 8-16
	port_byte_out(REG_SCREEN_CTRL, 0xf);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff)); // get the lower 8 bits
	// by masking and logical AND
	
}

/*
Print given string at specified location row, col
*/
void print_at(char* str, int col, int row){
	if (col >= 0 && row >= 0){
		// update cursor location to the location
		set_cursor(get_screen_offset(col, row));
	}
	
	//loop through print_char as long as it doesn't hit 0
	int i=0;
	while(str[i] != 0){
		print_char(str[i],col,row,WHITE_ON_BLACK);
		i++;
	}
}

/*
Print string at current cursor location
*/
void print(char* str){
	print_at(str, -1,-1);
}

/*
Clears the screen and resets the cursor
*/
void clear_screen(){
	int row = 0;
	int col = 0;
	for (row=0; row < MAX_ROWS; row++){
		for(col=0; col < MAX_COLS; col++){
			print_char(' ', col, row, WHITE_ON_BLACK);	//just print loads of empty strings
		}
	}
	
	// reset cursor back to 0,0 to get the impression we have reset everything
	set_cursor(get_screen_offset(0,0));
}

// implementing scrolling feature
// by deleting the very first row and then copying every following row up
// e.g. row 2 > row 1, row 3 > row 2 etc
// clear the last row for new input, giving the impression of scrolling

int handle_scrolling(int cursor_offset){
	
	// Don't do anything and return original cursor_offset if
	// cursor is still within the screen
	// within screen means < MAX_ROWS*MAX_COLS * 2 in memory
	if (cursor_offset < MAX_ROWS*MAX_COLS*2){
		return cursor_offset;
	}
	
	// here, cursor is about to go offscreen
	// copy for all rows: row n => row n-1
	int i;
	for (i = 1; i < MAX_ROWS; i++){
		mem_cp((char*)(VIDEO_MEM + get_screen_offset(0,i)), // source which is the first char of current line
				  (char*)(VIDEO_MEM + get_screen_offset(0,i-1)), // dest, which is row before
				  MAX_COLS*2	//all cells, each cell 2 bytes long
		);
	}
	
	// now that everything has moved, blank last line
	char* last_line = (char*)( VIDEO_MEM + get_screen_offset(0, MAX_ROWS-1)); //beginning addr of last line
	for (i=0; i < MAX_COLS; i++){
		last_line[i] = ' ';
	}

	// reset cursor to the beginning of the last row
	cursor_offset -= 2*MAX_COLS;	// subtract length of row from current position which would be out of bounds
	return cursor_offset;
}
