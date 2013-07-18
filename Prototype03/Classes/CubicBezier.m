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
#import "CubicBezier.h"
#import "CubicBezierControlPoint.h"
#import "LaserEmitter.h"
#import "NSArray+Extended.h"
#import "CCNode+Extended.h"
#import "LaserCollider.h"

//
//
//
static const bool _drawBezier = false;
static const int _segments = 10.0f;
static const float _step = 1.0f/10.0f;
static const float _controlPointOffsetVelocityDefault = 120.0f; // 120 pixels/second
static const float _controlPointOffsetVelocityFast = 240.0f;
static const float _controlPointOffsetVelocitySlow = 60.0f;

//
//
//
@implementation CubicBezier

//
// synthesize
//
@synthesize _laserEmitter;
@synthesize _origin;
@synthesize _target;
@synthesize _controlPoint01;
@synthesize _controlPoint02;
@synthesize _targetGoal;
@synthesize _controlPoint01Goal;
@synthesize _controlPoint02Goal;
@synthesize _originDirection;
@synthesize _targetDirection;
@synthesize _controlPoint01Direction;
@synthesize _controlPoint02Direction;
@synthesize _targetVelocity;
@synthesize _controlPoint01Velocity;
@synthesize _controlPoint02Velocity;
@synthesize _controlPointOffsetVelocity;
@synthesize _targetNormal;
@synthesize _controlPoint01Offset;
@synthesize _controlPoint02Offset;
@synthesize _normal01;
@synthesize _normal02;
@synthesize _distance01;
@synthesize _distance02;
@synthesize _maxDistance01;
@synthesize _maxDistance02;
@synthesize _oscillateType;
@synthesize _isDirty;
@synthesize _length;
@synthesize _controlPoints;
@synthesize _active;

//
//
//
+ (id)cubicBezierWithLaserEmitter:(LaserEmitter *)laserEmitter {
    CubicBezier *cubicBezier = [[CubicBezier alloc] initWithLaserEmitter:laserEmitter];
    return [cubicBezier autorelease];
}

//
//
//
+ (int)getSegments {
    return _segments;
}

//
//
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter {
    self = [super init];
    
    // init properties
    self._laserEmitter = laserEmitter;
    self._origin = ccp(0.0f, 0.0f);
    self._target = ccp(0.0f, 0.0f);
    self._controlPoint01 = ccp(0.0f, 0.0f);
    self._controlPoint02 = ccp(0.0f, 0.0f);
    self._targetGoal = ccp(0.0f, 0.0f);
    self._controlPoint01Goal = ccp(0.0f, 0.0f);
    self._controlPoint02Goal = ccp(0.0f, 0.0f);
    self._originDirection = ccp(0.0f, 0.0f);
    self._targetDirection = ccp(0.0f, 0.0f);
    self._controlPoint01Direction = ccp(0.0f, 0.0f);
    self._controlPoint02Direction = ccp(0.0f, 0.0f);
    self._targetVelocity = 350.0f;
    self._controlPoint01Velocity = 200.0f;
    self._controlPoint02Velocity = 200.0f;
    self._controlPointOffsetVelocity = _controlPointOffsetVelocityDefault;
    self._targetNormal = ccp(0.0f, 1.0f);
    self._controlPoint01Offset = ccp(0.0f, 0.0f);
    self._controlPoint02Offset = ccp(0.0f, 0.0f);
    self._normal01 = ccp(0.0f, 0.0f);
    self._normal02 = ccp(0.0f, 0.0f);
    self._distance01 = 0.0f;
    self._distance02 = 0.0f;
    self._maxDistance01 = 25.0f;
    self._maxDistance02 = -25.0f;
    self._oscillateType = kOscillateTypeNormal;
    self._isDirty = true;
    self._length = 0.0f;
    self._controlPoints = nil;
    self._active = false;
    
    // init CCNode base class variables
    [self scheduleUpdate];
    
    // init control points
    [self initControlPoints];
    
    return self;
}

//
//
//
- (void)initControlPoints {
    
    self._controlPoints = [NSMutableArray arrayWithCapacity:_segments];
    
    for (int i=0; i < _segments; i++) {
        CubicBezierControlPoint *controlPoint = [CubicBezierControlPoint cubicBezierControlPoint];
        [_controlPoints addObject:controlPoint];
    }
}

