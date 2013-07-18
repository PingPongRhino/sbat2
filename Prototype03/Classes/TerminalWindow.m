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
#import "TerminalWindow.h"
#import "CCSprite+Extended.h"
#import "LabelAnimateType.h"
#import "LabelAnimateTypeSlider.h"
#import "CCNode+Extended.h"
#import "TerminalLabel.h"

//
// static globals
//
static const float _acceleration = 800.0f;
static const float _maxVelocity = 5000.0f;
static const float _contentSizeHeightAdjustment = 12.0f;
static const float _textTopMargin = 5.0f;
static const float _textLeftMargin = 1.0f;
static const ccTime _characterInterval = 0.005f;

//
// @implementation TerminalWindow
//
@implementation TerminalWindow

//
// synthesize
//
@synthesize _delegate;
@synthesize _active;
@synthesize _state;
@synthesize _velocity;
@synthesize _currentRect;
@synthesize _prevCurrentRect;
@synthesize _goalSize;
@synthesize _goalSizeDirection;
@synthesize _resizeAnchorPoint;
@synthesize _topLeftCorner;
@synthesize _topEdge;
@synthesize _topRightCorner;
@synthesize _leftEdge;
@synthesize _content;
@synthesize _rightEdge;
@synthesize _bottomLeftCorner;
@synthesize _bottomEdge;
@synthesize _bottomRightCorner;
@synthesize _commandLineText;
@synthesize _typing;
@synthesize _allCommandlineTextIsDisplayed;
@synthesize _commandLineTextIndex;

//
//
//
+ (id)terminalWindow {
    TerminalWindow *terminalWindow = [[TerminalWindow alloc] init];
    return [terminalWindow autorelease];
}

//
// methods
//
- (id)init {
    self = [super init];
    
    // init properties
    self._delegate = nil;
    self._active = false;
    self._state = kTerminalWindowStateUnknown;
    self._velocity = 0.0f;
	self._currentRect = CGRectZero;
	self._prevCurrentRect = CGRectZero;
	self._goalSize = CGSizeZero;
	self._goalSizeDirection = CGSizeZero;
	self._resizeAnchorPoint = CGPointZero;
    self._topLeftCorner     = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_top_left_corner.png"]];
    self._topEdge           = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_top_edge.png"]];
    self._topRightCorner    = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_top_right_corner.png"]];
    self._leftEdge          = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_left_edge.png"]]; 
    self._content           = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_content.png"]];
    self._rightEdge         = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_right_edge.png"]];
    self._bottomLeftCorner  = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_bottom_left_corner.png"]];
    self._bottomEdge        = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_bottom_edge.png"]];
    self._bottomRightCorner = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"terminal_window_bottom_right_corner.png"]];
    self._commandLineText = [NSMutableArray array];
    self._typing = false;
    self._allCommandlineTextIsDisplayed = true;
    self._commandLineTextIndex = 0;
    
    // init anchor points
    [self initAnchorPoints];
    
    // init super stuff
    [self scheduleUpdate];
    
    return self;
}

//
//
//
- (void)initAnchorPoints {
    self.anchorPoint = ccp(0.5f, 0.5f);
    _topLeftCorner.anchorPoint = ccp(0.0f, 0.0f);
    _topEdge.anchorPoint = ccp(0.0f, 0.0f);
    _topRightCorner.anchorPoint = ccp(0.0f, 0.0f);
    _leftEdge.anchorPoint = ccp(0.0f, 0.0f);
    _content.anchorPoint = ccp(0.0f, 0.0f);
    _rightEdge.anchorPoint = ccp(0.0f, 0.0f);
    _bottomLeftCorner.anchorPoint = ccp(0.0f, 0.0f);
    _bottomEdge.anchorPoint = ccp(0.0f, 0.0f);
    _bottomRightCorner.anchorPoint = ccp(0.0f, 0.0f);
}

