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
#import "ScoreTerminalWindow.h"
#import "StageScene.h"
#import "CCSprite+Extended.h"
#import "SpriteFrameManager.h"

//
// static globals
//
static const float _acceleration = 800.0f;
static const float _maxVelocity = 5000.0f;

//
// @implementation TerminalWindow
//
@implementation ScoreTerminalWindow

//
// synthesize
//
@synthesize _delegate;
@synthesize _active;
@synthesize _state;
@synthesize _reverse;
@synthesize _terminalLeftEdge;
@synthesize _terminalRightEdge;
@synthesize _terminalMiddle;
@synthesize _velocity;
@synthesize _terminalMiddleGoalWidth;

//
//
//
+ (id)scoreTerminalWindow {
    CCSpriteFrame *spriteFrame = [SpriteFrameManager scoreTerminalWindowSpriteFrame];
    ScoreTerminalWindow *terminalWindow = [[ScoreTerminalWindow alloc] initWithSpriteFrame:spriteFrame];
    return [terminalWindow autorelease];
}

//
//
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame {
    self = [super initWithSpriteFrame:spriteFrame];
    
    // init properties
    self._active = false;
    self._state = kTerminalWindowStateUnknown;
    self._terminalLeftEdge = [self createTerminalLeftEdge];
    self._terminalRightEdge = [self createTerminalRightEdge];
    self._terminalMiddle = [self createTerminalMiddle];
    self._velocity = 0.0f;
    self._terminalMiddleGoalWidth = _terminalMiddle.textureRect.size.width;
    self._reverse = false;
    
    // set super class stuff
    self.anchorPoint = ccp(12.0f / self.textureRect.size.width, 0.5f); // 12/256 is because the middle frame starts at 10 pixels in, and we want to anchor to that
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (CCSprite *)createTerminalLeftEdge {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager scoreTerminalLeftEdgeSpriteFrame]];
    sprite.anchorPoint = ccp(1.0f, 0.5f);
    return sprite;
}

//
//
//
- (CCSprite *)createTerminalRightEdge {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager scoreTerminalRightEdgeSpriteFrame]];
    sprite.anchorPoint = ccp(0.0f, 0.5f);
    return sprite;
}

//
//
//
- (CCSprite *)createTerminalMiddle {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager scoreTerminalMiddleSpriteFrame]];
    sprite.anchorPoint = ccp(0.0f, 0.5f);
    return sprite;
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _terminalLeftEdge.position = position;
    _terminalRightEdge.position = ccp(position.x-2, position.y);
    _terminalMiddle.position = ccp(position.x-2, position.y);
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint {
    if (_active) {
        return 1;
    }
    
    _active = true;
    
    CCSpriteBatchNode *spriteBatchNode = [[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_HUD_LOW];
    [spriteBatchNode addChild:self z:ZORDER_TERMINAL];
    [spriteBatchNode addChild:_terminalLeftEdge z:ZORDER_TERMINAL_EDGE_LEFT];
    [spriteBatchNode addChild:_terminalRightEdge z:ZORDER_TERMINAL_EDGE_RIGHT];
    [spriteBatchNode addChild:_terminalMiddle z:ZORDER_TERMINAL_MIDDLE];
    
    // set positions
    self.position = spawnPoint;
        
    // set state to animate in
    [self setStateToExpanding:false];
        
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
    [_terminalLeftEdge removeFromParentAndCleanup:false];
    [_terminalRightEdge removeFromParentAndCleanup:false];
    [_terminalMiddle removeFromParentAndCleanup:false];
    
    // notify parent we are hidden
    [_delegate completedHiding:self];
    
    return 0;
}

//
//
//
- (void)hideTerminal {
    [self setStateToExpanding:true];
}

//
//
//
- (int)setStateToExpanding:(bool)reverse {
    
    // set state
    _state = kTerminalWindowStateResizing;
    _reverse = reverse;
    
    // set visibilty
    self.visible = false;
    _terminalMiddle.visible = true;
    _terminalLeftEdge.visible = true;
    _terminalRightEdge.visible = true;
        
    // shift right back one pixel, we are getting 1 pixel gaps
    if (!_reverse) {
        _terminalRightEdge.position = ccp(self.position.x-2, self.position.y);
    }
    else {
        _terminalRightEdge.position = ccp(_terminalMiddle.position.x + _terminalMiddleGoalWidth - 2.0f,
                                          _terminalMiddle.position.y);
    }
    
    // reset texture rect width
    [_terminalMiddle setTextureRectWidth:_reverse ? _terminalMiddleGoalWidth : 1.0f];
    
    // reset velocity
    _velocity = 0.0f;
    
    return 0;
}

//
//
//
- (int)setStateToAlive {
    _state = kTerminalWindowStateAlive;
    
    // set visibility
    self.visible = true;
    _terminalLeftEdge.visible = false;
    _terminalRightEdge.visible = false;
    _terminalMiddle.visible = false;
    
    // notify delegate we are displayed
    [_delegate completedResizing:self];
    
    return 0;
}

//
//
//
- (void)updateVelocity:(ccTime)elapsedTime {
    
    // if at max, don't accelerate anymore
    if (_velocity == _maxVelocity) {
        return;
    }
    
    float delta = elapsedTime * _acceleration;
    _velocity += delta;
    if (_velocity >= _maxVelocity) {
        _velocity = _maxVelocity;
        return;
    }
}

//
//
//
- (void)updateStateExpanding:(ccTime)elapsedTime {
    
    [self updateVelocity:elapsedTime];
    
    // if going in reverse
    if (_reverse) {
        elapsedTime *= -1;
    }
    
    float delta = elapsedTime * _velocity;
    
    // update right edge
    CGPoint newPosition = _terminalRightEdge.position;
    newPosition.x += delta;
    _terminalRightEdge.position = newPosition;
    
    // update texture rect
    float newWidth = _terminalMiddle.textureRect.size.width;
    newWidth += delta;
    
    // if we are not going in reverse
    if (!_reverse && newWidth >= _terminalMiddleGoalWidth) {
        [self setStateToAlive];
        return;
    }
    
    // if we are going in reverse
    if (_reverse && newWidth <= 0.0f) {
        _state = kTerminalWindowStateUnknown;
        [_delegate completedHiding:self];
        return;
    }
    
    [_terminalMiddle setTextureRectWidth:newWidth];
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    switch (_state) {
        case kTerminalWindowStateResizing: [self updateStateExpanding:elapsedTime]; break;
        default: break;
    }
}

//
//
//
- (void)dealloc {
    self._terminalLeftEdge = nil;
    self._terminalRightEdge = nil;
    self._terminalMiddle = nil;
    [super dealloc];
}


@end
