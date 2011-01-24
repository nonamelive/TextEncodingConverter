//
//  Encoding.m
//  TextEncodingConverter
//
//  Created by Kai on 1/23/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "Encoding.h"


@implementation Encoding

@synthesize localizedName;
@synthesize stringEncoding;


- (void)dealloc {
	
	[localizedName release];
	[super dealloc];
}

@end
