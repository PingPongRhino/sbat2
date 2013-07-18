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
//
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "protocols.h"
#import "defines.h"

//
// forward declarations
//
@class HealthManager;
@class LaserCollider;
@class LaserTower;
@class BarrierManager;
@class SFSpawn;
@class PathSprite;
@class SFExplosion;
@class Soldier;
@class SFAttackManager;

//
// @interface SoldierSpawn
//
@interface SoldierFactory : CCSprite <LaserTowerTargetingProtocol, PathSpriteOwnerProtocol> {
    
    // id
    unsigned int _soldierFactoryId;
        
    // chipmunk stuff
    cpBody *_body;
    cpShape *_shape;
    int _soldierCollisionCount;
    
    // state stuff
    bool _active;
    bool _chipmunkActive;
    ColorState _colorState;
    SFState _state;
    SFAliveState _aliveState;
    EnemyType _enemyType;
    unsigned int _collisionGroup;
    
    // pathing stuff
    NSMutableArray *_pathSprites;
    NSMutableArray *_pathSegments;
    LaserTower *_targetedTower;
    CGPoint _direction;
    
    // health stuff
    HealthManager *_healthManager;
    CCProgressTimer *_healthBar;
    
    // gear sprite
    CCSprite *_gearSprite;
    
    // timers for various states
    ccTime _timer; // timer that is used for all states
    ccTime _stateQueuedInterval;
    ccTime _aliveStateRestingInterval;
    ccTime _aliveStateSpawningInterval;
    
    // spawn counter for kSFAliveStateSpawningInterval state
    int _spawnCounter;
    int _spawnMaxCount;
    
    // rotation spin up for spawn stuff
    float _rotationVelocity;
        
    // kEnemyBarrierFactory specific stuff
    BarrierManager *_barrierManager;
    
    // spawn stuff
    SFSpawn *_sfSpawn;
    
    // exlposion stuff
    SFExplosion *_sfExlposion;
    
    // attack stuff
    SFAttackManager *_sfAttackManager;
}

//
// properties
//
@property (nonatomic, assign) unsigned int _soldierFactoryId;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) int _soldierCollisionCount;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _chipmunkActive;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, assign) SFState _state;
@property (nonatomic, assign) SFAliveState _aliveState;
@property (nonatomic, assign) EnemyType _enemyType;
@property (nonatomic, assign) unsigned int _collisionGroup;
@property (nonatomic, retain) NSMutableArray *_pathSprites;
@property (nonatomic, retain) NSMutableArray *_pathSegments;
@property (nonatomic, assign) LaserTower *_targetedTower;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, retain) HealthManager *_healthManager;
@property (nonatomic, retain) CCProgressTimer *_healthBar;
@property (nonatomic, retain) CCSprite *_gearSprite;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) ccTime _stateQueuedInterval;
@property (nonatomic, assign) ccTime _aliveStateRestingInterval;
@property (nonatomic, assign) ccTime _aliveStateSpawningInterval;
@property (nonatomic, assign) float _rotationVelocity;
@property (nonatomic, assign) int _spawnCounter;
@property (nonatomic, assign) int _spawnMaxCount;
@property (nonatomic, retain) BarrierManager *_barrierManager;
@property (nonatomic, retain) SFSpawn *_sfSpawn;
@property (nonatomic, retain) SFExplosion *_sfExplosion;
@property (nonatomic, retain) SFAttackManager *_sfAttackManager;

//
// static functions
//
+ (id)soldierFactory;
+ (float)radius;
+ (float)diameter;
+ (float)spawnSpacing;
+ (float)spawnSpacingWithBarrier;

//
// initialization
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;
- (CCProgressTimer *)createHealthBar;
- (void)setupChipmunkObjects;

//
// setters/getters
//
- (void)setPosition:(CGPoint)position;
- (CGPoint)bodyPosition;
- (NSMutableArray *)pathSprites;
- (NSMutableArray *)pathSegments;
- (LaserTower *)targetedTower;
- (void)setTargetedTower:(LaserTower *)targetedTower;


//
// path mangement
//
- (float)calcDistanceFromPathSegmentArray:(NSArray *)pathSegmentArray;
- (void)recalcTargetedTowerAndPath;


//
// activate/deactivate
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint;
- (int)deactivate;
- (int)activateChipmunkObjects;
- (int)deactivateChipmunkObjects;

//
// visibility
//
- (void)setVisibility:(bool)visible;

//
// state management stuff
//
- (void)explode;
- (void)attack;
- (int)setStateToQueued;
- (int)setStateToAlive;
- (int)setAliveStateToResting;
- (int)setStateToExplodingWithAttackType:(bool)attackType;
- (int)setStateToDead;

//
// color state stuff
//
- (void)switchToColorState:(ColorState)colorState;
- (void)switchToColorStateWithNumber:(NSNumber *)colorStateNumber;

//
// update
//
- (int)updateStateQueued:(ccTime)elapsedTime;
- (int)updateStateAlive:(ccTime)elapsedTime;
- (int)updateSpin:(ccTime)elapsedTime;
- (int)updateActiveStateResting:(ccTime)elapsedTime;
- (int)updateActiveStateSoldierSpawning:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;

//
// notifications
//
- (void)handleLaserTowerDeactivated:(NSNotification *)notification;

//
// chipmunk callbacks
//
- (void)handleLaserCollision:(LaserCollider *)laserCollider;
- (void)handleSoldierCollisionBegin:(Soldier *)soldier;
- (void)handleSoldierCollisionSeparate:(Soldier *)soldier;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;

//
// cleanup
//
- (void)dealloc;


@end
