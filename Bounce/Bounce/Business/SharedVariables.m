//
//  SharedVariables.m
//  bounce
//
//  Created by Steven on 8/11/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SharedVariables.h"

@implementation SharedVariables

static bool _shouldNotOpenRequestsView = NO;

+(BOOL)shouldNotOpenRequestsView;{
    return _shouldNotOpenRequestsView;
}

+(void)setShouldNotOpenRequestsView:(BOOL)shouldNotOpenRequestsView {
        _shouldNotOpenRequestsView = shouldNotOpenRequestsView;
    }

@end
