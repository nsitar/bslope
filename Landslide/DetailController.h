//
//  FTPLoginController.h
//  FieldNotesTT
//
//  Created by Oliver Rickard on 8/6/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import <IBAForms/IBAFormViewController.h>
//#import "KeychainItemWrapper.h"

@class MBProgressHUD;
@class MKInfoPanel;
@class S7FTPRequest;

@interface DetailController : IBAFormViewController {
    BOOL shouldAutoRotate_;
    UITableViewStyle tableViewStyle_;
    
//    KeychainItemWrapper *keychain;
    
    id<NSObject> delegate;
    
    MBProgressHUD *HUD;
    
    NSString *filePath;
    
    MKInfoPanel *panel;
    
    S7FTPRequest *ftp;
}

@property (nonatomic, assign) BOOL shouldAutoRotate;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, retain) NSString *filePath;
@property (nonatomic, assign) id<NSObject> delegate;
@property (nonatomic, retain) MKInfoPanel *panel;


+(DetailController *)showInViewController:(UIViewController *)viewController;

+(void) savePassword: (NSString*) password;
+(NSString *) retrievePassword;
+(void)saveUsername:(NSString *)username;
+(NSString *)retrieveUsername;
+(void)saveServer:(NSString *)server;
+(NSString *)getServer;
+(void)saveRemember:(BOOL)remember;
+(int)getRemember;
+(void)saveFolder:(NSString *)folder;
+(NSString *)getFolder;

@end
