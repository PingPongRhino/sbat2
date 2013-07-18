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
#import <AudioToolbox/AudioToolbox.h>
#import "LaserTower.h"
#import "StageLayer.h"
#import "LaserEmitter.h"
#import "ColorStateManager.h"
#import "UITouch+Extended.h"
#import "GearSwitch.h"
#import "GearExplosionEmitter.h"
#import "StageScene.h"
#import "NSMutableSet+Extended.h"
#import "SimpleAudioEngine.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "MasterControlSwitch.h"

//
// globals
//
static unsigned int _currentLaserTowerId = 0;
static const float _radius = 22.0f;
static const float _diameter = 44.0f;
static const float _gearRotationVelocityMax = 360; // 360 degrees/second
static const float _gearRotationDeaccelerate = 135;
static const int _targetRetcialCount = 3;
static const ccTime _shakeInterval = 2.0f; // shake for 2 seconds
static const float _shakeMaxRange = 3.0f;
static const float _healthIconOffset = 22.0f + 10.0f;
static const float _healthIconRotation = CC_DEGREES_TO_RADIANS(22.5f);
static const float _touchHitRadius = 44.0f;
static const float _gearShadowOffset = 3.0f;
static const float _gearShadowDegrees = -120;

//
// @implementation LaserTower
//
@implementation LaserTower

//
// synthesize
//
@synthesize _laserTowerId;
@synthesize _body;
@synthesize _shape;
@synthesize _collisionLayer;
@synthesize _wallCollisionLayer;
@synthesize _laserEmitter;
@synthesize _direction;
@synthesize _target;
@synthesize _active;
@synthesize _colorState;
@synthesize _laserTowerState;
@synthesize _partner;
@synthesize _takingDamage;
@synthesize _health;
@synthesize _attackingEnemies;
@synthesize _healthBarIcons;
@synthesize _healthBarDirection;
@synthesize _reverseIconDirection;
@synthesize _gear;
@synthesize _gearShadow;
@synthesize _gearShadowDirection;
@synthesize _gearRotationVelocity;
@synthesize _gearRotationStopped;
@synthesize _gearExplosionEmitter;
@synthesize _shakeTimer;
@synthesize _touch;
@synthesize _gearSwitches;
@synthesize _inactiveGearSwitches;

//
// get static values
//
+ (float)radius { return _radius; }
+ (float)diameter { return _diameter; }

//
//
//
+ (id)laserTower {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager characterSpriteFrameWithCharacterType:kCharacterTypeCoco];
    LaserTower *laserTower = [[LaserTower alloc] initWithSpriteFrame:spriteFrame];
    return [laserTower autorelease];
}

//
//
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
    self = [super initWithSpriteFrame:spriteFrame];
    
    // set id
    self._laserTowerId = _currentLaserTowerId;
    _currentLaserTowerId++;
    
    // init properties
    self._body = cpBodyNew(INFINITY, INFINITY);
    self._shape = cpCircleShapeNew(_body, _radius, cpvzero);
    self._collisionLayer = 0;
    self._wallCollisionLayer = 0;
    self._laserEmitter = [LaserEmitter laserEmitter];
    self._direction = ccp(0.0f, 0.0f);
    self._active = false;
    self._colorState = kColorStateDefault;
    self._laserTowerState = kLaserTowerStateUnknown;
    self._takingDamage = false;
    self._health = 0;
    self._attackingEnemies = [NSMutableSet set];
    self._healthBarIcons = [self createHealthBarIcons];
    self._healthBarDirection = CGPointZero;
    self._reverseIconDirection = false;
    self._gear = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:false colorState:kColorStateDefault]];
    self._gearShadow = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager gearShadowSpriteFrameWithTeeth:false]];
    self._gearShadowDirection = ccpMult(ccpRotateByAngle(ccp(0.0f, 1.0f), CGPointZero, CC_DEGREES_TO_RADIANS(_gearShadowDegrees)), _gearShadowOffset);
    self._gearRotationVelocity = _gearRotationVelocityMax;
    self._gearRotationStopped = false;
    self._gearExplosionEmitter = [GearExplosionEmitter gearExplosionEmitterWithLaserTower:self];
    self._shakeTimer = 0.0f;
    self._gearSwitches = [NSMutableSet set];
    self._inactiveGearSwitches = [NSMutableSet set];
    
    // init chipmunk body
    [self setupChipmunkObjects];
    
    // init sprite stuff
    [self scheduleUpdate];
                
    return self;
}

//
//
//
- (NSMutableArray *)createHealthBarIcons {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:LASER_TOWER_MAX_HEALTH];
    for (int i=0; i < LASER_TOWER_MAX_HEALTH; i++) {
        CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager healthIconSpriteFrame]];
        [array addObject:sprite];
    }
    
    return array;
}

