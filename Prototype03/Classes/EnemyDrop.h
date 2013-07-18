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
#import "chipmunk.h"
#import "cocos2d.h"
#import "defines.h"

//
// forward declarations
//
@class EnemyDropManager;

//
// @interface EnemyDrop
//
@interface EnemyDrop : CCSprite {
    EnemyDropType _enemyDropType;
    cpBody *_body;
    cpShape *_shape;
    bool _active;
    bool _chipmunkActive;
    bool _deactivateAfterScaling;
    ccTime _expireTimer;
    ccTime _blinkInterval;
    ccTime _blinkTimer;
    
    CCSprite *_activatedAnimation;    
}

//
// property
//
@property (nonatomic, assign) EnemyDropType _enemyDropType;
@property (nonatomic, assign) cpBody *_body;
@property (nonatomic, assign) cpShape *_shape;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) bool _chipmunkActive;
@property (nonatomic, assign) bool _deactivateAfterScaling;
@property (nonatomic, assign) ccTime _expireTimer;
@property (nonatomic, assign) ccTime _blinkInterval;
@property (nonatomic, assign) ccTime _blinkTimer;
@property (nonatomic, retain) CCSprite *_activatedAnimation;

//
// static methods
//
+ (id)enemyDropWithEnemyDropType:(EnemyDropType)enemyDropType;

//
// methods
//
- (id)initWithEnemyDropType:(EnemyDropType)enemyDropType;
- (cpShape *)createShape;
- (CCSprite *)createActivatedAnimation;
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint;
- (int)deactivate;
- (int)activateChipmunk;
- (int)deactivateChipmunk;
- (void)update:(ccTime)elapsedTime;
- (void)completedAnimation;
- (void)handleCollisionWithPlayer:(id)object;
- (void)chipmunkDeactivate;
- (void)dropWasActivated;
- (void)dealloc;


@end
