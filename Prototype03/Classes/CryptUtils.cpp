// The TEA encryption algorithm was invented by 
// David Wheeler & Roger Needham at Cambridge 
// University Computer Lab
//   http://www.cl.cam.ac.uk/ftp/papers/djw-rmn/djw-rmn-tea.html (1994)
//   http://www.cl.cam.ac.uk/ftp/users/djw3/xtea.ps (1997)
//   http://www.cl.cam.ac.uk/ftp/users/djw3/xxtea.ps (1998)
//
// This code was originally written in JavaScript by 
// Chris Veness at Movable Type Ltd
//   http://www.movable-type.co.uk
//
// It was adapted to C++ by Andreas Jonsson 
//   http://www.angelcode.com
//
// 25/2/10 - modified to allow integration into the cocos2d-iphone codebase
//

#include "CryptUtils.h"
#include <stdlib.h>
#include <memory.h>
#include <CommonCrypto/CommonCryptor.h>

#define CRYPT_KEY_LEN kCCKeySizeAES256

//AES256 key is 32 bytes
unsigned char cryptKey[CRYPT_KEY_LEN] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

int AES256EncryptWithKey(unsigned char *input, unsigned int length,
                         unsigned char **output, unsigned char *key);
int AES256DecryptWithKey(unsigned char *input, unsigned int length,
                         unsigned char **output, unsigned char *key);


//CLIENT bridging functions, if you want to change the encryption algorithm change it here.
int CCEncryptMemory(unsigned char *data, unsigned int byteLength, unsigned char **encryptedData)
{
	return AES256EncryptWithKey(data, byteLength, encryptedData, cryptKey);
}

int CCDecryptMemory(unsigned char *data, unsigned int byteLength, unsigned char **decryptedData)
{
	return AES256DecryptWithKey(data, byteLength, decryptedData, cryptKey);
}

int AES256EncryptWithKey(unsigned char *input, unsigned int length,
                         unsigned char **output, unsigned char *key)
{
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t outLength = length + kCCBlockSizeAES128;
	*output = (unsigned char *)malloc(outLength);
    memset(*output, 0, outLength);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  key, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  input, length, /* input */
										  *output, outLength, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		return numBytesEncrypted;
	}
	
	free(*output); //free the buffer;
    *output = NULL;
	return -1;
}

int AES256DecryptWithKey(unsigned char *input, unsigned int length,
                         unsigned char **output, unsigned char *key)
{
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t outLength = length + kCCBlockSizeAES128;
	*output = (unsigned char *)malloc(outLength);
    memset(*output, 0, outLength);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  key, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  input, length, /* input */
										  *output, outLength, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		return numBytesDecrypted;
	}
	
	free(*output); //free the buffer;
    *output = NULL;
	return -1;
}

