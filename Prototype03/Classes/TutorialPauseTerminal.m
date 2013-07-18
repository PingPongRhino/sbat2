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
#import "TutorialPauseTerminal.h"
#import "ScoreTerminalWindow.h"
#import "LabelAnimateType.h"
#import "StageLayer.h"
#import "MainMenuLayer.h"
#import "UITouch+Extended.h"
#import "SimpleAudioEngine.h"

//
// @implementation TutorialPauseTerminal
//
@implementation TutorialPauseTerminal

//
// synthesize
//
@synthesize _active;
@synthesize _terminalWindow;
@synthesize _pauseLabel;
@synthesize _touch;

//
//
//
+ (id)tutorialPauseTerminal {
	TutorialPauseTerminal *tutorialPauseTerminal = [[TutorialPauseTerminal alloc] init];
	return [tutorialPauseTerminal autorelease];
}

//
//
//
- (id)init {
	self = [super init];
	
	// init properties
	self._active = false;
	self._terminalWindow = [ScoreTerminalWindow scoreTerminalWindow];
	self._pauseLabel = [LabelAnimateType labelWithFontName:FONT_DEFAULT fontSize:11];
	self._touch = nil;
	
	// set terminal window delegate
    _terminalWindow._delegate = self;
	
	return self;
}

//
//
//
- (int)activate {
	
	// if already active
	if (_active) {
		return 1;
	}
	
	// set to active
	_active = true;
	
	// activate terminal window
    [_terminalWindow activateWithSpawnPoint:ccp(126.0f, [StageLayer sharedStageLayer].contentSize.height - 26.0f)];
	
	return 0;
}

//
//
//
- (int)deactivate {
	
	// if not active
	if (!_active) {
		return 1;
	}
	
	// set to inactive
	_active = false;
	
	// cleanup sprite stuff
	[_terminalWindow deactivate];
    [_pauseLabel removeFromParentAndCleanup:false];
	
	return 0;
}

//
//
//
- (void)hideTerminal {
    
    // if terminal is not alive OR score is typing
    if (_terminalWindow._state != kTerminalWindowStateAlive || _pauseLabel._typing) {
        return;
    }

	// kill pause text
    [_pauseLabel removeFromParentAndCleanup:false];
    
    // tell terminal to hide here
    [_terminalWindow hideTerminal];
}

//
//
//
- (void)completedResizing:(ScoreTerminalWindow *)terminalWindow {
	
    // add score to scene
	[[StageLayer sharedStageLayer] addChild:_pauseLabel z:ZORDER_SCORE_TEXT];
    _pauseLabel.anchorPoint = ccp(0.0f, 0.0f);
    _pauseLabel.position = ccp(([StageLayer sharedStageLayer].contentSize.width / 2.0f) - 110.0f,
                               [StageLayer sharedStageLayer].contentSize.height - 30.0f);
    [_pauseLabel setColor:FONT_COLOR_DEFAULT];
    [_pauseLabel typeString:@"tap here to pause"];
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
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance; {
    // if terminal is not alive OR score is typing, ignore touches
    if (_terminalWindow._state != kTerminalWindowStateAlive || _pauseLabel._typing) {
        return false;
    }
    
    CGPoint touchPoint = [_terminalWindow convertToNodeSpace:[touch worldCoordinate]];
    CGRect rect = CGRectZero;
    rect.size = _terminalWindow.textureRect.size;
    
    // if touch wasn't inside us, then bail
    if (!CGRectContainsPoint(rect, touchPoint)) {
        return false;
    }
    
    // save touch
    _touch = touch;
    
    // pause will just take if it gets hit
    *minDistance = 0.0f;
    
    // highlight pause text
    [_pauseLabel setHighlighted:true];
    
    // report we will handle the touch
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
	
    // reset touch tracking
    _touch = nil;
    
    // unhighlight text
    [_pauseLabel setHighlighted:false];
    
    // if touch is not inside the terminal window, then ignore the touch
    CGPoint touchPoint = [_terminalWindow convertToNodeSpace:[touch worldCoordinate]];
    CGRect rect = CGRectZero;
    rect.size = _terminalWindow.textureRect.size;
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
    
    // reset touch tracking
    _touch = nil;
    
    // unhighlight text
    [_pauseLabel setHighlighted:false];
}

//
//
//
- (void)dealloc {
	[self deactivate];
	self._terminalWindow = nil;
	self._pauseLabel = nil;
	self._touch = nil;
	[super dealloc];
}


@end
