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

#import "UITouch+Extended.h"
#import "cocos2d.h"
#import "chipmunk.h"


@implementation UITouch (Extended)

//
// displacementOfTouch
//
- (CGPoint)displacementOfTouch {
	CGPoint prevLocation = [self previousLocationInView: [self view]];
	CGPoint location = [self locationInView: [self view]];
	CGPoint convertedPrevLocation = [[CCDirector sharedDirector] convertToGL:prevLocation];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
	CGPoint displacement = cpvsub(convertedLocation, convertedPrevLocation);
	return displacement;
}

//
// worldCoordinate
//
- (CGPoint)worldCoordinate {
	return [[CCDirector sharedDirector] convertToGL:[self locationInView:[self view]]];
}

//
//
//
- (CGPoint)previousWorldCoordinate {
    return [[CCDirector sharedDirector] convertToGL:[self previousLocationInView:[self view]]];
}


@end
