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
#import "LaserSwitchEmitter.h"
#import "LaserSwitchParticle.h"
#import "LaserEmitter.h"
#import "LaserCollider.h"
#import "NSMutableSet+Extended.h"
#import "NotificationStrings.h"

//
// static globals
//
static const ccTime _animationDelayStep = 0.025f; // how much to delay between kicking off animations

//
// @implementation LaserSwitchColorEmitter
//
@implementation LaserSwitchEmitter

//
// synthesize
//
@synthesize _laserEmitter;
@synthesize _laserSwitchParticles;
@synthesize _inactiveLaserSwitchParticles;
@synthesize _active;

//
//
//
+ (id)laserSwitchEmitterWithLaserEmitter:(LaserEmitter *)laserEmitter {
    LaserSwitchEmitter *laserSwitchEmitter = [[LaserSwitchEmitter alloc] initWithLaserEmitter:laserEmitter];
    return [laserSwitchEmitter autorelease];
}

//
//
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter {
    self = [super init];
    
    // init properties
    self._laserEmitter = laserEmitter;
    self._laserSwitchParticles = [NSMutableSet set];
    self._inactiveLaserSwitchParticles = [NSMutableSet set];
    self._active = false;

    return self;
}

//
//
//
- (LaserSwitchParticle *)inactiveLaserSwitchParticle {
    LaserSwitchParticle *laserSwitchParticle = [_inactiveLaserSwitchParticles popItem];
    if (!laserSwitchParticle) {
        laserSwitchParticle = [LaserSwitchParticle laserSwitchParticleWithLaserSwitchEmitter:self];
        [_laserSwitchParticles addObject:laserSwitchParticle];
    }
    
    return laserSwitchParticle;
}

//
//
//
- (int)activate {
    
    // if already active then bail
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
    
    // set delay timer
    ccTime animationDelayInterval = 0.0f;
    
    // track number of particles we activate
    int particlesActivatedCount = 0;
    
    // get laser colliders to draw split emitter along
    NSArray *laserColliders = _laserEmitter._colliders;
    
    // if too few colliders then bail
    if ([laserColliders count] <= 3) {
        [self deactivate];
        return 2;
    }
    
    // active particles based on current laser colliders
    for (int i=0; i < [laserColliders count]-2; i += 2) {
        
        LaserCollider *laserCollider01 = [laserColliders objectAtIndex:i];
        LaserCollider *laserCollider02 = [laserColliders objectAtIndex:i+2];
        
        // if either collider is deactivated, then bail
        if (!laserCollider01._active || !laserCollider02._active) {
            break; // we are done here
        }
        
        // get next two laser colliders
        CGPoint point01 = laserCollider01._body->p;
        CGPoint point02 = laserCollider02._body->p;
        
        // get spawn point
        CGPoint spawnPoint = ccpMidpoint(point01, point02);
        
        // get direction between these guys
        CGPoint direction = ccpNormalize(ccpSub(point02, point01));
        
        // get inactive particle and activate him
        LaserSwitchParticle *particle = [self inactiveLaserSwitchParticle];
        [particle activateWithAnimateDelayInterval:animationDelayInterval
                                        spawnPoint:spawnPoint
                                         direction:direction
                                        colorState:_laserEmitter._colorState];
        
        // increment activated particled counter
        particlesActivatedCount++;
        
        // increment animation delay interval
        animationDelayInterval += _animationDelayStep;
    }
    
    
    // if we didn't activate any particles then bail
    if (particlesActivatedCount <= 0) {
        [self deactivate];
        return 3;
    }
    
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
    
    // deactivate emitters
    [_laserSwitchParticles makeObjectsPerformSelector:@selector(deactivate)];
    
    // report to delegate we are done
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserSwitchEmitterDeactivated object:self];
    
    return 0;
}

//
//
//
- (void)deactivateLaserSwitchParticle:(LaserSwitchParticle *)laserSwitchParticle {
    [_inactiveLaserSwitchParticles addObject:laserSwitchParticle];
    
    // if we are active, and all our guys reported in, then deactivate
    if (_active && [_inactiveLaserSwitchParticles count] == [_laserSwitchParticles count]) {
        [self deactivate];
    }
}

//
//
//
- (void)dealloc {
    self._laserEmitter = nil;
    self._laserSwitchParticles = nil;
    self._inactiveLaserSwitchParticles = nil;
    [super dealloc];
}

@end
