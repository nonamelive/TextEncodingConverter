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
@class PathPopupButton;

@interface MainWindowController : NSWindowController {
    
	NSString *currentPath;
	NSMutableArray *files;
	IBOutlet NSTableView *filesTableView;
	IBOutlet FilesArrayController *filesArrayController;
    
    NSMutableArray *selectedFiles;
	
	IBOutlet NSSegmentedControl *backForwardSegementedControl;
	IBOutlet PathPopupButton *pathPopupButton;
	
	IBOutlet NSProgressIndicator *progressIndicator;
	NSMutableArray *availableEncodings;
	int fromEncodingIndex;
	int toEncodingIndex;
	BOOL overwriting;
	NSString *saveDestinationFolderPath;
	
	BOOL converting;
	
	IBOutlet BWSheetController *sheetController;
}

@property (nonatomic, retain) NSString *currentPath;
@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, retain) NSMutableArray *selectedFiles;
@property (nonatomic, retain) NSMutableArray *availableEncodings;
@property (nonatomic, assign) int fromEncodingIndex;
@property (nonatomic, assign) int toEncodingIndex;
@property (nonatomic, retain) NSString *saveDestinationFolderPath;
@property (nonatomic, assign, getter=isConverting) BOOL converting;
@property (nonatomic, assign, getter=isOverwriting) BOOL overwriting;

@property (nonatomic, assign) IBOutlet NSPathControl *pathControl;

- (IBAction)backForwardSegementedControlClicked:(id)sender;
- (IBAction)convertToolButtonClicked:(id)sender;
- (IBAction)pathPopupButtonClicked:(id)sender;
- (IBAction)refreshMenuItemClicked:(id)sender;

- (IBAction)clearSucceededFilesMenuItemClicked:(id)sender;
- (IBAction)convertButtonClicked:(id)sender;
- (IBAction)selectDestinationFolderButtonClicked:(id)sender;

@end
