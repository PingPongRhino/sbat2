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
#import "TutorialTerminal.h"
#import "StageScene.h"
#import "TerminalWindow.h"
#import "StageLayer.h"
#import "LaserGrid.h"
#import "UITouch+Extended.h"
#import "LabelAnimateType.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"

//
// @implementation TutorialTerminal
//
@implementation TutorialTerminal

//
// properties
//
@synthesize _active;
@synthesize _minimized;
@synthesize _initialResize;
@synthesize _terminalWindow;
@synthesize _minimizedSize;
@synthesize _maximizedSize;
@synthesize _touch;
@synthesize _minTextLabel;
@synthesize _minimizeStatusWindow;
@synthesize _returnToTutorialMenu;
@synthesize _selectedLabel;
@synthesize _currentObjective;

//
//
//
+ (id)tutorialTerminal {
	TutorialTerminal *tutorialTerminal = [[TutorialTerminal alloc] init];
	return [tutorialTerminal autorelease];
}

//
//
//
- (id)init {
	self = [super init];
    
    [self setContentSize:CGSizeMake(480, 320)];
	
	// init properties
	self._active = false;
    self._minimized = false;
    self._initialResize = true;
	self._terminalWindow = [self setupTerminalWindow];
	self._minimizedSize = CGSizeMake(190.0f, 0.0f);
	self._maximizedSize = CGSizeMake(190.0f, 252.0f);
    self._minTextLabel = [_terminalWindow setupCommandLineText:@""];
    self._minimizeStatusWindow = nil;
    self._returnToTutorialMenu = nil;
    self._selectedLabel = nil;
    self._currentObjective = 0;

	// setup touch stuff
	self.isTouchEnabled = YES;
	
	return self;
}

//
//
//
- (TerminalWindow *)setupTerminalWindow {
    TerminalWindow *terminalWindow = [TerminalWindow terminalWindow];
    terminalWindow._delegate = self;
    return terminalWindow;
}

//
//
//
- (int)activate {
	
	if (_active) {
		return 1;
	}

	_active = true;
    _minimized = true;
	StageScene *stageScene = [StageScene sharedStageScene];
    [stageScene._scene addChild:self z:ZORDER_MENU_LAYER];
		
	// calc minimized and maximized points
	CGPoint spawnPoint = ccp(self.contentSize.width / 2.0f, 28.0f);
    
    // activate terminal
    CCSpriteBatchNode *spriteBatchNode = [stageScene._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_HUD_HIGH];
    [_terminalWindow activateWithSpawnPoint:spawnPoint
                                       size:_minimizedSize
                                 parentNode:self
                            spriteBatchNode:spriteBatchNode];

    _initialResize = true;
    _currentObjective = 0;
    
	return 0;
}

//
//
//
- (int)deactivate {
	
	if (!_active) {
		return 1;
	}
	
	// deactivate and remove from scene
	_active = false;
	[self removeFromParentAndCleanup:false];
	
	// deactivate terminal window and menus
    [_terminalWindow deactivate];
    	
	return 0;
}

//
// desc: override this
//
- (NSString *)minStringForCurrentObjective { return @""; }

//
//
//
- (void)refreshMinimizedText {
    [_minTextLabel setString:[self minStringForCurrentObjective]];
}

//
//
//
- (LabelAnimateType *)getMaximizedHitLabel:(UITouch *)touch {
    if ([_minimizeStatusWindow wasHitByTouch:touch]) {
        return _minimizeStatusWindow;
    }
    
    if ([_returnToTutorialMenu wasHitByTouch:touch]) {
        return _returnToTutorialMenu;
    }
    
    return nil;
}

//
//
//
- (void)setupMinimizeStatusWindowLabel {
    self._minimizeStatusWindow = [_terminalWindow addCommandLineText:@"[ Minimize      ]"];
}

//
//
//
- (void)setupReturnToTutorialMenuLabel {
    self._returnToTutorialMenu = [_terminalWindow addCommandLineText:@"[ Exit tutorial ]"];
}

//
//
//
- (void)minimize {
    [_terminalWindow resizeToNewSize:_minimizedSize withAnchorPoint:ccp(0.0f, 0.0f) hideAfterResize:false];
    self._minimizeStatusWindow = nil;
    self._returnToTutorialMenu = nil;
}

//
//
//
- (void)maximize {
        
    // pause tutorial and maximize
    [[StageLayer sharedStageLayer] pause];
    [_terminalWindow resizeToNewSize:_maximizedSize withAnchorPoint:ccp(0.0f, 0.0f) hideAfterResize:false];
    
    // set to swallow touches
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
													 priority:0
											  swallowsTouches:YES];
}

