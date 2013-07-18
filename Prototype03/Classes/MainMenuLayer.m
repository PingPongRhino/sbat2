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
#import "MainMenuLayer.h"
#import "StageScene.h"
#import "NotificationStrings.h"
#import "TerminalWindow.h"
#import "TerminalMenuMain.h"
#import "TerminalMenuOptions.h"
#import "TerminalMenuSurvivalGameOver.h"
#import "TerminalMenuPause.h"
#import "TerminalMenuTutorial.h"
#import "TerminalMenuCredits.h"
#import "ScoreManager.h"

//
// static globals
//
static MainMenuLayer *_sharedMainMenuLayer = nil;
static const float _terminalWindowWidth = 220.0f;
static const float _terminalWindowHeight = 210.0f;

//
// @implementation MainMenuLayer
//
@implementation MainMenuLayer

//
// synthesize
//
@synthesize _terminalWindow;
@synthesize _active;
@synthesize _menuScreen;
@synthesize _gameMode;
@synthesize _gameScore;
@synthesize _gameScoreWithoutCompletionBonus;
@synthesize _mainMenu;
@synthesize _tutorialMenu;
@synthesize _optionsMenu;
@synthesize _survivalGameOverMenu;
@synthesize _pauseMenu;
@synthesize _creditsMenu;
@synthesize _menus;

//
//
//
+ (MainMenuLayer *)createSharedMainMenuLayer {
    [MainMenuLayer destroyMainMenuLayer];
    _sharedMainMenuLayer = [[MainMenuLayer alloc] init];
    return _sharedMainMenuLayer;
}

//
//
//
+ (MainMenuLayer *)sharedMainMenuLayer { return _sharedMainMenuLayer; }

//
//
//
+ (void)destroyMainMenuLayer {
    [_sharedMainMenuLayer release];
    _sharedMainMenuLayer = nil;
}


//
//
//
- (id)init {
    self = [super init];
    
    [self setContentSize:CGSizeMake(480, 320)];
    
    // init properties
    self._terminalWindow = [self createTerminalWindow];
    self._active = false;
    self._menuScreen = kMenuScreenUnknown;
    self._gameMode = kGameModeUnknown;
    self._gameScore = 0;
    self._gameScoreWithoutCompletionBonus = 0;
    self._mainMenu = [TerminalMenuMain terminalMenuWithMainMenuLayer:self];
    self._tutorialMenu = [TerminalMenuTutorial terminalMenuWithMainMenuLayer:self];
    self._optionsMenu = [TerminalMenuOptions terminalMenuWithMainMenuLayer:self];
    self._survivalGameOverMenu = [TerminalMenuSurvivalGameOver terminalMenuWithMainMenuLayer:self];
    self._pauseMenu = [TerminalMenuPause terminalMenuWithMainMenuLayer:self];
    self._creditsMenu = [TerminalMenuCredits terminalMenuWithMainMenuLayer:self];
    self._menus = [NSArray arrayWithObjects:_mainMenu, _tutorialMenu, _optionsMenu, _survivalGameOverMenu, _pauseMenu, _creditsMenu, nil];
            
    // setup touch stuff
	self.isTouchEnabled = YES;
	
    return self;
}

//
//
//
- (TerminalWindow *)createTerminalWindow {
    TerminalWindow *terminalWindow = [TerminalWindow terminalWindow];
    terminalWindow._delegate = self;
    return terminalWindow;
}

//
//
//
- (TerminalMenu *)getTerminalMenu:(MenuScreen)menuScreen {
    switch (menuScreen) {
        case kMenuScreenMain:               return _mainMenu;
        case kMenuScreenTutorial:           return _tutorialMenu;
        case kMenuScreenOptions:            return _optionsMenu;
        case kMenuScreenCredits:            return _creditsMenu;
        case kMenuScreenSurvivalOutOfTime:
        case kMenuScreenSurvivalTowersDestroyed:
        case kMenuScreenSurvivalCompleted:
                                            return _survivalGameOverMenu;
        case kMenuScreenPause:              return _pauseMenu;
        default: break;
    }
    
    return nil;
}

