//
//  PathMenuItem.m
//  TextEncodingConverter
//
//  Created by Kai on 1/25/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "PathMenuItem.h"

#define kMenuItemImageSize CGSizeMake(16, 16)

@implementation PathMenuItem

@synthesize path;

- (void)setPath:(NSString *)aPath {
	
    if (path != aPath) {
        [path release];
        path = [aPath copy];
		
		self.title = [[NSFileManager defaultManager] displayNameAtPath:path];
		
		NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
		[icon setSize:kMenuItemImageSize];
        self.image = icon;
    }
}

- (void)dealloc {
    // Clean-up code here.
    
    [path release];
    
    [super dealloc];
}

@end
