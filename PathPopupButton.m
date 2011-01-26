//
//  PathPopupButton.m
//  TextEncodingConverter
//
//  Created by Kai on 1/25/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "PathPopupButton.h"
#import "PathMenuItem.h"

@implementation PathPopupButton

@synthesize path;

- (id)init {
	
	if ((self = [super init])) {
		self.path = @"";
	}
	
	return self;
}

- (void)awakeFromNib {
	
	[super awakeFromNib];
		
	self.path = @"";
}

- (void)setPath:(NSString *)aPath {
	
    if (path != aPath) {
        [path release];
        path = [aPath copy];
		
		[self.menu removeAllItems];
		
		if (!path || [path isEqualToString:@""]) {
			return;
		}
		
        NSURL *url = [NSURL fileURLWithPath:path];
        NSMutableArray *pathComponents = [[url pathComponents] mutableCopy];
		
		// Add an empty menu item to be the placeholder.
		NSMenuItem *emptyMenuItem = [[NSMenuItem alloc] init];
		emptyMenuItem.title = @"";
		emptyMenuItem.image = [NSImage imageNamed:NSImageNamePathTemplate];
		[self.menu addItem:emptyMenuItem];
        [emptyMenuItem release];
		
		// Iterate path components to add subfolders.
		do {
            PathMenuItem *menuItem = [[PathMenuItem alloc] init];
            menuItem.path = [NSString pathWithComponents:pathComponents];
            [self.menu addItem:menuItem];
			[menuItem release];
            
            [pathComponents removeLastObject];
        } while ([pathComponents count] > 0);
		
        [pathComponents release];
    }
}

- (void)dealloc {
    // Clean-up code here.
    	
    [path release];
    [super dealloc];
}

@end
