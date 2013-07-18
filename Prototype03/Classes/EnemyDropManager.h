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
#import <Foundation/Foundation.h>
#import "defines.h"

//
// forward declarations
//
@class EnemyDrop;

//
// @interface EnemyDropManager
//
@interface EnemyDropManager : NSObject {
    NSMutableArray *_defaultDropRate;
    NSMutableArray *_currentDropRate;
    NSMutableArray *_dropTable;
    NSMutableSet *_activeEnemyDrops;
    bool _disableEnemyDrops;
}

//
// properties
//
@property (nonatomic, retain) NSMutableArray *_defaultDropRate;
@property (nonatomic, retain) NSMutableArray *_currentDropRate;
@property (nonatomic, retain) NSMutableArray *_dropTable;
@property (nonatomic, retain) NSMutableSet *_activeEnemyDrops;
@property (nonatomic, assign) bool _disableEnemyDrops;

//
// create shared guy
//
+ (EnemyDropManager *)createSharedEnemyDropManager;
+ (EnemyDropManager *)sharedEnemyDropManager;
+ (void)destroySharedEnemyDropManager;

//
// static stuff
//
+ (float)getDropRateForEnemyDropType:(EnemyDropType)enemyDropType;

//
// methods
//
- (id)init;
- (NSMutableArray *)setupDefaultDropRate;
- (void)setDefaultDropRate;
- (void)changeEnemyDrop:(EnemyDropType)enemyDrop toNewRate:(float)newRate;
- (void)refreshDropTable;
- (EnemyDrop *)generateEnemyDrop;
- (void)handleEnemyDropDeactivated:(NSNotification *)notification;
- (void)deactivateAllActiveEnemyDrops;
- (void)dealloc;

@end
