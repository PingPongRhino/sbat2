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
#import "GamePlayManager.h"

//
// forward declarations
//
@class TutorialTerminalMobileTower;
@class TutorialPauseTerminal;

//
// @interface GPM_TutorialMobileTower
//
@interface GPM_TutorialMobileTower : GamePlayManager {
    TutorialTerminalMobileTower *_tutorialTerminal;
    TutorialPauseTerminal *_pauseTerminal;
    NSArray *_masterControlSwitches;
    NSArray *_playerShips;
}

//
// properties
//
@property (nonatomic, retain) TutorialTerminalMobileTower *_tutorialTerminal;
@property (nonatomic, retain) TutorialPauseTerminal *_pauseTerminal;
@property (nonatomic, retain) NSArray *_masterControlSwitches;
@property (nonatomic, retain) NSArray *_playerShips;

//
//
//

//
// methods
//
- (id)initWithGameMode:(GameMode)gameMode;
- (void)activateGamePlay;
- (void)deactivateGamePlay;
- (void)handleAllLaserTowersDeactivated:(NSNotification *)notification;
- (void)dealloc;

@end