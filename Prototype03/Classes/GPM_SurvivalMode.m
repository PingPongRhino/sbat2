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
#import "GPM_SurvivalMode.h"
#import "HUDTopTerminal.h"
#import "ScoreManager.h"
#import "EnemyManager.h"
#import "EnemyDropManager.h"
#import "PathSpriteManager.h"
#import "StageLayer.h"
#import "LaserGrid.h"
#import "MasterControlSwitch.h"
#import "PlayerShip.h"
#import "NotificationStrings.h"
#import "MainMenuLayer.h"
#import "WaveManager.h"
#import "LeaderboardMgr.h"
#import "defines.h"

//
// static globals
//
static const int _maxWaveNumber = 10;

//
// @implementation GPM_SurvivalMode
//
@implementation GPM_SurvivalMode

//
// synthesize
//
@synthesize _hudTopTerminal;
@synthesize _playerShip01;
@synthesize _playerShip02;
@synthesize _playerShips;
@synthesize _masterControlSwitchWhite;
@synthesize _masterControlSwitchBlack;
@synthesize _masterControlSwitches;
@synthesize _waveNumber;
@synthesize _waveManager;
@synthesize _survivalMenuScreenToOpen;

//
//
//
- (id)initWithGameMode:(GameMode)gameMode {
    self = [super initWithGameMode:gameMode];
    
    self._hudTopTerminal = [HUDTopTerminal hudTopTerminal];
    self._playerShip01 = [PlayerShip playerShipWithCharacterType:kCharacterTypeBangoBlue];
    self._playerShip02 = [PlayerShip playerShipWithCharacterType:kCharacterTypeSpinLock];
    self._playerShips = [NSArray arrayWithObjects:_playerShip01, _playerShip02, nil];
    self._masterControlSwitchWhite = [MasterControlSwitch masterControlSwitchWithColorState:kColorStateWhite];
    self._masterControlSwitchBlack = [MasterControlSwitch masterControlSwitchWithColorState:kColorStateBlack];
    self._masterControlSwitches = [NSSet setWithObjects:_masterControlSwitchWhite, _masterControlSwitchBlack, nil];
    self._waveNumber = 0;
    self._waveManager = nil;
    self._survivalMenuScreenToOpen = kMenuScreenUnknown;
    
    return self;
}

//
//
//
- (void)registerForNotifications {
    
    // wave timer notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWaveTimerStarted:)
                                                 name:kNotificationWaveTimerStarted
                                               object:_hudTopTerminal._waveTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWaveTimerFinished:)
                                                 name:kNotificationWaveTimerFinished
                                               object:_hudTopTerminal._waveTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWaveManagerCompleted:)
                                                 name:kNotificationWaveManagerCompleted
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAllTowersDeactivated:)
                                                 name:kNotificationAllLaserTowersDeactivated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleHudTopTerminalCompletedHiding:)
                                                 name:kNotificationHudTopTerminalCompletedHiding
                                               object:_hudTopTerminal];
}

//
//
//
- (void)activateGamePlay {
            
    // activate path sprite manager
    [PathSpriteManager createSharedPathSpriteManager];
    [[PathSpriteManager sharedPathSpriteManager] activate];
	
    // create shared enemy manager
    [EnemyManager createSharedEnemyManager];
    
    // create enemy drop manager
    [EnemyDropManager createSharedEnemyDropManager];
    
    // create shared score manager
    [ScoreManager createShreadScoreManager];
    
    // activate players
    CGPoint spawnPoint01 = [PlayerShip defaultSpawnPointForPlayerShip:1];
    CGPoint spawnPoint02 = [PlayerShip defaultSpawnPointForPlayerShip:2];
    [_playerShip01 activateWithSpawnPoint:spawnPoint01
                                   target:spawnPoint02
                              partnerShip:_playerShip02
                    masterControlSwitches:_masterControlSwitches];
    [_playerShip02 activateWithSpawnPoint:spawnPoint02
                                   target:spawnPoint01
                              partnerShip:_playerShip01
                    masterControlSwitches:_masterControlSwitches];
    [PlayerShip setSharedPlayerShips:_playerShips];
    
    // activate master control switches
    [_masterControlSwitches makeObjectsPerformSelector:@selector(activate)];
    [MasterControlSwitch setSharedMasterControlSwitches:_masterControlSwitches];
    
    // display top terminal score board/wave timer
    [_hudTopTerminal activateWithScoreManager:[ScoreManager sharedScoreManager]];
    
    // let laser grid know about our master control switches
    [[LaserGrid sharedLaserGrid] registerMasterControlSwitches:_masterControlSwitches];
        
    // setup touch objects
    [_touchObjectArray addObjectsFromArray:_playerShips];
    [_touchObjectArray addObjectsFromArray:[[LaserGrid sharedLaserGrid] _laserTowers]];
    [_touchObjectArray addObjectsFromArray:_masterControlSwitches];
    [_touchObjectArray addObject:_hudTopTerminal];
    
    // setup low priority objects
    [_touchLowPrioritySet addObject:_hudTopTerminal];
    
    // register for notifications
    [self registerForNotifications];
}

