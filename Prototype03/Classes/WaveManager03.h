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
// #import "WaveManager.h"
//
#import "WaveManager.h"

//
// @interface WaveManager03
//
@interface WaveManager03 : WaveManager {
    int _spawnBlackCenterCounter;
    int _spawnLinesFromTop;
}

//
// overrides
//
- (int)activate;

//
// wave spawn patterns
//
- (void)spawnBlackAndWhiteOppositeEachOther:(EnemyManager *)enemyManager;
- (void)spawnBlackAndWhiteCrosses:(EnemyManager *)enemyManager;
- (void)spawnBlackAndWhiteSlashes:(EnemyManager *)enemyManager;
- (void)spawnBlackAndWhiteSlashesInReverse:(EnemyManager *)enemyManager;
- (void)spawnBlackAndWhiteOppositeArcs:(EnemyManager *)enemyManager;
- (void)spawnBlackAndWhiteArcsFromInside:(EnemyManager *)enemyManager;

- (void)spawnWhiteAndBlackOppositeEachOther:(EnemyManager *)enemyManager;
- (void)spawnWhiteAndBlackCrosses:(EnemyManager *)enemyManager;
- (void)spawnWhiteAndBlackSlashes:(EnemyManager *)enemyManager;
- (void)spawnWhiteAndBlackSlashesInReverse:(EnemyManager *)enemyManager;
- (void)spawnWhiteAndBlackOppositeArcs:(EnemyManager *)enemyManager;
- (void)spawnWhiteAndBlackArcsFromInside:(EnemyManager *)enemyManager;

- (void)spawnVerticalLines:(EnemyManager *)enemyManager;

//
// misc helper functions
//
- (void)spawnBlackAndWhiteOppositeEachOther:(EnemyManager *)enemyManager withBlackOnLeft:(bool)blackOnLeft;

- (void)spawnArcs:(EnemyManager *)enemyManager leftColor:(ColorState)leftColor rightColor:(ColorState)rightColor centerPointInside:(bool)centerPointInside;
- (void)spawnArc:(EnemyManager *)enemyManager color:(ColorState)color leftSide:(bool)leftSide centerPointInside:(bool)centerPointInside;

- (void)spawnCrosses:(EnemyManager *)enemyManager leftColor:(ColorState)leftColor rightColor:(ColorState)rightColor;
- (void)spawnCross:(EnemyManager *)enemyManager color:(ColorState)color leftSide:(bool)leftSide;

- (void)spawnSlashes:(EnemyManager *)enemyManager leftColor:(ColorState)leftColor rightColor:(ColorState)rightColor startAtTop:(bool)startAtTop;
- (void)spawnSlash:(EnemyManager *)enemyManager color:(ColorState)color leftSide:(bool)leftSide startAtTop:(bool)startAtTop;

- (void)spawnWhiteAndBlackVerticalLines:(EnemyManager *)enemyManager fromTop:(bool)top;
- (bool)spawnBlackInCenter:(EnemyManager *)enemyManager;

@end
