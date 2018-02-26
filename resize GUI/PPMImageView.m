//
//  PPMImageView.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/25/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "PPMImageView.h"

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
        
        NSImageView *newImageView = [[NSImageView alloc] initWithFrame:frameRect];
        [self setImgView:newImageView];
    }
    return self;
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
        [self.imgView setImage:bmpImage];
        
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
        [self addSubview:self.imgView];
        //add constraints
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        [self.imgView addConstraint:topConstraint];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        [self.imgView addConstraint:bottomConstraint];
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        [self.imgView addConstraint:leftConstraint];
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.imgView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        [self.imgView addConstraint:rightConstraint];
        
        [self refreshImage];
        hasDrawn = true;
    }
}

@end
