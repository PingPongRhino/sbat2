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
#import "CCLayer.h"
#import "protocols.h"
#import "defines.h"

//
// forward declarations
//
@class TerminalWindow;
@class LabelAnimateType;

//
// @interface TutorialTerminal
//
@interface TutorialTerminal : CCLayer <TerminalWindowProtocol, TouchProtocol> {
	bool _active;
    bool _minimized;
    bool _initialResize;
	TerminalWindow *_terminalWindow;
	CGSize _minimizedSize;
	CGSize _maximizedSize;
	UITouch *_touch;
    LabelAnimateType *_minTextLabel;
    LabelAnimateType *_minimizeStatusWindow;
    LabelAnimateType *_returnToTutorialMenu;
    LabelAnimateType *_selectedLabel;
    int _currentObjective;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _minimized;
@property (nonatomic, assign) bool _initialResize;
@property (nonatomic, retain) TerminalWindow *_terminalWindow;
@property (nonatomic, assign) CGSize _minimizedSize;
@property (nonatomic, assign) CGSize _maximizedSize;
@property (nonatomic, assign) UITouch *_touch;
@property (nonatomic, assign) LabelAnimateType *_minTextLabel;
@property (nonatomic, assign) LabelAnimateType *_minimizeStatusWindow;
@property (nonatomic, assign) LabelAnimateType *_returnToTutorialMenu;
@property (nonatomic, assign) LabelAnimateType *_selectedLabel;
@property (nonatomic, assign) int _currentObjective;

//
// static methods
//
+ (id)tutorialTerminal;

//
// initialization
//
- (id)init;
- (TerminalWindow *)setupTerminalWindow;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// misc
//
- (NSString *)minStringForCurrentObjective;
- (void)refreshMinimizedText;
- (LabelAnimateType *)getMaximizedHitLabel:(UITouch *)touch;
- (void)setupMinimizeStatusWindowLabel;
- (void)setupReturnToTutorialMenuLabel;

//
// minimize/maximize
//
- (void)minimize;
- (void)maximize;

//
// completed minimizing/maximizing
//
- (void)completedMinimizing;
- (void)completedMaximizing;

//
// TerminalWindowProtocol
//
- (void)completedResizing:(TerminalWindow *)terminalWindow;
- (void)completedHiding:(TerminalWindow *)terminalWindow;

//
// TouchProtocol (used when minimized)
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance;
- (void)handleTouchMoved:(UITouch *)touch;
- (bool)handleTouchEnded:(UITouch *)touch;
- (void)handleTouchCancelled:(UITouch *)touch;

//
// CCTouchDispatcher used when maximized
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

//
// cleanup
//
- (void)dealloc;

@end
