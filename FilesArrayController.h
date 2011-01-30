//
//  FilesArrayController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FilesArrayController : NSArrayController <NSTableViewDelegate, NSTableViewDataSource> {
    
	IBOutlet NSTableView *tableView;
	
	BOOL hasItems;
	BOOL hasSelectedItems;
}

@property (assign) BOOL hasItems;
@property (assign) BOOL hasSelectedItems;

- (IBAction)addFiles:(id)sender;
- (IBAction)removeAll:(id)sender;
- (IBAction)clearCovertedItems:(id)sender;

// Drag & Drop support.
- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;


@end
