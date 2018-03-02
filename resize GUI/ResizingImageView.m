//
//  ResizingImageView.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/26/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "ResizingImageView.h"

@implementation ResizingImageView

// this alternative to an NSImageView gives us the same content mode AspectFill behavior from UIKit
- (id)initWithFrame:(NSRect)frame andImage:(NSImage*)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer = [[CALayer alloc] init];
        self.layer.contentsGravity = kCAGravityResizeAspectFill;
        self.layer.contents = image;
        self.wantsLayer = YES;
    }
    return self;
}

@end
