/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;


// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *  
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *  
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

void RotWord(unsigned char * word)
{
	unsigned char temp = word[0];
	int k = 0;
	for(k; k < 3; k++){
		word[k] = word[k+1];
	}
	word[3] = temp;
}

void SubWord(unsigned char * word)
{
	// Implement this function
	int k = 0;
	for(k; k < 4; k++){
		word[k] = aes_sbox[16 * (word[k] >> 4) + (word[k] & 0x0F)];
	}
}

/**
GRAPHICAL LAYOUT:

W0,0   W1,0   W2,0 ...
W0,1   W1,1   W2,1 ...
W0,2   W1,2   W2,2 ...
W0,3   W1,3   W2,3 ...

ACTUAL 1D ARRAY:

[W0,0] [W0,1] [W0,2] [W0,3] [W1,0] [W1,1] [W1,2] [W1,3] [W2,0] ......  

 */
unsigned char * KeyExpansion(unsigned char * KeySchedule, unsigned char * currkey, int keyNum)
{
	// Implement this function		
	unsigned char keyWord[4];
	unsigned char keyWord1[4];
	unsigned char keyWord4[4];
	unsigned char RconVal[4];
	unsigned char word, word1, word4;
	int i;
	word = keyNum * 16;
	word1 = word - 4;
	word4 = word - 16;

	for (i = 0; i < 4; i++){
		keyWord1[i] =  KeySchedule[word1 + i];		//Now keyWord holds W-1
		keyWord4[i] =  KeySchedule[word4 + i];		//Now keyWord holds W-1
		RconVal[3-i] = (unsigned char)((Rcon[keyNum] >> 2*i) & 0x03 );		//RconVal holds the Rcon for the correct number roundkey
	}

	// First column use Rcon
	RotWord(keyWord1);
	SubWord(keyWord1);

	for (i = 0; i < 4; i++) {
		currkey[i*4] = keyWord1[i] ^ keyWord4[i] ^ RconVal[i];
		KeySchedule[word + i] = keyWord1[i] ^ keyWord4[i] ^ RconVal[i];
	}

	for (i = 0; i < 3; i++) {
		word1 = word1 + 4;
		word4 = word4 + 4;
		for (j = 0; j < 4; j++) {
			currkey[4*(i+1) + j] = KeySchedule[word1 + j] ^ KeySchedule[word4 + j];
			KeySchedule[word + 4*(i+1) + j] = KeySchedule[word1 + j] ^ KeySchedule[word4 + j];
		}
	}

}

void AddRoundKey(unsigned char * State, unsigned char * currkey)
{
	// Implement this function
	int i;
	for (i = 0; i < 16; i++) 
		State[i] = State[i] ^ currkey[i];
}

void SubBytes(unsigned char * State)
{
	// Loop over State and substitute in given matrix values for msg.
	int i;
	for (i = 0; i < 16; i++) {
		State[i] = aes_sbox[16 * (State[i] >> 4) + (State[i] & 0x0F)];	
	}
}
void ShiftRows(unsigned char * State)
{
	int i,j;
	unsigned char tempState;
	
	for (i = 1; i < 4; i++) {
		for (j = 0; j < 4; j++) {
			tempState[4*i + j] = State[4*i + ((j+i)%4)]
		}
	}
	for (i = 0; i < 16; i++)
		State[i] = tempState[i]; 
}

void MixColumns(unsigned char * State)
{
	int i,j,k;

	unsigned char tempState[16];
	
	for (j = 0; j < 4; j++) {
		tempState[j] = gf_mul[State[j]][0] ^ gf_mul[State[4+j]][1] ^ State[8+j] ^ State[12+j];
		tempState[4 + j] = gf_mul[State[4+j]][0] ^ gf_mul[State[8+j]][1] ^ State[12+j] ^ State[j];
		tempState[8 + j] = gf_mul[State[8+j]][0] ^ gf_mul[State[12+j]][1] ^ State[j] ^ State[4+j];
		tempState[12 + j] = gf_mul[State[12+j]][0] ^ gf_mul[State[j]][1] ^ State[4+j] ^ State[8+j];
	}
	for (i = 0; i < 16; i++)
		State[i] = tempState[i]; 
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	// Implement this function
	unsigned char State[16];
	word; // ASSIGN TYPE: 32 bit; its four 8-bit data pieces
	unsigned char RoundKey[16];
	unsigned char KeySchedule[]


}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}


