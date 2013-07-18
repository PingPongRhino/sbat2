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
#import "Soldier.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "LaserGrid.h"
#import "LaserTower.h"
#import "HealthManager.h"
#import "LaserCollider.h"
#import "LaserEmitter.h"
#import "PathSegment.h"
#import "PathSpriteManager.h"
#import "SoldierExplosion.h"
#import "SoldierSpawn.h"
#import "EnemyDropManager.h"
#import "EnemyDrop.h"
#import "SimpleAudioEngine.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "SimpleAudioEngine.h"

//
// globals
//
static unsigned int _currentSoldierId = 0;
static const int _radius = 10.0f;
static const int _diameter = 20.0f;
static const float _rotationVelocity = 360;
static const float _shakeDistance = 2.0f;

//
// @implementation Soldier
//
@implementation Soldier

//
// synthesize
//
@synthesize _soldierId;
@synthesize _controlBody;
@synthesize _body;
@synthesize _shape;
@synthesize _pivot;
@synthesize _groove;
@synthesize _active;
@synthesize _chipmunkActive;
@synthesize _state;
@synthesize _subState;
@synthesize _prevSubState;
@synthesize _colorState;
@synthesize _timer;
@synthesize _stateQueuedInterval;
@synthesize _subStateIdleInterval;
@synthesize _pathSegments;
@synthesize _currentPathSegmentIndex;
@synthesize _targetedTower;
@synthesize _direction;
@synthesize _grooveDirection;
@synthesize _goalPosition;
@synthesize _maxVelocity;
@synthesize _acceleration;
@synthesize _stoppingDistance;
@synthesize _goalRotation;
@synthesize _goalRotationDistance;
@synthesize _rotationTraveled;
@synthesize _healthManager;
@synthesize _healthBar;
@synthesize _pathSprites;
@synthesize _soldierExplosion;
@synthesize _soldierSpawn;
@synthesize _spawnZorder;

//
//
//
+ (float)radius { return _radius; }
+ (float)diameter { return _diameter; }
+ (float)spawnSpacing { return _diameter + 10.0f; }

//
//
//
+ (Soldier *)soldier {
    Soldier *soldier = [[Soldier alloc] initWithSpriteFrame:[SpriteFrameManager soldierSpriteFrameWithColorState:kColorStateDefault]];
    return [soldier autorelease];
}

//
//
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
    self = [super initWithSpriteFrame:spriteFrame];
    
    // set id
    self._soldierId = _currentSoldierId;
    _currentSoldierId++;
        
    // chipmunk properties
    self._controlBody = cpBodyNew(INFINITY, INFINITY);
    self._body = cpBodyNew(1.0f, INFINITY);
    self._shape = cpCircleShapeNew(_body, _radius, cpvzero);
    self._pivot = cpPivotJointNew2(_controlBody, _body, cpvzero, cpvzero);
    self._groove = cpGrooveJointNew(&[StageLayer sharedStageLayer]._space->staticBody, _body, cpvzero, cpvzero, cpvzero);
    
    // state properties
    self._active = false;
    self._chipmunkActive = false;
    self._state = kSoldierStateUnknown;
    self._subState = kSoldierSubStateUnknown;
    self._prevSubState = kSoldierSubStateUnknown;
    self._colorState = kColorStateDefault;
    
    // state timer properties
    self._timer = 0.0f;
    self._stateQueuedInterval = 0.0f;
    self._subStateIdleInterval = 0.0f;

    // pathing properties
    self._pathSegments = [NSMutableArray arrayWithCapacity:2];
    self._currentPathSegmentIndex = 0;
    self._targetedTower = nil;
    self._direction = ccp(0.0f, 0.0f);
    self._grooveDirection = ccp(0.0f, 0.0f);
    
    // position and movement properties
    self._goalPosition = ccp(0.0f, 0.0f);
    self._maxVelocity = 100.0f;
    self._acceleration = 1000.0f;
    self._stoppingDistance = 0.5f * _maxVelocity * (_maxVelocity / _acceleration); // 0.5f * current velocity * time to stop
    
    // rotation properties
    self._goalRotation = 0.0f;
    self._goalRotationDistance = 0.0f;
    self._rotationTraveled = 0.0f;

    // health properties
    self._healthManager = [HealthManager healthManagerWithMaxHealth:100 damageVelocity:500.0f];
    self._healthBar = [self createHealthBar];
    
    // path sprite stuff
    self._pathSprites = [NSMutableArray array];
    
    // soldier explosion
    self._soldierExplosion = [SoldierExplosion soldierExplosionWithSoldier:self];
    
    // soldier spawn
    self._soldierSpawn = [SoldierSpawn soldierSpawnWithSoldier:self];
    self._spawnZorder = 0;
    
    // init chipmunk objects
    [self setupChipmunkObjects];
                
    // init sprite stuff
    [self scheduleUpdate];
            
    return self;
}

