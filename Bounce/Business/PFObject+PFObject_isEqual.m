//
//  PFObject+PFObject_isEqual.m
//  bounce
//
//  Created by Shimaa Essam on 4/15/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "PFObject+PFObject_isEqual.h"

@implementation PFObject (PFObject_isEqual)

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[PFObject class]])
    {
        PFObject* pfObject = object;
        return [self.objectId isEqualToString:pfObject.objectId];
    }
    
    return NO;
}

@end
