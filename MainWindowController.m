//
//  MainWindowController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "MainWindowController.h"
#import "FilesArrayController.h"
#import "EncodingsArrayController.h"
#import "FileItem.h"
#import "Encoding.h"
#import "TouchView.h"
#import "NSStringEncodingSniffer.h"

@implementation MainWindowController

@synthesize files;
@synthesize availableEncodings;
@synthesize fromEncodingIndex;
@synthesize toEncodingIndex;
@synthesize saveDestinationFolderPath;
@synthesize converting;
@synthesize overwriting;
@synthesize previewText;
@synthesize previewData;

#pragma mark -
#pragma mark Preview Window

- (void)encodingTableViewSelectionChanged:(NSNotification *)notification {
	
	Encoding *encoding = [notification object];
	NSString *previewString = [[NSString alloc] initWithData:self.previewData encoding:encoding.stringEncoding];
	self.previewText = previewString;
	[previewString release];
}

- (IBAction)applyButtonClicked:(id)sender {
	
	self.fromEncodingIndex = [self.availableEncodings indexOfObject:encodingsArrayController.lastEncoding];
	
	[NSApp stopModal];
}

- (IBAction)cancelButtonClicked:(id)sender {
	
	[NSApp stopModal];
}

#pragma mark -
#pragma mark Toolbar & Buttons

- (IBAction)showInFinderButtonClicked:(id)sender {
		
	for (FileItem *item in [filesArrayController selectedObjects]) {
		NSString *folder = [item.path stringByDeletingLastPathComponent];
		[[NSWorkspace sharedWorkspace] selectFile:item.path inFileViewerRootedAtPath:folder];
	}
}

- (IBAction)guessEncodingButtonClicked:(id)sender {
	
	NSArray *selectedItems = [filesArrayController selectedObjects];
	
	FileItem *item = [selectedItems objectAtIndex:0];
	self.previewData = [[[NSData alloc] initWithContentsOfFile:item.path] autorelease];

//	NSArray *possibleEncodings = [NSStringEncodingSniffer sniffData:itemData];
//	
//	for (NSNumber *encoding in possibleEncodings) {
//		NSString *name = [NSString localizedNameOfStringEncoding:[encoding intValue]];
//		if (!name || [name isEqualTo:@""]) {
//			name = [NSString localizedNameOfStringEncoding:[encoding intValue] - 2147483648.0];
//		}
//		NSLog(@"%d - %@", (NSInteger)[encoding intValue], name);
//	}
//	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(encodingTableViewSelectionChanged:) 
												 name:kEncodingTableViewSelectionChange 
											   object:nil];
	
	if (encodingsArrayController.lastEncoding == nil) {
		encodingsArrayController.lastEncoding = [self.availableEncodings objectAtIndex:0];
	}
	
	NSString *previewString = [[NSString alloc] initWithData:self.previewData encoding:encodingsArrayController.lastEncoding.stringEncoding];
	self.previewText = previewString;
	[previewString release];
	
	[NSApp beginSheet:previewWindow modalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[NSApp runModalForWindow:previewWindow];
	// sheet is up here...
	
	[NSApp endSheet:previewWindow];
	[previewWindow orderOut:self];
		
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kEncodingTableViewSelectionChange object:nil];
	self.previewText = nil;
	self.previewData = nil;
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

- (IBAction)convertButtonClicked:(id)sender {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL saveFolderExists = NO;
	[fileManager fileExistsAtPath:self.saveDestinationFolderPath isDirectory:&saveFolderExists];
	if (!saveFolderExists && ![self.saveDestinationFolderPath isEqualToString:@""]) {
		
		NSLog(@"ERROR");
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:NSLocalizedString(@"OK", @"Main Window")];
		[alert setMessageText:NSLocalizedString(@"Cannot save files.", @"Main Window")];
		[alert setInformativeText:NSLocalizedString(@"Destination doesn't exist. Please select another directory.", @"Main Window")];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:nil contextInfo:nil];
		
		return;
	}
	
	NSStringEncoding fromEncoding = [(Encoding *)[self.availableEncodings objectAtIndex:fromEncodingIndex] stringEncoding];
	NSStringEncoding toEncoding = [(Encoding *)[self.availableEncodings objectAtIndex:toEncodingIndex] stringEncoding];	
	
	[progressIndicator setMaxValue:[self.files count]];
	[progressIndicator setMinValue:0];
	[progressIndicator startAnimation:self];
	[progressIndicator setUsesThreadedAnimation:YES];
	self.converting = YES;
	
	BOOL allItemsConvertedSucceeded = YES;
	
	for (FileItem *item in self.files) {
		
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
	
	NSSound *completeSound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"complete" ofType:@"aif"] byReference:YES];
	[completeSound play];
	[completeSound release];
	
	if (!allItemsConvertedSucceeded) {
		NSLog(@"ERROR");
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:NSLocalizedString(@"OK", @"Main Window")];
		[alert setMessageText:NSLocalizedString(@"Failed to convert one or more files.", @"Main Window")];
		[alert setInformativeText:NSLocalizedString(@"Some files cannot be converted because output file already exists or original encoding is wrong.", @"Main Window")];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
	}
}

#pragma mark -
#pragma mark Window Life Cycle

- (void)awakeFromNib {
	[super awakeFromNib];
	
	// [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"en"] forKey:@"AppleLanguages"];
	
	// Retrieve all avaiable string encodings, and store them into self.availableEncodings.
	NSMutableArray *encodingsArray = [[NSMutableArray alloc] init];
	const NSStringEncoding *encodings = [NSString availableStringEncodings];
	double encoding;
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
	
	self.files = [[[NSMutableArray alloc] init] autorelease];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
        
	[files release];
	[availableEncodings release];
	[saveDestinationFolderPath release];
	[previewText release];
	[previewData release];
	
	[super dealloc];
}

@end