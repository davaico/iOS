//
//  ActionViewPresentAnimationController.h
//  davai
//
//  Created by Zhi Li on 2014-11-28.
//  Copyright (c) 2014 Davai. All rights reserved.
//

#import <UIKit/UIKit.h>

enum TransitionDirection {LEFT, RIGHT};

@interface ActionViewPresentAnimationController : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic) enum TransitionDirection direction;

@end
