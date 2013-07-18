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
@class LaserEmitter;
@class StageLayer;
@class CubicBezier;

//
// @interface TriangleStripParticle
//
@interface TriangleStripParticle : CCSprite {
    LaserEmitter *_laserEmitter;
    bool _active;
    ColorState _colorState;
    CGRect _textureRect;
    CGPoint _textureOffset;
    float _scrollVelocity;
    float _thickness;
    
    // vertex and texture coordinate info for triangle strip
    ccVertex2F _vertices[20];
    ccTex2F _texCoord[20];
    ccColor4B _colors[20];
}

//
// properties
//
@property (nonatomic, assign) LaserEmitter *_laserEmitter;
@property (nonatomic, assign) ColorState _colorState;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) CGRect _textureRect;
@property (nonatomic, assign) CGPoint _textureOffset;
@property (nonatomic, assign) float _scrollVelocity;
@property (nonatomic, assign) float _thickness;

//
// static functions
//
+ (id)triangleStripParticleWithLaserEmitter:(LaserEmitter *)laserEmitter;

//
// initializations
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter;
- (void)initVertexData;

//
// used by batch node to sort based on texture name
//
- (NSComparisonResult)sortByTextureName:(id)object;

//
// activate/deactivate
//
- (int)activate;
- (int)deactivate;

//
// color state
//
- (void)switchToColorState:(ColorState)colorState;

//
// update
//
- (void)updateWithNumber:(NSNumber *)elapsedTime;

//
// draw
//
- (void)drawStripAlongBezier:(CubicBezier *)cubicBezier texOffset:(CGPoint)texOffset;
- (void)drawTriangleStrip;

//
// cleanup
//
- (void)dealloc;

@end
