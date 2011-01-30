//
//  EncodingsArrayController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/30/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "EncodingsArrayController.h"
#import "Encoding.h"

@implementation EncodingsArrayController

@synthesize lastEncoding;

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
		
	if ([notification object] != tableView)
		return;
	
	if ([[self selectedObjects] count] > 0) {
		Encoding *encoding = [[self selectedObjects] lastObject];
		
		if (encoding != self.lastEncoding) {
			self.lastEncoding = encoding;
			[[NSNotificationCenter defaultCenter] postNotificationName:kEncodingTableViewSelectionChange object:encoding userInfo:nil];
		}
	}
}

- (void)awakeFromNib {
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(tableViewSelectionDidChange:) 
												 name:NSTableViewSelectionDidChangeNotification 
											   object:nil];
}

- (void)dealloc {
    // Clean-up code here.
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

@end
