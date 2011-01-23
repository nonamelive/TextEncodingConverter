//
//  MainWindowController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController {
    
	NSMutableArray *files;
	IBOutlet NSTableView *filesTableView;
}

@property (nonatomic, retain) NSMutableArray *files;

@end
