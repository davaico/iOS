//
//  ActionViewPresentAnimationController.m
//  davai
//
//  Created by Zhi Li on 2014-11-28.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import "ActionViewPresentAnimationController.h"

@implementation ActionViewPresentAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    CGRect fromFrame, toFrame;
    if (self.direction == LEFT) {
        toFrame = containerView.bounds;
        fromFrame = CGRectMake(toFrame.size.width, 0, toFrame.size.width, toFrame.size.height);
    }
    else {
        toFrame = containerView.bounds;
        fromFrame = CGRectMake(-toFrame.size.width, 0, toFrame.size.width, toFrame.size.height);
    }
    
    toViewController.view.frame = fromFrame;
    
    [containerView addSubview:toViewController.view];
    
    toViewController.view.alpha = 0.0;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         toViewController.view.alpha = 1.0;
                         toViewController.view.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         [transitionContext completeTransition:YES];
                     }];
    
//    [UIView animateWithDuration:duration animations:^{
//        toViewController.view.alpha = 1.0;
//        toViewController.view.frame = toFrame;
//    }];
//    
//    [transitionContext completeTransition:YES];
}

@end
