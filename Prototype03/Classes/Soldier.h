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
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "protocols.h"
#import "defines.h"

//
// forward declarations
//
@class LaserCollider;
@class HealthManager;
@class LaserTower;
@class SoldierExplosion;
@class SoldierSpawn;

//
// @interface Soldier
//
@interface Soldier : CCSprite <LaserTowerTargetingProtocol, PathSpriteOwnerProtocol> {
    
    // id, parent properties
    unsigned int _soldierId;
    
    // chipmnk stuff
    cpBody *_controlBody;
    cpBody *_body;
    cpShape *_shape;
    cpConstraint *_pivot;
    cpConstraint *_groove;
    
    // state tracking stuff
    bool _active;
    bool _chipmunkActive;
    SoldierState _state;
    SoldierSubState _subState;
    SoldierSubState _prevSubState;
    ColorState _colorState;
    
    // state timers
    ccTime _timer;
    ccTime _stateQueuedInterval;
    ccTime _subStateIdleInterval;
    
    // pathing stuff
    NSMutableArray *_pathSegments;
    int _currentPathSegmentIndex;
    LaserTower *_targetedTower;
    CGPoint _direction;
    CGPoint _grooveDirection;
    
    // position and movement
    CGPoint _goalPosition;
    float _maxVelocity;
    float _acceleration;
    float _stoppingDistance;
    
    // rotation
    float _goalRotation;
    float _goalRotationDistance;
    float _rotationTraveled;
    
    // health
    HealthManager *_healthManager;
    CCProgressTimer *_healthBar;
    
    // our path sprites
    NSMutableArray *_pathSprites;
    
    // explosion
    SoldierExplosion *_soldierExplosion;
    
    // spawning
    SoldierSpawn *_soldierSpawn;
    int _spawnZorder;    
}

//
// properties
//
@property (nonatomic, assign) unsigned int _soldierId;
@property (nonatomic, assign) cpBody *_controlBody;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) cpConstraint *_pivot;
@property (nonatomic, assign) cpConstraint *_groove;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _chipmunkActive;
@property (nonatomic, assign) SoldierState _state;
@property (nonatomic, assign) SoldierSubState _subState;
@property (nonatomic, assign) SoldierSubState _prevSubState;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) ccTime _stateQueuedInterval;
@property (nonatomic, assign) ccTime _subStateIdleInterval;
@property (nonatomic, retain) NSMutableArray *_pathSegments;
@property (nonatomic, assign) int _currentPathSegmentIndex;
@property (nonatomic, assign) LaserTower *_targetedTower;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, assign) CGPoint _grooveDirection;
@property (nonatomic, assign) CGPoint _goalPosition;
@property (nonatomic, assign) float _maxVelocity;
@property (nonatomic, assign) float _acceleration;
@property (nonatomic, assign) float _stoppingDistance;
@property (nonatomic, assign) float _goalRotation;
@property (nonatomic, assign) float _goalRotationDistance;
@property (nonatomic, assign) float _rotationTraveled;
@property (nonatomic, retain) HealthManager *_healthManager;
@property (nonatomic, retain) CCProgressTimer *_healthBar;
@property (nonatomic, retain) NSMutableArray *_pathSprites;
@property (nonatomic, retain) SoldierExplosion *_soldierExplosion;
@property (nonatomic, retain) SoldierSpawn *_soldierSpawn;
@property (nonatomic, assign) int _spawnZorder;

//
// static functions
//
+ (float)radius;
+ (float)diameter;
+ (float)spawnSpacing;
+ (Soldier *)soldier;

//
// initialization
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;
- (CCProgressTimer *)createHealthBar;
- (void)setupChipmunkObjects;

//
// setter/getter overrides
//
- (void)setPosition:(CGPoint)position;
- (void)set_subState:(SoldierSubState)subState;
- (CGPoint)bodyPosition;
- (NSMutableArray *)pathSprites;
- (NSMutableArray *)pathSegments;
- (LaserTower *)targetedTower;
- (void)setTargetedTower:(LaserTower *)targetedTower;

//
// manage targeting and pathing
//
- (void)recalcTargetedTowerAndPath;
- (void)resetPathing;
- (float)calcDistanceToTargetedTower;

//
// activate/deactivate
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint skipSpawnAnimation:(bool)skipSpawnAnimation;
- (int)deactivate;
- (int)activateChipmunkObjects;
- (int)deactivateChipmunkObjects;

//
// state stuff
//
- (void)explode;
- (void)switchToColorState:(ColorState)colorState;
- (void)switchToColorStateWithNumber:(NSNumber *)colorStateNumber;
- (float)calcGoalRotation;
- (int)setStateToQueued;
- (int)setStateToSpawning;
- (int)setStateToAlive;
- (int)setToSubState:(SoldierSubState)subState;
- (int)setSubStateToIdle;
- (int)setSubStateToNormal;
- (int)setSubStateToRotating;
- (int)setSubStateToExploding;
- (int)setStateToDead;

//
// update
//
- (void)refreshFrame;
- (int)updateStateQueued:(ccTime)elapsedTime;
- (int)updateGrooveConstraint:(ccTime)elapsedTime;
- (int)updateVelocity:(ccTime)elapsedTime;
- (int)updateAliveSubStateIdle:(ccTime)elapsedTime;
- (int)updateAliveSubStateNormal:(ccTime)elapsedTime;
- (int)updateAliveSubStateRotating:(ccTime)elapsedTime;
- (int)updateStateAlive:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;

//
// notification stuff
//
- (void)handleLaserTowerDeactivated:(NSNotification *)notification;

//
// chipmunk callbacks
//
- (void)handleLaserCollision:(LaserCollider *)laserCollider;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;
- (void)chipmunkDeactivate;

//
// cleanup
//
- (void)dealloc;


@end
