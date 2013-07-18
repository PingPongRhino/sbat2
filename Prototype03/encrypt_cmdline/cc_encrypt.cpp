#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <memory.h>
#include <ctype.h>

#include "../Classes/CryptUtils.h"

int main(int argc, char **argv)
{
   if(argc!=4)
   {
      for(int i=0; i<argc; i++)
          printf("argv[%d] = %s\n",i,argv[i]);
      printf("\n\n%s -e|-d <infile> <outfile>\n", argv[0]);
      return -1;
   }

   FILE *inFP = fopen(argv[2], "rb");

   if(inFP!=NULL)
   {
      fseek(inFP, 0L, SEEK_END);
      long fileSize = ftell(inFP);
      fseek(inFP, 0L, SEEK_SET);

      //allocate data and round up to 4 bytes for the TEA implementation
//      long dataSize = fileSize + ((4-(fileSize&3))&3);
      long dataSize = fileSize;
      unsigned char *indata = new unsigned char[dataSize];
      memset( indata, dataSize,0);

      printf("reading %lu bytes from %s\n", fileSize, argv[2]);
      fread(indata, sizeof(char), fileSize, inFP);
      fclose(inFP);

      printf("processing %lu bytes\n", dataSize);
      unsigned int encryptedSize = fileSize;
      unsigned char *outputData = NULL;

      if(tolower(argv[1][1])=='e')
      {
         printf("encrypting\n" );
         encryptedSize = CCEncryptMemory(indata, dataSize, &outputData);
      }
      else
      {
         printf("decrypting\n" );
         encryptedSize = CCDecryptMemory(indata, dataSize, &outputData);
      }

      if (!outputData) {
         printf("failed to encrypt/decrypt file\n");
         delete [] indata;
         printf("finished\n");
         return 0;
      }
      
      FILE *outFP = fopen(argv[3],"wb");
      if(outFP!=NULL)
      {
         printf("writing %d bytes to %s\n", encryptedSize, argv[3]);
         fwrite(outputData, sizeof(char), encryptedSize, outFP);
         fclose(outFP);
      }

      free(outputData);
      delete [] indata;
   }
   printf("finished\n");

   return 0;
}