//
//
//
- (void)resetToPoint:(CGPoint)point {
    _isDirty = true;
    _origin = point;
    _target = point;
    _controlPoint01 = point;
    _controlPoint02 = point;
    _controlPoint01Offset = point;
    _controlPoint02Offset = point;
    _targetGoal = point;
    _controlPoint01Goal = point;
    _controlPoint02Goal = point;
    
    // reset directions
    _controlPoint01Direction = ccp(0.0f, 0.0f);
    _controlPoint02Direction = ccp(0.0f, 0.0f);
    _targetDirection = ccp(0.0f, 0.0f);
    
    // reset length
    _length = 0.0f;
    
    // reset all control points to origin
    for (CubicBezierControlPoint *controlPoint in _controlPoints) {
        controlPoint._position = point;
    }
}

//
//
//
- (CGPoint)origin { return _origin; }

//
//
//
- (int)setOrigin:(CGPoint)origin {

    // only tell bezier to refresh on substantial changes
    if (ccpDistance(origin, _origin) >= 2.0f) {
        _isDirty = true;
    }
        
    _origin = origin;

    return 0;
}

//
//
//
- (int)setTarget:(CGPoint)target {
    [self setTarget:target recalcDirection:true];
    return 0;
}

//
//
//
- (int)setTarget:(CGPoint)target recalcDirection:(bool)recalcDirection {
    if (ccpDistance(target, _target) >= 2.0f) {
        _isDirty = true;
    }
    
    _target = target;
        
    // make sure none of the control points are ahead of the target
    float targetDistance = ccpDistance(_origin, _target);
    float controlPoint01Distance = ccpDistance(_origin, _controlPoint01);
    float controlPoint02Distance = ccpDistance(_origin, _controlPoint02);
    
    // scale this back to match target distance if we are too long
    if (controlPoint01Distance > targetDistance) {
        CGPoint normal = ccpNormalize(ccpSub(_controlPoint01, _origin));
        _controlPoint01 = ccpAdd(_origin, ccpMult(normal, targetDistance));
    }
    
    // scale this back to match target distance if we are too long
    if (controlPoint02Distance > targetDistance) {
        CGPoint normal = ccpNormalize(ccpSub(_controlPoint02, _origin));
        _controlPoint02 = ccpAdd(_origin, ccpMult(normal, targetDistance));
    }
    
    // if we should recalc the direction
    if (recalcDirection) {
        [self setTargetGoal:_targetGoal];
    }

    return 0;
}

//
//
//
- (int)setControlPoint01:(CGPoint)controlPoint01 {
    if (ccpDistance(controlPoint01, _controlPoint01) >= 2.0f) {
        _isDirty = true;
    }
    
    _controlPoint01 = controlPoint01;
    return 0;
}

//
//
//
- (int)setControlPoint02:(CGPoint)controlPoint02 {
    if (ccpDistance(controlPoint02, _controlPoint02) >= 2.0f) {
        _isDirty = true;
    }
    
    _controlPoint02 = controlPoint02;
    return 0;
}

//
//
//
- (void)setTargetGoal:(CGPoint)targetGoal {
    _targetGoal = targetGoal;
    
    // recalc target direction
    _targetDirection = ccp(0.0f, 0.0f);
    if (CGPointEqualToPoint(_targetGoal, _target) == NO) {
        _targetDirection = ccpNormalize(ccpSub(_targetGoal, _target));
    }
    
    // calculate new control points
    [self recalcControlPointGoals];
}

//
//
//
- (void)recalcControlPointGoals {
    // calculate new control points
    CGPoint midPoint = ccpMidpoint(_targetGoal, _origin);
    _controlPoint01Goal = ccpMidpoint(midPoint, _origin);
    _controlPoint02Goal = ccpMidpoint(midPoint, _targetGoal);
    
    // recalc control point 1 direction
    _controlPoint01Direction = ccp(0.0f, 0.0f);
    if (CGPointEqualToPoint(_controlPoint01Direction, _controlPoint01) == NO) {
        _controlPoint01Direction = ccpNormalize(ccpSub(_controlPoint01Goal, _controlPoint01));
    }
    
    // recalc control point 2 direction
    _controlPoint02Direction = ccp(0.0f, 0.0f);
    if (CGPointEqualToPoint(_controlPoint02Goal, _controlPoint02) == NO) {
        _controlPoint02Direction = ccpNormalize(ccpSub(_controlPoint02Goal, _controlPoint02));
    }
}

