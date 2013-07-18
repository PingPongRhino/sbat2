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
#import "EnemyDropManager.h"
#import "EnemyDrop.h"
#import "NotificationStrings.h"

//
// static globals
//
static EnemyDropManager *_sharedEnemyDropManager = nil;
static const int _diceSize = 1000;

//
// @implementation EnemyDropManager
//
@implementation EnemyDropManager

//
// synthesize
//
@synthesize _defaultDropRate;
@synthesize _currentDropRate;
@synthesize _dropTable;
@synthesize _activeEnemyDrops;
@synthesize _disableEnemyDrops;

//
//
//
+ (EnemyDropManager *)createSharedEnemyDropManager {
    [EnemyDropManager destroySharedEnemyDropManager];
    _sharedEnemyDropManager = [[EnemyDropManager alloc] init];
    return _sharedEnemyDropManager;
}

//
//
//
+ (EnemyDropManager *)sharedEnemyDropManager { return _sharedEnemyDropManager; }

//
//
//
+ (void)destroySharedEnemyDropManager {
    [_sharedEnemyDropManager release];
    _sharedEnemyDropManager = nil;
}

//
// desc: drop rates should compute to 1.0f
//
+ (float)getDropRateForEnemyDropType:(EnemyDropType)enemyDropType {
    switch (enemyDropType) {
        case kEnemyDropTypeNone:    return 0.835f;
        case kEnemyDropTypeHealth:  return 0.015f;
        case kEnemyDropType500Pts:  return 0.050f;
        case kEnemyDropType1000Pts: return 0.040f;
        case kEnemyDropType1500Pts: return 0.030f;
        case kEnemyDropType2000Pts: return 0.020f;
        case kEnemyDropType2500Pts: return 0.010f;
        default: break;
    }
    
    return 0.0f;
}

//
// methods
//
- (id)init {
    self = [super init];
    
    self._defaultDropRate = [self setupDefaultDropRate];
    self._currentDropRate = nil;
    self._dropTable = [NSMutableArray array];
    self._activeEnemyDrops = [NSMutableSet set];
    self._disableEnemyDrops = false;
    
    [self setDefaultDropRate];
    
    // register for observering enemy drops
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnemyDropDeactivated:)
                                                 name:kNotificationEnemyDropDeactivated
                                               object:nil];
    return self;
}

//
//
//
- (NSMutableArray *)setupDefaultDropRate {
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i < kEnemyDropTypeCount; i++) {
        [array addObject:[NSNumber numberWithFloat:[EnemyDropManager getDropRateForEnemyDropType:(EnemyDropType)i]]];
    }
    return array;
}

//
//
//
- (void)setDefaultDropRate {
    self._currentDropRate = [NSMutableArray arrayWithArray:_defaultDropRate];
    [self refreshDropTable];
}

//
//
//
- (void)changeEnemyDrop:(EnemyDropType)enemyDrop toNewRate:(float)newRate {
    
    NSMutableArray *newDropRate = [NSMutableArray array];
    float delta = ([[_currentDropRate objectAtIndex:enemyDrop] floatValue] - newRate) / (kEnemyDropTypeCount - 1);
    
    int index = 0;
    for (NSNumber *number in _currentDropRate) {
        
        if (index != enemyDrop) {
            [newDropRate addObject:[NSNumber numberWithFloat:[number floatValue] + delta]];
        }
        else {
            [newDropRate addObject:[NSNumber numberWithFloat:newRate]];
        }
        
        index++;
    }
    
    // set new drop rate
    self._currentDropRate = newDropRate;
    [self refreshDropTable];
}

//
//
//
- (void)refreshDropTable {
    // build our drop table
    [_dropTable removeAllObjects];
    int startOfRange = 0;
    for (int i=0; i < kEnemyDropTypeCount; i++) {
        float length = ([[_currentDropRate objectAtIndex:i] floatValue] * _diceSize) - 1;
        if (length < 0) {
            length = 0;
        }
        NSRange range = NSMakeRange(startOfRange, length);
        
        // add to array
        [_dropTable addObject:[NSValue valueWithRange:range]];
        
        // set next range
        startOfRange += length;
    }
}

//
//
//
- (EnemyDrop *)generateEnemyDrop {
    
    if (_disableEnemyDrops) {
        return nil;
    }
    
    int diceRoll = arc4random() % _diceSize;
    
    EnemyDropType enemyDropType = kEnemyDropTypeNone;
    for (NSValue *value in _dropTable) {
        if (NSLocationInRange(diceRoll, [value rangeValue])) {
            break;
        }
        
        enemyDropType++;
    }
    
    // if not in any range or unknown, then drop nothing
    if (enemyDropType >= kEnemyDropTypeCount || enemyDropType <= kEnemyDropTypeNone) {
        return nil;
    }
    
    // generate enemy drop
    EnemyDrop *enemyDrop = [EnemyDrop enemyDropWithEnemyDropType:enemyDropType];
    [_activeEnemyDrops addObject:enemyDrop];
        
    return enemyDrop;
}

//
//
//
- (void)handleEnemyDropDeactivated:(NSNotification *)notification {
    [_activeEnemyDrops removeObject:[notification object]];
}

//
//
//
- (void)deactivateAllActiveEnemyDrops {
    NSSet *set = [[NSSet alloc] initWithSet:_activeEnemyDrops];
    [set makeObjectsPerformSelector:@selector(deactivate)];
    [set release];
}

//
//
//
- (void)dealloc {
    [self deactivateAllActiveEnemyDrops];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self._defaultDropRate = nil;
    self._currentDropRate = nil;
    self._dropTable = nil;
    self._activeEnemyDrops = nil;
    [super dealloc];
}


@end
