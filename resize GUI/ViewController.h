//
//  ViewController.h
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/24/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

- (void)setNewImage;
- (void)loadResizedImagewithBlock:(void (^)(void))completionBlock;

@property (nonatomic) NSString *executablePath;
@property (nonatomic) NSString *imagePath;


@end

