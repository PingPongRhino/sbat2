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
#import "PlayerShip.h"
#import "StageLayer.h"
#import "LaserEmitter.h"
#import "LaserCollider.h"
#import "UITouch+Extended.h"
#import "LaserGrid.h"
#import "HealthManager.h"
#import "PlayerShipGear.h"
#import "ColorStateManager.h"
#import "StageScene.h"
#import "SimpleAudioEngine.h"
#import "NSMutableSet+Extended.h"
#import "PlayerShipLaserInfo.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "MasterControlSwitch.h"


// general stuff
static unsigned int _currentPlayerId = 0;
static const float _radius = 24.0f;

// movement
static const float _maxVelocity = 500.0f;
static const float _acceleration = 1500.0f;
static const float _stoppingDistance = 0.5f * _maxVelocity * (_maxVelocity / _acceleration); // 0.5f * current velocity * time to stop

// touch stuff
static const float _touchHitRadius = 33.0f;
static const float _minTouchDisplacement = 10.0f;

// laser emitter stuff
static const ccTime _stopLaserDelay = 0.2f; // delay to stop laser after it looses connection with a stream

// for tracking global player ships
static NSArray *_playerShips = nil;


//
// @implementation PlayerShip
//
@implementation PlayerShip

//
// synthesize
//
@synthesize _playerId;
@synthesize _body;
@synthesize _controlBody;
@synthesize _shape;
@synthesize _pivot;
@synthesize _laserEmitters;
@synthesize _inactiveLaserEmitters;
@synthesize _laserEmitterDictionary;
@synthesize _mainLaserEmitter;
@synthesize _partnerShip;
@synthesize _active;
@synthesize _touch;
@synthesize _touchMoved;
@synthesize _touchDisplacement;
@synthesize _touchOffset;
@synthesize _goalPosition;
@synthesize _goalDirection;
@synthesize _colorState;
@synthesize _playerShipGear;
@synthesize _ledRed;
@synthesize _ledGreen;

//
//
//
+ (float)radius {
    return _radius;
}

//
//
//
+ (CGPoint)defaultSpawnPointForPlayerShip:(int)playerShip {
    CGPoint defaultSpawnPoint = CGPointZero;
    defaultSpawnPoint.x = (playerShip == 1) ? CGRectGetMinX([LaserGrid sharedLaserGrid]._rect) :
                                              CGRectGetMaxX([LaserGrid sharedLaserGrid]._rect);
    defaultSpawnPoint.y = [LaserGrid sharedLaserGrid]._rectCenter.y;
    return defaultSpawnPoint;
}

//
//
//
+ (void)setSharedPlayerShips:(NSArray *)playerShips {
    if (_playerShips) {
        [_playerShips release];
        _playerShips = nil;
    }
    
    _playerShips = [playerShips retain];
}

//
//
//
+ (NSArray *)sharedPlayerShips {
    return _playerShips;
}

//
//
//
+ (bool)sharedPlayerShipIsColor:(ColorState)colorState {
    for (PlayerShip *playerShip in [PlayerShip sharedPlayerShips]) {
        if (playerShip._colorState == colorState) {
            return true;
        }
    }
    
    return false;
}

//
//
//
+ (id)playerShipWithCharacterType:(CharacterType)characterType {
    PlayerShip *playerShip = [[PlayerShip alloc] initWithSpriteFrame:[SpriteFrameManager characterSpriteFrameWithCharacterType:characterType]];
    return [playerShip autorelease];
}