//
//
//
- (int)activateWithSpawnPoint:(CGPoint)spawnPoint
						 size:(CGSize)terminalSize
                   parentNode:(CCNode *)parentNode
              spriteBatchNode:(CCSpriteBatchNode *)spriteBatchNode
{
    if (_active) {
        return 1;
    }
    
    _active = true;
	
	// make sure command line text has been cleared out
	[self removeAllCommandLineText];
    
    // add stuff to scene
    [parentNode addChild:self];
    [spriteBatchNode addChild:_content];
    [spriteBatchNode addChild:_topEdge];
    [spriteBatchNode addChild:_bottomEdge];
    [spriteBatchNode addChild:_leftEdge];
    [spriteBatchNode addChild:_rightEdge];
    [spriteBatchNode addChild:_topLeftCorner];
    [spriteBatchNode addChild:_topRightCorner];
    [spriteBatchNode addChild:_bottomLeftCorner];
    [spriteBatchNode addChild:_bottomRightCorner];
	
	// set initial sizing
	[_topEdge setTextureRectWidth:0.0f];
	[_leftEdge setTextureRectHeight:0.0f];
	[_content setTextureRectSize:CGSizeZero];
	[_rightEdge setTextureRectHeight:0.0f];
	[_bottomEdge setTextureRectWidth:0.0f];
	
	// init rect so it will end up centered around the spawn point
	_currentRect.origin = ccp(spawnPoint.x - (terminalSize.width / 2.0f),
							  spawnPoint.y + (terminalSize.height / 2.0f));
	_currentRect.size = CGSizeZero;
	
	// set initial positions
    [self calcPositions];
	
	// start resizing
	[self resizeToNewSize:terminalSize withAnchorPoint:ccp(0.0f, 1.0f) hideAfterResize:false];
	
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
    [_topLeftCorner removeFromParentAndCleanup:false];
    [_topEdge removeFromParentAndCleanup:false];
    [_topRightCorner removeFromParentAndCleanup:false];
    [_leftEdge removeFromParentAndCleanup:false];
    [_content removeFromParentAndCleanup:false];
    [_rightEdge removeFromParentAndCleanup:false];
    [_bottomLeftCorner removeFromParentAndCleanup:false];
    [_bottomEdge removeFromParentAndCleanup:false];
    [_bottomRightCorner removeFromParentAndCleanup:false];
    
    // kill commandline text
    [self removeAllCommandLineText];
        
    // notify delegate we are done
	if (_delegate && [_delegate respondsToSelector:@selector(completedHiding:)]) {
		[_delegate completedHiding:self];
	}
    
    return 0;
}

//
//
//
- (LabelAnimateType *)setupCommandLineText:(NSString *)commandLineText {
    LabelAnimateType *label = [LabelAnimateType labelWithFontName:FONT_DEFAULT fontSize:11.0f];
    [label setColor:FONT_COLOR_DEFAULT];
    [label setString:commandLineText];
    label.anchorPoint = ccp(0.0f, 0.0f);
    return label;
}

//
//
//
- (LabelAnimateType *)addCommandLineText:(NSString *)commandLineText {
    LabelAnimateType *label = [self setupCommandLineText:commandLineText];
    [self addCommandLineLabelTypeObject:label];
    return label;
}

//
//
//
- (LabelAnimateTypeSlider *)addCommandLineTextSliderWithPercentage:(float)percentage {
    LabelAnimateTypeSlider *slider = [LabelAnimateTypeSlider labelWithFontName:FONT_DEFAULT fontSize:11.0f];
    [slider setPercentage:percentage];
    [slider setColor:FONT_COLOR_DEFAULT];
    slider.anchorPoint = ccp(0.0f, 0.0f);
    [self addCommandLineLabelTypeObject:slider];
    return slider;
}

//
//
//
- (void)addCommandLineLabelTypeObject:(id<LabelTypeProtocol>)object {
    [_commandLineText addObject:object];
    self._allCommandlineTextIsDisplayed = false;
    [self layoutCommandLineText];
}

//
//
//
- (void)removeAllCommandLineText {
    
    for (CCNode *node in _commandLineText) {
        [node removeFromParentAndCleanup:false];
    }
    
    [_commandLineText removeAllObjects];
    _commandLineTextIndex = 0;
}

//
//
//
- (void)layoutCommandLineText {
    
    // if already typing or min/maximing window, then don't do anything
    if (_typing || _state != kTerminalWindowStateAlive) {
        return;
    }
    
    // if index is out of range, then bail
    if (_commandLineTextIndex >= [_commandLineText count]) {
        _allCommandlineTextIsDisplayed = true;
        return;
    }
        
    // relayout stuff
    float yPosition = 0.0f;
    for (int i=_commandLineTextIndex; i >= 0; i--) {
        id object = [_commandLineText objectAtIndex:i];
        [object setPosition:ccp(_textLeftMargin, yPosition)];
        yPosition += [object calcContentHeight] + _textTopMargin;
    }
    
    // tell this label to start typing
    _typing = true;
    id<LabelTypeProtocol> label = [_commandLineText objectAtIndex:_commandLineTextIndex];
    label._delegate = self;
    label._characterInterval = _characterInterval;
    [self addChild:label];
    [label startTyping];
}

//
//
//
- (bool)isReady {
    if (!_allCommandlineTextIsDisplayed || _state != kTerminalWindowStateAlive) {
        return false;
    }
    
    return true;
}

