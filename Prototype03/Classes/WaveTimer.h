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
// forward declarations
//
@class EnemySpawnManager;
@class StageLayer;

//
// @interface WaveTimer
//
@interface WaveTimer : CCProgressTimer {
    bool _active;
    WaveTimerState _state;
    float _drainFromPercentage;
    
    // top and bottom sprites
    CCSprite *_overlay;
    CCSprite *_backing;
    
    // timers
    ccTime _drainInterval;
    ccTime _drainTimer;
    ccTime _fillInterval;
    ccTime _fillTimer;
    ccTime _activeInterval;
    ccTime _activeTimer;
    
    ccTime _warningInterval;
    ccTime _warningTimer;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) WaveTimerState _state;
@property (nonatomic, assign) float _drainFromPercentage;
@property (nonatomic, retain) CCSprite *_overlay;
@property (nonatomic, retain) CCSprite *_backing;
@property (nonatomic, assign) ccTime _drainInterval;
@property (nonatomic, assign) ccTime _drainTimer;
@property (nonatomic, assign) ccTime _fillInterval;
@property (nonatomic, assign) ccTime _fillTimer;
@property (nonatomic, assign) ccTime _activeInterval;
@property (nonatomic, assign) ccTime _activeTimer;
@property (nonatomic, assign) ccTime _warningInterval;
@property (nonatomic, assign) ccTime _warningTimer;

//
// static functions
//
+ (WaveTimer *)waveTimer;

//
// functions
//
- (id)initWithSprite:(CCSprite *)sprite;
- (int)activate;
- (int)deactivate;
- (void)stopTimer;
- (void)setToDrainState;
- (void)setToFillState;
- (void)setToActiveState;
- (int)updateDrainState:(ccTime)elapsedTime;
- (int)updateFillState:(ccTime)elapsedTime;
- (int)updateActiveState:(ccTime)elapsedTimes;
- (void)update:(ccTime)elapsedTime;
- (void)dealloc;

@end