//
//
//
- (CCProgressTimer *)createHealthBar {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager soldierHealthBarSpriteFrameWithColorState:_colorState];
    CCProgressTimer *healthBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrame:spriteFrame]];
    healthBar.type = kCCProgressTimerTypeRadial;
    healthBar.percentage = 0.0f;
    return healthBar;
}

//
//
//
- (void)setupChipmunkObjects {
    
    // shape setup
    _shape->e = 0.0f;
    _shape->u = 0.0f;
    _shape->group = GROUP_SOLDIERS + _soldierId;
    _shape->collision_type = COLLISION_TYPE_SOLDIER;
    _shape->layers = 0;
    _shape->data = self;
    
    // constraint setup
    _pivot->biasCoef = 0.0f;
    _pivot->maxForce = 1000.0f;
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _healthBar.position = position;
}

//
//
//
- (void)set_subState:(SoldierSubState)subState {
    _prevSubState = _subState;
    _subState = subState;
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
- (void)recalcTargetedTowerAndPath {
        
    // recalc targeted tower and path
    [[LaserGrid sharedLaserGrid] calcPathForLaserTowerTargetingObject:self];
    
    // if no more towers to target, then bail
    if (!_targetedTower) {
        return;
    }
    
    // tell path sprite manager to setup some path sprites for us
    [[PathSpriteManager sharedPathSpriteManager] activatePathSpritesWithPathSpriteOwner:self];
    
    // reset our pathing
    [self resetPathing];
}

//
//
//
- (void)resetPathing {
        
    // initialize on pathing
    _currentPathSegmentIndex = 0;
    PathSegment *pathSegment = [_pathSegments objectAtIndex:_currentPathSegmentIndex];
    
    // init groove joint
    cpGrooveJointSetGrooveA(_groove, pathSegment._start);
    cpGrooveJointSetGrooveB(_groove, pathSegment._end);
    
    // set groove direction
    _grooveDirection = ccpNormalize(ccpSub(pathSegment._end, pathSegment._start));
    
    // update goal position
    _goalPosition = pathSegment._end;
    
    // reset layer collisions
    _shape->layers = LAYER_MASK_SOLDIERS |
                     LAYER_MASK_PLAYER_LASER_COLLIDERS |
                     _targetedTower._collisionLayer | 
                     _targetedTower._partner._collisionLayer;
    
    // enter rotating state so we can align with the new pathing
    [self setSubStateToRotating];
}

//
//
//
- (float)calcDistanceToTargetedTower {
    
    // make sure we are on a valid segment
    if (_currentPathSegmentIndex < 0 || _currentPathSegmentIndex >= [_pathSegments count]) {
        return MAXFLOAT; // something screwy
    }
    
    // git distance left on current segment
    PathSegment *pathSegment = [_pathSegments objectAtIndex:_currentPathSegmentIndex];
    float distance = ccpDistance(_body->p, pathSegment._end);
    
    // calc rest of path
    for (int i=_currentPathSegmentIndex+1; i < [_pathSegments count]; i++) {
        pathSegment = [_pathSegments objectAtIndex:i];
        distance += ccpDistance(pathSegment._start, pathSegment._end);
    }
    
    return distance;
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint skipSpawnAnimation:(bool)skipSpawnAnimation {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
    
    // add to scene so we start updating
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_02] addChild:self z:ZORDER_SOLDIER];
    
    // see if we are paused
    if ([StageLayer sharedStageLayer]._paused) {
        [self pauseSchedulerAndActions];
    }
    
    // register for laser tower deactivate notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerDeactivated:)
                                                 name:kNotificationLaserTowerDeactivated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerDeactivated:)
                                                 name:kNotificationLaserTowerExploding
                                               object:nil];
    
    // set our spawn point
    _body->p = spawnPoint;
            
    // if we are doing spawn, then start spawn
    if (!skipSpawnAnimation) {
        [self setStateToQueued];
        return 2;
    }
    
    // else set to alive state immediately
    [self setStateToAlive];
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already inactive, then bail out
    if (!_active)
        return 1;
    
    // set to inactive
    _active = false;
    
    // shrink our paths and let go of them
    [[PathSpriteManager sharedPathSpriteManager] deactivatePathSpritesForPathSpriteOwner:self];
    [_pathSprites removeAllObjects];
    
    // set to dead state
    [self setStateToDead];
    
    // reset body velocity so we are reset if we reactivate
    _controlBody->v = cpvzero;
    _body->v = cpvzero;
            
    // reset our way point array
    _currentPathSegmentIndex = 0;
    [[LaserGrid sharedLaserGrid] deactivateLaserTowerTargetingObject:self];
                
    // deactivate explosion
    [_soldierExplosion deactivate];
    
    // deactivate spawning guy
    [_soldierSpawn deactivate];
    
    // remove from scene
    [self removeFromParentAndCleanup:false];
    
    // send out deactivated event
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSoldierDeactivated object:self];
    
    // stop observing stuff
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    // add body to the space
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceAddBody(space, _body);
    cpSpaceAddShape(space, _shape);
    cpSpaceAddConstraint(space, _pivot);
    cpSpaceAddConstraint(space, _groove);
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
    
    // remove body from space
    cpSpace *space = [StageLayer sharedStageLayer]._space;
    cpSpaceRemoveBody(space, _body);
    cpSpaceRemoveShape(space, _shape);
    cpSpaceRemoveConstraint(space, _pivot);
    cpSpaceRemoveConstraint(space, _groove);
    return 0;
}

