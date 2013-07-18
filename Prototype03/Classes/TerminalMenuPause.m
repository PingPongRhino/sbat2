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
#import "TerminalMenuPause.h"
#import "TerminalWindow.h"
#import "MainMenuLayer.h"
#import "LabelAnimateType.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "TerminalMenuMain.h"
#import "SimpleAudioEngine.h"

//
// @implementation TerminalMenuPause
//
@implementation TerminalMenuPause

//
// synthesize
//
@synthesize _restartGameLabel;
@synthesize _mainMenuLabel;
@synthesize _returnToGameLabel;
@synthesize _optionsLabel;
@synthesize _touch;
@synthesize _selectedLabel;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer {
    TerminalMenuPause *terminalMenuPause = [[TerminalMenuPause alloc] initWithMainMenuLayer:mainMenulayer];
    return [terminalMenuPause autorelease];
}

//
//
//
- (void)addTextToTerminalForTutorialMode {
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: pause_menu"];
    [_terminalWindow addCommandLineText:@"---- select command ----"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._returnToGameLabel =   [_terminalWindow addCommandLineText:@"[ Return to game             ]"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._optionsLabel =        [_terminalWindow addCommandLineText:@"[ Options                    ]"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._mainMenuLabel =       [_terminalWindow addCommandLineText:@"[ Return to main_menu (quit) ]"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@"_"];
    
    // add to label list
    self._labelList = [NSArray arrayWithObjects:_returnToGameLabel,
                                                _optionsLabel,
                                                _mainMenuLabel, nil];
}

//
//
//
- (void)addTextToTerminalForSurvivalMode {
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: pause_menu"];
    [_terminalWindow addCommandLineText:@"---- select command ----"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._returnToGameLabel =   [_terminalWindow addCommandLineText:@"[ Return to game             ]"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._restartGameLabel =    [_terminalWindow addCommandLineText:@"[ New Game (Restart)         ]"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._optionsLabel =        [_terminalWindow addCommandLineText:@"[ Options                    ]"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    self._mainMenuLabel =       [_terminalWindow addCommandLineText:@"[ Return to main_menu (quit) ]"];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@""];
    [_terminalWindow addCommandLineText:@"_"];
    
    // add to label list
    self._labelList = [NSArray arrayWithObjects:_returnToGameLabel,
                                                _restartGameLabel,
                                                _optionsLabel,
                                                _mainMenuLabel, nil];
}

//
//
//
- (void)addTextToTerminal {
    
    if ([[StageLayer sharedStageLayer] gameMode] == kGameModeSurvival) {
        [self addTextToTerminalForSurvivalMode];
        return;
    }
    
    [self addTextToTerminalForTutorialMode];
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
    if (_selectedLabel == _returnToGameLabel) {
        [_mainMenuLayer closeMenuWithGameMode:kGameModeResume];
        return;
    }
    
    if (_selectedLabel == _restartGameLabel) {
        [[StageLayer sharedStageLayer] deactivateCurrentGamePlayManager];
        [_mainMenuLayer closeMenuWithGameMode:kGameModeSurvival];
        return;
    }
    
    if (_selectedLabel == _optionsLabel) {
        [_mainMenuLayer openMenu:kMenuScreenOptions];
        return;
    }
    
    if (_selectedLabel == _mainMenuLabel) {
        [[StageLayer sharedStageLayer] reset];
        [_mainMenuLayer openMenu:kMenuScreenMain];
        return;
    }
}

@end
