//
//  CCLayer+Extended.h
//  Prototype01
//
//  Created by Cody Sandel on 9/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface CCLayer (Extended)

//
//
//
- (CCSpriteBatchNode *)loadSpriteSheet:(NSString *)name;

//
//
//
- (CCSpriteBatchNode *)initSpriteSheet:(NSString *)name;

//
//
//
- (void)cleanupSpriteSheet:(NSString *)name;

//
//
//
- (void)cleanupLayerGenericStuff;

@end
