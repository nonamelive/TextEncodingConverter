//
//  MainWindowController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@interface MainWindowController : NSWindowController <PXSourceListDataSource, PXSourceListDelegate> {

	IBOutlet PXSourceList *sourceList;
	
	NSMutableArray *sourceListItems;
}

@end
