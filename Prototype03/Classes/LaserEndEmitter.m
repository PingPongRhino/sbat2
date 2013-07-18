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
// inclues
//
#import "LaserEndEmitter.h"
#import "LaserEndParticle.h"
#import "LaserEndSpark.h"
#import "LaserEmitter.h"
#import "NSMutableSet+Extended.h"

//
// static globals
//
static const int _laserEndParticleCount = 2;        // this is the main base end particle effect (the large spark)
static const int _laserEndSparkCount = 2;           // this is the small line sparks that shoot off the main one
static const int _laserSparkSpawnCount = 2;         // this is the numebr of small sparks to spawn in one iteration
static const ccTime _spawnSparkInterval = 0.05f;    // time between spawning the small sparks

//
// @implementation LaserEndEmitter
//
@implementation LaserEndEmitter

//
// synthesize
//
@synthesize _laserEmitter;
@synthesize _laserEndParticleSet;
@synthesize _inactiveLaserEndParticleSet;
@synthesize _laserEndSparkSet;
@synthesize _inactiveEndSparkSet;
@synthesize _active;
@synthesize _timer;

//
//
//
+ (id)laserEndEmitterWithLaserEmitter:(LaserEmitter *)laserEmitter {
    LaserEndEmitter *laserEndEmitter = [[LaserEndEmitter alloc] initWithLaserEmitter:laserEmitter];
    return [laserEndEmitter autorelease];
}

//
//
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter {
    self = [super init];
    
    // init properties
    self._laserEmitter = laserEmitter;
    self._laserEndParticleSet = [NSMutableSet setWithCapacity:_laserEndParticleCount];
    self._inactiveLaserEndParticleSet = [NSMutableSet setWithCapacity:_laserEndParticleCount];
    self._laserEndSparkSet = [NSMutableSet setWithCapacity:_laserEndSparkCount];
    self._inactiveEndSparkSet = [NSMutableSet setWithCapacity:_laserEndSparkCount];
    self._active = false;
    self._timer = 0.0f;
    
    // init end particle list
    [self setupLaserEndParticleSet];
    
    // init spark particle list
    [self setupLaserEndSparkSet];
    
    return self;
}

//
//
//
- (void)setupLaserEndParticleSet {
    
    for (int i=0; i < _laserEndParticleCount; i++) {
        LaserEndParticle *laserEndParticle = [LaserEndParticle laserEndParticleWithLaserEndEmitter:self];
        [_laserEndParticleSet addObject:laserEndParticle];
        [_inactiveLaserEndParticleSet addObject:laserEndParticle];
    }
}

//
//
//
- (void)setupLaserEndSparkSet {
    
    for (int i=0; i < _laserEndSparkCount; i++) {
        LaserEndSpark *laserEndSpark = [LaserEndSpark laserEndSparkWithLaserEndEmitter:self];
        [_laserEndSparkSet addObject:laserEndSpark];
        [_inactiveEndSparkSet addObject:laserEndSpark];
    }
}

//
//
//
- (int)activate {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // else set to active
    _active = true;
    _timer = _spawnSparkInterval; // so we immediately spawn the first guy on the first update
    
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
    
    // deactivate
    _active = false;
    
    // tell all particles to deactivate
    NSNumber *cleanup = [NSNumber numberWithBool:true];
    [_laserEndParticleSet makeObjectsPerformSelector:@selector(deactivateAndCleanupWithObject:) withObject:cleanup];
    [_laserEndSparkSet makeObjectsPerformSelector:@selector(deactivateAndCleanupWithObject:) withObject:cleanup];
    
    return 0;
    
}

//
//
//
- (CubicBezierControlPoint *)controlPointToTrack { return [_laserEmitter lastControlPoint]; } 

//
//
//
- (void)deactivateLaserEndParticle:(LaserEndParticle *)laserEndParticle {
    [_inactiveLaserEndParticleSet addObject:laserEndParticle];
}

//
//
//
- (void)deactivateLaserEndSpark:(LaserEndSpark *)laserEndSpark {
    [_inactiveEndSparkSet addObject:laserEndSpark];
}

//
//
//
- (void)updateLaserEndParticles:(NSNumber *)elapsedTime {

    // update all of our active laser ends
    [_laserEndParticleSet makeObjectsPerformSelector:@selector(update:) withObject:elapsedTime];
    
    // activate an end particle as frequently as we possibly can
    LaserEndParticle *laserEndParticle = [_inactiveLaserEndParticleSet popItem];
    [laserEndParticle activateWithColorState:_laserEmitter._colorState];
}

//
//
//
- (void)updateLaserEndSparks:(NSNumber *)elapsedTime {
    
    // increment timer
    _timer += [elapsedTime floatValue];
    
    // if not yet time to spawn a particle, then bail
    if (_timer < _spawnSparkInterval) {
        return;
    }
    
    // spawn sparks
    for (int i=0; i < _laserSparkSpawnCount; i++) {
        
        // else activate a particle
        LaserEndSpark *laserEndSpark = [_inactiveEndSparkSet popItem];
        if (laserEndSpark == nil) {
            return; // if we couldn't get a new particle, then bail
        }
        
        // activate particle
        [laserEndSpark activateWithColorState:_laserEmitter._colorState];
    }
    
    // reset timer
    _timer = 0.0f;
}

//
// desc: we don't update our end particles until after
//       chipmunk has updated, becuase the laser might of
//       changes after processing collisions
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    
    if (!_active) {
        return;
    }
    
    // update particles
    [self updateLaserEndParticles:elapsedTime];
    [self updateLaserEndSparks:elapsedTime];
}

//
//
//
- (void)dealloc {
    self._laserEmitter = nil;
    self._laserEndParticleSet = nil;
    self._inactiveLaserEndParticleSet = nil;
    self._laserEndSparkSet = nil;
    self._inactiveEndSparkSet = nil;
    [super dealloc];
}


@end
