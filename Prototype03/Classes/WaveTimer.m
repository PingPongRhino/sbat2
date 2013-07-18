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
#import "WaveTimer.h"
#import "StageLayer.h"
#import "StageScene.h"
#import "SpriteFrameManager.h"
#import "NotificationStrings.h"
#import "SimpleAudioEngine.h"

static const ccTime _startWarningTimer = 10; // start warning at last 10 seconds
static const ccTime _warningTimerDecrement = 0.01f;

//
// @implementation WaveTimer
//
@implementation WaveTimer

//
// synthesize
//
@synthesize _active;
@synthesize _state;
@synthesize _drainFromPercentage;
@synthesize _overlay;
@synthesize _backing;
@synthesize _drainInterval;
@synthesize _drainTimer;
@synthesize _fillInterval;
@synthesize _fillTimer;
@synthesize _activeInterval;
@synthesize _activeTimer;
@synthesize _warningInterval;
@synthesize _warningTimer;

//
//
//
+ (WaveTimer *)waveTimer {
    CCSprite * sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager waveTimerProgressSpriteFrame]];
    WaveTimer *waveTimer = [[WaveTimer alloc] initWithSprite:sprite];
    return [waveTimer autorelease];
}

//
//
//
- (id)initWithSprite:(CCSprite *)sprite {
    self = [super initWithSprite:sprite];
  
    // init properties
    self._active = false;
    self._state = kWaveTimerStateUnknown;
    self._drainFromPercentage = 0.0f;
    self._overlay = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager waveTimerOverlaySpriteFrame]];
    self._backing = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager waveTimerBackingSpriteFrame]];
    self._drainInterval = 0.5f;
    self._drainTimer = 0.0f;
    self._fillInterval = 0.5f;
    self._fillTimer = 0.0f;
    self._activeInterval = 120.0f;
    self._activeTimer = 0.0f;
    self._warningInterval = 1.0f;
    self._warningTimer = 1.0f;
    
    // init super class stuff
    self.type = kCCProgressTimerTypeRadial;
    self.percentage = 100.0f;
    
    // schedul updater on this
    [self scheduleUpdateWithPriority:-1];
                
    return self;
}

//
//
//
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _overlay.position = position;
    _backing.position = position;
}

//
//
//
- (void)setOpacity:(GLubyte)opacity {
    [super setOpacity:opacity];
    _overlay.opacity = opacity;
    _backing.opacity = opacity;
}

//
//
//
- (int)activate {
    
    // if already active, bail
    if (_active) {
        return 1;
    }
    
    // set to active and add to scene
    _active = true;
    [[StageLayer sharedStageLayer] addChild:self z:ZORDER_WAVE_TIMER_PROGRESS];
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_HUD_LOW] addChild:_backing z:ZORDER_WAVE_TIMER_BACKING];
    [[[StageScene sharedStageScene] spriteBatchNodeWithIndex:SPRITEBATCHNODE_INDEX_HUD_HIGH] addChild:_overlay z:ZORDER_WAVE_TIMER_OVERLAY];
        
    // the initial state is to fill up the bar from empty
    [self setToFillState];

    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already inactive, then bail
    if (!_active) {
        return 1;
    }
    
    // set to inactive and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    [_backing removeFromParentAndCleanup:false];
    [_overlay removeFromParentAndCleanup:false];

    return 0;
}

//
//
//
- (void)stopTimer {
    _state = kWaveTimerStateUnknown;
}

//
//
//
- (void)setToDrainState {
    
    // set percentage to drain from our current percentage
    _drainFromPercentage = self.percentage;
    
    // set progress timer to drain state
    _drainTimer = 0.0f;
    
    // set state info
    _state = kWaveTimerStateDrain;
}

//
//
//
- (void)setToFillState {
    self.percentage = 0.0f;
    _fillTimer = 0.0f;
    _state = kWaveTimerStateFill;
}

//
//
//
- (void)setToActiveState {
    _fillInterval = 0.5f;
    self.percentage = 100.0f;
    _activeTimer = 0.0f;
    _state = kWaveTimerStateActive;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWaveTimerStarted object:self];
}

//
//
//
- (int)updateDrainState:(ccTime)elapsedTime {
    
    // increment drain timer
    _drainTimer += elapsedTime;
    
    // if we are still draining, then update the progress bar and bail
    if (_drainTimer < _drainInterval) {
        float deltaPercentage = _drainTimer / _drainInterval;
        self.percentage = _drainFromPercentage - (_drainFromPercentage * deltaPercentage);
        return 1;
    }
    
    // else we are done, go to fill state
    [self setToFillState];
    return 0;
}

//
//
//
- (int)updateFillState:(ccTime)elapsedTime {
    
    // increment fill timer
    _fillTimer += elapsedTime;
    
    // if still filling, then update progress bar and bail
    if (_fillTimer < _fillInterval) {
        self.percentage = (_fillTimer / _fillInterval) * 100.0f;
        return 1;
    }
    
    // set ourselves into an active state
    [self setToActiveState];
    return 0;
}

//
//
//
- (int)updateActiveState:(ccTime)elapsedTime {
    
    // increment pattern timer
    _activeTimer += elapsedTime;
    
    // if still active, then update progress bar and bail
    if (_activeTimer < _activeInterval) {
        self.percentage = 100.0f - ((_activeTimer / _activeInterval) * 100.0f);
        
        // see if we need to do warning
        if ((_activeInterval - _activeTimer) <= _startWarningTimer) {
            
            _warningTimer += elapsedTime;
            if (_warningTimer >= _warningInterval) {
                [[SimpleAudioEngine sharedEngine] playEffect:SFX_TIMER_WARNING pitch:1.0f pan:0.0f gain:SFX_TIMER_WARNING_GAIN];
                _warningInterval -= _warningTimerDecrement;
                _warningTimer = 0.0f;
                
                self.opacity = (self.opacity == 255) ? 64 : 255;
            }
        }
        
        return 1;
    }
    
    // go into unknown state, let whoever we notifiy reset us
    _state = kWaveTimerStateUnknown;
    
    // post notification that we completed
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationWaveTimerFinished object:self];
    
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    switch (_state) {
        case kWaveTimerStateDrain:   [self updateDrainState:elapsedTime];    break;
        case kWaveTimerStateFill:    [self updateFillState:elapsedTime];     break;
        case kWaveTimerStateActive:  [self updateActiveState:elapsedTime];   break;
        default: break;
    }
}

//
//
//
- (void)dealloc {
    self._overlay = nil;
    self._backing = nil;
    [super dealloc];
}

@end