//
//
//
- (void)recalcControlPointOffsetsWithElapsedTime:(ccTime)elapsedTime {
    
    // recalc normals
    _normal01 = ccpNormalize(ccpPerp(ccpSub(_target, _controlPoint01)));
    _normal02 = ccpNormalize(ccpPerp(ccpSub(_controlPoint02, _origin)));
    
    // add delta's to distance
    float delta = elapsedTime * _controlPointOffsetVelocity;
    
    if (_maxDistance01 <= 0.0f) {
        _distance01 -= delta;
        _distance02 += delta;
    }
    else {
        _distance01 += delta;
        _distance02 -= delta;
    }
    
    // if we need to swap cause we hit a max
    if (abs(_distance01) >= abs(_maxDistance01) || abs(_distance02) >= abs(_maxDistance02)) {
        _distance01 = _maxDistance01;
        _distance02 = _maxDistance02;
        _maxDistance01 *= -1;
        _maxDistance02 *= -1;
    }
    
    // apply modifier to control points
    _controlPoint01Offset = ccpAdd(_controlPoint01, ccpMult(_normal01, _distance01));
    _controlPoint02Offset = ccpAdd(_controlPoint02, ccpMult(_normal02, _distance02));
    _isDirty = true;
}

//
//
//
- (void)setOscillateType:(OscillateType)oscillateType {
    _oscillateType = oscillateType;
    
    switch (_oscillateType) {
        case kOscillateTypeNormal:  _controlPointOffsetVelocity = _controlPointOffsetVelocityDefault; break;
        case kOscillateTypeFast:    _controlPointOffsetVelocity = _controlPointOffsetVelocityFast; break;
        case kOscillateTypeSlow:    _controlPointOffsetVelocity = _controlPointOffsetVelocitySlow; break;
        default: break;
    }
}

//
//
//
- (int)activate {
    
    // if already active, don't reactivate
    if (_active)
        return 1;

    // say we are active
    _active = true;
    self.visible = true;
    [_laserEmitter addChild:self];
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already deactivated
    if (!_active)
        return 1;
    
    _active = false;
    [self removeFromParentAndCleanup:false];
    return 0;
}

//
//
//
- (CGPoint)getPointAt:(float)t {

    // pre calc and cache as many values as we can
    // cubic bezier formulat is
    // B(t) = (1-t)^3*P0 + 3(1-t)^2*t*P1 + 3(1-t)*t^2*P2 + t^3*P3
    float one_minus_t = 1-t;
    float p0_mult = powf(one_minus_t, 3.0f);
    float p1_mult = 3 * powf(one_minus_t, 2.0f) * t;
    float p2_mult = 3 * one_minus_t * powf(t, 2.0f);
    float p3_mult = powf(t, 3.0f);
    
    // calc point
    CGPoint point;
    point.x = p0_mult * _origin.x + p1_mult * _controlPoint01Offset.x + p2_mult * _controlPoint02Offset.x + p3_mult * _target.x;
    point.y = p0_mult * _origin.y + p1_mult * _controlPoint01Offset.y + p2_mult * _controlPoint02Offset.y + p3_mult * _target.y;
    
    // return point
    return point;
}

//
// desc: manually set length and force it to keep the same control points
//
- (int)truncateToLength:(float)length {
    _length = length;
    _isDirty = false;
    return 0;
}

//
// desc: only here to satisfy the protocol stuff.
//       this just truncates objects that have
//       gone pase the length
//
- (int)truncateObjects:(NSArray *)objectList {
    
    // these should be sorted so the ones at the end
    // have traveled the farthest distance, so we start
    // there and break out once we don't need to truncate
    // any more
    for (int i=[objectList count]-1; i >= 0; i--) {
        LaserCollider *object = [objectList objectAtIndex:i];
        
        // the rest below these should all be less than the length
        if (object._distanceTraveled <= _length) {
            break;
        }
        
        // deactiveat object
        [object deactivate];
    }
    
    return 0;
}

//
//
//
- (int)recalcControlPoints {
    
    // if these aren't dirty, then bail
    if (!_isDirty) {
        return 1;
    }
    
    // say points are no longer dirty, they are uber clean
    _isDirty = false;
    
    // for tracking stuff in the loop
    CubicBezierControlPoint *controlPoint = nil;
    CubicBezierControlPoint *prevControlPoint = nil;
    float currentStep = 0.0f;
    
    // recalc each point
    for (int i=0; i < _segments; i++) {
        
        // set prev control point
        prevControlPoint = controlPoint;
        
        // get next control point
        controlPoint = [_controlPoints objectAtIndex:i];
        
        // calc control point
        controlPoint._position = [self getPointAt:currentStep];
        
        // increment step
        currentStep += _step;
        
        // calc distance and normal traveled to this point
        if (prevControlPoint) {
            CGPoint delta = ccpSub(controlPoint._position, prevControlPoint._position);
            _length += ccpLength(delta);
            prevControlPoint._normal = ccpNormalize(delta);
        }
        // else this is the first control point, so reset the length
        else { 
            _length = 0.0f;
        }
        
        // update distance
        controlPoint._distance = _length;
    }
    
    // reset target normal, use the direction of the second to last control point
    // the very last control point won't have a normal cause it doesn't have a
    // control point in front of it to point to
    controlPoint._normal = _targetNormal;
    _targetNormal = prevControlPoint._normal;
    
    return 0;
}