//
//
//
- (void)deactivateGamePlay {
    
    // kill wave manager
    [_waveManager deactivate];
    self._waveManager = nil;
    
    // report score to game center
    [[LeaderboardMgr sharedLeaderboardMgr] reportScore:[[ScoreManager sharedScoreManager] _score] forCategory:kLeaderBoardCategorySurvial01];
    
    // deactivate stuff
    [PathSpriteManager destroySharedPathSpriteManager];
    [EnemyManager destroySharedEnemyManager];
    [EnemyDropManager destroySharedEnemyDropManager];
    [ScoreManager destroySharedScoreManager];
    [_playerShips makeObjectsPerformSelector:@selector(deactivate)];
    [PlayerShip setSharedPlayerShips:nil];
    [_masterControlSwitches makeObjectsPerformSelector:@selector(deactivate)];
    [MasterControlSwitch setSharedMasterControlSwitches:nil];
    [_hudTopTerminal deactivate];
    
    // unregister
    [[LaserGrid sharedLaserGrid] unregisterMasterControlSwitches:_masterControlSwitches];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
//
//
- (void)handleWaveTimerStarted:(NSNotification *)notification {
        
    // start next wave
    _waveNumber++;
    Class waveManagerClass = NSClassFromString([NSString stringWithFormat:@"WaveManager%02d", _waveNumber]);
    WaveManager *waveManager = [[waveManagerClass alloc] initWithWaveNumber:_waveNumber];
    self._waveManager = waveManager;
    [waveManager release];
    
    [_waveManager activate];
    
    // set score multiplier
    [[ScoreManager sharedScoreManager] set_levelMultiplier:_waveNumber];
    
    // update hud to indicate wave
    [_hudTopTerminal refreshWaveLabelWithWave:_waveNumber];
}

//
// desc: if they didn't clear wave in time, then game over
//
- (void)handleWaveTimerFinished:(NSNotification *)notification {
    _survivalMenuScreenToOpen = kMenuScreenSurvivalOutOfTime;
    [_hudTopTerminal hideTerminal];
}

//
//
//
- (void)handleAllTowersDeactivated:(NSNotificationCenter *)notification {
    _survivalMenuScreenToOpen = kMenuScreenSurvivalTowersDestroyed;
    [_hudTopTerminal hideTerminal];
}

//
//
//
- (void)handleWaveManagerCompleted:(NSNotificationCenter *)notification {
    self._waveManager = nil;
    
    // see if they won
    if (_waveNumber >= _maxWaveNumber) {
        _survivalMenuScreenToOpen = kMenuScreenSurvivalCompleted;
        [[ScoreManager sharedScoreManager] addCompletionBonus];
        [_hudTopTerminal hideTerminal];
        [_hudTopTerminal stopWaveTimer];
        return;
    }
    
    [_hudTopTerminal resetWaveTimer];
}

//
//
//
- (void)handleHudTopTerminalCompletedHiding:(NSNotificationCenter *)notification {
    // TODO: open different menu screen based on if they won or not (completed all the waves)
    [[MainMenuLayer sharedMainMenuLayer] activateWithMenuScreen:_survivalMenuScreenToOpen];
    [self deactivate];
}

//
//
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._hudTopTerminal = nil;
    self._playerShip01 = nil;
    self._playerShip02 = nil;
    self._playerShips = nil;
    self._masterControlSwitchWhite = nil;
    self._masterControlSwitchBlack = nil;
    self._masterControlSwitches = nil;
    self._waveManager = nil;
    [super dealloc];
}


@end
