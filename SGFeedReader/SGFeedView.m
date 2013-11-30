//
//  SGFeederView.m
//  SGFeeder
//
//  Created by Guy Lachish on 10/19/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#import "SGFeedView.h"
#import "UIView+UIViewExtensions.h"
#import "SGAnimationController.h"

#define LABEL_OFFSET_X 5.0f




@implementation SGFeedView

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {

        [self _setDefaultValues];
    }
    
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self _setDefaultValues];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {

}

#pragma mark Private

/**
 *  Get the user's perferred font and adjusting it to the feeder's size
 *
 *  @return The resulted font
 */
- (UIFont *)_preferredFontOfSize {
    
    
    UIFont * bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont * labelFont = [bodyFont fontWithSize:ceilf(self.height * 0.6)];
    
    return labelFont;
}
/**
 *  Set default values for the view
 */
- (void)_setDefaultValues {
    
    //       Default values
    //       ==============
    _speed = 30.0f;
    _isLeftToRight = YES;
    _currentMessage = [[UILabel alloc] init];
    self.backgroundColor = [UIColor clearColor];

    //    Min. height for the feederView is 16.0f
    if (16.0f > self.height) self.frame = CGRectMake(self.left, self.top, self.width, 16.0f);
    [self setAutoresizesSubviews:YES];
}

-(void)layoutSubviews {
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    if (nil != _currentMessage && animator.isRunning) [animator updateItemUsingCurrentState:_currentMessage];
}


/** TODO:update documentation
 *  Calculate and returns the minimum rectangle that is big enough to contain the current message string
 *
 *  @param message The message string to surround
 *
 *  @return The result rectangle
 */
- (void)_resetFrame {
    
    NSDictionary * textAttributes = @{ NSFontAttributeName : [self _preferredFontOfSize],
                                       };
    
    CGSize textSize = [_currentMessage.text sizeWithAttributes:textAttributes];
    CGFloat labelWidth = ceilf(textSize.width);
    
    CGRect labelRect =  CGRectMake(LABEL_OFFSET_X, -self.height, labelWidth , self.height);
    
    _currentMessage.frame = labelRect;
    
    if (!_isLeftToRight) {
        
        [_currentMessage setRight:self.width - LABEL_OFFSET_X];
//        self.currentMessage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | // !!!
//                                               UIViewAutoresizingFlexibleTopMargin;
        
    }
    
    [_currentMessage setNeedsDisplayInRect:self.bounds];
}

#pragma mark Public

- (void)resetMessagePosition {
    
    [_currentMessage removeFromSuperview];
    _currentMessage.alpha = 1.0f;
    [self _resetFrame];
    [self addSubview:_currentMessage];
}
- (void)calibrate {
    
    [self _resetFrame];
    _currentMessage.font = [self _preferredFontOfSize];
    _currentMessage.textColor = (nil != _textColor) ? _textColor : self.tintColor;
    if (!_isLeftToRight) _currentMessage.textAlignment = NSTextAlignmentRight;
    
    [self addSubview:_currentMessage];
}
- (void)resetPosition:(CGFloat)x {

    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    if (_isLeftToRight) {
    
        [_currentMessage setLeft:x];
        [animator updateItemUsingCurrentState:_currentMessage];
    }
    else {
    
        [_currentMessage setRight:x];
        [animator updateItemUsingCurrentState:_currentMessage];
    }
}

@end

