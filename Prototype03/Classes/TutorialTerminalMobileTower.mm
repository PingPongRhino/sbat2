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
#import "TutorialTerminalMobileTower.h"
#import "TerminalLabel.h"
#import "TerminalWindow.h"
#import "WayPoint.h"
#import "EnemyManager.h"
#import "StageLayer.h"
#import "StageScene.h"
#import "PlayerShip.h"
#import "LaserEmitter.h"
#import "SoldierFactory.h"
#import "ColorStateManager.h"
#import "EnemyDropManager.h"
#import "EnemyDrop.h"
#import "NotificationStrings.h"
#import "SpriteFrameManager.h"
#import "LaserGrid.h"

//
// objectives
//
enum {
    kObjUnknown             = -1,
    kObjWayPoints           =  0,
    kObjMobileBeams         =  1,
    kObjSoldierFactories    =  2,
    kObjFactoryBarriers     =  3,
    kObjPowerUps            =  4,
    kObjFinal               =  5,
    kObjCount               =  6
};

//
// @implementation TutorialTerminalMobileTower
//
@implementation TutorialTerminalMobileTower

//
// synthesize
//
@synthesize _trackingSet01;
@synthesize _trackingSet02;
@synthesize _wayPoints;
@synthesize _counter;
@synthesize _playerShips;

//
//
//
+ (id)tutorialTerminalMobileTower {
    TutorialTerminalMobileTower *tutorialTerminalMobileTower = [[TutorialTerminalMobileTower alloc] init];
    return [tutorialTerminalMobileTower autorelease];
}

//
// initialization
//
- (id)init {
    self = [super init];
    self._trackingSet01 = nil;
    self._trackingSet02 = nil;
    self._wayPoints = nil;
    self._counter = 0;
    self._playerShips = nil;
    
    // activate first objective
    [self activateObjWayPoints];
    return self;
}

//
//
//
- (NSString *)minStringForCurrentObjective {
    switch (_currentObjective) {
        case kObjWayPoints:         return [NSString stringWithFormat:@"%d/2 waypoints active", [_trackingSet01 count]];
        case kObjMobileBeams:       return [NSString stringWithFormat:@"%d/3 white, %d/3 black beams", [_trackingSet01 count], [_trackingSet02 count]];
        case kObjSoldierFactories:
        case kObjFactoryBarriers:   return [NSString stringWithFormat:@"%d/6 generators killed", _counter];
        case kObjPowerUps:          return [NSString stringWithFormat:@"%d/6 powerups activated", _counter];
        default: break;
    }
    
    return @"objectives = completed;";
}

//
//
//
- (void)activateObjWayPoints {
    
    _currentObjective = kObjWayPoints;
    self._trackingSet01 = [NSMutableSet set];
    [self refreshMinimizedText];
    
    // create way points
    self._wayPoints = [NSMutableArray array];
    for (int i=0; i < 2; i++) {
        WayPoint *wayPoint = [WayPoint wayPoint];
        [_wayPoints addObject:wayPoint];
    }
    
    EnemyManager *enemyManager = [EnemyManager sharedEnemyManager];
    [[_wayPoints objectAtIndex:0] activateWithSpawnPosition:ccp(CGRectGetMinX(enemyManager._rect) + 20.0f,
                                                                CGRectGetMinY(enemyManager._rect) + 20.0f)];
    [[_wayPoints objectAtIndex:1] activateWithSpawnPosition:ccp(CGRectGetMaxX(enemyManager._rect) - 20.0f,
                                                                CGRectGetMaxY(enemyManager._rect) - 20.0f)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleShipsInWayPointChanged:)
                                                 name:kNotificationWayPointShipsInWayPointChanged
                                               object:nil];
}

//
//
//
- (void)deactivateObjWayPoints {
    
    // kill the way points
    for (WayPoint *wayPoint in _wayPoints) {
        [wayPoint deactivate];
    }
    
    // unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // cleanup stuff we used
    self._trackingSet01 = nil;
    self._wayPoints = nil;
    
    // activate next objective
    [self activateObjMobileBeams];
}

//
//
//
- (void)activateObjMobileBeams {
    
    // set to objective 1
    _currentObjective = kObjMobileBeams;
    
    // init tracking sets
    self._trackingSet01 = [NSMutableSet set];
    self._trackingSet02 = [NSMutableSet set];
        
    // initialize tracking player ships
    for (PlayerShip *playerShip in _playerShips) {
        [self handlePlayerShipLaserEmitterColorStateChanged:[NSNotification notificationWithName:nil object:playerShip]];
    }
   
    // register for notifications from ships
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerShipLaserEmitterColorStateChanged:)
                                                 name:kNotificationPlayerLaserEmitterColorStateChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlayerShipCompletedSwitchingColor:)
                                                 name:kNotificationPlayerShipCompletedSwitchingColor
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLaserTowerCompletedSwitchingColor:)
                                                 name:kNotificationLaserTowerCompletedSwitchingColor
                                               object:nil];

    // set minimized text and maximize
    [self refreshMinimizedText];
    [self maximize];
}

