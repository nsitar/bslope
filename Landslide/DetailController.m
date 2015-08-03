//
//  DetailController.m
//  FieldNotesTT
//
//  Created by Oliver Rickard on 8/6/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import "DetailController.h"
#import "DetailDataSource.h"
#import "MKInfoPanel.h"

@implementation DetailController


@synthesize shouldAutoRotate = shouldAutoRotate_;
@synthesize tableViewStyle = tableViewStyle_;
@synthesize filePath;
@synthesize delegate;
@synthesize panel;

+(DetailController *)showInViewController:(UIViewController *)viewController withFilePath:(NSString *)path {
    NSMutableDictionary *DetailModel = [[[NSMutableDictionary alloc] init] autorelease];
    
	// Values set on the model will be reflected in the form fields.
//	[DetailModel setObject:@"A value contained in the model" forKey:@"readOnlyText"];
    
    
    
	DetailDataSource *dataSource = [[[DetailDataSource alloc] initWithModel:DetailModel] autorelease];
	DetailController *detailController = [[[DetailController alloc] initWithNibName:nil bundle:nil formDataSource:dataSource] autorelease];
    detailController.filePath = path;
	detailController.title = @"FTP Server Details";
	detailController.shouldAutoRotate = YES;
	detailController.tableViewStyle = UITableViewStyleGrouped;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LandslideDetailRemember"]) {
        if([DetailController getServer]) {
            [DetailModel setObject:[DetailController getServer] forKey:@"server"];
        }
        if([DetailController getFolder]) {
            [DetailModel setObject:[DetailController getFolder] forKey:@"folder"];
        }
        if([DetailController retrieveUsername]) {
            [DetailModel setObject:[DetailController retrieveUsername] forKey:@"username"];
        }
        if([DetailController retrievePassword]) {
            [DetailModel setObject:[DetailController retrievePassword] forKey:@"password"];
        }
        if([NSString stringWithFormat:@"%d",[DetailController getRemember]]) {
            [DetailModel setObject:[NSString stringWithFormat:@"%d",[DetailController getRemember]] forKey:@"remember"];
        }
     }
         
    
    
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                 target:detailController 
                                                                                 action:@selector(dismissForm)] autorelease];
    detailController.navigationItem.leftBarButtonItem = cancelButton;
    
    
    
    
    // create a toolbar where we can place some buttons
    UIToolbar* toolbar = [[UIToolbar alloc]
                          initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    //        [toolbar insertSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barbg.png"]] autorelease] atIndex:0];
//    toolbar.tintColor = RGBCOLOR(59, 74, 101); 
    toolbar.tintColor = [UIColor colorWithRed:59/255.0 green:74/255.0 blue:101/255.0 alpha:1.0];
    
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
    toolbar.backgroundColor = [UIColor clearColor];
    
    // place the toolbar into the navigation bar
    detailController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithCustomView:toolbar] autorelease];
    [toolbar release];
    
    
    
    
    
    
    UINavigationController *formNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailController] autorelease];
    
    formNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if([formNavigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [formNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"barbg.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    
    
    [viewController presentModalViewController:formNavigationController animated:YES];
    [viewController presentViewController:detailController animated:YES completion:nil];
    
    return detailController;
}

-(id)init {
    if(self = [super init]) {
        NSMutableDictionary *DetailModel = [[[NSMutableDictionary alloc] init] autorelease];
        
        // Values set on the model will be reflected in the form fields.
        //	[DetailModel setObject:@"A value contained in the model" forKey:@"readOnlyText"];
        
        
        
        DetailDataSource *dataSource = [[[DetailDataSource alloc] initWithModel:DetailModel] autorelease];
        DetailController *detailController = [[[DetailController alloc] initWithNibName:nil bundle:nil formDataSource:dataSource] autorelease];
//        detailController.filePath = path;
        detailController.title = @"FTP Server Details";
        detailController.shouldAutoRotate = YES;
        detailController.tableViewStyle = UITableViewStylePlain;
        
//        if([[NSUserDefaults standardUserDefaults] boolForKey:@"LandslideDetailRemember"]) {
//            if([DetailController getServer]) {
//                [DetailModel setObject:[DetailController getServer] forKey:@"server"];
//            }
//            if([DetailController getFolder]) {
//                [DetailModel setObject:[DetailController getFolder] forKey:@"folder"];
//            }
//            if([DetailController retrieveUsername]) {
//                [DetailModel setObject:[DetailController retrieveUsername] forKey:@"username"];
//            }
//            if([DetailController retrievePassword]) {
//                [DetailModel setObject:[DetailController retrievePassword] forKey:@"password"];
//            }
//            if([NSString stringWithFormat:@"%d",[DetailController getRemember]]) {
//                [DetailModel setObject:[NSString stringWithFormat:@"%d",[DetailController getRemember]] forKey:@"remember"];
//            }
//        }
        
        
        
        
        
        
        
        
        

    }
    return self;
}

-(void)showHelp {
    if(self.panel) {
        [self.panel hidePanel];
        self.panel = nil;
    } else {
        
//        if(self.tableView.isEditing && self.tableView.indexPathForSelectedRow.row == 0) {
//            self.panel = [MKInfoPanel showPanelInView:self.view
//                                                 type:MKInfoPanelTypeInfo
//                                                title:@"Address to Server"
//                                             subtitle:@"No trailing slash. Example: ftp://mycompany.com"
//                                            hideAfter:0];
//        } else if(self.tableView.indexPathForSelectedRow.row == 1) {
//            self.panel = [MKInfoPanel showPanelInView:self.view
//                                                 type:MKInfoPanelTypeInfo
//                                                title:@"Folder"
//                                             subtitle:@"Relative path from server root.  Example: /docs/work/"
//                                            hideAfter:0];
//        } else if(self.tableView.indexPathForSelectedRow.row == 2) {
//            self.panel = [MKInfoPanel showPanelInView:self.view
//                                                 type:MKInfoPanelTypeInfo
//                                                title:@"Username"
//                                             subtitle:@"FTP access username."
//                                            hideAfter:0];
//        } else if(self.tableView.indexPathForSelectedRow.row == 3) {
//            self.panel = [MKInfoPanel showPanelInView:self.view
//                                                 type:MKInfoPanelTypeInfo
//                                                title:@"Password"
//                                             subtitle:@"FTP access password."
//                                            hideAfter:0];
//        } else if(self.tableView.indexPathForSelectedRow.row == 4) {
//            self.panel = [MKInfoPanel showPanelInView:self.view
//                                                 type:MKInfoPanelTypeInfo
//                                                title:@"Remember Login Details"
//                                             subtitle:@"Save all login details.  Encrypted and stored safely."
//                                            hideAfter:0];
//        } else {
//            self.panel = [MKInfoPanel showPanelInView:self.view
//                                                 type:MKInfoPanelTypeInfo
//                                                title:@"Enter Login Details"
//                                             subtitle:@"Enter details, and press Done to begin uploading."
//                                            hideAfter:0];
//        }
//        self.panel.delegate = self;
    }
}

- (void)loadView {
	[super loadView];
    
//    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"DetailData" accessGroup:nil];
    
    
	UIView *view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	[view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	UITableView *formTableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:self.tableViewStyle] autorelease];
	[formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self setTableView:formTableView];
	
	[view addSubview:formTableView];
	[self setView:view];
}

+ (void) savePassword: (NSString*) password {
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"DetailData" accessGroup:nil];
//    [keychain setObject:password  forKey:(id)kSecValueData];
}

