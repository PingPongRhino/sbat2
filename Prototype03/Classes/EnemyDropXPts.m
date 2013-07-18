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
#import "EnemyDropXPts.h"
#import "ScoreManager.h"

//
// @implementation EnemyDropXPts
//
@implementation EnemyDropXPts

//
// synthesize
//
@synthesize _points;

//
//
//
- (id)initWithEnemyDropType:(EnemyDropType)enemyDropType {
    self = [super initWithEnemyDropType:enemyDropType];
    
    self._points = 0;
    
    switch (enemyDropType) {
        case kEnemyDropType500Pts:  _points = 500; break;
        case kEnemyDropType1000Pts: _points = 1000; break;
        case kEnemyDropType1500Pts: _points = 1500; break;
        case kEnemyDropType2000Pts: _points = 2000; break;
        case kEnemyDropType2500Pts: _points = 2500; break;
        default: break;
    }
    
    return self;
}

//
//
//
- (void)dropWasActivated {
    [[ScoreManager sharedScoreManager] addToScore:_points];
    [super dropWasActivated];
}

@end
