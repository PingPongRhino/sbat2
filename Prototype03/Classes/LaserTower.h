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
// include
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "defines.h"
#import "protocols.h"

//
// forward declarations
//
@class LaserEmitter;
@class Soldier;
@class GearSwitch;
@class GearExplosionEmitter;

//
// @interface LaserTower
//
@interface LaserTower : CCSprite <TouchProtocol> {
    unsigned int _laserTowerId;
    cpBody *_body;
    cpShape *_shape;
    unsigned int _collisionLayer;       // this is our layer
    unsigned int _wallCollisionLayer;   // invisible wall we will might hit
    LaserEmitter *_linearLaserEmitter;
    CGPoint _direction;
    CGPoint _target;
    bool _active;
    ColorState _colorState;
    LaserTowerState _laserTowerState;
    LaserTower *_partner;
    bool _takingDamage;
    int _health;
    NSMutableSet *_attackingEnemies;
    NSMutableArray *_healthBarIcons;
    CGPoint _healthBarDirection;
    bool _reverseIconDirection;
    CCSprite *_gear;
    CCSprite *_gearShadow;
    CGPoint _gearShadowDirection;
    float _gearRotationVelocity;
    bool _gearRotationStopped;
    GearExplosionEmitter *_gearExplosionEmitter;
    ccTime _shakeTimer;
    UITouch *_touch;
    
    // gear switch stuff
    NSMutableSet *_gearSwitches;
    NSMutableSet *_inactiveGearSwitches;
}

//
// properties
//
@property (nonatomic, assign) unsigned int _laserTowerId;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) unsigned int _collisionLayer;
@property (nonatomic, assign) unsigned int _wallCollisionLayer;
@property (nonatomic, retain) LaserEmitter *_laserEmitter;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, assign) CGPoint _target;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, assign) LaserTowerState _laserTowerState;
@property (nonatomic, assign) LaserTower *_partner;
@property (nonatomic, assign) bool _takingDamage;
@property (nonatomic, assign) int _health;
@property (nonatomic, retain) NSMutableSet *_attackingEnemies;
@property (nonatomic, retain) NSMutableArray *_healthBarIcons;
@property (nonatomic, assign) CGPoint _healthBarDirection;
@property (nonatomic, assign) bool _reverseIconDirection;
@property (nonatomic, retain) CCSprite *_gear;
@property (nonatomic, retain) CCSprite *_gearShadow;
@property (nonatomic, assign) CGPoint _gearShadowDirection;
@property (nonatomic, assign) float _gearRotationVelocity;
@property (nonatomic, assign) bool _gearRotationStopped;
@property (nonatomic, retain) GearExplosionEmitter *_gearExplosionEmitter;
@property (nonatomic, assign) ccTime _shakeTimer;
@property (nonatomic, assign) UITouch *_touch;
@property (nonatomic, retain) NSMutableSet *_gearSwitches;
@property (nonatomic, retain) NSMutableSet *_inactiveGearSwitches;

//
// static functions
//
+ (float)radius;
+ (float)diameter;
+ (id)laserTower;
//
// initialization
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;
- (NSMutableArray *)createHealthBarIcons;
- (void)setupChipmunkObjects;

//
// setters/getters
//
- (void)setVisible:(BOOL)visible;
- (void)setPosition:(CGPoint)position;
- (void)setCollisionGroup:(unsigned int)collisionGroup;
- (void)setCollisionLayerMask:(unsigned int)collisionLayerMask;

//
// check state
//
- (bool)isDead;

//
// managed attacking enemeies
//
- (void)addAttackingEnemy:(id<LaserTowerTargetingProtocol>)enemy;
- (void)removeAttackingEnemy:(id<LaserTowerTargetingProtocol>)enemy;

//
// activate/deactivate
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint withDirection:(CGPoint)direction;
- (int)deactivate;

//
// color state stuff
//
- (bool)isSwitchingColor;
- (GearSwitch *)inactiveGearSwitch;
- (void)switchToColorState:(ColorState)colorState playSFX:(bool)playSFX forceSwitch:(bool)forceSwitch;

//
// do damage
//
- (void)incrementHealthByValue:(int)healthToIncrement;
- (void)decrementHealthByValue:(int)healthToDecrement;
- (void)decrementHealthByNumber:(NSNumber *)number;
- (void)displayDamage;

//
// collision mask stuff
//
- (void)refreshLayerMask;

//
// update active state stuff
//
- (void)updateHealthBar;
- (void)updateGearRotation:(ccTime)elapsedTime;
- (void)updateLaserStateActive:(ccTime)elapsedTime;

//
// update exploding state stuff
//
- (void)enterLaserStateExlpoding;
- (void)updateLaserStateExploding:(ccTime)elapsedTime;

//
// update shake
//
- (void)updateShake:(ccTime)elapsedTime;

//
// update
//
- (void)update:(ccTime)elapsedTime;

//
// chipmunk callbacks
//
- (void)handleSoldierCollision:(Soldier *)soldier;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;

//
// handle notifications
//
- (void)handleGearSwitchDeactivated:(NSNotification *)notification;

//
// touch stuff
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance;
- (void)handleTouchMoved:(UITouch *)touch;
- (bool)handleTouchEnded:(UITouch *)touch;
- (void)handleTouchCancelled:(UITouch *)touch;

//
// cleanup
//
- (void)dealloc;

@end