//
//
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
    self = [super initWithSpriteFrame:spriteFrame];
    
    // increment player id
    self._playerId = _currentPlayerId;
    _currentPlayerId++; // increment player id
    
    // init properties
    self._body = cpBodyNew(1.0f, INFINITY);
    self._controlBody = cpBodyNew(INFINITY, INFINITY);
    self._shape = cpCircleShapeNew(_body, _radius, cpvzero);
    self._pivot = cpPivotJointNew2(_controlBody, _body, cpvzero, cpvzero);
    self._partnerShip = nil;
    self._laserEmitters = [NSMutableSet set];
    self._inactiveLaserEmitters = [NSMutableSet set];
    self._laserEmitterDictionary = [NSMutableDictionary dictionary];
    self._mainLaserEmitter = nil;
    self._active = false;
    self._touch = nil;
    self._touchMoved = false;
    self._touchDisplacement = 0.0f;
    self._touchOffset = ccp(0.0f, 0.0f);
    self._goalPosition = self.position;
    self._goalDirection = ccp(0.0f, 0.0f);
    self._colorState = kColorStateDefault;
    self._playerShipGear = [PlayerShipGear playerShipGearWithPlayerShip:self];
    //self._ledRed = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"led_red.png"]];
    //self._ledGreen = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"led_green.png"]];
    
    // init sprite stuff
    [self scheduleUpdate];
    
    // init chipmunk stuff
    [self setupChipmunkObjects];
        
    return self;
}

//
//
//
- (void)setupChipmunkObjects {
    
    // setup shape
    _shape->e = 0.0f;
    _shape->u = 0.0f;
    _shape->group = GROUP_PLAYERS + _playerId;
    _shape->collision_type = COLLISION_TYPE_PLAYER;
    _shape->layers = (LAYER_MASK_ALL & ~(LAYER_MASK_OUTSIDE_INVISIBLE_WALLS | LAYER_MASK_PLAYER_LASER_COLLIDERS));
    _shape->data = self;
    
    // setup pivot
    _pivot->biasCoef = 0.0f; // disable joint correction
    _pivot->maxForce = 10000.0f; // emulate linear friction
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    
    _playerShipGear.position = position;
    _ledRed.position = position;
    _ledGreen.position = position;
    
    // send out notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerShipPositionChanged object:self];
}

//
//
//
- (void)setGoalPosition:(CGPoint)goalPosition {
    _goalPosition = goalPosition;
    _goalDirection = ccpNormalize(ccpSub(_goalPosition, self.position));
}

//
//
//
- (LaserEmitter *)inactiveLaserEmitter {
    LaserEmitter *laserEmitter = [_inactiveLaserEmitters popItem];
    if (!laserEmitter) {
        laserEmitter = [LaserEmitter laserEmitter];
        [laserEmitter setCollisionGroup:_shape->group];
        [laserEmitter setCollisionLayerMask:LAYER_MASK_PLAYER_LASER_COLLIDERS];
        [_laserEmitters addObject:laserEmitter];
    }
    
    return laserEmitter;
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint
                       target:(CGPoint)target
                  partnerShip:(PlayerShip *)partnerShip
        masterControlSwitches:(NSArray *)masterControlSwitches
{
    
    // if already activated, then don't worry about it
    if (_active) {
        return 1;
    }
    
    // set to active
    _active = true;
    
    // add to scene
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_04];
    [spriteBatchNode addChild:self z:ZORDER_PLAYER_SHIP];
    //[spriteBatchNode addChild:_ledRed z:ZORDER_PLAYER_LED_RED];
    //[spriteBatchNode addChild:_ledGreen z:ZORDER_PLAYER_LED_GREEN];
    
    // set partner ship
    self._partnerShip = partnerShip;
    
    // activate gear
    [_playerShipGear activate];
    
    // hide red led
    _ledRed.visible = false;
    _ledGreen.visible = true;
    
    // set spawn position
    _body->p = cpv(spawnPoint.x, spawnPoint.y);
    [self setPosition:spawnPoint];
    [self setGoalPosition:spawnPoint];
    
    // initialize laser
    // calc laser origin
    CGPoint origin = spawnPoint;
    CGPoint direction = ccpNormalize(ccpSub(target, origin));
    origin = ccpAdd(origin, ccpMult(direction, _radius));
    self._mainLaserEmitter = [self inactiveLaserEmitter];
    [_mainLaserEmitter setOscillateType:kOscillateTypeNormal];
    [_mainLaserEmitter resetToPoint:origin];
    _mainLaserEmitter._colorState = _colorState; // need to resync it's a random laser we pulled back out of the deck
        
    // add collision objects to space
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceAddBody(space, _body);
    cpSpaceAddShape(space, _shape);
    cpSpaceAddConstraint(space, _pivot);
    
    // register for messages from master control switches
    for (MasterControlSwitch *masterControlSwitch in masterControlSwitches) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMasterControlSwitchTapped:)
                                                     name:kNotificationMasterControlSwitchTapped
                                                   object:masterControlSwitch];
    }
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    if (!_active) {
        return 1;
    }
    
    // set to inactive
    _active = false;
    
    // remove collision objects from space
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceRemoveBody(space, _body);
    cpSpaceRemoveShape(space, _shape);
    cpSpaceRemoveConstraint(space, _pivot);
    
    // deactivate laser emitters
    [_laserEmitters makeObjectsPerformSelector:@selector(stopLaserEmitter)];
    self._mainLaserEmitter = nil;
        
    // deactivate gear
    [_playerShipGear deactivate];
        
    // stop displaying it, and deactivate
    [self removeFromParentAndCleanup:false];
    [_ledRed removeFromParentAndCleanup:false];
    [_ledGreen removeFromParentAndCleanup:false];
    
    // unregister for all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return 0;
}

