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
#import "TutorialTerminalBaseTower.h"
#import "TerminalWindow.h"
#import "LabelAnimateType.h"
#import "TerminalLabel.h"
#import "StageScene.h"
#import "StageLayer.h"
#import "LaserTower.h"
#import "LaserGrid.h"
#import "MasterControlSwitch.h"
#import "Soldier.h"
#import "ColorStateManager.h"
#import "NotificationStrings.h"
#import "EnemyManager.h"
#import "SpriteFrameManager.h"

//
// objective enum
//
enum {
    kObjUnknown                 = -1,
    kObjChangeBaseTowerColors   =  0,
    kObjMasterControlSwitches   =  1,
    kObjKillSoldiers            =  2,
    kObjFinal                   =  3,
    kObjCount                   =  4
};

//
// @implementation TutorialTerminalBaseTower
//
@implementation TutorialTerminalBaseTower

//
// synthesize
//
@synthesize _trackingSet;
@synthesize _counter;

//
//
//
+ (id)tutorialTerminalBaseTower {
	TutorialTerminalBaseTower *tutorialTerminalBaseTower = [[TutorialTerminalBaseTower alloc] init];
	return [tutorialTerminalBaseTower autorelease];
}

//
//
//
- (id)init {
	self = [super init];
    
    // init properties
    self._trackingSet = nil;
    self._counter = 0;
    
    // activate first objective
    [self activateObjChangeBaseTowerColors];
    
	return self;
}

//
//
//
- (NSString *)minStringForCurrentObjective {
    switch (_currentObjective) {
        case kObjChangeBaseTowerColors: return [NSString stringWithFormat:@"%d/8 base towers = black", [_trackingSet count]];
        case kObjMasterControlSwitches: return [NSString stringWithFormat:@"%d/2 master switches hit", [_trackingSet count]];
        case kObjKillSoldiers:          return [NSString stringWithFormat:@"%d/8 emissions destroyed", _counter];
        default: break;
    }
    
    return @"objectives = completed;";
}

//
//
//
- (void)activateObjChangeBaseTowerColors {
    // set up properties
    _currentObjective = kObjChangeBaseTowerColors;
    self._trackingSet = [NSMutableSet set];
        
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerTapped:)
                                                 name:kNotificationLaserTowerTapped
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerCompletedSwitchingColorForObjChangeBaseTowerColor:)
                                                 name:kNotificationLaserTowerCompletedSwitchingColor
                                               object:nil];
    // set min text
    [self refreshMinimizedText];
}

//
//
//
- (void)deactivateObjChangeBaseTowerColors {
    // cleanup properties we used
    self._trackingSet = nil;
    
    // unregsiter events
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // activate next obj and maximize
    [self activateObjMasterControlSwitches];
    [self maximize];
}

//
//
//
- (void)activateObjMasterControlSwitches {
    // set up properties
    _currentObjective = kObjMasterControlSwitches;
    self._trackingSet = [NSMutableSet set];
    
    // activate master control switches
    [[MasterControlSwitch sharedMasterControlSwitches] makeObjectsPerformSelector:@selector(activate)];
    
    // register for master control switch events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserGridHandledMasterControlSwitchTap:)
                                                 name:kNotificationLaserGridHandledMasterControlSwitchTap
                                               object:nil];
    
    // register for laser tower events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerCompletedSwitchingColorForObjMasterConrolSwitches:)
                                                 name:kNotificationLaserTowerCompletedSwitchingColor
                                               object:nil];
    
    [self refreshMinimizedText];
}

//
//
//
- (void)deactivateObjMasterControlSwitches {
    // cleanup properties we used
    self._trackingSet = nil;
    
    // unregister for events
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // activate next objective and maximize
    [self activateKillSoldiers];
    [self maximize];
}

//
//
//
- (void)activateKillSoldiers {
    _currentObjective = kObjKillSoldiers;
    self._trackingSet = [NSMutableSet set];
    _counter = 0;
    
    // register for soldier notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSoldierKilledByPlayer:)
                                                 name:kNotificationSoldierKilledByPlayer
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSoldierDeactivated:)
                                                 name:kNotificationSoldierDeactivated
                                               object:nil];
    
    // refresh min text
    [self refreshMinimizedText];
    
    // spawn first solider
    [self spawnSoldierWithColorState:kColorStateWhite];
}

//
//
//
- (void)deactivateKillSoldiers {
    
    // cleanup properties we used
    self._trackingSet = nil;
    _counter = 0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // activate final objective
    [self activateObjFinal];
}

//
//
//
- (void)activateObjFinal {
    _currentObjective = kObjFinal;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSoldierDeactivated:)
                                                 name:kNotificationSoldierDeactivated
                                               object:nil];
    [self refreshMinimizedText];
    [self maximize];
}

