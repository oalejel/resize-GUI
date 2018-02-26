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
    
//    NSData *rawFileData = [NSData dataWithContentsOfFile:self.imagePath];
//    NSString *fileString =
    NSError *err;
    NSString *imageDataString = [NSString stringWithContentsOfFile:self.imagePath encoding:NSUTF8StringEncoding error:&err];
//    NSString *imageDataString = [[NSString alloc] initWithData:rawFileData encoding:NSUTF8StringEncoding];
    
    if (err) {
        NSLog(@"%@", err);
    }
    
    imageDataString = [imageDataString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    imageDataString = [imageDataString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    
//    [imageDataString replaceOccurrencesOfString:@"\n" withString:@" " options:NSLiteralSearch range:NSRangeFromString(imageDataString)];
//    [imageDataString replaceOccurrencesOfString:@"  " withString:@" " options:NSLiteralSearch range:NSRangeFromString(imageDataString)];
    
    NSArray *imageDataArray = [imageDataString componentsSeparatedByString:@" "];
    int width = [(NSString *)imageDataArray[1] intValue];
    int height = [(NSString *)imageDataArray[2] intValue];
    
    //set window size
    NSRect rect = [[[NSApplication sharedApplication] mainWindow] frame];
    rect.size.width = width;
    rect.size.height = height;
    [[[NSApplication sharedApplication] mainWindow] setFrame:rect display:true];
    
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
    PPMImageView *ppmView = [[PPMImageView alloc] initWithFrame:zeroOriginRect imageArray:table];
    [ppmView setParentController:self];
    
    [ppmView setFrameOrigin:NSZeroPoint];
    [ppmView setFrameSize:NSMakeSize(width, height)];
    [self.view addSubview:ppmView];
    [ppmView setWantsLayer:true];
    [ppmView setNeedsDisplay:true];
    [self.view setNeedsDisplay:true];
    //note: ppmImageView should call refresh on drawrect
}

- (void)loadResizedImage {
    //display loading indicator
    //lock window size
    
}

- (void)executeResize {
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"resize" ofType:@""];
//    NSString *horsePath = [[NSBundle mainBundle] pathForResource:@"horses" ofType:@".ppm"];
    NSArray *tempArgs = [NSArray arrayWithObjects: self.imagePath, @"modified.ppm", @"200", nil];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:self.executablePath];
    [task setArguments:tempArgs];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    [task setStandardError:errorPipe];
    
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *ouputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *errData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
    NSString *errOutputString = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", errOutputString);
    NSLog(@"%@", ouputString);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
