//
//  AppDelegate.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/24/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //  initialize your application
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    CGFloat titleOffset = mainWindow.frame.size.height - mainWindow.contentView.frame.size.height;
    [Global setTitleOffset:titleOffset];
}

// we want the application to shut down once the window is closed
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return true;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



@end
