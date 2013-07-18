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
#import "MasterControlSwitch.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "UITouch+Extended.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "PlayerShip.h"
#import "LaserGrid.h"
#import "ColorStateManager.h"
#import "SimpleAudioEngine.h"

//
// static globals
//
static const float _touchHitRadius = 66.0f;
static const float _shiftDuration = 0.25f;
static NSArray *_masterControlSwitches = nil;

//
// @implementation MasterControlSwitch
//
@implementation MasterControlSwitch

//
// synthesize
//
@synthesize _active;
@synthesize _colorState;
@synthesize _touch;
@synthesize _startPosition;
@synthesize _endPosition;

//
//
//
+ (void)setSharedMasterControlSwitches:(NSArray *)masterControlSwitches {
    if (_masterControlSwitches) {
        [_masterControlSwitches release];
        _masterControlSwitches = nil;
    }
    
    _masterControlSwitches = [masterControlSwitches retain];
}

//
//
//
+ (NSArray *)sharedMasterControlSwitches {
    return _masterControlSwitches;
}

//
//
//
+ (MasterControlSwitch *)masterControlSwitchWithColorState:(ColorState)colorState {
    MasterControlSwitch *masterControlSwitch = [[MasterControlSwitch alloc] initWithColorState:colorState];
    return [masterControlSwitch autorelease];
}

//
// initialization
//
- (id)initWithColorState:(ColorState)colorState {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager masterControlSwitchSpriteFrameWithColorState:colorState];
    self = [super initWithSpriteFrame:spriteFrame];
    
    self._active = false;
    self._colorState = colorState;
    self._touch = nil;
    
    // set sprite stuff based on color
    if (_colorState == kColorStateWhite) {
        self.flipX = true;
        self.anchorPoint = ccp(0.0f, 0.5f);
        self._endPosition = ccp(0.0f, [StageLayer sharedStageLayer].contentSize.height / 2.0f);
        self._startPosition = ccp(-self.contentSize.width, _endPosition.y);
    }
    else {
        self.anchorPoint = ccp(1.0f, 0.5f);
        self._endPosition = ccp([StageLayer sharedStageLayer].contentSize.width, [StageLayer sharedStageLayer].contentSize.height / 2.0f);
        self._startPosition = ccp(_endPosition.x + self.contentSize.width, _endPosition.y);
    }
    
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
    self.position = _startPosition;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_SPAWN] addChild:self z:ZORDER_MASTER_CONTROL_SWITCH];
    
    [self stopAllActions];
    [self runAction:[CCMoveTo actionWithDuration:_shiftDuration position:_endPosition]];
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
    [self removeFromParentAndCleanup:true];
    return 0;
}

//
//
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance {
    // if not in an active state, then bail
    if (!_active) {
        return false;
    }
    
    // check if touch happened inside us, if not, then bail
    CGPoint touchCoord = [touch worldCoordinate];
    CGPoint objectCoord = [self.parent convertToWorldSpace:self.position];
    float distance = ccpDistance(touchCoord, objectCoord);
    
    // if not in our hit radius, we are done
    if (distance > _touchHitRadius) {
        return false;
    }
    
    // if we are above the min distance, then drop it
    if (distance > *minDistance) {
        return false;
    }
    
    // grab this touch
    _touch = touch;
    *minDistance = distance;    
    return true;

}

- (void)handleTouchMoved:(UITouch *)touch { }

//
//
//
- (bool)handleTouchEnded:(UITouch *)touch {
    
    // if not our touch 
    if (touch != _touch) {
        return false;
    }
    
    _touch = nil;
    
    // check if touch happened inside us, if not, then bail
    CGPoint touchCoord = [touch worldCoordinate];
    CGPoint objectCoord = [self.parent convertToWorldSpace:self.position];
    float distance = ccpDistance(touchCoord, objectCoord);
    
    // if not in our hit radius, we are done
    if (distance > _touchHitRadius) {
        return true; // we handled it, but they cancelled it, so don't switch colors
    }
    
    // see if we will be switching anyone to a different color
    ColorState oppositeColor = [ColorStateManager nextColorState:_colorState];
    if ([PlayerShip sharedPlayerShipIsColor:oppositeColor] ||
        [[LaserGrid sharedLaserGrid] laserTowerIsColorState:oppositeColor])
    {
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_REVERSE_POLARITY pitch:1.0f pan:0.0f gain:SFX_REVERSE_POLARITY_GAIN];
    }
    
    // send out notification that we were hit
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMasterControlSwitchTapped object:self];
    return true;
}

//
//
//
- (void)handleTouchCancelled:(UITouch *)touch {
    if (touch != _touch) {
        return;
    }
    _touch = nil;
}

//
// cleanup
//
- (void)dealloc {
    [self deactivate];
    self._touch = nil;
    [super dealloc];
}


@end