//
//
//
- (void)calcPositions {
    
    // make edges a little bigger to cover any stitching problems
    CGSize adjustedSize = CGSizeMake(_currentRect.size.width + 2.0f, _currentRect.size.height + 2.0f);
    
    // update texture sizes
    [_topEdge setTextureRectWidth:adjustedSize.width];
    [_leftEdge setTextureRectHeight:adjustedSize.height];
    [_content setTextureRectSize:adjustedSize];
    [_rightEdge setTextureRectHeight:adjustedSize.height];
    [_bottomEdge setTextureRectWidth:adjustedSize.width];

    // calc absolute value of rect
	CGRect absValueRect = CGRectMake(_currentRect.origin.x, _currentRect.origin.y, CGRectGetMaxX(_currentRect), CGRectGetMaxY(_currentRect));
	
    // set top sprites
    _topLeftCorner.position = ccp(absValueRect.origin.x - _topLeftCorner.contentSize.width, absValueRect.size.height);
    _topEdge.position = ccp(absValueRect.origin.x - 1.0f, absValueRect.size.height);
    _topRightCorner.position = ccp(absValueRect.size.width, absValueRect.size.height);
    
    // set middle sprites
    _leftEdge.position = ccp(absValueRect.origin.x - _leftEdge.contentSize.width, absValueRect.origin.y - 1.0f);
    _content.position = ccp(absValueRect.origin.x - 1.0f, absValueRect.origin.y - 1.0f); // shift out a bit for sticthing purposes
    _rightEdge.position = ccp(absValueRect.size.width, absValueRect.origin.y - 1.0f);
     
    // set bottom sprites
    _bottomLeftCorner.position = ccp(absValueRect.origin.x - _bottomLeftCorner.contentSize.width,
									 absValueRect.origin.y - _bottomLeftCorner.contentSize.height);
    _bottomEdge.position = ccp(absValueRect.origin.x - 1.0f, absValueRect.origin.y - _bottomEdge.contentSize.height);
    _bottomRightCorner.position = ccp(absValueRect.size.width, absValueRect.origin.y - _bottomRightCorner.contentSize.height);
}

//
//
//
- (CGRect)calcHitBox {
    CGRect hitBox = CGRectZero;
    hitBox.origin = _bottomLeftCorner.position;
    hitBox.size.width = (_topRightCorner.position.x + _topRightCorner.contentSize.width) - hitBox.origin.x;
    hitBox.size.height = (_topLeftCorner.position.y + _topLeftCorner.contentSize.height) - hitBox.origin.y;
    return hitBox;
}

//
//
//
- (void)resizeToNewSize:(CGSize)newSize withAnchorPoint:(CGPoint)anchorPoint hideAfterResize:(bool)hideAfterResize
{
    // clear current text
    [self removeAllCommandLineText];
    
    // update variables for going into resize state
	_state = hideAfterResize ? kTerminalWindowStateHiding : kTerminalWindowStateResizing;
	_prevCurrentRect = _currentRect;
	_goalSize = newSize;
	_resizeAnchorPoint = anchorPoint;
    _velocity = 0.0f;
	
	// determine directions
	_goalSizeDirection = CGSizeMake(1.0f, 1.0f);
	if (_goalSize.width < _content.textureRect.size.width) {
		_goalSizeDirection.width = -1.0f;
	}
	
	if (_goalSize.height < _content.textureRect.size.height) {
		_goalSizeDirection.height = -1.0f;
	}
}

//
//
//
- (void)setStateToAlive {
    _state = kTerminalWindowStateAlive;
    
    // adjust content size and position
	CGPoint middlePoint = ccp(CGRectGetMidX(_currentRect), CGRectGetMidY(_currentRect));
    self.position = ccp(middlePoint.x, middlePoint.y);
    self.contentSize = CGSizeMake(_currentRect.size.width, _currentRect.size.height + _contentSizeHeightAdjustment);
}

