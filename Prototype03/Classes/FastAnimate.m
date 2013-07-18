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
#import "FastAnimate.h"

//
// @implementation FastAnimate
//
@implementation FastAnimate

//
// synthesize
//
@synthesize _animation;
@synthesize _slice;
@synthesize _sliceTimer;
@synthesize _currentFrameIndex;

//
//
//
+ (id)actionWithAnimation:(CCAnimation *)animation {
	return [[[self alloc] initWithAnimation:animation] autorelease];
}

//
//
//
+ (id)actionWithAnimation:(CCAnimation *)animation duration:(ccTime)duration {
    return [[[self alloc] initWithAnimation:animation duration:duration] autorelease];
}

//
//
//
- (id)initWithAnimation:(CCAnimation *)animation duration:(ccTime)duration {
	NSAssert(animation != nil, @"Animate: argument Animation must be non-nil");
    
	self = [super initWithDuration:duration];
    
    self._animation = animation;
    self._slice = 1.0f / [[animation frames] count];
    self._sliceTimer = 0.0f;
    self._currentFrameIndex = -1;
	
	return self;
}

//
//
//
- (id)initWithAnimation:(CCAnimation *)animation {
	NSAssert(animation != nil, @"Animate: argument Animation must be non-nil");
    
	self = [super initWithDuration:[[animation frames] count] * [animation delay]];
    
    self._animation = animation;
    self._slice = 1.0f / [[animation frames] count];
    self._sliceTimer = 0.0f;
    self._currentFrameIndex = -1;
	
	return self;
}

//
//
//
- (id)copyWithZone:(NSZone*)zone {
	return [[[self class] allocWithZone:zone] initWithAnimation:_animation];
}

//
//
//
- (void)dealloc {
	self._animation = nil;
	[super dealloc];
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    _sliceTimer += elapsedTime;
    if (_sliceTimer < _slice) {
        
        // make sure frame we got initial frame displayed
        if (_currentFrameIndex < 0 && _currentFrameIndex < [[_animation frames] count]) {
            _currentFrameIndex = 0;
            CCSprite *sprite = (CCSprite *)self.target;
            [sprite setDisplayFrame:[[_animation frames] objectAtIndex:_currentFrameIndex]];
        }
        return;
    }
	
    // calc our frame
    int newIndex = elapsedTime/_slice;
	if (newIndex >= [[_animation frames] count]) {
		newIndex = [[_animation frames] count] - 1;
	}
    
	CCSprite *sprite = (CCSprite *)self.target;
    
	if (newIndex != _currentFrameIndex) {
        _currentFrameIndex = newIndex;
		[sprite setDisplayFrame:[[_animation frames] objectAtIndex:_currentFrameIndex]];
	}
}

@end