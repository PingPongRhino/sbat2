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

//
// @interface WaveManager08
//
@interface WaveManager08 : WaveManager {
    int _spawnCounter;
}

//
// overrides
//
- (int)activate;

//
// spawn methods
//
- (void)spawnThreeWhiteFactoriesOnLeftWithBlackSoldiersOnRight:(EnemyManager *)enemyManager;
- (void)spawnThreeWhiteSoldierFactoriesOnLeft:(EnemyManager *)enemyManager;
- (void)spawnBlackSoldierOnRight:(EnemyManager *)enemyManager;

- (void)spawnThreeBlackSoldierFactoriesOnLeftWithWhiteSoldiersOnRight:(EnemyManager *)enemyManager;
- (void)spawnThreeBlackSoldierFactoriesOnLeft:(EnemyManager *)enemyManager;
- (void)spawnWhiteSoldierOnRight:(EnemyManager *)enemyManager;

- (void)spawnThreeWhiteFactoriesOnRightWithBlackSoldiersOnLeft:(EnemyManager *)enemyManager;
- (void)spawnThreeWhiteSoldierFactoriesOnRight:(EnemyManager *)enemyManager;
- (void)spawnBlackSoldierOnLeft:(EnemyManager *)enemyManager;

- (void)spawnThreeBlackSoldierFactoriesOnRightWithWhiteSoldiersOnLeft:(EnemyManager *)enemyManager;
- (void)spawnThreeBlackSoldierFactoriesOnRight:(EnemyManager *)enemyManager;
- (void)spawnWhiteSoldierOnLeft:(EnemyManager *)enemyManager;

//
// spawn helpers
//
- (void)spawnThreeSoldierFactories:(EnemyManager *)enemyManager onLeft:(bool)left withColorState:(ColorState)colorState;
- (void)spawnSoldierAtRandomLocation:(EnemyManager *)enemyManager
                              onLeft:(bool)left
                          colorState:(ColorState)colorState;

@end
