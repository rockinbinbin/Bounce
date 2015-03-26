//
//  GenderScreenViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "GenderScreenViewController.h"
#import "HomeScreenViewController.h"

@interface GenderScreenViewController ()

@end

@implementation GenderScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _btnSelect.backgroundColor = [UIColor whiteColor];
    self.gotItButton.backgroundColor = [UIColor colorWithRed:120.0/250.0 green:175.0/250.0 blue:212.0/250.0 alpha:1.0];
    self.view.backgroundColor = [UIColor colorWithRed:230.0/250.0 green:89.0/250.0 blue:89.0/250.0 alpha:1.0];
    
    UIImageView *downArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"common_down_arrow"]];
    downArrow.contentMode = UIViewContentModeScaleToFill;
    downArrow.frame = CGRectMake(160, 10, 20, 20);
    downArrow.contentMode=UIViewContentModeScaleAspectFill;
    [self.btnSelect addSubview:downArrow];
    
}

- (void)viewDidUnload {
    _btnSelect = nil;
    [self setBtnSelect:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectClicked:(id)sender {
    NSArray * arr = [[NSArray alloc] init];
    arr = [NSArray arrayWithObjects:@"Male", @"Female",nil];
    if(_dropDown == nil) {
        CGFloat f = 200;
        _dropDown = [[NIDropDown alloc]showDropDown:sender :&f :arr :nil :@"down"];
        _dropDown.delegate = self;
    }
    else {
        [_dropDown hideDropDown:sender];
        [self rel];
    }
}

- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    [self rel];
}

-(void)rel{
    //    [dropDown release];
    _dropDown = nil;
}


@end
