//
//  FileItem.h
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kFileItemStatusWaiting = 0,
	kFileItemStatusConverting,
	kFileItemStatusSucceeded,
	kFileItemStatusFailed,
} FileItemStatus;

@interface FileItem : NSObject {

	NSString *name;
	NSString *path;
	NSImage *icon;
	NSString *convertedFilename;
	
	FileItemStatus status;
	NSImage *statusIcon;
    
    BOOL directory;
	BOOL invisible;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, retain) NSImage *icon;
@property (nonatomic, retain) NSString *convertedFilename;

@property (nonatomic, assign) FileItemStatus status;
@property (nonatomic, retain) NSImage *statusIcon;

@property (nonatomic, readonly, getter=isDirectory) BOOL directory;
@property (nonatomic, readonly, getter=isInvisible) BOOL invisible;

- (BOOL)isEqualToFileItem:(FileItem *)anItem;

@end
