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
#import "TerminalMenu.h"
#import "MainMenuLayer.h"
#import "TerminalMenu.h"
#import "TerminalWindow.h"
#import "LabelAnimateType.h"

//
// @implementation MainMenu
//
@implementation TerminalMenu

//
// synthesize
//
@synthesize _mainMenuLayer;
@synthesize _terminalWindow;
@synthesize _active;
@synthesize _prevMenuScreen;
@synthesize _labelList;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer {
    TerminalMenu *terminalMenu = [[TerminalMenu alloc] initWithMainMenuLayer:mainMenulayer];
    return [terminalMenu autorelease];
}

//
//
//
- (id)initWithMainMenuLayer:(MainMenuLayer *)mainMenulayer {
    self = [super init];
    
    self._mainMenuLayer = mainMenulayer;
    self._terminalWindow = mainMenulayer._terminalWindow;
    self._active = false;
    self._prevMenuScreen = kMenuScreenUnknown;
    self._labelList = nil;
    
    return self;
}

//
//
//
- (int)activateWithPrevMenuScreen:(MenuScreen)prevMenuScreen {
    if (_active) {
        return 1;
    }
    
    _active = true;
    _prevMenuScreen = prevMenuScreen;
    [self addTextToTerminal];
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    _active = false;
    [_terminalWindow removeAllCommandLineText];
    return 0;
}

//
//
//
- (LabelAnimateType *)getHitLabel:(UITouch *)touch {
    for (LabelAnimateType *label in _labelList) {
        if ([label wasHitByTouch:touch]) {
            return label;
        }
    }
    
    return nil;
}

//
//
//
- (void)addTextToTerminal {
}

//
//
//
- (void)handleTouchBegan:(UITouch *)touch {
}

//
//
//
- (void)handleTouchMoved:(UITouch *)touch {
}

//
//
//
- (void)handleTouchEnded:(UITouch *)touch {
}

//
//
//
- (void)dealloc {
    self._mainMenuLayer = nil;
    self._terminalWindow = nil;
    self._labelList = nil;
    [super dealloc];
}

@end
