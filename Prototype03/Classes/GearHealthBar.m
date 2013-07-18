//
//  GearHealthBar.m
//  Prototype03
//
//  Created by Cody Sandel on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// includes
//
#import "GearHealthBar.h"
#import "StageScene.h"
#import "StageLayer.h"

//
// @implementation GearHealthBar
//
@implementation GearHealthBar

//
// synthesize
//
@synthesize _stageLayer;
@synthesize _active;
@synthesize _percentage;

//
// functions
//
+ (id)gearHealthBarWithStageLayer:(StageLayer *)stageLayer {
    GearHealthBar *gearHealthBar = [[GearHealthBar alloc] initWithStageLayer:stageLayer];
    return [gearHealthBar autorelease];
}

//
//
//
+ (CCSpriteFrame *)getFrame {
    NSString *frameName = [NSString stringWithFormat:@"gear_health_bar.png"];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

//
//
//
- (id)initWithStageLayer:(StageLayer *)stageLayer {
    self = [super initWithSpriteFrame:[GearHealthBar getFrame]];
    
    // init properties
    self._stageLayer = stageLayer;
    self._active = false;
    self._percentage = 0.0f;
    
    // init colors
    for (int i=0; i < GEAR_HEALTH_BAR_VERTEX_COUNT; i++) {
        _colors[i] = (ccColor4B) { 255, 255, 255, 255 };
    }
    
    self.anchorPoint = ccp(0.0f, 0.0f);
    
    return self;
}

//
//
//
- (void)setPercentage:(float)percentage {
    if (percentage < 0.0f) {
        _percentage = 0.0f;
        return;
    }
    
    if (percentage > 1.0f) {
        _percentage = 1.0f;
        return;
    }
    
    _percentage = percentage;
}

//
//
//
- (int)activate {
    
    // if already active, then bail
    if (_active) {
        return 1;
    }
    
    // activate and add to scene
    _active = true;
    [_stageLayer addChild:self z:ZORDER_GEAR_HEALTH_BAR];
    
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
    
    // set to inactive and remove from scene
    _active = false;
    [self removeFromParentAndCleanup:false];
    
    return 0;
}

//
//
//
- (int)calcVerticesForEntireQuad {
    
    // set up vertices
    _vertices[0] = (ccVertex2F) { 0.0f,             0.0f };
    _vertices[1] = (ccVertex2F) { rect_.size.width, 0.0f };
    _vertices[2] = (ccVertex2F) { rect_.size.width, rect_.size.height };
    _vertices[3] = (ccVertex2F) { 0.0f,             rect_.size.height };
    
    // set up tex coords
    _texCoord[0] = quad_.bl.texCoords;
    _texCoord[1] = quad_.br.texCoords;
    _texCoord[2] = quad_.tr.texCoords;
    _texCoord[3] = quad_.tl.texCoords;
    
    return 4; // return that it's vertex count of 4
}

//
//
//
- (int)calcVerticesForPartialQuad {
    
    // calculate our angle and vector
    float angle = 90 * _percentage;
    CGPoint vector = ccpRotateByAngle(ccp(0.0f, 1.0f), ccp(0.0f, 0.0f), CC_DEGREES_TO_RADIANS(-angle));
    
    // set first vertex
    _vertices[0] = (ccVertex2F) { 0.0f, 0.0f };
    _texCoord[0] = quad_.bl.texCoords;
    
    // calc the moving vertex
    CGPoint edgeStart = CGPointZero;
    CGPoint edgeEnd = CGPointZero;
    ccTex2F texStart;
    ccTex2F texEnd;
    int vertexCount = 0;
    
    // if 50% or lower, then intersect with top edge
    if (_percentage <= 0.5f) {
        edgeStart = ccp(0.0f, rect_.size.height);
        edgeEnd = ccp(rect_.size.width, rect_.size.height);
        texStart = quad_.tl.texCoords;
        texEnd = quad_.tr.texCoords;
        vertexCount = 3; // only need one triangle for this
    }
    // else intersect with the right edge
    else {
        edgeStart = ccp(rect_.size.width, rect_.size.height);
        edgeEnd = ccp(rect_.size.width, 0.0f);
        texStart = quad_.br.texCoords;
        texEnd = quad_.tr.texCoords;
        vertexCount = 4; // will need two triangles for this
    }
    
    // intersect with segment and get hit point, we should always intersect, so don't worry
    // checking if the intersect actually hit or not
    float s = 0.0f;
    float t = 0.0f;
    ccpLineIntersect(edgeStart, edgeEnd, ccp(0.0f, 0.0f), vector, &s, &t);
    CGPoint hitPoint = ccpAdd(edgeStart, ccpMult(ccpSub(edgeEnd, edgeStart), s));
    _vertices[1] = (ccVertex2F) { hitPoint.x, hitPoint.y };
    
    // calc tex coordinate
    CGPoint texCoord = ccp(hitPoint.x / rect_.size.width, hitPoint.y / rect_.size.height);
    float distance = texEnd.u - texStart.u;
    _texCoord[1].u = texStart.u + (distance * texCoord.x);
    distance = texEnd.v - texStart.v;
    _texCoord[1].v = texStart.v + (distance * texCoord.y);
    
    // if we are only need one triangle 
    if (vertexCount == 3) {
        _vertices[2] = (ccVertex2F) { 0.0f, rect_.size.height };
        _texCoord[2] = quad_.tl.texCoords;
    }
    else { // else we need two
        _vertices[2] = (ccVertex2F) { rect_.size.width, rect_.size.height };
        _texCoord[2] = quad_.tr.texCoords;
        _vertices[3] = (ccVertex2F) { 0.0f, rect_.size.height };
        _texCoord[3] = quad_.tl.texCoords;
    }
    
    return vertexCount;
}

//
//
//
- (void)draw {
    
    // if percentage is zero, then bail, nothing to draw
    if (_percentage <= 0.0f) {
        return;
    }
    
    int vertexCount = 0;
    
    // if we are at 100% then just draw the quad
    if (_percentage >= 1.0f) {
        vertexCount = [self calcVerticesForEntireQuad];
    }
    else {
        vertexCount = [self calcVerticesForPartialQuad];
    }
    
    glBindTexture(GL_TEXTURE_2D, texture_.name);
    glVertexPointer(2, GL_FLOAT, 0, _vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _texCoord);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, _colors);
    glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
}

//
//
//
- (void)dealloc {
    [super dealloc];
}


@end
