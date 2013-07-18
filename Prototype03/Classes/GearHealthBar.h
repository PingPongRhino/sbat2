//
//  GearHealthBar.h
//  Prototype03
//
//  Created by Cody Sandel on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// includes
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

//
// defines
//
#define GEAR_HEALTH_BAR_VERTEX_COUNT 4

//
// forward declarations
//
@class StageLayer;

//
// @interface GearHealthBar
//
@interface GearHealthBar : CCSprite {
    StageLayer *_stageLayer;
    bool _active;
    float _percentage;
    
    // vertex and texture coordinate info for triangle strip
    ccVertex2F _vertices[GEAR_HEALTH_BAR_VERTEX_COUNT];
    ccTex2F _texCoord[GEAR_HEALTH_BAR_VERTEX_COUNT];
    ccColor4B _colors[GEAR_HEALTH_BAR_VERTEX_COUNT];
}

//
// properties
//
@property (nonatomic, assign) StageLayer *_stageLayer;
@property (nonatomic, assign) bool _active;
@property (nonatomic, assign) float _percentage;

//
// static functions
//
+ (id)gearHealthBarWithStageLayer:(StageLayer *)stageLayer;
+ (CCSpriteFrame *)getFrame;

//
// functions
//
- (id)initWithStageLayer:(StageLayer *)stageLayer;
- (void)setPercentage:(float)percentage;
- (int)activate;
- (int)deactivate;
- (int)calcVerticesForEntireQuad;
- (int)calcVerticesForPartialQuad;
- (void)draw;
- (void)dealloc;

@end
