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
#import "TerminalLabel.h"
#import "LabelAnimateType.h"

//
// @implementation TerminalLabel
//
@implementation TerminalLabel

//
// synthesize
//
@synthesize _componentsArray;
@synthesize _delegate;
@synthesize _componentIndex;
@synthesize _currentXOffset;
@synthesize _typing;
@synthesize _updateTimer;
@synthesize _characterInterval;
@synthesize _timer;
@synthesize _cachedHeight;

//
//
//
+ (id)terminalLabel {
    TerminalLabel *terminalLabel = [[TerminalLabel alloc] init];
    return [terminalLabel autorelease];
}

//
//
//
- (id)init {
    self = [super init];
    
    self._componentsArray = [NSMutableArray array];
    self._delegate = nil;
    self._componentIndex = 0;
    self._currentXOffset = 0.0f;
    self._typing = false;
    self._updateTimer = false;
    self._characterInterval = 0.0f;
    self._timer = 0.0f;
    self._cachedHeight = 0.0f;
    
    [self scheduleUpdate];
    self.anchorPoint = ccp(0.0f, 0.0f);
    
    return self;
}

//
//
//
- (float)calcContentHeight {
    _cachedHeight = 0.0f;
    for (id object in _componentsArray) {
        
        float height = 0.0f;
        if ([object isKindOfClass:[LabelAnimateType class]]) {
            height = [object contentSize].height;
        }
        else if ([object isKindOfClass:[CCSprite class]]) {
            height = [object textureRect].size.height * [object scaleY];
        }
        
        if (height > _cachedHeight) {
            _cachedHeight = height;
        }
    }
    
    return _cachedHeight;
}

//
//
//
- (void)startTyping {
    
    // init variables
    _typing = true;
    _componentIndex = 0;
    _currentXOffset = 0.0f;
    _timer = 0.0f;
    
    // remove current children
    [self removeAllChildrenWithCleanup:true];
    
    // start typing first component
    [self typeNextComponent];
}

//
//
//
- (void)typeNextComponent {
    // if we are done, then report in to delegate
    if (_componentIndex >= [_componentsArray count]) {
        _typing = false;
        if (_delegate && [_delegate respondsToSelector:@selector(completedTyping:)]) {
            [_delegate completedTyping:self];
        }
        return;
    }
    
    // type next component
    id object = [_componentsArray objectAtIndex:_componentIndex];
    _componentIndex++;
    
    // start typing text label
    if ([object isKindOfClass:[LabelAnimateType class]]) {
        LabelAnimateType *labelAnimateType = (LabelAnimateType *)object;
        labelAnimateType._delegate = self;
        labelAnimateType.anchorPoint = ccp(0.0f, 0.0f);
        labelAnimateType.position = ccp(_currentXOffset, 0.0f);
        labelAnimateType._characterInterval = _characterInterval;
        [self addChild:labelAnimateType];
        [labelAnimateType typeString:[labelAnimateType getString]];
        _currentXOffset += labelAnimateType._goalWidth; // adjust x offset for next component
        return;
    }
    
    // else we will assume this a node that needs to be displayed
    CCSprite *sprite = (CCSprite *)object;
    
    // anchor is in middle, so need to translate to that point
    CGSize scaledSize = CGSizeMake(sprite.textureRect.size.width * sprite.scaleX, sprite.textureRect.size.height * sprite.scaleY);
    CGRect spriteDrawRect = CGRectMake(_currentXOffset, 0.0f, scaledSize.width, scaledSize.height);
    sprite.position = ccp(CGRectGetMidX(spriteDrawRect), scaledSize.height / 2.0f);
    
    // add to node and say we completed typing it out
    [self addChild:sprite];
    [self completedTyping:sprite];
    
    // update x offset
    _currentXOffset += scaledSize.width;
}

//
//
//
- (void)completedTyping:(id)object {
    _timer = 0.0f;
    _updateTimer = true;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    if (!_updateTimer) {
        return;
    }
    
    _timer += elapsedTime;
    if (_timer >= _characterInterval) {
        _updateTimer = false;
        [self typeNextComponent];
    }
}

//
//
//
- (void)dealloc {
    self._componentsArray = nil;
    self._delegate = nil;
    [super dealloc];
}

@end
