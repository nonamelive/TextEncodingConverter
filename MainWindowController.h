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
    
	NSURL *currentPath;
	NSMutableArray *files;
	IBOutlet NSTableView *filesTableView;
	IBOutlet FilesArrayController *filesArrayController;
    
    NSMutableArray *selectedFiles;
	
	NSMutableArray *availableEncodings;
	int fromEncodingIndex;
	int toEncodingIndex;
	
	IBOutlet BWSheetController *sheetController;
}

@property (nonatomic, retain) NSURL *currentPath;
@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, retain) NSMutableArray *selectedFiles;
@property (nonatomic, retain) NSMutableArray *availableEncodings;
@property (nonatomic, assign) int fromEncodingIndex;
@property (nonatomic, assign) int toEncodingIndex;

- (IBAction)convertToolButtonClicked:(id)sender;
- (IBAction)convertButtonClicked:(id)sender;
- (IBAction)pathControlClicked:(id)sender;

@end
