//
//  MKInfoPanel.m
//  HorizontalMenu
//
//  Created by Mugunth on 25/04/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8e on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKInfoPanel.h"
#import <QuartzCore/QuartzCore.h>

// Private Methods

@interface MKInfoPanel ()

@property (nonatomic, assign) MKInfoPanelType type;

+ (MKInfoPanel*) infoPanel;

- (void)setup;

@end


@implementation MKInfoPanel

@synthesize titleLabel = _titleLabel;
@synthesize detailLabel = _detailLabel;
@synthesize thumbImage = _thumbImage;
@synthesize backgroundGradient = _backgroundGradient;
@synthesize onTouched = _onTouched;
@synthesize delegate = _delegate;
@synthesize onFinished = _onFinished;
@synthesize type = type_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    if([_delegate respondsToSelector:_onFinished]) {
        [_delegate performSelector:_onFinished];
    }
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

-(void)setType:(MKInfoPanelType)type {
    if(type == MKInfoPanelTypeError) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Red"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.detailLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        self.thumbImage.image = [UIImage imageNamed:@"Warning"];
        self.detailLabel.textColor = [UIColor colorWithRed:1.f green:0.651f blue:0.651f alpha:1.f];
    }
    
    else if(type == MKInfoPanelTypeInfo) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Blue"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.thumbImage.image = [UIImage imageNamed:@"Tick"];   
        self.detailLabel.textColor = RGBA(210, 210, 235, 1.0);
    }
    
    else if(type == MKInfoPanelTypeMap) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Green"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.thumbImage.image = [UIImage imageNamed:@"MapIcon"];   
        self.detailLabel.textColor = RGBA(210, 210, 235, 1.0);
    }
    
    else if(type == MKInfoPanelTypeOpenMaps) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Gray"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.thumbImage.image = [UIImage imageNamed:@"MapIconBlack"];   
        self.detailLabel.textColor = [UIColor lightTextColor];
    }
    
    else if(type == MKInfoPanelTypeRecording) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Red"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.detailLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        self.thumbImage.image = [UIImage imageNamed:@"recordingMic"];
        self.detailLabel.textColor = [UIColor colorWithRed:1.f green:0.651f blue:0.651f alpha:1.f];
    }
    
    else if(type == MKInfoPanelTypeErrorDropBox) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Blue"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.thumbImage.image = [UIImage imageNamed:@"dberrorlogo"];   
        self.detailLabel.textColor = RGBA(210, 210, 235, 1.0);
    }
    
    else if(type == MKInfoPanelTypeErrorDropBox) {
        self.backgroundGradient.image = [[UIImage imageNamed:@"Gray"] stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.titleLabel.textColor = [UIColor blackColor];
        self.thumbImage.image = [UIImage imageNamed:@"info"];   
        self.detailLabel.textColor = [UIColor whiteColor];
        self.detailLabel.font = [UIFont systemFontOfSize:10];
    }
    
    type_ = type;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Show/Hide
////////////////////////////////////////////////////////////////////////

+ (MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInView:view type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {    
    MKInfoPanel *panel = [MKInfoPanel infoPanel];
    CGFloat panelHeight = 50;   // panel height when no subtitle set
    
    panel.type = type;
    panel.titleLabel.text = title;
    
    if(subtitle) {
        panel.detailLabel.text = subtitle;
        [panel.detailLabel sizeToFit];
        CGRect frame = panel.detailLabel.frame;
        frame.size.width = view.frame.size.width - 114;
        panel.detailLabel.frame = frame;
        
        panelHeight = MAX(CGRectGetMaxY(panel.thumbImage.frame), CGRectGetMaxY(panel.detailLabel.frame));
        panelHeight += 10.f;    // padding at bottom
    } else {
        panel.detailLabel.hidden = YES;
        panel.thumbImage.frame = CGRectMake(15, 5, 35, 35);
        panel.titleLabel.frame = CGRectMake(57, 12, 240, 21);
    }
    
    if(panel.type == MKInfoPanelTypeOpenMaps) {
        
        UIButton *openMapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openMapsButton setImage:[UIImage imageNamed:@"yesButton"] forState:UIControlStateNormal];
        [openMapsButton addTarget:panel action:@selector(openMaps) forControlEvents:UIControlEventTouchUpInside];
        openMapsButton.frame = CGRectMake(57, panelHeight, 70, 18);
        [panel addSubview:openMapsButton];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"noButton"] forState:UIControlStateNormal];
        [cancelButton addTarget:panel action:@selector(cancelOpenMaps) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.frame = CGRectMake(view.frame.size.width - 57 - 100, panelHeight, 70, 18);
        [panel addSubview:cancelButton];
        
        panelHeight += 25.0f;//Give myself extra space to put buttons
        
    } else if (panel.type == MKInfoPanelTypeErrorDropBox) {
        UIButton *openMapsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openMapsButton setImage:[UIImage imageNamed:@"okButton"] forState:UIControlStateNormal];
        [openMapsButton addTarget:panel action:@selector(dropBoxOK) forControlEvents:UIControlEventTouchUpInside];
        openMapsButton.frame = CGRectMake(view.frame.size.width*0.5f - 35, panelHeight, 70, 18);
        [panel addSubview:openMapsButton];
        
        panelHeight+= 25.0f;
    } else if (panel.type == MKInfoPanelTypeHelp) {
        UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [okButton setImage:[UIImage imageNamed:@"okButton"] forState:UIControlStateNormal];
        [okButton addTarget:panel action:@selector(FTPOK) forControlEvents:UIControlEventTouchUpInside];
        okButton.frame = CGRectMake(view.frame.size.width*0.5f - 35, panelHeight, 70, 18);
        [panel addSubview:okButton];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, panelHeight)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.alpha = 0.5f;
        [panel insertSubview:backgroundView atIndex:0];
        [backgroundView release];
    }
    
    // update frame of panel
    panel.frame = CGRectMake(0, 0, view.bounds.size.width, panelHeight);
    [view addSubview:panel];
    
    if (interval > 0 && panel.type != MKInfoPanelTypeOpenMaps) {
        [panel performSelector:@selector(hidePanel) withObject:view afterDelay:interval]; 
    }
    
    return panel;
}

+ (MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {
    MKInfoPanel *panel = [self showPanelInView:window type:type title:title subtitle:subtitle hideAfter:interval];
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect frame = panel.frame;
        frame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
        panel.frame = frame;
    }
    
    return panel;
}

-(void)hidePanel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromTop;
	[self.layer addAnimation:transition forKey:nil];
    self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height); 
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
}

-(void)dropBoxOK {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(dropBoxOK)]) {
            [self.delegate dropBoxOK];
        }
    }
}

-(void)FTPOK {
    [self hidePanel];
}

-(void)openMaps {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(openMaps)]) {
            [self.delegate openMaps];
        }
    }
}


-(void)cancelOpenMaps {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(cancelOpenMaps)]) {
            [self.delegate cancelOpenMaps];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Touch Recognition
////////////////////////////////////////////////////////////////////////

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:_onTouched];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

+(MKInfoPanel *)infoPanel {
    MKInfoPanel *panel =  (MKInfoPanel*) [[[UINib nibWithNibName:@"MKInfoPanel" bundle:nil] 
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromBottom;
	[panel.layer addAnimation:transition forKey:nil];
    
    return panel;
}

- (void)setup {
    self.onTouched = @selector(hidePanel);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

@end
