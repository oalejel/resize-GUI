//
//  Global.h
//  resize GUI
//
//  Created by Omar Al-Ejel on 3/1/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

+ (NSRect)getDrawingRect;
+ (NSSize)getDrawingSize;
+ (CGFloat)getCorrectedHeight:(CGFloat)height;

@property (class) CGFloat titleOffset;

@end
