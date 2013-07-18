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
#import "defines.h"

//
// forward declarations
//
@class WayPoint;
@class PlayerShip;
@class SoldierFactory;
@class EnemyDropManager;
@class EnemyDrop;

//
// @interface TutorialTerminalMobileTower
//
@interface TutorialTerminalMobileTower : TutorialTerminal {
    NSMutableSet *_trackingSet01;
    NSMutableSet *_trackingSet02;
    NSMutableArray *_wayPoints;
    int _counter;
    
    NSArray *_playerShips;
}

//
// properties
//
@property (nonatomic, retain) NSMutableSet *_trackingSet01;
@property (nonatomic, retain) NSMutableSet *_trackingSet02;
@property (nonatomic, retain) NSMutableArray *_wayPoints;
@property (nonatomic, assign) int _counter;
@property (nonatomic, retain) NSArray *_playerShips;

//
// static initializer
//
+ (id)tutorialTerminalMobileTower;

//
// initialization
//
- (id)init;

//
// manage min text
//
- (NSString *)minStringForCurrentObjective;

//
// activate/deactivate objectives
//
- (void)activateObjWayPoints;
- (void)deactivateObjWayPoints;
- (void)activateObjMobileBeams;
- (void)deactivateObjMobileBeams;
- (void)activateObjSoldierFactories;
- (void)deactivateObjSoldierFactories;
- (void)activateObjFactoryBarriers;
- (void)deactivateObjFactoryBarriers;
- (void)activateObjPowerUps;
- (void)deactivateObjPowerUps;
- (void)activateObjFinal;

//
// print objective text
//
- (void)printObjWayPoints;
- (void)printObjMobileBeams;
- (void)printObjSoldierFactories;
- (void)printObjFactoryBarriers;
- (void)printObjFinal;

//
// override deactivate
//
- (int)deactivate;

//
// overrides
//
- (void)completedMaximizing;

//
// misc helpers
//
- (void)regsiterForSoldierFactoryNotificationsWithObject:(id)object;
- (void)unregisterForSoldierFactoryNotificationsWithObject:(id)object;
- (void)spawnSoldierFactoryWithColorState:(ColorState)colorState;
- (bool)completedObjMobileBeams;

//
// notification handlers
//
- (void)handleShipsInWayPointChanged:(NSNotification *)notification;
- (void)handlePlayerShipLaserEmitterColorStateChanged:(NSNotification *)notification;
- (void)handlePlayerShipCompletedSwitchingColor:(NSNotification *)notification;
- (void)handleLaserTowerCompletedSwitchingColor:(NSNotification *)notification;
- (void)handleSoldierFactoryDeactivated:(NSNotification *)notification;
- (void)handleSoldierFactoryKilledByPlayer:(NSNotification *)notification;

//
// cleanup
//
- (void)dealloc;

@end
