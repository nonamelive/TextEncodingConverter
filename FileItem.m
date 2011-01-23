//
//  FileItem.m
//  TextEncodingConverter
//
//  Created by Kai on 1/22/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "FileItem.h"


@implementation FileItem

@synthesize name;
@synthesize path;
@synthesize icon;
@synthesize directory;
@synthesize invisible;

- (BOOL)isDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = NO;
    [fileManager fileExistsAtPath:path isDirectory:&result];
    return result;
}

- (BOOL)isInvisible {
	
	CFURLRef inURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, ![self isDirectory]);
	LSItemInfoRecord itemInfo;
	LSCopyItemInfoForURL(inURL, kLSRequestAllFlags, &itemInfo);
	
	BOOL isInvisible = itemInfo.flags & kLSItemInfoIsInvisible;
	return (isInvisible != 0);
}

- (void)dealloc {
	[name release];
	[path  release];
	[icon release];
	[super dealloc];
}

@end
