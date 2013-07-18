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
#import "defines.h"
#import "protocols.h"

//
// @interface MasterControlSwitch
//
@interface MasterControlSwitch : CCSprite <TouchProtocol> {
    bool _active;
    ColorState _colorState;
    UITouch *_touch;
    CGPoint _startPosition;
    CGPoint _endPosition;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, assign) UITouch *_touch;
@property (nonatomic, assign) CGPoint _startPosition;
@property (nonatomic, assign) CGPoint _endPosition;

//
// static stuff
//
+ (void)setSharedMasterControlSwitches:(NSArray *)masterControlSwitches;
+ (NSArray *)sharedMasterControlSwitches;
+ (MasterControlSwitch *)masterControlSwitchWithColorState:(ColorState)colorState;

//
// initialization
//
- (id)initWithColorState:(ColorState)colorState;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// TouchProtocol
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance;
- (void)handleTouchMoved:(UITouch *)touch;
- (bool)handleTouchEnded:(UITouch *)touch;
- (void)handleTouchCancelled:(UITouch *)touch;

//
// cleanup
//
- (void)dealloc;

@end
