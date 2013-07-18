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

//
// forward declarations
//
@class LaserEmitter;
@class LaserEndParticle;
@class LaserEndSpark;
@class CubicBezierControlPoint;

//
// @interface LaserEndEmitter
//
@interface LaserEndEmitter : NSObject {
    LaserEmitter *_laserEmitter;
    NSMutableSet *_laserEndParticleSet;
    NSMutableSet *_inactiveLaserEndParticleSet;
    NSMutableSet *_laserEndSparkSet;
    NSMutableSet *_inactiveEndSparkSet;
    bool _active;
    ccTime _timer;
}

//
// properties
//
@property (nonatomic, assign) LaserEmitter *_laserEmitter;
@property (nonatomic, retain) NSMutableSet *_laserEndParticleSet;
@property (nonatomic, retain) NSMutableSet *_inactiveLaserEndParticleSet;
@property (nonatomic, retain) NSMutableSet *_laserEndSparkSet;
@property (nonatomic, retain) NSMutableSet *_inactiveEndSparkSet;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ccTime _timer;

//
//
//
+ (id)laserEndEmitterWithLaserEmitter:(LaserEmitter *)laserEmitter;

//
// functions
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter;
- (void)setupLaserEndParticleSet;
- (void)setupLaserEndSparkSet;
- (int)activate;
- (int)deactivate;
- (CubicBezierControlPoint *)controlPointToTrack;
- (void)deactivateLaserEndParticle:(LaserEndParticle *)laserEndParticle;
- (void)deactivateLaserEndSpark:(LaserEndSpark *)laserEndSpark;
- (void)updateLaserEndParticles:(NSNumber *)elapsedTime;
- (void)updateLaserEndSparks:(NSNumber *)elapsedTime;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;
- (void)dealloc;

@end
