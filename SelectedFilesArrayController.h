//
//  SelectedFilesArrayController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/23/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SelectedFilesArrayController : NSArrayController {
	
	IBOutlet NSTableView *tableView;
	
	BOOL hasItems;
}

@property (assign) BOOL hasItems;

// Drag & drop support.
- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;

@end
