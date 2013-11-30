//
//  SGAnimationController.m
//  SGFeeder
//
//  Created by Guy Lachish on 11/2/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#import "SGAnimationController.h"
#import "SGFeedView.h"
#import "SGFeedControllerView.h"
#import "UIView+UIViewExtensions.h"
#import "SGActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

#define BARRIER_WIDTH_UNIT 5000.0f
#define ACTIVITY_OFFSET_X 10.0f
#define LABEL_OFFSET_X 5.0f
#define FEED_DIFERENTIAL 20.0f

@interface SGAnimationController ()

@end

static SGAnimationController * sharedAnimator = nil;

@implementation SGAnimationController {
    
    UIDynamicAnimator * _animator;
    UIGravityBehavior * _gravity;
    UICollisionBehavior * _collision;
    UIDynamicItemBehavior * _elasticity;
    UISnapBehavior * _snap;
    UIPushBehavior * _push;
    
    BOOL _firstContact;
    BOOL _animationStopped;
    BOOL _isAnimating;
//    BOOL _deviceRotated;
    CGFloat _feedViewWidth;
}

+ (instancetype)sharedAnimator {
    
        static id _sharedAnimator = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedAnimator = [[self alloc] init];
        });
        
        return _sharedAnimator;
}

- (void)setWidth:(CGFloat)width {
    
    _feedViewWidth = width - 20.0f;
}

- (BOOL)animationStopped {
    
    return _animationStopped;
}

- (void)attachGravityToFeedView:(SGFeedView *)feedView {
    
    _firstContact = YES;
    [_animator removeAllBehaviors];
    
    if (_animationStopped) _animationStopped = NO;
    
    [feedView calibrate];
    
    if (nil == _gravity) _gravity = [[UIGravityBehavior alloc] init];
    if (nil == _collision) _collision = [[UICollisionBehavior alloc] init];
    if (nil == _elasticity) _elasticity = [[UIDynamicItemBehavior alloc] init];
    [self addBehaviorsToView:feedView.currentMessage];
    [_animator addBehavior:_gravity];
    [_animator addBehavior:_collision];
    
    _gravity.magnitude = 4.0f;
    _gravity.gravityDirection = CGVectorMake(0.0f, 0.75f);
    
    CGRect barrier = CGRectMake(-BARRIER_WIDTH_UNIT, feedView.height + 1.0f , 2 * BARRIER_WIDTH_UNIT, 1.0f);
    CGPoint rightEdge = CGPointMake(barrier.size.width, barrier.origin.y);
    CGPoint leftEdge = CGPointMake(barrier.origin.x, barrier.origin.y);
    
    [_collision addBoundaryWithIdentifier:@"barrier2" fromPoint:leftEdge toPoint:rightEdge];
    

    _elasticity.elasticity = 0.35f;
    [_animator addBehavior:_elasticity];
    
}

- (void)addActivityIndicator:(SGActivityIndicator *)activity forView:(SGFeedControllerView *)controlView {

    activity.isVisible = YES;
    CGFloat angle = (controlView.isLeftToRight) ? M_PI : 0.0f;
    
    [self removeBehaviorsFromView:activity];
    
    [self _initialPositioForActivityIndicator:activity inControlView:controlView];
    
    [controlView addSubview:activity];
    
    if (nil == _animator) {
        
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:controlView];
    }
    else {
        [_animator removeAllBehaviors];
    }
    
    if(nil == _elasticity) _elasticity = [[UIDynamicItemBehavior alloc] init];
    _elasticity.elasticity = 10.0f;
    [_animator addBehavior:_elasticity];
    
    if (nil == _push) _push = [[UIPushBehavior alloc] init];
    [_push addItem:activity];
    [_push setAngle:angle magnitude:0.0f];
    [_animator addBehavior:_push];

    if (nil == _collision) _collision = [[UICollisionBehavior alloc] init];
    [_collision addItem:activity];
    [self _barrierForActivity:activity inControlView:(SGFeedControllerView *)controlView];
    [_animator addBehavior:_collision];
    
    CGRect finalRectForFeeder = [self _finalRectForControlView:controlView
                                                      activity:activity
                                                addingActivity:YES];
    controlView.layer.masksToBounds = NO;
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         controlView.frame = finalRectForFeeder;
                     }
                     completion:^(BOOL finished) {
                         
                         _push.magnitude = 0.4f;
                     }
     ];
    [_animator updateItemUsingCurrentState:activity];
}

