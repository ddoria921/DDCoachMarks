//
//  DDCoachMarksView.h
//  Coach Marks
//
//  Created by Darin Doria on 02/17/2014.
//  Copyright (c) 2014 Darin Doria. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol DDCoachMarksViewDelegate;

@interface DDCoachMarksView : UIView

@property (nonatomic, weak) id<DDCoachMarksViewDelegate> delegate;
@property (nonatomic, retain)   NSArray *coachMarks;
@property (nonatomic, retain)   UIColor *maskColor;
@property (nonatomic)           CGFloat animationDuration;
@property (nonatomic)           CGFloat cutoutRadius;
@property (nonatomic)           CGFloat maxLblWidth;
@property (nonatomic)           CGFloat LblFontSize;
@property (nonatomic)           CGFloat lblSpacing;
@property (nonatomic)           BOOL    useBubbles;
@property (nonatomic)           BOOL enableContinueLabel;
@property (nonatomic)           BOOL enableSkipButton;
@property (nonatomic)           BOOL enableTapAction;


- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks;
- (void)setMaskColor:(UIColor *)maskColor;
- (void)start;
- (void)stop;

@end

@protocol DDCoachMarksViewDelegate <NSObject>

@optional
- (void)coachMarksView:(DDCoachMarksView*)coachMarksView willNavigateToIndex:(NSUInteger)index;
- (void)coachMarksView:(DDCoachMarksView*)coachMarksView didNavigateToIndex:(NSUInteger)index;
- (void)coachMarksViewWillCleanup:(DDCoachMarksView*)coachMarksView;
- (void)coachMarksViewDidCleanup:(DDCoachMarksView*)coachMarksView;
- (void)didTapAtIndex:(NSUInteger)index;

@end