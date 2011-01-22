//
//  FavoriteFileListHelper.m
//  TextEncodingConverter
//
//  Created by Kai on 1/23/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "FavoriteFileListHelper.h"

static FavoriteFileListHelper *sharedInstance = nil;

@implementation FavoriteFileListHelper

- (NSArray *)localMountedVolumes {
    
    /* 10.5 provides ability to retrieve Finder favorite places */
    
    NSMutableArray *volumes = [[[NSMutableArray alloc] init] autorelease];
    
    UInt32 seed;
    OSErr err = noErr;
    CFArrayRef pathsArray;
    LSSharedFileListRef list;
    LSSharedFileListItemRef itemRef;
    CFIndex i, pathsCount;
    CFURLRef cfURL = NULL;
    CFStringRef pathString = NULL;
    
    /* Get local mounted volumes */
    list = LSSharedFileListCreate(NULL, kLSSharedFileListFavoriteVolumes, NULL);
    pathsArray = LSSharedFileListCopySnapshot(list, &seed);
    pathsCount = CFArrayGetCount(pathsArray);
    
    for (i = 0; i < pathsCount; i++) {
        
        itemRef = (LSSharedFileListItemRef)CFArrayGetValueAtIndex(pathsArray, i);
        
        err = LSSharedFileListItemResolve(itemRef, 
                                          kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, 
                                          &cfURL, 
                                          NULL);
        if (err != noErr)
            continue;
        
        pathString = CFURLCopyFileSystemPath(cfURL, kCFURLPOSIXPathStyle);
        if (pathString) {
            NSString *path = [[NSString alloc] initWithString:(NSString *)pathString];
            [volumes addObject:path];
            [path release];
        }
        
        CFRelease(pathString);
        CFRelease(cfURL);
    }
    
    CFRelease(pathsArray);
    CFRelease(list);
    
    return (NSArray *)volumes;
}

- (NSArray *)finderFavoritePlaces {
    
    /* 10.5 provides ability to retrieve Finder favorite places */
    
    NSMutableArray *places = [[[NSMutableArray alloc] init] autorelease];
    
    UInt32 seed;
    OSErr err = noErr;
    CFArrayRef pathsArray;
    LSSharedFileListRef list;
    LSSharedFileListItemRef itemRef;
    CFIndex i, pathsCount;
    CFURLRef cfURL = NULL;
    CFStringRef pathString = NULL;
    
    /* Get user favorite places */
    list = LSSharedFileListCreate(NULL, kLSSharedFileListFavoriteItems, NULL);
    pathsArray = LSSharedFileListCopySnapshot(list, &seed);
    pathsCount = CFArrayGetCount(pathsArray);
    
    for (i = 0; i < pathsCount; i++) {
        itemRef = (LSSharedFileListItemRef)CFArrayGetValueAtIndex(pathsArray, i);
        
        err = LSSharedFileListItemResolve(itemRef, 
                                          kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes, 
                                          &cfURL, NULL);
        if (err != noErr)
            continue;
        
        pathString = CFURLCopyFileSystemPath(cfURL, kCFURLPOSIXPathStyle);
        if (pathString) {
            NSString *path = [[NSString alloc] initWithString:(NSString *)pathString];
            [places addObject:path];
            [path release];
        }
        
        CFRelease(pathString);
        CFRelease(cfURL);
    }
    
    CFRelease(pathsArray);
    CFRelease(list);
    
    return (NSArray *)places;
}

#pragma -
#pragma Singleton Methods

+ (void)initialize {
    if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];
}

+ (id)sharedFavoriteFileListHelper {
    // Already set by +initialize.
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone*)zone {
    // Usually already set by +initialize.
    @synchronized(self) {
        if (sharedInstance) {
            // The caller expects to receive a new object, so implicitly retain it
            // to balance out the eventual release message.
            return [sharedInstance retain];
        } else {
            // When not already set, +initialize is our caller.
            // It's creating the shared instance, let this go through.
            return [super allocWithZone:zone];
        }
    }
}

- (id)init {
    // If sharedInstance is nil, +initialize is our caller, so initialize the instance.
    // If it is not nil, simply return the instance without re-initializing it.
    if (sharedInstance == nil) {
        self = [super init];
        if (self) {
            // Initialize the instance here.
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX; // denotes an object that cannot be released
}

- (void)release {
    // do nothing 
}

- (id)autorelease {
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

@end
