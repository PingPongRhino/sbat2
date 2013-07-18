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
#import "CCNode+Extended.h"

//
//
//
@implementation CCNode (Extended)

//
//
//
+ (CGPoint)convertPointPointsToPixels:(CGPoint)pointInPoints {
    
    if (CC_CONTENT_SCALE_FACTOR() == 1) {
		return pointInPoints;
    }
    
    return ccpMult(pointInPoints, CC_CONTENT_SCALE_FACTOR());
}

//
//
//
+ (CGRect)convertRectPointsToPixels:(CGRect)rectInPoints {
    return CC_RECT_POINTS_TO_PIXELS(rectInPoints);
}

//
//
//
- (CGPoint)translatePoint:(CGPoint)point 
                   toGoal:(CGPoint)goal
             withVelocity:(float)velocity
              elapsedTime:(ccTime)elapsedTime
                direction:(CGPoint)direction 
{    
    // if point is already at the goal, then just return the point
    if (CGPointEqualToPoint(point, goal) == YES)
        return point;
    
    // else move the point towards the goal
    float delta = elapsedTime * velocity;
    point = ccpAdd(point, ccpMult(direction, delta));
    
    // see if we went past our goal
    CGPoint directionToGoal = ccpSub(goal, point);
    float angle = ccpAngleSigned(directionToGoal, direction);
    if (angle < -1.0f || angle > 1.0f) {
        point = goal;
    }
    
    return point;
}

@end
