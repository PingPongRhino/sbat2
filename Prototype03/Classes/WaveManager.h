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
#import "cocos2d.h"
#import "defines.h"

//
// forward declarations
//
@class EnemyManager;

//
// @interface WaveManager
//
@interface WaveManager : CCNode {
    bool _active;
    int _waveNumber;
    ccTime _timer;
    ccTime _timerInterval;
    NSMutableSet *_trackingEnemies;
    SEL _timerCompletedAction;      // action that will be called when the timer completes
    SEL _enemiesDeactivatedAction;  // action that will be called when all the enemies in _trackingEnemies are deactivated
    SEL _allEnemiesClearedAction;   // action that will be called when all the enemies have been cleared
    bool _completedSpawn;           // set when wave has completed spawning all ememies
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) int _waveNumber;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) ccTime _timerInterval;
@property (nonatomic, retain) NSMutableSet *_trackingEnemies;
@property (nonatomic, assign) SEL _timerCompletedAction;
@property (nonatomic, assign) SEL _enemiesDeactivatedAction;
@property (nonatomic, assign) SEL _allEnemiesClearedAction;
@property (nonatomic, assign) bool _completedSpawn;

//
// methods
//
- (id)initWithWaveNumber:(int)waveNumber;
- (int)activate;
- (int)deactivate;
- (bool)handleWaveCompleted;
- (void)update:(ccTime)elapsedTime;
- (void)handleEnemyDeactivated:(NSNotification *)notification;
- (void)dealloc;

@end
