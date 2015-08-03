//
//  HelloWorldLayer.m
//  Landslide
//
//  Created by Oliver Rickard on 11/23/11.
//  Copyright UC Berkeley 2011. All rights reserved.
//


// Import the interfaces
#import "SlopeViewLayer.h"
#import "MDAboutController.h"
#import "DetailController.h"
#import "CCUIViewWrapper.h"


void ccDrawPolyFilled( const CGPoint *poli, NSUInteger numberOfPoints, BOOL closePolygon)
{
	ccVertex2F newPoint[numberOfPoints];
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
	
	// iPhone and 32-bit machines
	if( sizeof(CGPoint) == sizeof(ccVertex2F) ) {
        
		// convert to pixels ?
		if( CC_CONTENT_SCALE_FACTOR() != 1 ) {
			memcpy( newPoint, poli, numberOfPoints * sizeof(ccVertex2F) );
			for( NSUInteger i=0; i<numberOfPoints;i++)
				newPoint[i] = (ccVertex2F) { poli[i].x * CC_CONTENT_SCALE_FACTOR(), poli[i].y * CC_CONTENT_SCALE_FACTOR() };
            
			glVertexPointer(2, GL_FLOAT, 0, newPoint);
            
		} else
			glVertexPointer(2, GL_FLOAT, 0, poli);
        
		
	} else {
		// 64-bit machines (Mac)
		
		for( NSUInteger i=0; i<numberOfPoints;i++)
			newPoint[i] = (ccVertex2F) { poli[i].x, poli[i].y };
        
		glVertexPointer(2, GL_FLOAT, 0, newPoint );
        
	}
    
	if( closePolygon )
		glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei) numberOfPoints);
	else
		glDrawArrays(GL_TRIANGLE_FAN, 0, (GLsizei) numberOfPoints);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
}

void ccDrawSmoothLine(CGPoint pos1, CGPoint pos2, float width)
{
    GLfloat lineVertices[12], curc[4];
    GLint   ir, ig, ib, ia;
    CGPoint dir, tan;
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
	//glEnable(GL_LINE_SMOOTH);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	pos1.x *= CC_CONTENT_SCALE_FACTOR();
	pos1.y *= CC_CONTENT_SCALE_FACTOR();
	pos2.x *= CC_CONTENT_SCALE_FACTOR();
	pos2.y *= CC_CONTENT_SCALE_FACTOR();
	width *= CC_CONTENT_SCALE_FACTOR();
    
    width = width*8;
    dir.x = pos2.x - pos1.x;
    dir.y = pos2.y - pos1.y;
    float len = sqrtf(dir.x*dir.x+dir.y*dir.y);
    if(len<0.00001)
        return;
    dir.x = dir.x/len;
    dir.y = dir.y/len;
    tan.x = -width*dir.y;
    tan.y = width*dir.x;
    
    lineVertices[0] = pos1.x + tan.x;
    lineVertices[1] = pos1.y + tan.y;
    lineVertices[2] = pos2.x + tan.x;
    lineVertices[3] = pos2.y + tan.y;
    lineVertices[4] = pos1.x;
    lineVertices[5] = pos1.y;
    lineVertices[6] = pos2.x;
    lineVertices[7] = pos2.y;
    lineVertices[8] = pos1.x - tan.x;
    lineVertices[9] = pos1.y - tan.y;
    lineVertices[10] = pos2.x - tan.x;
    lineVertices[11] = pos2.y - tan.y;
    
    glGetFloatv(GL_CURRENT_COLOR,curc);
    ir = 255.0*curc[0];
    ig = 255.0*curc[1];
    ib = 255.0*curc[2];
    ia = 255.0*curc[3];
    
    const GLubyte lineColors[] = {
        ir, ig, ib, 0,
        ir, ig, ib, 0,
        ir, ig, ib, ia,
        ir, ig, ib, ia,
        ir, ig, ib, 0,
        ir, ig, ib, 0,
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, lineVertices);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, lineColors);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 6);
    glDisableClientState(GL_COLOR_ARRAY);
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
	float			temp1,
    temp2;
	float			temp[3];
	int				i;
    
	// Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
	if(s == 0.0) {
		if(outR)
			*outR = l;
		if(outG)
			*outG = l;
		if(outB)
			*outB = l;
		return;
	}
    
	// Test for luminance and compute temporary values based on luminance and saturation 
	if(l < 0.5)
		temp2 = l * (1.0 + s);
	else
		temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
    
	// Compute intermediate values based on hue
	temp[0] = h + 1.0 / 3.0;
	temp[1] = h;
	temp[2] = h - 1.0 / 3.0;
    
	for(i = 0; i < 3; ++i) {
        
		// Adjust the range
		if(temp[i] < 0.0)
			temp[i] += 1.0;
		if(temp[i] > 1.0)
			temp[i] -= 1.0;
        
        
		if(6.0 * temp[i] < 1.0)
			temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
		else {
			if(2.0 * temp[i] < 1.0)
				temp[i] = temp2;
			else {
				if(3.0 * temp[i] < 2.0)
					temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
				else
					temp[i] = temp1;
			}
		}
	}
    
	// Assign temporary values to R, G, B
	if(outR)
		*outR = temp[0];
	if(outG)
		*outG = temp[1];
	if(outB)
		*outB = temp[2];
}

