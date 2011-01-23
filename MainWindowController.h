//
//  MainWindowController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FilesArrayController;
@class BWSheetController;

@interface MainWindowController : NSWindowController {
    
	NSMutableArray *files;
	IBOutlet NSTableView *filesTableView;
	IBOutlet FilesArrayController *filesArrayController;
	
	IBOutlet BWSheetController *sheetController;
}

@property (nonatomic, retain) NSMutableArray *files;

- (IBAction)convertToolButtonClicked:(id)sender;

@end
