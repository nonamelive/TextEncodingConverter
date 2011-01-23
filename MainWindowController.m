//
//  MainWindowController.m
//  TextEncodingConverter
//
//  Created by Kai on 1/19/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "MainWindowController.h"
#import "FileItem.h"
#import "FilesArrayController.h"
#import "SidebarController.h"

@interface MainWindowController ()

- (NSMutableArray *)generateFilesArrayWithDirectoryPath:(NSString *)path;

@end

@implementation MainWindowController

@synthesize files;

#pragma mark -
#pragma mark Window Life Cycle

- (void)awakeFromNib {
	[super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(sidebarListSelectionDidChange:) 
                                                 name:kSidebarListSelectionDidChange 
                                               object:nil];
	
	self.files = [self generateFilesArrayWithDirectoryPath:@"/"];
}

- (void)windowDidLoad {
	
}

- (void)sidebarListSelectionDidChange:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSString *path = [userInfo objectForKey:@"path"];
    
    self.files = [self generateFilesArrayWithDirectoryPath:path];
    
    [path release];
}

- (NSMutableArray *)generateFilesArrayWithDirectoryPath:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray *newFiles = [[[NSMutableArray alloc] initWithCapacity:[filesArray count]] autorelease];
    for (NSString *filename in filesArray) {
        
        if (![filename hasPrefix:@"."]) {
            
            FileItem *item = [[FileItem alloc] init];
            item.path = [path stringByAppendingPathComponent:filename];
            item.name = filename;
            item.icon = [[NSWorkspace sharedWorkspace] iconForFile:item.path];
            
            [newFiles addObject:item];
            [item release];
        }
    }
    
    return newFiles;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[files release];
	
	[super dealloc];
}

@end