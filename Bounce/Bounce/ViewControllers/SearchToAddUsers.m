//
//  SearchToAddUsers.m
//  bounce
//
//  Created by Robin Mehta on 8/15/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "SearchToAddUsers.h"

@implementation SearchToAddUsers

- (void)viewDidLoad {
        [super viewDidLoad];
    
        [self setBarButtonItemLeft:@"common_back_button"];
        [self setBarButtonItemRight:@"whiteCheck"];
    
       UILabel *navLabel = [UILabel new];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.backgroundColor = [UIColor clearColor];
        navLabel.textAlignment = NSTextAlignmentCenter;
        navLabel.font = [UIFont fontWithName:@"Quicksand-Regular" size:20];
       self.navigationItem.titleView = navLabel;
        navLabel.text = @"MEMBERS";
        [navLabel sizeToFit];
    
    }

// Sets left nav bar button
-(void) setBarButtonItemLeft:(NSString*) imageName {
        UIImage *menuImage = [UIImage imageNamed:imageName];
        self.navigationItem.leftBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(cancelButtonClicked)];
    }

- (void) setBarButtonItemRight:(NSString *)imageName {
        UIImage *menuImage = [UIImage imageNamed:imageName];
       self.navigationItem.rightBarButtonItem = [self initialiseBarButton:menuImage withAction:@selector(doneClicked)];
    }

// Sets nav bar button item with image
-(UIBarButtonItem *)initialiseBarButton:(UIImage*) buttonImage withAction:(SEL) action {
    
        UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonItem.bounds = CGRectMake( 0, 0, buttonImage.size.width, buttonImage.size.height );
       [buttonItem addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [buttonItem setImage:buttonImage forState:UIControlStateNormal];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
        return barButtonItem;
    }

- (void)cancelButtonClicked {
        [self.navigationController popViewControllerAnimated:YES];
    }

- (void)doneClicked {
        // save & pop
    }

@end