//
//
//
- (PlayerShipLaserInfo *)activateLaserEmitterWithObject:(id)object colorState:(ColorState)colorState {
    
    // check if we already activated for this object
    PlayerShipLaserInfo *laserInfo = [_laserEmitterDictionary objectForKey:[NSValue valueWithPointer:object]];
    if (laserInfo) {
        
        // if laser successfully switched colors then send out event
        if ([laserInfo._activeLaserEmitter switchToColorState:colorState forceSwitch:false] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerLaserEmitterColorStateChanged object:self];
        }
        return laserInfo;
    }
    
    // figure out oscillation type
    OscillateType oscillateType = kOscillateTypeFast;
    NSSet *set = [[NSSet alloc] initWithArray:[_laserEmitterDictionary allValues]];
    for (PlayerShipLaserInfo *laserInfo in [_laserEmitterDictionary allValues]) {
        
        LaserEmitter *laserEmitter = laserInfo._activeLaserEmitter;
        OscillateType currentType = [laserEmitter oscillateType];
        
        if (currentType == kOscillateTypeFast) {
            oscillateType = kOscillateTypeSlow;
            break;
        }
        else if (currentType == kOscillateTypeSlow) {
            oscillateType = kOscillateTypeFast;
            break;
        }
    }
    [set release];
    
    // get inactive emitter and set him up
    LaserEmitter *laserEmitter = [self inactiveLaserEmitter];
    if (!laserEmitter) {
        return nil;
    }
    
    // set up laser
    [laserEmitter setOscillateType:oscillateType];
    laserEmitter._colorState = colorState;
    [laserEmitter resetToPoint:[_mainLaserEmitter origin]];
    [laserEmitter activate];
    
    // generate laser info for this guy
    laserInfo = [[PlayerShipLaserInfo alloc] init];
    laserInfo._activeLaserEmitter = laserEmitter;
    laserInfo._trackinglaserEmitter = (LaserEmitter *)object;
    
    [_laserEmitterDictionary setObject:laserInfo forKey:[NSValue valueWithPointer:laserInfo._activeLaserEmitter]];
    [_laserEmitterDictionary setObject:laserInfo forKey:[NSValue valueWithPointer:laserInfo._trackinglaserEmitter]];
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleLaserEmitterDeactivated:)
                                                 name:kNotificationLaserEmitterDeactivated
                                               object:laserEmitter];
    [laserInfo release];
    
    // send event
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerLaserEmitterColorStateChanged object:self];
    
    return laserInfo;
}

//
//
//
- (void)handleLaserEmitterDeactivated:(NSNotification *)notification {
    LaserEmitter *laserEmitter = (LaserEmitter *)[notification object];
    [_inactiveLaserEmitters addObject:laserEmitter];
    
    // get laser info object so we can clear him out
    PlayerShipLaserInfo *laserInfo = [_laserEmitterDictionary objectForKey:[NSValue valueWithPointer:laserEmitter]];
    [_laserEmitterDictionary removeObjectForKey:[NSValue valueWithPointer:laserInfo._activeLaserEmitter]];
    [_laserEmitterDictionary removeObjectForKey:[NSValue valueWithPointer:laserInfo._trackinglaserEmitter]];
    
    // send event laser emitters colors have changed
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerLaserEmitterColorStateChanged object:self];
    
    // unregister for notifications from this guy
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLaserEmitterDeactivated object:laserEmitter];
}

