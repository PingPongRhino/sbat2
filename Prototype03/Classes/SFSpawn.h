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
#import "defines.h"

//
// forward declarations
//
@class SoldierFactory;
@class BarrierManager;

//
// @interface SFSpawn
//
@interface SFSpawn : CCNode {
    SoldierFactory *_soldierFactory;
    bool _active;
    CCSprite *_centerSprite;
    CCSprite *_gearSprite;
    CCSprite *_gearShadowSprite;
    CCProgressTimer *_healthBar;
    BarrierManager *_barrierManager;
    float _centerZVelocity;
    float _gearZVelocity;
    float _gearRotationVelocity;
    bool _gearDeacclerate;
    ccTime _timer;
    CCSprite *_animation;
    CCSequence *_whiteAnimation;
    CCSequence *_blackAnimation;
    
}

//
// properties
//
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) CCSprite *_centerSprite;
@property (nonatomic, retain) CCSprite *_gearSprite;
@property (nonatomic, retain) CCSprite *_gearShadowSprite;
@property (nonatomic, retain) CCProgressTimer *_healthBar;
@property (nonatomic, retain) BarrierManager *_barrierManager;
@property (nonatomic, assign) float _centerZVelocity;
@property (nonatomic, assign) float _gearZVelocity;
@property (nonatomic, assign) float _gearRotationVelocity;
@property (nonatomic, assign) bool _gearDeacclerate;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, retain) CCSprite *_animation;
@property (nonatomic, retain) CCSequence *_whiteAnimation;
@property (nonatomic, retain) CCSequence *_blackAnimation;

//
// static initializer
//
+ (id)sfSpawnWithSoldierFactory:(SoldierFactory *)soldierFactory;

//
// methods
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory;
- (CCProgressTimer *)createHealthBar;
- (CCSequence *)createSequenceWithColorState:(ColorState)colorState;
- (CCSequence *)animationWithColorState:(ColorState)colorState;
- (int)activate;
- (int)deactivate;
- (void)activateAnimation;
- (void)completedAnimation;
- (void)activateGearSprite;
- (void)activateCenterSprite;
- (void)activateBarrierManager;
- (void)activateHealthBar;
- (void)updateAnimation:(ccTime)elapsedTime;
- (void)updateGearSprite:(ccTime)elapsedTime;
- (void)updateCenterSprite:(ccTime)elapsedTime;
- (void)updateHealthBar:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;

@end
