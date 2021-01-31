//
//  DDCoachMarksView.m
//  Coach Marks
//
//  Created by Darin Doria on 02/17/2014.
//  Copyright (c) 2014 Darin Doria. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DDCoachMarksView.h"
#import "DDCircleView.h"
#import "DDBubble.h"

static const CGFloat    kAnimationDuration = 0.3f;
static const CGFloat    kCutoutRadius = 2.0f;
static const CGFloat    kMaxLblWidth = 230.0f;
static const CGFloat    kLblSpacing = 35.0f;
static const CGFloat    kLblFontSize = 16.0f;
static const BOOL kEnableContinueLabel = NO;
static const BOOL kEnableSkipButton = NO;
static const BOOL kEnableTapAction = YES;

@interface DDCoachMarksView ()
@property (nonatomic, strong) DDCircleView  *animatingCircle;
@property (nonatomic, strong) DDBubble      *bubble;
@end

@implementation DDCoachMarksView {
    CAShapeLayer    *mask;
    NSUInteger      markIndex;
    UILabel         *lblContinue;
    UIButton        *btnSkipCoach;

}

#pragma mark - Methods

- (id)initWithFrame:(CGRect)frame coachMarks:(NSArray *)marks {
    self = [super initWithFrame:frame];
    if (self) {
        // Save the coach marks
        self.coachMarks = marks;

        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)setup {
    // Default
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    self.maxLblWidth = kMaxLblWidth;
    self.lblSpacing = kLblSpacing;
    self.LblFontSize = kLblFontSize;
    self.enableContinueLabel = kEnableContinueLabel;
    self.enableSkipButton = kEnableSkipButton;
    self.enableTapAction = kEnableTapAction;
    self.useBubbles = YES;

    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithWhite:0.000 alpha:0.800] CGColor]];
    [self.layer addSublayer:mask];

    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeGestureRecognizer];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // Hide until unvoked
    self.hidden = YES;
}

#pragma mark - Cutout modify

- (void)setCutoutToRect:(CGRect)rect withShape:(NSString *)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    if ([shape isEqualToString:@"circle"])
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if ([shape isEqualToString:@"square"])
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    [maskPath appendPath:cutoutPath];

    // Set the new path
    mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRect:(CGRect)rect withShape:(NSString *)shape{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath;
    
    
    if ([shape isEqualToString:@"circle"])
        cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    else if ([shape isEqualToString:@"square"])
        cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    else
        cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    
    [maskPath appendPath:cutoutPath];

    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}

#pragma mark - Mask color

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    [mask setFillColor:[maskColor CGColor]];
}

#pragma mark - Touch handler

- (void)userDidTap:(UITapGestureRecognizer *)recognizer {
    
    if ([self.delegate respondsToSelector:@selector(didTapAtIndex:)]) {
        [self.delegate didTapAtIndex:markIndex];
    }
    
    if (self.enableTapAction == YES) {
        // Go to the next coach mark
        [self goToCoachMarkIndexed:(markIndex+1)];
    }
    else{
        // Nothing
    }

}

#pragma mark - Navigation

- (void)start {
    // Fade in self
    self.alpha = 0.0f;
    self.hidden = NO;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         [self goToCoachMarkIndexed:0];
                     }];
}
- (void)stop {
    // Fade in self
    self.alpha = 1.0f;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // Go to the first coach mark
                         self.hidden = YES;
                         [self goToCoachMarkIndexed:0];
                     }];
}

- (void)skipCoach {
    [self goToCoachMarkIndexed:self.coachMarks.count];
}

- (void)goToCoachMarkIndexed:(NSUInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }

    // Current index
    markIndex = index;
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }
    
    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];
    NSString *shape = [markDef objectForKey:@"shape"];

    if (self.useBubbles) {
        [self animateNextBubble];
    }

    // If first mark, set the cutout to the center of first mark
    if (markIndex == 0) {
        CGPoint center = CGPointMake(floorf(markRect.origin.x + (markRect.size.width / 2.0f)), floorf(markRect.origin.y + (markRect.size.height / 2.0f)));
        CGRect centerZero = (CGRect){center, CGSizeZero};
        [self setCutoutToRect:centerZero withShape:shape];
    }

    // Animate the cutout
    [self animateCutoutToRect:markRect withShape:shape];
    
    // Animate swipe gesture
    [self showSwipeGesture];
    
    CGFloat lblContinueWidth = self.enableSkipButton ? (70.0/100.0) * self.bounds.size.width : self.bounds.size.width;
    CGFloat btnSkipWidth = self.bounds.size.width - lblContinueWidth;
    
    // Show continue lbl if first mark
    if (self.enableContinueLabel) {
        if (markIndex == 0) {
            lblContinue = [[UILabel alloc] initWithFrame:(CGRect){{0, self.bounds.size.height - 30.0f}, {lblContinueWidth, 30.0f}}];
            lblContinue.font = [UIFont boldSystemFontOfSize:self.LblFontSize];
            lblContinue.textAlignment = NSTextAlignmentCenter;
            lblContinue.text = @"Tap to continue";
            lblContinue.alpha = 0.0f;
            lblContinue.backgroundColor = [UIColor whiteColor];
            [self addSubview:lblContinue];
            [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
                lblContinue.alpha = 1.0f;
            } completion:nil];
        } else if (markIndex > 0 && lblContinue != nil) {
            // Otherwise, remove the lbl
            [lblContinue removeFromSuperview];
            lblContinue = nil;
        }
    }
    
    if (self.enableSkipButton) {
        btnSkipCoach = [[UIButton alloc] initWithFrame:(CGRect){{lblContinueWidth, self.bounds.size.height - 30.0f}, {btnSkipWidth, 30.0f}}];
        [btnSkipCoach addTarget:self action:@selector(skipCoach) forControlEvents:UIControlEventTouchUpInside];
        [btnSkipCoach setTitle:@"Skip" forState:UIControlStateNormal];
        btnSkipCoach.titleLabel.font = [UIFont boldSystemFontOfSize:self.LblFontSize];
        btnSkipCoach.alpha = 0.0f;
        btnSkipCoach.tintColor = [UIColor whiteColor];
        [self addSubview:btnSkipCoach];
        [UIView animateWithDuration:0.3f delay:1.0f options:0 animations:^{
            btnSkipCoach.alpha = 1.0f;
        } completion:nil];
    }
}

