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
#import "cocos2d.h"

//
// forward declarations
//
@class LaserTower;

//
// @interface GearExplosion
//
@interface GearExplosion : CCSprite {
    LaserTower *_laserTower;
    CCSpriteBatchNode *_spriteBatchNode;
    NSString *_glowColor;
    bool _active;
    CCSequence *_animationSequence;
    CCSequence *_normalDamageSequence;
}

//
// properties
//
@property (nonatomic, assign) LaserTower *_laserTower;
@property (nonatomic, assign) CCSpriteBatchNode *_spriteBatchNode;
@property (nonatomic, copy  ) NSString *_glowColor;
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) CCSequence *_animationSequence;
@property (nonatomic, retain) CCSequence *_normalDamageSequence;

//
// static functions
//
+ (id)gearExplosionWithLaserTower:(LaserTower *)laserTower
                        glowColor:(NSString *)glowColor;

+ (CCSpriteFrame *)getFrameWithGlowColor:(NSString *)glowColor frameNumber:(int)frameNumber;

//
// functions
//
- (id)initWithLaserTower:(LaserTower *)laserTower
               glowColor:(NSString *)glowColor;
- (CCSequence *)initAnimationSequence;
- (CCSequence *)initNormalDamageSequence;
- (int)activateWithFullSequence:(bool)fullSequence;
- (int)deactivate;
- (void)hide;
- (void)show;
- (void)hideLaserTower;
- (void)completedAnimation;
- (void)completedNormalDamageAnimation;
- (void)dealloc;

@end