- (void)removeActivityIndicator:(SGActivityIndicator *)activity
                        forView:(SGFeedControllerView *)controlView {
    
    [activity stop];
    CGFloat angle = (controlView.isLeftToRight) ? 0.0f : M_PI;
    _push.angle = angle;
    
    if (![_push.items containsObject:activity]) {
        
        [_push addItem:activity];
    }
    
    [_collision removeBoundaryWithIdentifier:@"barrier1"];
    [_push removeChildBehavior:_collision];
    
    CGRect finalRectForFeeder = [self _finalRectForControlView:controlView
                                                      activity:activity
                                                addingActivity:NO];
    
    [UIView animateWithDuration:0.25f
                          delay:0.2f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         controlView.layer.frame = finalRectForFeeder;
                     }
     
                     completion:^(BOOL finished) {
                         
                         [self updateItemUsingCurrentState:activity];
                         [self removeBehaviorsFromView: activity];
                         [activity removeFromSuperview];
                         activity.isVisible = NO;
                         [controlView ready];
                     }
     ];
}

- (void)removeFeeder:(SGFeedView *)feedView {
    
    CGRect finalRect = CGRectMake(feedView.left, feedView.top, feedView.width, 0.0f);
    [UIView animateWithDuration:0.25f
                          delay:1.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         feedView.layer.frame = finalRect;
                         feedView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         
                         NSLog(@"REMOVING FEEDER: connection or general error !!!!!!!");
                     }
     ];
}

- (void)startPushAnimation:(SGFeedView *)feedView {
    
    _isAnimating = YES;
    UILabel * currentMessage = feedView.currentMessage;
    [currentMessage.layer removeAllAnimations];
    [self removeBehaviorsFromView:currentMessage];
    CGFloat distanceInPixels = [self _distanceForFeeder:feedView];
    
    CGRect finalRect;
    
//    if last message, update distance
    if ([self _titleRect:&finalRect forFeedView:feedView andDistance:distanceInPixels]) {
        
        if ( 0.0f > distanceInPixels) distanceInPixels = 0.0f;
        distanceInPixels += MIN(currentMessage.width + LABEL_OFFSET_X, _feedViewWidth);
    }
    
    NSTimeInterval duration = distanceInPixels / feedView.speed;
    
    [UIView animateWithDuration:MAX(duration, 0.5f)
                          delay:1.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         if ((_feedViewWidth < currentMessage.width) || _lastMessage) {

                             currentMessage.frame = finalRect;
                         }
                     }
                     completion:^(BOOL finished ) {
                         
                         if (finished) {
                             
                             _isAnimating = NO;
                             [self fadeAnimation:currentMessage inContainer:feedView];
                         }
                     }
     ];
    
}

- (void)stopAnimation:(SGFeedView *)feedView {
    
    _animationStopped = YES;
//    [self pauseLayer:feeder.currentMessage.layer];
    [self fadeAnimation:feedView.currentMessage inContainer:feedView];
}

- (void)pauseLayer:(CALayer*)layer {
//    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
//    layer.speed = 0.0;
//    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer *)layer {
    
//    CFTimeInterval paused_time = [layer timeOffset];
//    layer.speed = 1.0f;
//    layer.timeOffset = 0.0f;
//    layer.beginTime = 0.0f;
//    CFTimeInterval time_since_pause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - paused_time;
//    layer.beginTime = time_since_pause;
}

