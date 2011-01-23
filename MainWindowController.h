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
    
    NSMutableArray *selectedFiles;
	
	IBOutlet BWSheetController *sheetController;
}

@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, retain) NSMutableArray *selectedFiles;

- (IBAction)convertToolButtonClicked:(id)sender;

@end
