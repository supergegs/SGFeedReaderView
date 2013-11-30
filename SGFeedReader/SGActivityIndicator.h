//
//  SGActivityIndicator.h
//  SGFeeder
//
//  Created by Guy Lachish on 10/22/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
/**
 *  SGActivityIndicator inherits UIView. This view is a simple custom activity indicator
 *  matching the SGFeederView appearance style. The object is responsible for animating its path with
 *  its layer once activated through the start/stop method, but the SGAnimationController is 
 *  responsible for the transition animations.
 *
 *  Generaly explicit creation of this object is redundant,
 *  the SGFeederController will create and handle it for you
 */
@interface SGActivityIndicator : UIView


@property (nonatomic, assign)CGColorRef cgColor;
@property (nonatomic,assign)BOOL isVisible;
@property (nonatomic,assign)BOOL isAnimating;
/**
 *  C'tor
 *
 *  @param height The height for the indicator, results in size with height x height
 *  @param color  The color for the indicator
 *
 *  @return A class instancetype
 */
- (instancetype)initWithHeight:(CGFloat)height color:(UIColor *)color;
/**
 *  Start animating the activity indicator
 */
- (void)start;
/**
 *  Stop animating the activity indicator
 */
- (void)stop;

//- (void)resetActivityPosition:(CGFloat)right; //TODO: add documentation
- (void)resetPosition;
@end
