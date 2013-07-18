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
// @interface WaveManager04
//
@interface WaveManager04 : WaveManager {
    int _spawnCenterCounter;
}

//
// overrides
//
- (int)activate;

//
// spawn stuff
//
- (void)spawnBoxStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnBoxStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnDiagonalStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnDiagonalStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnVerticalLinesStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnVerticalLinesStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnCircleStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnCircleStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnHorizontalLinesStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnHorizontalLinesStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnVerticalLines:(EnemyManager *)enemyManager;

//
// misc helpers
//
- (void)spawnCircle:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor;
- (void)spawnVerticalLines:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor;
- (void)spawnHorizontalLines:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor;
- (void)spawnDiagonal:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor reverse:(bool)reverse;
- (void)spawnBox:(EnemyManager *)enemyManager withStartingColor:(ColorState)startingColor;
- (void)spawnWhiteAndBlackVerticalLines:(EnemyManager *)enemyManager fromTop:(bool)top;
- (bool)spawnCenterMix:(EnemyManager *)enemyManager;

@end
