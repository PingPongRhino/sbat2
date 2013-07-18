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
#import "cocos2d.h"
#import "defines.h"

//
// forward delcarations
//
@class LaserEmitter;
@class CubicBezierControlPoint;

//
// @interface CubicBezier
//
@interface CubicBezier : CCNode {
    
    // parent laser emitter
    LaserEmitter *_laserEmitter;
    
    // current points
    CGPoint _origin;
    CGPoint _target;
    CGPoint _controlPoint01;
    CGPoint _controlPoint02;
    
    // goal positions
    CGPoint _targetGoal;
    CGPoint _controlPoint01Goal;
    CGPoint _controlPoint02Goal;
    
    // initial direction to goal
    CGPoint _originDirection;
    CGPoint _targetDirection;
    CGPoint _controlPoint01Direction;
    CGPoint _controlPoint02Direction;
    
    // point velocity
    float _targetVelocity;
    float _controlPoint01Velocity;
    float _controlPoint02Velocity;
    float _controlPointOffsetVelocity;
    
    // target tracking stuff
    CGPoint _targetNormal;
    
    // for animating the control points
    CGPoint _controlPoint01Offset;
    CGPoint _controlPoint02Offset;
    CGPoint _normal01;
    CGPoint _normal02;
    float _distance01;
    float _distance02;
    float _maxDistance01;
    float _maxDistance02;
    OscillateType _oscillateType;
    
    // tracking length and control points
    bool _isDirty;
    float _length;
    NSMutableArray *_controlPoints;
    
    // if we are active
    bool _active;
}

//
// properties
//
@property (nonatomic, assign) LaserEmitter *_laserEmitter;
@property (nonatomic, assign) CGPoint _origin;
@property (nonatomic, assign) CGPoint _target;
@property (nonatomic, assign) CGPoint _controlPoint01;
@property (nonatomic, assign) CGPoint _controlPoint02;
@property (nonatomic, assign) CGPoint _targetGoal;
@property (nonatomic, assign) CGPoint _controlPoint01Goal;
@property (nonatomic, assign) CGPoint _controlPoint02Goal;
@property (nonatomic, assign) CGPoint _originDirection;
@property (nonatomic, assign) CGPoint _targetDirection;
@property (nonatomic, assign) CGPoint _controlPoint01Direction;
@property (nonatomic, assign) CGPoint _controlPoint02Direction;
@property (nonatomic, assign) CGPoint _controlPoint01Offset;
@property (nonatomic, assign) CGPoint _controlPoint02Offset;
@property (nonatomic, assign) CGPoint _normal01;
@property (nonatomic, assign) CGPoint _normal02;
@property (nonatomic, assign) float _distance01;
@property (nonatomic, assign) float _distance02;
@property (nonatomic, assign) float _maxDistance01;
@property (nonatomic, assign) float _maxDistance02;
@property (nonatomic, assign) float _targetVelocity;
@property (nonatomic, assign) float _controlPoint01Velocity;
@property (nonatomic, assign) float _controlPoint02Velocity;
@property (nonatomic, assign) float _controlPointOffsetVelocity;
@property (nonatomic, assign) CGPoint _targetNormal;
@property (nonatomic, assign) OscillateType _oscillateType;
@property (nonatomic, assign) bool _isDirty;
@property (nonatomic, assign) float _length;
@property (nonatomic, retain) NSMutableArray *_controlPoints;
@property (nonatomic, assign) bool _active;

//
// static functions
//
+ (id)cubicBezierWithLaserEmitter:(LaserEmitter *)laserEmitter;
+ (int)getSegments;

//
// initialization
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter;
- (void)initControlPoints;

//
// setter/getters
//
- (void)resetToPoint:(CGPoint)point;
- (CGPoint)origin;
- (int)setOrigin:(CGPoint)origin;
- (int)setTarget:(CGPoint)target;
- (int)setTarget:(CGPoint)target recalcDirection:(bool)recalcDirection;
- (int)setControlPoint01:(CGPoint)controlPoint01;
- (int)setControlPoint02:(CGPoint)controlPoint02;
- (void)setTargetGoal:(CGPoint)targetGoal;
- (void)recalcControlPointGoals;
- (void)recalcControlPointOffsetsWithElapsedTime:(ccTime)elapsedTime;
- (void)setOscillateType:(OscillateType)oscillateType;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// cubic bezier calculation stuff
//
- (int)truncateToLength:(float)length;
- (int)truncateObjects:(NSArray *)objectList;
- (int)recalcControlPoints;
- (int)recalcPathObjects:(NSArray *)objectList;

//
// update and draw stuff
//
- (void)update:(ccTime)elapsedTime;
- (void)draw;

//
// cleanup
//
- (void)dealloc;

@end
