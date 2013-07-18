//
//  CCEncryptedTextureCache.m
//

#import "CCEncryptedTextureCache.h"
#include "CryptUtils.h"

@implementation CCEncryptedTextureCache

-(CCTexture2D*) addImage:(NSString*)path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");
	
	CCTexture2D * tex = nil;
	
	// MUTEX:
	// Needed since addImageAsync calls this method from a different thread
	[dictLock_ lock];
    
    // remove possible -HD suffix to prevent caching the same image twice (issue #1040)
	path = ccRemoveHDSuffixFromFile( path );
	
	tex=[textures_ objectForKey: path];
	
	if (!tex) {
		// see if this is encrypted file
		if ([[path pathExtension] isEqualToString:@"enc"]) {
            
            // prevents overloading the autorelease pool
			NSString *fullpath = [CCFileUtils fullPathFromRelativePath:path];
            
			NSData *encData = [NSData dataWithContentsOfFile:fullpath];
            unsigned char *decryptedData = NULL;
			int length = CCDecryptMemory((unsigned char *)[encData bytes], [encData length], &decryptedData);
            if (!decryptedData) {
                [dictLock_ unlock];
                CCLOG(@"cocos2d: Failed to decrypt image:%@ in CCEncryptedTextureCache", path);
                return nil;
            }
            
            // stick into a NSData and cleanup up buffer
            NSData *imageData = [NSData dataWithBytes:decryptedData length:length];
            free(decryptedData);
            decryptedData = NULL;
			
            // now create a texture from mem
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            tex = [ [CCTexture2D alloc] initWithImage: image ];
            [image release];
    
            if( tex )
                [textures_ setObject: tex forKey:path];
            else
                CCLOG(@"cocos2d: Couldn't add image:%@ in CCEncryptedTextureCache", path);
    
            [tex release];
		} 
		else
		{
			[dictLock_ unlock];
			return [super addImage:path];
		}
	}//if !tex
	
	[dictLock_ unlock];

	return tex;
}

@end
