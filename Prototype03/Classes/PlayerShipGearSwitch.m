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
#import "PlayerShipGearSwitch.h"
#import "PlayerShipGear.h"
#import "PlayerShip.h"
#import "FastAnimate.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _frameCount = 7;
static const ccTime _animationDuration = 0.5f;
static const float _gearBaseVelocity = 200.0f;

//
// @implementation PlayerShipGearSwitch
//
@implementation PlayerShipGearSwitch

//
// properties
//
@synthesize _playerShipGear;
@synthesize _active;
@synthesize _colorState;
@synthesize _animateWhite;
@synthesize _animateBlack;
@synthesize _gearBaseWhite;
@synthesize _gearBaseBlack;
@synthesize _activeGearBase;

//
//
//
+ (id)playerShipGearSwitchWithPlayerShipGear:(PlayerShipGear *)playerShipGear {
    PlayerShipGearSwitch *playerShipGearSwitch = [[PlayerShipGearSwitch alloc] initWithPlayerShipGear:playerShipGear];
    return [playerShipGearSwitch autorelease];
}

//
// functions
//
- (id)initWithPlayerShipGear:(PlayerShipGear *)playerShipGear {
    self = [super initWithSpriteFrame:[SpriteFrameManager gearSwitchSpriteFrameWithColorState:kColorStateDefault frameNumber:0]];
    
    // init properties
    self._playerShipGear = playerShipGear;
    self._active = false;
    self._colorState = kColorStateDefault;
    self._animateWhite = [self createAnimationWithColorState:kColorStateWhite];
    self._animateBlack = [self createAnimationWithColorState:kColorStateBlack];
    self._gearBaseWhite = [self createGearBaseWithColorState:kColorStateWhite];
    self._gearBaseBlack = [self createGearBaseWithColorState:kColorStateBlack];
    self._activeGearBase = nil;
    
    // init super class stuff
    [self scheduleUpdate];
        
    return self;
}

//
//
//
- (FastAnimate *)createAnimationWithColorState:(ColorState)colorState {
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:_frameCount];
    int frameNumber = 0;
    
    // get frames
    for (int i=0; i < _frameCount; i++) {
        [frames addObject:[SpriteFrameManager gearSwitchSpriteFrameWithColorState:colorState frameNumber:frameNumber]];
        
        // we want to hold frame 0 and 1 for two frames instead of one,
        // so we load frame 0 into frame 0 and 1, and frame 1 into 2 and 3
        if (i == 0 || i == 2) {
            continue;
        }
        
        frameNumber++;
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:frames delay:_animationDuration / (float)_frameCount];
    return [FastAnimate actionWithAnimation:animation];
}

//
//
//
- (CCProgressTimer *)createGearBaseWithColorState:(ColorState)colorState {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:false colorState:colorState]];
    CCProgressTimer *gearBase = [CCProgressTimer progressWithSprite:sprite];
    gearBase.type = kCCProgressTimerTypeRadial;
    return gearBase;
}

//
//
//
- (FastAnimate *)animationWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _animateWhite;
        case kColorStateBlack: return _animateBlack;
        default: break;
    }
    
    return _animateWhite;
}

//
//
//
- (CCProgressTimer *)gearBaseWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _gearBaseWhite;
        case kColorStateBlack: return _gearBaseBlack;
        default: break;
    }
    
    return nil;
}

//
//
//
- (void)setPositionWithValue:(NSValue *)value {
    self.position = [value CGPointValue];
    _activeGearBase.position = [value CGPointValue];
}

//
//
//
- (void)setRotationWithNumber:(NSNumber *)number {
    _activeGearBase.rotation = [number floatValue];
}

//
//
//
- (int)activateWithColorState:(ColorState)colorState {
    
    // if already activate then bail
    if (_active) {
        return 1;
    }
    
    // overwrite so it's always white right now
    _colorState = colorState;
    
    // activate and add to scene
    _active = true;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_04] addChild:self z:ZORDER_PLAYER_SHIP_GEAR_SWITCH];
        
    // set display frame
    [self setDisplayFrame:[SpriteFrameManager gearSwitchSpriteFrameWithColorState:_colorState frameNumber:0]];
    
    // run action
    [self runAction:[self animationWithColorState:_colorState]];
    
    // sync with player gear
    self.position = _playerShipGear.position;
    self.rotation = _playerShipGear.rotation;
    
    // add gear switch base to scene and initialize him
    self._activeGearBase = [self gearBaseWithColorState:_colorState];
    [[StageLayer sharedStageLayer] addChild:_activeGearBase z:ZORDER_GEAR_SWITCH_BASE];
    _activeGearBase.percentage = 0.0f;
    _activeGearBase.position = _playerShipGear.position;
    _activeGearBase.rotation = _playerShipGear.rotation;

    return 0;
    
}

//
//
//
- (int)deactivate {
    
    // if already inactive then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    [_activeGearBase removeFromParentAndCleanup:false];
    
    // stop actions
    [self stopAllActions];
    
    // notify parent we are dead
    [_playerShipGear deactivateGearSwitch:self];
    
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    float delta = _gearBaseVelocity * elapsedTime;
    _activeGearBase.percentage += delta;
    
    if (_activeGearBase.percentage >= 100.0f) {
        [self deactivate];
    }
}

//
//
//
- (void)dealloc {
    [self deactivate];
    self._playerShipGear = nil;
    self._animateWhite = nil;
    self._animateBlack = nil;
    self._gearBaseWhite = nil;
    self._gearBaseBlack = nil;
    self._activeGearBase = nil;
    [super dealloc];
}

@end