// HelloWorldLayer implementation
@implementation SlopeViewLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SlopeViewLayer *layer = [SlopeViewLayer node];
    layer.isTouchEnabled = YES;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255,255,255,255)])) {
        
        H = 100;
        Ls = 100;
        
        L = 5*H;
        
        center = ccp(5*H/2, 100);
        R = 300;
        
        topLayerController = [[UIViewController alloc] init];
        
        [[[CCDirector sharedDirector] openGLView] addSubview:topLayerController.view];
        

		// create and initialize a Label
		label = [CCLabelTTF labelWithString:@"FS:--" fontName:@"Arial" fontSize:30];

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width-200 , size.height-50);
        label.color = ccc3(0, 0, 0);
        
		
		// add the label as a child to this Layer
		[self addChild: label];
        
        CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"Icon@2x.png" selectedImage:@"Icon@2x.png" target:self selector:@selector(tappedLogo)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( size.width*.1,size.height - 45);
        item1.scale = size.width/1024;
		[self addChild: menu z:1];
        
        
        thicknesses = [[NSArray alloc] initWithObjects:
                       [NSNumber numberWithFloat:10],
                       [NSNumber numberWithFloat:20],
                       [NSNumber numberWithFloat:5], 
                       [NSNumber numberWithFloat:20], 
                       [NSNumber numberWithFloat:5], 
                       [NSNumber numberWithFloat:5], 
                       [NSNumber numberWithFloat:5], 
                       [NSNumber numberWithFloat:500], nil];
        
        gamma = [[NSArray alloc] initWithObjects:
                 [NSNumber numberWithFloat:110], 
                 [NSNumber numberWithFloat:95],
                 [NSNumber numberWithFloat:100],
                 [NSNumber numberWithFloat:100],
                 [NSNumber numberWithFloat:100],
                 [NSNumber numberWithFloat:100],
                 [NSNumber numberWithFloat:100],
                 [NSNumber numberWithFloat:100], nil];
        
        cohesion = [[NSArray alloc] initWithObjects:
                    [NSNumber numberWithFloat:0], 
                    [NSNumber numberWithFloat:45],
                    [NSNumber numberWithFloat:0], 
                    [NSNumber numberWithFloat:0], 
                    [NSNumber numberWithFloat:0], 
                    [NSNumber numberWithFloat:0], 
                    [NSNumber numberWithFloat:0], 
                    [NSNumber numberWithFloat:0], nil];
        
        phi = [[NSArray alloc] initWithObjects:
               [NSNumber numberWithFloat:(9*3.1415/180)], 
               [NSNumber numberWithFloat:(30*3.1415/180)],
               [NSNumber numberWithFloat:(30*3.1415/180)],
               [NSNumber numberWithFloat:(30*3.1415/180)],
               [NSNumber numberWithFloat:(30*3.1415/180)],
               [NSNumber numberWithFloat:(30*3.1415/180)],
               [NSNumber numberWithFloat:(30*3.1415/180)],
               [NSNumber numberWithFloat:(30*3.1415/180)], nil];
        
        NSMutableArray *potentialColors = [[NSMutableArray alloc] init];
        
        [potentialColors addObject:[UIColor colorWithRed:30/255.0f green:144/255.0f blue:255/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:99/255.0f green:184/255.0f blue:255/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:108/255.0f green:166/255.0f blue:205/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:0/255.0f green:229/255.0f blue:238/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:0/255.0f green:206/255.0f blue:209/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:0/255.0f green:199/255.0f blue:140/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:69/255.0f green:139/255.0f blue:116/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:60/255.0f green:179/255.0f blue:113/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:238/255.0f green:220/255.0f blue:130/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:255/255.0f green:193/255.0f blue:37/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:238/255.0f green:154/255.0f blue:0/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:238/255.0f green:118/255.0f blue:0/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:238/255.0f green:64/255.0f blue:0/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:255/255.0f green:99/255.0f blue:71/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:205/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f]];
        [potentialColors addObject:[UIColor colorWithRed:205/255.0f green:0 blue:0 alpha:1.0f]];
        
        colors = [[NSMutableArray alloc] init];
        for(int i = 0; i < thicknesses.count; i++) {
//            CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
//            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
//            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
//            CGFloat r;
//            CGFloat g;
//            CGFloat b;
//            HSL2RGB(hue, saturation, brightness, &r, &g, &b);
//            [colors addObject:[UIColor colorWithRed:r green:g blue:b alpha:1.0f]];
            [colors addObject:((UIColor *)[potentialColors objectAtIndex:(i%potentialColors.count)])];
//            NSLog(@"colorNum:%d", (i%potentialColors.count));
        }
        
        [potentialColors release];
        

        
	}
	return self;
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertToNodeSpace:[touch locationInView: [touch view]]];
    center = [self revertPointInView:location];
    R = 0;