//
//
//
- (void)setupChipmunkObjects {
    // shape setup
    _shape->e = 0.0f;
    _shape->u = 0.0f;
    _shape->group = GROUP_LASER_TOWERS + _laserTowerId;
    _shape->collision_type = COLLISION_TYPE_LASER_TOWER;
    _shape->layers = LAYER_MASK_ALL;
    _shape->data = self;
    
    [_laserEmitter setCollisionGroup:_shape->group];
}

//
//
//
- (void)setVisible:(BOOL)visible {
    [super setVisible:visible];
    _gear.visible = visible;
    _gearShadow.visible = visible;
    
    for (GearSwitch *gearSwitch in _gearSwitches) {
        gearSwitch.visible = visible;
    }
    
    for (CCSprite *sprite in _healthBarIcons) {
        sprite.visible = visible;
    }
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _gear.position = position;
    _gearShadow.position = ccpAdd(position, _gearShadowDirection);
    
    for (GearSwitch *gearSwitch in _gearSwitches) {
        gearSwitch.position = position;
    }
}

//
//
//
- (void)setCollisionGroup:(unsigned int)collisionGroup {
    _shape->group = collisionGroup;
    [_laserEmitter setCollisionGroup:collisionGroup];
}

//
//
//
- (void)setCollisionLayerMask:(unsigned int)collisionLayerMask {
    _shape->layers = collisionLayerMask;
    [_laserEmitter setCollisionLayerMask:collisionLayerMask];
}

//
//
//
- (bool)isDead {
    if (!_active || _laserTowerState == kLaserTowerStateExploding) {
        return true;
    }
    
    return false;
}

//
//
//
- (void)addAttackingEnemy:(id<LaserTowerTargetingProtocol>)enemy {
    [enemy setTargetedTower:self];
    [_attackingEnemies addObject:enemy];
}

//
//
//
- (void)removeAttackingEnemy:(id<LaserTowerTargetingProtocol>)enemy {
    [enemy setTargetedTower:nil];
    [_attackingEnemies removeObject:enemy];    
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint withDirection:(CGPoint)direction {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // set to active
    _active = true;
    _laserTowerState = kLaserTowerStateActive;
    
    // add to scene
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_04];
    [spriteBatchNode addChild:self z:ZORDER_LASER_TOWER];
    [spriteBatchNode addChild:_gear z:ZORDER_PLAYER_GEAR];
    [spriteBatchNode addChild:_gearShadow z:ZORDER_PLAYER_GEAR_SHADOW];
    
    // set to visible
    [self setVisible:true];
    
    // set our direction
    _direction = direction;
    
    // setup body
    _body->p = spawnPoint;
    
    // add body to the space
    cpSpaceAddStaticShape([StageLayer sharedStageLayer]._space, _shape);
    
    // sync sprite to body
    self.position = _body->p;
    
    // calc emitter origin
    CGPoint origin = self.position;
    origin = ccpAdd(origin, ccpMult(_direction, _radius));
    
    // calc emitter target
    _target.x = direction.x * [StageLayer sharedStageLayer].contentSize.width;
    _target.y = direction.y * [StageLayer sharedStageLayer].contentSize.height;
    _target = ccpAdd(_target, _body->p);
    
    // set goal and activate
    [_laserEmitter activate];
    [_laserEmitter resetToPoint:origin];
    [_laserEmitter setOrigin:origin];
    [_laserEmitter setTarget:_target];
    [_laserEmitter setRandomOscillateType];
    
    // reset health
    _health = LASER_TOWER_MAX_HEALTH;
    
    // set health bar direction
    float angle = -(_healthIconRotation * floorf((float)LASER_TOWER_MAX_HEALTH / 2.0f));
    float rotateIncrement = _healthIconRotation;
    if (_reverseIconDirection) {
        angle *= -1.0f;
        rotateIncrement *= -1.0f;
    }
    
    for (CCSprite *sprite in _healthBarIcons) {
        CGPoint direction = ccpRotateByAngle(_healthBarDirection, CGPointZero, angle);
        sprite.position = ccpAdd(_body->p, ccpMult(direction, _healthIconOffset));
        angle += rotateIncrement;
        
        [spriteBatchNode addChild:sprite z:ZORDER_LASER_HEALTH_ICON];
    }
        
    // start all the gears off at a random rotation so they aren't all in sync
    _gearRotationVelocity = _gearRotationVelocityMax;
    _gearRotationStopped = false;
    _gear.rotation = arc4random() % 360;
    _gearShadow.rotation = _gear.rotation;
    
    // reset shake
    _shakeTimer = 0.0f;
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already deactivated
    if (!_active) {
        return 1;
    }
    
    // set to inactive
    _active = false;
    
    // update partners layer mask
    [_partner refreshLayerMask];
    
    // remove body from the space
    cpSpaceRemoveStaticShape([StageLayer sharedStageLayer]._space, _shape);
    
    // deactivate laser emitter
    [_laserEmitter deactivate];
            
    // deactivate health bar
    for (CCSprite *sprite in _healthBarIcons) {
        [sprite removeFromParentAndCleanup:false];
    }
    
    // deactivate gear switch
    for (GearSwitch *gearSwitch in _gearSwitches) {
        [gearSwitch deactivate];
    }
    
    // deactivate explosion emitter
    [_gearExplosionEmitter deactivate];
        
    // stop displaying and updating
    [_gear removeFromParentAndCleanup:false];
    [_gearShadow removeFromParentAndCleanup:false];
    [self removeFromParentAndCleanup:false];
    
    // post notification we deactivated
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserTowerDeactivated object:self];
    return 0;
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
- (GearSwitch *)inactiveGearSwitch {
    GearSwitch *gearSwitch = [_inactiveGearSwitches popItem];
    if (!gearSwitch) {
        gearSwitch = [GearSwitch gearSwitch];
        [_gearSwitches addObject:gearSwitch];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleGearSwitchDeactivated:)
                                                     name:kNotificationGearSwitchDeactivated
                                                   object:gearSwitch];
    }
    
    return gearSwitch;
}


