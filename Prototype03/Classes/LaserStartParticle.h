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
@class LaserStartEmitter;
@class FastAnimate;

//
// @interface LaserStartParticle
//
@interface LaserStartParticle : CCSprite {
    LaserStartEmitter *_laserStartEmitter;
    bool _active;
    FastAnimate *_animateWhite;
    FastAnimate *_animateBlack;
    ccTime _timer;
    CGPoint _direction;
    float _distanceTraveled;
}

//
// properties
//
@property (nonatomic, assign) LaserStartEmitter *_laserStartEmitter;
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) FastAnimate *_animateWhite;
@property (nonatomic, retain) FastAnimate *_animateBlack;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) CGPoint _direction;
@property (nonatomic, assign) float _distanceTraveled;

//
// static functions
//
+ (id)laserStartParticleWithLaserStartEmitter:(LaserStartEmitter *)laserStartEmitter;

//
// functions
//
- (id)initWithLaserStartEmitter:(LaserStartEmitter *)laserStartEmitter;
- (FastAnimate *)createAnimationWithColorState:(ColorState)colorState;
- (FastAnimate *)animationWithColorState:(ColorState)colorState;
- (int)activateWithColorState:(ColorState)colorState direction:(CGPoint)direction;
- (void)deactivateAndCleanupWithObject:(NSNumber *)cleanup;
- (int)deactivateAndCleanup:(bool)cleanup;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;
- (void)dealloc;


@end
