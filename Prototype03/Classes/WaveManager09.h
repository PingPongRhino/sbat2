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
// @interface WaveManager09
//
@interface WaveManager09 : WaveManager

//
// overrides
//
- (int)activate;

//
// spawn methods
//
- (void)spawnWhiteBarrierSFInCenter:(EnemyManager *)enemyManager;
- (void)spawnBlackBarrierSFInCenter:(EnemyManager *)enemyManager;
- (void)spawnWhiteBarrierHighBlackBarrierLow:(EnemyManager *)enemyManager;
- (void)spawnBlackBarrierHighWhiteBarrierLow:(EnemyManager *)enemyManager;
- (void)spawnCrossStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnCrossStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnFourInCornersStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnFourInCornersStartingWithBlack:(EnemyManager *)enemyManager;
- (void)spawnFourInCornersWithCenterStartingWithWhite:(EnemyManager *)enemyManager;
- (void)spawnFourInCornersWithCenterStartingWithBlack:(EnemyManager *)enemyManager;

//
// spawn helpers
//
- (void)spawnCross:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor withCenter:(bool)center;
- (void)spawnFourInCorners:(EnemyManager *)enemyManager startingColor:(ColorState)startingColor withCenter:(bool)center;

@end