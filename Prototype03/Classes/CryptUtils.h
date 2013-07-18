#ifndef __CC_CRYPT_UTILS_H
#define __CC_CRYPT_UTILS_H

#ifdef __cplusplus
extern "C" 
{
#endif

int CCEncryptMemory(unsigned char *data, unsigned int byteLength, unsigned char **encryptedData);
int CCDecryptMemory(unsigned char *data, unsigned int byteLength, unsigned char **decryptedData);
	
#ifdef __cplusplus
}
#endif
		
#endif