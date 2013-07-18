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
#import "LaserEmitter.h"
#import "StageLayer.h"
#import "CubicBezier.h"
#import "LaserEndEmitter.h"
#import "LaserStartEmitter.h"
#import "LaserSwitchEmitter.h"
#import "LaserCollider.h"
#import "NSMutableArray+Extended.h"
#import "TriangleStripParticle.h"
#import "NotificationStrings.h"

//
// globals
//
static int _currentLaserEmitterId = 0;
static const int _colliderCount = 40;

//
// @implementation LaserEmitter
//
@implementation LaserEmitter

//
// synthesize
//
@synthesize _laserEmitterId;
@synthesize _collisionGroup;
@synthesize _collisionLayerMask;
@synthesize _active;
@synthesize _stopping;
@synthesize _colorState;
@synthesize _cubicBezier;
@synthesize _triangleStripParticle;
@synthesize _laserEndEmitter;
@synthesize _laserStartEmitter;
@synthesize _laserSwitchEmitter;
@synthesize _colliders;
@synthesize _deactivatedColliderWithLowestIndex;

//
//
//
+ (id)laserEmitter {
    LaserEmitter *laserEmitter = [[LaserEmitter alloc] init];
    return [laserEmitter autorelease];
}

//
//
//
- (id)init {
    self = [super init];
    
    // get id
    self._laserEmitterId = _currentLaserEmitterId;
    _currentLaserEmitterId++;
    
    // set properties
    self._collisionGroup = GROUP_LASER_EMITTERS + _laserEmitterId;
    self._collisionLayerMask = LAYER_MASK_ALL;
    self._active = false;
    self._stopping = false;
    self._colorState = kColorStateDefault;
    self._cubicBezier = [CubicBezier cubicBezierWithLaserEmitter:self];
    self._triangleStripParticle = [TriangleStripParticle triangleStripParticleWithLaserEmitter:self];
    self._laserEndEmitter = [LaserEndEmitter laserEndEmitterWithLaserEmitter:self];
    self._laserStartEmitter = [LaserStartEmitter laserStartEmitterWithLaserEmitter:self];
    self._laserSwitchEmitter = [LaserSwitchEmitter laserSwitchEmitterWithLaserEmitter:self];
    self._colliders = [self createColliders];
    self._deactivatedColliderWithLowestIndex = nil;
    
    // init parent propertiess
    [self scheduleUpdate];
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleLaserSwitchEmitterDeactivated:)
                                                 name:kNotificationLaserSwitchEmitterDeactivated
                                               object:_laserSwitchEmitter];
    
    return self;
}

//
//
//
- (NSMutableArray *)createColliders {
    NSMutableArray *colliders = [NSMutableArray array];
    for (int i=0; i < _colliderCount; i++) {
        LaserCollider *laserCollider = [LaserCollider laserColliderWithLaserEmitter:self index:i];
        [colliders addObject:laserCollider];
    }
    
    return colliders;
}

//
//
//
- (void)setCollisionGroup:(unsigned int)collisionGroup {
    _collisionGroup = collisionGroup;
    for (int i=0; i < _colliderCount; i++) {
        LaserCollider *collider = [_colliders objectAtIndex:i];
        if (collider._shape) {
            collider._shape->group = _collisionGroup;
        }
    }
}

//
//
//
- (void)setCollisionLayerMask:(unsigned int)collisionLayerMask {
    _collisionLayerMask = collisionLayerMask;
    for (int i=0; i < _colliderCount; i++) {
        LaserCollider *collider = [_colliders objectAtIndex:i];
        if (collider._shape) {
            collider._shape->layers = _collisionLayerMask;
        }
    }
}

//
//
//
- (void)resetToPoint:(CGPoint)point {
    self.position = point;
    [_cubicBezier resetToPoint:point];
}

//
//
//
- (CGPoint)origin {
    return [_cubicBezier origin];
}

//
//
//
- (void)setOrigin:(CGPoint)origin {
    self.position = origin;
    [_cubicBezier setOrigin:origin];
}

//
//
//
- (void)setTarget:(CGPoint)target {
    // set target goal
    [_cubicBezier setTargetGoal:target];
}

//
//
//
- (void)setOscillateType:(OscillateType)oscillateType {
    [_cubicBezier setOscillateType:oscillateType];
}

//
//
//
- (void)setRandomOscillateType {
    [_cubicBezier setOscillateType:(arc4random() % (kOscillateTypeSlow + 1))];
}

//
//
//
- (OscillateType)oscillateType { return _cubicBezier._oscillateType; }

//
//
//
- (CubicBezierControlPoint *)firstControlPoint { return [_cubicBezier._controlPoints objectAtIndex:0]; }
- (CubicBezierControlPoint *)lastControlPoint { return [_cubicBezier._controlPoints lastObject]; }

