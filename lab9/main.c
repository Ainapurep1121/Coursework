

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
volatile unsigned int * AES_PTR = (unsigned int *)0x00000100;


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
	for (k; k < 3; k++) {
		word[k] = word[k + 1];
	}
	word[3] = temp;
}

void SubWord(unsigned char * word)
{
	// Implement this function
	int k = 0;
	for (k; k < 4; k++) {
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
	int i, j;
	word = keyNum * 16;
	word1 = word - 4;
	word4 = word - 16;

	for (i = 0; i < 4; i++) {
		keyWord1[i] = KeySchedule[word1 + i];		//Now keyWord holds W-1
		keyWord4[i] = KeySchedule[word4 + i];		//Now keyWord holds W-1
		RconVal[3 - i] = (unsigned char)((Rcon[keyNum] >> (8 * i)) & 0x00FF);		//RconVal holds the Rcon for the correct number roundkey
	}
	for (i = 0; i < 4; i++) {
		printf("%x", RconVal[i]);
	}
	printf("\n");

	// First column use Rcon
	RotWord(keyWord1);
	SubWord(keyWord1);

	for (i = 0; i < 4; i++) {
		currkey[i * 4] = keyWord1[i] ^ keyWord4[i] ^ RconVal[i];
		KeySchedule[word + i] = keyWord1[i] ^ keyWord4[i] ^ RconVal[i];
	}
	
	for (i = 0; i < 3; i++) {
		word1 = word1 + 4;
		word4 = word4 + 4;
		for (j = 0; j < 4; j++) {
			currkey[(4 * j) + i+1] = KeySchedule[word1 + j] ^ KeySchedule[word4 + j];
			KeySchedule[word + (4 * (i + 1)) + j] = KeySchedule[word1 + j] ^ KeySchedule[word4 + j];
			
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
	
	int i, j;
	unsigned char tempState[16];

	tempState[0] = State[0];
	tempState[1] = State[1];
	tempState[2] = State[2];
	tempState[3] = State[3];

	tempState[4] = State[5];
	tempState[5] = State[6];
	tempState[6] = State[7];
	tempState[7] = State[4];

	tempState[8] = State[10];
	tempState[9] = State[11];
	tempState[10] = State[8];
	tempState[11] = State[9];

	tempState[12] = State[15];
	tempState[13] = State[12];
	tempState[14] = State[13];
	tempState[15] = State[14];

	

	for (i = 0; i < 16; i++)
		State[i] = tempState[i];
			
	
}
void MixColumns(unsigned char * State)
{
	int i, j, k;

	unsigned char tempState[16];

	for (j = 0; j < 4; j++) {
		tempState[j] = gf_mul[State[j]][0] ^ gf_mul[State[4 + j]][1] ^ State[8 + j] ^ State[12 + j];
		tempState[4 + j] = gf_mul[State[4 + j]][0] ^ gf_mul[State[8 + j]][1] ^ State[12 + j] ^ State[j];
		tempState[8 + j] = gf_mul[State[8 + j]][0] ^ gf_mul[State[12 + j]][1] ^ State[j] ^ State[4 + j];
		tempState[12 + j] = gf_mul[State[12 + j]][0] ^ gf_mul[State[j]][1] ^ State[4 + j] ^ State[8 + j];
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
	unsigned char RoundKey[16];
	unsigned char KeySchedule[192];
	int i,m;

	State[0] = charsToHex(msg_ascii[0], msg_ascii[1]);
	State[4] = charsToHex(msg_ascii[2], msg_ascii[3]);
	State[8] = charsToHex(msg_ascii[4], msg_ascii[5]);
	State[12] = charsToHex(msg_ascii[6], msg_ascii[7]);
	State[1] = charsToHex(msg_ascii[8], msg_ascii[9]);
	State[5] = charsToHex(msg_ascii[10], msg_ascii[11]);
	State[9] = charsToHex(msg_ascii[12], msg_ascii[13]);
	State[13] = charsToHex(msg_ascii[14], msg_ascii[15]);
	State[2] = charsToHex(msg_ascii[16], msg_ascii[17]);
	State[6] = charsToHex(msg_ascii[18], msg_ascii[19]);
	State[10] = charsToHex(msg_ascii[20], msg_ascii[21]);
	State[14] = charsToHex(msg_ascii[22], msg_ascii[23]);
	State[3] = charsToHex(msg_ascii[24], msg_ascii[25]);
	State[7] = charsToHex(msg_ascii[26], msg_ascii[27]);
	State[11] = charsToHex(msg_ascii[28], msg_ascii[29]);
	State[15] = charsToHex(msg_ascii[30], msg_ascii[31]);

	RoundKey[0] = charsToHex(key_ascii[0], key_ascii[1]);
	RoundKey[4] = charsToHex(key_ascii[2], key_ascii[3]);
	RoundKey[8] = charsToHex(key_ascii[4], key_ascii[5]);
	RoundKey[12] = charsToHex(key_ascii[6], key_ascii[7]);
	RoundKey[1] = charsToHex(key_ascii[8], key_ascii[9]);
	RoundKey[5] = charsToHex(key_ascii[10], key_ascii[11]);
	RoundKey[9] = charsToHex(key_ascii[12], key_ascii[13]);
	RoundKey[13] = charsToHex(key_ascii[14], key_ascii[15]);
	RoundKey[2] = charsToHex(key_ascii[16], key_ascii[17]);
	RoundKey[6] = charsToHex(key_ascii[18], key_ascii[19]);
	RoundKey[10] = charsToHex(key_ascii[20], key_ascii[21]);
	RoundKey[14] = charsToHex(key_ascii[22], key_ascii[23]);
	RoundKey[3] = charsToHex(key_ascii[24], key_ascii[25]);
	RoundKey[7] = charsToHex(key_ascii[26], key_ascii[27]);
	RoundKey[11] = charsToHex(key_ascii[28], key_ascii[29]);
	RoundKey[15] = charsToHex(key_ascii[30], key_ascii[31]);

	for (m = 0; m < 16; m++) printf("%x ", State[m]);
	printf("\n");  

	KeySchedule[0] = RoundKey[0];
	KeySchedule[4] = RoundKey[1];
	KeySchedule[8] = RoundKey[2];
	KeySchedule[12] = RoundKey[3];
	KeySchedule[1] = RoundKey[4];
	KeySchedule[5] = RoundKey[5];
	KeySchedule[9] = RoundKey[6];
	KeySchedule[13] = RoundKey[7];
	KeySchedule[2] = RoundKey[8];
	KeySchedule[6] = RoundKey[9];
	KeySchedule[10] = RoundKey[10];
	KeySchedule[14] = RoundKey[11];
	KeySchedule[3] = RoundKey[12];
	KeySchedule[7] = RoundKey[13];
	KeySchedule[11] = RoundKey[14];
	KeySchedule[15] = RoundKey[15];
	
	key[0] = (uint)((RoundKey[0] << 24) & 0xFF000000) | (uint)((RoundKey[1] << 16) & 0x00FF0000) | (uint)((RoundKey[2] << 8) & 0x0000FF00) | (uint)((RoundKey[3]) & 0x000000FF);
	key[1] = (uint)((RoundKey[4] << 24) & 0xFF000000) | (uint)((RoundKey[5] << 16) & 0x00FF0000) | (uint)((RoundKey[6] << 8) & 0x0000FF00) | (uint)((RoundKey[7]) & 0x000000FF);
	key[2] = (uint)((RoundKey[8] << 24) & 0xFF000000) | (uint)((RoundKey[9] << 16) & 0x00FF0000) | (uint)((RoundKey[10] << 8) & 0x0000FF00) | (uint)((RoundKey[11]) & 0x000000FF);
	key[3] = (uint)((RoundKey[12] << 24) & 0xFF000000) | (uint)((RoundKey[13] << 16) & 0x00FF0000) | (uint)((RoundKey[14] << 8) & 0x0000FF00) | (uint)((RoundKey[15]) & 0x000000FF);

	AddRoundKey(State, RoundKey);

	for (m = 0; m < 16; m++) printf("%x ", State[m]);
	printf("\nLoop Starts:\n\n");

	for (i = 0; i < 9; i++) {
		for (m = 0; m < 16; m++) printf("%x ", State[m]);
			printf("\n");
		SubBytes(State); 
		for (m = 0; m < 16; m++) printf("%x ", State[m]);
			printf("\n");
		ShiftRows(State);
		for (m = 0; m < 16; m++) printf("%x ", State[m]);
			printf("\n");
		MixColumns(State);
		for (m = 0; m < 16; m++) printf("%x ", State[m]);
			printf("\n");
		KeyExpansion(KeySchedule, RoundKey, i + 1);
		for (m = 0; m < 16; m++) printf("%x ", RoundKey[m]);
			printf("\n");
		AddRoundKey(State, RoundKey); 
		printf("\n");
	}
	KeyExpansion(KeySchedule, RoundKey, 10);
	for (m = 0; m < 16; m++) printf("%x ", RoundKey[m]);
		printf("\n");
	SubBytes(State);
	for (m = 0; m < 16; m++) printf("%x ", RoundKey[m]);
		printf("\n");
	ShiftRows(State);
	for (m = 0; m < 16; m++) printf("%x ", RoundKey[m]);
		printf("\n");
	AddRoundKey(State, RoundKey);
	int s = 0;
	printf("\n Final State \n");
	for (s; s < 16; s++) {
		printf("%x ", State[s]);
	}
	

	printf("\n msg_enc");
	for (i = 0; i < 4; i++) {
		printf("%u", msg_enc[i]);
	}
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

	msg_enc[0] = (uint)((State[0] << 24) & 0xFF000000) | (uint)((State[1] << 16) & 0x00FF0000) | (uint)((State[2] << 8) & 0x0000FF00) | (uint)((State[3]) & 0x000000FF);
	msg_enc[1] = (uint)((State[4] << 24) & 0xFF000000) | (uint)((State[5] << 16) & 0x00FF0000) | (uint)((State[6] << 8) & 0x0000FF00) | (uint)((State[7]) & 0x000000FF);
	msg_enc[2] = (uint)((State[8] << 24) & 0xFF000000) | (uint)((State[9] << 16) & 0x00FF0000) | (uint)((State[10] << 8) & 0x0000FF00) | (uint)((State[11]) & 0x000000FF);
	msg_enc[3] = (uint)((State[12] << 24) & 0xFF000000) | (uint)((State[13] << 16) & 0x00FF0000) | (uint)((State[14] << 8) & 0x0000FF00) | (uint)((State[15]) & 0x000000FF);

	AES_PTR[0] = (charsToHex(key_ascii[0], key_ascii[1]) << 24) | (charsToHex(key_ascii[2], key_ascii[3]) << 16);
	AES_PTR[1] = key[1];
	AES_PTR[2] = key[2];
	AES_PTR[3] = (charsToHex(key_ascii[28], key_ascii[29]) << 8) | charsToHex(key_ascii[30], key_ascii[31]);


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
			for (i = 0; i < 4; i++) {
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for (i = 0; i < 4; i++) {
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


