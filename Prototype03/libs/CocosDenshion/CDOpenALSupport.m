/*
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 $Id$
 */

#import "CDOpenALSupport.h"
#import "CocosDenshion.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#import "CryptUtils.h"

//
// desc: for storing the decrypted audio file data in memory
//
typedef struct {
    unsigned char *data;    // pointer to audio data
    SInt64 dataLength;      // length of audio data
} AudioFileMemory;

//
// desc: callback for reading the audio data, 
//       check AudioFileOpenWithCallbacks doc for more details
//
OSStatus AudioFileReadProc(void *inClientData, SInt64 inPosition, UInt32 requestCount, void *buffer, UInt32 *actualCount)
{
    // check parameters
    if (!inClientData || !buffer || !actualCount) {
        return EINVAL;
    }
    
    AudioFileMemory *audioFileMemory = (AudioFileMemory *)inClientData;
        
    // make sure position is within bounds
    if (inPosition < 0 || inPosition >= audioFileMemory->dataLength) {
        *actualCount = 0; // don't read anything and tell them everything is just friggin fine,
                          // this is called passive aggressive error handling ^_^
        return noErr;
    }
    
    // see if we need to cap requested length
    *actualCount = requestCount;
    SInt64 endPosition = inPosition + requestCount;
    if (endPosition >= audioFileMemory->dataLength) {
        *actualCount = requestCount - (endPosition - audioFileMemory->dataLength);
    }
    
    memcpy(buffer, audioFileMemory->data + inPosition, *actualCount);
    return noErr;
}

//
// desc: callback for getting size of audio data 
//       check AudioFileOpenWithCallbacks doc for more details
//
SInt64 AudioFileGetSizeProc(void *inClientData) {
    if (!inClientData) {
        return EINVAL;
    }
    
    AudioFileMemory *audioFileMemory = (AudioFileMemory *)inClientData;
    return audioFileMemory->dataLength;
}

