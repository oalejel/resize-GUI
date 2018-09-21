//
//  DragView.m
//  resize GUI
//
//  Created by Omar Al-Ejel on 2/24/18.
//  Copyright © 2018 Omar Al-Ejel. All rights reserved.
//

#import "DragView.h"

@implementation DragView 

bool didDraw = false;
bool hasExecutable = false;
bool hasImage = false;

-(void)viewDidMoveToSuperview {
    //must register for certain drag types to recieve protocol calls
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

//called when drag has been dropped
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
    NSString *filePath = [files lastObject];

    //check for correct input
    if ([filePath containsString:@".ppm"]) {
        //case where we still have no image
        NSLog(@"got image");
        [self.parentController setImagePath:filePath];
        if (!hasImage) {
            hasImage = true;
            [self adjustInfoField];
        } else {
            //if we already have an image, we need to handle some cleanup!
            //#WARNING need to handle existing image replacement
        }
    } else if ([filePath containsString:@"resize"]) {
        // the executable
        [self.parentController setExecutablePath:filePath];
        hasExecutable = true;
        NSLog(@"got resize");
        [self adjustInfoField];
    }
    
    return true;
}

- (void)adjustInfoField {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!hasImage && !hasExecutable) {
            [self.infoField setPlaceholderString:@"Drag and Drop .ppm image file + \"resize\" executable"];
        } else if (hasImage && !hasExecutable) {
            [self.infoField setPlaceholderString:@"Drag and Drop \"resize\" executable"];
        } else if (!hasImage && hasExecutable) {
            [self.infoField setPlaceholderString:@"Drag and Drop .ppm image file"];
        } else {
            //at this point, our program should be displaying the image
            //we reset the image dragbox states so that when a new image is ready to be dragged in, we may consider it
            hasImage = false;
            hasExecutable = false;
            [self.infoField setPlaceholderString:@"Drag and Drop .ppm image file + resize executable"];
            
            //inform parentview controller
            [self.parentController setNewImage];
        }
    });
}

// reset variables to prepare for a new set of inputs
- (void)resetState {
    //resets drag view state for new image
    self.execPath = nil;
    self.imagePath = nil;
    hasImage = false;
    hasExecutable = false;
}

//more customizational aspects of drag and drop
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    //highlight background
    [self.dragBox setBorderColor:[NSColor systemBlueColor]];
    return NSDragOperationEvery;
}
- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    [self.dragBox setBorderColor:[NSColor clearColor]];
}
- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self.dragBox setBorderColor:[NSColor clearColor]];
}


@end
