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
#import "SoldierFactory.h"
#import "StageLayer.h"
#import "EnemyManager.h"
#import "LaserGrid.h"
#import "Soldier.h"
#import "HealthManager.h"
#import "LaserCollider.h"
#import "LaserEmitter.h"
#import "LaserTower.h"
#import "PathSegment.h"
#import "BarrierManager.h"
#import "StageScene.h"
#import "SFSpawn.h"
#import "PathSpriteManager.h"
#import "SFExplosion.h"
#import "SFAttackManager.h"
#import "EnemyDrop.h"
#import "EnemyDropManager.h"
#import "SimpleAudioEngine.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "NSArray+Extended.h"
#import "ColorStateManager.h"
#import "SimpleAudioEngine.h"

//
// globals
//
static unsigned int _currentSoldierFactoryId = 0;
static const float _radius = 22.0f;
static const float _diameter = 44.0f;
static const float _maxRotationVelocity = 180.0f;
static const float _rotationAcceleration = 180.0f;
static const ccTime _spinUpInterval = 1.0f;
static const float _shakeDistance = 2.0f;

//
// @implementation SoldierFactory
//
@implementation SoldierFactory

//
// synthesize
//
@synthesize _soldierFactoryId;
@synthesize _body;
@synthesize _shape;
@synthesize _soldierCollisionCount;
@synthesize _active;
@synthesize _chipmunkActive;
@synthesize _colorState;
@synthesize _state;
@synthesize _aliveState;
@synthesize _enemyType;
@synthesize _collisionGroup;
@synthesize _pathSprites;
@synthesize _pathSegments;
@synthesize _targetedTower;
@synthesize _direction;
@synthesize _healthManager;
@synthesize _healthBar;
@synthesize _gearSprite;
@synthesize _timer;
@synthesize _stateQueuedInterval;
@synthesize _aliveStateRestingInterval;
@synthesize _aliveStateSpawningInterval;
@synthesize _rotationVelocity;
@synthesize _spawnCounter;
@synthesize _spawnMaxCount;
@synthesize _barrierManager;
@synthesize _sfSpawn;
@synthesize _sfExplosion;
@synthesize _sfAttackManager;

//
//
//
+ (id)soldierFactory {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager soldierFactorySpriteFrameWithColorState:kColorStateDefault];
    SoldierFactory *soldierFactory = [[SoldierFactory alloc] initWithSpriteFrame:spriteFrame];
    return [soldierFactory autorelease];
}

//
// getters for static variables
//
+ (float)radius { return _radius; }
+ (float)diameter { return _diameter; }
+ (float)spawnSpacing { return _diameter + 10.0f; }
+ (float)spawnSpacingWithBarrier { return [SoldierFactory spawnSpacing] + 10.0f; }

//
//
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
    self = [super initWithSpriteFrame:spriteFrame];
    
    // init id
    self._soldierFactoryId = _currentSoldierFactoryId;
    _currentSoldierFactoryId++;
        
    // init chipmunk stuff
    self._body = cpBodyNew(INFINITY, INFINITY);
    self._shape = cpCircleShapeNew(_body, _radius, cpvzero);
    self._soldierCollisionCount = 0;
    
    // init state stuff
    self._active = false;
    self._chipmunkActive = false;
    self._colorState = kColorStateDefault;
    self._state = kSFStateUnknown;
    self._aliveState = kSFAliveStateUnknown;
    self._enemyType = kEnemyTypeSoldierFactory;
    self._collisionGroup = GROUP_SOLDIER_FACTORIES + _soldierFactoryId;
    
    // init pathing stuff
    self._pathSprites = [NSMutableArray array];
    self._pathSegments = [NSMutableArray array];
    self._targetedTower = nil;
    self._direction = ccp(0.0f, 0.0f);
    
    // init health stuff
    self._healthManager = [HealthManager healthManagerWithMaxHealth:100 damageVelocity:50.0f];
    self._healthBar = [self createHealthBar];
    
    // init gear stuff
    self._gearSprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager soldierFactoryGearSpriteFrameWithColorState:kColorStateDefault]];
    
    // init timers
    self._timer = 0.0f;
    self._stateQueuedInterval = 0.0f;
    self._aliveStateRestingInterval = 0.0;
    self._aliveStateSpawningInterval = 0.0f;
    
    // init rotation stuff
    self._rotationVelocity = 0.0f;
    
    // init spawn stuff
    self._spawnCounter = 0;
    self._spawnMaxCount = 0;
        
    // init barrier stuff
    self._barrierManager = [BarrierManager barrierManagerWithSoldierFactory:self];
    
    // init spawn stuff
    self._sfSpawn = [SFSpawn sfSpawnWithSoldierFactory:self];
    
    // init explosion stuff
    self._sfExplosion = [SFExplosion sfExplosionWithSoldierFactory:self];
    
    // init attack stuff
    //self._sfAttackManager = [SFAttackManager sfAttackManagerWithSoldierFactory:self];
        
    // setup sprite stuff
    [self scheduleUpdate];
    
    // init chipmunk objects
    [self setupChipmunkObjects];

    return self;
}

