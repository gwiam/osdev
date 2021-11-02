/*
Header file for generic C function lib
*/


#ifndef UTILS_H
#define UTILS_H
void mem_cp(char* src, char* dest, int no_bytes);
int str_len(char* str);
char* str_cat(char* str1, char* str2);
char* int2str(int value);
#endif
