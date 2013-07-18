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
#import "TerminalMenuOptions.h"
#import "TerminalWindow.h"
#import "MainMenuLayer.h"
#import "StageScene.h"
#import "LabelAnimateType.h"
#import "LabelAnimateTypeSlider.h"
#import "BGSoundManager.h"
#import "SimpleAudioEngine.h"
#import "SettingsManager.h"

//
// @implementation TerminalMenuOptions
//
@implementation TerminalMenuOptions

//
// synthesize
//
@synthesize _backgroundMusicVolumeLabel;
@synthesize _backgroundMusicVolumeSlider;
@synthesize _sfxVolumeLabel;
@synthesize _sfxVolumeSlider;
@synthesize _creditsLabel;
@synthesize _returnPrevMenuLabel;
@synthesize _optionsPrevMenuScreen;
@synthesize _touch;
@synthesize _selectedLabel;

//
//
//
+ (id)terminalMenuWithMainMenuLayer:(MainMenuLayer *)mainMenulayer {
    TerminalMenuOptions *terminalMenuOptions = [[TerminalMenuOptions alloc] initWithMainMenuLayer:mainMenulayer];
    return [terminalMenuOptions autorelease];
}

//
//
//
- (void)addTextToTerminal {
    
    if (_prevMenuScreen == kMenuScreenCredits) {
        _prevMenuScreen = _optionsPrevMenuScreen;
    }
    else {
        _optionsPrevMenuScreen = _prevMenuScreen;
    }
    
    // generat return button text
    NSString *returnPrevMenuString = @"[ Return to somewhere?    ]";
    switch (_optionsPrevMenuScreen) {
        case kMenuScreenMain:   returnPrevMenuString = @"[ Return to main_menu     ]"; break;
        case kMenuScreenPause:  returnPrevMenuString = @"[ Return to pause_menu    ]"; break;
        default: break;
    }
    
        
    // command line text for options menu
    [_terminalWindow addCommandLineText:@"emscntrl: options_menu"];
    [_terminalWindow addCommandLineText:@"---- adjust settings ----"];
    [_terminalWindow addCommandLineText:@" "];
    self._backgroundMusicVolumeLabel =  [_terminalWindow addCommandLineText:@"[ Background Volume       ]"];
    self._backgroundMusicVolumeSlider = [_terminalWindow addCommandLineTextSliderWithPercentage:[[BGSoundManager sharedBGSoundManager] adjustedVolume]];
    [_terminalWindow addCommandLineText:@" "];
    self._sfxVolumeLabel =              [_terminalWindow addCommandLineText:@"[ SFX Volume              ]"];
    self._sfxVolumeSlider =             [_terminalWindow addCommandLineTextSliderWithPercentage:[[BGSoundManager sharedBGSoundManager] adjustedSFXVolume]];
    [_terminalWindow addCommandLineText:@" "];
    self._creditsLabel =                [_terminalWindow addCommandLineText:@"[ Credits                 ]"];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@""];
    self._returnPrevMenuLabel =         [_terminalWindow addCommandLineText:returnPrevMenuString];
    [_terminalWindow addCommandLineText:@"_"];
    
    // add to list
    self._labelList = [NSArray arrayWithObjects:_backgroundMusicVolumeLabel,
                                                _backgroundMusicVolumeSlider,
                                                _sfxVolumeLabel,
                                                _sfxVolumeSlider,
                                                _creditsLabel,
                                                _returnPrevMenuLabel, nil];
    
}

//
//
//
- (void)handleTouchBegan:(UITouch *)touch {
    
    // if not active
    if (!_active) {
        return;
    }
    
    // if we already got a touch, then drop this one
    if (_touch) {
        return;
    }
    
    self._selectedLabel = [self getHitLabel:touch];
    
    // if no label was hit, then bail
    if (!_selectedLabel) {
        self._touch = nil;
        return;
    }
    
    // highlight the appropriate label
    if (_selectedLabel == _backgroundMusicVolumeLabel || _selectedLabel == _backgroundMusicVolumeSlider) {
        [_backgroundMusicVolumeLabel setHighlighted:true];
        [_backgroundMusicVolumeSlider handleTouchBegan:touch];
        self._selectedLabel = _backgroundMusicVolumeSlider;
    }
    else if (_selectedLabel == _sfxVolumeLabel || _selectedLabel == _sfxVolumeSlider) {
        [_sfxVolumeLabel setHighlighted:true];
        [_sfxVolumeSlider handleTouchBegan:touch];
        self._selectedLabel = _sfxVolumeSlider;
    }
    else {
        [_selectedLabel setHighlighted:true];
    }
        
    // save off touch
    self._touch = touch;
}

//
//
//
- (void)handleTouchMoved:(UITouch *)touch {
    
    // if not active
    if (!_active || _touch != touch) {
        return;
    }
    
    // adjust background volume
    if (_selectedLabel == _backgroundMusicVolumeSlider) {
        [_backgroundMusicVolumeSlider handleTouchMoved:touch];
        [[BGSoundManager sharedBGSoundManager] setAdjustedVolume:[_backgroundMusicVolumeSlider percentage]];
    }
    
    // adjust sfx
    if (_selectedLabel == _sfxVolumeSlider) {
        [_sfxVolumeSlider handleTouchMoved:touch];
        [[BGSoundManager sharedBGSoundManager] setAdjustedSFXVolume:[_sfxVolumeSlider percentage]];
    }
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
    if (_selectedLabel == _backgroundMusicVolumeSlider) {
        [_backgroundMusicVolumeLabel setHighlighted:false];
        [_backgroundMusicVolumeSlider handleTouchEnded:touch];
        [[BGSoundManager sharedBGSoundManager] setAdjustedVolume:[_backgroundMusicVolumeSlider percentage]];
    }
    else if (_selectedLabel == _sfxVolumeSlider) {
        [_sfxVolumeLabel setHighlighted:false];
        [_sfxVolumeSlider handleTouchEnded:touch];
        [[BGSoundManager sharedBGSoundManager] setAdjustedSFXVolume:[_sfxVolumeSlider percentage]];
    }
    else {
        [_selectedLabel setHighlighted:false];
    }
    
    // update settings file
    [SettingsManager saveSettings];
    
    // clear touch
    self._touch = nil;
    
    // get label touch ended on
    LabelAnimateType *label = [self getHitLabel:touch];
    
    // if doens't end on same label then bail
    if (label != _selectedLabel) {
        return;
    }
    
    // do action based on item that was selected
    if (_selectedLabel == _creditsLabel) {
        [_mainMenuLayer openMenu:kMenuScreenCredits];
        return;
    }
    
    if (_selectedLabel == _returnPrevMenuLabel) {
        [_mainMenuLayer openMenu:_prevMenuScreen];
        return;
    }
}

@end
