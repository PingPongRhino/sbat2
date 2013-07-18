/* Copyright (c) 2011 Cody Sandel
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

//
// includes
//
#import "StageScene.h"
#import "StageLayer.h"
#import "MainMenuLayer.h"
#import "BGSoundManager.h"
#import "CCEncryptedTextureCache.h"
#import "NSDictionary+Extended.h"
#import "CryptUtils.h"

//
// static globals
//
static StageScene *_sharedStageScene = nil;
static const int _spriteSheetCount = 2;
static const int _spriteSheetBatchNodeCount[] = { SPRITEBATCHNODE00_COUNT, SPRITEBATCHNODE01_COUNT };

//
// StageScene
//
@implementation StageScene

//
// synthesize
//
@synthesize _scene;
@synthesize _active;
@synthesize _spriteBatchNodeList;

//
//
//
+ (StageScene *)createSharedStageScene {
    [StageScene destroySharedStageScene];
    _sharedStageScene = [[StageScene alloc] init];
    [_sharedStageScene activate];
    return _sharedStageScene;
}

//
//
//
+ (StageScene *)sharedStageScene { return _sharedStageScene; }

//
//
//
+ (void)destroySharedStageScene {
    [_sharedStageScene release];
    _sharedStageScene = nil;
}


//
// desc: init
//
- (id)init {
    
    // init
    self = [super init];
    
    // init variables
    self._scene = [CCScene node];
    self._spriteBatchNodeList = [self createSpriteBatchNodes];

#if TARGET_IPAD
    [_scene setScale:2];
    [_scene setAnchorPoint:CGPointZero];
    [_scene setPosition:CC_WORLD_OFFSET()];
#endif
            
    // return self
    return self;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    _active = true;
    
    // create the shared stage layer and activate it
    [StageLayer createSharedStageLayer];
    [[StageLayer sharedStageLayer] activate];
    
    // start with the main menu as the active layer
    [MainMenuLayer createSharedMainMenuLayer];
    [[MainMenuLayer sharedMainMenuLayer] activateWithMenuScreen:kMenuScreenMain];
        
    // init bg sound manager
    [BGSoundManager createSharedBGSoundManager];
    [[BGSoundManager sharedBGSoundManager] activate];
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    _active = false;
    [StageLayer destroySharedStageLayer];
    [MainMenuLayer destroyMainMenuLayer];
    [BGSoundManager destroySharedBGSoundManager];
    return 0;
}

//
//
//
- (void)createSpriteSheets {
    
    // load up the frames for the sprite sheet
    for (int i=0; i < _spriteSheetCount; i++) {
        
        // fetch texture
        NSString *textureName = [NSString stringWithFormat:@"spritesheet%02d.png.enc", i];
        CCTexture2D *texture = [[CCEncryptedTextureCache sharedTextureCache] addImage:textureName];
        if (!texture) {
            continue;
        }
        
        // get spritesheet and decode it
        NSString *plistName = [NSString stringWithFormat:@"spritesheet%02d.plist.enc", i];
        NSString *path = [CCFileUtils fullPathFromRelativePath:plistName];
        NSData *encData = [NSData dataWithContentsOfFile:path];
        
        if (!encData) {
            NSLog(@"Failed to load %@, could not find file.", plistName);
            continue;
        }
        
        unsigned char *decryptedData = NULL;
        int length = CCDecryptMemory((unsigned char *)[encData bytes], [encData length], &decryptedData);
        if (!decryptedData) {
            NSLog(@"Failed to load %@, failed to decrypt.", plistName);
            continue;
        }
        
        // stick in nsdata and cleanup memory
        NSData *plistData = [NSData dataWithBytes:decryptedData length:length];
        free(decryptedData);
        decryptedData = NULL;
        
        // generate dictionary from plist data
        NSDictionary *dict = [NSDictionary dictionaryWithData:plistData];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithDictionary:dict texture:texture];
    }
}

//
//
//
- (NSMutableArray *)createSpriteBatchNodes {
    
    // add frame info to frame cache
    [self createSpriteSheets];
    
    // no generate the batch nodes
    NSMutableArray *spriteBatchNodeList = [NSMutableArray array];
    for (int i=0; i < _spriteSheetCount; i++) {
        NSString *spriteSheetName = [NSString stringWithFormat:@"spritesheet%02d.png.enc", i];
        CCTexture2D *spriteSheet = [[CCEncryptedTextureCache sharedTextureCache] addImage:spriteSheetName];
        
        // load up sprite batch nodes for spritsheet00.png
        for (int x=0; x < _spriteSheetBatchNodeCount[i]; x++) {
            CCSpriteBatchNode *spriteBatchNode = [CCSpriteBatchNode batchNodeWithTexture:spriteSheet];
            [spriteBatchNodeList addObject:spriteBatchNode];
        }
    }
    
    return spriteBatchNodeList;
}

//
//
//
- (CCSpriteBatchNode *)spriteBatchNodeWithIndex:(int)index {
    return [_spriteBatchNodeList objectAtIndex:index];
}

//
//
//
- (void)destroySpriteSheets {
    for (int i=0; i < _spriteSheetCount; i++) {
        NSString *plistName = [NSString stringWithFormat:@"spritesheet%02d.plist.enc", i];
        [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:plistName];
    }    
}

//
// desc: dealloc
//
- (void)dealloc {
    
    // make sure to deactivate
    [self deactivate];
    
    // cleanup sprite sheets and what not
    [self destroySpriteSheets];
    
    // purge our encrypted texture cache
    [CCEncryptedTextureCache purgeSharedTextureCache];
    
    // cleanup properties
    self._scene = nil;
    self._spriteBatchNodeList = nil;
    [super dealloc];
}

@end
