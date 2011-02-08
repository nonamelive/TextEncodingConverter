//
//  MainWindowController.h
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FilesArrayController;
@class EncodingsArrayController;

@interface MainWindowController : NSWindowController {
    
	IBOutlet FilesArrayController *filesArrayController;
	IBOutlet NSProgressIndicator *progressIndicator;
	
	NSMutableArray *files;
	NSMutableArray *availableEncodings;
	int fromEncodingIndex;
	int toEncodingIndex;
	BOOL overwriting;
	BOOL backupOriginalFiles;
	NSString *saveDestinationFolderPath;
	
	BOOL converting;
	
	// Preview Window.
	IBOutlet EncodingsArrayController *encodingsArrayController;
	IBOutlet NSWindow *previewWindow;
	NSString *previewText;
	NSData *previewData;
}

@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, retain) NSMutableArray *availableEncodings;
@property (nonatomic, assign) int fromEncodingIndex;
@property (nonatomic, assign) int toEncodingIndex;
@property (nonatomic, retain) NSString *saveDestinationFolderPath;
@property (nonatomic, assign, getter=isConverting) BOOL converting;
@property (nonatomic, assign, getter=isOverwriting) BOOL overwriting;
@property (nonatomic, assign, getter=isBackupOriginalFiles) BOOL backupOriginalFiles;

@property (nonatomic, retain) NSString *previewText;
@property (nonatomic, retain) NSData *previewData;

- (IBAction)backupOriginalFilesButtonClicked:(id)sender;
- (IBAction)convertButtonClicked:(id)sender;
- (IBAction)selectDestinationFolderButtonClicked:(id)sender;
- (IBAction)guessEncodingButtonClicked:(id)sender;
- (IBAction)showInFinderButtonClicked:(id)sender;

- (IBAction)applyButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
