//
//  HelloWorldLayer.h
//  Landslide
//
//  Created by Oliver Rickard on 11/23/11.
//  Copyright UC Berkeley 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SlopeAnalyzer.h"

@class DetailController;
@class CCUIViewWrapper;

// HelloWorldLayer
@interface SlopeViewLayer : CCLayerColor
{
    float L;
    float Ls;
    float H;
    CGPoint center;
    float R;
    
    NSArray *thicknesses;
    NSArray *gamma;
    NSArray *phi;
    NSArray *cohesion;
    NSMutableArray *colors;
    UIViewController *topLayerController;
    
    SlopeAnalyzer *slopeAnalyzer;
    
    CCLabelTTF *label;
    
    DetailController *detailController;
    CCUIViewWrapper *viewWrapper;
    
    
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

//Translate coordinates from the slope world to the screen world.
-(CGPoint) translatePointWithX:(float) x andY:(float) y;
-(CGPoint) translatePoint:(CGPoint)p;

//Reverts a point in the view coordinate system to the real world
-(CGPoint) revertPointInView:(CGPoint)p;

//Find the Factor of safety with current state vars
-(void) findFS;

@end