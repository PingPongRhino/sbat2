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
#import <Foundation/Foundation.h>
#import "LabelAnimateType.h"

//
// @interface LabelAnimateTypeSlider
//
@interface LabelAnimateTypeSlider : LabelAnimateType {
    int _notchLocation;
    int _prevNotchLocation;
    int _lastRefreshNotchLocation;
    CGPoint _startingTouchPosition;
}

//
// properties
//
@property (nonatomic, assign) int _notchLocation;
@property (nonatomic, assign) int _prevNotchLocation;
@property (nonatomic, assign) int _lastRefreshNotchLocation;
@property (nonatomic, assign) CGPoint _startingTouchPosition;


//
//
//
+ (id)labelWithFontName:(NSString *)name fontSize:(CGFloat)size;

//
// methods
//
- (float)percentage;
- (void)setPercentage:(float)percentage;
- (void)refreshString;
- (void)refreshString:(float)percentage;
- (void)updateSliderWithTouch:(UITouch *)touch;
- (void)handleTouchBegan:(UITouch *)touch;
- (void)handleTouchMoved:(UITouch *)touch;
- (void)handleTouchEnded:(UITouch *)touch;


@end