//
//
//
- (void)completedMinimizing {
    // print out min text label and reset it's highlight state to be safe
    [_minTextLabel setHighlighted:false];
    [_terminalWindow addCommandLineLabelTypeObject:_minTextLabel];
    
    // stop swallowing touches
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

//
//
//
- (void)completedMaximizing { }

//
//
//
- (void)completedResizing:(TerminalWindow *)terminalWindow {
    
    // are initial sizing is minimized so we need to move from minimized to maximized on initialization
    if (_initialResize) {
        _initialResize = false;
        [self maximize];
        return;
    }
	
	// figure out if we just finished being minimized or maximized
	if (CGSizeEqualToSize(_minimizedSize, _terminalWindow._goalSize)) {
        [[StageLayer sharedStageLayer] resume];
		[self completedMinimizing];
        _minimized = true;
		return;
	}
	
	if (CGSizeEqualToSize(_maximizedSize, _terminalWindow._goalSize)) {
		[self completedMaximizing];
        _minimized = false;
		return;
	}
}

//
//
//
- (void)completedHiding:(TerminalWindow *)terminalWindow {
	
	// deactivate
	[self deactivate];
	
	// tell stage layer to deactivate so we can get back to the menu
	[[StageLayer sharedStageLayer] deactivateCurrentGamePlayManager];
}

//
//
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance {
    
    // if not ready, then bail
    if (![_terminalWindow isReady]) {
        return false;
    }
        
    // if minimize and touch was not inside us, then don't handle it
    if (!CGRectContainsPoint([_terminalWindow calcHitBox], [touch worldCoordinate])) {
        return false;
    }
    
    // save off touch
    _touch = touch;
    [_minTextLabel setHighlighted:true];
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
    
    // make sure this is our touch
    if (_touch != touch) {
        return false;
    }
    
    // play sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_MENU_CLICK pitch:1.0f pan:0.0f gain:SFX_MENU_CLICK_GAIN];
    
    // reset touch stuff
    _touch = nil;
    [_minTextLabel setHighlighted:false];
    
    // if not ready, then cancel
    if (![_terminalWindow isReady]) {
        return true;
    }
    
    // if didn't end on us, then cance
    if (!CGRectContainsPoint([_terminalWindow calcHitBox], [touch worldCoordinate])) {
        return true;
    }
    
    // maximize
    [self maximize];
    return true;
}

//
//
//
- (void)handleTouchCancelled:(UITouch *)touch {
    _touch = nil;
    [_minTextLabel setHighlighted:false];
}


//
// handle touch input
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (![_terminalWindow isReady]) {
        return true;
    }
    
    // if we already got a touch, then drop this one
    if (_touch) {
        return true;
    }
    
    // get selected label
    self._selectedLabel = [self getMaximizedHitLabel:touch];
    
    // if nothing hit, then drop it
    if (!_selectedLabel) {
        return true;
    }
    
    [_selectedLabel setHighlighted:true];
    _touch = touch;
    return true;
}

//
//
//
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}

//
//
//
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (![_terminalWindow isReady]) {
        return;
    }
    
    // if this isn't our touch, then bail
    if (_touch != touch) {
        return;
    }
    
    // play sound effect
    [[SimpleAudioEngine sharedEngine] playEffect:SFX_MENU_CLICK pitch:1.0f pan:0.0f gain:SFX_MENU_CLICK_GAIN];
    
    // kill touch and unhighlight label
    _touch = nil;
    [_selectedLabel setHighlighted:false];
    
    // make sure they let up on the same label
    LabelAnimateType *label = [self getMaximizedHitLabel:touch];
    if (label != _selectedLabel) {
        return;
    }
    
    // w00t, we got a hit, so process it
    if (_selectedLabel == _minimizeStatusWindow) {
        [self minimize];
        return;
    }
    
    if (_selectedLabel == _returnToTutorialMenu) {
        [[StageLayer sharedStageLayer] deactivateCurrentGamePlayManager];
        [[MainMenuLayer sharedMainMenuLayer] activateWithMenuScreen:kMenuScreenTutorial];
        return;
    }
}

//
//
//
- (void)dealloc {
	self._terminalWindow = nil;
    self._minTextLabel = nil;
    self._minimizeStatusWindow = nil;
    self._returnToTutorialMenu = nil;
    self._selectedLabel = nil;
	[super dealloc];	
}

@end
