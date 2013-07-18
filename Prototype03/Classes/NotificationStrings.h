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

#ifndef _NOTIFICATIONSTRINGS_H_
#define _NOTIFICATIONSTRINGS_H_

//
// player ship notifications
//
static NSString * const kNotificationPlayerLaserEmitterColorStateChanged = @"kNotificationPlayerLaserEmitterColorStateChanged";
static NSString * const kNotificationPlayerShipPositionChanged = @"kNotificationPlayerShipPositionChanged";
static NSString * const kNotificationPlayerShipCompletedSwitchingColor = @"kNotificationPlayerShipCompletedSwitchingColor";

//
// laser tower notifications
//
static NSString * const kNotificationLaserTowerTapped = @"kNotificationLaserTowerTapped";
static NSString * const kNotificationLaserTowerCompletedSwitchingColor = @"kNotificationLaserTowerCompletedSwitchingColor";
static NSString * const kNotificationLaserTowerExploding = @"kNotificationLaserTowerExploding";
static NSString * const kNotificationLaserTowerDeactivated = @"kNotificationLaserTowerDeactivated";
static NSString * const kNotificationGearSwitchDeactivated = @"kNotificationGearSwitchDeactivated";
static NSString * const kNotificationAllLaserTowersDeactivated = @"kNotificationAllLaserTowersDeactivated";
static NSString * const kNotificationLaserGridHandledMasterControlSwitchTap = @"kNotificationLaserGridHandledMasterControlSwitchTap";

//
// master control switch notifications
//
static NSString * const kNotificationMasterControlSwitchTapped = @"kNotificationMasterControlSwitchTapped";

//
// soldier notifications
//
static NSString * const kNotificationSoldierKilledByPlayer = @"kNotificationSoldierKilledByPlayer";
static NSString * const kNotificationSoldierDeactivated = @"kNotificationSoldierDeactivated";

//
// soldier factory notifications
//
static NSString * const kNotificationSoldierFactoryKilledByPlayer = @"kNotificationintSoldierFactoryKilledByPlayer";
static NSString * const kNotificationSoldierFactoryDeactivated = @"kNotificationSoldierFactoryDeactivated";

//
// enemy drop notifications
//
static NSString * const kNotificationEnemyDropDeactivated = @"kNotificationEnemyDropDeactivated";
static NSString * const kNotificationEnemyDropActivated = @"kNotificationEnemyDropActivated";

//
// way point notifications
//
static NSString * const kNotificationWayPointShipsInWayPointChanged = @"kNotificationShipsInWayPointChanged";

//
// main menu notifications
//
static NSString * const kNotificationMainMenuClosed = @"kNotificationMainMenuClosed";
static NSString * const kNotificationKeyMainMenuGameMode = @"kNotificationKeyMainMenuGameMode";

//
// game play manager notifications
//
static NSString * const kNotificationGamePlayManagerDeactivated = @"kNotificationGamePlayManagerDeactivated";

//
// laser emitter notifications
//
static NSString * const kNotificationLaserEmitterDeactivated = @"kNotificationLaserEmitterDeactivated";
static NSString * const kNotificationLaserSwitchEmitterDeactivated = @"kNotificationLaserSwitchEmitterDeactivated";

//
// score manager notifications
//
static NSString * const kNotificationScoreManagerScoreChanged = @"kNotificationScoreManagerScoreChanged";

//
// wave timer notifications
//
static NSString * const kNotificationWaveTimerStarted = @"kNotificationWaveTimerStarted";
static NSString * const kNotificationWaveTimerFinished = @"kNotificationWaveTimerFinished";

//
// wave manager notfications
//
static NSString * const kNotificationWaveManagerCompleted = @"kNotificationWaveManagerCompleted";

//
// survival mode hud notifications
//
static NSString * const kNotificationHudTopTerminalCompletedHiding = @"kNotificationHudTopTerminalCompletedHiding";

#endif // #ifndef _NOTIFICATIONSTRINGS_H_
