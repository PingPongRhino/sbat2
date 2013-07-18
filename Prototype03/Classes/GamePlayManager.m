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
#import "GamePlayManager.h"
#import "StageLayer.h"
#import "GPM_TutorialBaseTowers.h"
#import "GPM_TutorialMobileTower.h"
#import "GPM_SurvivalMode.h"
#import "UITouch+Extended.h"
#import "NotificationStrings.h"
#import "protocols.h"

//
// @implementation GamePlayManager
//
@implementation GamePlayManager

//
// synthesize
//
@synthesize _active;
@synthesize _gameMode;
@synthesize _touchObjectArray;
@synthesize _touchLowPrioritySet;

//
//
//
+ (GamePlayManager *)gamePlayManagerWithGameMode:(GameMode)gameMode {
    GamePlayManager *gamePlayManager = nil;
    switch (gameMode) {
        case kGameModeBaseTowerTutorial:    gamePlayManager = [[GPM_TutorialBaseTowers alloc] initWithGameMode:gameMode]; break;
        case kGameModeMobileTowerTutorial:  gamePlayManager = [[GPM_TutorialMobileTower alloc] initWithGameMode:gameMode]; break;
        case kGameModeSurvival:             gamePlayManager = [[GPM_SurvivalMode alloc] initWithGameMode:gameMode]; break;
        default: break;
    }
    
    return [gamePlayManager autorelease];
}

//
//
//
- (id)initWithGameMode:(GameMode)gameMode {
    self = [super init];
    self._active = false;
    self._gameMode = gameMode;
    self._touchObjectArray = [NSMutableArray array];
    self._touchLowPrioritySet = [NSMutableSet set];
    return self;
}

//
//
//
- (int)activate {
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
        
    // reset touch stuff just to be safe
    [_touchObjectArray removeAllObjects];
    [_touchLowPrioritySet removeAllObjects];
    [self activateGamePlay];
    return 0;
}

//
//
//
- (int)deactivate {
    if (!_active) {
        return 1;
    }
    
    // set to inactive and tell subclass to do it's deactivation
    _active = false;
    
    // deactivate gameplay
    [self deactivateGamePlay];
    
    // reset touch stuff
    [_touchObjectArray removeAllObjects];
    [_touchLowPrioritySet removeAllObjects];
    
    // notify that we deactivated
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGamePlayManagerDeactivated object:self];
    return 0;
}

//
// desc: meant to be overridden by sub classes
//
- (void)activateGamePlay { }
- (void)deactivateGamePlay { }

//
// desc: delegate for handling touch began
//
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    float minDistance = MAXFLOAT;
    id<TouchProtocol> touchObjectHandler = nil;
    for (id<TouchProtocol> touchObject in _touchObjectArray) {
        
        // if this is low priority touch object AND we already have a high priority object, then bail
        if ([_touchLowPrioritySet containsObject:touchObject] && touchObjectHandler) {
            continue;
        }
        
        if ([touchObject handleTouchBegan:touch handleIfCloserThanDistance:&minDistance]) {
            touchObjectHandler = touchObject;
        }        
    }
    
    // if we got a touch handler, tell everyone else to drop this touch if they tried to grab it
    for (id<TouchProtocol> touchObject in _touchObjectArray) {
        if (touchObject == touchObjectHandler) {
            break;
        }
        [touchObject handleTouchCancelled:touch];
    }
    
    return YES;
}

//
// desc: delegate for handling touch moved
//
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [_touchObjectArray makeObjectsPerformSelector:@selector(handleTouchMoved:) withObject:touch];     
}

//
// desc: delegate for handling touch ended
//
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouchCompeleted:touch withEvent:event];
}

//
//
//
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouchCompeleted:touch withEvent:event];
}

//
//
//
- (void)handleTouchCompeleted:(UITouch *)touch withEvent:(UIEvent *)event {
    for (id<TouchProtocol> touchObject in _touchObjectArray) {
        if ([touchObject handleTouchEnded:touch]) {
            break;
        }
    }    
}

//
//
//
- (void)dealloc {
    self._touchObjectArray = nil;
    self._touchLowPrioritySet = nil;
    [super dealloc];
}


@end
