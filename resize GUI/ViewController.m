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

@interface ViewController ()

@property (nonatomic) PPMImageView *ppmView;

@end

@implementation ViewController
    
    /*
     
     plan:
     - DONE: run a successful resize on a ppm file
     - DONE: read filepath from drag and drop
     - add flexible window and learn to decide when the user is done resizing
     - perform a successful resize (with hardcoded width and height) given a drag and drop
     -
     ...
     - ensure packaged application can handle filepaths and store its own temp files
     
     notes:
     - since the eecs 280 euchre executable does not support growing an image, it may be better to compute all shrinking on a "copy" image. We must keep a separate storage so that once euchre overwrites the image path it is given, we have a replacement image to work with
     
            -- btw, you can specify an outputfile in the euchre command line inputs
     -
     
     */

- (void)viewDidLoad {
    [super viewDidLoad];
    [(DragView *)self.view setParentController:self];
}

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
    for (NSLayoutConstraint *c in self.view.constraints) {
        [c setActive:false];
    }
}

- (void)parseImageDataString:(NSString *)imageDataString {
    imageDataString = [imageDataString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    imageDataString = [imageDataString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
    NSArray *imageDataArray = [imageDataString componentsSeparatedByString:@" "];
    int width = [(NSString *)imageDataArray[1] intValue];
    int height = [(NSString *)imageDataArray[2] intValue];
    
    //set window size and constraints
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    NSRect rect = [[[NSApplication sharedApplication] windows][0] frame];
    rect.size.width = width;
    rect.size.height = height;
    [mainWindow setFrame:rect display:true animate:true];
    
    //set window title
    NSString *titleString = [NSString stringWithFormat:@"%d x %d — %@", width, height, self.imagePath];
    [mainWindow setTitle:titleString];
    
    //to store our pixel data
    UInt8 table[[imageDataArray count] * 3];
    
    int offsetIndex = 4;
    for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
            //traverse through columns at every vertical level
            UInt8 r = [(NSString *)imageDataArray[offsetIndex + (h * width * 3) + (3 * w)] intValue];
            UInt8 g = [(NSString *)imageDataArray[offsetIndex + (h * width * 3) + (3 * w) + 1] intValue];
            UInt8 b = [(NSString *)imageDataArray[offsetIndex + (h * width * 3) + (3 * w) + 2] intValue];
            
            UInt32 rgb = 0x000000;
            rgb += b << 16;
            rgb += g << 8;
            rgb += r;
            
            table[(h * width * 3) + (3 * w)] = r;
            table[(h * width * 3) + (3 * w) + 1] = g;
            table[(h * width * 3) + (3 * w) + 2] = b;
        }
    }
    
    NSRect zeroOriginRect = NSMakeRect(0, 0, rect.size.width, rect.size.height);
    if (self.ppmView) {
        [self.ppmView setDataArray:table];
        [self.ppmView setImgWidth:width];
        [self.ppmView setImgHeight:height];
        [self.ppmView refreshImage];
        
    } else {
        self.ppmView = [[PPMImageView alloc] initWithFrame:zeroOriginRect imageArray:table];
        [self.ppmView setParentController:self];
    }
    
    [self.ppmView setFrame:zeroOriginRect];
    [self.view addSubview:self.ppmView];
    [self.ppmView setWantsLayer:true];
    [self.ppmView setNeedsDisplay:true];
    [self.view setNeedsDisplay:true];
}

- (void)loadResizedImagewithBlock:(void (^)(void))completionBlock {
    //lock window size
    NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
    [mainWindow setStyleMask:[mainWindow styleMask] & ~NSWindowStyleMaskResizable];
    //execute resize, and perform completion
    [self executeResize];
    NSError *err;
    NSString *imageDataString = [NSString stringWithContentsOfFile:@"resized.ppm" encoding:NSUTF8StringEncoding error:&err];
    if (imageDataString && !err) {
        //parses image and writes to ppm view
        [self parseImageDataString:imageDataString];
        //remove progress indicator
        
    } else {
        NSLog(@"%@", err);
    }
    //allow window resizing
    [mainWindow setStyleMask:[mainWindow styleMask] | NSWindowStyleMaskResizable];
    //call completion block
    completionBlock();
}

- (NSString *)executeResize {
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    
    NSString *widthArg = [NSString stringWithFormat:@"%d", (int)ceil(mainWindow.frame.size.width)];
    NSString *heightArg = [NSString stringWithFormat:@"%d", (int)ceil(mainWindow.frame.size.height)];
    
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

#pragma mark  - resetting state to original
- (void)clearImage {
    //reactive all constraints to allow image to be shrunk
    for (NSLayoutConstraint *c in self.view.constraints) {
        [c setActive:true];
    }
}





- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
