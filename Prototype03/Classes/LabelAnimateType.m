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
// incudles
//
#import "LabelAnimateType.h"
#import "CCSprite+Extended.h"
#import "UITouch+Extended.h"

//
// static globals
//
static const ccTime _defaultCharacterInterval = 0.01f;//0.05f; // interval to wait between each character
static const float _offsetWidth = 1.0f; // pull back a pixel on the width calculation, it was overflowling a little into next character
static NSString * const _endOfLineString = @"_"; // character that shows up at end while it is being typed
static const float _backgroundTopMargin = 2.0f;
static float _hitMarignWidth = 75.0f;
static float _hitMarginHeight = 15.0f;

//
// @implementation LabelAnimateType
//
@implementation LabelAnimateType

//
// synthesize
//
@synthesize _fontName;
@synthesize _fontSize;
@synthesize _delegate;
@synthesize _stringToType;
@synthesize _timer;
@synthesize _characterIndex;
@synthesize _typing;
@synthesize _completedTyping;
@synthesize _goalWidth;
@synthesize _endOfLineCharLabel;
@synthesize _characterInterval;
@synthesize _backgroundColor;
@synthesize _highlighted;

//
//
//
+ (id)labelWithFontName:(NSString *)name fontSize:(CGFloat)size {
    LabelAnimateType *label = [[LabelAnimateType alloc] initWithFontName:name fontSize:size];
    return [label autorelease];
}

//
//
//
- (id)initWithFontName:(NSString *)name fontSize:(CGFloat)size {
    self = [super initWithString:@"" fontName:name fontSize:size];
    
    self._fontName = name;
    self._fontSize = size;
    self._delegate = nil;
    self._stringToType = nil;
    self._timer = 0.0f;
    self._characterIndex = 0;
    self._typing = false;
    self._completedTyping = false;
    self._goalWidth = 0.0f;
    self._endOfLineCharLabel = [CCLabelTTF labelWithString:_endOfLineString fontName:_fontName fontSize:_fontSize];
    self._characterInterval = _defaultCharacterInterval;
    self._backgroundColor = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 0)];
    self._highlighted = false;
    
    // init end of line char labe properties
    _endOfLineCharLabel.anchorPoint = ccp(0.0f, 0.0f);
    
    [super scheduleUpdate];
    
    return self;
}

//
//
//
- (void)setForegroundColor:(ccColor3B)foregroundColor {
    [_backgroundColor removeFromParentAndCleanup:false];
    [self setColor:foregroundColor];
}

//
//
//
- (void)setForegroundColor:(ccColor3B)foregroundColor backgroundColor:(ccColor3B)backgroundColor {
    [_backgroundColor changeWidth:self.contentSize.width height:self.contentSize.height + _backgroundTopMargin];
    _backgroundColor.anchorPoint = ccp(0.0f, 0.0f);
    _backgroundColor.position = self.position;
    [_backgroundColor setColor:backgroundColor];
    [_backgroundColor setOpacity:255];
    [_backgroundColor removeFromParentAndCleanup:false];
    [self.parent addChild:_backgroundColor z:self.zOrder-1];
    
    [self setColor:foregroundColor];
}

//
//
//
- (void)setHighlighted:(bool)highlighted {
    _highlighted = highlighted;
    if (_highlighted) {
        [self setForegroundColor:FONT_COLOR_HIGHLIGHT backgroundColor:FONT_COLOR_HIGHLIGHT_BACKGROUND];
    }
    else {
        [self setForegroundColor:FONT_COLOR_DEFAULT];
    }
    
}

//
//
//
- (NSString *)getString {
    return string_;
}

//
//
//
- (CGRect)getHitBoundingBox {
    
    CGSize halfSize = CGSizeMake(self.contentSize.width / 2.0f, self.contentSize.height / 2.0f);
    CGPoint centerPoint = [self convertToWorldSpace:ccp(halfSize.width, halfSize.height)];
    CGRect hitBoundingBox = CGRectZero;
    hitBoundingBox.origin.x = centerPoint.x - (halfSize.width + _hitMarignWidth);
    hitBoundingBox.origin.y = centerPoint.y - (halfSize.height + _hitMarginHeight);
    hitBoundingBox.size.width = self.contentSize.width + (_hitMarignWidth * 2.0f);
    hitBoundingBox.size.height = self.contentSize.height + (_hitMarginHeight * 2.0f);
    return hitBoundingBox;
}

//
//
//
- (bool)wasHitByTouch:(UITouch *)touch {
    // get bounding box for 
    CGRect hitBoundBox = [self getHitBoundingBox];
    
    // check if touch landed in our hit bounding box
    if (CGRectContainsPoint(hitBoundBox, [touch worldCoordinate])) {
        return true;
    }
    
    return false;
}

//
//
//
- (float)calcContentHeight {
    return self.contentSize.height;
}

//
//
//
- (void)startTyping {
    [self typeString:[self getString]];
}

//
//
//
- (int)typeString:(NSString *)stringToType {
    self._stringToType = stringToType;
    
    // reset variables
    [self setString:_stringToType];
    _timer = _characterInterval;
    _characterIndex = 0;
    _typing = true;
    _completedTyping = false;
    
    // save off goal width
    _goalWidth = self.textureRect.size.width;
    
    // set initial texture size
    [self setTextureRectWidth:0.0f];
    
    // add end of line character
    [self.parent addChild:_endOfLineCharLabel z:self.zOrder];
    _endOfLineCharLabel.position = self.position;
    
    // type first character
    [self update:0.0f];
    return 0;
}

//
//
//
- (void)finishTyping {
    
    // if not typing, then do nothing
    if (!_typing) {
        return;
    }
    
    // set texture rect to the full width
    [self setTextureRectWidth:_goalWidth];
    
    // remove end of line character
    [_endOfLineCharLabel removeFromParentAndCleanup:false];
    
    // if we completed typing, then notify delegate
    _characterIndex = [_stringToType length];
    _typing = false;
    _completedTyping = true;
    [_delegate completedTyping:self];
}

//
//
//
- (float)getTextureWidthForString:(NSString *)string
{
    CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:_fontName fontSize:_fontSize];
    return label.contentSize.width - _offsetWidth;
}

//
//
//
- (void)update:(ccTime)elapsedTime {
    
    // if we typed all the characters
    if (_characterIndex > [_stringToType length]) {
        [self finishTyping];
        return;
    }
    
    // check if it's time to type another character
    _timer += elapsedTime;
    
    // type out characters
    while (_timer >= _characterInterval) {
        
        // reset timer
        _timer -= _characterInterval;
        
        // go to next character to type
        _characterIndex++;
        if (_characterIndex > [_stringToType length]) {
            [self finishTyping];
            return;
        }
        
        // get substring up to new character index
        NSString *newString = [_stringToType substringToIndex:_characterIndex];
        float width = [self getTextureWidthForString:newString];
        [self setTextureRectWidth:width];
        
        // now add our end of line character
        CGPoint newPosition = _endOfLineCharLabel.position;
        newPosition.x = self.position.x + (self.textureRect.size.width + _offsetWidth);
        _endOfLineCharLabel.position = newPosition;
    }
}

//
//
//
- (void)removeFromParentAndCleanup:(BOOL)cleanup {
    
    if (_typing) {
        [self finishTyping];
    }
    
    [super removeFromParentAndCleanup:cleanup];
}

//
//
//
- (void)dealloc {
    self._fontName = nil;
    self._delegate = nil;
    self._stringToType = nil;
    self._endOfLineCharLabel = nil;
    self._backgroundColor = nil;
    [super dealloc];
}

@end
