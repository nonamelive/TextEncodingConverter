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
#import "PathMenuItem.h"
#import "FilesArrayController.h"
#import "SidebarController.h"
#import "ConvertWindowController.h"
#import "TouchView.h"
#import "PathPopupButton.h"
#import <BWToolkitFramework/BWToolkitFramework.h>

@interface MainWindowController ()

- (void)generateFilesArrayWithDirectoryPath:(NSString *)path;
- (void)updateSegmentedControl;
- (void)handleUndo;
- (void)handleRedo;

@end

@implementation MainWindowController

@synthesize currentPath;
@synthesize files;
@synthesize selectedFiles;
@synthesize availableEncodings;
@synthesize fromEncodingIndex;
@synthesize toEncodingIndex;

@synthesize pathControl;

#pragma mark -
#pragma mark Window Life Cycle

- (void)awakeFromNib {
	[super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(sidebarListSelectionDidChange:) 
                                                 name:kSidebarListSelectionDidChange 
                                               object:nil];
	
	// Notifications to perform undo & redo via swipe gestures.
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleUndo) 
												 name:kSwipeGestureLeft 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleRedo) 
												 name:kSwipeGestureRight 
											   object:nil];
	
	// Initialize default foder is "/".
	[self generateFilesArrayWithDirectoryPath:@"/"];
	
	// Retrieve all avaiable string encodings, and store them into self.availableEncodings.
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

#pragma mark -
#pragma mark Undo & Redo

- (IBAction)backForwardSegementedControlClicked:(id)sender {
	
	NSSegmentedControl *segmentedControl = sender;
	if (segmentedControl.selectedSegment == 0) {
		[self handleUndo];
	} else {
		[self handleRedo];
	}
}

- (void)handleUndo {
	
	[[self.window undoManager] undo];
	[self updateSegmentedControl];
}

- (void)handleRedo {
	
	[[self.window undoManager] redo];
	[self updateSegmentedControl];
}

- (void)updateSegmentedControl {
	
	[backForwardSegementedControl setEnabled:[self.window.undoManager canUndo] forSegment:0];
	[backForwardSegementedControl setEnabled:[self.window.undoManager canRedo] forSegment:1];
}

#pragma mark -
#pragma mark Toolbar Items

- (IBAction)pathPopupButtonClicked:(id)sender {
	
	PathPopupButton *popupButton = (PathPopupButton *)sender;
	PathMenuItem *menuItem = (PathMenuItem *)[popupButton selectedItem];
	popupButton.path = menuItem.path;
	[self generateFilesArrayWithDirectoryPath:popupButton.path];
}

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

#pragma mark -
#pragma mark TableView

- (void)tableViewDoubleClicked:(NSArray *)selectedObjects {
	
    if ([selectedObjects count] > 0) {
        
        FileItem *item = (FileItem *)[selectedObjects objectAtIndex:0];
        if ([item isDirectory]) {
            [self generateFilesArrayWithDirectoryPath:item.path];
        }
    }
}

#pragma mark -
#pragma mark Change Path

- (void)generateFilesArrayWithDirectoryPath:(NSString *)path {
    
	if (self.currentPath != nil)
		[[self.window undoManager] registerUndoWithTarget:self selector:@selector(generateFilesArrayWithDirectoryPath:) object:self.currentPath];	
	
	[self updateSegmentedControl];
	
	self.currentPath = path;
	pathPopupButton.path = path;
	
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
    
    self.files = newFiles;
}

#pragma mark -
#pragma mark SidebarList

- (void)sidebarListSelectionDidChange:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    [self generateFilesArrayWithDirectoryPath:[userInfo objectForKey:@"path"]];
}

#pragma mark -
#pragma mark Sheet Window

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
#pragma mark Memory Management

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[currentPath release];
	[files release];
    [selectedFiles release];
	[availableEncodings release];
	
	[super dealloc];
}

@end