//
//
//
- (bool)isSwitchingColor {
    return [_playerShipGear isSwitchingColor];
}

//
//
//
- (void)switchToColorState:(ColorState)colorState playSFX:(bool)playSFX forceSwitch:(bool)forceSwitch {
    
    if (!_active) {
        return;
    }
    
    // switch our laser to new color
    // if it failed to switch, then bail and don't switch us
    if ([_mainLaserEmitter switchToColorState:colorState forceSwitch:forceSwitch] < 0) {
        return;
    }
    
    // play sound effect
    if (playSFX) {
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_REVERSE_POLARITY pitch:1.0f pan:0.0f gain:SFX_REVERSE_POLARITY_GAIN];
    }
    
    // switch gear color
    [_playerShipGear switchToColorState:colorState];
        
    // toggle leds
    _ledRed.visible = !_ledRed.visible;
    _ledGreen.visible = !_ledGreen.visible;
    
    // set our color state
    self._colorState = colorState;
    
    // send event
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayerLaserEmitterColorStateChanged object:self];
}

//
//
//
- (void)updatePosition:(ccTime)elapsedTime {
    
    cpVect direction = cpvsub(_goalPosition, _body->p);
    float length = cpvlength(direction);
    
    // if at goal or user is not controlling us, then kill velocity
    if (length <= 1.0f || _touch == nil) {
        _controlBody->v = cpvzero;
        return;
    }
    
    // assume max velocity
    float velocity = _maxVelocity;
    
    // if are with in the stopping distance, figure out our slow downed velocity
    if (length <= _stoppingDistance) {
        velocity = _maxVelocity * (length / _stoppingDistance);
    }
    
    // get our new direction and set to max velocity
    direction = cpvnormalize(direction);
    _controlBody->v = cpvmult(direction, velocity);
}

//
//
//
- (int)updateLaser {
    
    // activate laser
    [_mainLaserEmitter activate];
    
    // calc laser origin
    CGPoint origin = self.position;
    CGPoint direction = ccpNormalize(ccpSub(_partnerShip._body->p, origin));
    origin = ccpAdd(origin, ccpMult(direction, _radius));
    
    // set origin and target
    for (LaserEmitter *laserEmitter in _laserEmitters) {
        
        if (laserEmitter._active) {
            [laserEmitter setOrigin:origin];
            [laserEmitter setTarget:_partnerShip._body->p];
        }
    }
    
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // update position
    [self updatePosition:elapsedTime];
        
    // update laser
    [self updateLaser];
        
    // update gear rotation
    [_playerShipGear update:elapsedTime];
}

//
//
//
- (void)handleLaserCollision:(LaserCollider *)laserCollider {
    LaserEmitter *laserEmitter = laserCollider._laserEmitter;
    PlayerShipLaserInfo *laserInfo = [self activateLaserEmitterWithObject:laserEmitter colorState:laserEmitter._colorState];
    laserInfo._collisionCount++;
    laserInfo._timeSinceLastCollision = 0.0f;
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    // sync sprite with chipmunk body
    [self setPosition:_body->p];
    
    // figure out which guys we've lost touched with (sad really when good friends lose touch
    NSSet *set = [[NSSet alloc] initWithArray:[_laserEmitterDictionary allValues]];
    for (PlayerShipLaserInfo *laserInfo in set) {
        
        // if no collisions on this
        if (laserInfo._collisionCount <= 0) {
            
            // increment time since last collision
            laserInfo._timeSinceLastCollision += [elapsedTime floatValue];
            
            // if we haven't had a collision in a while, then stop the active laser
            if (laserInfo._timeSinceLastCollision >= _stopLaserDelay) {
                [laserInfo._activeLaserEmitter stopLaserEmitter];
            }
        }
        
        // reset collision counter
        laserInfo._collisionCount = 0;
    }
    [set release];
    
    // tell emitter to update since it isn't actually part of the space
    [_laserEmitters makeObjectsPerformSelector:@selector(chipmunkUpdate:) withObject:elapsedTime];
}

