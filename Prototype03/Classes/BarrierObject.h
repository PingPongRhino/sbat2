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

//
// forward declarations
//
@class SoldierFactory;
@class LaserCollider;
@class HealthManager;

//
// @interface BarrierObject
//
@interface BarrierObject : CCSprite {
    SoldierFactory *_soldierFactory;
    cpBody *_body;
    cpShape *_shape;
    bool _active;
    bool _chipmunkActive;
    bool _exploding;
    ColorState _colorState;
    HealthManager *_healthManager;
    CCRepeatForever *_whiteAnimation;
    CCRepeatForever *_blackAnimation;
    CCSequence *_whiteExplosion;
    CCSequence *_blackExplosion;
}

//
// properties
//
@property (nonatomic, assign) SoldierFactory *_soldierFactory;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _chipmunkActive;
@property (nonatomic, assign) bool _exploding;
@property (nonatomic, retain) HealthManager *_healthManager;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, retain) CCRepeatForever *_whiteAnimation;
@property (nonatomic, retain) CCRepeatForever *_blackAnimation;
@property (nonatomic, retain) CCSequence *_whiteExplosion;
@property (nonatomic, retain) CCSequence *_blackExplosion;

//
// static functions
//
+ (id)barrierObjectWithSoldierFactory:(SoldierFactory *)soldierFactory;

//
// functions
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory;
- (void)setupChipmunkObjects;
- (CCRepeatForever *)createAnimationWithColorState:(ColorState)colorState;
- (CCSequence *)createExplosionAnimationWithColorState:(ColorState)colorState;
- (CCRepeatForever *)animationWithColorState:(ColorState)colorState;
- (CCSequence *)explosionAnimationWithColorState:(ColorState)colorState;
- (int)activateWithSpriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode chipmunkEnabled:(bool)chipmunkEnabled;
- (int)deactivate;
- (int)activateChipmunkObjects;
- (int)deactivateChipmunkObjects;
- (void)switchToColorState:(ColorState)colorState;
- (void)explode;
- (void)update:(ccTime)elapsedTime;
- (void)completedExplosion;
- (void)handleLaserCollision:(LaserCollider *)laserCollider;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;
- (void)dealloc;

@end
