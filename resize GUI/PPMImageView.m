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

- (id)initWithFrame:(NSRect)frameRect imageData:(NSMutableData *)imgData {
    self = [self initWithFrame:frameRect];
    if (self) {
        [self setImgData:imgData];
        [self setImgWidth:frameRect.size.width];
        [self setImgHeight:frameRect.size.height];
        
        NSImageView *newImageView = [[NSImageView alloc] initWithFrame:frameRect];
        [self setImgView:newImageView];
    }
    return self;
}

- (void)refreshImage {
    if (self.imgData) {
//        NSData *byteData = [NSData dataWithBytes:(__bridge const void * _Nullable)(self.imgData) length:self.imgData.length];
        NSBitmapImageRep *bmpRep = [NSBitmapImageRep imageRepWithData:self.imgData];
        NSSize imageSize = NSMakeSize(self.imgWidth, self.imgHeight);
        
        NSImage *bmpImage = [[NSImage alloc] initWithSize:imageSize];
        [bmpImage addRepresentation:bmpRep];
        [self.imgView setImage:bmpImage];
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
        [self refreshImage];
        hasDrawn = true;
    }
}
    
    
//    CGImageRef ref = CGImageCreate(dirtyRect.size.width, dirtyRect.size.height, 8, 24, dirtyRect.size.width * 3, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderMask, CGDataProviderCreateWithData(<#void * _Nullable info#>, <#const void * _Nullable data#>, dirtyRect.size.width * dirtyRect.size.height * 3, nil), 0, false, kCGPDFContextOutputIntent);
//
//    NSImage *img = [[NSImage alloc] initWithCGImage:ref size:NSMakeSize(dirtyRect.size.width, dirtyRect.size.height)];
//
//    //alternative
//
//    [otherImg addRepresentation:imageRep]
    
    
    // Drawing code here.

@end