//
//
//
- (int)recalcPathObjects:(NSArray *)objectList {
        
    // refresh control points if we need to
    [self recalcControlPoints];
    
    // init current control point
    int controlPointIndex = 1;
    CubicBezierControlPoint *controlPoint = [_controlPoints objectAtIndex:controlPointIndex];
    CubicBezierControlPoint *prevControlPoint = [_controlPoints objectAtIndex:controlPointIndex-1];
    
    // place objects along path
    for (int i=0; i < [objectList count]; i++) {
        
        // get object to place on bezier path
        LaserCollider *object = [objectList objectAtIndex:i];
        
        // if we have gone past the end, then deactivate this object
        if (object._distanceTraveled > _length) {
            [object deactivate];
            continue;
        }
        
        // find the next control point for this guy
        while (object._distanceTraveled > controlPoint._distance) {
            
            // move to next control point
            controlPointIndex++;
                        
            // get next control point
            prevControlPoint = controlPoint;
            controlPoint = [_controlPoints objectAtIndex:controlPointIndex];
            
        }
        
        // assume distance traveled is to this current point
        CGPoint newPosition = controlPoint._position;
        
        // if it's not at this control point, then backtrack
        // to find it's position between this and the previous
        // control point
        if (object._distanceTraveled != controlPoint._distance) {
            
            // calc new position
            float deltaDistance = object._distanceTraveled - prevControlPoint._distance;
            newPosition = ccpAdd(prevControlPoint._position, ccpMult(prevControlPoint._normal, deltaDistance));
        }
        
        // set new position
        [object updatePosition:newPosition];
    }
    
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    CGPoint newPosition;
        
    // update target
    newPosition = [self translatePoint:_target
                                toGoal:_targetGoal
                          withVelocity:_targetVelocity
                           elapsedTime:elapsedTime
                             direction:_targetDirection];
    [self setTarget:newPosition recalcDirection:false];
    
    // update control point 01
    newPosition = [self translatePoint:_controlPoint01
                                toGoal:_controlPoint01Goal
                          withVelocity:_controlPoint01Velocity
                           elapsedTime:elapsedTime
                             direction:_controlPoint01Direction];
    [self setControlPoint01:newPosition];
    
    // update control point 02
    newPosition = [self translatePoint:_controlPoint02
                                toGoal:_controlPoint02Goal
                          withVelocity:_controlPoint02Velocity
                           elapsedTime:elapsedTime
                             direction:_controlPoint02Direction];
    [self setControlPoint02:newPosition];
    
    // recalc control point offsets
    [self recalcControlPointOffsetsWithElapsedTime:elapsedTime];
}

//
//
//
- (void)draw {
    
    // if we aren't drawing the bezier line, then bail
    if (!_drawBezier)
        return;
    
    glEnable(GL_LINE_SMOOTH);
    glLineWidth(1);
    glColor4ub(0, 50, 255, 255);
    
    CGPoint origin = [self convertToNodeSpace:_origin];
    CGPoint controlPoint01 = [self convertToNodeSpace:_controlPoint01Offset];
    CGPoint controlPoint02 = [self convertToNodeSpace:_controlPoint02Offset];
    CGPoint target = [self convertToNodeSpace:_target];
    
    ccDrawCubicBezier(origin, controlPoint01, controlPoint02, target, _segments);
    
    // draw control points we calculated
    glColor4ub(255, 50, 0, 255);
    for (int i=0; i < [_controlPoints count]; i++) {
        CubicBezierControlPoint *controlPoint = [_controlPoints objectAtIndex:i];
        ccDrawPoint([self convertToNodeSpace:controlPoint._position]);
    }
    
    // restore original values
    glDisable(GL_LINE_SMOOTH);
    glLineWidth(1);
    glColor4ub(255, 255, 255, 255);
    glPointSize(1);
}

//
//
//
- (void)dealloc {
    self._controlPoints = nil;
    [super dealloc];
}

@end