+ (NSString *) retrievePassword {
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"DetailData" accessGroup:nil];
//    return (NSString *)[keychain objectForKey:(id)kSecValueData];
}

+(void)saveUsername:(NSString *)username {
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"DetailData" accessGroup:nil];
//    [keychain setObject:username forKey:(id)kSecAttrAccount];
}

+(NSString *)retrieveUsername {
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"DetailData" accessGroup:nil];
//    return (NSString *)[keychain objectForKey:(id)kSecAttrAccount];
}

+(void)saveServer:(NSString *)server {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:server forKey:@"FieldNotesFTPServer"];
}

+(NSString *)getServer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *server = [defaults objectForKey:@"FieldNotesFTPServer"];
    if(!server) {
        server = @"ftp://";
    }
    return server;
}

+(void)saveRemember:(BOOL)remember {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:remember forKey:@"FieldNotesFTPRemember"];
}

+(int)getRemember {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL remember = [defaults boolForKey:@"FieldNotesFTPRemember"];
    return remember;
}

+(void)saveFolder:(NSString *)folder {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:folder forKey:@"FieldNotesFTPFolder"];
}

+(NSString *)getFolder {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *folder = [defaults objectForKey:@"FieldNotesFTPFolder"];
    if(!folder) {
        folder = @"";
    }
    return folder;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return self.shouldAutoRotate;
}

- (void)dismissForm {
    
    if(delegate) {
        if([delegate respondsToSelector:@selector(removeWrapper)]) {
            [(UIViewController *)delegate removeWrapper];
        }
    }
}


-(void)dealloc {
//    if(keychain) {
//        [keychain release];
//        keychain = nil;
//    }
    if(HUD) {
        [HUD release];
        HUD = nil;
    }
    if(self.panel) {
        self.panel.delegate = nil;
        self.panel = nil;
    }
    self.filePath = nil;
    [super dealloc];
}

@end