//    NSLog(@"touchesBegan");
    return YES;
}
-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertToNodeSpace:[touch locationInView: [touch view]]];
    CGPoint realLoc = [self revertPointInView:location];
    float distance = sqrtf( (center.x - realLoc.x)*(center.x - realLoc.x) + (center.y - realLoc.y)*(center.y - realLoc.y));
    R = 2*distance;
    [self draw];
    
//    NSLog(@"touchesMoved");
}
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertToNodeSpace:[touch locationInView: [touch view]]];
    CGPoint realLoc = [self revertPointInView:location];
    float distance = sqrtf( (center.x - realLoc.x)*(center.x - realLoc.x) + (center.y - realLoc.y)*(center.y - realLoc.y));
    R = 2*distance;
    [self draw];
    [self findFS];
}



//Draw the landslide mass and stratigraphy
-(void) draw
{
    
    
    CGPoint p1 = ccp(0, 0); //bottom left of quad
    CGPoint p2 = ccp([[CCDirector sharedDirector] winSize].width, 0); //bottom right
    CGPoint p3= ccp([[CCDirector sharedDirector] winSize].width, [[CCDirector sharedDirector] winSize].height);//upper right
    CGPoint p4 = ccp(0, [[CCDirector sharedDirector] winSize].height); //bottom left of quad
    CGPoint vertices[] = { p1,p2,p3,p4 };
    glColor4ub(255, 255, 255, 255);
    
    ccDrawPolyFilled(vertices, 4, YES);
    
        
    float top = H;
    int i = 0;
    for(NSNumber *n in thicknesses) {
        float thickness = [n floatValue];
//        glColor4ub(255, 0, 255, 255);
        float bottom = top - thickness;
        float slopeBase = 0;
        if(bottom>=slopeBase) {
        
            CGPoint p1 = ccp(0, top); //Upper left of quad
            CGPoint p2 = ccp(Ls/H*(H*(5*H+Ls)/(2*Ls) - top), top); //Upper right
            CGPoint p3= ccp(Ls/H*(H*(5*H+Ls)/(2*Ls) - bottom), bottom);//Lower right
            CGPoint p4 = ccp(0, bottom); //bottom left of quad
            CGPoint vertices[] = { [self translatePoint:p1],[self translatePoint:p2],[self translatePoint:p3],[self translatePoint:p4] };
            
            //Get color for layer
            UIColor *c = [colors objectAtIndex:i];
            CGColorRef color = [c CGColor];
            const CGFloat *components = CGColorGetComponents(color);
            glColor4ub(components[0]*255, components[1]*255, components[2]*255, components[3]*255);
            
            ccDrawPolyFilled(vertices, 4, YES);
            
        } else if(bottom < slopeBase && top > slopeBase) {
            //Get color for this layer
            UIColor *c = [colors objectAtIndex:i];
            CGColorRef color = [c CGColor];
            const CGFloat *components = CGColorGetComponents(color);
            glColor4ub(components[0]*255, components[1]*255, components[2]*255, components[3]*255);
            
            
            CGPoint p1 = ccp(0, top); //Upper left of quad
            CGPoint p2 = ccp(Ls/H*(H*(5*H+Ls)/(2*Ls) - top), top); //Upper right
            CGPoint p3 = ccp(((5*H+Ls)/2),0);
            CGPoint p4 = ccp(0,0);
            CGPoint vertices[] = { [self translatePoint:p1],[self translatePoint:p2],[self translatePoint:p3],[self translatePoint:p4] };
            ccDrawPolyFilled(vertices, 4, YES);
            
            p1 = ccp(0,0);
            p2 = ccp(L,0);
            p3 = ccp(L, bottom);
            p4 = ccp(0,bottom);
            CGPoint vertices2[] = { [self translatePoint:p1],[self translatePoint:p2],[self translatePoint:p3],[self translatePoint:p4] };
            ccDrawPolyFilled(vertices2, 4, YES);
            
        } else {
            CGPoint p1 = ccp(0, top); //Upper left of quad
            CGPoint p2 = ccp(L, top); //Upper right
            CGPoint p3= ccp(L, bottom);//Lower right
            CGPoint p4 = ccp(0, bottom); //bottom left of quad
            CGPoint vertices[] = { [self translatePoint:p1],[self translatePoint:p2],[self translatePoint:p3],[self translatePoint:p4] };
            
            UIColor *c = [colors objectAtIndex:i];
            CGColorRef color = [c CGColor];
            const CGFloat *components = CGColorGetComponents(color);
            glColor4ub(components[0]*255, components[1]*255, components[2]*255, components[3]*255);
            
            ccDrawPolyFilled(vertices, 4, YES);
        }
        
        
        top = bottom;
        i++;
    }
    
    //Draw the circle
    // draw a green circle with 10 segments
	glLineWidth(5);
	glColor4ub(235, 0, 0, 255);
    
	ccDrawCircle([self translatePoint:center], R, 0, [self translatePointWithX:R andY:0].x, NO);
    
    //Cover up top of circle
    p1 = [self translatePoint:ccp(0,H)];
    p2 = [self translatePoint:ccp(L,H)];
    p3= ccp([[CCDirector sharedDirector] winSize].width, [[CCDirector sharedDirector] winSize].height);
    p4 = ccp(0, [[CCDirector sharedDirector] winSize].height);
    CGPoint vertices3[] = { p1,p2,p3,p4 };
    glColor4ub(248, 248, 255, 255);
    
    ccDrawPolyFilled(vertices3, 4, YES);
    
    //Cover up top of circle
    p1 = [self translatePoint:ccp(((5*H-Ls)/2),H)];
    p2 = [self translatePoint:ccp(((5*H+Ls)/2),0)]; 
    p3= ccp([[CCDirector sharedDirector] winSize].width, p2.y);
    p4 = ccp([[CCDirector sharedDirector] winSize].width, p1.y);
    CGPoint vertices4[] = { p1,p2,p3,p4 };
    glColor4ub(248, 248, 255, 255);
    
    ccDrawPolyFilled(vertices4, 4, YES);
    
    
    // draw point in the center
	glPointSize(8);
	glColor4ub(245,0,0,128);
	ccDrawPoint( [self translatePoint:center] );

    
    glLineWidth(3);
    glColor4ub(0, 0, 0, 255);
    glEnable(GL_LINE_SMOOTH);
    
    //Draw the first line from the left to X1
    ccDrawSmoothLine([self translatePoint:ccp(0,H)], [self translatePoint:ccp(((5*H-Ls)/2),H)], .2);
    
    //Draw slope line
    ccDrawSmoothLine([self translatePoint:ccp(((5*H-Ls)/2),H)], [self translatePoint:ccp(((5*H+Ls)/2),0)], .2);
    
    //Draw the tail
    ccDrawSmoothLine([self translatePoint:ccp(((5*H+Ls)/2),0)], [self translatePoint:ccp(L,0)], .2);
    
    glDisable(GL_LINE_SMOOTH);
    glLineWidth(1);
    
    
}

