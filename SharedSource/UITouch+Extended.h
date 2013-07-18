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

#import <Foundation/Foundation.h>

@interface UITouch (Extended)
	
//
// desc: returns the displacement of the touch from it's previous position
//
// params: touch[in] - touch to calculate displacement for
//
// returns: returns the displacement of the touch
//
- (CGPoint)displacementOfTouch;

//
// desc: converts UITouch screen coordinates to world coordinates
//
// returns: returns where the touch happened in world coordinates
//
- (CGPoint)worldCoordinate;

//
// desc: converts prevoius location of the UITouch 
//       screen coordinates to world coordinates
//
// returns: returns where the previous touch happened in world coordinates
//
- (CGPoint)previousWorldCoordinate;

@end
