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
// @interface LabelAnimateType
//
@interface LabelAnimateType : CCLabelTTF <LabelTypeProtocol> {
    NSString *_fontName;
    CGFloat _fontSize;
    id<LabelTypeDelegateProtocol> _delegate;
    NSString *_stringToType;
    ccTime _timer;
    int _characterIndex;
    bool _typing;
    bool _completedTyping;
    float _goalWidth;
    CCLabelTTF *_endOfLineCharLabel;
    ccTime _characterInterval;
    CCLayerColor *_backgroundColor;
    bool _highlighted;
}

//
// properties
//
@property (nonatomic, copy  ) NSString *_fontName;
@property (nonatomic, assign) CGFloat _fontSize;
@property (nonatomic, assign) id<LabelTypeDelegateProtocol> _delegate;
@property (nonatomic, copy  ) NSString *_stringToType;
@property (nonatomic, assign) ccTime _timer;
@property (nonatomic, assign) int _characterIndex;
@property (nonatomic, assign) bool _typing;
@property (nonatomic, assign) bool _completedTyping;
@property (nonatomic, assign) float _goalWidth;
@property (nonatomic, retain) CCLabelTTF *_endOfLineCharLabel;
@property (nonatomic, assign) ccTime _characterInterval;
@property (nonatomic, retain) CCLayerColor *_backgroundColor;
@property (nonatomic, assign) bool _highlighted;

//
//
//
+ (id)labelWithFontName:(NSString *)name fontSize:(CGFloat)size;

//
//
//
- (id)initWithFontName:(NSString *)name fontSize:(CGFloat)size;

//
// getter/setter stuff
//
- (NSString *)getString;
- (CGRect)getHitBoundingBox;
- (void)setForegroundColor:(ccColor3B)foregroundColor;
- (void)setForegroundColor:(ccColor3B)foregroundColor backgroundColor:(ccColor3B)backgroundColor;
- (void)setHighlighted:(bool)highlighted;

//
// touch detection stuff
//
- (bool)wasHitByTouch:(UITouch *)touch;

//
// methods for typing out string
//
- (float)calcContentHeight;
- (void)startTyping;
- (int)typeString:(NSString *)stringToType;
- (void)finishTyping;
- (float)getTextureWidthForString:(NSString *)string;
- (void)update:(ccTime)elapsedTime;

//
// CCNode overrides
//
- (void)removeFromParentAndCleanup:(BOOL)cleanup;

//
// cleanup
//
- (void)dealloc;

@end
