//
//  TouchView.m
//  TextEncodingConverter
//
//  Created by Kai on 1/24/11.
//  Copyright 2011 NONAME STUDIO. All rights reserved.
//

#import "TouchView.h"


@implementation TouchView

- (void)swipeWithEvent:(NSEvent *)event {
	
	if ([event deltaX] != 0) {
		if ([event deltaX] > 0)
			[[NSNotificationCenter defaultCenter] postNotificationName:kSwipeGestureLeft object:nil];
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:kSwipeGestureRight object:nil];;
	} else if ([event deltaY] != 0) {
		if ([event deltaY] > 0)
			[[NSNotificationCenter defaultCenter] postNotificationName:kSwipeGestureUp object:nil];
		else
			[[NSNotificationCenter defaultCenter] postNotificationName:kSwipeGestureDown object:nil];
	}
}

@end
