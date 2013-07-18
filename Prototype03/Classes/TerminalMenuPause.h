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
#import "TerminalMenu.h"
#import "defines.h"

//
// forward declarations
//
@class LabelAnimateType;

//
// @interface TerminalMenuPause
//
@interface TerminalMenuPause : TerminalMenu {
    LabelAnimateType *_restartGameLabel;
    LabelAnimateType *_mainMenuLabel;
    LabelAnimateType *_returnToGameLabel;
    LabelAnimateType *_optionsLabel;
    
    // touch stuff
    UITouch *_touch;
    LabelAnimateType *_selectedLabel;
}

//
// properties
//
@property (nonatomic, assign) LabelAnimateType *_restartGameLabel;
@property (nonatomic, assign) LabelAnimateType *_mainMenuLabel;
@property (nonatomic, assign) LabelAnimateType *_returnToGameLabel;
@property (nonatomic, assign) LabelAnimateType *_optionsLabel;
@property (nonatomic, assign) UITouch *_touch;
@property (nonatomic, assign) LabelAnimateType *_selectedLabel;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer;

//
// manage text
//
- (void)addTextToTerminalForTutorialMode;
- (void)addTextToTerminalForSurvivalMode;

//
// terminal menu overrides
//
- (void)addTextToTerminal;
- (void)handleTouchBegan:(UITouch *)touch;
- (void)handleTouchEnded:(UITouch *)touch;

@end