//
//
//
- (int)deactivate {
    int retCode = [super deactivate];
    if (retCode == 0) {
        // remove us from notification center
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    return retCode;
}

//
//
//
- (void)printObjChangeBaseTowerColors {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    // terminal lable with base tower icon
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"Tap on a base tower {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager baseTowerIconSpriteWithCharacter:kCharacterTypeCoco]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"to switch its' color."];
    [_terminalWindow addCommandLineText:@"Switch all 8 base towers to"];
    [_terminalWindow addCommandLineText:@"black by tapping on them."];
    
    // spacing
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    
    // commands
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)printObjMasterControlSwitches {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    [_terminalWindow addCommandLineText:@"Tap on white master control"];
    
    // description text
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"switch {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager masterControlSwitchIconSpriteWithColorState:kColorStateWhite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} to switch all"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    [_terminalWindow addCommandLineText:@"base towers to white.  Tap"];
    
    [_terminalWindow addCommandLineText:@"on black master control"];
    
    terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"switch {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager masterControlSwitchIconSpriteWithColorState:kColorStateBlack]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} to switch all"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    [_terminalWindow addCommandLineText:@"base towers to black.  Tap"];
    [_terminalWindow addCommandLineText:@"on both master control"];
    [_terminalWindow addCommandLineText:@"switches."];
    
    // commands
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)printObjKillSoldiers {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    // description text
    [_terminalWindow addCommandLineText:@"Destroy white emissions"];
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"{"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager soldierIconSpriteWithColorState:kColorStateWhite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} by hitting them with"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"a white beam.  Destroy black"];
    
    terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"emissions {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager soldierIconSpriteWithColorState:kColorStateBlack]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} by hitting"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"them with a black beam."];
    [_terminalWindow addCommandLineText:@"Emissions will shake when"];
    [_terminalWindow addCommandLineText:@"they take damage.  Destroy"];
    [_terminalWindow addCommandLineText:@"8 emissions."];
    
    // commands
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)printObjFinal {
    // current status
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"If an emission {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager soldierIconSpriteWithColorState:kColorStateWhite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"touches a base tower {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager baseTowerIconSpriteWithCharacter:kCharacterTypeCoco]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"then the base tower will"];
    
    terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"lose one health {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager healthIconSprite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}.  Don't"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"let the emissions reach your"];
    [_terminalWindow addCommandLineText:@"towers!  Minimize to"];
    [_terminalWindow addCommandLineText:@"continue playing with base"];
    [_terminalWindow addCommandLineText:@"towers."];
    
    // commands
    [_terminalWindow addCommandLineText:@" "];
    [self setupReturnToTutorialMenuLabel];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)completedMaximizing {
    
    switch (_currentObjective) {
        case kObjChangeBaseTowerColors: [self printObjChangeBaseTowerColors]; break;
        case kObjMasterControlSwitches: [self printObjMasterControlSwitches]; break;
        case kObjKillSoldiers:          [self printObjKillSoldiers]; break;
        default:                        [self printObjFinal]; break;
    }
}

//
//
//
- (void)spawnSoldierWithColorState:(ColorState)colorState {
    
    EnemyManager *enemyManager = [EnemyManager sharedEnemyManager];
    [enemyManager spawnSoldierWithSpawnPoint:[enemyManager randomSpawnPoint]
                                  colorState:colorState
                               queueInterval:0.0f
                                idleInterval:0.0f];    
}

//
//
//
- (void)handleLaserTowerTapped:(NSNotification *)notification {
    
    LaserTower *laserTower = (LaserTower *)[notification object];
    
    // if they switched it to black, then add it to tracking set
    // else remove it from the tracking set
    if (laserTower._colorState == kColorStateBlack) {
        [_trackingSet addObject:laserTower];
    }
    else {
        [_trackingSet removeObject:laserTower];
    }
    
    // if not completed, then update min text
    if ([_trackingSet count] < 8) {
        [self refreshMinimizedText];
        return;
    }
    
    // if completed and nobody is changing states, then complete
    if ([[LaserGrid sharedLaserGrid] allTowersHaveCompletedColorSwitch]) {
        [self deactivateObjChangeBaseTowerColors];
        return;
    }
}

//
//
//
- (void)handleLaserTowerCompletedSwitchingColorForObjChangeBaseTowerColor:(NSNotification *)notification {
    
    // fetch laser tower
    LaserTower *laserTower = (LaserTower *)[notification object];
    
    // if this tower switched back to whiter, then remove him from the set
    if (laserTower._colorState == kColorStateWhite) {
        [_trackingSet removeObject:laserTower];
        [self refreshMinimizedText];
    }
    
    // if all towers were last switched to black and they have all completed switching color animation
    // then go to next objective
    if ([_trackingSet count] >= 8 && [[LaserGrid sharedLaserGrid] allTowersHaveCompletedColorSwitch]) {
        [self deactivateObjChangeBaseTowerColors];
    }
}

//
//
//
- (void)handleLaserTowerCompletedSwitchingColorForObjMasterConrolSwitches:(NSNotification *)notification {
        
    // if they hit both master control switches and all towers have completed switching colors
    // then deactivate objective
    if ([_trackingSet count] >= 2 && [[LaserGrid sharedLaserGrid] allTowersHaveCompletedColorSwitch]) {
        [self deactivateObjMasterControlSwitches];
    }
}

//
//
//
- (void)handleLaserGridHandledMasterControlSwitchTap:(NSNotification *)notification {
    
    MasterControlSwitch *masterControlSwitch = (MasterControlSwitch *)[notification object];
    [_trackingSet addObject:masterControlSwitch];
    
    // if not done, update min text
    if ([_trackingSet count] < 2) {
        [self refreshMinimizedText];
        return;
    }
    
    // if all the towers aren't switching, then switch to next objective
    if ([[LaserGrid sharedLaserGrid] allTowersHaveCompletedColorSwitch]) {
        [self deactivateObjMasterControlSwitches];
        return;
    }
}

//
//
//
- (void)handleSoldierDeactivated:(NSNotification *)notification {
    
    Soldier *soldier = (Soldier *)[notification object];
    
    // if we are still active, then spawn another
    if (_active) {
        [self spawnSoldierWithColorState:[ColorStateManager nextColorState:soldier._colorState]];
    }
}

//
//
//
- (void)handleSoldierKilledByPlayer:(NSNotification *)notification {

    // update counter and refresh min text
    _counter++;
    [self refreshMinimizedText];
    
    // if we are done, deactivate
    if (_counter >= 8) {
        [self deactivateKillSoldiers];
    }
}

//
//
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._trackingSet = nil;
	[super dealloc];
}


@end