//
//
//
- (CCProgressTimer *)createHealthBar {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager soldierFactoryHealthBarSpriteFrameWithColorState:kColorStateDefault];
    CCProgressTimer *progressTimer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrame:spriteFrame]];
    progressTimer.type = kCCProgressTimerTypeRadial;
    progressTimer.percentage = 0.0f;
    return progressTimer;
}

//
//
//
- (void)setupChipmunkObjects {
    
    _shape->sensor = true;
    _shape->group = _collisionGroup;
    _shape->collision_type = COLLISION_TYPE_SOLDIER_FACTORY;
    _shape->layers = LAYER_MASK_SOLDIERS | LAYER_MASK_PLAYER_LASER_COLLIDERS;
    _shape->data = self;
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _gearSprite.position = position;
    _healthBar.position = position;
}

//
//
//
- (CGPoint)bodyPosition { return _body->p; }
- (NSMutableArray *)pathSprites { return _pathSprites; }
- (NSMutableArray *)pathSegments { return _pathSegments; }
- (LaserTower *)targetedTower { return _targetedTower; }
- (void)setTargetedTower:(LaserTower *)targetedTower { _targetedTower = targetedTower; }

//
//
//
- (float)calcDistanceFromPathSegmentArray:(NSArray *)pathSegmentArray {
    
    float distance = 0.0f;
    for (PathSegment *pathSegment in pathSegmentArray) {
        distance += ccpDistance(pathSegment._start, pathSegment._end);
    }
    
    return distance;
}

//
//
//
- (void)recalcTargetedTowerAndPath {
    
    // get our way path to target from here
    [[LaserGrid sharedLaserGrid] calcPathForLaserTowerTargetingObject:self];
    
    // if not tower to target
    if (_targetedTower == nil) {
        return;
    }
        
    // figure out which direction we need to spawn soldiers
    PathSegment *pathSegment = [_pathSegments firstObject];
    _direction = ccpNormalize(ccpSub(pathSegment._end, pathSegment._start));
        
    // recalc barrier positions
    [_barrierManager calcGoalRotation];
    
    // activate path for us
    [[PathSpriteManager sharedPathSpriteManager] activatePathSpritesWithPathSpriteOwner:self];    
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint {
    
    // if already active then bail
    if (_active)
        return 1;
    
    // set to active
    _active = true;
    
    // add to scene
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_03];
    [spriteBatchNode addChild:self z:ZORDER_SF_BASE];
    [spriteBatchNode addChild:_gearSprite z:ZORDER_SF_GEAR];
    [[StageLayer sharedStageLayer] addChild:_healthBar z:ZORDER_SF_HEALTH_BAR];
    
    // see if we are paused
    if ([StageLayer sharedStageLayer]._paused) {
        [self pauseSchedulerAndActions];
        [_gearSprite pauseSchedulerAndActions];
        [_healthBar pauseSchedulerAndActions];
    }
    
    // set spawn point
    _body->p = cpv(spawnPoint.x, spawnPoint.y);
    
    // set state to spawning
    [self setStateToQueued];
    
    // register for laser tower deactivate notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerDeactivated:)
                                                 name:kNotificationLaserTowerDeactivated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerDeactivated:)
                                                 name:kNotificationLaserTowerExploding
                                               object:nil];
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already not active, then bail
    if (!_active)
        return 1;
    
    // set to inactive
    _active = false;
    
    // unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // set to dead
    [self setStateToDead];
        
    // deactivate barrier
    [_barrierManager deactivate];
        
    // reset pathing
    [[LaserGrid sharedLaserGrid] deactivateLaserTowerTargetingObject:self];
    
    // shrink our paths and let go of them
    [[PathSpriteManager sharedPathSpriteManager] deactivatePathSpritesForPathSpriteOwner:self];
    [_pathSprites removeAllObjects];
    
    // deactivate spawn
    [_sfSpawn deactivate];
    
    // deactivate explosion
    [_sfExplosion deactivate];
    
    // deactivate attack stuff
    [_sfAttackManager deactivate];
 
    // remove from scene
    [_healthBar removeFromParentAndCleanup:false];
    [_gearSprite removeFromParentAndCleanup:false];
    [self removeFromParentAndCleanup:false];
    
    // send out event
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSoldierFactoryDeactivated object:self];
    return 0;
}

