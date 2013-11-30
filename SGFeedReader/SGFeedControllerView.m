//
//  SGFeederController.m
//  SGFeeder
//
//  Created by Guy Lachish on 11/2/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//



#import "SGFeedControllerView.h"
#import "SGFeedView.h"
#import "SGAnimationController.h"
#import "SGActivityIndicator.h"
#import "SGXMLDataParser.h"
#import "UIView+UIViewExtensions.h"

@interface SGFeedControllerView() <SGFeedViewDelegete, UICollisionBehaviorDelegate>

@end

@implementation SGFeedControllerView {
    
    SGXMLDataParser * _parser;
    SGActivityIndicator * _activity;
    SGFeedView * _feedView;
    BOOL _firstContact;
    BOOL _timerInvalidated;
    int _currentIndex;
    
    NSArray * _xmlRootElements;
    NSString * _xmlDateElement;
    NSString * _xmlTitleElement;
    
}
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
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    
    CGFloat maxBoxRadius = self.height / 2.0f;
    
    if (maxBoxRadius < _boxRadius) {
        _boxRadius = maxBoxRadius;
    }
    
    layer.cornerRadius = _boxRadius;
    layer.opaque = NO;
    
    switch (self.style) {
            
        case SGFeedFrostedGlassStyle:
        {
            
            layer.borderWidth = 1.0f;
            layer.borderColor = (nil != _boxColor) ? _boxColor.CGColor : [UIColor colorWithWhite:1.0f alpha:0.35f].CGColor;
            _textColor = (nil != _boxColor) ? _boxColor :[UIColor colorWithWhite:1.0f alpha:0.35f];
            
        }
            break;
            
        case SGFeedFilledBoxStyle:
        {
            if (nil == _textColor) _textColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
            [layer setBackgroundColor: (nil != _backgroundColor) ? _backgroundColor.CGColor : [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor ];
        }
            break;
            
        case SGFeedBoundingBoxStyle:
        default:
            layer.borderColor = (nil != _boxColor) ? _boxColor.CGColor :self.tintColor.CGColor;
            layer.borderWidth = 1.0f;
            _textColor = (nil != _textColor) ? _textColor : [UIColor colorWithCGColor: layer.borderColor];
            break;
    }
    
    CGLayerRef ref = CGLayerCreateWithContext(ctx, self.bounds.size, NULL);
    CGContextDrawLayerAtPoint(ctx, CGPointZero, ref);
    CGLayerRelease(ref);
}

- (void)_setDefaultValues {

    //       Default values
    //       ==============
    _boxRadius = self.height / 2.0f;
    _speed = 35.0f;
    _isLeftToRight = YES;
    
    _firstContact = YES;
    _currentIndex = 0;
    _timerInvalidated = YES;
    
    //    self.transform = CGAffineTransformIdentity;
    //    Min. height for the view is 16.0f
    if (16.0f > self.height) self.frame = CGRectMake(self.left, self.top, self.width, 16.0f);
    [self _addObsevers];
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    [animator setWidth:[UIScreen mainScreen].bounds.size.width];
}

- (void)setXMLRootElements:(NSArray *)  rootElements
                     title:(NSString *) titleElement
                      date:(NSString *) dateElement
                    andURL:(NSString *)urlString {
    
    _xmlRootElements = rootElements;
    _xmlTitleElement = titleElement;
    _xmlDateElement = dateElement;
    _url = urlString;
}

- (void)activate {
    
    if (nil == _url || !_timerInvalidated) {
            return;
    }
    
    [self _addFeedView];
    [self _addActivationTimer];
    _timerInvalidated = NO;
    
    if (nil == _activity) {
        
        _activity = [[SGActivityIndicator alloc] initWithHeight:self.height color:self.themeColor];
        if (_isLeftToRight) {
            
            [_activity setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin];
        }
    }
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    [animator setCollisionDelegate:self];
    [animator addActivityIndicator:_activity forView:self];
    
    if (nil == _parser) {
        
        _parser = [[SGXMLDataParser alloc] initWithRootElements:_xmlRootElements textElement:_xmlTitleElement dateElement:_xmlDateElement];
    }
    
    [_parser request:_url];
}

- (void)reload {
    
    if (_timerInvalidated) {
        
        SGAnimationController * animator = [SGAnimationController sharedAnimator];
        [animator stopAnimation:_feedView];
        [_feedView removeFromSuperview];
        _currentIndex = 0;
        _firstContact = YES;
    
        [self performSelector:@selector(activate) withObject:nil afterDelay:0.4];
    }
}

- (void)ready {
    
    _feedView.currentMessage.hidden = NO;
    self.layer.masksToBounds = YES;
}

- (UIColor *)themeColor {
    
    switch (self.style) {
            
        case SGFeedFrostedGlassStyle:
            
            return [UIColor colorWithCGColor:self.layer.borderColor];
            break;
        case SGFeedFilledBoxStyle:
            
            return [UIColor colorWithCGColor:self.layer.backgroundColor];
            break;
        case SGFeedBoundingBoxStyle:
        default:
            
            return [UIColor colorWithCGColor:self.layer.borderColor];
            break;
    }
}

