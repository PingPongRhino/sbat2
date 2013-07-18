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
#import "PathSpriteParticle.h"
#import "PathSpriteManager.h"
#import "PathSpriteGroup.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const float _velocity = 100.0f;

//
// @implementation PathSpriteParticle
//
@implementation PathSpriteParticle

//
// synthesize
//
@synthesize _pathSpriteManager;
@synthesize _topSprite;
@synthesize _bottomSprite;
@synthesize _pathSpriteGroup;
@synthesize _active;

//
//
//
+ (id)pathSpriteParticleWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager {
    PathSpriteParticle *pathSpriteParticle = [[PathSpriteParticle alloc] initWithPathSpriteManager:pathSpriteManager];
    return [pathSpriteParticle autorelease];
}

//
//
//
- (id)initWithPathSpriteManager:(PathSpriteManager *)pathSpriteManager {
    self = [super init];
    
    // init properties
    self._pathSpriteManager = pathSpriteManager;
    self._topSprite = [self createPathParticleSpriteFlipped:true];
    self._bottomSprite = [self createPathParticleSpriteFlipped:false];
    self._active = false;
    
    return self;
}

//
//
//
- (CCSprite *)createPathParticleSpriteFlipped:(bool)flipped {
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager pathParticleSpriteFrame]];
    sprite.anchorPoint = ccp(1.0f, 0.5f);
        
    if (flipped) {
        sprite.flipY = true;
    }
    
    return sprite;
}

//
//
//
- (int)activateWithPathSpriteGroup:(PathSpriteGroup *)pathSpriteGroup elapsedTime:(ccTime)elapsedTime {
    if (_active) {
        return 1;
    }
    
    // activate and add to scene
    _active = true;
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PATHING];
    [spriteBatchNode addChild:_topSprite z:ZORDER_PATH_SPRITE_PARTICLE];
    [spriteBatchNode addChild:_bottomSprite z:ZORDER_PATH_SPRITE_PARTICLE];
    
    // set sprite group we are moving along
    _pathSpriteGroup = pathSpriteGroup;
    
    // rotate to align with direction
    float rotation = ccpAngleSigned(_pathSpriteGroup._direction, ccp(-1.0f, 0.0f));
    rotation = CC_RADIANS_TO_DEGREES(rotation);
    _topSprite.rotation = rotation;
    _bottomSprite.rotation = rotation;
    
    // set starting position
    CGPoint startingPoint = [_pathSpriteGroup getStartingPoint];
    _topSprite.position = startingPoint;
    _bottomSprite.position = startingPoint;
    
    [self updateWithNumber:[NSNumber numberWithFloat:elapsedTime]];
    
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
    [_topSprite removeFromParentAndCleanup:false];
    [_bottomSprite removeFromParentAndCleanup:false];
    [_pathSpriteManager deactivatePathSpriteParticle:self];
    return 0;
}

//
//
//
- (void)updateWithNumber:(NSNumber *)number {
    
    if (!_active) {
        return;
    }
    
    // calc new position
    float elapsedTime = [number floatValue];
    float delta = elapsedTime * _velocity;
    CGPoint newPosition = ccpAdd(_topSprite.position, ccpMult(_pathSpriteGroup._direction, delta));
    
    // check if we should be visible or if we should be destroyed
    int result = [_pathSpriteGroup checkPoint:newPosition];
    
    // deactivate, we have gone of the end
    if (result < 0) {
        [self deactivate];
        return;
    }
    
    // set to invisible, we are in a gap
    if (result == 1) {
        _topSprite.visible = false;
        _bottomSprite.visible = false;
    }
    else {
        _topSprite.visible = true;
        _bottomSprite.visible = true;
    }
    
    // update sprites with new position
    _topSprite.position = newPosition;
    _bottomSprite.position = newPosition;
}

//
//
//
- (void)dealloc {
    self._pathSpriteManager = nil;
    self._topSprite = nil;
    self._bottomSprite = nil;
    self._pathSpriteGroup = nil;
    [super dealloc];
}

@end
