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
// @interface WaveManager01
//
@interface WaveManager01 : WaveManager {
    int _verticalLineCounter;
    float _verticalLineSpacing;
}

//
// overrides
//
- (int)activate;

//
// wave pattern algorithms
//
- (void)spawnBlack:(EnemyManager *)enemyManager;
- (void)spawnWhiteSmileyFace:(EnemyManager *)enemyManager;
- (void)spawnBlackInX:(EnemyManager *)enemyManager;
- (void)spawnWhiteInX:(EnemyManager *)enemyManager;
- (void)spawnBlackInCircle:(EnemyManager *)enemyManager;
- (void)spawnWhiteInCircle:(EnemyManager *)enemyManager;
- (void)spawnBlackLineAlongTop:(EnemyManager *)enemyManager;
- (void)spawnWhiteLineAlongBottom:(EnemyManager *)enemyManager;
- (void)spawnBlackSineWave:(EnemyManager *)enemyManager;
- (void)spawnWhiteBox:(EnemyManager *)enemyManager;
- (void)spawnBlackReverseSineWave:(EnemyManager *)enemyManager;
- (void)spawnVerticalLine:(EnemyManager *)enemyManager;

//
// helper functions
//
- (void)spawnX:(EnemyManager *)enemyManager withColor:(ColorState)colorState;
- (void)spawnCircle:(EnemyManager *)enemyManager withColor:(ColorState)colorState;
- (void)spawnSineWaveWithEnemyManager:(EnemyManager *)enemyManager color:(ColorState)colorState reverse:(bool)reverse;
- (void)spawnVerticalLineWithEnemyManager:(EnemyManager *)enemyManager
                                    color:(ColorState)colorState
                                   xCoord:(float)xCoord
                                  reverse:(bool)reverse;

@end
