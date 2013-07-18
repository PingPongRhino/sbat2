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
#import "PlayerShipGear.h"
#import "PlayerShip.h"
#import "PlayerShipGearSwitch.h"
#import "NSMutableSet+Extended.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"
#import "NotificationStrings.h"

//
// static globals
//
static const float _rotationVelocity = 360.0f;
static const float _gearShadowOffset = 3.0f;
static const float _gearShadowDegrees = -120.0f;

//
// @implementation PlayerShipGear
//
@implementation PlayerShipGear

//
// synthesize
//
@synthesize _playerShip;
@synthesize _shadow;
@synthesize _shadowDirection;
@synthesize _active;
@synthesize _colorState;
@synthesize _gearSwitches;
@synthesize _inactiveGearSwitches;

//
//
//
+ (id)playerShipGearWithPlayerShip:(PlayerShip *)playerShip {
    PlayerShipGear *playerShipGear = [[PlayerShipGear alloc] initWithPlayerShip:playerShip];
    return [playerShipGear autorelease];
}

//
//
//
- (id)initWithPlayerShip:(PlayerShip *)playerShip {
    self = [super initWithSpriteFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:true colorState:kColorStateDefault]];
    
    // init properties
    self._playerShip = playerShip;
    self._shadow = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager gearShadowSpriteFrameWithTeeth:true]];
    self._shadowDirection = ccpMult(ccpRotateByAngle(ccp(0.0f, 1.0f), CGPointZero, CC_DEGREES_TO_RADIANS(_gearShadowDegrees)), _gearShadowOffset);
    self._active = false;
    self._colorState = kColorStateDefault;
    self._gearSwitches = [NSMutableSet set];
    self._inactiveGearSwitches = [NSMutableSet set];
    
    return self;
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _shadow.position = ccpAdd(position, _shadowDirection);
    [_gearSwitches makeObjectsPerformSelector:@selector(setPositionWithValue:) withObject:[NSValue valueWithCGPoint:position]];
}

//
//
//
- (void)setRotation:(float)rotation {
    [super setRotation:rotation];
    _shadow.rotation = rotation;
    [_gearSwitches makeObjectsPerformSelector:@selector(setRotationWithNumber:) withObject:[NSNumber numberWithFloat:rotation]];
}

//
//
//
- (int)activate {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // set to active and add to the scene
    _active = true;
    
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_04];
    [spriteBatchNode addChild:self z:ZORDER_PLAYER_GEAR];
    [spriteBatchNode addChild:_shadow z:ZORDER_PLAYER_GEAR_SHADOW];
    
    // give random starting rotation so it's not in sync with the other guys
    self.rotation = arc4random() % 360;
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already inactive, then bail
    if (!_active) {
        return 1;
    }
    
    // set to inactive and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    [_shadow removeFromParentAndCleanup:false];
    
    // tell gear switch stuff to deactivate
    [_gearSwitches makeObjectsPerformSelector:@selector(deactivate)];
    return 0;
}

//
//
//
- (PlayerShipGearSwitch *)inactivePlayerShipGearSwitch {
    PlayerShipGearSwitch *gearSwitch = [_inactiveGearSwitches popItem];
    if (!gearSwitch) {
        gearSwitch = [PlayerShipGearSwitch playerShipGearSwitchWithPlayerShipGear:self];
        [_gearSwitches addObject:gearSwitch];
    }
    return gearSwitch;
}

//
//
//
- (void)deactivateGearSwitch:(PlayerShipGearSwitch *)gearSwitch {
    
    // switch to new color since the switch animation  completed
    [self setDisplayFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:true colorState:_colorState]];
    
    // set this gear switch back into inactive list
    [_inactiveGearSwitches addObject:gearSwitch];
    
    // send out notification that we completed a color switch
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerShipCompletedSwitchingColor object:_playerShip];
}

//
//
//
- (bool)isSwitchingColor {
    if ([_inactiveGearSwitches count] == [_gearSwitches count]) {
        return false;
    }
    
    return true;
}

//
//
//
- (void)switchToColorState:(ColorState)colorState {
    
    // run switch animation to kill the old color
    PlayerShipGearSwitch *gearSwitch = [self inactivePlayerShipGearSwitch];
    [gearSwitch activateWithColorState:colorState];
    
    // set new color state
    _colorState = colorState;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if not active, then bail
    if (!_active) {
        return;
    }
    
    // calculate rotation delta
    float delta = _rotationVelocity * elapsedTime;
    
    // update our rotation
    self.rotation -= delta;
}

//
//
//
- (void)dealloc {
    [self deactivate];
    self._playerShip = nil;
    self._shadow = nil;
    self._gearSwitches = nil;
    self._inactiveGearSwitches = nil;
    [super dealloc];
}



@end
