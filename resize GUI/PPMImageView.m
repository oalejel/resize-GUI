//
//  PPMImageView.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/25/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "PPMImageView.h"
#import "ResizingImageView.h"

@interface PPMImageView () <CALayerDelegate>

@property (nonatomic) NSVisualEffectView *vfxView;
@property (nonatomic) NSTimer *resizeTimer;
@property bool hasDrawn;
//@property (nonatomic) NSProgressIndicator *progressInd;

@end

@implementation PPMImageView 



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
        NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize) name:NSWindowDidResizeNotification object:mainWindow];
    }
    return self;
}

- (void)windowDidResize {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
        NSRect newRect = NSMakeRect(0, 0, mainWindow.frame.size.width, mainWindow.frame.size.height);
        [self.resizingImgView setFrame:newRect];
        [self setFrame:newRect];
        if (!self.vfxView) {
            self.vfxView = [[NSVisualEffectView alloc] initWithFrame:newRect];
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
        
        [self fadeInVfxView];
        [self.vfxView setFrame:newRect];
    });
    
    //start or reset a timer to keep track of whether the user has stopped resizing
    if (self.resizeTimer) {
        [self.resizeTimer invalidate];
        self.resizeTimer = nil;
    }
    self.resizeTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:false block:^(NSTimer * _Nonnull timer) {
        //display progress indicator
//        [self showProgressIndicator];
        [self loadResizedImagewithBlock:^{
            [self fadeOutVfxView];
        }];
    }];
}

- (void)loadResizedImagewithBlock:(void (^)(void))completionBlock {
    [self.parentController loadResizedImagewithBlock:completionBlock];
    //once resized image is loaded, the controller will notify this existing ppmimageview
}

- (void)fadeInVfxView {
    [self addSubview:self.vfxView positioned:NSWindowAbove relativeTo:self.resizingImgView];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.2;
        [[self.vfxView animator] setAlphaValue:1];
    } completionHandler:^{
        [self.vfxView setAlphaValue:1];
    }];
}

- (void)fadeOutVfxView {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.2;
            [[self.vfxView animator] setAlphaValue:0];
        } completionHandler:^{
            [self.vfxView setAlphaValue:0];
            [self.vfxView removeFromSuperview];
        }];
}

//- (void)showProgressIndicator {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSWindow *mainWindow = [[NSApplication sharedApplication] windows][0];
//        float width = mainWindow.frame.size.width;
//        float height = mainWindow.frame.size.height;
//        NSRect progressRect = NSMakeRect(0.5 * width - 50, 0.5 * height - 50, 100, 100);
//
//        self.progressInd = [[NSProgressIndicator alloc] initWithFrame:progressRect];
//        [self.progressInd setStyle:NSProgressIndicatorSpinningStyle];
//        [self.progressInd setIndeterminate:true];
//        [self.progressInd setUsesThreadedAnimation:false];
//
//        [self addSubview:self.progressInd positioned:NSWindowAbove relativeTo:self.vfxView];
//        [self.progressInd startAnimation:self];
//        [self.progressInd setNeedsDisplay:true];
//    });
//}

- (void)refreshImage {
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
        
        NSRect imgRect = NSMakeRect(0, 0, self.imgWidth, self.imgHeight);
        if (self.resizingImgView) {
            [self.resizingImgView removeFromSuperview];
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

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    NSRect rect = self.bounds;
    rect.origin.x = 0;
    rect.origin.y = 0;
    [self drawRect:rect];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (!self.hasDrawn) {
        [self refreshImage];
        self.hasDrawn = true;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
