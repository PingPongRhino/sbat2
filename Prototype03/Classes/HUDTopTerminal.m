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
#import "HUDTopTerminal.h"
#import "StageLayer.h"
#import "StageScene.h"
#import "MainMenuLayer.h"
#import "ScoreTerminalWindow.h"
#import "WaveTimer.h"
#import "ScoreManager.h"
#import "LabelAnimateType.h"
#import "UITouch+Extended.h"
#import "NotificationStrings.h"
#import "SimpleAudioEngine.h"

//
// static globals
//
static NSString * const _scoreFormat = @"score = %qu;";
static NSString * const _waveFormat = @"%02d/10";

//
// @implementation HUDTopTerminal
//
@implementation HUDTopTerminal

//
// synthesize
//
@synthesize _active;
@synthesize _scoreTerminalWindow;
@synthesize _scoreLabel;
@synthesize _waveLabel;
@synthesize _waveTimer;
@synthesize _touch;

//
//
//
+ (id)hudTopTerminal {
    HUDTopTerminal *hudTopTerminal = [[HUDTopTerminal alloc] init];
    return [hudTopTerminal autorelease];
}

//
// methods
//
- (id)init {
    self = [super init];
    
    self._active = false;
    self._scoreTerminalWindow = [ScoreTerminalWindow scoreTerminalWindow];
    self._scoreLabel = [LabelAnimateType labelWithFontName:FONT_DEFAULT fontSize:11];
    self._waveLabel = [LabelAnimateType labelWithFontName:FONT_DEFAULT fontSize:8];
    self._waveTimer = [WaveTimer waveTimer];
    self._touch = nil;
    
    // set terminal window delegate
    _scoreTerminalWindow._delegate = self;
    
    return self;
}

//
//
//
- (int)activateWithScoreManager:(ScoreManager *)scoreManager {
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
    
    // register for score updates with the score manager
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleScoreChanged:)
                                                 name:kNotificationScoreManagerScoreChanged
                                               object:scoreManager];
    
    // activate terminal window
    [_scoreTerminalWindow activateWithSpawnPoint:ccp(126.0f, [StageLayer sharedStageLayer].contentSize.height - 26.0f)];
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    // set to inactive
    _active = false;
    
    // unregister for notificaitons
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // deactiavte children
    [_scoreTerminalWindow deactivate];
    [_scoreLabel removeFromParentAndCleanup:false];
    [_waveLabel removeFromParentAndCleanup:false];
    [_waveTimer deactivate];
    
    return 0;
}

//
//
//
- (void)resetWaveTimer {
    [_waveTimer setToDrainState];
}

//
//
//
- (void)stopWaveTimer {
    [_waveTimer stopTimer];
}

//
//
//
- (void)hideTerminal {
    
    // if terminal is not alive OR score is typing
    if (_scoreTerminalWindow._state != kTerminalWindowStateAlive || _scoreLabel._typing) {
        return;
    }
        
    [_scoreLabel removeFromParentAndCleanup:false];
    [_waveLabel removeFromParentAndCleanup:false];
    [_waveTimer deactivate];
    
    // tell terminal to hide here
    [_scoreTerminalWindow hideTerminal];
}

//
//
//
- (void)refreshScoreWithScore:(u_int64_t)score {
    [_scoreLabel setString:[NSString stringWithFormat:_scoreFormat, score]];
}

//
//
//
- (void)refreshWaveLabelWithWave:(int)waveNumber {
    [_waveLabel setString:[NSString stringWithFormat:_waveFormat, waveNumber]];
}

//
//
//
- (void)completedResizing:(ScoreTerminalWindow *)terminalWindow {
        
    // add score to scene
   [[StageLayer sharedStageLayer] addChild:_scoreLabel z:ZORDER_SCORE_TEXT];
    _scoreLabel.anchorPoint = ccp(0.0f, 0.0f);
    _scoreLabel.position = ccp(([StageLayer sharedStageLayer].contentSize.width / 2.0f) - 110.0f,
                               [StageLayer sharedStageLayer].contentSize.height - 30.0f);
    _scoreLabel._delegate = self;
    [_scoreLabel setColor:FONT_COLOR_DEFAULT];
    [_scoreLabel typeString:[NSString stringWithFormat:_scoreFormat, (u_int64_t)0]];
}

