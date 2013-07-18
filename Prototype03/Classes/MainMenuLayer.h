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
#import "cocos2d.h"
#import "protocols.h"
#import "defines.h"

//
// forward declarations
//
@class MainMenuLayer;
@class TerminalWindow;
@class TerminalMenu;
@class TerminalMenuMain;
@class TerminalMenuOptions;
@class TerminalMenuSurvivalGameOver;
@class TerminalMenuPause;
@class TerminalMenuTutorial;
@class TerminalMenuCredits;

//
// @interface MainMenuLayer
//
@interface MainMenuLayer : CCLayer <TerminalWindowProtocol> {
    TerminalWindow *_terminalWindow;
    bool _active;
    MenuScreen _menuScreen;
    GameMode _gameMode;
    u_int64_t _gameScore;
    u_int64_t _gameScoreWithoutCompletionBonus;
    TerminalMenuMain *_mainMenu;
    TerminalMenuTutorial *_tutorialMenu;
    TerminalMenuOptions *_optionsMenu;
    TerminalMenuSurvivalGameOver *_survivalGameOverMenu;
    TerminalMenuPause *_pauseMenu;
    TerminalMenuCredits *_creditsMenu;
    NSArray *_menus;
}

//
// properties
//
@property (nonatomic, retain) TerminalWindow *_terminalWindow;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) MenuScreen _menuScreen;
@property (nonatomic, assign) GameMode _gameMode;
@property (nonatomic, assign) u_int64_t _gameScore;
@property (nonatomic, assign) u_int64_t _gameScoreWithoutCompletionBonus;
@property (nonatomic, retain) TerminalMenuMain *_mainMenu;
@property (nonatomic, retain) TerminalMenuTutorial *_tutorialMenu;
@property (nonatomic, retain) TerminalMenuOptions *_optionsMenu;
@property (nonatomic, retain) TerminalMenuSurvivalGameOver *_survivalGameOverMenu;
@property (nonatomic, retain) TerminalMenuPause *_pauseMenu;
@property (nonatomic, retain) TerminalMenuCredits *_creditsMenu;
@property (nonatomic, retain) NSArray *_menus;

//
// static functions
//
+ (MainMenuLayer *)createSharedMainMenuLayer;
+ (MainMenuLayer *)sharedMainMenuLayer;
+ (void)destroyMainMenuLayer;

//
// initilization
//
- (id)init;
- (TerminalWindow *)createTerminalWindow;

//
// fetch menu
//
- (TerminalMenu *)getTerminalMenu:(MenuScreen)menuScreen;

//
// activate/deactivate
//
- (int)activateWithMenuScreen:(MenuScreen)menuScreen;
- (int)deactivate;

//
// managed transistions
//
- (void)openMenu:(MenuScreen)menuScreen;
- (void)closeMenuWithGameMode:(GameMode)gameMode;

//
// TerminalWindowProtocol
//
- (void)completedResizing:(TerminalWindow *)terminalWindow;
- (void)completedHiding:(TerminalWindow *)terminalWindow;

//
// handle touch input
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

//
// cleaaup
//
- (void)dealloc;

@end
