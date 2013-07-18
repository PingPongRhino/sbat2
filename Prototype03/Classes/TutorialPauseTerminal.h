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
#import "protocols.h"
#import "defines.h"
#import "NotificationStrings.h"

//
// forward declarations
//
@class ScoreTerminalWindow;
@class LabelAnimateType;

//
// @interface TutorialPauseTerminal
//
@interface TutorialPauseTerminal : NSObject <TerminalWindowProtocol,
										     TouchProtocol>
{
	// track state
	bool _active;
	
	// terminal window
	ScoreTerminalWindow *_terminalWindow;
	LabelAnimateType *_pauseLabel;
	
	// touch stuff
    UITouch *_touch;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) ScoreTerminalWindow *_terminalWindow;
@property (nonatomic, retain) LabelAnimateType *_pauseLabel;
@property (nonatomic, assign) UITouch *_touch;

//
// static constructor
//
+ (id)tutorialPauseTerminal;

//
// initialization
//
- (id)init;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// manage terminal
//
- (void)hideTerminal;

//
// TerminalWindowProtocol
//
- (void)completedResizing:(ScoreTerminalWindow *)terminalWindow;
- (void)completedHiding:(ScoreTerminalWindow *)terminalWindow;

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
