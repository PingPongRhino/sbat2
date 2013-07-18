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
#import "CubicBezierControlPoint.h"
#import "cocos2d.h"

//
// @implementation CubicBezierControlPoint
//
@implementation CubicBezierControlPoint

//
// synthesize
//
@synthesize _position;
@synthesize _normal;
@synthesize _distance;

//
//
//
+ (id)cubicBezierControlPoint {
    CubicBezierControlPoint *cubicBezierControlPoint = [[CubicBezierControlPoint alloc] init];
    return [cubicBezierControlPoint autorelease];
}

//
//
//
+ (id)cubicBezierControlPointWithControlPoint:(CubicBezierControlPoint *)controlPoint {
    CubicBezierControlPoint *newControlPoint = [CubicBezierControlPoint cubicBezierControlPoint];
    newControlPoint._position = controlPoint._position;
    newControlPoint._normal = controlPoint._normal;
    newControlPoint._distance = controlPoint._distance;
    return newControlPoint;
}

//
//
//
- (id)init {
    self = [super init];
    
    // init properties
    self._position = ccp(0.0f, 0.0f);
    self._normal = ccp(0.0f, 0.0f);
    self._distance = 0.0f;
    
    return self;
}

//
//
//
- (void)dealloc {
    [super dealloc];
}

@end