//
//
//
- (void)explode {
    [self setSubStateToExploding];
}

//
//
//
- (void)switchToColorState:(ColorState)colorState {
    
    _colorState = colorState;
    
    // switch ourselves to new color
    [self refreshFrame];
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
- (float)calcGoalRotation {
    CGPoint direction = ccpSub(cpGrooveJointGetGrooveB(_groove), cpGrooveJointGetGrooveA(_groove));
    _goalRotation = CC_RADIANS_TO_DEGREES(ccpAngleSigned(direction, ccp(0.0f, 1.0f)));
    
    // find shortest distance to our goal rotation from our current rotation
    CGPoint oldDirection = ccpRotateByAngle(ccp(0.0f, 1.0f), ccp(0.0f, 0.0f), CC_DEGREES_TO_RADIANS(-self.rotation));
    _goalRotationDistance = CC_RADIANS_TO_DEGREES(ccpAngleSigned(direction, oldDirection));
    
    // reset distance traveled
    _rotationTraveled = 0.0f;
    
    return _goalRotation;
}

//
//
//
- (int)setStateToQueued {
    _state = kSoldierStateQueued;
    _timer = 0.0f;
    self.visible = false;
    return 0;
}

//
//
//
- (int)setStateToSpawning {
    _state = kSoldierStateSpawning;
    [_soldierSpawn activate];
    return 0;
}

//
//
//
- (int)setStateToAlive {
    
    _state = kSoldierStateAlive;
    [self setSubStateToIdle];
    _prevSubState = kSoldierSubStateIdle; // init previous substate
    
    // add to scene
    self.visible = true;
    [[StageLayer sharedStageLayer] addChild:_healthBar z:ZORDER_SOLDIER_HEALTH_BAR];
    
    // activate chipmunk objects
    [self activateChipmunkObjects];
    
    // sync sprite with body
    self.position = _body->p;
    
    // reset rotation and direction
    self._direction = ccp(0.0f, 1.0f);
    self.rotation = 0.0f;
    
    // calc our path if it hasn't already been set or we don't have a targeted tower
    if ([_pathSegments count] <= 0 || _targetedTower == nil) {
        [self recalcTargetedTowerAndPath];
    }
    else {
        // reset our pathing so we start at beginning of the way points
        [self resetPathing];
        
        // this is a hack, if the soldier factory precomputed the path for us, we still
        // want to register our path sprites incase the kill the soldier factory but not the soldier
        // let path manager know about our new path
        [[PathSpriteManager sharedPathSpriteManager] activatePathSpritesWithPathSpriteOwner:self];
    }
    
    // set health
    [_healthManager reset];
    
    // set health bar initial state
    _healthBar.percentage = [_healthManager getPercentage];
    _healthBar.visible = true;
    
    return 0;
}

//
//
//
- (int)setToSubState:(SoldierSubState)subState {
    switch (subState) {
        case kSoldierSubStateIdle: return [self setSubStateToIdle];
        case kSoldierSubStateNormal: return [self setSubStateToNormal];
        case kSoldierSubStateRotating: return [self setSubStateToRotating];
        case kSoldierSubStateExploding: return [self setSubStateToExploding];
        default: break;
    }
    
    return -1;
}

//
//
//
- (int)setSubStateToIdle {
    self._subState = kSoldierSubStateIdle;
    _timer = 0.0f;
    _body->v = cpvzero;
    _controlBody->v = cpvzero;
    return 0;
}

//
//
//
- (int)setSubStateToNormal {
    self._subState = kSoldierSubStateNormal;
    return 0;
}

//
//
//
- (int)setSubStateToRotating {
    self._subState = kSoldierSubStateRotating;
    
    // recalc goal rotation
    [self calcGoalRotation];
    
    // kill velocity
    _body->v = cpvzero;
    _controlBody->v = cpvzero;
    return 0;
}

//
//
//
- (int)setSubStateToExploding {
    
    // if not active or alive, then do nothing
    if (!_active || _state != kSoldierStateAlive) {
        return 1;
    }

    // set state
    self._subState = kSoldierSubStateExploding;
    
    // reset position to final position cause we are probably shaking around
    self.position = _body->p;
    
    // get enemy drop
    if (_healthManager._health <= 0) {
        EnemyDrop *enemyDrop = [[EnemyDropManager sharedEnemyDropManager] generateEnemyDrop];
        [enemyDrop activateWithSpawnPoint:_body->p];
        
        [[SimpleAudioEngine sharedEngine] playEffect:SFX_SOLDIER_DEATH pitch:1.0f pan:0.0f gain:SFX_SOLDIER_DEATH_GAIN];
    }
    
    // hid the health bar, we no longer need to see it
    _healthBar.visible = false;
    
    // kill velocity
    _body->v = cpvzero;
    _controlBody->v = cpvzero;
    
    // deactivate collisions
    [self deactivateChipmunkObjects];
    
    // run explosion animation
    [_soldierExplosion activate];
    return 0;
}

//
//
//
- (int)setStateToDead {
    
    // update state
    SoldierState prevState = _state;
    _state = kSoldierStateDead;
    
    if (prevState != kSoldierStateAlive) {
        return 1;
    }
    
    // send out notification that we were killed
    if (_healthManager._health <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSoldierKilledByPlayer object:self];
    }
    
    // deactivate chipmunk objects
    [self deactivateChipmunkObjects];
    
    // remove health bar from scene
    [_healthBar removeFromParentAndCleanup:false];
    return 0;
}

