//
//  SourceListController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

#define kSidebarListSelectionDidChange      @"SidebarListSelectionDidChange"
#define kCurrentFolderChanged				@"CurrentFolderChanged"

@interface SidebarController : NSObjectController <PXSourceListDataSource, PXSourceListDelegate> {
    
    IBOutlet PXSourceList *sidebarList;
    NSMutableArray *sidebarItems;
}

@end
