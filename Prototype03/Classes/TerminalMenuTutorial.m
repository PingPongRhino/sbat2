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
#import "TerminalMenuTutorial.h"
#import "TerminalWindow.h"
#import "LabelAnimateType.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"

//
// @implementation TerminalMenuTutorial
//
@implementation TerminalMenuTutorial

//
// synthesize
//
@synthesize _baseTowerTutorialLabel;
@synthesize _mobileTowerTutorialLabel;
@synthesize _mainMenuLabel;
@synthesize _touch;
@synthesize _selectedLabel;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer
{
    TerminalMenuTutorial *terminalMenuTutorial = [[TerminalMenuTutorial alloc] initWithMainMenuLayer:mainMenulayer];
    return [terminalMenuTutorial autorelease];
}

//
//
//
- (void)addTextToTerminal {
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: tutorial_menu"];
    [_terminalWindow addCommandLineText:@"---- select command ----"];
    [_terminalWindow addCommandLineText:@" "];
    self._baseTowerTutorialLabel    = [_terminalWindow addCommandLineText:@"[ Base tower tutorial   ]"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    self._mobileTowerTutorialLabel  = [_terminalWindow addCommandLineText:@"[ Mobile tower tutorial ]"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    self._mainMenuLabel             = [_terminalWindow addCommandLineText:@"[ Return to main_menu   ]"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@"_"];
    
    // add to label list
    self._labelList = [NSArray arrayWithObjects:_baseTowerTutorialLabel,
                                                _mobileTowerTutorialLabel,
                                                _mainMenuLabel, nil];
}

//
//
//
- (void)handleTouchBegan:(UITouch *)touch {
    
    // if not active
    if (!_active || _touch) {
        return;
    }
    
    self._selectedLabel = [self getHitLabel:touch];
    
    // if no label was hit, then bail
    if (!_selectedLabel) {
        self._touch = nil;
        return;
    }
    
    // highlight selected label
    [_selectedLabel setHighlighted:true];
    
    // save off touch
    self._touch = touch;
}

//
//
//
- (void)handleTouchEnded:(UITouch *)touch {
    
    if (!_active || touch != _touch) {
        return;
    }
    
    // play sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_MENU_CLICK pitch:1.0f pan:0.0f gain:SFX_MENU_CLICK_GAIN];
    
    // unhighlight selected text
    [_selectedLabel setHighlighted:false];
    
    // clear touch
    self._touch = nil;
    
    // get label touch ended on
    LabelAnimateType *label = [self getHitLabel:touch];
    
    // if doens't end on same label then bail
    if (label != _selectedLabel) {
        return;
    }
    
    // do action based on item that was selected
    if (_selectedLabel == _baseTowerTutorialLabel) {
        [_mainMenuLayer closeMenuWithGameMode:kGameModeBaseTowerTutorial];
        return;
    }
    
    if (_selectedLabel == _mobileTowerTutorialLabel) {
        [_mainMenuLayer closeMenuWithGameMode:kGameModeMobileTowerTutorial];
        return;
    }
        
    if (_selectedLabel == _mainMenuLabel) {
        [_mainMenuLayer openMenu:kMenuScreenMain];
        return;
    }
}

@end