//
//
//
- (void)switchToColorState:(ColorState)colorState playSFX:(bool)playSFX forceSwitch:(bool)forceSwitch {
    
    // only switch if active
    if (!_active) {
        return;
    }

    // switch our laser to new color
    // if it failed to switch, then bail and don't switch us
    if ([_laserEmitter switchToColorState:colorState forceSwitch:forceSwitch] < 0) {
        return;
    }
    
    // switch oscillate type
    [_laserEmitter setRandomOscillateType];
    
    // start the switch animation
    [[self inactiveGearSwitch] activateWithColorState:colorState];
    
    // play sound effect
    if (playSFX) {
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_REVERSE_POLARITY pitch:1.0f pan:0.0f gain:SFX_REVERSE_POLARITY_GAIN];
    }
    
    // set new color state
    _colorState = colorState;
}

//
//
//
- (void)incrementHealthByValue:(int)healthToIncrement {
    // if not active or not active state, then don't worry about it
    if (!_active || _laserTowerState != kLaserTowerStateActive) {
        return;
    }
    
    // decrement and update health
    _health += healthToIncrement;
    
    if (_health > LASER_TOWER_MAX_HEALTH) {
        _health = LASER_TOWER_MAX_HEALTH;
    }
}

//
//
//
- (void)decrementHealthByValue:(int)healthToDecrement
{
    // if not active or not active state, then don't worry about it
    if (!_active || _laserTowerState != kLaserTowerStateActive) {
        return;
    }
    
    // decrement and update health
    _health -= healthToDecrement;
    
    // display damage
    [_gearExplosionEmitter activateWithFullSequence:false];
}

//
//
//
- (void)decrementHealthByNumber:(NSNumber *)number
{
    [self decrementHealthByValue:[number intValue]];
}

//
//
//
- (void)displayDamage {
    [self updateHealthBar];
    _takingDamage = true;
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_TOWER_HIT pitch:1.0f pan:0.0f gain:SFX_TOWER_HIT_GAIN];
}

//
//
//
- (void)refreshLayerMask {
    
    // reset collision layer to just us
    unsigned int collisionLayer = _collisionLayer;
        
    // if partner is active, then we need to be colliding on his layer
    if (_partner._active) {
        collisionLayer |= _partner._collisionLayer;
    }
    // else get on the wall collision
    else {
        collisionLayer |= _wallCollisionLayer;
    }
    
    [self setCollisionLayerMask:collisionLayer];
}

//
//
//
- (void)updateHealthBar {
    
    // make them all visible
    for (CCSprite *sprite in _healthBarIcons) {
        sprite.visible = true;
    }
    
    // hide health icons to indicate damage
    int spritesToHide = LASER_TOWER_MAX_HEALTH - _health;
    int spritesHidden = 0;
    for (CCSprite *sprite in _healthBarIcons) {
        
        if (spritesHidden >= spritesToHide) {
            break;
        }
        
        sprite.visible = false;
        spritesHidden++;
    }
}

//
//
//
- (void)updateGearRotation:(ccTime)elapsedTime {
    float delta = elapsedTime * _gearRotationVelocity;
    _gear.rotation -= delta;
    _gearShadow.rotation = _gear.rotation;
    
    for (GearSwitch *gearSwitch in _gearSwitches) {
        gearSwitch.rotation = _gear.rotation;
    }
}