- (void)fadeAnimation:(UIView *)view inContainer:(UIView *)container { //TODO: Fix ugly animation
    
    SGFeedView * feeder;
    
    if (![container isKindOfClass:[SGFeedView class]] || _isAnimating) {
        return;
    }
    
    feeder = (SGFeedView *)container;
    
    CGFloat delay = [self _fadeAnimationDelayForView:view];
    
    [UIView animateWithDuration:0.33
                          delay:delay
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         view.transform = CGAffineTransformMakeScale(0.98f, 0.8f);
                         view.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         
                         if (finished) {
                             
                             view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             if (_lastMessage) _lastMessage = NO;
                             
                             if (nil != feeder && !_animationStopped) {
                                 
                                 [feeder.feederDelegate updateLabelsForward:YES];
                                 [_animator addBehavior:_gravity];
                                 [_animator addBehavior:_collision];
                                 [_animator addBehavior:_elasticity];
                             }
                             else {
                                 
                                 [self removeBehaviorsFromView:feeder.currentMessage];
                                 [view removeFromSuperview];

                                 view.alpha = 1.0f;
                             }
                         }
                     }
     ];
}

- (void)updateItemUsingCurrentState:(id<UIDynamicItem>)item {
    
    [_animator updateItemUsingCurrentState:item];
}

- (void)addBehaviorsToView:(id<UIDynamicItem>)view {
    
    [_elasticity addItem:view];
    [_gravity addItem:view];
    [_collision addItem:view];
}

- (void)removeBehaviorsFromView:(id<UIDynamicItem>)view {
    
    [_elasticity removeItem:view];
    [_gravity removeItem:view];
    [_collision removeItem:view];
    [_push removeItem:view];
}

- (void)setCollisionDelegate:(id<UICollisionBehaviorDelegate>)delegate {
    
    if(nil == _collision) _collision = [[UICollisionBehavior alloc] init];
    _collision.collisionDelegate = delegate;
}
//TODO: documentation
- (BOOL)isRunning {
    
    return _animator.isRunning;
}

#pragma mark Private
/**
 *  Calculate the distance for the transition animation of the message label
 *
 *  @param feeder The current feeder
 *
 *  @return The distance for the animation
 */
- (CGFloat)_distanceForFeeder:(SGFeedView *)feedView {
    
    CGFloat distanceInPixels = 0.0f;
//    if (!_deviceRotated) {
    
        distanceInPixels = ceilf(feedView.currentMessage.width - feedView.width);
//    }
//    else  {
    
        if (feedView.isLeftToRight) {
            
            distanceInPixels = ceilf(feedView.currentMessage.right - feedView.right);
            
        }
        else {
            
            distanceInPixels = ceilf(feedView.left -  feedView.currentMessage.left);
        }
//    }
    
    if (0 > distanceInPixels) {

        if (!_lastMessage) {
            
            distanceInPixels = 0.0f;
        }
    }
    
    return distanceInPixels;
}
/**
 *  Calculate the fianl position for the message label in the transition animation
 *
 *  @param finalRect        The context Rect as reference
 *  @param feeder           The current feederView
 *  @param distanceInPixels The Distance used as an offset for the finalRect
 *
 *  @return True if the message is the last message. when it is the last message the distance in 
 *  pixels needs to be updated because it affects the total duratio of the animation.
*/
- (BOOL)_titleRect:(CGRect *)finalRect
         forFeedView:(SGFeedView *)feedView
       andDistance:(CGFloat)distanceInPixels{
    
    CGFloat isLeftToRight = (feedView.isLeftToRight) ? -1.0f: 1.0f;
        
    *finalRect = feedView.currentMessage.frame;
        
    if (0.0f < distanceInPixels) {
        
        *finalRect = CGRectOffset(feedView.currentMessage.frame , (distanceInPixels + LABEL_OFFSET_X * 2.0f) * isLeftToRight, 0.0f);
    }
    if (_lastMessage) {
        
        CGFloat lastMessageDistance = MIN(feedView.currentMessage.width + LABEL_OFFSET_X, _feedViewWidth);
        
        *finalRect = CGRectOffset(*finalRect, lastMessageDistance * isLeftToRight, 0.0f);
        
        return YES;
    }
    
    return NO;
}
/**
 *  Sets the initial position for the activity indicator according to leftToRight languages
 *
 *  @param activity The positioned activity
 *  @param feeder   The feederView to add the indicator to
 */
