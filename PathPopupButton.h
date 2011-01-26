//
//  PathPopupButton.h
//  TextEncodingConverter
//
//  Created by Kai on 1/25/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PathPopupButton : NSPopUpButton {
    
    NSString *path;
}

@property (nonatomic, copy) NSString *path;

@end