//
//
//
- (void)completedHiding:(ScoreTerminalWindow *)terminalWindow {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHudTopTerminalCompletedHiding object:self];
}

//
//
//
- (void)completedTyping:(LabelAnimateType *)labelAnimateType {
    
    // start and dispaly wave timer
    // unfortunately this is just guesswork (trial/error) until it looked good...
    _waveTimer.position = ccp(([StageLayer sharedStageLayer].contentSize.width / 2.0f) + 75.0f,
                              [StageLayer sharedStageLayer].contentSize.height - 24.0f);
    [_waveTimer activate];
    
    // refresh score
    [self refreshScoreWithScore:0];
    
    // add wave number to scene
    [[StageLayer sharedStageLayer] addChild:_waveLabel z:ZORDER_SCORE_TEXT];
    [_waveLabel setAnchorPoint:ccp(0.0f, 0.0f)];
    [_waveLabel setPosition:ccp(([StageLayer sharedStageLayer].contentSize.width / 2.0f) + 85.0f,
                                [StageLayer sharedStageLayer].contentSize.height - 30.0f)];
    [_waveLabel setColor:FONT_COLOR_DEFAULT];
    [self refreshWaveLabelWithWave:1];
}

//
//
//
- (void)handleScoreChanged:(NSNotification *)notification {
    ScoreManager *scoreManager = (ScoreManager *)[notification object];
    [self refreshScoreWithScore:scoreManager._score];
}

//
//
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance; {
    // if terminal is not alive OR score is typing, ignore touches
    if (_scoreTerminalWindow._state != kTerminalWindowStateAlive || _scoreLabel._typing) {
        return false;
    }
    
    CGPoint touchPoint = [_scoreTerminalWindow convertToNodeSpace:[touch worldCoordinate]];
    CGRect rect = CGRectZero;
    rect.size = _scoreTerminalWindow.textureRect.size;
    
    // if touch wasn't inside us, then bail
    if (!CGRectContainsPoint(rect, touchPoint)) {
        return false;
    }
    
    // save touch
    _touch = touch;
    
    // pause will just take if it gets hit
    *minDistance = 0.0f;
    return true;
}

//
//
//
- (void)handleTouchMoved:(UITouch *)touch { }

//
//
//
- (bool)handleTouchEnded:(UITouch *)touch {
    
    // if we've never seen this touch before
    if (touch != _touch) {
        return false;
    }
    
    // play sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_MENU_CLICK pitch:1.0f pan:0.0f gain:SFX_MENU_CLICK_GAIN];

    _touch = nil;
    
    // if touch is not inside the terminal window, then ignore the touch
    CGPoint touchPoint = [_scoreTerminalWindow convertToNodeSpace:[touch worldCoordinate]];
    CGRect rect = CGRectZero;
    rect.size = _scoreTerminalWindow.textureRect.size;
    if (!CGRectContainsPoint(rect, touchPoint)) {
        return true;
    }
    
    // toggle paused state
    [[StageLayer sharedStageLayer] pause];
    [[MainMenuLayer sharedMainMenuLayer] activateWithMenuScreen:kMenuScreenPause];
    return true;
}

//
//
//
- (void)handleTouchCancelled:(UITouch *)touch {
    if (touch != _touch) {
        return;
    }
    
    _touch = nil;
}

//
//
//
- (void)dealloc {
    [self deactivate];
    self._scoreTerminalWindow = nil;
    self._scoreLabel = nil;
    self._waveLabel = nil;
    self._waveTimer = nil;
    self._touch = nil;
    [super dealloc];
}

@end
