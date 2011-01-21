//
//  AppDelegate.h
//  TextEncodingConverter
//
//  Created by Kai on 1/18/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
	NSWindow *window;
	MainWindowController *windowController;
}

@property (assign) IBOutlet NSWindow *window;

@end