//
//
//
- (void)deactivateObjMobileBeams {

    // cleanup observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // cleanup stuff we used
    self._trackingSet01 = nil;
    self._trackingSet02 = nil;
    
    // activate next objective
    [self activateObjSoldierFactories];
}

//
//
//
- (void)activateObjSoldierFactories {
    _currentObjective = kObjSoldierFactories;
    _counter = 0;
    
    // spawn first soldier factory
    [self spawnSoldierFactoryWithColorState:kColorStateWhite];
    
    // refresh minimized text
    [self refreshMinimizedText];
    [self maximize];
}

//
//
//
- (void)deactivateObjSoldierFactories {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self activateObjFactoryBarriers];
}

//
//
//
- (void)activateObjFactoryBarriers {
    _currentObjective = kObjFactoryBarriers;
    _counter = 0;
    
    [self spawnSoldierFactoryWithColorState:kColorStateWhite];
    [self refreshMinimizedText];
    [self maximize];
}

//
//
//
- (void)deactivateObjFactoryBarriers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self activateObjPowerUps];
}

//
//
//
- (void)activateObjPowerUps {
    _currentObjective = kObjPowerUps;
    _counter = 0;
    
    // enable enemy drops and set it to drop something 100% of the time
    [EnemyDropManager createSharedEnemyDropManager];
    [[EnemyDropManager sharedEnemyDropManager] setDefaultDropRate];
    [[EnemyDropManager sharedEnemyDropManager] changeEnemyDrop:kEnemyDropTypeNone toNewRate:0.0f];
    
    // register for power up notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnemyDropActivated:)
                                                 name:kNotificationEnemyDropActivated
                                               object:nil];
        
    // start spawning soldier factories
    [self spawnSoldierFactoryWithColorState:kColorStateWhite];
    
    // refresh min text and maximize
    [self refreshMinimizedText];
    [self maximize];
}

//
//
//
- (void)deactivateObjPowerUps {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self activateObjFinal];
}

//
//
//
- (void)activateObjFinal {
    _currentObjective = kObjFinal;
    [[EnemyDropManager sharedEnemyDropManager] setDefaultDropRate];
    
    // register for soldier factory notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSoldierFactoryDeactivated:)
                                                 name:kNotificationSoldierFactoryDeactivated
                                               object:nil];
    
    [self refreshMinimizedText];
    [self maximize];
}

//
//
//
- (int)deactivate {
    
    // deactivate our objects
    for (WayPoint *wayPoint in _wayPoints) {
        [wayPoint deactivate];
    }
    
    int retCode = [super deactivate];
    if (retCode == 0) {
        // remove us from notification center
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [EnemyDropManager destroySharedEnemyDropManager];
    }
    
    return retCode;
}

//
//
//
- (void)printObjWayPoints {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    [_terminalWindow addCommandLineText:@"Tap and drag on a mobile"];
    
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"tower {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager mobileTowerIconSpriteWithShipNumber:1]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager mobileTowerIconSpriteWithShipNumber:2]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} to move"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"the mobile tower."];
    [_terminalWindow addCommandLineText:@"Multi-touch is supported, so"];
    [_terminalWindow addCommandLineText:@"both towers can be moved at"];
    [_terminalWindow addCommandLineText:@"the same time.  Move the"];
    [_terminalWindow addCommandLineText:@"mobile towers to the"];
    
    terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"waypoints {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager wayPointIconSprite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}."]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    // commands
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)printObjMobileBeams {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    [_terminalWindow addCommandLineText:@"Mobile towers work as"];
    [_terminalWindow addCommandLineText:@"repeaters for base towers."];
    [_terminalWindow addCommandLineText:@"Move the mobile tower into"];
    [_terminalWindow addCommandLineText:@"a base tower beam to add"];
    [_terminalWindow addCommandLineText:@"the base tower beam"];
    [_terminalWindow addCommandLineText:@"to the mobile tower."];
    [_terminalWindow addCommandLineText:@"Fire 3 white beams and"];
    [_terminalWindow addCommandLineText:@"3 black beams from the"];
    [_terminalWindow addCommandLineText:@"mobile towers."];
    
    // commands
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)printObjSoldierFactories {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    [_terminalWindow addCommandLineText:@"Destroy white emission"];
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"generators {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager soldierFactoryIconSpriteWithColorState:kColorStateWhite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} by"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"hitting them with a white"];
    [_terminalWindow addCommandLineText:@"beam.  Destroy black"];
    
    terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"emission generators {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager soldierFactoryIconSpriteWithColorState:kColorStateBlack]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"by hitting them with a black"];

    
    [_terminalWindow addCommandLineText:@"beam.  Generators generate"];
    [_terminalWindow addCommandLineText:@"emissions, take more"];
    [_terminalWindow addCommandLineText:@"damage, and are immobile."];
    [_terminalWindow addCommandLineText:@"Destroy 6 generators"];
    [_terminalWindow addCommandLineText:@"with the mobile towers."];
    
    // commands
    [_terminalWindow addCommandLineText:@""];
    [self setupMinimizeStatusWindowLabel];
}

