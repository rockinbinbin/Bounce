//
//  Intro2IDViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "Intro2IDViewController.h"
#import "Constants.h"

@interface Intro2IDViewController ()

@end

@implementation Intro2IDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.currentIndexPageControl.backgroundColor = [UIColor clearColor];
    self.currentIndexPageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IS_IPHONE4) {
        _backgroundImageView.image = [UIImage imageNamed:@"Tutorial-2.png"];
    }
    else if (IS_IPHONE5) {
        _backgroundImageView.image = [UIImage imageNamed:@"Tutorial-2_iPhone5"];
    }else if (IS_IPHONE6){
        _backgroundImageView.image = [UIImage imageNamed:@"Tutorial-2_iPhone6"];
    }else if (IS_IPHONE6PLUS){
        _backgroundImageView.image = [UIImage imageNamed:@"Tutorial-2_iPhone6plus"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