//
//
//
- (void)updateLaserStateActive:(ccTime)elapsedTime {
    
    // if no more health, then deactivate
    if (_health <= 0) {
        [self enterLaserStateExlpoding];
        return;
    }
    
    // update gear rotation
    [self updateGearRotation:elapsedTime];
    
    // just b/c i'm paranoid if the laser state gets tripped up, want to make sure
    // it's always there, activate is smart enough to not re-activate if already active
    [_laserEmitter activate];
    
    // update the target, this is to ensure it gets reset
    // incase the emitter changes it's internal state temporarily, for
    // instance, during a color change
    [_laserEmitter setTarget:_target];
}

//
//
//
- (void)enterLaserStateExlpoding {
    
    // set state
    _laserTowerState = kLaserTowerStateExploding;
        
    // kill the laser emitter
    [_laserEmitter stopLaserEmitter];
    
    // kill the health bar
    for (CCSprite *sprite in _healthBarIcons) {
        sprite.visible = false;
    }
    
    // post notification we are exploding
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserTowerExploding object:self];
}

//
//
//
- (void)updateLaserStateExploding:(ccTime)elapsedTime {
    
    if (!_gearRotationStopped) {
        
        // slow down gear rotation
        _gearRotationVelocity -= elapsedTime * _gearRotationDeaccelerate;
        if (_gearRotationVelocity <= 0.0f) {
            
            // we completed stopping the rotation
            _gearRotationStopped = true;
            
            // set velocity to 0.0f
            _gearRotationVelocity = 0.0f;
                    
            // activate explosion emitter here
            [_gearExplosionEmitter activateWithFullSequence:true];
        }
        
        // update rotation
        [self updateGearRotation:elapsedTime];
    }
    
    // update our explosion emitter
    [_gearExplosionEmitter update:elapsedTime];
}
//
//
//
- (void)updateShake:(ccTime)elapsedTime {
    
    // if we are alread path the interval, then bail
    if (_shakeTimer <= 0.0f) {
        return;
    }
    
    // increment timer
    _shakeTimer -= elapsedTime;
    if (_shakeTimer <= 0.0f) {
        _shakeTimer = 0.0f;
    }
    
    // calc percentage
    float percentage = _shakeTimer / _shakeInterval;
    
    // calc our range
    float distance = _shakeMaxRange * percentage;
    CGPoint shakeDelta = ccpRotateByAngle(ccp(0.0f, distance), ccp(0.0f, 0.0f), arc4random());
    self.position = ccpAdd(_body->p, shakeDelta);
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // call update for our current state
    switch (_laserTowerState) {
        case kLaserTowerStateActive:    [self updateLaserStateActive:elapsedTime]; break;
        case kLaserTowerStateExploding: [self updateLaserStateExploding:elapsedTime]; break;
        default: break;
    }
}

//
//
//
- (void)handleSoldierCollision:(Soldier *)soldier {
    [self decrementHealthByValue:LASER_TOWER_DEFAULT_DAMAGE];
    [self displayDamage];
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    self.position = _body->p;
    [_laserEmitter chipmunkUpdate:elapsedTime];
    
    // shake if taking dmage
    if (_takingDamage) {
        _shakeTimer = _shakeInterval; // start shaking!
        _takingDamage = false;
    }
    
    // update shake
    [self updateShake:[elapsedTime floatValue]];
}

//
//
//
- (void)handleGearSwitchDeactivated:(NSNotification *)notification {
    
    // switch gear color
    [_gear setDisplayFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:false colorState:_colorState]];
    
    // stick back onto inactive
    [_inactiveGearSwitches addObject:[notification object]];
    
    // send out event
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserTowerCompletedSwitchingColor object:self];
}

//
//
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance {
    
    // if not in an active state, then bail
    if (_laserTowerState != kLaserTowerStateActive) {
        return false;
    }
    
    // check if touch happened inside us, if not, then bail
    CGPoint touchCoord = [touch worldCoordinate];
    CGPoint objectCoord = [self.parent convertToWorldSpace:_body->p];
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

//
//
//
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
    CGPoint objectCoord = [self.parent convertToWorldSpace:_body->p];
    float distance = ccpDistance(touchCoord, objectCoord);
    
    // if not in our hit radius, we are done
    if (distance > _touchHitRadius) {
        return true; // we handled it, but they cancelled it, so don't switch colors
    }
    
    // toggle color
    [self switchToColorState:[ColorStateManager nextColorState:_colorState] playSFX:true forceSwitch:false];
    
    // send out notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserTowerTapped object:self];
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
//
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    self._laserEmitter = nil;
    self._attackingEnemies = nil;
    self._healthBarIcons = nil;
    self._gear = nil;
    self._gearShadow = nil;
    self._gearExplosionEmitter = nil;
    self._touch = nil;
    self._gearSwitches = nil;
    self._inactiveGearSwitches = nil;
    [super dealloc];
}

@end