//
//
//
- (int)activateWithMenuScreen:(MenuScreen)menuScreen {
    
    if (_active)
        return 1;
    
    // set to active
    _active = true;
    _menuScreen = menuScreen;
    _gameScore = [ScoreManager sharedScoreManager]._score; // save off score incase the game play manager destroys the score manager
    _gameScoreWithoutCompletionBonus = [ScoreManager sharedScoreManager]._scoreWithoutCompletionBonus;
    
    // get shared stage scene
    StageScene *stageScene = [StageScene sharedStageScene];
    
    // start displaying and set to active
    [stageScene._scene addChild:self z:ZORDER_MENU_LAYER];
    
    // add sprite batch nodes
    CCSpriteBatchNode *spriteBatchNode = [stageScene._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_TERMINAL_MAIN_MENU];
    [self addChild:spriteBatchNode z:ZORDER_SPRITEBATCHNODE_TERMINAL_MAIN_MENU];
    
    // activate terminal
    [_terminalWindow activateWithSpawnPoint:ccp(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f)
                                       size:CGSizeMake(_terminalWindowWidth, _terminalWindowHeight)
                                 parentNode:self
                            spriteBatchNode:spriteBatchNode];
    
    // add us back to swallo touches
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
													 priority:0
											  swallowsTouches:YES];
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
    self._active = false;

    // stop displaying
    [self removeFromParentAndCleanup:false];
    
    // remove sprite batch node
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene]._spriteBatchNodeList objectAtIndex:SPRITEBATCHNODE_INDEX_TERMINAL_MAIN_MENU];
    [spriteBatchNode removeFromParentAndCleanup:false];
    
    // deactivate terminal window and menus
    [_terminalWindow deactivate];
    [_menus makeObjectsPerformSelector:@selector(deactivate)];
    
    // unresgister for touches
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    
    return 0;
}

//
//
//
- (void)openMenu:(MenuScreen)menuScreen {
    
    // fetch menu
    TerminalMenu *terminalMenu = [self getTerminalMenu:menuScreen];
    
    // close all menus
    [_menus makeObjectsPerformSelector:@selector(deactivate)];
    
    // activate menu
    [terminalMenu activateWithPrevMenuScreen:_menuScreen];
    _menuScreen = menuScreen;
}

//
//
//
- (void)closeMenuWithGameMode:(GameMode)gameMode {
    _gameMode = gameMode;
	[_terminalWindow resizeToNewSize:CGSizeZero withAnchorPoint:ccp(0.0f, 1.0f) hideAfterResize:true];
}

//
//
//
- (void)completedResizing:(TerminalWindow *)terminalWindow {
    
    // fetch terminal menu
    TerminalMenu *terminalMenu = [self getTerminalMenu:_menuScreen];
    [terminalMenu activateWithPrevMenuScreen:kMenuScreenUnknown];
}

//
//
//
- (void)completedHiding:(TerminalWindow *)terminalWindow {
    
    // switch to stage layer
    [self deactivate];
    
    // send out notification
    NSDictionary *userInfoDictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_gameMode] forKey:kNotificationKeyMainMenuGameMode];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMainMenuClosed
                                                        object:self
                                                      userInfo:userInfoDictionary];
}

//
// handle touch input
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // drop touch events if terminal window has not completed typing
    // out menu stuff or it's not alive yet
    if (!_terminalWindow._allCommandlineTextIsDisplayed ||
        _terminalWindow._state != kTerminalWindowStateAlive)
    {
        return true;
    }
    
    // let menu's handle the touch
    [_menus makeObjectsPerformSelector:@selector(handleTouchBegan:) withObject:touch];
    
    return true;
}

//
//
//
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [_menus makeObjectsPerformSelector:@selector(handleTouchMoved:) withObject:touch];
}

//
//
//
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_terminalWindow._allCommandlineTextIsDisplayed ||
        _terminalWindow._state != kTerminalWindowStateAlive)
    {
        return;
    }
    
    // let menus handle the touch
    [_menus makeObjectsPerformSelector:@selector(handleTouchEnded:) withObject:touch];
}

//
//
//
- (void)dealloc {
    
    // deactivate
    [self deactivate];
    
    // clean up variables
    self._terminalWindow = nil;
    self._mainMenu = nil;
    self._tutorialMenu = nil;
    self._optionsMenu = nil;
    self._survivalGameOverMenu = nil;
    self._pauseMenu = nil;
    self._creditsMenu = nil;
    self._menus = nil;
    [super dealloc];
}


@end
