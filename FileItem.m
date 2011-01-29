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
@synthesize convertedFilename;
@synthesize status;
@synthesize statusIcon;
@synthesize directory;
@synthesize invisible;

- (void)setStatus:(FileItemStatus)aStatus {
	
	status = aStatus;
	
	switch (status) {
		case kFileItemStatusWaiting:
			self.statusIcon = [NSImage imageNamed:@"waiting.png"];
			break;
		case kFileItemStatusConverting:
			self.statusIcon = [NSImage imageNamed:@"converting.png"];
			break;
		case kFileItemStatusSucceeded:
			self.statusIcon = [NSImage imageNamed:@"succeeded.png"];
			break;
		case kFileItemStatusFailed:
			self.statusIcon = [NSImage imageNamed:@"failed.png"];
			break;
		default:
			break;
	}
}

- (void)setPath:(NSString *)aPath {
	
	if (path != aPath) {
        [path release];
        path = [aPath retain];
		
		self.name = [path lastPathComponent];
		self.icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
		
		// Generate the new filename. e.g. nonamelive.txt -> nonamelive.converted.txt
		NSString *newFilename = [self.name stringByDeletingPathExtension];
		newFilename = [newFilename stringByAppendingPathExtension:@"converted"];
		newFilename = [newFilename stringByAppendingPathExtension:[self.name pathExtension]];
		self.convertedFilename = newFilename;
		
		self.status = kFileItemStatusWaiting;
    }
}

- (BOOL)isDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = NO;
    [fileManager fileExistsAtPath:path isDirectory:&result];
    return result;
}

- (BOOL)isInvisible {
	
	if ([[[NSWorkspace sharedWorkspace] mountedLocalVolumePaths] containsObject:path]) {
		return YES;
	}
	
	CFURLRef inURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, ![self isDirectory]);
	LSItemInfoRecord itemInfo;
	LSCopyItemInfoForURL(inURL, kLSRequestAllFlags, &itemInfo);
	
	BOOL isInvisible = itemInfo.flags & kLSItemInfoIsInvisible;
	
	CFRelease(inURL);
	
	return (isInvisible != 0);
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToFileItem:other];
}

- (BOOL)isEqualToFileItem:(FileItem *)anItem {
    if (self == anItem)
        return YES;
    if (![(id)[self path] isEqual:[anItem path]])
        return NO;

    return YES;
}

- (void)dealloc {
	[name release];
	[path release];
	[icon release];
	[convertedFilename release];
	[statusIcon release];
	[super dealloc];
}

@end
