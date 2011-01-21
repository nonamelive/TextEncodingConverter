//
//  MainWindowController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "MainWindowController.h"
#import "SourceListItem.h"

@implementation MainWindowController

#pragma mark -
#pragma mark Source List Items Creation

- (SourceListItem *)devicesListItem {
	SourceListItem *devicesItem = [SourceListItem itemWithTitle:@"Devices" identifier:@"devices"];
	NSMutableArray *devices = [[[NSMutableArray alloc] init] autorelease];
	NSArray *mountedVols = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:[NSArray arrayWithObjects:NSURLNameKey, nil] options:NSVolumeEnumerationSkipHiddenVolumes];
	if ([mountedVols count] > 0) {
		for (NSURL *element in mountedVols) {
			NSString *path = [element path];
			NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:path];
			SourceListItem *item = [SourceListItem itemWithTitle:displayName identifier:path];
			[item setIcon:[[NSWorkspace sharedWorkspace] iconForFile:path]];
			[devices addObject:item];
		}
	}
	[devicesItem setChildren:devices];

	return devicesItem;
}

- (NSString *)pathForDirectory:(NSSearchPathDirectory)pathDirectory {
	NSArray *array = NSSearchPathForDirectoriesInDomains(pathDirectory, NSUserDomainMask, YES);
	if ([array count] > 0) {
		return [array objectAtIndex:0];
	}

	return nil;
}

- (SourceListItem *)placesListItems {
	SourceListItem *placesItem = [SourceListItem itemWithTitle:@"Places" identifier:@"places"];

	NSSearchPathDirectory pathDirectories[6] = {
		0,
		NSDesktopDirectory,
		NSDocumentDirectory,
		NSDownloadsDirectory,
		NSMoviesDirectory,
		NSLibraryDirectory,
	};

	NSArray *icons = [NSArray arrayWithObjects:@"", @"desktop.png", @"documents.png", @"downloads.png", @"movies.png", @"library.png", nil];
	NSMutableArray *places = [[NSMutableArray alloc] initWithCapacity:6];
	for (int i = 0; i < 6; i++) {
		NSString *path = [self pathForDirectory:pathDirectories[i]];
		if (i == 0) {
			path = NSHomeDirectory();
		}
		NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:path];
		SourceListItem *item = [SourceListItem itemWithTitle:displayName identifier:path];

		NSString *iconName = [icons objectAtIndex:i];
		if (iconName && ![iconName isEqualToString:@""]) {
			[item setIcon:[NSImage imageNamed:iconName]];
		} else {
			[item setIcon:[[NSWorkspace sharedWorkspace] iconForFile:path]];
		}

		[places addObject:item];
	}
	[placesItem setChildren:places];
	[places release];

	return placesItem;
}

- (void)createSourceList {
	sourceListItems = [[NSMutableArray alloc] init];

	[sourceListItems addObject:[self devicesListItem]];
	[sourceListItems addObject:[self placesListItems]];

	[sourceList reloadData];

	for (SourceListItem *item in sourceListItems) {
		[sourceList expandItem:item];
	}
}

- (void)recreateSourceList {
	NSString *selectedIdentifier = [[NSString alloc] initWithString:[[sourceList itemAtRow:[sourceList selectedRow]] identifier]];

	if (sourceListItems) {
		[sourceListItems release];
	}

	[self createSourceList];

	for (SourceListItem *groupItem in sourceListItems) {
		for (SourceListItem *item in groupItem.children) {
			if ([item.identifier isEqualToString:selectedIdentifier]) {
				int row = [sourceList rowForItem:item];
				[sourceList selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
			}
		}
	}
	
	[selectedIdentifier release];
}

- (void)volumeChanged:(NSNotification *)notification {
	[self recreateSourceList];
}

#pragma mark -
#pragma mark Window Life Cycle

- (void)windowDidLoad {
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
	                                                       selector:@selector(volumeChanged:)
	                                                           name:NSWorkspaceDidMountNotification
	                                                         object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
	                                                       selector:@selector(volumeChanged:)
	                                                           name:NSWorkspaceDidUnmountNotification
	                                                         object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
	                                                       selector:@selector(volumeChanged:)
	                                                           name:NSWorkspaceDidRenameVolumeNotification
	                                                         object:nil];

	[self createSourceList];
}

- (void)dealloc {
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

	[sourceListItems release];

	[super dealloc];
}

#pragma mark -
#pragma mark Source List Data Source Methods

- (NSUInteger)sourceList:(PXSourceList *)sourceList numberOfChildrenOfItem:(id)item {
	// Works the same way as the NSOutlineView data source: 'nil' means a parent item.
	if (item == nil) {
		return [sourceListItems count];
	} else {
		return [[item children] count];
	}
}

- (id)sourceList:(PXSourceList *)aSourceList child:(NSUInteger)index ofItem:(id)item {
	// Works the same way as the NSOutlineView data source: 'nil' means a parent item.
	if (item == nil) {
		return [sourceListItems objectAtIndex:index];
	} else {
		return [[item children] objectAtIndex:index];
	}
}

- (id)sourceList:(PXSourceList *)aSourceList objectValueForItem:(id)item {
	return [item title];
}

- (void)sourceList:(PXSourceList *)aSourceList setObjectValue:(id)object forItem:(id)item {
	[item setTitle:object];
}

- (BOOL)sourceList:(PXSourceList *)aSourceList isItemExpandable:(id)item {
	return [item hasChildren];
}

- (BOOL)sourceList:(PXSourceList *)aSourceList itemHasBadge:(id)item {
	return [item hasBadge];
}

- (NSInteger)sourceList:(PXSourceList *)aSourceList badgeValueForItem:(id)item {
	return [item badgeValue];
}

- (BOOL)sourceList:(PXSourceList *)aSourceList itemHasIcon:(id)item {
	return [item hasIcon];
}

- (NSImage *)sourceList:(PXSourceList *)aSourceList iconForItem:(id)item {
	return [item icon];
}

- (NSMenu *)sourceList:(PXSourceList *)aSourceList menuForEvent:(NSEvent *)theEvent item:(id)item {
	if ( [theEvent type] == NSRightMouseDown || ([theEvent type] == NSLeftMouseDown && ([theEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask) ) {
		NSMenu *m = [[NSMenu alloc] init];
		if (item != nil) {
			[m addItemWithTitle:[item title] action:nil keyEquivalent:@""];
		} else {
			[m addItemWithTitle:@"clicked outside" action:nil keyEquivalent:@""];
		}
		return [m autorelease];
	}
	return nil;
}

#pragma mark -
#pragma mark Source List Delegate Methods

- (BOOL)sourceList:(PXSourceList *)aSourceList isGroupAlwaysExpanded:(id)group {
	return NO;
}

- (BOOL)sourceList:(PXSourceList *)aSourceList shouldExpandItem:(id)item {
	return YES;
}

- (BOOL)sourceList:(PXSourceList *)aSourceList shouldEditItem:(id)item {
	return NO;
}

- (void)sourceListSelectionDidChange:(NSNotification *)notification {
	NSUInteger row = [sourceList selectedRow];
	NSLog(@"%u", row);
}

- (void)sourceListDeleteKeyPressedOnRows:(NSNotification *)notification {
	NSIndexSet *rows = [[notification userInfo] objectForKey:@"rows"];

	NSLog(@"Delete key pressed on rows %@", rows);

	// Do something here
}

@end