//
//  SharedVariables.h
//  bounce
//
//  Created by Steven on 8/11/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedVariables : NSObject

+(bool)shouldNotOpenRequestsView;
+(void)setShouldNotOpenRequestsView:(BOOL)shouldNotOpenRequestsView;

@end