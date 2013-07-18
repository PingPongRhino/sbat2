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
#import "SpriteFrameManager.h"
#import "ColorStateManager.h"
#import "CCEncryptedTextureCache.h"
#import "StageScene.h"

//
// @implementation SpriteFrameManager
//
@implementation SpriteFrameManager

#pragma mark -
#pragma mark Character Sprites

//
//
//
+ (NSString *)characterStringForCharacterType:(CharacterType)characterType {
    switch (characterType) {
        case kCharacterTypeBangoBlue:   return @"bango_blue";
        case kCharacterTypeSpinLock:    return @"spin_lock";
        case kCharacterTypeCoco:        return @"coco";
        default: break;
    }
    
    return nil;
}

//
//
//
+ (CCSpriteFrame *)characterSpriteFrameWithCharacterType:(CharacterType)characterType {
    NSString *frameName = [NSString stringWithFormat:@"%@.png", [SpriteFrameManager characterStringForCharacterType:characterType]];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

#pragma mark -
#pragma mark Health Sprites

//
//
//
+ (CCSpriteFrame *)healthIconSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"emitter_health_icon.png"];
}

#pragma mark -
#pragma mark Laser Sprites

//
//
//
+ (CCSpriteFrame *)laserSwitchParticleSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"laser_switch_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)laserStartParticleSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"laser_start_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)laserEndParticleSpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"laser_end_base_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)laserEndSparkSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"laser_end_spark_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCTexture2D *)laserBaseTextureWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *textureName = [NSString stringWithFormat:@"laser_base_%@.png.enc", color];
    return [[CCEncryptedTextureCache sharedTextureCache] addImage:textureName];
}

#pragma mark -
#pragma mark Path Sprites

//
//
//
+ (CCSpriteFrame *)pathSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"emission_path.png"];
}

//
//
//
+ (CCSpriteFrame *)pathSpriteEndSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"emission_path_sprite_end.png"];
}

//
//
//
+ (CCSpriteFrame *)pathParticleSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"emission_path_particle.png"];
}

#pragma mark -
#pragma mark Gear Sprites

//
//
//
+ (CCSpriteFrame *)gearSpriteFrameWithTeeth:(bool)teeth colorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"gear_%@_teeth_%@.png", teeth ? @"with" : @"without", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)gearShadowSpriteFrameWithTeeth:(bool)teeth {
    NSString *frameName = [NSString stringWithFormat:@"gear_shadow_%@_teeth.png", teeth ? @"with" : @"without"];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)gearSwitchSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"gear_switch_animation_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

#pragma mark -
#pragma mark Soldier Sprites

//
//
//
+ (CCSpriteFrame *)soldierSpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_base_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierHealthBarSpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_health_bar_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierExplosionSpriteFrameWithColor:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_explosion_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

#pragma mark -
#pragma mark Soldier Factory Sprites

//
//
//
+ (CCSpriteFrame *)soldierFactorySpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_base_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryGearSpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_gear_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];    
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryHealthBarSpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_health_bar_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryCenterSpriteFrameWithColorState:(ColorState)colorState {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_center_%@.png", color];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryGearShadowSpriteFrame {
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_gear_shadow.png"];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryExplosionSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_explosion_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryAttackSpriteFrameWithColorState:(ColorState)colorState number:(int)number {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_attack_%@_%02d.png", color, number];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryBaseAttackSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_attack_base_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryCenterAttackSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_attack_center_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

#pragma mark -
#pragma mark Soldier Factory Barrier Sprites

//
//
//
+ (CCSpriteFrame *)soldierFactoryBarrierSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_barrier_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];    
}

//
//
//
+ (CCSpriteFrame *)soldierFactoryBarrierExplosionSpriteFrameWithColorState:(ColorState)colorState frameNumber:(int)frameNumber {
    NSString *color = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_barrier_explosion_%@_%02d.png", color, frameNumber];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];    
}

#pragma mark -
#pragma mark Enemy Drop Sprites

//
//
//
+ (NSString *)stringForEnemyDropType:(EnemyDropType)enemyDropType {
    switch (enemyDropType) {
        case kEnemyDropTypeHealth: return @"health";
        case kEnemyDropType500Pts: return @"500pts";
        case kEnemyDropType1000Pts: return @"1000pts";
        case kEnemyDropType1500Pts: return @"1500pts";
        case kEnemyDropType2000Pts: return @"2000pts";
        case kEnemyDropType2500Pts: return @"2500pts";
        default: break;
    }
    
    return @"";
}

