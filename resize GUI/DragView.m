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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
    
    if (!didDraw) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
        didDraw = true;
    }
}

//called when drag has been dropped
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
    NSString *fileString = [files lastObject];

    //check for correct input
    if ([[fileString substringFromIndex:[fileString length] - 7] isEqualToString:@"/resize"]) {
        [self.parentController setExecutablePath:fileString];
        hasExecutable = true;
        NSLog(@"got resize");
        [self adjustInfoField];
    } else if ([fileString containsString:@".ppm"]) {
        //case where we still have no image
         NSLog(@"got image");
        [self.parentController setImagePath:fileString];
        if (!hasImage) {
            hasImage = true;
            [self adjustInfoField];
        } else {
            //if we already have an image, we need to handle some cleanup!
            //#WARNING need to handle existing image replacement
        }
    }
    
    return true;
}

- (void)adjustInfoField {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!hasImage && !hasExecutable) {
            [self.infoField setPlaceholderString:@"Drag and Drop .ppm image file + resize executable"];
        } else if (hasImage && !hasExecutable) {
            [self.infoField setPlaceholderString:@"Drag and Drop resize executable"];
        } else if (!hasImage && hasExecutable) {
            [self.infoField setPlaceholderString:@"Drag and Drop .ppm image file"];
        } else {
            //at this point, our program should be displaying the image, and showing a clear button beneath this view
            
            //to prepare for future clearing, we reset our states
//            [self.dragBox setAlphaValue:0.0];
            hasImage = false;
            hasExecutable = false;
            [self.infoField setPlaceholderString:@"Drag and Drop .ppm image file + resize executable"];
            
            //inform parentview controller
            [self.parentController setNewImage];
        }
    });
}

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
