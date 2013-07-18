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
#import "BarrierManager.h"
#import "SoldierFactory.h"
#import "BarrierObject.h"
#import "chipmunk.h"

//
// static globals
//
static const float _rotationVelocity = 360.0f;

//
// @implementation BarrierManager
//
@implementation BarrierManager

//
// synthesize
//
@synthesize _soldierFactory;
@synthesize _barrierObject01;
@synthesize _barrierObject02;
@synthesize _active;
@synthesize _rotation;
@synthesize _rotationGoal;
@synthesize _rotationTraveled;
@synthesize _rotationGoalDistance;

//
//
//
+ (id)barrierManagerWithSoldierFactory:(SoldierFactory *)soldierFactory {
    BarrierManager *barrierManager = [[BarrierManager alloc] initWithSoldierFactory:soldierFactory];
    return [barrierManager autorelease];
}

//
//
//
- (id)initWithSoldierFactory:(SoldierFactory *)soldierFactory {
    self = [super init];
    
    // init properties
    self._soldierFactory = soldierFactory;
    self._barrierObject01 = [BarrierObject barrierObjectWithSoldierFactory:soldierFactory];
    self._barrierObject02 = [BarrierObject barrierObjectWithSoldierFactory:soldierFactory];
    self._active = false;
    self._rotation = 0.0f;
    self._rotationGoal = 0.0f;
    self._rotationTraveled = 0.0f;
    self._rotationGoalDistance = 0.0f;
    
    return self;
}

//
//
//
- (int)activateWithSpriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode chipmunkEnabled:(bool)chipmunkEnabled {
    
    // if already active then bail
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
    
    // set positions
    _barrierObject01._body->p = _soldierFactory._body->p;
    _barrierObject02._body->p = _soldierFactory._body->p;
    
    // sync goal rotation
    _rotationGoal = 90;
    _rotation = 90;
    _rotationTraveled = 0.0f;
    _rotationGoalDistance = 0.0f;
    
    // set initial rotation
    [self calcBarrierObjectRotation];
    
    // activate barriers
    [_barrierObject01 activateWithSpriteBatchNode:spriteBatchNode chipmunkEnabled:chipmunkEnabled];
    [_barrierObject02 activateWithSpriteBatchNode:spriteBatchNode chipmunkEnabled:chipmunkEnabled];
    
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
    
    // deactiavte
    _active = false;
    [_barrierObject01 deactivate];
    [_barrierObject02 deactivate];
    return 0;
}

//
//
//
- (void)switchToColorState:(ColorState)colorState {
    [_barrierObject01 switchToColorState:colorState];
    [_barrierObject02 switchToColorState:colorState];
}

//
//
//
- (void)explode {
    [_barrierObject01 explode];
    [_barrierObject02 explode];
}

//
//
//
- (void)setVertexZ:(float)vertexZ {
    float vertexZInPoints = vertexZ / CC_CONTENT_SCALE_FACTOR();
    _barrierObject01.vertexZ = vertexZInPoints;
    _barrierObject02.vertexZ = vertexZInPoints;
}

//
//
//
- (void)calcBarrierObjectRotation {
    
    // set barrier 1 rotation
    float barrierRotation = CC_DEGREES_TO_RADIANS(-(_rotation + 90.0f));
    cpBodySetAngle(_barrierObject01._body, barrierRotation);
    
    // set barrier 2 rotation
    barrierRotation = CC_DEGREES_TO_RADIANS(-(_rotation - 90.0f));
    cpBodySetAngle(_barrierObject02._body, barrierRotation);
}

//
//
//
- (float)calcGoalRotation {
    CGPoint direction = _soldierFactory._direction;
    _rotationGoal = CC_RADIANS_TO_DEGREES(ccpAngleSigned(direction, ccp(-1.0f, 0.0f)));
    
    // find shortest distance to our goal rotation from our current rotation
    CGPoint oldDirection = ccpRotateByAngle(ccp(-1.0f, 0.0f), ccp(0.0f, 0.0f), CC_DEGREES_TO_RADIANS(-_rotation));
    _rotationGoalDistance = CC_RADIANS_TO_DEGREES(ccpAngleSigned(direction, oldDirection));
    
    // reset distance traveled
    _rotationTraveled = 0.0f;
    
    return _rotationGoal;
}

//
//
//
- (void)updateRotation:(ccTime)elapsedTime {
    
    // else move towards goals
    float delta = elapsedTime * _rotationVelocity;
    
    // we are going forward
    if (_rotationGoalDistance >= 0.0f) {
        _rotation += delta;
        _rotationTraveled += delta;
        
        // if we completed rotating
        if (_rotationTraveled >= _rotationGoalDistance) {
            _rotation = _rotationGoal;
            return;
        }
        
        return;
    }
    
    // else we are going backwards
    _rotation -= delta;
    _rotationTraveled -= delta;
    
    // if we completed rotating
    if (_rotationTraveled <= _rotationGoalDistance) {
        _rotation = _rotationGoal;
    }
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if we are at correct rotation, then nothing to do
    if (_rotation == _rotationGoal) {
        return;
    }
    
    // update rotation
    [self updateRotation:elapsedTime];
    
    // update barrier object rotations
    [self calcBarrierObjectRotation];
}

//
//
//
- (void)dealloc {
    self._barrierObject01 = nil;
    self._barrierObject02 = nil;
    [super dealloc];
}

@end
