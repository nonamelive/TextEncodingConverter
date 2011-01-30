//
//  EncodingsArrayController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/30/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEncodingTableViewSelectionChange		@"EncodingTableViewSelectionChange"

@class Encoding;

@interface EncodingsArrayController : NSArrayController <NSTableViewDelegate, NSTableViewDataSource> {
	
	IBOutlet NSTableView *tableView;
	Encoding *lastEncoding;
}

@property (nonatomic, retain) Encoding *lastEncoding;

@end
