//
//  FavoriteFileListHelper.h
//  TextEncodingConverter
//
//  Created by Kai on 1/23/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FavoriteFileListHelper : NSObject {
    
}

- (NSArray *)localMountedVolumes;
- (NSArray *)finderFavoritePlaces;

+ (id)sharedFavoriteFileListHelper;

@end
