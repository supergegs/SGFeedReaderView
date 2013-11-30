//
//  SGAnimationController.h
//  SGFeeder
//
//  Created by Guy Lachish on 11/2/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//
@class SGFeedView;
@class SGFeedControllerView;
@class SGActivityIndicator;
#import <Foundation/Foundation.h>

/**
 *  SGAnimationController inherits NSObject.
 *
 *  This class is a singletone, the instance is accesible via the sharedAnimator static and thread
 *  safe method.
 *
 *  The class is provides almost all animations in the SGFeedReaderView project, it is using
 *  the iOS7 UIDynamic Kit to apply physics over some of the animated objects.
 *  Most of the animations are trigered by the SGFeederController, but in some cases if updates in
 *  the animated object state is needed the object can triger animations itself
 *
 *  There is no need in explicit creation of this object, the SGFeederController will create it for you
 */
@interface SGAnimationController : NSObject
@property (nonatomic,assign)BOOL lastMessage;

/**
 *  Static and thread safe instance creation
 *
 *  @return A singletone instance of the SGAnimationController
 */
+ (instancetype)sharedAnimator;

/**
 *  Adds physics to the view to apply forces over it
 *
 *  @param feederView The view to attach the behaviors to
 */
- (void)attachGravityToFeedView:(SGFeedView *)feedView;
/**
 *  Remove the feederView from screen
 *
 *  @param feeder The feederView to remove
 */
- (void)removeFeeder:(SGFeedView *)feedView;
/**
 *  The Activation method of the view
 *
 *  @param feeder The view to activate
 */
- (void)startPushAnimation:(SGFeedView *)feedView;
/**
 *  Stop the view's animation, fades the current message, must be called before the view is reloaded
 *
 *  @param feeder The feederView to stop
 */
- (void)stopAnimation:(SGFeedView *)feedView;

- (void)pauseLayer:(CALayer*)layer;
/**TODO:updte doc
 *  Animate in an SGActivityIndicator
 *
 *  @param indicator The indicator to animate in
 *  @param feeder    The feederView on which the indicator will be added
 */
- (void)addActivityIndicator:(SGActivityIndicator *)indicator forView:(SGFeedControllerView *)contorlView;
/**TODO:updte doc
 *  Animating out an SGActivityIndicator
 *
 *  @param activity The indicator to remove
 *  @param feeder   The container view of the Indicator
 */
- (void)removeActivityIndicator:(SGActivityIndicator *)activity forView:(SGFeedControllerView *)contorlView;

/**
 *  Update the animator (UIDynamicAnimator*) class member with a view's state
 *
 *  @param item An object that adopts the UIDynamicItem protocol, usually a UIview
 */
- (void)updateItemUsingCurrentState:(id<UIDynamicItem>)item;
/**
 *  Set the screen width
 *
 *  @param width width
 */
- (void)setWidth:(CGFloat)width ;
/**
 *  Set a delegete for the collision (UICollisioBehavior*) class member, basicaly its is always the 
 *  SGFeederController class.
 *
 *  @param delegate A class that implements the UICollisionBehaviorDelegate protocol
 */
- (void)setCollisionDelegate:(id<UICollisionBehaviorDelegate>)delegate;
/**
 *  Adds grvity and collision behaviors to a given view
 *
 *  @param view The view to weach the behaviors should be attached
 */
- (void)addBehaviorsToView:(id<UIDynamicItem>)view;
/**
 *  Remove the gravity and collision behaviors from a given view
 *
 *  @param view The view from weach we remove the behaviors
 */
- (void)removeBehaviorsFromView:(id<UIDynamicItem>)view;
/**
 *  The SGFeederView animation is mostly trigerred from state to state, when one animation ends it will
 *  call the next one, and so on... until it is stoppped explicitly;   this method passes the wished
 *  animation's state.
 *
 *  @return A boolian value indicating if the animation was stopped explicitly
 */
- (BOOL)animationStopped;
- (BOOL)isRunning;
- (void)resetAnimation:(UIView *)feedView;
@end
