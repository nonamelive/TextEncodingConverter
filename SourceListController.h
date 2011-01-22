//
//  SourceListController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PXSourceList.h"

@interface SourceListController : NSObjectController <PXSourceListDataSource, PXSourceListDelegate> {
    
    IBOutlet PXSourceList *sourceList;
    NSMutableArray *sourceListItems;
}

@property (nonatomic, assign) PXSourceList *sourceList;

@end