//
//
//
+ (CCSpriteFrame *)enemyDropSpriteFrameFrameWithEnemyDropType:(EnemyDropType)enemyDropType {
    NSString *frameName = [NSString stringWithFormat:@"enemy_drop_%@.png", [SpriteFrameManager stringForEnemyDropType:enemyDropType]];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
+ (CCSpriteFrame *)enemyDropActivatedSpriteFrameWithNumber:(int)number {
    NSString *frameName = [NSString stringWithFormat:@"enemy_drop_activated_%02d.png", number];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

#pragma mark -
#pragma mark Wave Timer Sprites

//
//
//
+ (CCSpriteFrame *)waveTimerProgressSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"wave_timer_progress.png"];
}

//
//
//
+ (CCSpriteFrame *)waveTimerOverlaySpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"wave_timer_overlay.png"];
}

//
//
//
+ (CCSpriteFrame *)waveTimerBackingSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"wave_timer_backing.png"];
}

#pragma mark -
#pragma mark Survival/Score HUD Sprites

//
//
//
+ (CCSpriteFrame *)scoreTerminalWindowSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"score_terminal_window.png"];
}

//
//
//
+ (CCSpriteFrame *)scoreTerminalLeftEdgeSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"score_terminal_window_left_edge.png"];    
}

//
//
//
+ (CCSpriteFrame *)scoreTerminalRightEdgeSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"score_terminal_window_right_edge.png"];
}

//
//
//
+ (CCSpriteFrame *)scoreTerminalMiddleSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"score_terminal_window_middle.png"];
}

#pragma mark -
#pragma mark Master Control Switch Sprites

//
//
//
+ (CCSpriteFrame *)masterControlSwitchSpriteFrameWithColorState:(ColorState)colorState {
    NSString *colorName = [ColorStateManager stringForColorState:colorState];
    NSString *frameName = [NSString stringWithFormat:@"master_control_%@.png", colorName];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

#pragma mark -
#pragma mark WayPoint

//
//
//
+ (CCSpriteFrame *)wayPointSpriteFrame {
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waypoint.png"];
}


#pragma mark -
#pragma mark Sprite Icons

//
//
//
+ (CCSprite *)baseTowerIconSpriteWithCharacter:(CharacterType)characterType {
    NSString *frameName = [NSString stringWithFormat:@"base_tower_tutorial_icon_%@.png", [SpriteFrameManager characterStringForCharacterType:characterType]];
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    return [CCSprite spriteWithSpriteFrame:spriteFrame];
}

//
//
//
+ (CCSprite *)mobileTowerIconSpriteWithShipNumber:(int)playerShipNumber {
    CharacterType characterType = (playerShipNumber == 1) ? kCharacterTypeBangoBlue : kCharacterTypeSpinLock;
    NSString *frameName = [NSString stringWithFormat:@"mobile_tower_tutorial_icon_%@.png", [SpriteFrameManager characterStringForCharacterType:characterType]];
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    return [CCSprite spriteWithSpriteFrame:spriteFrame];
}

//
//
//
+ (CCSprite *)masterControlSwitchIconSpriteWithColorState:(ColorState)colorState {
    NSString *frameName = [NSString stringWithFormat:@"master_control_tutorial_icon_%@.png", [ColorStateManager stringForColorState:colorState]];
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:spriteFrame];
    sprite.flipX = (colorState == kColorStateWhite) ? true : false;
    return sprite;
}

//
//
//
+ (CCSprite *)soldierIconSpriteWithColorState:(ColorState)colorState {
    NSString *frameName = [NSString stringWithFormat:@"emission_tutorial_icon_%@.png", [ColorStateManager stringForColorState:colorState]];
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    return [CCSprite spriteWithSpriteFrame:spriteFrame];
}

//
//
//
+ (CCSprite *)healthIconSprite {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager healthIconSpriteFrame]];
    sprite.anchorPoint = ccp(0.5f, 0.25f);
    return sprite;
}

//
//
//
+ (CCSprite *)wayPointIconSprite {
    NSString *frameName = [NSString stringWithFormat:@"waypoint_tutorial_icon.png"];
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    return [CCSprite spriteWithSpriteFrame:spriteFrame];
}

//
//
//
+ (CCSprite *)soldierFactoryIconSpriteWithColorState:(ColorState)colorState {
    NSString *frameName = [NSString stringWithFormat:@"emission_generator_tutorial_icon_%@.png", [ColorStateManager stringForColorState:colorState]];
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
    return [CCSprite spriteWithSpriteFrame:spriteFrame]; 
}

//
//
//
+ (CCSprite *)soldierFactoryBarrierIcon {
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"emission_generator_with_barriers_tutorial_icon.png"];
    return [CCSprite spriteWithSpriteFrame:spriteFrame];
}

//
//
//
+ (CCSprite *)powerUpIconSprite {
    return [CCSprite spriteWithSpriteFrame:[SpriteFrameManager enemyDropSpriteFrameFrameWithEnemyDropType:kEnemyDropTypeHealth]];
}

@end