//
//
//
- (int)activate {
    
    // if already activated, then don't reactivate
    if (_active) {
        return 1;
    }
    
    // set to active
    _active = true;
    _stopping = false;
    
    // add to scene
    [[StageLayer sharedStageLayer] addChild:self];
    
    // activate bezier
    [_cubicBezier activate];
    
    // activate triangle strip
    [_triangleStripParticle activate];
    [_triangleStripParticle switchToColorState:_colorState];
    
    // activate laser hit emitter
    [_laserEndEmitter activate];
    [_laserStartEmitter activate];
        
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already deactivated, then don't deactivate again
    if (!_active) {
        return 1;
    }
        
    // set to inactive
    _active = false;
    
    // deactive bezier
    [_cubicBezier deactivate];
    
    // deacitvate triangle strip
    [_triangleStripParticle deactivate];
    
    // deactivate laser emitter
    [_laserEndEmitter deactivate];
    [_laserStartEmitter deactivate];
    
    // deactivate all the colliders
    for (int i=0; i < [_colliders count]; i++) {
        LaserCollider *laserCollider = [_colliders objectAtIndex:i];
        [laserCollider deactivate];
    }
    
    // remove from parent
    [self removeFromParentAndCleanup:false];
    
    // notify delegate
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaserEmitterDeactivated object:self];
    return 0;
}

//
//
//
- (void)stopLaserEmitter {
    
    if (_stopping) {
        return;
    }
    
    _stopping = true;
    
    // force reset switch emitter
    [_laserSwitchEmitter deactivate];
    [_laserSwitchEmitter activate];
    
    // deactivate laser emitter
    [_triangleStripParticle deactivate];
    [_laserEndEmitter deactivate];
    [_laserStartEmitter deactivate];
    
    // deactivate all the colliders
    for (int i=0; i < [_colliders count]; i++) {
        LaserCollider *laserCollider = [_colliders objectAtIndex:i];
        [laserCollider deactivate];
    }
}

//
//
//
- (int)switchToColorState:(ColorState)colorState forceSwitch:(bool)forceSwitch {
    
    if (forceSwitch) {
        [_laserSwitchEmitter deactivate];
    }
    
    // if still in the middle of a switch, don't let them switch
    if (_laserSwitchEmitter._active) {
        return -1; // let them know we didn't switch colors
    }
    
    // make sure we aren't switching to the same color
    if (_colorState == colorState) {
        return -2;
    }
    
    // start off the emitter switch emitter, this needs to happend
    // before we switch the laser emitter, because it will use _colorState
    // to determine which color to show, and we want the previoius color
    // to break away, not the new one
    [_laserSwitchEmitter activate];
    
    // switch color state
    _colorState = colorState;
    
    // reset laser to origin
    [self resetToPoint:self.position];
    
    // switch triangle particle color
    // don't worry about switching particles, sense they are constantly
    // popping in and out, we reset their frame to the current self._colorState
    // whenever they get activated
    [_triangleStripParticle switchToColorState:colorState];
    
    // success
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    if (_stopping) {
        return;
    }
    
    // update bezier with our colliders, we update the particles
    // on the bezier after chipmunk has done it's update
    [_cubicBezier recalcPathObjects:_colliders];
}

//
//
//
- (void)processBezierCollisions {
    
    // if no colliders where destroyed, then do nothing
    if (_deactivatedColliderWithLowestIndex == nil) {
        return;
    }
        
    // for easier access
    LaserCollider *laserCollider = _deactivatedColliderWithLowestIndex;
    
    // if this isn't the last collider in the list
    if (laserCollider._index != 0) {
        laserCollider = [_colliders objectAtIndex:laserCollider._index-1];
    
        // so now we need to set the target and control point
        [_cubicBezier setTarget:laserCollider._body->p];
        [_cubicBezier truncateToLength:laserCollider._distanceTraveled];        
    }
    // else set it to it's origin, cause we are out of colliders
    else {
        [_cubicBezier setTarget:_cubicBezier._origin];
        [_cubicBezier truncateToLength:0.0f];
    }
    
    // reset deactived collider with lowest index
    _deactivatedColliderWithLowestIndex = nil;
}

//
//
//
- (void)chipmunkUpdate:(NSNumber *)elapsedTime {
    
    if (!_active || _stopping) {
        return;
    }
    
    // process our bezier collisions and adjust our curve
    [self processBezierCollisions];
    
    // update our laser end
    [_laserEndEmitter chipmunkUpdate:elapsedTime];
    [_laserStartEmitter chipmunkUpdate:elapsedTime];
}

//
//
//
- (void)chipmunkDeactivatedCollider:(LaserCollider *)laserCollider {
    
    if (_deactivatedColliderWithLowestIndex == nil) {
        _deactivatedColliderWithLowestIndex = laserCollider;
        return;
    }
    
    if (laserCollider._index < _deactivatedColliderWithLowestIndex._index) {
        _deactivatedColliderWithLowestIndex = laserCollider;
    }
}

//
//
//
- (void)handleLaserSwitchEmitterDeactivated:(NSNotification *)notification {
    if (_stopping) {
        [self deactivate];
    }
}

//
//
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._cubicBezier = nil;
    self._triangleStripParticle = nil;
    self._laserEndEmitter = nil;
    self._laserStartEmitter = nil;
    self._laserSwitchEmitter = nil;
    self._colliders = nil;
    self._deactivatedColliderWithLowestIndex = nil;
    [super dealloc];
}


@end