//Call our SlopeAnalyzer to process the F.S.
-(void) findFS {
    if(!slopeAnalyzer) {
        slopeAnalyzer = [[SlopeAnalyzer alloc] init];
    }
    
    float FS = [slopeAnalyzer computeFSWithCenter:center radius:R slopeLength:Ls slopeHeight:H thicknessArray:thicknesses gammaArray:gamma cohesionArray:cohesion phiArray:phi];
    
    if(FS >=0) {
        [label setString:[NSString stringWithFormat:@"FS:%f",((int)(FS*100))/100.0f]];
    } else {
        [label setString:@"Stable"];
    }
}

-(void) tappedLogo
{
    CGSize s = [[CCDirector sharedDirector] winSize];
    CGSize sPixels = [[CCDirector sharedDirector] winSizeInPixels];
    
    detailController = [[DetailController alloc] init];
    detailController.delegate = self;
    detailController.view.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    detailController.view.frame = CGRectMake(64, 64, sPixels.width - 64*2, sPixels.height - 64*2);
    
    
    UINavigationController *formNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailController] autorelease];
    
//    formNavigationController.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    formNavigationController.navigationBar.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    
    
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                   target:detailController 
                                                                                   action:@selector(dismissForm)] autorelease];
    detailController.navigationItem.leftBarButtonItem = cancelButton;
    
    
    
    
    // create a toolbar where we can place some buttons
    UIToolbar* toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    
    // create an array for the buttons
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // create a standard save button
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStylePlain target:detailController action:@selector(showHelp)];
    button1.style = UIBarButtonItemStyleBordered;
    [buttons addObject:button1];
    [button1 release];
    
    // create a spacer between the buttons
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                             target:detailController 
                                                                             action:@selector(login)];
    button2.style = UIBarButtonItemStyleBordered;
    [buttons addObject:button2];
    [button2 release];
    
    // put the buttons in the toolbar and release them
    [toolbar setItems:buttons animated:NO];
    [buttons release];
    
    // place the toolbar into the navigation bar
    detailController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                           initWithCustomView:toolbar] autorelease];
    [toolbar release];
    
    
    
    if(!viewWrapper) {
        [self removeChild:viewWrapper cleanup:YES];
        viewWrapper = nil;
    }
    viewWrapper = [CCUIViewWrapper wrapperForUIView:formNavigationController.view];
    
    viewWrapper.contentSize = CGSizeMake(500, 500);
    viewWrapper.position = ccp(s.width/2 - 500/2, s.height/2 + 500/2);
