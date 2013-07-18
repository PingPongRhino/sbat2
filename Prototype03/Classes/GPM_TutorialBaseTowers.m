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
#import "GPM_TutorialBaseTowers.h"
#import "MasterControlSwitch.h"
#import "LaserGrid.h"
#import "PathSpriteManager.h"
#import "EnemyManager.h"
#import "MainMenuLayer.h"
#import "TutorialTerminalBaseTower.h"
#import "TutorialPauseTerminal.h"
#import "NotificationStrings.h"

//
// @implementation GPM_TutorialBaseTowers
//
@implementation GPM_TutorialBaseTowers

//
// synthesize
//
@synthesize _tutorialTerminal;
@synthesize _pauseTerminal;
@synthesize _masterControlSwitches;

//
//
//
- (id)initWithGameMode:(GameMode)gameMode {
    self = [super initWithGameMode:gameMode];
    
    self._tutorialTerminal = [TutorialTerminalBaseTower tutorialTerminalBaseTower];
    self._pauseTerminal = [TutorialPauseTerminal tutorialPauseTerminal];
    self._masterControlSwitches = [NSArray arrayWithObjects:[MasterControlSwitch masterControlSwitchWithColorState:kColorStateWhite],
                                                            [MasterControlSwitch masterControlSwitchWithColorState:kColorStateBlack], nil];
    
    return self;
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
    
    // activate tutorial terminal
	[_tutorialTerminal activate];
    [_pauseTerminal activate];
    
    // let laser grid know about our master control switches
    [[LaserGrid sharedLaserGrid] registerMasterControlSwitches:_masterControlSwitches];
    
    // set shared master control switches, don't activate them, tutorial will activate them when it needs them
    [MasterControlSwitch setSharedMasterControlSwitches:_masterControlSwitches];
    
    // register for all towers deactivated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAllLaserTowersDeactivated:)
                                                 name:kNotificationAllLaserTowersDeactivated
                                               object:nil];
    
    // setup touch objects
    [_touchObjectArray addObjectsFromArray:[[LaserGrid sharedLaserGrid] _laserTowers]];
    [_touchObjectArray addObjectsFromArray:_masterControlSwitches];
    [_touchObjectArray addObject:_tutorialTerminal];
    [_touchObjectArray addObject:_pauseTerminal];
    
    // setup low priority objects
    [_touchLowPrioritySet addObject:_tutorialTerminal];
    [_touchLowPrioritySet addObject:_pauseTerminal];
}

//
//
//
- (void)deactivateGamePlay {
    
    // deactivate stuff
    [_tutorialTerminal deactivate];
    [_pauseTerminal deactivate];
    [PathSpriteManager destroySharedPathSpriteManager];
    [EnemyManager destroySharedEnemyManager];
    [_masterControlSwitches makeObjectsPerformSelector:@selector(deactivate)];
    [MasterControlSwitch setSharedMasterControlSwitches:nil];
    
    // unregister
    [[LaserGrid sharedLaserGrid] unregisterMasterControlSwitches:_masterControlSwitches];
    
    // unregister for events
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
//
//
- (void)handleAllLaserTowersDeactivated:(NSNotification *)notification {
    // reset laser towers
    [[LaserGrid sharedLaserGrid] reset];
    
    // tell all enemies to recalc their targets and wake up
    [[EnemyManager sharedEnemyManager] recalcPathsAndTargets];
}

//
//
//
- (void)dealloc {
    self._tutorialTerminal = nil;
    self._pauseTerminal = nil;
    self._masterControlSwitches = nil;
    [super dealloc];
}

@end
