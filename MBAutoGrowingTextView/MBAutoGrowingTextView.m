//
//  TINAutoGrowingTextView.m
//  TINUIKit
//
//  Created by Matej Balantic on 14/05/14.
//  Copyright (c) 2014 Matej Balantič. All rights reserved.
//

#import "MBAutoGrowingTextView.h"

@interface MBAutoGrowingTextView ()
@property (nonatomic, weak) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *minHeightConstraint;
@property (nonatomic, weak) NSLayoutConstraint *maxHeightConstraint;
@end

@implementation MBAutoGrowingTextView


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.borderColor = [UIColor bcs60GrayColor];
    self.fillColor = [UIColor bcs230GrayColor];
    
    self.arrowOrigin = round(self.bounds.size.width / 2.0f);
    self.arrowDirection = BCBubbleTextViewArrowDirectionUp;
    
    [self associateConstraints];
}

-(void)associateConstraints
{
    // iterate through all text view's constraints and identify
    // height, max height and min height constraints.
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            
            if (constraint.relation == NSLayoutRelationEqual) {
                self.heightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationLessThanOrEqual) {
                self.maxHeightConstraint = constraint;
            }
            
            else if (constraint.relation == NSLayoutRelationGreaterThanOrEqual) {
                self.minHeightConstraint = constraint;
            }
        }
    }

}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    
    NSAssert(self.heightConstraint != nil, @"Unable to find height auto-layout constraint. MBAutoGrowingTextView\
             needs a Auto-layout environment to function. Make sure you are using Auto Layout and that UITextView is enclosed in\
             a view with valid auto-layout constraints.");
    
    // calculate size needed for the text to be visible without scrolling
    CGSize sizeThatFits = [self sizeThatFits:self.frame.size];
    float newHeight = sizeThatFits.height;

    // if there is any minimal height constraint set, make sure we consider that
    if (self.maxHeightConstraint) {
        newHeight = MIN(newHeight, self.maxHeightConstraint.constant);
    }

    // if there is any maximal height constraint set, make sure we consider that
    if (self.minHeightConstraint) {
        newHeight = MAX(newHeight, self.minHeightConstraint.constant);
    }
    
    // update the height constraint
    self.heightConstraint.constant = newHeight;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if (self.arrowDirection == BCBubbleTextViewArrowDirectionNone)
    {
        return;
    }
    
    CGRect currentFrame = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat strokeWidth = 1.0f;
    CGFloat borderRadius = 8.0f;
    CGFloat arrowOrigin = self.arrowOrigin;
    CGColorRef borderColor = [self.borderColor CGColor];
    CGColorRef fillColor = [self.fillColor CGColor];
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, borderColor);
    CGContextSetFillColorWithColor(context, fillColor);
    
    // Draw and fill the bubble
    if (self.arrowDirection == BCBubbleTextViewArrowDirectionUp)
    {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, borderRadius + strokeWidth + 0.5f, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f);
        CGContextAddLineToPoint(context, round(arrowOrigin - WIDTHOFPOPUPTRIANGLE / 2.0f) + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f);
        CGContextAddLineToPoint(context, round(arrowOrigin) + 0.5f, strokeWidth + 0.5f);
        CGContextAddLineToPoint(context, round(arrowOrigin + WIDTHOFPOPUPTRIANGLE / 2.0f) + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f);
        CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
        CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, round(currentFrame.size.width / 2.0f + WIDTHOFPOPUPTRIANGLE / 2.0f) - strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
        CGContextAddArcToPoint(context, strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, strokeWidth + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
        CGContextAddArcToPoint(context, strokeWidth + 0.5f, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    else
    {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, borderRadius + strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f, strokeWidth + 0.5f);
        CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, strokeWidth + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
        CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, round(currentFrame.size.width / 2.0f) - strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
        CGContextAddArcToPoint(context, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, strokeWidth + 0.5f, strokeWidth + 0.5f, borderRadius - strokeWidth);
        CGContextAddLineToPoint(context, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, round(arrowOrigin + WIDTHOFPOPUPTRIANGLE / 2.0f) + 0.5f);
        CGContextAddLineToPoint(context, strokeWidth + 0.5f, round(arrowOrigin) + 0.5f);
        CGContextAddLineToPoint(context, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, round(arrowOrigin - WIDTHOFPOPUPTRIANGLE / 2.0f) + 0.5f);
        CGContextAddArcToPoint(context, strokeWidth + HEIGHTOFPOPUPTRIANGLE + 0.5f, strokeWidth + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    // Draw a clipping path for the fill
    //    CGContextBeginPath(context);
    //    CGContextMoveToPoint(context, borderRadius + strokeWidth + 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f);
    //    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
    //    CGContextAddArcToPoint(context, currentFrame.size.width - strokeWidth - 0.5f, currentFrame.size.height - strokeWidth - 0.5f, round(currentFrame.size.width / 2.0f + WIDTHOFPOPUPTRIANGLE / 2.0f) - strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, borderRadius - strokeWidth);
    //    CGContextAddArcToPoint(context, strokeWidth + 0.5f, currentFrame.size.height - strokeWidth - 0.5f, strokeWidth + 0.5f, HEIGHTOFPOPUPTRIANGLE + strokeWidth + 0.5f, borderRadius - strokeWidth);
    //    CGContextAddArcToPoint(context, strokeWidth + 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f, currentFrame.size.width - strokeWidth - 0.5f, round((currentFrame.size.height + HEIGHTOFPOPUPTRIANGLE) * 0.50f) + 0.5f, borderRadius - strokeWidth);
    //    CGContextClosePath(context);
    //    CGContextClip(context);
}

@end
