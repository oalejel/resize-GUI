//
//  PPMImageView.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/25/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "PPMImageView.h"
#import "ResizingImageView.h"

@implementation PPMImageView 

bool hasDrawn = false;

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer = [self makeBackingLayer];
        [self.layer setDelegate:self];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect imageArray:(UInt8 *)dataArray {
    self = [self initWithFrame:frameRect];
    if (self) {
        [self setDataArray:dataArray];
        [self setImgWidth:frameRect.size.width];
        [self setImgHeight:frameRect.size.height];
        
        //register for window resizing observation
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize) name:NSWindowDidResizeNotification object:mainWindow];
        
        
//        NSImageView *newImageView = [[NSImageView alloc] initWithFrame:frameRect];
//        [self setImgView:newImageView];
    }
    return self;
}

- (void)windowDidResize {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
//        [self.imgView setFrameSize:mainWindow.frame.size];
//        [self.imgView setFrameOrigin:NSZeroPoint];
        [self.resizingImgView setFrameSize:mainWindow.frame.size];
        [self.resizingImgView setFrameOrigin:NSZeroPoint];
        [self setFrameSize:mainWindow.frame.size];
        [self setFrameOrigin:NSZeroPoint];
    });
}

- (void)refreshImage {
    if (self.dataArray) {
        CGDataProviderRef provider = CGDataProviderCreateWithData(nil, self.dataArray, self.imgHeight * self.imgWidth * 3, nil);
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        CGImageRef img = CGImageCreate(self.imgWidth,                         // width
                                       self.imgHeight,                         // height
                                       8,                          // bitsPerComponent
                                       24,                         // bitsPerPixel
                                       self.imgWidth * 3,            // bytesPerRow
                                       space,                      // colorspace
                                       kCGBitmapByteOrderMask,  // bitmapInfo
                                       provider,                   // CGDataProvider
                                       nil,                 // decode array
                                       false,                         // shouldInterpolate
                                       kCGRenderingIntentDefault); // intent

        NSSize imgSize = NSMakeSize(self.imgWidth, self.imgHeight);
        // use the created CGImage
        NSImage *bmpImage = [[NSImage alloc] initWithCGImage:img size:imgSize];
        [bmpImage setResizingMode:NSImageResizingModeStretch];
        
        NSRect imgRect = NSMakeRect(0, 0, self.imgWidth, self.imgHeight);
        if (self.resizingImgView) {
            [self.resizingImgView removeFromSuperview];
        }
        ResizingImageView *resizingImgView = [[ResizingImageView alloc] initWithFrame:imgRect andImage:bmpImage];
        [self setResizingImgView: resizingImgView];
        [self addSubview:self.resizingImgView];
        
        ///[self.imgView setImage:bmpImage];
        
        CGColorSpaceRelease(space);
        CGDataProviderRelease(provider);
        
        CGImageRelease(img);
    } else {
        NSLog(@"no image data!");
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    NSRect rect = self.bounds;
    rect.origin.x = 0;
    rect.origin.y = 0;
    [self drawRect:rect];
}



- (void)drawRect:(NSRect)dirtyRect {
//    [self.layer setBackgroundColor:[[NSColor redColor] CGColor]];
    [super drawRect:dirtyRect];
    if (!hasDrawn) {
        ///[self.imgView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
//
//        //add constraints
//        [[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0] setActive:true];
////        [self addConstraint:topConstraint];
//
//        [[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0] setActive:true];
////        [self addConstraint:bottomConstraint];
//
//        [[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0] setActive:true];
////        [self addConstraint:leftConstraint];
//
//        [[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0] setActive:true];
////        [[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0] setActive:true];
////
////         [[NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0] setActive:true];

//        [[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0] setActive:true];
//
//        [[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0] setActive:true];
//
//        [[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:0] setActive:true];
//
//        [[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:0] setActive:true];

        [self refreshImage];
        hasDrawn = true;
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
