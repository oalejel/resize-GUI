//
//  PPMImageView.h
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/25/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ResizingImageView.h"
#import "ViewController.h"

@interface PPMImageView : NSView <CALayerDelegate>

@property (nonatomic) int imgWidth;
@property (nonatomic) int imgHeight;
@property (nonatomic) ResizingImageView *resizingImgView;
@property (atomic) UInt8 * dataArray;
@property (nonatomic, weak) ViewController *parentController;

- (id)initWithFrame:(NSRect)frameRect imageArray:(UInt8 *)dataArray;
- (void)refreshImage;

@end
