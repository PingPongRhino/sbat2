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
// @interface WaveManager10
//
@interface WaveManager10 : WaveManager {
    NSMutableArray *_quadrants;
    ColorState _currentColorState;
    int _deactivatedCounter;
}

//
// properties
//
@property (nonatomic, retain) NSMutableArray *_quadrants;

//
// overrides
//
- (id)initWithWaveNumber:(int)waveNumber;
- (void)dealloc;
- (int)activate;

//
// spawn helper stuff
//
- (void)spawnSoldierFactory:(EnemyManager *)enemyManager;
- (void)spawnFactory:(EnemyManager *)enemyManager withEnemyType:(EnemyType)enemyType;
- (NSSet *)findEmptyCorners;
- (void)spawnRandomLocation:(EnemyManager *)enemyManager
                  enemyType:(EnemyType)enemyType
              queueInterval:(float)queueInterval
                 colorState:(ColorState)colorState
                     corner:(Corner)corner;

//
// notifications for each quadrant
//
- (void)enemyDeactivated:(NSNotification *)notification;

@end