//
//
//
- (int)activateChipmunkObjects {
    if (_chipmunkActive) {
        return 1;
    }
    
    _chipmunkActive = true;
    _soldierCollisionCount = 0;
    cpSpaceAddStaticShape([StageLayer sharedStageLayer]._space, _shape);
    return 0;
}

//
//
//
- (int)deactivateChipmunkObjects {
    if (!_chipmunkActive) {
        return 1;
    }
    
    _chipmunkActive = false;
    cpSpaceRemoveStaticShape([StageLayer sharedStageLayer]._space, _shape);
    return 0;
}

//
//
//
- (void)setVisibility:(bool)visible {
    self.visible = visible;
    _gearSprite.visible = visible;
    _healthBar.visible = visible;
}

//
//
//
- (void)explode {
    [self setStateToExplodingWithAttackType:false];
}

//
//
//
- (void)attack {
    [self setStateToExplodingWithAttackType:true];
}

//
//
//
- (int)setStateToQueued {
    [self setVisibility:false];
    _timer = 0.0f;
    _state = kSFStateQueued;
    return 0;
}

//
//
//
- (int)setStateToSpawning {
    self.visible = false;
    [_sfSpawn activate];
    _state = kSFStateSpawning;
    return 0;
}

//
//
//
- (int)setStateToAlive {
    
    // set these guys to visible
    [self setVisibility:true];
    
    // active chipmunk body
    [self activateChipmunkObjects];
    
    // sync body with sprite
    self.position = _body->p;
    
    // set gear stuff
    _gearSprite.rotation = _sfSpawn._gearSprite.rotation;
    
    // reset any state tracking stuff
    [self setAliveStateToResting];
    
    // if barrier type, then activate barriers
    if (_enemyType == kEnemyTypeBarrierFactory) {
        CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_03];
        [_barrierManager activateWithSpriteBatchNode:spriteBatchNode chipmunkEnabled:true];
    }
    
    // calc targeted tower and path
    [self recalcTargetedTowerAndPath];
        
    // reset rotation velocity
    _rotationVelocity = 0.0f;
    
    // reset spawn counter
    _spawnCounter = 0;
    
    // reset health
    [_healthManager reset];
    
    // init health bar
    _healthBar.percentage = [_healthManager getPercentage];
    
    // update state
    _state = kSFStateAlive;
    return 0;
}

//
//
//
- (int)setAliveStateToResting {
    _timer = 0.0f; // reset timer
    _aliveState = kSFAliveStateResting; // go back to resting state
    return 0;
}

