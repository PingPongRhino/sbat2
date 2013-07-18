//
//  CCLayer+Extended.m
//  Prototype01
//
//  Created by Cody Sandel on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CCLayer+Extended.h"


@implementation CCLayer (Extended)

//
//
//
- (CCSpriteBatchNode *)loadSpriteSheet:(NSString *)name {
	return [self initSpriteSheet:name];
}

//
//
//
- (CCSpriteBatchNode *)initSpriteSheet:(NSString *)name {
	
	NSString *imageName = [NSString stringWithFormat:@"%@.png", name];
	NSString *plistName = [NSString stringWithFormat:@"%@.plist", name];
	
	// create a SpriteSheet
	CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithFile:imageName];
	
	// Add sprite sheet to parent (it won't draw anything itself, but 
	// needs to be there so that it's in the rendering pipeline)
	[self addChild:batchNode];
	
	// load up the frames for the sprite sheet
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistName];
	return batchNode;
}

//
//
//
- (void)cleanupSpriteSheet:(NSString *)name {
    
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", name];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrameByName:plistName];
}

//
//
//
- (void)cleanupLayerGenericStuff {
    [self unscheduleUpdate];
    [self removeFromParentAndCleanup:true];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}

@end
