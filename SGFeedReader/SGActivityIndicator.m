//
//  SGActivityIndicator.m
//  SGFeeder
//
//  Created by Guy Lachish on 10/22/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#define ACTIVITY_ORIENTATION_OFFSET 15.0f

#import "SGActivityIndicator.h"
#import "UIView+UIViewExtensions.h"
#import "AppDelegate.h"
#import "SGAnimationController.h"

static BOOL switchColor; // YES == blueLayer, NO == whiteLayer, determine the next animated layer

@interface SGActivityIndicator () {
    
    CAShapeLayer * _circleShapeLayer;
    UIColor * _color;
    BOOL _stopAnimation;
    UIBezierPath * _path;
    CABasicAnimation * _drawCircle;
    CABasicAnimation * _deleteCircle;
}

@property (nonatomic, assign)BOOL isDirectionRight;
@property (nonatomic, assign)CGFloat height;

@end

@implementation SGActivityIndicator

-(instancetype)initWithHeight:(CGFloat)height color:(UIColor *)color {
    
    CGRect frame = CGRectMake(0.0, 0.0, height, height);
    
    if (self = [super initWithFrame:frame]) {
        
        self.frame = frame;
        _height = height;
        _isDirectionRight = YES;
        self.backgroundColor = [UIColor whiteColor];
        switchColor = YES;
        _color = (nil != color) ? color : self.tintColor;
        [self setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleTopMargin];
        
        
    }
    
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    [self _createLayerAnimations];
    
    _path = [self _curvePathWithOrigin:CGPointMake(self.width / 2.0f, self.height / 2.0f) andRadius:self.width / 2.0f - 1.0f];
    
    _circleShapeLayer             = [CAShapeLayer layer];
    _circleShapeLayer.path        = _path.CGPath;
    _circleShapeLayer.strokeColor = _color.CGColor;
    _circleShapeLayer.fillColor   = nil;
    _circleShapeLayer.lineWidth   = 2.0f;
    _circleShapeLayer.lineJoin    = kCGLineJoinMiter;
    _circleShapeLayer.lineCap     = kCALineCapRound;
    _circleShapeLayer.hidden = YES;
    
    [self.layer addSublayer:_circleShapeLayer];
    
//    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    self.layer.cornerRadius = ceilf(self.width / 2.0f);
    self.layer.borderWidth = 1.0;
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.layer.borderColor = _color.CGColor;
}


- (void)layoutSubviews {
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
//    && [animator isRunning];
    if (_isVisible && !_isDirectionRight) [animator updateItemUsingCurrentState:self];
}


#pragma mark Private
/**
 *  Build a circle path for the animated CAShapeLayer
 *
 *  @param origin The center of the path
 *  @param radius The radius of the path
 *
 *  @return The circle path created
 */
- (UIBezierPath *)_curvePathWithOrigin:(CGPoint)origin
                            andRadius:(CGFloat)radius {
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:origin
                                          radius: radius - 1.0f
                                      startAngle: -M_PI * 0.5f
                                        endAngle: M_PI * 1.5f
                                       clockwise: YES
                           ];
    
    

    path.lineWidth = 2.0;
    
    return path;
    
}
/**
 *  Create the animation CAShapeLayer
 */
- (void)_createLayerAnimations {
    
    _drawCircle = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    _drawCircle.fromValue         = @(0.0f);
    _drawCircle.toValue           = @(1.0f);
    _drawCircle.duration          = 1.0f;
    _drawCircle.repeatCount       = 1;
    _drawCircle.delegate          = self;
    
    _deleteCircle = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    _deleteCircle.fromValue         = @(0.0f);
    _deleteCircle.toValue           = @(1.0f);
    _deleteCircle.duration          = 1.0f;
    _deleteCircle.repeatCount       = 1;
    _deleteCircle.delegate          = self;
}

#pragma mark Public

- (void)start {
    
    _circleShapeLayer.hidden = NO;
    _stopAnimation = NO;
    _isAnimating = YES;
    
    if (switchColor) {
        
        [_circleShapeLayer addAnimation:_drawCircle forKey:@"strokeEnd"];
    }
    else {
        
        [_circleShapeLayer addAnimation:_deleteCircle forKey:@"strokeEnd"];
    }

    switchColor = !switchColor;
}

- (void) stop {
    
    _stopAnimation = YES;
    
    [_circleShapeLayer removeAnimationForKey:@"strokedEnd"];
    _circleShapeLayer.hidden = YES;
    switchColor = YES;
}

// called when animation starts

//- (void)animationDidStart:(CAAnimation *)anim {
//    
//    
//}
- (void)resetPosition {
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    [animator removeBehaviorsFromView:self];
    
    CGFloat landscape = [UIScreen mainScreen].bounds.size.height - ACTIVITY_ORIENTATION_OFFSET;
    CGFloat portrait = [UIScreen mainScreen].bounds.size.width - ACTIVITY_ORIENTATION_OFFSET;
    
    CGFloat right = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) ? landscape : portrait;
    
    [self setRight:right];
    [animator updateItemUsingCurrentState:self];
    if (!_isAnimating) {
        
        [self start];
    }
}

#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if (!_stopAnimation) {
        
        [self start];
    }
    else {
        _isAnimating = NO;
    }
}

@end
