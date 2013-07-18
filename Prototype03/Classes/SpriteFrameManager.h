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
#import "defines.h"

//
// @interface SpriteFrameManager
//
@interface SpriteFrameManager : NSObject

// character sprites
+ (NSString *)characterStringForCharacterType:(CharacterType)characterType;
+ (CCSpriteFrame *)characterSpriteFrameWithCharacterType:(CharacterType)characterType;

// laser tower health
+ (CCSpriteFrame *)healthIconSpriteFrame;

// laser frame stuff
+ (CCSpriteFrame *)laserSwitchParticleSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;
+ (CCSpriteFrame *)laserStartParticleSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;
+ (CCSpriteFrame *)laserEndParticleSpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)laserEndSparkSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;
+ (CCTexture2D *)laserBaseTextureWithColorState:(ColorState)colorState;

// path frame stuff
+ (CCSpriteFrame *)pathSpriteFrame;
+ (CCSpriteFrame *)pathSpriteEndSpriteFrame;
+ (CCSpriteFrame *)pathParticleSpriteFrame;

// gear frame stuff
+ (CCSpriteFrame *)gearSpriteFrameWithTeeth:(bool)teeth colorState:(ColorState)colorState;
+ (CCSpriteFrame *)gearShadowSpriteFrameWithTeeth:(bool)teeth;
+ (CCSpriteFrame *)gearSwitchSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;

// soldier frame stuff
+ (CCSpriteFrame *)soldierSpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)soldierHealthBarSpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)soldierExplosionSpriteFrameWithColor:(ColorState)colorState frameNumber:(int)frameNumber;

// soldier factory stuff
+ (CCSpriteFrame *)soldierFactorySpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)soldierFactoryGearSpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)soldierFactoryHealthBarSpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)soldierFactoryCenterSpriteFrameWithColorState:(ColorState)colorState;
+ (CCSpriteFrame *)soldierFactoryGearShadowSpriteFrame;
+ (CCSpriteFrame *)soldierFactoryExplosionSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;
+ (CCSpriteFrame *)soldierFactoryAttackSpriteFrameWithColorState:(ColorState)colorState number:(int)number;
+ (CCSpriteFrame *)soldierFactoryBaseAttackSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;
+ (CCSpriteFrame *)soldierFactoryCenterAttackSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;

// soldier factory barriers
+ (CCSpriteFrame *)soldierFactoryBarrierSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;
+ (CCSpriteFrame *)soldierFactoryBarrierExplosionSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber;

// enemy drops
+ (NSString *)stringForEnemyDropType:(EnemyDropType)enemyDropType;
+ (CCSpriteFrame *)enemyDropSpriteFrameFrameWithEnemyDropType:(EnemyDropType)enemyDropType;
+ (CCSpriteFrame *)enemyDropActivatedSpriteFrameWithNumber:(int)number;

// wave timer
+ (CCSpriteFrame *)waveTimerProgressSpriteFrame;
+ (CCSpriteFrame *)waveTimerOverlaySpriteFrame;
+ (CCSpriteFrame *)waveTimerBackingSpriteFrame;

// score terminal
+ (CCSpriteFrame *)scoreTerminalWindowSpriteFrame;
+ (CCSpriteFrame *)scoreTerminalLeftEdgeSpriteFrame;
+ (CCSpriteFrame *)scoreTerminalRightEdgeSpriteFrame;
+ (CCSpriteFrame *)scoreTerminalMiddleSpriteFrame;

// master control switches
+ (CCSpriteFrame *)masterControlSwitchSpriteFrameWithColorState:(ColorState)colorState;

// way point
+ (CCSpriteFrame *)wayPointSpriteFrame;

// sprite icons
+ (CCSprite *)baseTowerIconSpriteWithCharacter:(CharacterType)characterType;
+ (CCSprite *)mobileTowerIconSpriteWithShipNumber:(int)playerShipNumber;
+ (CCSprite *)masterControlSwitchIconSpriteWithColorState:(ColorState)colorState;
+ (CCSprite *)soldierIconSpriteWithColorState:(ColorState)colorState;
+ (CCSprite *)healthIconSprite;
+ (CCSprite *)wayPointIconSprite;
+ (CCSprite *)soldierFactoryIconSpriteWithColorState:(ColorState)colorState;
+ (CCSprite *)soldierFactoryBarrierIcon;
+ (CCSprite *)powerUpIconSprite;

@end
