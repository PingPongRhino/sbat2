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
#import "LaserStartEmitter.h"
#import "LaserEmitter.h"
#import "CubicBezierControlPoint.h"
#import "LaserStartParticle.h"
#import "NSMutableSet+Extended.h"

//
// static globals
//
static const int _laserStartParticleCount = 4;
static const ccTime _spawnParticleInterval = 0.05f;
static const int _rotationRange = 22.5;

//
// @implementation LaserStartEmitter
//
@implementation LaserStartEmitter

//
// synthesize
//
@synthesize _laserEmitter;
@synthesize _laserStartParticleSet;
@synthesize _inactiveLaserStartParticleSet;
@synthesize _active;
@synthesize _timer;
@synthesize _angle;

//
//
//
+ (id)laserStartEmitterWithLaserEmitter:(LaserEmitter *)laserEmitter {
    LaserStartEmitter *laserStartEmitter = [[LaserStartEmitter alloc] initWithLaserEmitter:laserEmitter];
    return [laserStartEmitter autorelease];
}

//
//
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter {
    self = [super init];
    
    // init properties
    self._laserEmitter = laserEmitter;
    self._laserStartParticleSet = [NSMutableSet setWithCapacity:_laserStartParticleCount];
    self._inactiveLaserStartParticleSet = [NSMutableSet setWithCapacity:_laserStartParticleCount];
    self._active = false;
    self._timer = 0.0f;
    self._angle = CC_DEGREES_TO_RADIANS(_rotationRange);
    
    // init particles
    [self setupLaserStartParticles];
    
    return self;
}

//
//
//
- (void)setupLaserStartParticles {
    
    // tell all the particles to deactivate first
    [_laserStartParticleSet makeObjectsPerformSelector:@selector(deactivateAndCleanupWithObject:) withObject:[NSNumber numberWithBool:false]];
    
    // clear out list
    [_laserStartParticleSet removeAllObjects];
    [_inactiveLaserStartParticleSet removeAllObjects];
  
    for (int i=0; i < _laserStartParticleCount; i++) {
        LaserStartParticle *laserStartParticle = [LaserStartParticle laserStartParticleWithLaserStartEmitter:self];
        [_laserStartParticleSet addObject:laserStartParticle];
        [_inactiveLaserStartParticleSet addObject:laserStartParticle];
    }
}

//
//
//
- (int)activate {
    
    // if already activate then bail
    if (_active) {
        return 1;
    }
    
    // activate and add to scene
    _active = true;
    
    // reset timer
    _timer = _spawnParticleInterval;
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already inactive, then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate and remove from scene
    _active = false;
    
    // tell particles to deactivate
    [_laserStartParticleSet makeObjectsPerformSelector:@selector(deactivateAndCleanupWithObject:) withObject:[NSNumber numberWithBool:true]];
    
    return 0;
}

//
//
//
- (int)deactivateLaserStartParticle:(LaserStartParticle *)laserStartParticle {
    [_inactiveLaserStartParticleSet addObject:laserStartParticle];
    return 0;
}

//
//
//
- (CubicBezierControlPoint *)controlPointToTrack { return [_laserEmitter firstControlPoint]; }

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    
    // if not active, then bail
    if (!_active) {
        return;
    }
        
    // tell active particles to update
    [_laserStartParticleSet makeObjectsPerformSelector:@selector(chipmunkUpdate:) withObject:elapsedTime];
    
    // increment spawn timer
    _timer += [elapsedTime floatValue];
    
    // it not time to spawn, then bail
    if (_timer < _spawnParticleInterval) {
        return;
    }
    
    // spawn a particle
    LaserStartParticle *laserStartParticle = [_inactiveLaserStartParticleSet popItem];
    if (laserStartParticle == nil) {
        return;
    }
    
    // calc direction
    CGPoint direction = ccpRotateByAngle([self controlPointToTrack]._normal, ccp(0.0f, 0.0f), _angle);
    
    // activate particle
    [laserStartParticle activateWithColorState:_laserEmitter._colorState direction:direction];
    
    // reset timer
    _timer = 0.0f;
    
    // flip angle for next guy
    _angle *= -1;
}

//
//
//
- (void)dealloc {
    self._laserEmitter = nil;
    self._laserStartParticleSet = nil;
    self._inactiveLaserStartParticleSet = nil;
    [super dealloc];
}


@end
