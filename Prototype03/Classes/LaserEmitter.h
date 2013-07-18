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
@class CubicBezier;
@class CubicBezierControlPoint;
@class LaserParticle;
@class LaserCollider;
@class LaserEndEmitter;
@class LaserStartEmitter;
@class LaserSwitchEmitter;
@class TriangleStripParticle;

//
// @interface LaserEmitter
//
@interface LaserEmitter : CCNode {
    
    // general junk
    unsigned int _laserEmitterId;
    unsigned int _collisionGroup;
    unsigned int _collisionLayerMask;
    bool _active;
    bool _stopping;
    ColorState _colorState;
    
    // cubic bezier junk
    CubicBezier *_cubicBezier;
    
    // replacing particles
    TriangleStripParticle *_triangleStripParticle;
    
    // laser end stuff
    LaserEndEmitter *_laserEndEmitter;
    LaserStartEmitter *_laserStartEmitter;
    LaserSwitchEmitter *_laserSwitchEmitter;
    
    // collision info
    NSMutableArray *_colliders;
    LaserCollider *_deactivatedColliderWithLowestIndex;    
}

//
// properties
//
@property (nonatomic, assign) unsigned int _laserEmitterId;
@property (nonatomic, assign) unsigned int _collisionGroup;
@property (nonatomic, assign) unsigned int _collisionLayerMask;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _stopping;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, retain) CubicBezier *_cubicBezier;
@property (nonatomic, retain) TriangleStripParticle *_triangleStripParticle;
@property (nonatomic, retain) LaserEndEmitter *_laserEndEmitter;
@property (nonatomic, retain) LaserStartEmitter *_laserStartEmitter;
@property (nonatomic, retain) LaserSwitchEmitter *_laserSwitchEmitter;
@property (nonatomic, retain) NSMutableArray *_colliders;
@property (nonatomic, assign) LaserCollider *_deactivatedColliderWithLowestIndex;

//
// static functions
//
+ (id)laserEmitter;

//
// init stuff
//
- (id)init;
- (NSMutableArray *)createColliders;

//
// setters/getters
//
- (void)setCollisionGroup:(unsigned int)collisionGroup;
- (void)setCollisionLayerMask:(unsigned int)collisionLayerMask;
- (void)resetToPoint:(CGPoint)point;
- (CGPoint)origin;
- (void)setOrigin:(CGPoint)origin;
- (void)setTarget:(CGPoint)target;
- (void)setOscillateType:(OscillateType)oscillateType;
- (void)setRandomOscillateType;
- (OscillateType)oscillateType;
- (CubicBezierControlPoint *)firstControlPoint;
- (CubicBezierControlPoint *)lastControlPoint;

//
// activate/deactivate functions
//
- (int)activate;
- (int)deactivate;
- (void)stopLaserEmitter;

//
// color state stuff
//
- (int)switchToColorState:(ColorState)colorState forceSwitch:(bool)forceSwitch;

//
// update functions
//
- (void)update:(ccTime)elapsedTime;

//
// chipmunk callbacks
//
- (void)processBezierCollisions;
- (void)chipmunkUpdate:(NSNumber *)elapsedTime;
- (void)chipmunkDeactivatedCollider:(LaserCollider *)laserCollider;

//
// LaserSwitchEmitterDelegateProtocol
//
- (void)handleLaserSwitchEmitterDeactivated:(NSNotification *)notification;

//
// cleanup
//
- (void)dealloc;

@end