//
//
//
- (void)handleMasterControlSwitchTapped:(NSNotification *)notification {
    MasterControlSwitch *masterControlSwitch = (MasterControlSwitch *)[notification object];
    [self switchToColorState:masterControlSwitch._colorState playSFX:false forceSwitch:true];
}

//
//
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance {
            
    // check if this touch is on us
    CGPoint touchCoordinate = [touch worldCoordinate];
    CGPoint objectCoord = [self.parent convertToWorldSpace:_body->p];
    float distance = ccpDistance(touchCoordinate, objectCoord);
    
    // if the hit bounding circle didn't collide with us, then bail
    if (distance > (_radius + _touchHitRadius)) {
        return false;
    }
    
    // handle only if this is below the minDistance
    if (distance >= *minDistance) {
        return false;
    }
        
    // else we will handle this touch
    _touch = touch;
    _touchOffset = ccpSub(objectCoord, touchCoordinate);
    _touchMoved = false;
    _touchDisplacement = 0.0f;
        
    // set new min distance to beat
    *minDistance = distance;
    return true;
}

//
//
//
- (void)handleTouchMoved:(UITouch *)touch {
    
    // if this isn't our touch, then bail
    if (_touch != touch)
        return;
    
    // get touch coordinate
    CGPoint touchPosition = [touch worldCoordinate];
    CGPoint touchPreviousPosition = [touch previousWorldCoordinate];
            
    // calc new goal position by figuring out our offset from the touch
    CGPoint goalPosition = ccpAdd(touchPosition, _touchOffset);
    
    // we are tracking this touch, so update the position
    goalPosition = [self.parent convertToNodeSpace:goalPosition];
    [self setGoalPosition:goalPosition];
    
    // set that touch moved and calc displacement
    _touchMoved = true;
    _touchDisplacement += ccpDistance(touchPosition, touchPreviousPosition);
}

//
//
//
- (bool)handleTouchEnded:(UITouch *)touch {
    
    // if this isn't our touch, then bail
    if (_touch != touch) {
        return false;
    }
    
    // if this was a tap
    if (touch.tapCount > 0) {
        
        // if this tap moved, lets really make sure it's a tap and the displacement
        // isn't that large
        if (_touchMoved) {
            
            // if the total displacment isn't that much, then i suppose it's actually a tap
            // and not a drag
            _touchDisplacement += ccpDistance([touch worldCoordinate], [touch previousWorldCoordinate]);
            if (_touchDisplacement <= _minTouchDisplacement) {
                [self switchToColorState:[ColorStateManager nextColorState:_colorState] playSFX:true forceSwitch:false];
            }
        }
        else {
            [self switchToColorState:[ColorStateManager nextColorState:_colorState] playSFX:true forceSwitch:false];
        }
    }
    
    // reset the touch
    _touch = nil;
    return true;
}

//
//
//
- (void)handleTouchCancelled:(UITouch *)touch {
    
    // if this isn't our touch, then bail
    if (_touch != touch) {
        return;
    }
    
    // reset the touch
    _touch  = nil;
}

//
//
//
- (void)dealloc {
    
    // deactivate if not already
    [self deactivate];
    
    // clean up body
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    // clean up control body
    if (_controlBody) {
        cpBodyFree(_controlBody);
        _controlBody = NULL;
    }
    
    // clean up shape
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    // cleanup constraint
    if (_pivot) {
        cpConstraintFree(_pivot);
        _pivot = NULL;
    }
    
    self._laserEmitters = nil;
    self._inactiveLaserEmitters = nil;
    self._laserEmitterDictionary = nil;
    self._mainLaserEmitter = nil;
    self._partnerShip = nil;
    self._touch = nil;
    self._playerShipGear= nil;
    self._ledRed = nil;
    self._ledGreen = nil;
    
    [super dealloc];
}


@end
