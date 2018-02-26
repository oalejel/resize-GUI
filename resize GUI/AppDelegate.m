//
//  AppDelegate.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/24/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    [mainWindow setStyleMask:[mainWindow styleMask] | NSWindowStyleMaskResizable];
    [mainWindow setTitle:@"EECS 280 Project 2 – Resize GUI"];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
