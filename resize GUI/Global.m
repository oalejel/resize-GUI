//
//  Global.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 3/1/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "Global.h"
#import <Cocoa/Cocoa.h>

@implementation Global
CGFloat _titleOffset = 0;

+ (NSRect)getDrawingRect {
    NSWindow *window = [[NSApplication sharedApplication] windows][0];
    NSView *contentView = [window contentView];
    return contentView.frame;
}
+ (NSSize)getDrawingSize {
    return [Global getDrawingRect].size;
}
+ (CGFloat)getCorrectedHeight:(CGFloat)height {
    return height + Global.titleOffset;
}
+ (CGFloat)titleOffset {
    return _titleOffset;
}
+ (void)setTitleOffset:(CGFloat)input {
    _titleOffset = input;
}

@end