//
//
//
- (int)setStateToExplodingWithAttackType:(bool)attackType {
    
    // if not active or alive, then bail
    if (!_active || _state != kSoldierStateAlive) {
        return 1;
    }
    
    // reset position cause we are probably shaking and offseted
    self.position = _body->p;
    
    // tell exlposion to do it's thang
    _state = kSFStateExlpoding;
    
    if (attackType) {
        [_sfAttackManager activate];
    }
    else {
        [_sfExplosion activate];
        
        // do enemy drop
        EnemyDrop *enemyDrop = [[EnemyDropManager sharedEnemyDropManager] generateEnemyDrop];
        [enemyDrop activateWithSpawnPoint:_body->p];
        
        // play death sound
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_FACTORY_DEATH pitch:1.0f pan:0.0f gain:SFX_FACTORY_DEATH_GAIN];
    }
    
    // kill the health bar
    _healthBar.visible = false;
    
    // deactivate barriers
    [_barrierManager explode];
    
    // kill collisions
    [self deactivateChipmunkObjects];
    return 0;
}

//
//
//
- (int)setStateToDead {
    
    // set new state
    SFState prevState = _state;
    _state = kSFStateDead;
    
    // remove chipmunk bodies
    [self deactivateChipmunkObjects];
    
    // if we aren't coming from an exploding state, then we don't
    // need to do any of the following
    if (prevState != kSFStateExlpoding) {
        return 0;
    }
    
    // if health is zero, count towards score and bomb
    if (_healthManager._health <= 0) {
        // send out event
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSoldierFactoryKilledByPlayer object:self];
    }
        
    return 0;
}

//
//
//
- (void)switchToColorState:(ColorState)colorState {
    _colorState = colorState;
    
    // set display frames
    [self setDisplayFrame:[SpriteFrameManager soldierFactorySpriteFrameWithColorState:_colorState]];
    [_gearSprite setDisplayFrame:[SpriteFrameManager soldierFactoryGearSpriteFrameWithColorState:_colorState]];
    [_healthBar.sprite setDisplayFrame:[SpriteFrameManager soldierFactoryHealthBarSpriteFrameWithColorState:_colorState]];
    
    // since the CCProgressTimer won't update texture vertex info
    // unless the percentage change, we fake it out instead by changing
    // the percentage on it
    _healthBar.percentage = -1.0f;
    _healthBar.percentage = [_healthManager getPercentage];
    
    // update barriers if we are a barrier type
    if (_enemyType == kEnemyTypeBarrierFactory) {
        [_barrierManager switchToColorState:[ColorStateManager nextColorState:_colorState]];
    }    
}

//
//
//
- (void)switchToColorStateWithNumber:(NSNumber *)colorStateNumber {
    [self switchToColorState:[colorStateNumber intValue]];
}

//
//
//
- (int)updateStateQueued:(ccTime)elapsedTime {
        
    _timer += elapsedTime;
    if (_timer >= _stateQueuedInterval) {
        [self setStateToSpawning];
        return 2;
    }
    
    return 0;
}

//
//
//
- (int)updateStateAlive:(ccTime)elapsedTime {
    
    // update health
    if ([_healthManager updateHealth:elapsedTime] <= 0) {
        [self explode]; // no more health, then blow da fuck up
        return 2;
    }
    
    // update health bar
    _healthBar.percentage = [_healthManager getPercentage];
    
    // update based on our state
    switch (_aliveState) {
        case kSFAliveStateResting:         [self updateActiveStateResting:elapsedTime]; break;
        case kSFAliveStateSoldierSpawning: [self updateActiveStateSoldierSpawning:elapsedTime]; break;
        default: break;
    }
    
    // update rotation
    if (_rotationVelocity > 0.0f) {
        float delta = elapsedTime * _rotationVelocity;
        _gearSprite.rotation -= delta;
    }
    
    // update barrier manager
    [_barrierManager update:elapsedTime];
    
    return 0;
}

//
//
//
- (int)updateSpin:(ccTime)elapsedTime {
    
    float difference = _aliveStateRestingInterval - _timer;
    
    // if we are within a second, then start spinning up
    if (difference <= 1.0f) {
        float delta = elapsedTime * _rotationAcceleration;
        _rotationVelocity += delta;
        if (_rotationVelocity >= _maxRotationVelocity) {
            _rotationVelocity = _maxRotationVelocity;
        }
        
        return 1;
    }
    
    // spin down
    if (_rotationVelocity > 0.0f) {
        float delta = elapsedTime * _rotationAcceleration;
        _rotationVelocity -= delta;
        if (_rotationVelocity <= 0.0f) {
            _rotationVelocity = 0.0f;
        }
    }
    
    return 0;
}

