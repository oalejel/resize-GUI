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

@end

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
    }
    return self;
}

- (void)windowDidResize {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSWindow *mainWindow = [[NSApplication sharedApplication] mainWindow];
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
            [self fadeInVfxView];
        }
        
        [self.vfxView setFrame:newRect];
    });
    
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

- (void)loadResizedImagewithBlock:(void (^)(void))completionBlock {
    [self.parentController loadResizedImage];
    //once resized image is loaded, the controller will notify this existing ppmimageview
    
    //call completion block at end
    completionBlock();
}

- (void)fadeInVfxView {
    self.vfxView.alphaValue = 0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.3;
        [[self.vfxView animator] setAlphaValue:1];
    } completionHandler:^{
    }];
}

- (void)fadeOutVfxView {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 1;
        self.vfxView.alphaValue = 0.3;
        
        [[self.vfxView animator] setAlphaValue:0];
    } completionHandler:^{
        [self.vfxView removeFromSuperview];
        self.vfxView.alphaValue = 0.5;
    }];
}

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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
