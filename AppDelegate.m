//
//  TextEncodingConverterAppDelegate.m
//  TextEncodingConverter
//
//  Created by Kai on 1/18/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    
	windowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	[windowController showWindow:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)dealloc {
	
	[windowController release];
	[super dealloc];
}

@end