//
//
//
- (void)refreshFrame {

    // refresh soldier frame
    [self setDisplayFrame:[SpriteFrameManager soldierSpriteFrameWithColorState:_colorState]];
    
    // refresh healthbar frame
    [_healthBar.sprite setDisplayFrame:[SpriteFrameManager soldierHealthBarSpriteFrameWithColorState:_colorState]];
    
    // since the CCProgressTimer won't update texture vertex info
    // unless the percentage change, we fake it out instead by changing
    // the percentage on it
    _healthBar.percentage = -1.0f;
    _healthBar.percentage = [_healthManager getPercentage];
}

//
//
//
- (int)updateStateQueued:(ccTime)elapsedTime {
    
    // if we are still waiting to finish spawning
    _timer += elapsedTime;
    if (_timer <= _stateQueuedInterval) {
        return 1; // bail
    }
    
    // move to next state
    [self setStateToSpawning];
    return 0;
}

//
//
//
- (int)updateGrooveConstraint:(ccTime)elapsedTime {
    
    // if we are on last segment, then bail, we don't need
    // worry about updating the groove
    if (_currentPathSegmentIndex >= ([_pathSegments count]-1)) {
        return 1;
    }
    
    // if we haven't arrived at the goal or we aren't even close
    if (!CGPointEqualToPoint(_goalPosition, _body->p) &&
        ccpDistance(_goalPosition, _body->p) > 2.0f)
    {
        return 1;
    }

    // go to next segement
    _currentPathSegmentIndex++;
        
    // get new path segment
    PathSegment *pathSegment = [_pathSegments objectAtIndex:_currentPathSegmentIndex];
                    
    // set new groove points
    cpGrooveJointSetGrooveA(_groove, pathSegment._start);
    cpGrooveJointSetGrooveB(_groove, pathSegment._end);
    
    // update groove direction
    _grooveDirection = ccpNormalize(ccpSub(pathSegment._end, pathSegment._start));
    
    // update goal position
    _goalPosition = pathSegment._end;
    
    // if we are moving along the laser line now, then remove the enemy spawn layer
    _shape->layers = LAYER_MASK_SOLDIERS |
                     LAYER_MASK_PLAYER_LASER_COLLIDERS |
                     _targetedTower._collisionLayer |
                     _targetedTower._partner._collisionLayer;
    
    // go to rotating state so we can align with the new groove
    [self setSubStateToRotating];
    
    return 0;
}

