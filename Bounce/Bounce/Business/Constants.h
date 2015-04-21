//
//  Constants.h
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#ifndef bounce_Constants_h
#define bounce_Constants_h

// Parse creadential
#define PARSE_APP_ID @"vVNUbdp3ci9MLKqNWJMFMYBQZ1tE8EjJ5DZBTCF7"
#define PARSE_CLIENT_KEY @"JvcX34MRd7rREhmtjFZrcU8mxqmRDFlbyC0yXzAv"

#pragma mark - General Constants
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

#define IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)
#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.height == 667)
#define IS_IPHONE6PLUS ([[UIScreen mainScreen] bounds].size.height == 736)
#define IS_IPAD ([[UIScreen mainScreen] bounds].size.height > 736)
// Colors
#define DEFAULT_COLOR       [UIColor colorWithRed:230.0/250.0 green:89.0/250.0 blue:89.0/250.0 alpha:1.0]
#define LIGHT_BLUE_COLOR    [UIColor colorWithRed:120.0/250.0 green:175.0/250.0 blue:212.0/250.0 alpha:1.0]
#define LIGHT_SELECT_GRAY_COLOR    [UIColor colorWithRed:224.0/255.0 green:224.0/255.0 blue:224.0/255.0 alpha:1.0f]

// Parse Request class
#define PF_REQUEST_CLASS_NAME @"Requests"
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
//#define DISTANCE_MESSAGE @"%.1f miles away"
#define DISTANCE_MESSAGE @"%.1f feets away"

#define SIDE_MENU_WIDTH (IS_IPHONE? 225:375)

#define OBJECT_ID @"objectId"
#define PF_GENDER @"Gender"
#define PF_CREATED_AT @"createdAt"
// Home screen
#define REQUEST_TIME_LEFT_STRING @"%i minute left"
#define REQUEST_TIME_REMAINING_STRING @"%i minute remaining"


// Gender cases
#define ALL_GENDER @"All"
#define MALE_GENDER @"male"
#define FEMALE_GENDER @"female"

// Group Privacy
#define PUBLIC_GROUP @"Public"
#define PRIVATE_GROUP @"Private"


//
#define COMMON_CORNER_WIDTH 3.0
// custom annotaion pin view
#define CUSTOM_ANNOTAION_OVERLAY_COLOR [[UIColor alloc] initWithRed:180/255.0 green:225./255.0 blue:232/255.0 alpha:.5]
#define INNER_VIEW_RADIUS 70
#define OUTER_VIEW_RADIUS 140
#define INNER_VIEW_ICON_RADIUS 50


//
#define FEET_IN_KILOMETER 3281

// Update chat number notification
#define CHAT @"Chat"
#define REQUEST_NUMBER_POST_NOTIFICATION @"UpdateChatNumber"

// near distance that user when get the distance to homepoint
// It is in miles
#define K_NEAR_DISTANCE 5

// request Updating interval time
#define REQUEST_UPDATE_REPEATINTERVAL 10


// Hud Messages
#define COMMON_HUD_SEND_MESSAGE @"Sending..."
#define COMMON_HUD_LOADING_MESSAGE @"Loading..."

// Alert Messages
#define FAILURE_SEND_MESSAGE @"An error occur, please try to send the request again"

// Notification
#define NOTIFICATION_ALERT_MESSAGE @"alert"

typedef enum{
    publicGroup = 0,
    privateGroup = 1
}groupPrivacy;

#endif