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
    
    /*
    // Get the defaults as an NSDictionary
    NSDictionary *sidebarListsPlist = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.sidebarlists"];
    NSArray *array = [[sidebarListsPlist objectForKey:@"useritems"] objectForKey:@"CustomListItems"];
    NSDictionary *dict = [array objectAtIndex:4];
    NSData *icon = [dict objectForKey:@"Icon"];
    
    NSDictionary *iconDict = [NSKeyedUnarchiver unarchiveObjectWithData:icon];
    NSLog(@"%@", iconDict);
    
    //NSString *string = [[NSString alloc] initWithData:icon encoding:NSASCIIStringEncoding];
    NSImage *image = [[NSImage alloc] initWithData:icon];
    
    return;
	*/
    
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
