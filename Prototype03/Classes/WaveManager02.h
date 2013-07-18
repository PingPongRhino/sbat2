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
// @interface WaveManager02
//
@interface WaveManager02 : WaveManager {
    int _spawnBlackCenterCounter;
    bool _spawnWhiteVerticalLinesFromTop;
}

//
// overrides
//
- (int)activate;

//
// wave pattern algorithms
//
- (void)spawnTopHorizontalLineWhiteInside:(EnemyManager *)enemyManager;
- (void)spawnCenterHorizontalLineBlackInside:(EnemyManager *)enemyManager;
- (void)spawnBottomHorizontalLineWhiteInside:(EnemyManager *)enemyManager;
- (void)spawnXWithBlackCenter:(EnemyManager *)enemyManager;
- (void)spawnXWithWhiteCenter:(EnemyManager *)enemyManager;
- (void)spawnWhiteCircleWithBlackCenter:(EnemyManager *)enemyManager;
- (void)spawnBlackCircleWithWhiteCenter:(EnemyManager *)enemyManager;
- (void)spawnWhiteFourCenterProtectedByBlack:(EnemyManager *)enemyManager;
- (void)spawnBlackFourCenterProtectedByWhite:(EnemyManager *)enemyManager;
- (void)spawnWhiteVerticalLines:(EnemyManager *)enemyManager;

//
// spawn functions
//
- (void)spawnHorizontalLine:(EnemyManager *)enemyManager
                insideColor:(ColorState)insideColor
               outsideColor:(ColorState)outsideColor
                     yCoord:(float)yCoord;

- (void)spawnX:(EnemyManager *)enemyManager
   insideColor:(ColorState)insideColor
  outsideColor:(ColorState)outsideColor;

- (void)spawnCircleWithEnemyManager:(EnemyManager *)enemyManager
                       outsideColor:(ColorState)outsideColor
                        insideColor:(ColorState)insideColor;

- (void)spawnFourCenterProtected:(EnemyManager *)enemyManager
                     insideColor:(ColorState)insideColor
                    outsideColor:(ColorState)outsideColor;

- (void)spawnWhiteVerticalLines:(EnemyManager *)enemyManager fromTop:(bool)top;
- (bool)spawnBlackInCenter:(EnemyManager *)enemyManager;

@end
