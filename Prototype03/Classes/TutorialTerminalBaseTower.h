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

//
// @interface TutorialTerminalBaseTower
//
@interface TutorialTerminalBaseTower : TutorialTerminal
{
    NSMutableSet *_trackingSet;
    int _counter;
}

//
// properties
//
@property (nonatomic, retain) NSMutableSet *_trackingSet;
@property (nonatomic, assign) int _counter;

//
// static initializer
//
+ (id)tutorialTerminalBaseTower;

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
- (void)activateObjChangeBaseTowerColors;
- (void)deactivateObjChangeBaseTowerColors;

- (void)activateObjMasterControlSwitches;
- (void)deactivateObjMasterControlSwitches;

- (void)activateKillSoldiers;
- (void)deactivateKillSoldiers;

- (void)activateObjFinal;

//
// override deactivate
//
- (int)deactivate;

//
// print text
//
- (void)printObjChangeBaseTowerColors;
- (void)printObjMasterControlSwitches;
- (void)printObjKillSoldiers;
- (void)printObjFinal;

//
// overrides
//
- (void)completedMaximizing;

//
// misc helper stuff
//
- (void)spawnSoldierWithColorState:(ColorState)colorState;

//
// handle laser tower events
//
- (void)handleLaserTowerTapped:(NSNotification *)notification;
- (void)handleLaserTowerCompletedSwitchingColorForObjChangeBaseTowerColor:(NSNotification *)notification;
- (void)handleLaserTowerCompletedSwitchingColorForObjMasterConrolSwitches:(NSNotification *)notification;

//
// handle master control switch events
//
- (void)handleLaserGridHandledMasterControlSwitchTap:(NSNotification *)notification;

//
// handle soldier events
//
- (void)handleSoldierDeactivated:(NSNotification *)notification;
- (void)handleSoldierKilledByPlayer:(NSNotification *)notification;

//
// cleanup
//
- (void)dealloc;

@end
