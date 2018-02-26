//
//  PPMImageView.h
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/25/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PPMImageView : NSView <CALayerDelegate>

@property (nonatomic) int imgWidth;
@property (nonatomic) int imgHeight;
@property (nonatomic) NSImageView *imgView;
@property (nonatomic) UInt8 * dataArray;

- (id)initWithFrame:(NSRect)frameRect imageArray:(UInt8 *)dataArray;

@end