//
//
//
- (int)updateActiveStateResting:(ccTime)elapsedTime {
    
    // we are still resting, so do nothing
    _timer += elapsedTime;
    if (_timer < _aliveStateRestingInterval) {
        [self updateSpin:elapsedTime];        
        return 1;
    }
    
    // set our rotatoin velocity to max
    _rotationVelocity = _maxRotationVelocity;
    
    // reset timer, set it to soldier spawn interval so we
    // spawn the first soldier immediately
    _timer = _aliveStateSpawningInterval;
    
    // got to next state
    _aliveState = kSFAliveStateSoldierSpawning;
    return 0;
}

//
//
//
- (int)updateActiveStateSoldierSpawning:(ccTime)elapsedTime {
    
    // if no more targeted towers then bail
    if (!_targetedTower) {
        return -1;
    }
    
    // update timer
    _timer += elapsedTime;
    
    // if we haven't hit the interval, then bail
    if (_timer < _aliveStateSpawningInterval) {
        return 1;
    }
    
    // if there is currently a soldier in the way, then hold off on spawning the next one
    if (_soldierCollisionCount > 0) {
        return 2;
    }
        
    // spawn soldier
    if (![[EnemyManager sharedEnemyManager] spawnSoldierWithSpawnPoint:_body->p
                                                            colorState:_colorState
                                                      pathSegmentArray:_pathSegments
                                                         targetedTower:_targetedTower
                                                    skipSpawnAnimation:true])
    {
        return 3; // failed to spawn soldier, we will try again next update
    }
    
    // else reset time
    _timer = 0.0f;
    
    // increment spawn counter and see if we can leave our spawing state
    _spawnCounter++;
    if (_spawnCounter < _spawnMaxCount) {
        return 4; // stay in alive state
    }
    
    // reset spawn count
    _spawnCounter = 0;
    
    // move to resting state if we aren't a pusher
    [self setAliveStateToResting];

    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if all towers are gone, then stop doing whatever it is we are doing
    if ([[LaserGrid sharedLaserGrid] allTowersDeactivated]) {
        return;
    }
    
    switch (_state) {
        case kSFStateQueued:    [self updateStateQueued:elapsedTime]; break;
        case kSFStateAlive:     [self updateStateAlive:elapsedTime]; break;
        default: break;
    }
}

//
//
//
- (void)handleLaserTowerDeactivated:(NSNotification *)notification {
    LaserTower *laserTower = (LaserTower *)[notification object];
    if (laserTower == [self targetedTower]) {
        [self recalcTargetedTowerAndPath];
    }
}

//
//
//
- (void)handleLaserCollision:(LaserCollider *)laserCollider {
    
    // only if the laser is the same color as us, then take damage
    LaserEmitter *laserEmitter = laserCollider._laserEmitter;
    if (laserEmitter._colorState == _colorState) {
        [_healthManager takingDamageFromLaserCollider:laserCollider];
    }
}

//
//
//
- (void)handleSoldierCollisionBegin:(Soldier *)soldier {
    _soldierCollisionCount++;
}

//
//
//
- (void)handleSoldierCollisionSeparate:(Soldier *)soldier {
    _soldierCollisionCount--;
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    
    self.position = _body->p;
    
    // if we are taking damage, then shake
    if ([_healthManager isTakingDamage]) {
        float distance = _shakeDistance * [_healthManager._laserHitSet count];
        CGPoint shakeDelta = ccpRotateByAngle(ccp(0.0f, distance), ccp(0.0f, 0.0f), arc4random());
        self.position = ccpAdd(_body->p, shakeDelta);
    }
}

//
//
//
- (void)dealloc {    
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    self._pathSprites = nil;
    self._pathSegments = nil;
    self._targetedTower = nil;
    self._healthManager = nil;
    self._healthBar = nil;
    self._gearSprite = nil;
    self._barrierManager = nil;
    self._sfSpawn = nil;
    self._sfExplosion = nil;
    self._sfAttackManager = nil;
    
    [super dealloc];
}


@end
