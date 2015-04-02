//
//  Constants.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#ifndef bounce_Constants_h
#define bounce_Constants_h

#pragma mark - General Constants
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6PLUS ([[UIScreen mainScreen] bounds].size.height == 736)


// Parse Request class
#define PF_REQUET_CLASS_NAME @"Requests"
#define PF_REQUEST_TIME_ALLOCATED @"TimeAllocated"
#define PF_REQUEST_TIME @"TimeAllocated"
#define PF_REQUEST_SELECTED_GROUPS @"RequestedGroups"
#define PF_REQUEST_RADIUS @"Radius"
#define PF_REQUEST_RECEIVER @"receivers"
#define PF_REQUEST_SENDER @"Sender"
#define PF_REQUEST_GROUPS_RELATION @"RequestGroups"
#define PF_REQUEST_RECEIVERS_RELATION @"RequestReceivers"
#define PF_REQUEST_LOCATION @"Location"
#define PF_REQUEST_IS_ENDED @"isEnded"
// save end date instead save the timee allocate 
#define PF_REQUEST_END_DATE @"EndDate"
#define PF_REQUEST_GENDER @"gender";


//
#define DISTANCE_MESSAGE @"%.1f miles away"

#define SIDE_MENU_WIDTH (IS_IPHONE? 225:375)

#define OBJECT_ID @"objectId"
#define PF_GENDER @"Gender"
// Home screen
#define REQUEST_TIME_LEFT_STRING @"%ld minute left"

// Gender cases
#define ALL_GENDER @"All"
#define MALE_GENDER @"Male"
#define FEMALE_GENDER @"Female"


#endif
