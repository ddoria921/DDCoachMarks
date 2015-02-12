//
//  DDCircleView.m
//  CoachMarks
//
//  Created by Darin Doria on 2/17/14.
//  Copyright (c) 2014 Darin Doria. All rights reserved.
//

#import "DDCircleView.h"

@implementation DDCircleView

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:CGRectMake(10, 0, 40, 40)];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CAShapeLayer *shapeLayer = (CAShapeLayer *) self.layer;
        shapeLayer.path = ([UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 40, 40)].CGPath);
        shapeLayer.fillColor = [UIColor colorWithWhite:1.000 alpha:1.00].CGColor;
        shapeLayer.shadowRadius = 8.0;
        shapeLayer.shadowOffset = CGSizeMake(0, 0);
        shapeLayer.shadowColor = [UIColor colorWithRed:0.000 green:0.299 blue:0.715 alpha:1.000].CGColor;
        shapeLayer.shadowOpacity = 1.0;
        shapeLayer.shadowPath = ([UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 40, 40)].CGPath);
        
        self.animationShouldStop = NO;
    }
    
    return self;
}

- (void)userTap:(UITapGestureRecognizer *)recognizer {
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)swipeInFrame:(CGRect)frame
{
    [self centerYPositioninView:self inFrame:frame];
    [self animateSwipe];
}

- (void)animateSwipe
{
    if (!_animationShouldStop) {
        CGAffineTransform scale = CGAffineTransformMakeScale(2, 2);
        CGAffineTransform translateRight = CGAffineTransformMakeTranslation(260, 0);
        if (self.swipeDirection == kCircleSwipeLeftToRight) {
            self.transform = scale;
        } else {
            // Start on the right hand side as well as scaling
            self.transform = CGAffineTransformConcat(translateRight, scale);
        }
        self.alpha = 0.0f;
        [UIView animateKeyframesWithDuration:0.6 delay:0.3 options:0
                                  animations:^{
                                      // Fade In
                                      if (self.swipeDirection == kCircleSwipeLeftToRight) {
                                          // Scale down to normal
                                          self.transform = CGAffineTransformMakeScale(1, 1);
                                      } else {
                                          // Start on the right hand side
                                          self.transform = translateRight;
                                      }
                                      self.alpha = 1.0f;
                                  }
                                  completion:^(BOOL finished){
                                      // End
                                      [UIView animateWithDuration:1.0
                                                       animations:^{
                                                           if (self.swipeDirection == kCircleSwipeLeftToRight) {
                                                               // Slide Right
                                                               self.transform = translateRight;
                                                           } else {
                                                               // Slide left
                                                               self.transform = CGAffineTransformIdentity;
                                                           }
                                                           // Fade Out
                                                           self.alpha = 0.0f;
                                                       }
                                                       completion:^(BOOL finished) {
                                                           // End
                                                           [self performSelector:@selector(animateSwipe)];
                                                       }];
                                  }];
        
    }
}

- (void)centerYPositioninView:(UIView *)view inFrame:(CGRect)frame
{
    CGFloat centerY = frame.origin.y + CGRectGetHeight(frame)/2;
    CGFloat offsetY = CGRectGetHeight(view.frame)/2;
    
    CGFloat newY = centerY - offsetY;
    view.frame = CGRectMake(view.frame.origin.x, newY, 40, 40);
}

- (void)centerXPositioninView:(UIView *)view inFrame:(CGRect)frame
{
    CGFloat centerX = frame.origin.x + CGRectGetWidth(frame)/2;
    CGFloat offsetX = CGRectGetWidth(view.frame)/2;
    
    CGFloat newX = centerX - offsetX;
    view.frame = CGRectMake(newX, view.frame.origin.y, 40, 40);
}

- (void)centerInView:(UIView *)view inFrame:(CGRect)frame
{
    [self centerYPositioninView:view inFrame:frame];
    [self centerXPositioninView:view inFrame:frame];
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

@end
