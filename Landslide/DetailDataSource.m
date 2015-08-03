//
//  DetailDataSource.m
//  FieldNotesTT
//
//  Created by Oliver Rickard on 8/6/11.
//  Copyright 2011 UC Berkeley. All rights reserved.
//

#import "DetailDataSource.h"
#import <IBAForms/IBAForms.h>

@implementation DetailDataSource

- (id)initWithModel:(id)aModel {
	if (self = [super initWithModel:aModel]) {
		// Some basic form fields that accept text input
		IBAFormSection *basicFieldSection = [self addSectionWithHeaderTitle:@"Layer Details" footerTitle:nil];
        
        IBAFormFieldStyle *style = [[[IBAFormFieldStyle alloc] init] autorelease];
		style.labelTextColor = [UIColor blackColor];
		style.labelFont = [UIFont systemFontOfSize:14];
		style.labelTextAlignment = UITextAlignmentLeft;
		style.valueTextAlignment = UITextAlignmentRight;
		style.valueTextColor = [UIColor darkGrayColor];
		style.activeColor = [UIColor colorWithRed:174/255.0f green:203/255.0f blue:247/255.0f alpha:1.0];
        
		basicFieldSection.formFieldStyle = style;
        
        IBATextFormField *serverField = [[IBATextFormField alloc] initWithKeyPath:@"server" title:@"Server"];
        
		[basicFieldSection addFormField:[serverField autorelease]];
        
        serverField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeURL;
        serverField.textFormFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        serverField.textFormFieldCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        IBATextFormField *folderField = [[IBATextFormField alloc] initWithKeyPath:@"folder" title:@"Folder"];
        
		[basicFieldSection addFormField:[folderField autorelease]];
        
        folderField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeURL;
        folderField.textFormFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        folderField.textFormFieldCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        IBATextFormField *usernameField = [[IBATextFormField alloc] initWithKeyPath:@"username" title:@"Username"];
        
        [basicFieldSection addFormField:[usernameField autorelease]];
        
        usernameField.textFormFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        usernameField.textFormFieldCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
		[basicFieldSection addFormField:[[[IBAPasswordFormField alloc] initWithKeyPath:@"password" title:@"Password"] autorelease]];
        
		[basicFieldSection addFormField:[[[IBABooleanFormField alloc] initWithKeyPath:@"remember" title:@"Remember?"] autorelease]];
    }
    
    return self;
}

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
	[super setModelValue:value forKeyPath:keyPath];
	
	NSLog(@"%@", [self.model description]);
}

@end
