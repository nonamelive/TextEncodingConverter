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

- (void)updateSidebarListSelectionItemWithPath:(NSString *)path;
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
@synthesize saveDestinationFolderPath;
@synthesize converting;
@synthesize overwriting;
@synthesize pathControl;

#pragma mark -
#pragma mark Window Life Cycle

- (IBAction)refreshMenuItemClicked:(id)sender {
	[self generateFilesArrayWithDirectoryPath:self.currentPath];
}

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
	[self updateSidebarListSelectionItemWithPath:@"/"];
	
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
	
	self.saveDestinationFolderPath = @"";
}

#pragma mark -
#pragma mark Undo & Redo

- (IBAction)backForwardSegementedControlClicked:(id)sender {
	NSLog(@"%@", self.currentPath);
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
		if (![item isDirectory]) {
			item.status = kFileItemStatusWaiting;
			[selectedFilesArray addObject:item];
		}
	}
	self.selectedFiles = selectedFilesArray;
    [selectedFilesArray release];
	
	[progressIndicator setDoubleValue:0];
    
	[sheetController openSheet:self];
}

#pragma mark -
#pragma mark TableView

- (void)tableViewDoubleClicked:(NSArray *)selectedObjects {
	
    if ([selectedObjects count] > 0) {
        
        FileItem *item = (FileItem *)[selectedObjects objectAtIndex:0];
        if ([item isDirectory]) {
            [self generateFilesArrayWithDirectoryPath:item.path];
        } else {
			[self convertToolButtonClicked:nil];
		}
    }
}

- (IBAction)selectDestinationFolderButtonClicked:(id)sender {
	
	NSOpenPanel *openDialog = [NSOpenPanel openPanel];
	[openDialog setCanChooseDirectories:YES];
	[openDialog setCanChooseFiles:NO];

	if ([openDialog runModal] == NSOKButton) {
		NSURL *folder = [openDialog URL];
		self.saveDestinationFolderPath = [folder path];
	}
}
#pragma mark -
#pragma mark Change Path

- (void)generateFilesArrayWithDirectoryPath:(NSString *)path {
    	
	if (self.currentPath != nil && ![self.currentPath isEqualToString:path])
		[[self.window undoManager] registerUndoWithTarget:self selector:@selector(generateFilesArrayWithDirectoryPath:) object:self.currentPath];	
	
	[self updateSegmentedControl];
	
	self.currentPath = path;
	pathPopupButton.path = path;
	[self updateSidebarListSelectionItemWithPath:self.currentPath];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray *newFiles = [[[NSMutableArray alloc] initWithCapacity:[filesArray count]] autorelease];
    for (NSString *filename in filesArray) {
		
		FileItem *item = [[FileItem alloc] init];
		item.path = [path stringByAppendingPathComponent:filename];
		
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

- (void)updateSidebarListSelectionItemWithPath:(NSString *)path {

	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCurrentFolderChanged object:nil userInfo:userInfo];
}

#pragma mark -
#pragma mark Sheet Window

- (IBAction)clearSucceededFilesMenuItemClicked:(id)sender {
	
	NSMutableArray *remainings = [[NSMutableArray alloc] init];
	
	for (FileItem *item in self.selectedFiles) {
		if (item.status != kFileItemStatusSucceeded) {
			[remainings addObject:item];
		}
	}
	
	self.selectedFiles = remainings;
	[remainings release];
}

- (IBAction)convertButtonClicked:(id)sender {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL saveFolderExists = NO;
	[fileManager fileExistsAtPath:self.saveDestinationFolderPath isDirectory:&saveFolderExists];
	if (!saveFolderExists && ![self.saveDestinationFolderPath isEqualToString:@""]) {
		
		NSLog(@"ERROR");
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Cannot save files."];
		[alert setInformativeText:@"Destination doesn't exist. Please select another directory."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		
		return;
	}

	NSStringEncoding fromEncoding = [(Encoding *)[self.availableEncodings objectAtIndex:fromEncodingIndex] stringEncoding];
	NSStringEncoding toEncoding = [(Encoding *)[self.availableEncodings objectAtIndex:toEncodingIndex] stringEncoding];	
	
	[progressIndicator setMaxValue:[self.selectedFiles count]];
	[progressIndicator setMinValue:0];
	[progressIndicator startAnimation:self];
	[progressIndicator setUsesThreadedAnimation:YES];
	self.converting = YES;
	
	BOOL allItemsConvertedSucceeded = YES;
	
	for (FileItem *item in self.selectedFiles) {

		item.status = kFileItemStatusWaiting;
		
		NSString *newPath = nil;
		if (saveFolderExists) {
			newPath = [self.saveDestinationFolderPath stringByAppendingPathComponent:item.convertedFilename];
		} else {
			newPath = [[item.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:item.convertedFilename];
		}
		
		BOOL result = YES;
		if (![fileManager fileExistsAtPath:newPath] || self.overwriting) {
			NSError *error = nil;
			NSString *content = [NSString stringWithContentsOfFile:item.path encoding:fromEncoding error:nil];
			result = [content writeToFile:newPath atomically:YES encoding:toEncoding error:&error];
			if (!content || error.code) {
				result = NO;
				NSLog(@"Failed.");
			}
		} else {
			result = NO;
			NSLog(@"File existed.");
		}
		
		if (result == NO) {
			allItemsConvertedSucceeded = NO;
			item.status = kFileItemStatusFailed;
		} else {
			item.status = kFileItemStatusSucceeded;
		}
		
		[progressIndicator setDoubleValue:[progressIndicator doubleValue] + 1];
	}
	
	[progressIndicator stopAnimation:self];
	self.converting = NO;
	
	if (!allItemsConvertedSucceeded) {
		NSLog(@"ERROR");
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Failed to convert one or more files."];
		[alert setInformativeText:@"Some files cannot be converted because output file is already existed or original encoding is wrong."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:nil contextInfo:nil];
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
	[saveDestinationFolderPath release];
	
	[super dealloc];
}

@end