/*
 *
 * General purpose C functions
*/
/*
@brief Copies a section of memories from src to dest

@param src memory addr of what you want to copy
@param dest memory addr of where you want it to be copied
@param no_bytes number of bytes to copy (length of section)
*/
void mem_cp(char* src, char* dest, int no_bytes){
	int i;
	for (i=0; i < no_bytes; i++){
		*(dest + i) = *(src + i);	// copy byte-wise from A to B
	}	
}

/*
Gets the length of the given string
*/
int str_len(char* str){
	int i=0;
	while(str[i] != 0){
		i++;
	}
	return i;
}

/*
@brief Concatenate two strings
@param str1 first string
@param str2 second string
*/
char* str_cat(char* str1, char* str2){
	int str1_len = str_len(str1);
	char* endp = (char*)(str1 + str1_len);
	int str2_len = str_len(str2);
	mem_cp(str2, endp, str2_len);
	str1[str1_len+str2_len] = 0;	// NULL-terminate new string
	return str1;
}
/*
Concatenate a character onto a given string

@param str string where things need to get concatenated on
@param c character
@param inverse 0 for appending, 1 for prepending
*/
char* str_char_cat(char* str, char c, char inverse){
	if (inverse){
		//prepend char
		*(str-1) = c; // not sure this is a good idea
		return str-1;
	}else{
		//append char
		int str1_len = str_len(str);
		char* endp = (char*)(str + str1_len);
		*endp = c;
		return str;
	}
}

/*
Converts an int into its ASCII character representation
*/
char* int2str(int value){
	char* total_str = "";
	int digit_len = 0;
	int val2 = value;
	while(val2 > 0){
		digit_len++;
		val2 /= 10;
	}
	total_str[digit_len+1] = 0;
	int i=1;
	while(value > 0){
		int digit = value % 10;	// n mod 10 always gives us the last digit of n
		char character = 48 + digit;	// get ASCII code, digits are conveniently encoded!
		total_str[digit_len-i] = character;
		//total_str = str_char_cat(total_str,character,1);	// concat all the digits by prepending them
		value = value/10;					// cut off last digit and start again
		i++;
	}
	return total_str;
}