//
//
//
- (void)updateVelocty:(ccTime)elapsedTime {
    
    if (_velocity >= _maxVelocity) {
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
- (void)updateStateResizing:(ccTime)elapsedTime {
    
    // update velocity
    [self updateVelocty:elapsedTime];
    
    // calc delta
    float delta = elapsedTime * _velocity;
    
    // update sizes
	_currentRect.size.width += delta * _goalSizeDirection.width;
	_currentRect.size.height += delta * _goalSizeDirection.height;
	
	// cap width
	bool widthCompleted = false;
	if ((_goalSizeDirection.width == -1.0f && _currentRect.size.width < _goalSize.width) ||
		(_goalSizeDirection.width == 1.0f && _currentRect.size.width > _goalSize.width))
	{
		_currentRect.size.width = _goalSize.width;
		widthCompleted = true;
	}
	
	// cap height
	bool heightCompleted = false;
	if ((_goalSizeDirection.height == -1.0f && _currentRect.size.height < _goalSize.height) ||
		(_goalSizeDirection.height == 1.0f && _currentRect.size.height > _goalSize.height))
	{
		_currentRect.size.height = _goalSize.height;
		heightCompleted = true;
	}
	
	// update x origin if we need to
	if (_resizeAnchorPoint.x != 0.0f) {
		float diff = fabsf(_currentRect.size.width - _prevCurrentRect.size.width);
		float originOffset = diff * _resizeAnchorPoint.x * _goalSizeDirection.width;
		_currentRect.origin.x = _prevCurrentRect.origin.x - originOffset;
	}
	
	// update y origin if we need to
	if (_resizeAnchorPoint.y != 0.0f) {
		float diff = fabsf(_currentRect.size.height - _prevCurrentRect.size.height);
		float originOffset = diff * _resizeAnchorPoint.y * _goalSizeDirection.height;
		_currentRect.origin.y = _prevCurrentRect.origin.y - originOffset;
	}
	
    // recalc positions
    [self calcPositions];
    
    // see if we are done
	if (widthCompleted && heightCompleted) {
		[self completedResizing];
	}
}

//
//
//
- (void)update:(ccTime)elapsedTime {
	
	switch (_state) {
		case kTerminalWindowStateHiding:
		case kTerminalWindowStateResizing: [self updateStateResizing:elapsedTime]; break;
		default: break;
	}
}

//
//
//
- (void)completedResizing
{	
	// if resizing, then notify delegate and deactivate
	if (_state == kTerminalWindowStateResizing) {
		[self setStateToAlive];
		if (_delegate && [_delegate respondsToSelector:@selector(completedResizing:)]) {
			[_delegate completedResizing:self];
		}
		return;
	}
	
	// if hiding, then deactivate
	if (_state == kTerminalWindowStateHiding) {
		[self deactivate];
		return;
	}
}

//
//
//
- (void)completedTyping:(id)object {
    _typing = false;
    _commandLineTextIndex++;
    [self layoutCommandLineText];
}

//
// desc: copied this off the internetz
//
- (void) visit {
	if (!self.visible)
		return;
    
	glPushMatrix();
    
	glEnable(GL_SCISSOR_TEST);
    
	// convert from node space to world space
	CGPoint bottomLeft = [self convertToWorldSpace:CGPointZero];
	CGPoint topRight = [self convertToWorldSpace:ccp(self.contentSize.width, self.contentSize.height)];
    
	// calculate scissor rect in world space
	CGSize size = [[CCDirector sharedDirector] winSize];
	CGRect scissorRect = CGRectMake(bottomLeft.x, bottomLeft.y, topRight.x-bottomLeft.x, topRight.y-bottomLeft.y);
    
	// transform the clipping rectangle to adjust to the current screen
	// orientation: the rectangle that has to be passed into glScissor is
	// always based on the coordinate system as if the device was held with the
	// home button at the bottom. the transformations account for different
	// device orientations and adjust the clipping rectangle to what the user
	// expects to happen.
	ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
	switch (orientation) {
		case kCCDeviceOrientationPortrait:
			break;
		case kCCDeviceOrientationPortraitUpsideDown:
			scissorRect.origin.x = size.width-scissorRect.size.width-scissorRect.origin.x;
			scissorRect.origin.y = size.height-scissorRect.size.height-scissorRect.origin.y;
			break;
		case kCCDeviceOrientationLandscapeLeft:
		{
			float tmp = scissorRect.origin.x;
			scissorRect.origin.x = scissorRect.origin.y;
			scissorRect.origin.y = size.width-scissorRect.size.width-tmp;
			tmp = scissorRect.size.width;
			scissorRect.size.width = scissorRect.size.height;
			scissorRect.size.height = tmp;
		}
			break;
		case kCCDeviceOrientationLandscapeRight:
		{
			float tmp = scissorRect.origin.y;
			scissorRect.origin.y = scissorRect.origin.x;
			scissorRect.origin.x = size.height-scissorRect.size.height-tmp;
			tmp = scissorRect.size.width;
			scissorRect.size.width = scissorRect.size.height;
			scissorRect.size.height = tmp;
		}
			break;
	}
    
    // convert rect for retina if we need to
    scissorRect = [CCNode convertRectPointsToPixels:scissorRect];
    
	glScissor(scissorRect.origin.x, scissorRect.origin.y,
			  scissorRect.size.width, scissorRect.size.height);
    
	[super visit];
    
	glDisable(GL_SCISSOR_TEST);
	glPopMatrix();
}

//
//
//
- (void)dealloc {
    self._delegate = nil;
    self._topLeftCorner = nil;
    self._topEdge = nil;
    self._topRightCorner = nil;
    self._leftEdge = nil;
    self._content = nil;
    self._rightEdge = nil;
    self._bottomLeftCorner = nil;
    self._bottomEdge = nil;
    self._bottomRightCorner = nil;
    self._commandLineText = nil;
    [super dealloc];
}


@end
