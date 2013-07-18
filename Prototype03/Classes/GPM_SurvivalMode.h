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
#import "GamePlayManager.h"

//
// forward declarations
//
@class HUDTopTerminal;
@class PlayerShip;
@class MasterControlSwitch;
@class WaveManager;

//
// @interface GPM_SurvivalMode
//
@interface GPM_SurvivalMode : GamePlayManager {
    
    // game objects
    HUDTopTerminal *_hudTopTerminal;
    
    // player ships
    PlayerShip *_playerShip01;
    PlayerShip *_playerShip02;
    NSArray *_playerShips;
    
    // master control switches
    MasterControlSwitch *_masterControlSwitchWhite;
    MasterControlSwitch *_masterControlSwitchBlack;
    NSArray *_masterControlSwitches;
    
    // wave tracking stuff
    int _waveNumber;
    WaveManager *_waveManager;
    
    // survival mode menu to open when hud closes
    MenuScreen _survivalMenuScreenToOpen;
}

//
// properties
//
@property (nonatomic, retain) HUDTopTerminal *_hudTopTerminal;
@property (nonatomic, retain) PlayerShip *_playerShip01;
@property (nonatomic, retain) PlayerShip *_playerShip02;
@property (nonatomic, retain) NSArray *_playerShips;
@property (nonatomic, retain) MasterControlSwitch *_masterControlSwitchWhite;
@property (nonatomic, retain) MasterControlSwitch *_masterControlSwitchBlack;
@property (nonatomic, retain) NSArray *_masterControlSwitches;
@property (nonatomic, assign) int _waveNumber;
@property (nonatomic, retain) WaveManager *_waveManager;
@property (nonatomic, assign) MenuScreen _survivalMenuScreenToOpen;

//
// initialization
//
- (id)initWithGameMode:(GameMode)gameMode;
- (void)registerForNotifications;

//
// activate/deactivate overrides
//
- (void)activateGamePlay;
- (void)deactivateGamePlay;

//
// notifications
//
- (void)handleWaveTimerStarted:(NSNotification *)notification;
- (void)handleWaveTimerFinished:(NSNotification *)notification;
- (void)handleWaveManagerCompleted:(NSNotificationCenter *)notification;
- (void)handleAllTowersDeactivated:(NSNotification *)notification;
- (void)handleHudTopTerminalCompletedHiding:(NSNotificationCenter *)notification;

//
// cleanup
//
- (void)dealloc;

@end
