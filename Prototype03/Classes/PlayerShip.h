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
#import "defines.h"
#import "protocols.h"

//
// forward declarations
//
@class LaserEmitter;
@class LaserCollider;
@class PlayerShipGear;
@class PlayerShipLaserInfo;

//
// @interface PlayerShip
//
@interface PlayerShip : CCSprite <TouchProtocol> {
    unsigned int _playerId;
    
    // chipmunk stuff
    cpBody *_body;
    cpBody *_controlBody;
    cpShape *_shape;
    cpConstraint *_pivot;
    PlayerShip *_partnerShip;
    
    // laser emitter stuff
    NSMutableSet *_laserEmitters;
    NSMutableSet *_inactiveLaserEmitters;
    NSMutableDictionary *_laserEmitterDictionary;
    LaserEmitter *_mainLaserEmitter;
    
    bool _active;
    UITouch *_touch;
    bool _touchMoved;
    CGPoint _touchOffset;
    CGPoint _goalPosition;
    CGPoint _goalDirection;;
    ColorState _colorState;
    
    PlayerShipGear *_playerShipGear;
    CCSprite *_ledRed;
    CCSprite *_ledGreen;
}

//
// properties
//
@property (nonatomic, assign) unsigned int _playerId;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpBody *_controlBody;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) cpConstraint *_pivot;
@property (nonatomic, retain) NSMutableSet *_laserEmitters;
@property (nonatomic, retain) NSMutableSet *_inactiveLaserEmitters;
@property (nonatomic, retain) NSMutableDictionary *_laserEmitterDictionary;
@property (nonatomic, assign) LaserEmitter *_mainLaserEmitter;
@property (nonatomic, assign) PlayerShip *_partnerShip;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) UITouch *_touch;
@property (nonatomic, assign) bool _touchMoved;
@property (nonatomic, assign) float _touchDisplacement;
@property (nonatomic, assign) CGPoint _touchOffset;
@property (nonatomic, assign) CGPoint _goalPosition;
@property (nonatomic, assign) CGPoint _goalDirection;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, retain) PlayerShipGear *_playerShipGear;
@property (nonatomic, retain) CCSprite *_ledRed;
@property (nonatomic, retain) CCSprite *_ledGreen;

//
// static methods
//
+ (float)radius;
+ (CGPoint)defaultSpawnPointForPlayerShip:(int)playerShip;
+ (void)setSharedPlayerShips:(NSArray *)playerShips;
+ (NSArray *)sharedPlayerShips;
+ (bool)sharedPlayerShipIsColor:(ColorState)colorState;

//
// static initializer
//
+ (id)playerShipWithCharacterType:(CharacterType)characterType;

//
// initialization
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;
- (void)setupChipmunkObjects;

//
// setters/getters
//
- (void)setPosition:(CGPoint)position;
- (void)setGoalPosition:(CGPoint)goalPosition;
- (LaserEmitter *)inactiveLaserEmitter;

//
// activate/deactivate
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint
                       target:(CGPoint)target
                  partnerShip:(PlayerShip *)partnerShip
        masterControlSwitches:(NSArray *)masterControlSwitches;
- (int)deactivate;

// handle laser emitter activate/deactivate
- (PlayerShipLaserInfo *)activateLaserEmitterWithObject:(id)object colorState:(ColorState)colorState;
- (void)handleLaserEmitterDeactivated:(NSNotification *)notification;

//
// color state stuff
//
- (bool)isSwitchingColor;
- (void)switchToColorState:(ColorState)colorState playSFX:(bool)playSFX forceSwitch:(bool)forceSwitch;

//
// cocos2d update
//
- (void)updatePosition:(ccTime)elapsedTime;
- (int)updateLaser;
- (void)update:(ccTime)elapsedTime;

//
// chipmunk stuff
//
- (void)handleLaserCollision:(LaserCollider *)laserCollider;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;

//
// handle notifications
//
- (void)handleMasterControlSwitchTapped:(NSNotification *)notification;

//
// TouchProtocol
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