//
// desc: assumes this is encrypted or packaged file and that
//       the file naming convention is filename.xxx.enc or filename.xxx.tar, etc...
//       determines type based off xxx, only coded for checking for wave and mp3
//       cause that's all I care about right now
//
// params: inFileURL[in] - file url to get audio file type on
//
// returns: audio file type id for file if successful
//          returns 0 if file type is unknown
//
AudioFileTypeID GetAudioFileTypeId(CFURLRef inFileURL)
{
    CFURLRef pathWithoutEncExtension = CFURLCreateCopyDeletingPathExtension(kCFAllocatorDefault, inFileURL);
    CFStringRef extension = CFURLCopyPathExtension(pathWithoutEncExtension);
    AudioFileTypeID audioFileTypeId = 0;
    if (CFStringCompare(extension, (CFStringRef)@"wav", kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        audioFileTypeId = kAudioFileWAVEType;
    }
    else if (CFStringCompare(extension, (CFStringRef)@"mp3", kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
        audioFileTypeId = kAudioFileMP3Type;
    }
    
    CFRelease(pathWithoutEncExtension);
    CFRelease(extension);
    return audioFileTypeId;
}

//
// desc: creates an audio file id, checks to see if file type is encrypted.
//       if it's not encrypted, then it loads it like normal and returns audioFileId.
//       if is its encrypted, it will decrypt the file in memory and load it into a AudioFileId.
//       if it decrypts, then it will return pointer to the audio data in audioFileMemory.  when
//       you close the audioFileId, be sure to free() the data pointer inside audioFileMemory.
//       I'm not really sure if we need to keep the data around, but I'm doing it to be safe.
//
// params: inFileURL[in] - url of file to load
//         audioFileId[out] - returns audio file id if file was successfully loaded
//         audioFileMemory[out] - returns pointer to audio memory if the audio file was decrpyted and loaded from mem
//                                BE SURE TO CALL free() ON THE DATA POINTER WHEN YOU ARE DONE WITH THE AUDIO FILE ID
//
// returns: returns  0 if opened file like normal (not encrypted)
//          returns  1 if dectypred file and loaded it from memory
//          returns -1 if failed to open unencrypted file
//          returns -2 if failed to open encrypted file
//          returns -3 if failed to decrypt file
//          returns -4 if failed to load audio file id with decrypted memory
//
int CreateAudioFileId(CFURLRef inFileURL, AudioFileID *audioFileId, AudioFileMemory *audioFileMemory)
{
    CFStringRef extension = CFURLCopyPathExtension(inFileURL);
    OSStatus err = noErr;
    
    // reset audioFileMemory
    memset(audioFileMemory, 0, sizeof(AudioFileMemory));
    
    // if not an encrypted file, then get audio id like always
    if (CFStringCompare(extension, (CFStringRef)@"enc", kCFCompareCaseInsensitive) != kCFCompareEqualTo) {
        CFRelease(extension);
        
        err = AudioFileOpenURL(inFileURL, kAudioFileReadPermission, 0, audioFileId);
        if (err) {
            CDLOG(@"CreateAudioFileId: AudioFileOpenURL FAILED, Error = %ld\n", err);
            return -1;
        }
        
        return 0;
    }
    
    CFRelease(extension);
    
    // else we are dealing with encrypted file, so decrypt it
    @autoreleasepool {
        NSData *encData = [NSData dataWithContentsOfURL:(NSURL *)inFileURL];
        
        if (!encData) {
            CDLOG(@"CreateAudioFileId: Failed to load %@, could not find file.", CFURLGetString(inFileURL));
            return -2;
        }
        
        audioFileMemory->dataLength = CCDecryptMemory((unsigned char *)[encData bytes], [encData length], &audioFileMemory->data);
        if (!audioFileMemory->data) {
            CDLOG(@"CreateAudioFileId: Failed to load %@, failed to decrypt.", CFURLGetString(inFileURL));
            return -3;
        }
    }
    
    err = AudioFileOpenWithCallbacks(audioFileMemory,
                                     AudioFileReadProc, NULL,
                                     AudioFileGetSizeProc, NULL,
                                     GetAudioFileTypeId(inFileURL), audioFileId);
        
    if (err) {
        char bytes[4];
        bytes[0] = (err >> 24) & 0xFF;
        bytes[1] = (err >> 16) & 0xFF;
        bytes[2] = (err >> 8) & 0xFF;
        bytes[3] = err & 0xFF;
        CDLOG(@"CreateAudioFileId: AudioFileOpenWithCallbacks FAILED, Error = %ld, %c%c%c%c\n", err, bytes[0], bytes[1], bytes[2], bytes[3]);
        return -4;
    }
    
    return 1;
}

//Taken from oalTouch MyOpenALSupport 1.1
void* CDloadWaveAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*	outSampleRate)
{
	OSStatus						err = noErr;	
	UInt64							fileDataSize = 0;
	AudioStreamBasicDescription		theFileFormat;
	UInt32							thePropertySize = sizeof(theFileFormat);
	AudioFileID						afid = 0;
	void*							theData = NULL;
    AudioFileMemory                 audioFileMemory;
	
	// Open a file with ExtAudioFileOpen()
    if (CreateAudioFileId(inFileURL, &afid, &audioFileMemory) < 0) {
        goto Exit;
    }
	
	// Get the audio data format
	err = AudioFileGetProperty(afid, kAudioFilePropertyDataFormat, &thePropertySize, &theFileFormat);
	if(err) { CDLOG(@"MyGetOpenALAudioData: AudioFileGetProperty(kAudioFileProperty_DataFormat) FAILED, Error = %ld\n", err); goto Exit; }
	
	if (theFileFormat.mChannelsPerFrame > 2)  { 
		CDLOG(@"MyGetOpenALAudioData - Unsupported Format, channel count is greater than stereo\n"); goto Exit;
	}
	
	if ((theFileFormat.mFormatID != kAudioFormatLinearPCM) || (!TestAudioFormatNativeEndian(theFileFormat))) { 
		CDLOG(@"MyGetOpenALAudioData - Unsupported Format, must be little-endian PCM\n"); goto Exit;
	}
	
	if ((theFileFormat.mBitsPerChannel != 8) && (theFileFormat.mBitsPerChannel != 16)) { 
		CDLOG(@"MyGetOpenALAudioData - Unsupported Format, must be 8 or 16 bit PCM\n"); goto Exit;
	}
	
	
	thePropertySize = sizeof(fileDataSize);
	err = AudioFileGetProperty(afid, kAudioFilePropertyAudioDataByteCount, &thePropertySize, &fileDataSize);
	if(err) { CDLOG(@"MyGetOpenALAudioData: AudioFileGetProperty(kAudioFilePropertyAudioDataByteCount) FAILED, Error = %ld\n", err); goto Exit; }
	
	// Read all the data into memory
	UInt32		dataSize = (UInt32)fileDataSize;
	theData = malloc(dataSize);
	if (theData)
	{
		AudioFileReadBytes(afid, false, 0, &dataSize, theData);
		if(err == noErr)
		{
			// success
			*outDataSize = (ALsizei)dataSize;
			//This fix was added by me, however, 8 bit sounds have a clipping sound at the end so aren't really usable (SO)
			if (theFileFormat.mBitsPerChannel == 16) { 
				*outDataFormat = (theFileFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			} else {
				*outDataFormat = (theFileFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO8 : AL_FORMAT_MONO8;	
			}	
			*outSampleRate = (ALsizei)theFileFormat.mSampleRate;
		}
		else 
		{ 
			// failure
			free (theData);
			theData = NULL; // make sure to return NULL
			CDLOG(@"MyGetOpenALAudioData: ExtAudioFileRead FAILED, Error = %ld\n", err); goto Exit;
		}	
	}
	
Exit:
	// Dispose the ExtAudioFileRef, it is no longer needed
	if (afid) AudioFileClose(afid);
    
    // clean up memory if we need to
    if (audioFileMemory.data) {
        free(audioFileMemory.data);
        memset(&audioFileMemory, 0, sizeof(audioFileMemory));
    }
    
	return theData;
}

//Taken from oalTouch MyOpenALSupport 1.4
void* CDloadCafAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei* outSampleRate)
{
	OSStatus						status = noErr;
	BOOL							abort = NO;
	SInt64							theFileLengthInFrames = 0;
	AudioStreamBasicDescription		theFileFormat;
	UInt32							thePropertySize = sizeof(theFileFormat);
	ExtAudioFileRef					extRef = NULL;
	void*							theData = NULL;
	AudioStreamBasicDescription		theOutputFormat;
	UInt32							dataSize = 0;
    AudioFileID                     audioFileId = 0;
    AudioFileMemory                 audioFileMemory;
    
    // create audio file id
    if (CreateAudioFileId(inFileURL, &audioFileId, &audioFileMemory) < 0) {
        goto Exit;
    }
	
	// Open a file with ExtAudioFileOpen()
    status = ExtAudioFileWrapAudioFileID(audioFileId, false, &extRef);
	if (status != noErr)
	{
		CDLOG(@"MyGetOpenALAudioData: ExtAudioFileOpenURL FAILED, Error = %ld\n", status);
		abort = YES;
	}
	if (abort)
		goto Exit;
	
	// Get the audio data format
	status = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &theFileFormat);
	if (status != noErr)
	{
		CDLOG(@"MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) FAILED, Error = %ld\n", status);
		abort = YES;
	}
	if (abort)
		goto Exit;
	
	if (theFileFormat.mChannelsPerFrame > 2)
	{
		CDLOG(@"MyGetOpenALAudioData - Unsupported Format, channel count is greater than stereo\n");
		abort = YES;
	}
	if (abort)
		goto Exit;
	
	// Set the client format to 16 bit signed integer (native-endian) data
	// Maintain the channel count and sample rate of the original source format
	theOutputFormat.mSampleRate = theFileFormat.mSampleRate;
	theOutputFormat.mChannelsPerFrame = theFileFormat.mChannelsPerFrame;
	
	theOutputFormat.mFormatID = kAudioFormatLinearPCM;
	theOutputFormat.mBytesPerPacket = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mFramesPerPacket = 1;
	theOutputFormat.mBytesPerFrame = 2 * theOutputFormat.mChannelsPerFrame;
	theOutputFormat.mBitsPerChannel = 16;
	theOutputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	
	// Set the desired client (output) data format
	status = ExtAudioFileSetProperty(extRef, kExtAudioFileProperty_ClientDataFormat, sizeof(theOutputFormat), &theOutputFormat);
	if (status != noErr)
	{
		CDLOG(@"MyGetOpenALAudioData: ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) FAILED, Error = %ld\n", status);
		abort = YES;
	}
	if (abort)
		goto Exit;
	
	// Get the total frame count
	thePropertySize = sizeof(theFileLengthInFrames);
	status = ExtAudioFileGetProperty(extRef, kExtAudioFileProperty_FileLengthFrames, &thePropertySize, &theFileLengthInFrames);
	if (status != noErr)
	{
		CDLOG(@"MyGetOpenALAudioData: ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) FAILED, Error = %ld\n", status);
		abort = YES;
	}
	if (abort)
		goto Exit;
	
	// Read all the data into memory
	dataSize = (UInt32) theFileLengthInFrames * theOutputFormat.mBytesPerFrame;
	theData = malloc(dataSize);
	if (theData)
	{
		AudioBufferList		theDataBuffer;
		theDataBuffer.mNumberBuffers = 1;
		theDataBuffer.mBuffers[0].mDataByteSize = dataSize;
		theDataBuffer.mBuffers[0].mNumberChannels = theOutputFormat.mChannelsPerFrame;
		theDataBuffer.mBuffers[0].mData = theData;
		
		// Read the data into an AudioBufferList
		status = ExtAudioFileRead(extRef, (UInt32*)&theFileLengthInFrames, &theDataBuffer);
		if(status == noErr)
		{
			// success
			*outDataSize = (ALsizei)dataSize;
			*outDataFormat = (theOutputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			*outSampleRate = (ALsizei)theOutputFormat.mSampleRate;
		}
		else
		{
			// failure
			free (theData);
			theData = NULL; // make sure to return NULL
			CDLOG(@"MyGetOpenALAudioData: ExtAudioFileRead FAILED, Error = %ld\n", status);
			abort = YES;
		}
	}
	if (abort)
		goto Exit;
	
Exit:
	// Dispose the ExtAudioFileRef, it is no longer needed
	if (extRef) ExtAudioFileDispose(extRef);
    if (audioFileId) AudioFileClose(audioFileId);
    
    // cleanup up audio memory
    if (audioFileMemory.data) {
        free(audioFileMemory.data);
        memset(&audioFileMemory, 0, sizeof(audioFileMemory));
    }
    
	return theData;
}

void* CDGetOpenALAudioData(CFURLRef inFileURL, ALsizei *outDataSize, ALenum *outDataFormat, ALsizei*	outSampleRate) {
	
	CFStringRef extension = CFURLCopyPathExtension(inFileURL);
	CFComparisonResult isWavFile = 0;
	if (extension != NULL) {
        
        // see if this is encrypted then drop the enc extension and get the real extension
        // file should be in form filename.xxx.enc
        if (CFStringCompare(extension, (CFStringRef)@"enc", kCFCompareCaseInsensitive) == kCFCompareEqualTo) {
            CFRelease(extension);
            CFURLRef pathWithoutEncExtension = CFURLCreateCopyDeletingPathExtension(kCFAllocatorDefault, inFileURL);
            extension = CFURLCopyPathExtension(pathWithoutEncExtension);
            CFRelease(pathWithoutEncExtension);
        }
        
		isWavFile = CFStringCompare(extension,(CFStringRef)@"wav", kCFCompareCaseInsensitive);
		CFRelease(extension);
	}	
	
	if (isWavFile == kCFCompareEqualTo) {
		return CDloadWaveAudioData(inFileURL, outDataSize, outDataFormat, outSampleRate);	
	} else {
		return CDloadCafAudioData(inFileURL, outDataSize, outDataFormat, outSampleRate);		
	}
}

