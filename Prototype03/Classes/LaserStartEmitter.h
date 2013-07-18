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
@class LaserEmitter;
@class LaserStartParticle;
@class CubicBezierControlPoint;

//
// @interface LaserStartEmitter
//
@interface LaserStartEmitter : NSObject {
    LaserEmitter *_laserEmitter;
    NSMutableSet *_laserStartParticleSet;
    NSMutableSet *_inactiveLaserStartParticleSet;
    bool _active;
    ccTime _timer;
    float _angle;
}

//
// properties
//
@property (nonatomic, assign) LaserEmitter *_laserEmitter;
@property (nonatomic, retain) NSMutableSet *_laserStartParticleSet;
@property (nonatomic, retain) NSMutableSet *_inactiveLaserStartParticleSet;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) float _angle;

//
// static functions
//
+ (id)laserStartEmitterWithLaserEmitter:(LaserEmitter *)laserEmitter;

//
// funcitons
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter;
- (void)setupLaserStartParticles;
- (int)activate;
- (int)deactivate;
- (CubicBezierControlPoint *)controlPointToTrack;
- (int)deactivateLaserStartParticle:(LaserStartParticle *)laserStartParticle;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;
- (void)dealloc;

@end
