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
#import "SidebarController.h"
#import "ConvertWindowController.h"
#import <BWToolkitFramework/BWToolkitFramework.h>

@interface MainWindowController ()

- (NSMutableArray *)generateFilesArrayWithDirectoryPath:(NSString *)path;

@end

@implementation MainWindowController

@synthesize files;

- (IBAction)convertToolButtonClicked:(id)sender {
	
	NSArray *selectedObjects = [filesArrayController selectedObjects];
	
	int filesCount = 0;
	for (FileItem *item in selectedObjects) {
		if (![item isDirectory])
			filesCount++;
	}
	
	if (filesCount == 0) {
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"No Selection"];
		[alert setInformativeText:@"There are no files to be converted."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
	} else {
		[sheetController openSheet:self];		
	}
}

#pragma mark -
#pragma mark Window Life Cycle

- (void)awakeFromNib {
	[super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(sidebarListSelectionDidChange:) 
                                                 name:kSidebarListSelectionDidChange 
                                               object:nil];
	
	self.files = [self generateFilesArrayWithDirectoryPath:@"/"];
}

- (void)sidebarListSelectionDidChange:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSString *path = [userInfo objectForKey:@"path"];
    
    self.files = [self generateFilesArrayWithDirectoryPath:path];
    
    [path release];
}

- (NSMutableArray *)generateFilesArrayWithDirectoryPath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray *newFiles = [[[NSMutableArray alloc] initWithCapacity:[filesArray count]] autorelease];
    for (NSString *filename in filesArray) {
		
		FileItem *item = [[FileItem alloc] init];
		item.path = [path stringByAppendingPathComponent:filename];
		item.name = filename;
		item.icon = [[NSWorkspace sharedWorkspace] iconForFile:item.path];
		
		if (![item isInvisible])
			[newFiles addObject:item];
		
		[item release];
    }
    
    return newFiles;
}

- (void)tableViewDoubleClicked:(NSArray *)selectedObjects {
    	
    if ([selectedObjects count] > 0) {
        
        FileItem *item = (FileItem *)[selectedObjects objectAtIndex:0];
        if ([item isDirectory]) {
            self.files = [self generateFilesArrayWithDirectoryPath:item.path];
        }
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[files release];
	
	[super dealloc];
}

@end