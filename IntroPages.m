//
//  IntroPages.m
//  bounce
//
//  Created by Robin Mehta on 2/17/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntroPages : UIPageViewController
<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (IBAction)skipButton:(id)sender;

@end

@implementation IntroPages
{
    NSArray *myViewControllers;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // SKIP BUTTON
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(skipButton:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"skip" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 470.0, 160.0, 40.0);
    
    self.delegate = self;
    self.dataSource = self;
    
    UIViewController *p1 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"Intro1ID"];
        [p1.view addSubview:button];
    
    UIViewController *p2 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"Intro2ID"];
    
    UIViewController *p3 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"Intro3ID"];
    
    UIViewController *p4 = [self.storyboard
                            instantiateViewControllerWithIdentifier:@"Intro4ID"];
    
    myViewControllers = @[p1,p2,p3,p4];
    
    [self setViewControllers:@[p1]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    
    NSLog(@"loaded!");
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    
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
      viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger currentIndex = [myViewControllers indexOfObject:viewController];
    
    if (currentIndex == 3) {
        return 0;
    }

    {
        NSLog(@"%d", currentIndex);
        ++currentIndex;
        currentIndex = currentIndex % (myViewControllers.count);
        return [myViewControllers objectAtIndex:currentIndex];
    }
}

-(NSInteger)presentationCountForPageViewController:
(UIPageViewController *)pageViewController
{
    return myViewControllers.count;
}

-(NSInteger)presentationIndexForPageViewController:
(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)skipButton:(id)sender {
    [self performSegueWithIdentifier:@"skipSegue" sender:nil];
}

@end