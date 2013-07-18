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
#import "GearSwitch.h"
#import "StageLayer.h"
#import "SpriteFrameManager.h"
#import "NotificationStrings.h"

//
// static globals
//
static const float _gearBaseVelocity = 200.0f; // how quicly the base will fill up with the new color

//
// @implementation GearSwitch
//
@implementation GearSwitch

//
// properties
@synthesize _active;
@synthesize _colorState;

//
//
//
+ (id)gearSwitch {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:false colorState:kColorStateDefault]];
    GearSwitch *gearSwitch = [[GearSwitch alloc] initWithSprite:sprite];
    return [gearSwitch autorelease];
}

//
// functions
//
- (id)initWithSprite:(CCSprite *)sprite {
    
    // init progress timer super class
    self = [super initWithSprite:sprite];
    
    // init properties
    self._active = false;
    self._colorState = kColorStateDefault;
    
    // init super class stuff
    self.type = kCCProgressTimerTypeRadial;
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (int)activateWithColorState:(ColorState)colorState {
    
    // if already activate then bail
    if (_active) {
        return 1;
    }
    
    // overwrite so it's always white right now
    _colorState = colorState;
    
    // activate and add to scene
    _active = true;
    [[StageLayer sharedStageLayer] addChild:self z:ZORDER_GEAR_SWITCH_BASE];
    
    // set display frame
    [self.sprite setDisplayFrame:[SpriteFrameManager gearSpriteFrameWithTeeth:false colorState:_colorState]];
    
    // just to make sure we refresh the frame, we want to make sure we change the percentage value
    // it's pretty hackish to get the ccprogresstimer to play nicely
    self.percentage = 100.0f;
    self.percentage = 0.0f;
    
    return 0;
    
}

//
//
//
- (int)deactivate {
    
    // if already inactive then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    // report to parent we deactivated
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGearSwitchDeactivated object:self];
    return 0;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    float delta = _gearBaseVelocity * elapsedTime;
    self.percentage += delta;
    
    if (self.percentage >= 100.0f) {
        [self deactivate];
    }
}

//
//
//
- (void)dealloc {
    [self deactivate];
    [super dealloc];
}

@end