//
//
//
- (void)printObjFactoryBarriers {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    [_terminalWindow addCommandLineText:@"Some generators have"];
    
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"barriers {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager soldierFactoryBarrierIcon]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"} to"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"protect themselves.  Either"];
    [_terminalWindow addCommandLineText:@"destroy them by hitting the"];
    [_terminalWindow addCommandLineText:@"barrier with the same color"];
    [_terminalWindow addCommandLineText:@"beam or maneuver the mobile"];
    [_terminalWindow addCommandLineText:@"towers to hit the generator"];
    [_terminalWindow addCommandLineText:@"directly and avoid the"];
    [_terminalWindow addCommandLineText:@"barriers."];
        
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
- (void)printObjPowerUps {
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    
    [_terminalWindow addCommandLineText:@"Sometimes enemies will drop"];
    TerminalLabel *terminalLabel = [TerminalLabel terminalLabel];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"power ups {"]];
    [terminalLabel._componentsArray addObject:[SpriteFrameManager powerUpIconSprite]];
    [terminalLabel._componentsArray addObject:[_terminalWindow setupCommandLineText:@"}.  Pick up"]];
    [_terminalWindow addCommandLineLabelTypeObject:terminalLabel];
    
    [_terminalWindow addCommandLineText:@"a power up by touching it"];
    [_terminalWindow addCommandLineText:@"with a mobile tower.  Power"];
    [_terminalWindow addCommandLineText:@"ups will expire if you don't"];
    [_terminalWindow addCommandLineText:@"pick them up fast enough."];
    [_terminalWindow addCommandLineText:@"Pick up 6 power ups."];
    
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
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
    [_terminalWindow addCommandLineText:@"---- readme ----"];
    [_terminalWindow addCommandLineText:@"Mobile towers are"];
    [_terminalWindow addCommandLineText:@"invulnerable to emissions."];
    [_terminalWindow addCommandLineText:@"So don't worry about"];
    [_terminalWindow addCommandLineText:@"avoiding emissions when"];
    [_terminalWindow addCommandLineText:@"moving the mobile towers."];
    [_terminalWindow addCommandLineText:@"Just worry about protecting"];
    [_terminalWindow addCommandLineText:@"those base towers!  Minimize"];
    [_terminalWindow addCommandLineText:@"to continue playing around"];
    [_terminalWindow addCommandLineText:@"with the mobile towers."];
    
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupReturnToTutorialMenuLabel];
    [_terminalWindow addCommandLineText:@" "];
    [_terminalWindow addCommandLineText:@" "];
    [self setupMinimizeStatusWindowLabel];
}

//
// overrides
//
- (void)completedMaximizing {
    
    switch (_currentObjective) {
        case kObjWayPoints:         [self printObjWayPoints]; break;
        case kObjMobileBeams:       [self printObjMobileBeams]; break;
        case kObjSoldierFactories:  [self printObjSoldierFactories]; break;
        case kObjFactoryBarriers:   [self printObjFactoryBarriers]; break;
        case kObjPowerUps:          [self printObjPowerUps]; break;
        default:                    [self printObjFinal]; break;
    }
}

//
//
//
- (void)regsiterForSoldierFactoryNotificationsWithObject:(id)object {
    // register for soldier factory notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSoldierFactoryDeactivated:)
                                                 name:kNotificationSoldierFactoryDeactivated
                                               object:object];
    
    // register for power up notifications
    if (_currentObjective == kObjSoldierFactories ||
        _currentObjective == kObjFactoryBarriers)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSoldierFactoryKilledByPlayer:)
                                                     name:kNotificationSoldierFactoryKilledByPlayer
                                                   object:object];
    }
}

//
//
//
- (void)unregisterForSoldierFactoryNotificationsWithObject:(id)object {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSoldierFactoryDeactivated object:object];
    
    if (_currentObjective == kObjSoldierFactories ||
        _currentObjective == kObjFactoryBarriers)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSoldierFactoryKilledByPlayer object:object];
    }
}

