//
//  MainWindowController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "MainWindowController.h"
#import "FileItem.h"
#import "FilesArrayController.h"

@implementation MainWindowController

@synthesize files;

#pragma mark -
#pragma mark Window Life Cycle

- (void)awakeFromNib {
	[super awakeFromNib];
	
	FileItem *item = [[FileItem alloc] init];
	item.name = @"Google";
	
	self.files = [[NSMutableArray alloc] initWithObjects:item, item, item, nil];
}

- (void)windowDidLoad {
	
	[filesTableView reloadData];
}

- (void)dealloc {
    
	[files release];
	
	[super dealloc];
}

@end