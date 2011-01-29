//
//  SelectedFilesArrayController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/23/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "SelectedFilesArrayController.h"
#import "FileItem.h"

@implementation SelectedFilesArrayController

@synthesize hasItems;

- (NSArray *)arrangedObjects {
	
	self.hasItems = [super.arrangedObjects count];
	
    return [super arrangedObjects];
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    
	if ([info draggingSource] == tableView) {
		return NSDragOperationNone;
    }
	
	NSDragOperation dragOp = NSDragOperationNone;
	
	NSURL *url = [NSURL URLFromPasteboard:[info draggingPasteboard]];
	
	if (url != nil) {
		dragOp = NSDragOperationCopy;
		/*
		 we want to put the object at, not over, the current row (contrast NSTableViewDropOn) 
		 */
		[tv setDropRow:row dropOperation:NSTableViewDropAbove];
	}
	
    return dragOp;
}


- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
	
    if (row < 0) {
		row = 0;
	}
    	
	NSArray *array = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	for (id filePath in array) {
		FileItem *item = [[FileItem alloc] init];
		item.path = filePath;
		if (![item isDirectory]) {
			if (![self.arrangedObjects containsObject:item]) {
				[self insertObject:item atArrangedObjectIndex:row];
			}
		}
		[item release];
	}
	
	return YES;		
}

- (void)awakeFromNib {

	// Register the table view for dragged types an set the drag mask.
	[tableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
	[tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
}


- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

@end
