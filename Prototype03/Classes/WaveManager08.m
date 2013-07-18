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
#import "WaveManager08.h"
#import "ColorStateManager.h"
#import "EnemyManager.h"
#import "SoldierFactory.h"
#import "Soldier.h"

//
// @implementation WaveManager08
//
@implementation WaveManager08

//
//
//
- (int)activate {
    if ([super activate] == 1) {
        return 1;
    }
    
    [self spawnThreeWhiteFactoriesOnLeftWithBlackSoldiersOnRight:[EnemyManager sharedEnemyManager]];
    return 0;
}

//
//
//
- (void)spawnThreeWhiteFactoriesOnLeftWithBlackSoldiersOnRight:(EnemyManager *)enemyManager {
    _spawnCounter = 0;
    [self spawnThreeWhiteSoldierFactoriesOnLeft:enemyManager];
    [self spawnBlackSoldierOnRight:enemyManager];
}

//
//
//
- (void)spawnThreeWhiteSoldierFactoriesOnLeft:(EnemyManager *)enemyManager {
    
    _spawnCounter++;
    if (_spawnCounter > 3) {
        self._timerCompletedAction = nil;
        self._allEnemiesClearedAction = @selector(spawnThreeBlackSoldierFactoriesOnLeftWithWhiteSoldiersOnRight:);
        return;
    }
    
    [self spawnThreeSoldierFactories:enemyManager onLeft:true withColorState:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnThreeWhiteSoldierFactoriesOnLeft:);    
}

//
//
//
- (void)spawnBlackSoldierOnRight:(EnemyManager *)enemyManager {
    [self spawnSoldierAtRandomLocation:enemyManager onLeft:false colorState:kColorStateBlack];
    _timerInterval = 1.0f;
    self._timerCompletedAction = @selector(spawnBlackSoldierOnRight:);
}

//
//
//
- (void)spawnThreeBlackSoldierFactoriesOnLeftWithWhiteSoldiersOnRight:(EnemyManager *)enemyManager {
    _spawnCounter = 0;
    [self spawnThreeBlackSoldierFactoriesOnLeft:enemyManager];
    [self spawnWhiteSoldierOnRight:enemyManager];
}

//
//
//
- (void)spawnThreeBlackSoldierFactoriesOnLeft:(EnemyManager *)enemyManager {
    
    _spawnCounter++;
    if (_spawnCounter > 3) {
        self._timerCompletedAction = nil;
        self._allEnemiesClearedAction = @selector(spawnThreeWhiteFactoriesOnRightWithBlackSoldiersOnLeft:);
        return;
    }
    
    [self spawnThreeSoldierFactories:enemyManager onLeft:true withColorState:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnThreeBlackSoldierFactoriesOnLeft:);
}

//
//
//
- (void)spawnWhiteSoldierOnRight:(EnemyManager *)enemyManager {
    [self spawnSoldierAtRandomLocation:enemyManager onLeft:false colorState:kColorStateWhite];
    _timerInterval = 1.0f;
    self._timerCompletedAction = @selector(spawnWhiteSoldierOnRight:);
}

//
//
//
- (void)spawnThreeWhiteFactoriesOnRightWithBlackSoldiersOnLeft:(EnemyManager *)enemyManager {
    _spawnCounter = 0;
    [self spawnThreeWhiteSoldierFactoriesOnRight:enemyManager];
    [self spawnBlackSoldierOnLeft:enemyManager];
}

//
//
//
- (void)spawnThreeWhiteSoldierFactoriesOnRight:(EnemyManager *)enemyManager {
    
    _spawnCounter++;
    if (_spawnCounter > 3) {
        self._timerCompletedAction = nil;
        self._allEnemiesClearedAction = @selector(spawnThreeBlackSoldierFactoriesOnRightWithWhiteSoldiersOnLeft:);
        return;
    }
    
    [self spawnThreeSoldierFactories:enemyManager onLeft:false withColorState:kColorStateWhite];
    self._enemiesDeactivatedAction = @selector(spawnThreeWhiteSoldierFactoriesOnRight:);    
}

//
//
//
- (void)spawnBlackSoldierOnLeft:(EnemyManager *)enemyManager {
    [self spawnSoldierAtRandomLocation:enemyManager onLeft:true colorState:kColorStateBlack];
    _timerInterval = 1.0f;
    self._timerCompletedAction = @selector(spawnBlackSoldierOnLeft:);
}

//
//
//
- (void)spawnThreeBlackSoldierFactoriesOnRightWithWhiteSoldiersOnLeft:(EnemyManager *)enemyManager {
    _spawnCounter = 0;
    [self spawnThreeBlackSoldierFactoriesOnRight:enemyManager];
    [self spawnWhiteSoldierOnLeft:enemyManager];
}

//
//
//
- (void)spawnThreeBlackSoldierFactoriesOnRight:(EnemyManager *)enemyManager {
    
    _spawnCounter++;
    if (_spawnCounter > 3) {
        self._timerCompletedAction = nil;
        _completedSpawn = true;
        return;
    }
    
    [self spawnThreeSoldierFactories:enemyManager onLeft:false withColorState:kColorStateBlack];
    self._enemiesDeactivatedAction = @selector(spawnThreeBlackSoldierFactoriesOnRight:);
}

//
//
//
- (void)spawnWhiteSoldierOnLeft:(EnemyManager *)enemyManager {
    [self spawnSoldierAtRandomLocation:enemyManager onLeft:true colorState:kColorStateWhite];
    _timerInterval = 1.0f;
    self._timerCompletedAction = @selector(spawnWhiteSoldierOnLeft:);
}

//
//
//
- (void)spawnThreeSoldierFactories:(EnemyManager *)enemyManager onLeft:(bool)left withColorState:(ColorState)colorState {
    float xSpacing = [SoldierFactory diameter];
    float xCoord = (left) ? CGRectGetMinX(enemyManager._rect) + xSpacing :
                            CGRectGetMaxX(enemyManager._rect) - xSpacing;
    CGPoint spawnPoint = ccp(xCoord, enemyManager._center.y - [SoldierFactory spawnSpacing]);
    
    for (int y=0; y < 3; y++) {
        [_trackingEnemies addObject:[enemyManager spawnSoldierFactoryWithSpawnPoint:spawnPoint
                                                                          enemyType:kEnemyTypeSoldierFactory
                                                                         colorState:colorState
                                                                      queueInterval:(y * 0.1f)
                                                                    restingInterval:1.0f
                                                                   spawningInterval:0.1f
                                                                 spawnEmissionCount:3]];
        spawnPoint.y += [SoldierFactory spawnSpacing];
    }
}

//
//
//
- (void)spawnSoldierAtRandomLocation:(EnemyManager *)enemyManager
                              onLeft:(bool)left
                          colorState:(ColorState)colorState
{
    float xOffset = arc4random() % (int)(CGRectGetWidth(enemyManager._rect) / 2.0f);
    float yOffset = arc4random() % (int)CGRectGetHeight(enemyManager._rect);
    CGPoint spawnPoint;
    spawnPoint.x = (left) ? CGRectGetMinX(enemyManager._rect) + xOffset :
                            CGRectGetMaxX(enemyManager._rect) - xOffset;
    spawnPoint.y = CGRectGetMinY(enemyManager._rect) + yOffset;
    
    [enemyManager spawnSoldierWithSpawnPoint:spawnPoint
                                  colorState:colorState
                               queueInterval:0.0f
                                idleInterval:0.5f];
}


@end
