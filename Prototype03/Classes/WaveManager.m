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
#import "WaveManager.h"
#import "StageLayer.h"
#import "NotificationStrings.h"
#import "EnemyManager.h"

//
// @implementation WaveManager
//
@implementation WaveManager

//
// synthesize
//
@synthesize _active;
@synthesize _waveNumber;
@synthesize _timer;
@synthesize _timerInterval;
@synthesize _trackingEnemies;
@synthesize _timerCompletedAction;
@synthesize _enemiesDeactivatedAction;
@synthesize _allEnemiesClearedAction;
@synthesize _completedSpawn;

//
//
//
- (id)initWithWaveNumber:(int)waveNumber {
    self = [super init];
    self._active = false;
    self._waveNumber = waveNumber;
    self._timer = 0.0f;
    self._timerInterval = 0.0f;
    self._trackingEnemies = [NSMutableSet set];
    self._timerCompletedAction = nil;
    self._enemiesDeactivatedAction = nil;
    self._allEnemiesClearedAction = nil;
    self._completedSpawn = false;
    [self scheduleUpdate];
    return self;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    _active = true;
    _timer = 0.0f;
    [_trackingEnemies removeAllObjects];
    _completedSpawn = false;
    [[StageLayer sharedStageLayer] addChild:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnemyDeactivated:)
                                                 name:kNotificationSoldierDeactivated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnemyDeactivated:)
                                                 name:kNotificationSoldierFactoryDeactivated
                                               object:nil];
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    _active = false;
    [_trackingEnemies removeAllObjects];
    [self removeFromParentAndCleanup:true];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return 0;
}

//
//
//
- (bool)handleWaveCompleted {
    if (_active &&                                          // if active AND
        _completedSpawn &&                                  //    we have completed spawning all our enemies AND
        [EnemyManager sharedEnemyManager] &&                //    there is still a valid shared enemy manager AND
        ![[EnemyManager sharedEnemyManager] activeEnemies]) //    that enemy manager has no active enemies
    {
        [self deactivate];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWaveManagerCompleted object:self];
        return true;
    }
    
    return false;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // see if we completed
    if ([self handleWaveCompleted]) {
        return;
    }
    
    // if timerCompletedAction is not set, then don't do timer updates
    if (_timerCompletedAction == nil) {
        return;
    }
    
    _timer += elapsedTime;
    if (_timer >= _timerInterval) {
        _timer = 0.0f;
        SEL action = _timerCompletedAction;
        self._timerCompletedAction = nil;
        [self performSelector:action withObject:[EnemyManager sharedEnemyManager]];
    }
}

//
//
//
- (void)handleEnemyDeactivated:(NSNotification *)notification {
    
    // see if we completed
    if ([self handleWaveCompleted]) {
        return;
    }
    
    // remove object from our tracking set
    [_trackingEnemies removeObject:[notification object]];
    
    // check for all enemies cleared
    if (_allEnemiesClearedAction && ![[EnemyManager sharedEnemyManager] activeEnemies]) {
        SEL action = _allEnemiesClearedAction;
        self._allEnemiesClearedAction = nil;
        [self performSelector:action withObject:[EnemyManager sharedEnemyManager]];
    }
    
    // if tracking enemy selector isn't set, then do nothing
    if (_enemiesDeactivatedAction == nil) {
        return;
    }
    
    if ([_trackingEnemies count] <= 0) {
        SEL action = _enemiesDeactivatedAction;
        self._enemiesDeactivatedAction = nil;
        [self performSelector:action withObject:[EnemyManager sharedEnemyManager]];
    }
}

//
// 
//
- (void)dealloc {
    [self deactivate];
    self._trackingEnemies = nil;
    [super dealloc];
}


@end
