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

//
// @interface FastAnimate
//
// desc: I ripped this off the internet, thought it would help with performance
//
@interface FastAnimate : CCActionInterval <NSCopying> {
	CCAnimation *_animation;
    ccTime _slice;
    ccTime _sliceTimer;
    int _currentFrameIndex;
}

//
// properties
//
@property (nonatomic, retain) CCAnimation *_animation;
@property (nonatomic, assign) ccTime _slice;
@property (nonatomic, assign) ccTime _sliceTimer;
@property (nonatomic, assign) int _currentFrameIndex;

//
// functions
//
+ (id)actionWithAnimation:(CCAnimation *)animation duration:(ccTime)duration;
+ (id)actionWithAnimation:(CCAnimation *)animation;
- (id)initWithAnimation:(CCAnimation *)animation duration:(ccTime)duration;
- (id)initWithAnimation:(CCAnimation *)animation;

@end