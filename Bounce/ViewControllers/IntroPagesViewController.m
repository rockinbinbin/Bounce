//
//  IntroPagesViewController.m
//  bounce
//
//  Created by Mohamed Abo Shamaaa on 3/26/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import "IntroPagesViewController.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Intro1IDViewController.h"
#import "Intro2IDViewController.h"
#import "Intro3IDViewController.h"
#import "IntroLoginScreenViewController.h"

@interface IntroPagesViewController ()

@end

@implementation IntroPagesViewController
{
    NSArray *myViewControllers;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
//    self.transitionStyle = UIPageViewControllerTransitionStyle.UIPageViewControllerTransitionStyleScroll;
    
    Intro1IDViewController* intro1IDViewController = [[Intro1IDViewController alloc] initWithNibName:@"Intro1IDViewController" bundle:nil];
    Intro2IDViewController* intro2IDViewController = [[Intro2IDViewController alloc] initWithNibName:@"Intro2IDViewController" bundle:nil];
    Intro3IDViewController* intro3IDViewController = [[Intro3IDViewController alloc] initWithNibName:@"Intro3IDViewController" bundle:nil];
    IntroLoginScreenViewController* introLoginScreenViewController = [[IntroLoginScreenViewController alloc] initWithNibName:@"IntroLoginScreenViewController" bundle:nil];

    myViewControllers = @[intro1IDViewController,intro2IDViewController,intro3IDViewController,introLoginScreenViewController];
//    [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];

    [self setViewControllers:@[intro1IDViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index{
    return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    
    if (currentIndex == 0) {
        return 0;
    }
    else {
        --currentIndex;
        currentIndex = currentIndex % (myViewControllers.count);
        return [myViewControllers objectAtIndex:currentIndex];
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    if (currentIndex == 3) {
        return 0;
    }
    ++currentIndex;
    currentIndex = currentIndex % (myViewControllers.count);
    return [myViewControllers objectAtIndex:currentIndex];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return myViewControllers.count;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end