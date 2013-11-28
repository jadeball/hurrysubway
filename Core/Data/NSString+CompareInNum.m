//
//  NSString+CompareInNum.m
//  CATest
//
//  Created by Liu Forest on 10-9-1.
//  Copyright 2010 Smilingmobile. All rights reserved.
//

#import "NSString+CompareInNum.h"


@implementation NSString (compareNumInString)

- (NSComparisonResult)compareNumInString:(NSString *)aString {
	return [self compare:aString options:NSNumericSearch];
}

@end
