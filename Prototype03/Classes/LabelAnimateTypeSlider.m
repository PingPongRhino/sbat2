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
#import "LabelAnimateTypeSlider.h"
#import "UITouch+Extended.h"

//
// global statics
//
static float _characterCount = 25;
static NSString * const _leftEdgeCharacter = @"[";
static NSString * const _rightEdgeCharacter = @"]";
static NSString * const _fillerCharacter = @"-";
static NSString * const _notchCharacter = @"|";
static float _touchSensitivity = 7.5f; // pixels per notch

//
// @implementation LabelAnimateTypeSlider
//
@implementation LabelAnimateTypeSlider

//
// synthesize
//
@synthesize _notchLocation;
@synthesize _prevNotchLocation;
@synthesize _lastRefreshNotchLocation;
@synthesize _startingTouchPosition;

//
//
//
+ (id)labelWithFontName:(NSString *)name fontSize:(CGFloat)size {
    LabelAnimateTypeSlider *slider = [[LabelAnimateTypeSlider alloc] initWithFontName:name fontSize:size];
    
    slider._notchLocation = 0;
    slider._lastRefreshNotchLocation = -1;
    
    return [slider autorelease];
}

//
//
//
- (float)percentage {
    return (float)_notchLocation / (float)(_characterCount-1);
}

//
//
//
- (void)setPercentage:(float)percentage {
    
    // cap percentage
    if (percentage > 1.0f) {
        percentage = 1.0f;
    }
    else if (percentage < 0.0f) {
        percentage = 0.0f;
    }
    
    // get notch locations
    _notchLocation = (_characterCount - 1) * percentage;
    
    // refresh string
    [self refreshString:percentage];
}

//
//
//
- (void)refreshString {
    [self refreshString:[self percentage]];
}

//
//
//
- (void)refreshString:(float)percentage {
    
    // safety net so notch is always in range
    if (_notchLocation >= _characterCount) {
        _notchLocation = _characterCount - 1;
    }
    else if (_notchLocation < 0) {
        _notchLocation = 0;
    }
    
    // if already displaying this notch, don't refres
    if (_lastRefreshNotchLocation == _notchLocation) {
        return;
    }
    _lastRefreshNotchLocation = _notchLocation;
    
    // create string
    NSString *string = _leftEdgeCharacter;
    
    // add dashes up to the notch
    for (int i=0; i < _notchLocation; i++) {
        string = [string stringByAppendingString:_fillerCharacter];
    }
    
    // add notch
    string = [string stringByAppendingString:_notchCharacter];
    
    // add rest of dashes
    for (int i=_notchLocation+1; i < _characterCount; i++) {
        string = [string stringByAppendingString:_fillerCharacter];
    }
    
    // add ending stuff
    string = [string stringByAppendingFormat:@"%@ %d%%", _rightEdgeCharacter, (int)(percentage * 100.0f)];
    
    // set new string
    [self setString:string];
}

//
//
//
- (void)updateSliderWithTouch:(UITouch *)touch {
    // get new location
    CGPoint newLocation = [touch worldCoordinate];
    
    // get x displacement
    float xDisplacement = newLocation.x - _startingTouchPosition.x;
    
    // translate to not displacement
    int notchDisplacement = xDisplacement / _touchSensitivity;
    
    // if not displacement then do nothing
    if (notchDisplacement == 0) {
        return;
    }
    
    // update our notch
    _notchLocation = _prevNotchLocation + notchDisplacement;
    
    // refresh slider
    [self refreshString];
}

//
//
//
- (void)handleTouchBegan:(UITouch *)touch {
    _startingTouchPosition = [touch worldCoordinate];
    _prevNotchLocation = _notchLocation;
}

//
//
//
- (void)handleTouchMoved:(UITouch *)touch {
    [self updateSliderWithTouch:touch];
}

//
//
//
- (void)handleTouchEnded:(UITouch *)touch {
    [self updateSliderWithTouch:touch];
}


@end
