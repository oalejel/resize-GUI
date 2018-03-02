//
//  PPMImageView.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/25/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "PPMImageView.h"
#import "ResizingImageView.h"
#import "Global.h"

@interface PPMImageView () <CALayerDelegate>

@property (nonatomic) NSVisualEffectView *vfxView;
@property (nonatomic) NSTimer *resizeTimer;
@property bool hasDrawn;

@end

@implementation PPMImageView 

// basic NSView initializer
- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer = [self makeBackingLayer];
        [self.layer setDelegate:self];
    }
    return self;
}

// custom initializer
- (id)initWithFrame:(NSRect)frameRect imageArray:(UInt8 *)dataArray {
    self = [self initWithFrame:frameRect];
    if (self) {
        [self setDataArray:dataArray];
        [self setImgWidth:frameRect.size.width];
        [self setImgHeight:frameRect.size.height];
        
        //register for window resizing observation
        NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize) name:NSWindowDidResizeNotification object:mainWindow];
    }
    return self;
}

//called every time small changes are made to window size
- (void)windowDidResize {
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    [self.resizingImgView setFrame:mainWindow.contentView.frame];
    [self setFrame:mainWindow.contentView.frame];
    if (!self.vfxView) {
        self.vfxView = [[NSVisualEffectView alloc] initWithFrame:mainWindow.contentView.frame];
        [self.vfxView setState:NSVisualEffectStateActive];
        [self.vfxView setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
        [self.vfxView setMaterial:NSVisualEffectMaterialLight];
        [self addSubview:self.vfxView];
        
        self.vfxView.alphaValue = 0;
        [self fadeInVfxView];
    } else if (!self.vfxView.superview) {
        //in case it needs to be added back, animate in
        [self addSubview:self.vfxView];
    }
    
    //show a blur to avoid false impression that image is being seam-carved live
    [self fadeInVfxView];
    [self.vfxView setFrame:mainWindow.contentView.frame];
    
    //start or reset a timer to keep track of whether the user has stopped resizing
    if (self.resizeTimer) {
        [self.resizeTimer invalidate];
        self.resizeTimer = nil;
    }
    self.resizeTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:false block:^(NSTimer * _Nonnull timer) {
        [self loadResizedImagewithBlock:^{
            [self fadeOutVfxView];
        }];
    }];
}

//tells viewcontroller to load run resie and load image
- (void)loadResizedImagewithBlock:(void (^)(void))completionBlock {
    [self.parentController loadResizedImageWithBlock:completionBlock];
    //once resized image is loaded, the controller will notify this existing ppmimageview
}

//animates in blur view
- (void)fadeInVfxView {
    [self addSubview:self.vfxView positioned:NSWindowAbove relativeTo:self.resizingImgView];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.2;
        [[self.vfxView animator] setAlphaValue:1];
    } completionHandler:^{
        [self.vfxView setAlphaValue:1];
    }];
}

//animates blur view away
- (void)fadeOutVfxView {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.2;
        [[self.vfxView animator] setAlphaValue:0];
    } completionHandler:^{
        [self.vfxView setAlphaValue:0];
        [self.vfxView removeFromSuperview];
    }];
}

//draws image from pixel data table with coregraphics
- (void)refreshImage {
    NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
    [self.resizingImgView setFrame:mainWindow.contentView.frame];
    [self setFrame:mainWindow.contentView.frame];
 
    if (self.dataArray) {
        CGDataProviderRef provider = CGDataProviderCreateWithData(nil, self.dataArray, self.imgHeight * self.imgWidth * 3, nil);
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        
        CGImageRef img = CGImageCreate(self.imgWidth,              // width
                                       self.imgHeight,             // height
                                       8,                          // bitsPerComponent
                                       24,                         // bitsPerPixel
                                       self.imgWidth * 3,          // bytesPerRow
                                       space,                      // colorspace
                                       kCGBitmapByteOrderMask,     // bitmapInfo
                                       provider,                   // CGDataProvider
                                       nil,                        // decode array
                                       false,                      // shouldInterpolate
                                       kCGRenderingIntentDefault); // intent

        NSSize imgSize = NSMakeSize(self.imgWidth, self.imgHeight);
        // use the created CGImage
        NSImage *bmpImage = [[NSImage alloc] initWithCGImage:img size:imgSize];
        [bmpImage setResizingMode:NSImageResizingModeStretch];
        
        //we need not worry about title bar height being a component of window height here
        //since the ppmimageview will already be offset
        NSRect imgRect = NSMakeRect(0, 0, self.imgWidth, self.imgHeight);
        if (self.resizingImgView) {
            [self.resizingImgView removeFromSuperview];
            self.resizingImgView = nil;
        }
        self.resizingImgView = [[ResizingImageView alloc] initWithFrame:imgRect andImage:bmpImage];
        [self setResizingImgView: self.resizingImgView];
        [self addSubview:self.resizingImgView positioned:NSWindowBelow relativeTo:self.vfxView];
        
        CGColorSpaceRelease(space);
        CGDataProviderRelease(provider);
        
        CGImageRelease(img);
    } else {
        NSLog(@"no image data!");
    }
}

//called when content is ready to be drawn to layer
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    NSRect rect = self.bounds;
    rect.origin.x = 0;
    rect.origin.y = 0;
    self.layer.backgroundColor = [[NSColor windowBackgroundColor] CGColor];
    [self drawRect:rect];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (!self.hasDrawn) {
        self.hasDrawn = true;
            //this mini-hack will work for now. It's taking quite some time to figure out why refreshing with the original image causes issues for small images
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.parentController loadResizedImageWithBlock:^{ }];
//                [self refreshImage];
            });
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
