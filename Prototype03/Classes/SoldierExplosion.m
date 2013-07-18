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
#import "SoldierExplosion.h"
#import "Soldier.h"
#import "StageScene.h"
#import "FastAnimate.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const int _frameCount = 9;
static const int _animation01BeginFrame = 0;
static const int _animation01EndFrame = 2;
static const int _animation02BeginFrame = 3;
static const int _animation02EndFrame = 8;
static const ccTime _animation01Duration = 0.3f;
static const ccTime _animation02Duration = 0.6f;
static const float _rotationVelocity = 45.0f;

//
// @implementation SoldierExplosion
//
@implementation SoldierExplosion

//
// synthesize
//
@synthesize _soldier;
@synthesize _sequenceWhite;
@synthesize _sequenceBlack;
@synthesize _active;
@synthesize _doRotation;

//
//
//
+ (id)soldierExplosionWithSoldier:(Soldier *)soldier {
    SoldierExplosion *soldierExplosion = [[SoldierExplosion alloc] initWithSoldier:soldier];
    return [soldierExplosion autorelease];
}

//
// functions
//
- (id)initWithSoldier:(Soldier *)soldier {
    self = [super initWithSpriteFrame:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:kColorStateDefault frameNumber:0]];
    
    self._soldier = soldier;
    self._sequenceWhite = [self createSequenceWithColorState:kColorStateWhite];
    self._sequenceBlack = [self createSequenceWithColorState:kColorStateBlack];
    self._active = false;
    self._doRotation = true;
    
    // init super stuff
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (CCSequence *)createSequenceWithColorState:(ColorState)colorState {
    
    // get frames for animation 01
    NSMutableArray *array = [NSMutableArray array];
    for (int i=_animation01BeginFrame; i <= _animation01EndFrame; i++) {
        [array addObject:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:colorState frameNumber:i]];
    }
    
    // create animation 01
    CCAnimation *animation = [CCAnimation animationWithFrames:array];
    FastAnimate *fastAnimate01 = [FastAnimate actionWithAnimation:animation duration:_animation01Duration];
    
    // get frames for animation 02
    [array removeAllObjects];
    for (int i=_animation02BeginFrame; i <= _animation02EndFrame; i++) {
        [array addObject:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:colorState frameNumber:i]];
    }
    
    // create animation 02
    animation = [CCAnimation animationWithFrames:array];
    FastAnimate *fastAnimate02 = [FastAnimate actionWithAnimation:animation duration:_animation02Duration];
    
    // create our call back so we know when stuff completes
    CCCallFunc *animation01Completed = [CCCallFunc actionWithTarget:self selector:@selector(animation01Completed)];
    CCCallFunc *animation02Completed = [CCCallFunc actionWithTarget:self selector:@selector(animation02Completed)];
    
    // create sequence
    CCSequence *sequence = [CCSequence actions:fastAnimate01, animation01Completed, fastAnimate02, animation02Completed, nil];
    return sequence;
}

//
//
//
- (CCSequence *)sequenceForColorState:(ColorState)colorState {
    switch (colorState) {
        case kColorStateWhite: return _sequenceWhite;
        case kColorStateBlack: return _sequenceBlack;            
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
    
    _active = true;
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_PLAYFIELD_02];
    [spriteBatchNode addChild:self z:ZORDER_SOLDIER_EXPLOSION];
    
    // get color state
    ColorState colorState = _soldier._colorState;
    
    // set initial frame
    [self setDisplayFrame:[SpriteFrameManager soldierExplosionSpriteFrameWithColor:colorState frameNumber:0]];
    
    // get sequence for color state and run it
    CCSequence *sequence = [self sequenceForColorState:colorState];
    [self runAction:sequence];
    
    // set position
    self.position = _soldier.position;
    
    // pick random rotation
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
    
    _active = false;
    [self removeFromParentAndCleanup:false];
    [self stopAllActions];
    return 0;
}

//
//
//
- (void)animation01Completed {
    _soldier.visible = false;
    _doRotation = false;
}

//
//
//
- (void)animation02Completed {
    [_soldier deactivate];
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // stayed synced with soldier
    self.position = _soldier.position;
    
    // if not doing rotation then bail
    if (!_doRotation) {
        return;
    }
    
    // update rotation
    float delta = elapsedTime * _rotationVelocity;
    self.rotation += delta;
}

//
//
//
- (void)dealloc {
    self._soldier = nil;
    self._sequenceWhite = nil;
    self._sequenceBlack = nil;
    [super dealloc];
}

@end
