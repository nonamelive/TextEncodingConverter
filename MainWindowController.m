//
//  MainWindowController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "MainWindowController.h"
#import "FileItem.h"
#import "Encoding.h"
#import "FilesArrayController.h"
#import "SidebarController.h"
#import "ConvertWindowController.h"
#import <BWToolkitFramework/BWToolkitFramework.h>

@interface MainWindowController ()

- (NSMutableArray *)generateFilesArrayWithDirectoryPath:(NSString *)path;

@end

@implementation MainWindowController

@synthesize currentPath;
@synthesize files;
@synthesize selectedFiles;
@synthesize availableEncodings;
@synthesize fromEncodingIndex;
@synthesize toEncodingIndex;

- (IBAction)convertToolButtonClicked:(id)sender {
	
	NSArray *selectedObjects = [filesArrayController selectedObjects];
	
    NSMutableArray *selectedFilesArray = [[NSMutableArray alloc] init];
	for (FileItem *item in selectedObjects) {
		if (![item isDirectory])
			[selectedFilesArray addObject:item];
	}
	self.selectedFiles = selectedFilesArray;
    [selectedFilesArray release];
    
	if ([self.selectedFiles count] == 0) {
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

- (IBAction)convertButtonClicked:(id)sender {
	
	NSStringEncoding fromEncoding = [(Encoding *)[self.availableEncodings objectAtIndex:fromEncodingIndex] stringEncoding];
	NSStringEncoding toEncoding = [(Encoding *)[self.availableEncodings objectAtIndex:toEncodingIndex] stringEncoding];	
	
	for (FileItem *item in self.selectedFiles) {
		NSError *error;
		NSString *content = [NSString stringWithContentsOfFile:item.path encoding:fromEncoding error:nil];
		NSString *newPath = [item.path stringByAppendingPathExtension:@".utf8.txt"];
		BOOL result = [content writeToFile:newPath atomically:YES encoding:toEncoding error:&error];
		if (!content)
			result = NO;
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
	
	NSMutableArray *encodingsArray = [[NSMutableArray alloc] init];
	const NSStringEncoding *encodings = [NSString availableStringEncodings];
	NSStringEncoding encoding;
	int index = 0;
	while ((encoding = *encodings++) != 0) {
		
		if (encoding == NSUTF8StringEncoding)
			self.toEncodingIndex = index;
		index++;
		
		Encoding *newEncoding = [[Encoding alloc] init];
		newEncoding.stringEncoding = encoding;
		newEncoding.localizedName = [NSString localizedNameOfStringEncoding:encoding];
		[encodingsArray addObject:newEncoding];
		[newEncoding release];
	}
	self.availableEncodings = encodingsArray;
	[encodingsArray release];
}

- (void)sidebarListSelectionDidChange:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    self.files = [self generateFilesArrayWithDirectoryPath:[userInfo objectForKey:@"path"]];
}

- (NSMutableArray *)generateFilesArrayWithDirectoryPath:(NSString *)path {
    
	self.currentPath = [NSURL fileURLWithPath:path];
	
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

- (IBAction)pathControlClicked:(id)sender {
	
	NSPathControl *pathControl = sender;
	NSURL *pathControlPath = [[[pathControl clickedPathComponentCell] URL] URLByStandardizingPath];
	BOOL samePath = [pathControlPath isEqualTo:[currentPath URLByStandardizingPath]];
	if (!samePath) {
		self.files = [self generateFilesArrayWithDirectoryPath:[pathControlPath path]];
	}
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[currentPath release];
	[files release];
    [selectedFiles release];
	[availableEncodings release];
	
	[super dealloc];
}

@end