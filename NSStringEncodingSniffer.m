//
//  NSStringEncodingSniffer.m
//  GBK2UTF8
//
//  Created by Kai on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSStringEncodingSniffer.h"
#import <CoreServices/CoreServices.h>

static ItemCount _numEncoding = 0;
static BOOL _inited = NO;
static TextEncoding	*_availableEncodings = NULL;
static TECSnifferObjectRef _encodingSniffer = NULL;
static ItemCount *_numErrsArray = NULL;
static ItemCount *_numFeaturesArray = NULL;

static void _initSniffer(void) {
	OSStatus error;

	error = TECCountAvailableSniffers(&_numEncoding);
	if (error == noErr) {
		_availableEncodings = (TextEncoding *)malloc(_numEncoding * sizeof(TextEncoding) );
		_numErrsArray = (ItemCount *)malloc( _numEncoding * sizeof(ItemCount) );
		_numFeaturesArray = (ItemCount *)malloc( _numEncoding * sizeof(ItemCount) );

		error = TECGetAvailableSniffers(_availableEncodings, _numEncoding, &_numEncoding);
		if (error == noErr)
			error = TECCreateSniffer(&_encodingSniffer, _availableEncodings, _numEncoding);
	}
	_inited = (error == noErr);
}

@implementation NSStringEncodingSniffer

+ (NSArray *)sniffData:(NSData *)inString {
	OSStatus error;
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:_numEncoding];

	if (!_inited) {
		_initSniffer();
	}
	if (_encodingSniffer != NULL) {
		TextEncoding *availableEncodings = NULL;

		availableEncodings = (TextEncoding *)malloc(_numEncoding * sizeof(TextEncoding));
		if (availableEncodings != NULL) {
			memcpy(availableEncodings, _availableEncodings, _numEncoding * sizeof(TextEncoding));

			error = TECSniffTextEncoding(_encodingSniffer, (TextPtr)[inString bytes],
			                             (ByteCount)[inString length], availableEncodings, _numEncoding, _numErrsArray,
			                             _numEncoding, _numFeaturesArray, _numEncoding);
			if (error == noErr) {
				int i = 0;
				while ((i < _numEncoding) && (_numErrsArray[i] == 0)) {
					[result addObject:[NSNumber numberWithInt:availableEncodings[i]]];
					++i;
				}
			}
			free(availableEncodings);
		}
	}

	return [NSArray arrayWithArray:result];
}

@end