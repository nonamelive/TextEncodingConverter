//
//  Encoding.h
//  TextEncodingConverter
//
//  Created by Kai on 1/23/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Encoding : NSObject {
	
	NSString *localizedName;
	NSStringEncoding stringEncoding;
}

@property (nonatomic, copy) NSString *localizedName;
@property (nonatomic, assign) NSStringEncoding stringEncoding;

@end
