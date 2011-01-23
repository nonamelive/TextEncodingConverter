//
//  SourceListController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "SidebarController.h"
#import "SidebarItem.h"
#import "FavoriteFileListHelper.h"

@interface SidebarController ()

- (void)createSourceList;

@end

@implementation SidebarController

#pragma mark -
#pragma mark Controller Life Cycle

- (void)awakeFromNib {
	
    [super awakeFromNib];
    
	[self createSourceList];
	
	if ((self = [super init])) {
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
    }
}

#pragma mark -
#pragma mark Source List Items Creation

- (SidebarItem *)devicesListItem {
    
	SidebarItem *devicesItem = [SidebarItem itemWithTitle:@"Devices" identifier:@"devices"];
	NSMutableArray *devices = [[NSMutableArray alloc] init];
    
    NSArray *volumesArray = [[[FavoriteFileListHelper sharedFavoriteFileListHelper] localMountedVolumes] retain];
    for (NSString *path in volumesArray) {
        NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:path];
        SidebarItem *item = [SidebarItem itemWithTitle:displayName identifier:path];
        [item setIcon:[[NSWorkspace sharedWorkspace] iconForFile:path]];
        [devices addObject:item];
    }
    
	[devicesItem setChildren:devices];
    [devices release];
    [volumesArray release];
    
	return devicesItem;
}

- (SidebarItem *)placesListItems {
    
	SidebarItem *placesItem = [SidebarItem itemWithTitle:@"Places" identifier:@"places"];
	NSMutableArray *places = [[NSMutableArray alloc] init];

    NSArray *placesArray = [[[FavoriteFileListHelper sharedFavoriteFileListHelper] finderFavoritePlaces] retain];
    for (NSString *path in placesArray) {
        NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:path];
        SidebarItem *item = [SidebarItem itemWithTitle:displayName identifier:path];
        [item setIcon:[[NSWorkspace sharedWorkspace] iconForFile:path]];
        [places addObject:item];
    }
    
	[placesItem setChildren:places];
	[places release];
    [placesArray release];
    
	return placesItem;
}

- (void)createSourceList {
	sidebarItems = [[NSMutableArray alloc] init];
	
	[sidebarItems addObject:[self devicesListItem]];
	[sidebarItems addObject:[self placesListItems]];
    
	[sidebarList reloadData];
    
	for (SidebarItem *item in sidebarItems) {
		[sidebarList expandItem:item];
	}
}

- (void)recreateSourceList {
	NSString *selectedIdentifier = [[NSString alloc] initWithString:[[sidebarList itemAtRow:[sidebarList selectedRow]] identifier]];
    
	if (sidebarItems) {
		[sidebarItems release];
	}
    
	[self createSourceList];
    
	for (SidebarItem *groupItem in sidebarItems) {
		for (SidebarItem *item in groupItem.children) {
			if ([item.identifier isEqualToString:selectedIdentifier]) {
				int row = [sidebarList rowForItem:item];
				[sidebarList selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
			}
		}
	}
	
	[selectedIdentifier release];
}

- (void)volumeChanged:(NSNotification *)notification {
	[self recreateSourceList];
}

#pragma mark -
#pragma mark Source List Data Source Methods

- (NSUInteger)sourceList:(PXSourceList *)sourceList numberOfChildrenOfItem:(id)item {
	// Works the same way as the NSOutlineView data source: 'nil' means a parent item.
	if (item == nil) {
		return [sidebarItems count];
	} else {
		return [[item children] count];
	}
}

- (id)sourceList:(PXSourceList *)aSourceList child:(NSUInteger)index ofItem:(id)item {
	// Works the same way as the NSOutlineView data source: 'nil' means a parent item.
	if (item == nil) {
		return [sidebarItems objectAtIndex:index];
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
	NSUInteger row = [sidebarList selectedRow];
    NSString *path = [[[sidebarList itemAtRow:row] identifier] copy];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:path forKey:@"path"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSidebarListSelectionDidChange object:nil userInfo:userInfo];
}

- (void)sourceListDeleteKeyPressedOnRows:(NSNotification *)notification {
	NSIndexSet *rows = [[notification userInfo] objectForKey:@"rows"];
    
	NSLog(@"Delete key pressed on rows %@", rows);
    
	// Do something here
}

#pragma -
#pragma Memory Management

- (void)dealloc {
    // Clean-up code here.
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [sidebarItems release];
    
    [super dealloc];
}

@end
