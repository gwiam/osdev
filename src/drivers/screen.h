/*
 *
 * Header file for screen.c
 *
*/

#ifndef SCREEN_H //define an include guard to avoid double definitions down the line
				 // good practice
#define SCREEN_H
// define native VGA framebuffer directly mapped IO
#define VIDEO_MEM 0xb8000	// starting address in memory
#define MAX_ROWS 25			// 80 width x 25 height
#define MAX_COLS 80

#define WHITE_ON_BLACK 0x0f	// we want white characters on black background, the first byte

// define screen IO port
#define REG_SCREEN_CTRL 0x3d4	// control register of screen
#define REG_SCREEN_DATA 0x3d5	// data register of screen
void print(char* str);
void print_at(char* str, int col, int row);
void print_char(char c, int col, int row, char attr);
int get_screen_offset(int col, int row);
int get_cursor();
void set_cursor(int offset);
void clear_screen();
#endif
