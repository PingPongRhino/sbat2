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
#import "TriangleStripParticleBatchNode.h"
#import "StageLayer.h"
#import "TriangleStripParticle.h"

//
// static globals
//
static TriangleStripParticleBatchNode *_sharedTriangleStripParticleBatchNode = nil;

//
// @implementation TriangleStripParticleBatchNode
//
@implementation TriangleStripParticleBatchNode

//
// synthesize
//
@synthesize _triangleStripParticles;
@synthesize _active;

//
//
//
+ (TriangleStripParticleBatchNode *)createSharedTriangleStripParticleBatchNode {
    [TriangleStripParticleBatchNode destroySharedTriangleStripParticleBatchNode];
    _sharedTriangleStripParticleBatchNode = [[TriangleStripParticleBatchNode alloc] init];
    return _sharedTriangleStripParticleBatchNode;
}

//
//
//
+ (TriangleStripParticleBatchNode *)sharedTriangleStripParticleBatchNode {
    return _sharedTriangleStripParticleBatchNode;
}

//
//
//
+ (void)destroySharedTriangleStripParticleBatchNode {
    [_sharedTriangleStripParticleBatchNode release];
    _sharedTriangleStripParticleBatchNode = nil;
}

//
//
//
- (id)init {
    self = [super init];
    
    // init properties
    self._triangleStripParticles = [NSMutableSet set];
    self._active = false;
    
    // ini super class stuff
    [super scheduleUpdate];
    
    return self;
}

//
//
//
- (int)activate {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // set to active and add to scene
    _active = true;
    [[StageLayer sharedStageLayer] addChild:self z:ZORDER_TRIANGLE_STRIP_PARTICLE_BATCH_NODE];
    
    return 0;
}

//
//
//
- (int)deactivate {
    
    // if already inactive, then bail
    if (!_active) {
        return 1;
    }
    
    // deactivate and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    return 0;
}

//
//
//
- (void)addParticle:(TriangleStripParticle *)triangleStripParticle { [_triangleStripParticles addObject:triangleStripParticle]; }
- (void)removeParticle:(TriangleStripParticle *)triangleStripParticle { [_triangleStripParticles removeObject:triangleStripParticle]; }

//
//
//
- (void)update:(ccTime)elapsedTime {
    [_triangleStripParticles makeObjectsPerformSelector:@selector(updateWithNumber:)
                                                withObject:[NSNumber numberWithFloat:elapsedTime]];
}

//
//
//
- (void)draw {
    
    // if no objects, then nothing ot draw, so bail
    if ([_triangleStripParticles count] <= 0) {
        return;
    }
    
    // sort our triangle strips by their texture
    NSMutableArray *sortedTriangleStripParticles = [[NSMutableArray alloc] initWithArray:[_triangleStripParticles allObjects]];
    [sortedTriangleStripParticles sortUsingSelector:@selector(sortByTextureName:)];
        
    // bind to first triangle strip
    TriangleStripParticle *triangleStripParticle = [sortedTriangleStripParticles objectAtIndex:0];
    GLuint currentTextureName = [triangleStripParticle texture].name;
    glBindTexture(GL_TEXTURE_2D, currentTextureName);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT); // this has to happen after the bind, it gets reset after every bind
    
    // draw all our triangle strips
    for (int i=0; i < [sortedTriangleStripParticles count]; i++) {
        TriangleStripParticle *triangleStripParticle = [sortedTriangleStripParticles objectAtIndex:i];
        GLuint textureName = [triangleStripParticle texture].name;
        
        // if this is new texture, then bind to it and set new currenttexture
        if (textureName != currentTextureName) {
            currentTextureName = textureName;
            glBindTexture(GL_TEXTURE_2D, currentTextureName);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }
        
        // draw the triangle strip
        [triangleStripParticle drawTriangleStrip];
    }
    
    [sortedTriangleStripParticles release];
}

//
//
//
- (void)dealloc {
    [self deactivate];
    self._triangleStripParticles = nil;
    [super dealloc];
}

@end
