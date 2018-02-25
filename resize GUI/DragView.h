//
//  DragView.h
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/24/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "ViewController.h"

@interface DragView : NSView

@property (weak) IBOutlet NSBox *dragBox;
@property (weak) IBOutlet NSTextField *infoField;

@property (weak) ViewController *parentController;

@property (nonatomic) NSString *execPath;
@property (nonatomic) NSString *imagePath;

@end
