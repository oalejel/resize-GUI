//
//  ViewController.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/24/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "ViewController.h"
#import <AppKit/AppKit.h>
#import "DragView.h"
#import "PPMImageView.h"
#import "Global.h"

@interface ViewController ()

@property (nonatomic) PPMImageView *ppmView;
@property (strong) NSArray *savedConstraints;

@end

@implementation ViewController
    
    /*
     plan:
     - DONE: run a successful resize on a ppm file
     - DONE: read filepath from drag and drop
     - DONE: add flexible window and learn to decide when the user is done resizing
     - DONE: perform a successful resize (with hardcoded width and height) given a drag and drop
     - DONE: make it work
     ...
     - DONE: ensure packaged application can handle filepaths and store its own temp files
     
     notes:
     - since the eecs 280 euchre executable does not support growing an image, it may be better to compute all shrinking on a "copy" image. We must keep a separate storage so that once euchre overwrites the image path it is given, we have a replacement image to work with
     
            -- btw, you can specify an outputfile in the euchre command line inputs
     */

- (void)viewDidLoad {
    [super viewDidLoad];
    [(DragView *)self.view setParentController:self];
    [self resetTitle];
    [self setStandardFrameSize];
}

// prepares application to draw the original image
- (void)setNewImage {
    NSError *err;
    NSString *imageDataString = [NSString stringWithContentsOfFile:self.imagePath encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        NSLog(@"%@", err);
    }
    [self parseImageDataString:imageDataString];
    
    //after parsing our original image, we set max width and height
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    [mainWindow setContentMaxSize:mainWindow.frame.size];
    [mainWindow setMaxSize:mainWindow.frame.size];
    
    //deactivate all constraints to allow image to be shrunk
    self.savedConstraints = self.view.constraints;
    for (NSLayoutConstraint *c in self.view.constraints) {
        [c setActive:false];
    }
}

//reads image data from .ppm file and stores it in a c-style UInt8 array
- (void)parseImageDataString:(NSString *)imageDataString {
    imageDataString = [imageDataString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    imageDataString = [imageDataString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    NSArray *imageDataArray = [imageDataString componentsSeparatedByString:@" "];
    int imageWidth = [(NSString *)imageDataArray[1] intValue];
    int imageHeight = [(NSString *)imageDataArray[2] intValue];
    
    //set window size (constraints only created when original image is drawn)
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    NSRect windowRect = [[[NSApplication sharedApplication] windows][0] frame];
    windowRect.size.width = imageWidth;
    windowRect.size.height = [Global getCorrectedHeight:imageHeight];
    [mainWindow setFrame:windowRect display:false animate:true];
    
    //set window title
    NSString *documentDirectory = [self.imagePath stringByDeletingLastPathComponent];
    NSString *documentName = [self.imagePath substringFromIndex:documentDirectory.length + 1];
    NSString *titleString = [NSString stringWithFormat:@"%d x %d — %@", imageWidth, imageHeight, documentName];
    [mainWindow setTitle:titleString];
    
    //to store our pixel data
    UInt8 table[[imageDataArray count] * 4];
    
    int offsetIndex = 4;
    for (int h = 0; h < imageHeight; h++) {
        for (int w = 0; w < imageWidth; w++) {
            //traverse through columns at every vertical level
            UInt8 r = [(NSString *)imageDataArray[offsetIndex + (h * imageWidth * 3) + (3 * w)] intValue];
            UInt8 g = [(NSString *)imageDataArray[offsetIndex + (h * imageWidth * 3) + (3 * w) + 1] intValue];
            UInt8 b = [(NSString *)imageDataArray[offsetIndex + (h * imageWidth * 3) + (3 * w) + 2] intValue];
            
            table[(h * imageWidth * 3) + (3 * w)] = r;
            table[(h * imageWidth * 3) + (3 * w) + 1] = g;
            table[(h * imageWidth * 3) + (3 * w) + 2] = b;
        }
    }
    
    if (self.ppmView) {
        [self.ppmView setDataArray:table];
        [self.ppmView setImgWidth:imageWidth];
        [self.ppmView setImgHeight:imageHeight];
        [self.ppmView setFrame:mainWindow.contentView.frame];
        [self.ppmView refreshImage];
    } else {
        self.ppmView = [[PPMImageView alloc] initWithFrame:mainWindow.contentView.frame imageArray:table];
        [self.ppmView setParentController:self];
        [self.view addSubview:self.ppmView];
    }

    [self.ppmView setWantsLayer:true];
    [self.ppmView setNeedsDisplay:true];
    [self.view setNeedsDisplay:true];
}

//called after a window resize is done to signal need for resize execution
- (void)loadResizedImageWithBlock:(void (^)(void))completionBlock {
    //lock window size
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    [mainWindow setStyleMask:[mainWindow styleMask] & ~NSWindowStyleMaskResizable];
    //execute resize, and perform completion
    [self executeResize];
    NSError *err;
    NSString *imageDataString = [NSString stringWithContentsOfFile:@"resized.ppm" encoding:NSUTF8StringEncoding error:&err];
    if (imageDataString && !err) {
        //parses image and writes to ppm view
        [self parseImageDataString:imageDataString];
    } else {
        NSLog(@"%@", err);
    }
    //allow window resizing
    [mainWindow setStyleMask:[mainWindow styleMask] | NSWindowStyleMaskResizable];
    //call completion block
    completionBlock();
}

//runs resize executable supplied by the user
- (NSString *)executeResize {
    NSString *widthArg = [NSString stringWithFormat:@"%d", (int)ceil([Global getDrawingSize].width)];
    NSString *heightArg = [NSString stringWithFormat:@"%d", (int)ceil([Global getDrawingSize].height)];
    
    NSArray *tempArgs = [NSArray arrayWithObjects: self.imagePath, @"resized.ppm", widthArg, heightArg, nil];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.executablePath];
    [task setArguments:tempArgs];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    [task setStandardError:errorPipe];
    
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *errData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    NSString *errOutputString = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", errOutputString);
    NSLog(@"%@", outputString);
    //if error is not an empty string
    if (![errOutputString isEqualToString:@""]) {
        return nil;
    }
    
    return outputString;
}

// removes current image and executable starting all states from new
- (void)newDocument:(void *)obj {
    //reactive all constraints to allow image to be shrunk
    [self.view addConstraints:self.savedConstraints];
    [self.view updateConstraints];
    
    //delete the old resized file
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:@"resized.ppm" error:&err];
    if (err) {NSLog(@"%@", err);}
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.ppmView];
    self.executablePath = nil;
    [self.ppmView removeFromSuperview];
    self.ppmView = nil;
    self.imagePath = nil;
    [self resetTitle];
    [(DragView *)self.view resetState];
    
    //allow window to size appropriately
    [self setStandardFrameSize];
    
    [self.view setNeedsDisplay:true];
    [self.view layoutSubtreeIfNeeded];
}

// sets frame size to 450 by 400
- (void)setStandardFrameSize {
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    NSRect standardRect = NSMakeRect(mainWindow.frame.origin.x, mainWindow.frame.origin.y, 450, 400);
    
    [mainWindow setContentMaxSize:standardRect.size];
    [mainWindow setMaxSize:standardRect.size];
    [mainWindow setFrame:standardRect display:true animate:true];
}

// sets generic title
- (void)resetTitle {
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    [mainWindow setStyleMask:[mainWindow styleMask] | NSWindowStyleMaskResizable];
    [mainWindow setTitle:@"EECS 280 Project 2 – Resize GUI"];
}

@end
