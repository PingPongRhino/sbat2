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
#import "protocols.h"

//
// forward declarations
//
@class ScoreTerminalWindow;
@class WaveTimer;
@class LabelAnimateType;
@class ScoreManager;

//
// @interface HUDTopTerminal
//
@interface HUDTopTerminal : NSObject <TerminalWindowProtocol,
                                      LabelTypeDelegateProtocol,
                                      TouchProtocol>
{   
	// track state
    bool _active;
    
    // stuff to display
    ScoreTerminalWindow *_scoreTerminalWindow;
    LabelAnimateType *_scoreLabel;
    LabelAnimateType *_waveLabel;
    WaveTimer *_waveTimer;
    
    // touch stuff
    UITouch *_touch;
}

//
// properties
//
@property (nonatomic, assign) bool _active;
@property (nonatomic, retain) ScoreTerminalWindow *_scoreTerminalWindow;
@property (nonatomic, retain) LabelAnimateType *_scoreLabel;
@property (nonatomic, retain) LabelAnimateType *_waveLabel;
@property (nonatomic, retain) WaveTimer *_waveTimer;
@property (nonatomic, assign) UITouch *_touch;

//
// static initializer
//
+ (id)hudTopTerminal;

//
// initialize
//
- (id)init;

//
// activate/deactivate
//
- (int)activateWithScoreManager:(ScoreManager *)scoreManager;
- (int)deactivate;

//
// manage timer
//
- (void)resetWaveTimer;
- (void)stopWaveTimer;

//
// manage display
//
- (void)hideTerminal;
- (void)refreshScoreWithScore:(u_int64_t)score;
- (void)refreshWaveLabelWithWave:(int)waveNumber;

//
// TerminalWindowProtocol
//
- (void)completedResizing:(ScoreTerminalWindow *)terminalWindow;
- (void)completedHiding:(ScoreTerminalWindow *)terminalWindow;

//
// LabelTypeDelegateProtocol
//
- (void)completedTyping:(LabelAnimateType *)labelAnimateType;

//
// handle notifications
//
- (void)handleScoreChanged:(NSNotification *)notification;

//
// TouchProtocol
//
- (bool)handleTouchBegan:(UITouch *)touch handleIfCloserThanDistance:(float *)minDistance;
- (void)handleTouchMoved:(UITouch *)touch;
- (bool)handleTouchEnded:(UITouch *)touch;
- (void)handleTouchCancelled:(UITouch *)touch;

//
// cleanup
//
- (void)dealloc;

@end
