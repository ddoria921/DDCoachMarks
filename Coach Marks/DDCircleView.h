//
//  DDCircleView.h
//  CoachMarks
//
//  Created by Darin Doria on 2/17/14.
//  Copyright (c) 2014 Darin Doria. All rights reserved.
//

#import <UIKit/UIKit.h>

enum EnumCircleSwipeDirection {
    kCircleSwipeLeftToRight,
    kCircleSwipeRightToLeft
};

@interface DDCircleView : UIView

@property BOOL animationShouldStop;
@property enum EnumCircleSwipeDirection swipeDirection;

- (void)swipeInFrame:(CGRect)frame;

@end