#pragma mark SGFeederViewDelegate

- (void) updateLabelsForward:(BOOL)forward {
    
    _firstContact = YES;
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    
//    [animator removeBehaviorFromView:_feedView.currentMessage];
    
    _currentIndex += (forward) ? 1 : -1;
    if ( 0 > _currentIndex) _currentIndex += _dataList.count;
    
    int index = _currentIndex % _dataList.count;
    
    _feedView.currentMessage.text = _dataList[index];
    
    [_feedView resetMessagePosition];
    
    [animator addBehaviorsToView:_feedView.currentMessage];
    [animator updateItemUsingCurrentState:_feedView.currentMessage];
    
}

#pragma mark CollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior
      endedContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier {
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    
    if (_firstContact ) {
        
        if ([item isKindOfClass:[UILabel class]] && ![animator animationStopped]) {
            
            _firstContact = NO;

            if ( _dataList.count == (_currentIndex % _dataList.count) + 1) {
                
                animator.lastMessage = YES;
            }
            [animator performSelector:@selector(startPushAnimation:) withObject:_feedView afterDelay:1.0f];
        }
        else if ([item isKindOfClass:[SGActivityIndicator class]]) {
            
            SGActivityIndicator * activity = (SGActivityIndicator *)item;
            [activity performSelector:@selector(start) withObject:nil afterDelay:0.1];
            _firstContact = NO;
        }
    }
}


#pragma mark Notifications
/**
 *  Activate the SGFeederView, if the data is loaded successfully a notification will raise this method
 *
 *  @param notification The notification, holding the data
 */
- (void)dataLoaded:(NSNotification *)notification {
    
    if (nil != _dataList)  _dataList = nil;
    _dataList = [notification.userInfo objectForKey:@"messages"];
    
    _feedView.currentMessage.text = _dataList[_currentIndex];
    if (!_feedView.isLeftToRight && _feedView.currentMessage.autoresizingMask == UIViewAutoresizingNone) {
        
        [_feedView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleWidth];
        [_feedView.currentMessage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleTopMargin];

//        [self setContentMode:UIViewContentModeBottomRight];
    }
    else if (_feedView.currentMessage.autoresizingMask == UIViewAutoresizingNone) {
        
        [_feedView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
         UIViewAutoresizingFlexibleTopMargin |
         UIViewAutoresizingFlexibleWidth];
        [_feedView.currentMessage setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin |
         UIViewAutoresizingFlexibleTopMargin];
    }
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    
    [self performSelector:@selector(_removeActivityIndicator) withObject:nil afterDelay:1.5f];
    
    [animator performSelector:@selector(attachGravityToFeedView:) withObject:_feedView afterDelay:3.0f];
}
/**
 *  Remove the feederView if an error occured.
 *  Raised by a notification.
 */
- (void)removeFeedView {
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    [self _removeActivityIndicator];
    [animator performSelector:@selector(removeFeeder:) withObject:_feedView afterDelay:1.5f];
    
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenWidth = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? screenSize.height : screenSize.width;
    
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    [animator setWidth:screenWidth];
    
    if (nil != _activity && _activity.isVisible && _isLeftToRight) {
        
        [_activity resetPosition];
    }
    
//    if (nil != _feedView) {
//        
//        [animator resetAnimation:_feedView];
//    }
}

#pragma mark Private
/** TODO: documentation
 *  Add a SGFeedView to view
 */
- (void)_addFeedView {
    
    _feedView = [[SGFeedView alloc] initWithFrame:self.bounds];
    _feedView.textColor = _textColor;
    _feedView.isLeftToRight = _isLeftToRight;
    _feedView.speed = _speed;
    _feedView.feederDelegate = self;
    
    [self addSubview:_feedView];
}

- (void)_addObsevers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoaded:)
                                                 name:@"MESSAGES_LOADED"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeFeedView)
                                                 name:@"REQUEST_FAILED"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleDeviceOrientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)_removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"MESSAGES_LOADED"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"REQUEST_FAILED"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UIDeviceOrientationDidChangeNotification
                                                 object:nil];
    
}

/**
 *  Remove the activity indicator
 */
- (void)_removeActivityIndicator {
    
    _firstContact = YES;
    SGAnimationController * animator = [SGAnimationController sharedAnimator];
    [animator removeActivityIndicator:_activity forView:self];
}
/**
 *  Prevent multiple reloads for 5 seconds between one and another
 */
- (void)_addActivationTimer {
    
    
    NSRunLoop * runloop = [NSRunLoop mainRunLoop];
    
    NSDate * date = [[NSDate alloc] initWithTimeInterval:5.0f sinceDate:[NSDate date]];
    
    
    NSTimer * timer = [[NSTimer alloc] initWithFireDate:date interval:0.0f target:self selector:@selector(_timerFireMethod:) userInfo:nil repeats:NO];
    
    [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
}
/**
 *  invalidte the reloadBlock timer
 *
 *  @param timer The timer that fired the method
 */
- (void)_timerFireMethod:(NSTimer *)timer {
    _timerInvalidated = YES;
    
    [timer invalidate];
}
    
@end
