//
//  ChatRoomViewController.h
//  bounce
//
//  Created by Robin Mehta on 3/22/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PF_EGORefreshTableHeaderView.h"
#import "Chatcell.h"

@interface ChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PF_EGORefreshTableHeaderDelegate>{
    UITextField *tfEntry;
    
    IBOutlet UITableView    *chatTable;
    NSMutableArray          *chatData;
    PF_EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
    NSString *className;
    NSString *userName;

}
@property (strong, nonatomic) IBOutlet UITextField *tfEntry;

@property (nonatomic, retain) UITableView *chatTable;
@property (nonatomic, retain) NSArray *chatData;

-(void) registerForKeyboardNotifications;
-(void) freeKeyboardNotifications;
-(void) keyboardWasShown:(NSNotification*)aNotification;
-(void) keyboardWillHide:(NSNotification*)aNotification;

- (void)loadLocalChat;

@end