//
//
//
- (void)spawnSoldierFactoryWithColorState:(ColorState)colorState {
    
    EnemyType enemyType = kEnemyTypeSoldierFactory;
    
    switch (_currentObjective) {
        case kObjSoldierFactories:
        case kObjPowerUps: enemyType = kEnemyTypeSoldierFactory; break;
        case kObjFactoryBarriers: enemyType = kEnemyTypeBarrierFactory; break;
        default: enemyType = (arc4random() % 2) ? kEnemyTypeSoldierFactory : kEnemyTypeBarrierFactory; break;
    }
    
    EnemyManager *enemyManager = [EnemyManager sharedEnemyManager];
    id object = [enemyManager spawnSoldierFactoryWithSpawnPoint:[enemyManager randomSpawnPoint]
                                                      enemyType:enemyType
                                                     colorState:colorState
                                                  queueInterval:0.0f
                                                restingInterval:2.5f
                                               spawningInterval:0.1f
                                             spawnEmissionCount:3];
    
    [self regsiterForSoldierFactoryNotificationsWithObject:object];
}

//
//
//
- (bool)completedObjMobileBeams {
    
    // if the either play ship hasn't completed color switch, then we haven't completed
    for (PlayerShip *playerShip in [PlayerShip sharedPlayerShips]) {
        if ([playerShip isSwitchingColor]) {
            return false;
        }
    }
    
    // if a tower has not completed it's color switch, then we haven't completed
    if (![[LaserGrid sharedLaserGrid] allTowersHaveCompletedColorSwitch]) {
        return false;
    }
    
    // check for completed case
    if ([_trackingSet01 count] != 3 || [_trackingSet02 count] != 3) {
        return false;
    }
    
    [self deactivateObjMobileBeams];
    return true;
}

//
//
//
- (void)handleShipsInWayPointChanged:(NSNotification *)notification {
    
    WayPoint *wayPoint = (WayPoint *)[notification object];
    
    if ([wayPoint._playerShipsInWayPoint count] > 0) {
        [_trackingSet01 addObject:wayPoint];
    }
    else {
        [_trackingSet01 removeObject:wayPoint];
    }
    
    // check for completed case
    if ([_trackingSet01 count] >= 2) {
        [self deactivateObjWayPoints];
        return;
    }
    
    // refresh min text
    [self refreshMinimizedText];
}

//
//
//
- (void)handlePlayerShipLaserEmitterColorStateChanged:(NSNotification *)notification {
    
    PlayerShip *playerShip = (PlayerShip *)[notification object];
    
    for (LaserEmitter *laserEmitter in playerShip._laserEmitters) {
        
        // remove from all tracking sets
        [_trackingSet01 removeObject:laserEmitter];
        [_trackingSet02 removeObject:laserEmitter];
        
        // if laser emitter is not active, then don't add him to any tracking set
        if (!laserEmitter._active) {
            continue;
        }
        
        // add to appropriate tracking set
        switch (laserEmitter._colorState) {
            case kColorStateWhite: [_trackingSet01 addObject:laserEmitter]; break;
            case kColorStateBlack: [_trackingSet02 addObject:laserEmitter]; break;
            default: break;
        }        
    }
    
    // refresh min text
    [self refreshMinimizedText];
        
    // check for completed case
    [self completedObjMobileBeams];
}

//
//
//
- (void)handlePlayerShipCompletedSwitchingColor:(NSNotification *)notification {
    [self completedObjMobileBeams];
}

//
//
//
- (void)handleLaserTowerCompletedSwitchingColor:(NSNotification *)notification {
    [self completedObjMobileBeams];
}

//
//
//
- (void)handleSoldierFactoryDeactivated:(NSNotification *)notification {
    
    SoldierFactory *soldierFactory = (SoldierFactory *)[notification object];
    [self unregisterForSoldierFactoryNotificationsWithObject:[notification object]];
    
    if (_active) {
        [self spawnSoldierFactoryWithColorState:[ColorStateManager nextColorState:soldierFactory._colorState]];
    }
}

//
//
//
- (void)handleSoldierFactoryKilledByPlayer:(NSNotification *)notification {
    
    // update count and minimize text
    _counter++;
    [self refreshMinimizedText];
    
    // check to see if we are done
    if (_counter >= 6) {
        
        if (_currentObjective == kObjSoldierFactories) {
            [self deactivateObjSoldierFactories];
        }
        else if (_currentObjective == kObjFactoryBarriers) {
            [self deactivateObjFactoryBarriers];
        }
    }
}

//
//
//
- (void)handleEnemyDropActivated:(NSNotification *)notification {
    _counter++;
    [self refreshMinimizedText];
    if (_counter >= 6) {
        [self deactivateObjPowerUps];
    }
}

//
// cleanup
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._trackingSet01 = nil;
    self._trackingSet02 = nil;
    self._wayPoints = nil;
    self._playerShips = nil;
    [super dealloc];
}

@end
