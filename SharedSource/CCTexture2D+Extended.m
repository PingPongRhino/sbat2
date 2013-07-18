//
//  CCTexture2D+Extended.m
//  Prototype03
//
//  Created by Cody Sandel on 4/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//
// includes
//
#import "CCTexture2D+Extended.h"
#import "CubicBezier.h"
#import "CubicBezierControlPoint.h"

//
// @implementation CCTexture2D (Extended)
//
@implementation CCTexture2D (Extended)

//
//
//
- (void)drawAtPoint:(CGPoint)point texOffset:(CGPoint)texOffset {
    
    float xOffset = texOffset.x / size_.width;
    float yOffset = texOffset.y / size_.height;
    
    GLfloat  coordinates[] = {
        0.0f  + xOffset, maxT_ + yOffset,
        maxS_ + xOffset, maxT_ + yOffset,
        0.0f  + xOffset, 0.0f  + yOffset,
        maxS_ + xOffset, 0.0f  + yOffset
    };
    
    GLfloat vertices[] = {
        point.x,               point.y,
        point.x + size_.width, point.y,                           
        point.x,               point.y + size_.height,       
        point.x + size_.width, point.y + size_.height
    };
    
    glBindTexture(GL_TEXTURE_2D, name_);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

//
//
//
- (void)drawInRect:(CGRect)rect texOffset:(CGPoint)texOffset {
    
    // if rect width or height is zero, then don't draw
    if (rect.size.width <= 0.0f || rect.size.height <= 0.0f) {
        return;
    }
    
    // calc offset in u,v coordinates
    float xOffset = texOffset.x / size_.width;
    float yOffset = texOffset.y / size_.height;
    
    // so it doesn't stretch
    float maxS = rect.size.width / size_.width;
    float maxT = rect.size.height / size_.height;
    
    // set texture coordinates
    GLfloat  coordinates[] = {
        0.0f  + xOffset, maxT + yOffset,
        maxS + xOffset, maxT + yOffset,
        0.0f  + xOffset, 0.0f  + yOffset,
        maxS + xOffset, 0.0f  + yOffset
    };
    
    // set texture coordinates
    GLfloat vertices[] = {
        rect.origin.x,                   rect.origin.y,
        rect.origin.x + rect.size.width, rect.origin.y,
        rect.origin.x,                   rect.origin.y + rect.size.height,
        rect.origin.x + rect.size.width, rect.origin.y + rect.size.height
    };

    glBindTexture(GL_TEXTURE_2D, name_);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