//
//
//
- (int)updateVelocity:(ccTime)elapsedTime {
    
    float velocity = 0.0f;
    
    // if we have arrived at the goal, then stop, don't worry about going to
    // next segment, updateConstraint that is called before us takes care of that
    if (CGPointEqualToPoint(_goalPosition, _body->p)) {
        return 1;
    }
    
    // move to the goal
    _direction = cpvsub(_goalPosition, _body->p);
    
    // safety check for nan
    if (isnan(_direction.x) || isnan(_direction.y)) {
        return 2;
    }
    
    // another safety check for if we arrived at the goal, logic cause me a lot of issues so being extra careful
    float length = cpvlength(_direction);
    if (length == 0) {
        return 3;
    }
            
    // if are with in the stopping distance, figure out our slow downed velocity
    if (length <= _stoppingDistance) {
        velocity = _maxVelocity * (length / _stoppingDistance);
    }
    else {
        
        // calc current velocity
        float delta = _acceleration * elapsedTime;
        velocity = cpvlength(_body->v) + delta;
        
        // set to max velocity
        if (velocity > _maxVelocity)
            velocity = _maxVelocity;        
    }
    
    // get our new direction and set to max velocity
    _direction = cpvnormalize(_direction);
    _controlBody->v = cpvmult(_direction, velocity);
    
    return 0;
}

