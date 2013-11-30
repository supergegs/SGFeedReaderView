//
//  SGFeederView.h
//  SGFeeder
//
//  Created by Guy Lachish on 10/19/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  The SGFeederView's delegate used to pass messages to the SGFeederController
 */
@protocol SGFeedViewDelegete <NSObject>

@required
/**
 *  If the delegate is not nil, this method is invoked when the current message label ends it's 
 *  transition animation, letting the controller handle the text and position updates of the next message.
 *
 *  @param forward Future use, always set to YES
 */
- (void) updateLabelsForward:(BOOL)forward;

@end

/**
 *  SGFeedView inherits from UIView. It is the container view responsible for showing feed messages.
 *  The appearance of this view is highly oriented to meet the iOS 7 flat design.
 *  You may control some properties that will affect the appearance of this view
 *  such as the textColor, the boundingBox color, the text animation direction and speed, and more...,
 *  but notice that it will always keep the iOS7 like flat design.
 *  It is possible to use default styles through the SGFeederViewStyle enum, in this case there is no need
 *  assigning the view properties, but if you wish you may use these styles in conjunction with the
 *  custom properties, the style will adopt custom set properties that are relevant to it.
 *
 *  It is a pure view in regards of the MVC design pattern, the messages displayed
 *  in the view are passed to it through the SGFeederController and its animations are commited through
 *  SGAnimationController
 */
@interface SGFeedView : UIView

@property (nonatomic, retain)UILabel * currentMessage;
@property (nonatomic, assign)CGFloat speed; // pixels per second in animation
@property (nonatomic, assign)BOOL isLeftToRight;
@property (nonatomic, retain)UIColor * textColor;
@property (nonatomic, retain)id<SGFeedViewDelegete> feederDelegate;
/**
 *  Sets the label position at the initial state ready for entering the view
 */
- (void)resetMessagePosition;

- (void)resetPosition:(CGFloat)x;
/**
 *  Sets the properties and text of the view's message label, must be called once before the first activation of the view.
 *  Generaly there is no need in calling this method since the SGFeederController manages the view's
 *  calibration for you.
 */
- (void)calibrate;



@end
