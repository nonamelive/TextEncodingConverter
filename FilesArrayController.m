//
//  FilesArrayController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "FilesArrayController.h"
#import "FileItem.h"
#import "NSTableView+DeleteKey.h"

@implementation FilesArrayController

@synthesize hasItems;
@synthesize hasSelectedItems;

#pragma -
#pragma mark Actions

- (IBAction)addFiles:(id)sender {
	
	NSOpenPanel *openDialog = [NSOpenPanel openPanel];
	[openDialog setCanChooseDirectories:NO];
	[openDialog setCanChooseFiles:YES];
	[openDialog setAllowsMultipleSelection:YES];
	
	if ([openDialog runModal] == NSOKButton) {
		
		for (NSURL *url in [openDialog URLs]) {
			FileItem *item = [[FileItem alloc] init];
			item.path = [url path];
			if (![self.arrangedObjects containsObject:item]) {
				[self addObject:item];
			}
			[item release];
		}
	}
}

- (IBAction)removeAll:(id)sender {
	
	[self removeObjects:self.arrangedObjects];
}

- (IBAction)clearCovertedItems:(id)sender {
		
	for (FileItem *item in self.arrangedObjects) {
		if (item.status == kFileItemStatusSucceeded) {
			[self removeObject:item];
		}
	}
}

#pragma mark -
#pragma mark Array Controller Overrides

- (NSArray *)arrangedObjects {
	
	self.hasItems = [super.arrangedObjects count];
	
    return [super arrangedObjects];
}


#pragma mark -
#pragma mark Table View Notifications

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	
	if ([notification object] != tableView)
		return;
	
	self.hasSelectedItems = [[tableView selectedRowIndexes] count] > 0;
}

#pragma mark Table View Delegates

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
    
	if ([info draggingSource] == tv) {
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


- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
	
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

#pragma mark Delete Key Delegate

- (void) deleteKeyPressed:(NSTableView *)aTableView onRow:(int)rowIndex {
    [self removeObjects:[self selectedObjects]];
    [self setSelectionIndex:rowIndex];
}


#pragma mark -
#pragma mark View Life Cycle

- (void)awakeFromNib {
	
	// Register the table view for dragged types an set the drag mask.
	[tableView setDraggingSourceOperationMask:NSDragOperationLink forLocal:NO];
	[tableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
	[tableView registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(tableViewSelectionDidChange:) 
												 name:NSTableViewSelectionDidChangeNotification 
											   object:nil];
	
	self.hasSelectedItems = NO;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    // Clean-up code here.
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

@end