//    [viewWrapper setRotation:];
    [self addChild:viewWrapper];
    
    
    // If the view controller doesn't already exist, create it
//    MDAboutController *aboutController = [[MDAboutController alloc] init];
}

-(void) removeWrapper {
    if(viewWrapper) {
        [self removeChild:viewWrapper cleanup:YES];
        viewWrapper = nil;
    }
    if(detailController) {
        [detailController release];
        detailController = nil;
    }
}

- (UIImage*) screenShotUIImage {
	CGSize size = [[CCDirector sharedDirector] winSize];
	//Create un buffer for pixels
	GLuint bufferLenght=size.width*size.height*4;
	GLubyte *buffer = (GLubyte *) malloc(bufferLenght);
    
	//Read Pixels from OpenGL
	glReadPixels(0,0,size.width,size.height,GL_RGBA,GL_UNSIGNED_BYTE,buffer);
	//Make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLenght, NULL);
    
	//Configure image
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * size.width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	CGImageRef iref = CGImageCreate(size.width,size.height,bitsPerComponent,bitsPerPixel,bytesPerRow,colorSpaceRef,bitmapInfo,provider,NULL,NO,renderingIntent);
    
	uint32_t *pixels = (uint32_t *)malloc(bufferLenght);
	CGContextRef context = CGBitmapContextCreate(pixels, size.width, size.height, 8, size.width*4, CGImageGetColorSpace(iref), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
	CGContextTranslateCTM(context,0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
	switch ([[CCDirector sharedDirector] deviceOrientation]) {
		case CCDeviceOrientationPortrait:
			break;
		case CCDeviceOrientationPortraitUpsideDown:
			CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(180));
			CGContextTranslateCTM(context,-size.width, -size.height);
			break;
		case CCDeviceOrientationLandscapeLeft:
			CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(-90));
			CGContextTranslateCTM(context,-size.height, 0);
			break;
		case CCDeviceOrientationLandscapeRight:
			CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(90));
			CGContextTranslateCTM(context,size.width*0.5, -size.height);
			break;
	}
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), iref);
	UIImage *outputImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    
	//Dealloc
	CGDataProviderRelease(provider);
	CGImageRelease(iref);
	CGContextRelease(context);
	free(buffer);
	free(pixels);
    
	return outputImage;
}