//
//
//
- (int)updateAliveSubStateIdle:(ccTime)elapsedTime {
    _timer += elapsedTime;
    if (_timer >= _subStateIdleInterval) {
        [self setSubStateToNormal];
    }
    return 0;
}

//
//
//
- (int)updateAliveSubStateNormal:(ccTime)elapsedTime {
    
    // update groove
    [self updateGrooveConstraint:elapsedTime];
    
    // update velocity
    [self updateVelocity:elapsedTime];
    return 0;
}

//
//
//
- (int)updateAliveSubStateRotating:(ccTime)elapsedTime {
    
    float delta = elapsedTime * _rotationVelocity;
    
    // we are going forward
    if (_goalRotationDistance >= 0.0f) {
        self.rotation += delta;
        _rotationTraveled += delta;
        
        // if we completed rotating
        if (_rotationTraveled >= _goalRotationDistance) {
            self.rotation = _goalRotation;
            
            // if previous state was rotation, then go back to normal
            SoldierSubState subState = (_prevSubState == kSoldierSubStateRotating) ? kSoldierSubStateNormal : _prevSubState;
            [self setToSubState:subState];
            return 1;
        }
        
        return 2;
    }
    
    // else we are going backwards
    self.rotation -= delta;
    _rotationTraveled -= delta;
    
    // if we completed rotating
    if (_rotationTraveled <= _goalRotationDistance) {
        self.rotation = _goalRotation;
        SoldierSubState subState = (_prevSubState == kSoldierSubStateRotating) ? kSoldierSubStateNormal : _prevSubState;
        [self setToSubState:subState];
        return 3;
    }
    
    return 0;
}

//
//
//
- (int)updateStateAlive:(ccTime)elapsedTime {
    
    // if we are in spawning state or exploding state, then don't take a hit
    if (_subState != kSoldierSubStateExploding) {
        // if we ran out of health, then kill us
        if([_healthManager updateHealth:elapsedTime] <= 0) {
            [self setSubStateToExploding]; // get all explody
            return 1;
        }
    }
        
    // update health bar
    _healthBar.percentage = [_healthManager getPercentage];
    
    // if no more towers to target, then just sit here
    if (!_targetedTower) {
        _body->v = cpvzero;
        _controlBody->v = cpvzero;
        return -1;
    }
    
    // update substate
    switch (_subState) {
        case kSoldierSubStateIdle:      [self updateAliveSubStateIdle:elapsedTime]; break;
        case kSoldierSubStateNormal:    [self updateAliveSubStateNormal:elapsedTime]; break;
        case kSoldierSubStateRotating:  [self updateAliveSubStateRotating:elapsedTime]; break;
        default: break;
    }
    
    return 0;
}

//
// update
//
- (void)update:(ccTime)elapsedTime {
    
    // if no more towers, then stop doing stuff
    if ([[LaserGrid sharedLaserGrid] allTowersDeactivated]) {
        return;
    }
    
    // update based on state
    switch (_state) {
        case kSoldierStateQueued: [self updateStateQueued:elapsedTime]; break;
        case kSoldierStateAlive:    [self updateStateAlive:elapsedTime]; break;
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
- (void)chipmunkDeactivate {
    [self explode];
}

//
//
//
- (void)dealloc {
    [self deactivate];
                     
    if (_controlBody) {
        cpBodyFree(_controlBody);
        _controlBody = NULL;
    }
    
    if (_body) {
        cpBodyFree(_body);
        _body = NULL;
    }
    
    if (_shape) {
        cpShapeFree(_shape);
        _shape = NULL;
    }
    
    if (_pivot) {
        cpConstraintFree(_pivot);
        _pivot = NULL;
    }
    
    if (_groove) {
        cpConstraintFree(_groove);
        _groove = NULL;
    }

    self._pathSegments = nil;
    self._healthManager = nil;
    self._targetedTower = nil;
    self._healthBar = nil;
    self._pathSprites = nil;
    self._soldierExplosion = nil;
    self._soldierSpawn = nil;
    
    [super dealloc];
}

@end
