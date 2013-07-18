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
// forward declarations
//
@class LabelAnimateType;
@class LabelAnimateTypeSlider;
@class TerminalLabel;

//
// @interface TerminalWindow
//
@interface TerminalWindow : CCNode <LabelTypeDelegateProtocol> {
    id<TerminalWindowProtocol> _delegate;
    bool _active;
    TerminalWindowState _state;
    float _velocity;
	CGRect _currentRect;
	CGRect _prevCurrentRect;
	CGSize _goalSize;
	CGSize _goalSizeDirection;
	CGPoint _resizeAnchorPoint;
        
    // various elements
    CCSprite *_topLeftCorner;
    CCSprite *_topEdge;
    CCSprite *_topRightCorner;
    CCSprite *_leftEdge;
    CCSprite *_content;
    CCSprite *_rightEdge;
    CCSprite *_bottomLeftCorner;
    CCSprite *_bottomEdge;
    CCSprite *_bottomRightCorner;
    
    // commandline text, text should be printed using LabelAnimateType
    NSMutableArray *_commandLineText;
    bool _typing;
    bool _allCommandlineTextIsDisplayed;
    int _commandLineTextIndex;
}

//
// properties
//
@property (nonatomic, assign) id<TerminalWindowProtocol> _delegate;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) TerminalWindowState _state;
@property (nonatomic, assign) float _velocity;
@property (nonatomic, assign) CGRect _currentRect;
@property (nonatomic, assign) CGRect _prevCurrentRect;
@property (nonatomic, assign) CGSize _goalSize;
@property (nonatomic, assign) CGSize _goalSizeDirection;
@property (nonatomic, assign) CGPoint _resizeAnchorPoint;
@property (nonatomic, retain) CCSprite *_topLeftCorner;
@property (nonatomic, retain) CCSprite *_topEdge;
@property (nonatomic, retain) CCSprite *_topRightCorner;
@property (nonatomic, retain) CCSprite *_leftEdge;
@property (nonatomic, retain) CCSprite *_content;
@property (nonatomic, retain) CCSprite *_rightEdge;
@property (nonatomic, retain) CCSprite *_bottomLeftCorner;
@property (nonatomic, retain) CCSprite *_bottomEdge;
@property (nonatomic, retain) CCSprite *_bottomRightCorner;
@property (nonatomic, retain) NSMutableArray *_commandLineText;
@property (nonatomic, assign) bool _typing;
@property (nonatomic, assign) bool _allCommandlineTextIsDisplayed;
@property (nonatomic, assign) int _commandLineTextIndex;

//
// static methods
//
+ (id)terminalWindow;

//
// initialization
//
- (id)init;
- (void)initAnchorPoints;

//
// activate/deactivate
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint
						 size:(CGSize)terminalSize
                   parentNode:(CCNode *)parentNode
              spriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode;

- (int)deactivate;

//
// for adding command line text
//
- (LabelAnimateType *)setupCommandLineText:(NSString *)commandLineText;
- (LabelAnimateType *)addCommandLineText:(NSString *)commandLineText;
- (LabelAnimateTypeSlider *)addCommandLineTextSliderWithPercentage:(float)percentage;
- (void)addCommandLineLabelTypeObject:(id<LabelTypeProtocol>)object;
- (void)removeAllCommandLineText;
- (void)layoutCommandLineText;

//
// misc helper
//
- (bool)isReady;
- (void)calcPositions;
- (CGRect)calcHitBox;

//
// state mangement
//
- (void)resizeToNewSize:(CGSize)newSize withAnchorPoint:(CGPoint)anchorPoint hideAfterResize:(bool)hideAfterResize;
- (void)setStateToAlive;

//
// update
//
- (void)updateVelocty:(ccTime)elapsedTime;
- (void)updateStateResizing:(ccTime)elapsedTime;
- (void)update:(ccTime)elapsedTime;

//
// completed states
//
- (void)completedResizing;

//
// LabelAnimateTypeProtocol protocol
//
- (void)completedTyping:(id)object;

//
// CCNode override, this is for clipping commandline text
//
- (void)visit;

//
// cleanup
//
- (void)dealloc;

@end
