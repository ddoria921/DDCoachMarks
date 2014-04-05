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

@interface DDCoachMarksView ()
@property (nonatomic, strong) DDCircleView  *animatingCircle;
@property (nonatomic, strong) DDBubble      *bubble;
@end

@implementation DDCoachMarksView {
    CAShapeLayer    *mask;
    NSUInteger      markIndex;
    UILabel         *lblContinue;
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
    self.useBubbles = YES;

    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[[UIColor colorWithWhite:0.000 alpha:0.800] CGColor]];
    [self.layer addSublayer:mask];

    // Capture touches
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:nil];
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
    
    // Go to the next coach mark
    [self goToCoachMarkIndexed:(markIndex+1)];
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

- (void)goToCoachMarkIndexed:(NSUInteger)index {
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return;
    }

    // Current index
    markIndex = index;

    // Coach mark definition
    NSDictionary *markDef = [self.coachMarks objectAtIndex:index];
    NSString *markCaption = [markDef objectForKey:@"caption"];
    CGRect markRect = [[markDef objectForKey:@"rect"] CGRectValue];
    NSString *shape = [markDef objectForKey:@"shape"];
    
    // Delegate (coachMarksView:willNavigateTo:atIndex:)
    if ([self.delegate respondsToSelector:@selector(coachMarksView:willNavigateToIndex:)]) {
        [self.delegate coachMarksView:self willNavigateToIndex:markIndex];
    }

    if (self.useBubbles) {
        [self animateNextBubble];
    }

    else {
        // Calculate the caption position and size
        self.lblCaption.alpha = 0.0f;
        self.lblCaption.frame = (CGRect){{0.0f, 0.0f}, {self.maxLblWidth, 0.0f}};
        self.lblCaption.text = markCaption;
        [self.lblCaption sizeToFit];
        CGFloat y = markRect.origin.y + markRect.size.height + self.lblSpacing;
        CGFloat bottomY = y + self.lblCaption.frame.size.height + self.lblSpacing;
        if (bottomY > self.bounds.size.height) {
            y = markRect.origin.y - self.lblSpacing - self.lblCaption.frame.size.height;
        }
        CGFloat x = floorf((self.bounds.size.width - self.lblCaption.frame.size.width) / 2.0f);
        
        // Animate the caption label
        self.lblCaption.frame = (CGRect){{x, y}, self.lblCaption.frame.size};
        [UIView animateWithDuration:0.3f animations:^{
            self.lblCaption.alpha = 1.0f;
        }];
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
}

#pragma mark - Swipe Animation

- (void)showSwipeGesture
{
    NSDictionary *coachMarkInfo = [self.coachMarks objectAtIndex:markIndex];
    CGRect frame = [[coachMarkInfo objectForKey:@"rect"] CGRectValue];
    BOOL shouldAnimateSwipe = [[coachMarkInfo objectForKey:@"swipe"] boolValue];
    
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
        self.animatingCircle = [[DDCircleView alloc] initWithFrame:CGRectZero];
        
        if (![self.subviews containsObject:self.animatingCircle]) {
            [self addSubview:self.animatingCircle];
        }
        
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
    
    // remove previous bubble
    if (self.bubble) {
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:0
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
        self.bubble = [[DDBubble alloc] initWithFrame:frame title:markCaption description:nil arrowPosition:CRArrowPositionTop andColor:nil];
    } else
        self.bubble = [[DDBubble alloc] initWithFrame:poi title:markCaption description:nil arrowPosition:CRArrowPositionTop andColor:nil];

    self.bubble.alpha = 0.0;
    [self addSubview:self.bubble];
    
    // fade in & bounce animation
    [UIView animateKeyframesWithDuration:0.8 delay:0.3 options:0
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
    [UIView animateKeyframesWithDuration:0.6 delay:0.3 options:0
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