- (void)_initialPositioForActivityIndicator:(UIView *)activity
                             inControlView:(SGFeedControllerView *) controlView {
    
    if (controlView.isLeftToRight) {
        
        activity.center = CGPointMake(controlView.right + activity.width * 2.0f, controlView.height / 2.0f);
        
    }
    
    else {
        
         activity.center = CGPointMake(-activity.width * 2.0 , controlView.height / 2.0f);
    }
}
/**
 *  Creates the barrier that stops the activity indicator
 *  The barrier itself will not be added to the container view, it will be added to collision behavior 
 *  class member.
 *
 *  @param activity The current activity indicator
 *  @param feeder   The container view of the indicator, for calculation purposes
 *
 *  @return The barrier view created
 */
- (void)_barrierForActivity:(SGActivityIndicator *)activity inControlView:(SGFeedControllerView *)controlView {
    
    UIView * barrier;
    
    if (controlView.isLeftToRight) {
        
        barrier = [[UIView alloc] initWithFrame:CGRectMake(controlView.right - activity.width - ACTIVITY_OFFSET_X / 2.0f, 0.0f , 1.0f, controlView.height)];
    }
    else {
        
        barrier = [[UIView alloc] initWithFrame:CGRectMake( -ACTIVITY_OFFSET_X / 2.0f, 0.0f , 1.0f, controlView.height)];
    }
    
    CGPoint topEdge = CGPointMake(barrier.left, barrier.top);
    CGPoint bottomEdge = CGPointMake(barrier.left, barrier.bottom);
    
    [_collision addBoundaryWithIdentifier:@"barrier1" fromPoint:topEdge toPoint:bottomEdge];
}
/**
 *  The final rectangle of the feederView when adding/removing a activityIndicator
 *
 *  @param feeder   The feederView to animate
 *  @param activity The added/removed activity indicator
 *  @param isAdding A boolian value representing wether the activity indicator is being added or being
 *  removed
 *
 *  @return The final frame of the feederView to be animated
 */
- (CGRect)_finalRectForControlView:(SGFeedControllerView *)controlView
                          activity:(SGActivityIndicator *)activity
                    addingActivity:(BOOL)isAdding {
        
        CGRect rect;
        
        CGFloat adding = (isAdding) ? 1.0f : -1.0f;
        
        if (controlView.isLeftToRight) {
            
            rect = CGRectMake(controlView.left, controlView.top, controlView.width - (activity.width * adding), controlView.height);
        }
        else {
            
            rect = CGRectMake(controlView.left + (activity.width * adding), controlView.top, (controlView.width - activity.width * adding), controlView.height);
        }
        
        return  rect;
    }

- (CGFloat)_fadeAnimationDelayForView:(UIView *)view {
    
    CGFloat delay = 0.0f;
    
    if (!_animationStopped && !_lastMessage) {
        
        delay = (_feedViewWidth < view.width + FEED_DIFERENTIAL)? 2.0 : 3.0;
        
        if ([UIDevice currentDevice].orientation & (UIDeviceOrientationLandscapeLeft|
                                                    UIDeviceOrientationLandscapeRight)) {
            delay = (_feedViewWidth < view.width + FEED_DIFERENTIAL)? 2.0 : 4.0;
        }
    }
    
    return delay;
}

#pragma mark UIDeviceOrientation

- (void)resetAnimation:(SGFeedView *)feedView {
 
//     && _feedView.width < _feedView.currentMessage.width
//    _deviceRotated = YES;
    UIView * currentMessage = feedView.currentMessage;
    if (feedView.isLeftToRight) {
        
        if (_isAnimating) {
            
            if (currentMessage.right > feedView.right - LABEL_OFFSET_X) {
            
                [feedView resetPosition:currentMessage.left];
                
            }
            else {
                
                [feedView resetPosition:LABEL_OFFSET_X];
            }
            
            [self startPushAnimation:feedView];
        }
        else {
            
            if (currentMessage.right > feedView.right - LABEL_OFFSET_X) {
                
                [feedView resetPosition:currentMessage.left];
                [self startPushAnimation:feedView];
            }
            else {
                
                [feedView resetPosition:LABEL_OFFSET_X];
            }
        }
    }
    else {
        if (_isAnimating) {
            
            if (currentMessage.left < feedView.left + LABEL_OFFSET_X) {
             
                [feedView resetPosition:currentMessage.right];
//                [self startPushAnimation:feedView];
            }
            else [feedView resetPosition:feedView.right - LABEL_OFFSET_X];
        }
    }
}

@end
