//
//  RequestManger.h
//  ChattingApp
//
//  Created by Shimaa Essam on 3/29/15.
//  Copyright (c) 2015 Shimaa Essam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestManger : NSObject

+ (RequestManger*) getInstance;
- (void) createrequestToGroups:(NSArray *) selectedGroups andGender:(NSString *)gender  withinTime:(NSInteger)timeAllocated andInRadius:(NSInteger) radius;
@end
