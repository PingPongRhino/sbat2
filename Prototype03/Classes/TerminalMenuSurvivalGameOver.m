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
#import "TerminalMenuSurvivalGameOver.h"
#import "LabelAnimateType.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "MainMenuLayer.h"
#import "TerminalWindow.h"
#import "SimpleAudioEngine.h"
#import "LeaderboardMgr.h"

//
// @implementation TerminalMenuSurvivalGameOver
//
@implementation TerminalMenuSurvivalGameOver

//
// synthesize
//
@synthesize _startNewGameLabel;
@synthesize _mainMenuLabel;
@synthesize _touch;
@synthesize _selectedLabel;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer {
    TerminalMenuSurvivalGameOver *terminalMenuSurvivalGameOver = [[TerminalMenuSurvivalGameOver alloc] initWithMainMenuLayer:mainMenulayer];
    return [terminalMenuSurvivalGameOver autorelease];
}

//
//
//
- (void)addTextToTerminal {
    
    switch (_mainMenuLayer._menuScreen) {
        case kMenuScreenSurvivalOutOfTime:          [self addTextToTerminalForGameOverOutOfTime]; break;
        case kMenuScreenSurvivalTowersDestroyed:    [self addTextToTerminalForGameOverTowersDestroyed]; break;
        case kMenuScreenSurvivalCompleted:          [self addTextToTerminalForCompleted]; break;
        default: break;
    }
    
    // add to label list
    self._labelList = [NSArray arrayWithObjects:_startNewGameLabel,
                                                _mainMenuLabel, nil];
}

//
//
//
- (void)addTextToTerminalForGameOverOutOfTime {
    // generate score string
    NSString *scoreString = [NSString stringWithFormat:@"score = %qu", _mainMenuLayer._gameScore];
    NSString *highScoreString = [NSString stringWithFormat:@"device_high_score = %qu;", [[LeaderboardMgr sharedLeaderboardMgr] highScore]];
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: survival_game_over"];
    [_terminalWindow addCommandLineText:@"---- game over (out of time)----"];
    [_terminalWindow addCommandLineText:scoreString];
    [_terminalWindow addCommandLineText:highScoreString];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    
    [_terminalWindow addCommandLineText:@"---- select command ----"];
    [_terminalWindow addCommandLineText:@" "];
    self._startNewGameLabel =   [_terminalWindow addCommandLineText:@"[ New Game            ]"];
    [_terminalWindow addCommandLineText:@" "];
    self._mainMenuLabel =       [_terminalWindow addCommandLineText:@"[ Return to main_menu ]"];
    [_terminalWindow addCommandLineText:@"_"];
}

//
//
//
- (void)addTextToTerminalForGameOverTowersDestroyed {
    // generate score string
    NSString *scoreString = [NSString stringWithFormat:@"score = %qu", _mainMenuLayer._gameScore];
    NSString *highScoreString = [NSString stringWithFormat:@"device_high_score = %qu;", [[LeaderboardMgr sharedLeaderboardMgr] highScore]];
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: survival_game_over"];
    [_terminalWindow addCommandLineText:@"---- game over (towers destroyed)"];
    [_terminalWindow addCommandLineText:scoreString];
    [_terminalWindow addCommandLineText:highScoreString];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    
    [_terminalWindow addCommandLineText:@"---- select command ----"];
    [_terminalWindow addCommandLineText:@" "];
    self._startNewGameLabel =   [_terminalWindow addCommandLineText:@"[ New Game            ]"];
    [_terminalWindow addCommandLineText:@" "];
    self._mainMenuLabel =       [_terminalWindow addCommandLineText:@"[ Return to main_menu ]"];
    [_terminalWindow addCommandLineText:@"_"];
}

//
//
//
- (void)addTextToTerminalForCompleted {
    // generate score string
    NSString *scoreString = [NSString stringWithFormat:@"score = %qu;", _mainMenuLayer._gameScoreWithoutCompletionBonus];
    NSString *completionBonusString = [NSString stringWithFormat:@"completion_bonus = %qu;", _mainMenuLayer._gameScore - _mainMenuLayer._gameScoreWithoutCompletionBonus];
    NSString *totalScoreString = [NSString stringWithFormat:@"total = %qu", _mainMenuLayer._gameScore];
    NSString *highScoreString = [NSString stringWithFormat:@"device_high_score = %qu;", [[LeaderboardMgr sharedLeaderboardMgr] highScore]];
    
    
    // command line text for main menu
    [_terminalWindow addCommandLineText:@"emscntrl: survival_completed"];
    [_terminalWindow addCommandLineText:@"---- survival completed ----"];
    [_terminalWindow addCommandLineText:scoreString];
    [_terminalWindow addCommandLineText:completionBonusString];
    [_terminalWindow addCommandLineText:totalScoreString];
    [_terminalWindow addCommandLineText:highScoreString];
    [_terminalWindow addCommandLineText:@" "];
    
    [_terminalWindow addCommandLineText:@"---- select command ----"];
    [_terminalWindow addCommandLineText:@" "];
    self._startNewGameLabel =   [_terminalWindow addCommandLineText:@"[ New Game            ]"];
    [_terminalWindow addCommandLineText:@" "];
    self._mainMenuLabel =       [_terminalWindow addCommandLineText:@"[ Return to main_menu ]"];
    [_terminalWindow addCommandLineText:@"_"];
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
    if (_selectedLabel == _startNewGameLabel) {
        [_mainMenuLayer closeMenuWithGameMode:kGameModeSurvival];
        return;
    }
    
    if (_selectedLabel == _mainMenuLabel) {
        [_mainMenuLayer openMenu:kMenuScreenMain];
        return;
    }
}

@end