#pragma mark - Swipe Animation

- (void)showSwipeGesture
{
    NSDictionary *coachMarkInfo = [self.coachMarks objectAtIndex:markIndex];
    CGRect frame = [[coachMarkInfo objectForKey:@"rect"] CGRectValue];
    BOOL shouldAnimateSwipe = [[coachMarkInfo objectForKey:@"swipe"] boolValue];
    
    NSString* swipeDirection = [coachMarkInfo objectForKey:@"direction"];
    enum EnumCircleSwipeDirection direction = kCircleSwipeLeftToRight;
    if ((swipeDirection != nil) && ([swipeDirection isEqualToString:@"righttoleft"])) {
        direction = kCircleSwipeRightToLeft;
    }
    
    // if next animation doesn't need swipe
    // remove current swiping circle if one exists
    if (self.animatingCircle) {
        [UIView animateWithDuration:0.6 delay:0.3 options:0 animations:^{
            self.animatingCircle.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.animatingCircle removeFromSuperview];
        }];
    }

    // create an animating circle and animate it
    if (shouldAnimateSwipe) {
        self.animatingCircle = [[DDCircleView alloc] initWithFrame:self.frame];
        
        if (![self.subviews containsObject:self.animatingCircle]) {
            [self addSubview:self.animatingCircle];
        }
        
        self.animatingCircle.swipeDirection = direction;
        
        [self.animatingCircle swipeInFrame:frame];
    }
}


#pragma mark - Bubble Caption

- (void)animateNextBubble
{
    // Get current coach mark information
    NSDictionary *coachMarkInfo = [self.coachMarks objectAtIndex:markIndex];
    NSString *markCaption = [coachMarkInfo objectForKey:@"caption"];
    CGRect frame = [[coachMarkInfo objectForKey:@"rect"] CGRectValue];
    CGRect poi = [[coachMarkInfo objectForKey:@"POI"] CGRectValue];
    UIFont *font = [coachMarkInfo objectForKey:@"font"];
    
    // remove previous bubble
    if (self.bubble) {
        [UIView animateWithDuration:0.3 delay:0.0 options:0
                                  animations:^{
                                      self.bubble.alpha = 0.0;
                                  } completion:nil];
    }
    
    // return if no text for bubble
    if ([markCaption length] == 0)
        return;
    
    // create bubble
    // IF using point of interest (poi) frame use that instead of cutout frame
    // ELSE use the cutout frame
    if (CGRectIsEmpty(poi)) {
        self.bubble = [[DDBubble alloc] initWithFrame:frame title:markCaption description:nil arrowPosition:CRArrowPositionTop color:nil andFont:font];
    } else
        self.bubble = [[DDBubble alloc] initWithFrame:poi title:markCaption description:nil arrowPosition:CRArrowPositionTop color:nil andFont:font];

    self.bubble.alpha = 0.0;
    [self addSubview:self.bubble];
    
    // fade in & bounce animation
    [UIView animateWithDuration:0.8 delay:0.3 options:0
                              animations:^{
                                  self.bubble.alpha = 1.0;
                                  [self.bubble animate];
                              } completion:^(BOOL finished) {
                                  
                              }];
}

#pragma mark - Cleanup

- (void)cleanup {
    // Delegate (coachMarksViewWillCleanup:)
    if ([self.delegate respondsToSelector:@selector(coachMarksViewWillCleanup:)]) {
        [self.delegate coachMarksViewWillCleanup:self];
    }
    
    __weak DDCoachMarksView *weakSelf = self;
    
    // animate & remove from super view
    [UIView animateWithDuration:0.6 delay:0.3 options:0
                              animations:^{
                                  self.alpha = 0.0f;
                                  self.animatingCircle.alpha = 0.0f;
                                  self.bubble.alpha = 0.0f;
                              } completion:^(BOOL finished) {
                                  // Remove self
                                  weakSelf.animatingCircle.animationShouldStop = YES;
                                  weakSelf.bubble.animationShouldStop = YES;
                                  [weakSelf.animatingCircle removeFromSuperview];
                                  [weakSelf.bubble removeFromSuperview];
                                  [weakSelf removeFromSuperview];
                          
                                  // Delegate (coachMarksViewDidCleanup:)
                                  if ([weakSelf.delegate respondsToSelector:@selector(coachMarksViewDidCleanup:)]) {
                                      [weakSelf.delegate coachMarksViewDidCleanup:weakSelf];
                                  }
                              }];
}

-(void)dealloc
{
    self.animatingCircle = nil;
    self.bubble = nil;
    self.maskColor = nil;
    self.coachMarks = nil;
}

#pragma mark - Animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // Delegate (coachMarksView:didNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:didNavigateToIndex:)]) {
        [self.delegate coachMarksView:self didNavigateToIndex:markIndex];
    }
}

@end