//
//  ActionViewDismissAnimationController.m
//  davai
//
//  Created by Zhi Li on 2014-11-28.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import "ActionViewDismissAnimationController.h"

@implementation ActionViewDismissAnimationController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         fromViewController.view.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [fromViewController.view removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end
