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
#import "ScoreManager.h"
#import "NotificationStrings.h"
#import "SoldierFactory.h"

//
// static globals
//
static ScoreManager *_sharedScoreManager = nil;

//
// @implementation Score
//
@implementation ScoreManager

//
// synthesize
//
@synthesize _score;
@synthesize _scoreWithoutCompletionBonus;
@synthesize _levelMultiplier;

//
//s
//
+ (ScoreManager *)createShreadScoreManager {
    [ScoreManager destroySharedScoreManager];
    _sharedScoreManager = [[ScoreManager alloc] init];
    return _sharedScoreManager;
}

//
//
//
+ (ScoreManager *)sharedScoreManager { return _sharedScoreManager; }

//
//
//
+ (void)destroySharedScoreManager {
    [_sharedScoreManager release];
    _sharedScoreManager = nil;
}

//
//
//
+ (id)scoreManager {
    ScoreManager *scoreManager = [[ScoreManager alloc] init];
    return [scoreManager autorelease];
}

//
//
//
+ (int64_t)pointsForEnemyType:(EnemyType)enemyType {
    switch (enemyType) {
        case kEnemyTypeSoldier: return 100;
        case kEnemyTypeSoldierFactory: return 1000;
        case kEnemyTypeBarrierFactory: return 1500;
        default: break;
    }
    
    return 0;
}

//
//
//
+ (int64_t)pointsForCompletion {
    return 1000000;
}

//
//
//
- (id)init {
    self = [super init];
    
    // init properties
    self._score = 0;
    self._scoreWithoutCompletionBonus = 0;
    self._levelMultiplier = 1;
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleSoldierFactoryKilledByPlayer:)
                                                 name:kNotificationSoldierFactoryKilledByPlayer
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSoldierKilledByPlayer:)
                                                 name:kNotificationSoldierKilledByPlayer
                                               object:nil];
    return self;
}

//
//
//
- (void)reset {
    _levelMultiplier = 1;
    _scoreWithoutCompletionBonus = 0;
    [self setScore:0];
}

//
//
//
- (void)setScore:(int)score {
    _score = score;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationScoreManagerScoreChanged object:self];
}

//
//
//
- (void)addToScore:(int)value {
    _score += value * _levelMultiplier;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationScoreManagerScoreChanged object:self];
}

//
//
//
- (void)addCompletionBonus {
    _scoreWithoutCompletionBonus = _score;
    [self addToScore:[ScoreManager pointsForCompletion]];
}

//
//
//
- (void)handleSoldierFactoryKilledByPlayer:(NSNotification *)notification {
    SoldierFactory *soldierFactory = (SoldierFactory *)[notification object];
    [self addToScore:[ScoreManager pointsForEnemyType:soldierFactory._enemyType]];
}

//
//
//
- (void)handleSoldierKilledByPlayer:(NSNotification *)notification {
    [self addToScore:[ScoreManager pointsForEnemyType:kEnemyTypeSoldier]];
}

//
//
//
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
