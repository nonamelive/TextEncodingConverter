//
//  FileItem.h
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileItem : NSObject {

	NSString *name;
	NSString *path;
	NSImage *icon;
    
    BOOL directory;
	BOOL invisible;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, retain) NSImage *icon;

@property (nonatomic, readonly, getter=isDirectory) BOOL directory;
@property (nonatomic, readonly, getter=isInvisible) BOOL invisible;

@end