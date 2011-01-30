//
//  NSStringEncodingSniffer.h
//  GBK2UTF8
//
//  Created by Kai on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStringEncodingSniffer : NSObject {
	
}

+ (NSArray *)sniffData:(NSData *)inString;

@end
