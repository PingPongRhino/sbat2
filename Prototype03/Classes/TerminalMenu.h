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
#import "defines.h"

//
// forward declarations
//
@class MainMenuLayer;
@class TerminalWindow;
@class LabelAnimateType;

//
// @interface MainMenu
//
@interface TerminalMenu : NSObject {
    MainMenuLayer *_mainMenuLayer;
    TerminalWindow *_terminalWindow;
    bool _active;
    MenuScreen _prevMenuScreen;
    NSArray *_labelList;
}

//
// properties
//
@property (nonatomic, assign) MainMenuLayer *_mainMenuLayer;
@property (nonatomic, assign) TerminalWindow *_terminalWindow;
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) NSArray *_labelList;
@property (nonatomic, assign) MenuScreen _prevMenuScreen;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer;

//
// initialize
//
- (id)initWithMainMenuLayer:(MainMenuLayer *)mainMenulayer;

//
// activate/deactivate
//
- (int)activateWithPrevMenuScreen:(MenuScreen)prevMenuScreen;
- (int)deactivate;

//
// for managing labels
//
- (LabelAnimateType *)getHitLabel:(UITouch *)touch;

//
// overrides
//
- (void)addTextToTerminal;
- (void)handleTouchBegan:(UITouch *)touch;
- (void)handleTouchMoved:(UITouch *)touch;
- (void)handleTouchEnded:(UITouch *)touch;

//
// cleanup
//
- (void)dealloc;


@end
