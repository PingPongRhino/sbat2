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
#import "PathSegment.h"
#import "cocos2d.h"

//
// @implementation PathSegment
//
@implementation PathSegment

//
// synthesize
//
@synthesize _start;
@synthesize _end;

//
//
//
+ (id)pathSegment {
    PathSegment *pathSegment = [[PathSegment alloc] init];
    return [pathSegment autorelease];
}

//
//
//
+ (id)pathSegmentWithPathSegment:(PathSegment *)pathSegment {
    PathSegment *newPathSegment = [[PathSegment alloc] init];
    newPathSegment._start = pathSegment._start;
    newPathSegment._end = pathSegment._end;
    return [newPathSegment autorelease];
}

//
// functions
//
- (id)init {
    self = [super init];
    self._start = ccp(0.0f, 0.0f);
    self._end = ccp(0.0f, 0.0f);
    return self;
}

//
//
//
- (bool)isPointAlongSharedAxis:(CGPoint)point {
    
    float sharedAxisValue = 0.0f;
    float pointAxisValue = 0.0f;
    
    // figure out the shared axis
    if (_start.x == _end.x) {
        sharedAxisValue = _start.x;
        pointAxisValue = point.x;
    }
    // else assume it is the y axis
    else {
        sharedAxisValue = _start.y;
        pointAxisValue = point.y;
    }
    
    // if they are reasonably close, then assume it is on the
    // same axis
    float diff = fabsf(sharedAxisValue - pointAxisValue);
    if (diff <= 1.0f) {
        return true;
    }
    
    return false;
}

//
//
//
- (void)dealloc {
    [super dealloc];
}


@end
