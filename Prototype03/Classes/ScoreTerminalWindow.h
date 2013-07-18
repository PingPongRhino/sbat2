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
#import "protocols.h"

//
// @interface ConsoleWindow
//
@interface ScoreTerminalWindow : CCSprite {
    id<TerminalWindowProtocol> _delegate;
    
    // state stuff
    bool _active;
    TerminalWindowState _state;
    bool _reverse;
    
    // for animating in the terminal
    CCSprite *_terminalLeftEdge;
    CCSprite *_terminalRightEdge;
    CCSprite *_terminalMiddle;
    
    // variables for animating states
    float _velocity;
    float _terminalMiddleGoalWidth;
}

//
// properties
//
@property (nonatomic, assign) id<TerminalWindowProtocol> _delegate;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) TerminalWindowState _state;
@property (nonatomic, assign) bool _reverse;
@property (nonatomic, retain) CCSprite *_terminalLeftEdge;
@property (nonatomic, retain) CCSprite *_terminalRightEdge;
@property (nonatomic, retain) CCSprite *_terminalMiddle;
@property (nonatomic, assign) float _velocity;
@property (nonatomic, assign) float _terminalMiddleGoalWidth;

//
// static functions
//
+ (id)scoreTerminalWindow;

//
// initialization
//
- (id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame;
- (CCSprite *)createTerminalLeftEdge;
- (CCSprite *)createTerminalRightEdge;
- (CCSprite *)createTerminalMiddle;

//
// activate/deactivate
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint;
- (int)deactivate;

//
// initiat stuff
//
- (void)hideTerminal;

//
// set state stuff
//
- (int)setStateToExpanding:(bool)reverse;
- (int)setStateToAlive;

//
// update
//
- (void)updateVelocity:(ccTime)elapsedTime;
- (void)updateStateExpanding:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;

//
// cleanup
//
- (void)dealloc;

@end
