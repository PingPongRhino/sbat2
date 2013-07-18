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
#import "WaveManager05.h"
#import "EnemyManager.h"
#import "Soldier.h"
#import "ColorStateManager.h"

//
// @implementation WaveManager05
//
@implementation WaveManager05

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    _spawnCounter = 0;
    _currentTimerInterval = 4.0f;
    [self spawnRandomLocation:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnRandomLocation:(EnemyManager *)enemyManager {
    
    if (_spawnCounter >= 40) {
        _completedSpawn = true;
        return;
    }
    _spawnCounter++;
    
    ColorState colorState = arc4random() % kColorStateCount;
    [self spawnRandomLocation:enemyManager queueInterval:0.0f colorState:colorState topHalf:true];
    [self spawnRandomLocation:enemyManager queueInterval:0.5f colorState:[ColorStateManager nextColorState:colorState] topHalf:false];
    
    _currentTimerInterval -= 0.1f;
    if (_currentTimerInterval < 1.0f) {
        _currentTimerInterval = 1.0f;
    }
    
    _timerInterval = _currentTimerInterval;
    self._timerCompletedAction = @selector(spawnRandomLocation:);
}

//
//
//
- (void)spawnRandomLocation:(EnemyManager *)enemyManager
              queueInterval:(float)queueInterval
                 colorState:(ColorState)colorState
                    topHalf:(bool)topHalf
{
        
    // random spawn point
    float offsetX = arc4random() % (int)(CGRectGetWidth(enemyManager._rect));
    float offsetY = arc4random() % (int)((CGRectGetHeight(enemyManager._rect) / 2.0f) - [Soldier radius]);
    CGPoint spawnPoint = CGPointZero;
    spawnPoint.x = CGRectGetMinX(enemyManager._rect) + offsetX;
        
    if (topHalf) {
        spawnPoint.y = enemyManager._center.y + [Soldier radius] + offsetY;
    }
    else {
        spawnPoint.y = enemyManager._center.y - [Soldier radius] - offsetY;
    }
        
    // spawn soldier
    [enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                   colorState:colorState
                                queueInterval:queueInterval
                                 idleInterval:1.0f];
}

@end