-(CGPoint) translatePoint:(CGPoint)p {
    return [self translatePointWithX:p.x andY:p.y];
}
                   
//Translate Coordinates
-(CGPoint) translatePointWithX:(float) x andY:(float) y
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float scaleFactorX = winSize.width/(5*H);
//    float scaleFactorY = winSize.height/(3*H);
    float scaleFactorY = scaleFactorX;
    
    float x1 = x * scaleFactorX;
    float y1 = y * scaleFactorY + 1.5*H*scaleFactorY;;
    
//    NSLog(@"translatePoint:(%f,%f) toPoint:(%f,%f)", x, y, x1, y1);
    
    return ccp(x1,y1);
}

-(CGPoint) revertPointInView:(CGPoint)p {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float scaleFactorX = winSize.width/(5*H);
    //    float scaleFactorY = winSize.height/(3*H);
    float scaleFactorY = scaleFactorX;
    
    float x1 = p.x / scaleFactorX;
    float y1 = -(p.y - 2.2*H*scaleFactorY)/scaleFactorX;
    
    //    NSLog(@"translatePoint:(%f,%f) toPoint:(%f,%f)", x, y, x1, y1);
    
    return ccp(x1,y1);
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    [topLayerController release];
    [thicknesses release];
    [colors release];
    if(slopeAnalyzer) {
        [slopeAnalyzer release];
    }
    
    if(viewWrapper) {
        // cleanup the viewWrapper
        [self removeChild:viewWrapper cleanup:true];
        viewWrapper = nil;
    }
    
    if(detailController) {
        [detailController release];
        detailController = nil;
    }
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
