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
#import "SFExplosion.h"
#import "SoldierFactory.h"
#import "StageScene.h"
#import "FastAnimate.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _animation01BeginFrame = 9;
static const int _animation01EndFrame = 2;
static const int _animation02BeginFrame = 1;
static const int _animation02EndFrame = 0;
static const ccTime _animation01Duration = 0.5f;
static const ccTime _animation02Duration = 0.1f;
static const float _rotationVelocity = -45.0f;

//
// @implementation SFExplosion
//
@implementation SFExplosion

//
// synthesize
//
@synthesize _soldierFactory;
@synthesize _active;
@synthesize _whiteAnimation;
@synthesize _blackAnimation;
@synthesize _doRotation;

//
//
//
+ (id)sfExplosionWithSoldierFactory:(SoldierFactory *)soldierFactory {
    SFExplosion *sfExplosion = [[SFExplosion alloc] initwithSoldierFactory:soldierFactory];
    return [sfExplosion autorelease];
}

//
// functions
//
- (id)initwithSoldierFactory:(SoldierFactory *)soldierFactory {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:kColorStateDefault frameNumber:0];
    self = [super initWithSpriteFrame:spriteFrame];
    
    // init properties
    self._soldierFactory = soldierFactory;
    self._active = false;
    self._whiteAnimation = [self createSequenceWithColorState:kColorStateWhite];
    self._blackAnimation = [self createSequenceWithColorState:kColorStateBlack];
    self._doRotation = false;
    
    // set super class stuff
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (CCSequence *)createSequenceWithColorState:(ColorState)colorState {
    
    // get frames for animation 01
    NSMutableArray *frameArray = [NSMutableArray array];
    
    // now forward
    for (int i=_animation01BeginFrame; i >= _animation01EndFrame; i--) {
        [frameArray addObject:[SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    // create animation
    CCAnimation *animation = [CCAnimation animationWithFrames:frameArray];
    FastAnimate *animate01 = [FastAnimate actionWithAnimation:animation duration:_animation01Duration];
    
    // create animation 02
    [frameArray removeAllObjects];
    for (int i=_animation02BeginFrame; i >= _animation02EndFrame; i--) {
        [frameArray addObject:[SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:colorState frameNumber:i]];
    }
    
    // create animation
    animation = [CCAnimation animationWithFrames:frameArray];
    FastAnimate *animate02 = [FastAnimate actionWithAnimation:animation duration:_animation02Duration];
    
    // create call back
    CCCallFunc *animation01Completed = [CCCallFunc actionWithTarget:self selector:@selector(animation01Completed)];
    CCCallFunc *animation02Completed = [CCCallFunc actionWithTarget:self selector:@selector(animation02Completed)];
    
    return [CCSequence actions:animate01, animation01Completed, animate02, animation02Completed, nil];
}

//
//
//
- (CCSequence *)animationSequenceWithColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _whiteAnimation;
        case kColorStateBlack: return _blackAnimation;
        default: break;
    }
    
    return nil;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    // add to scene
    _active = true;
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_03] addChild:self z:ZORDER_SF_EXPLOSION];
    
    // set animation
    CCSequence *sequence = [self animationSequenceWithColorState:_soldierFactory._colorState];
    [self runAction:sequence];
    
    // set initial frame
    [self setDisplayFrame:[SpriteFrameManager soldierFactoryExplosionSpriteFrameWithColorState:_soldierFactory._colorState frameNumber:0]];
    
    // set position
    self.position = _soldierFactory.position;
    self.rotation = arc4random() % 360;
    
    // do rotation
    _doRotation = true;
    
    return 0;  
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    // remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    [self stopAllActions];
    
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    if (_doRotation) {
        float delta = elapsedTime * _rotationVelocity;
        self.rotation += delta;
    }
}

//
//
//
- (void)animation01Completed {
    [_soldierFactory setVisibility:false];
}

//
//
//
- (void)animation02Completed {
    [_soldierFactory deactivate];
}

//
//
//
- (void)dealloc {
    self._soldierFactory = nil;
    self._whiteAnimation = nil;
    self._blackAnimation = nil;
    [super dealloc];
}

@end
