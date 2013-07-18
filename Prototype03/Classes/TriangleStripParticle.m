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
#import "TriangleStripParticle.h"
#import "LaserEmitter.h"
#import "CubicBezier.h"
#import "CubicBezierControlPoint.h"
#import "ColorStateManager.h"
#import "TriangleStripParticleBatchNode.h"
#import "CCNode+Extended.h"
#import "SpriteFrameManager.h"

//
// static variables
//
static const int _vertexCount = 20;

//
// @implementation TriangleStripParticle
//
@implementation TriangleStripParticle

//
// synthesize
//
@synthesize _laserEmitter;
@synthesize _active;
@synthesize _colorState;
@synthesize _textureRect;
@synthesize _textureOffset;
@synthesize _scrollVelocity;
@synthesize _thickness;

//
//
//
+ (id)triangleStripParticleWithLaserEmitter:(LaserEmitter *)laserEmitter {
    TriangleStripParticle *triangleStripParticle = [[TriangleStripParticle alloc] initWithLaserEmitter:laserEmitter];
    return [triangleStripParticle autorelease];
}

//
//
//
- (id)initWithLaserEmitter:(LaserEmitter *)laserEmitter {
    self = [super initWithTexture:[SpriteFrameManager laserBaseTextureWithColorState:kColorStateDefault]];
    
    // init properties
    self._laserEmitter = laserEmitter;
    self._active = false;
    self._colorState = kColorStateDefault;
    self._textureOffset = ccp(0.0f, 0.0f);
    self._scrollVelocity = -350.0f;
    self._thickness = texture_.contentSizeInPixels.width * 0.5f;
    
    // init super node stuff
    self.anchorPoint = ccp(0.0f, 0.0f);
    
    // init vertex data
    [self initVertexData];
    
    return self;
}
    
//
//
//
- (void)initVertexData {
    
    for (int i=0; i < _vertexCount; i++) {
        _vertices[i] = (ccVertex2F) { 0.0f, 0.0f };
        _texCoord[i] = (ccTex2F) { 0.0f, 0.0f };
        _colors[i] = (ccColor4B) { 255, 255, 255, 255 };
    }
}

//
//
//
- (NSComparisonResult)sortByTextureName:(id)object {
    TriangleStripParticle *triangleStripParticle = object;
    
    // get texture names
    GLuint name_a = texture_.name;
    GLuint name_b = [triangleStripParticle texture].name;
    
    // do comparision
    if (name_a == name_b) {
        return NSOrderedSame;
    }
    
    if (name_a < name_b) {
        return NSOrderedAscending;
    }
    
    return NSOrderedDescending;
}

//
// activate/deactivate
//
- (int)activate {
  
    // if already active
    if (_active) {
        return 1;
    }
    
    // activate
    _active = true;
    
    // reset texture offset
    _textureOffset = ccp(0.0f, 0.0f);
    _textureRect = CGRectMake(0.0f, 0.0f, texture_.contentSizeInPixels.width, 0.0f);
    
    // add to batch node
    [[TriangleStripParticleBatchNode sharedTriangleStripParticleBatchNode] addParticle:self];
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if not active
    if (!_active) {
        return 1;
    }
    
    // deactivate
    _active = false;
    
    // remove from scene
    [[TriangleStripParticleBatchNode sharedTriangleStripParticleBatchNode] removeParticle:self];
    return 0;
}

//
//
//
- (void)switchToColorState:(ColorState)colorState {
    _colorState = colorState;
    [self setTexture:[SpriteFrameManager laserBaseTextureWithColorState:_colorState]];
}

//
//
//
- (void)updateWithNumber:(NSNumber *)elapsedTime {
    
    // update scrolling
    float delta = _scrollVelocity * [elapsedTime floatValue];
    _textureOffset.y += delta;
    
    // cap scrolling
    CGSize contentSize = texture_.contentSizeInPixels;
    if (_textureOffset.y > contentSize.height) {
        _textureOffset.y -= contentSize.height;
    }
    
	if (_textureOffset.y < 0) { 
        _textureOffset.y += contentSize.height;
    }
}

//
//
//
- (void)drawStripAlongBezier:(CubicBezier *)cubicBezier texOffset:(CGPoint)texOffset {
    
    // if cubic bezier is really small, then don't worry about drawing it
    if (cubicBezier._length <= 10.0f) {
        return;
    }
    
    CGSize texSize = texture_.contentSizeInPixels;
    
    // calc offset in u,v coordinates
    float xOffset = texOffset.x / texSize.width;
    float yOffset = texOffset.y / texSize.height;
    
    int vertexIndex = 0;
    CGPoint perp = ccp(0.0f, 0.0f);
        
    // calc vertices and tex coordinates for the bezier line
    for (int i=0; i < [cubicBezier._controlPoints count]; i++) {
        
        // if first or last object, then just use perp
        CubicBezierControlPoint *p1 = [cubicBezier._controlPoints objectAtIndex:i];
        
        if (i == [cubicBezier._controlPoints count]-1) {
            perp = ccpPerp(cubicBezier._targetNormal);
        }
        else {
            perp = ccpPerp(p1._normal);
        }
        
        // convert from points to pixels
        CGPoint controlPoint = [CCNode convertPointPointsToPixels:p1._position];
        
        // calc verticies
        CGPoint vertex1 = ccpAdd(controlPoint, ccpMult(perp, _thickness));
        CGPoint vertex2 = ccpAdd(controlPoint, ccpMult(perp, -_thickness));
        
        // vertices and vertex color
        _vertices[vertexIndex] = (ccVertex2F) { vertex1.x, vertex1.y };
        _vertices[vertexIndex+1] = (ccVertex2F) { vertex2.x, vertex2.y };
        
        // tex coordinates
        float v = p1._distance / texSize.height;                
        _texCoord[vertexIndex] = (ccTex2F) { 0.0f + xOffset, v + yOffset };
        _texCoord[vertexIndex+1] = (ccTex2F) { 1.0f + xOffset, v + yOffset };
        
        vertexIndex += 2;
    }
    
    glVertexPointer(2, GL_FLOAT, 0, _vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _texCoord);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, _colors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertexCount);
}

//
//
//
- (void)drawTriangleStrip {
    [self drawStripAlongBezier:_laserEmitter._cubicBezier texOffset:_textureOffset];
}

//
// cleanup
//
- (void)dealloc {
    self._laserEmitter = nil;
    [super dealloc];
}

@end
