//
//  ViewController.m
//  SGFeeder
//
//  Created by Guy Lachish on 10/19/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#import "ViewController.h"
#import "SGFeedView.h"
#import "UIView+UIViewExtensions.h"
#import "SGActivityIndicator.h"
#import "SGFeedControllerView.h"
#import "SGAnimationController.h"
#import "UIImage+ImageEffects.h"

//  Test URLs, the first two are right to left language

//http://www.ynet.co.il/Integration/StoryRss1854.xml = ynet
//http://rcs.mako.co.il/rss/Sports-football-world.xml = mako
//http://images.apple.com/main/rss/hotnews/hotnews.rss = apple
//http://feeds.bbci.co.uk/news/rss.xml = BBC
//https://news.google.com/news/feeds?pz=1&cf=all&ned=en_il&hl=en&output=rss = google news
static NSString * xmlUrl = @"https://news.google.com/news/feeds?pz=1&cf=all&ned=en_il&hl=en&output=rss";

@interface ViewController ()

@property (nonatomic, strong) IBOutlet SGFeedControllerView * feedController;

- (IBAction)click:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    
    
    
//    Configuration
//    *************
//    *************
    
//    Custom appearance options

//    _feedController.isLeftToRight = NO; // default value is YES
//    _feedController.speed = 60.0f;
//    _feedController.boxColor = [UIColor colorWithRed:0.5f green:0.8f blue:0.3f alpha:1.0];
//    _feedController.textColor = [UIColor redColor];
//    _feedController.backgroundColor = [UIColor blueColor];
//    _feedController.boxRadius = 20.0f;
    
//  All suported styles :SGFeedFilledBoxStyle, SGFeedBoundingBoxStyle, SGFeedFrostedGlassStyle
//    _feedController.style = SGFeedFrostedGlassStyle;

    [_feedController setXMLRootElements:nil
                             title:nil
                              date:nil
                            andURL:xmlUrl];
    
//    Activation
//    **********
//    **********
    
//    Set the viewController's background image for the frostedGlassStyle
//    not a part of the feedReader's configuration

if (_feedController.style == SGFeedFrostedGlassStyle) {
    
    UIImage * bg = [UIImage imageNamed:@"pulpfiction"];
    
    UIColor *tintColor = [UIColor colorWithRed:140/255.0f green:70/255.0f blue:35/255.0f alpha:0.2f];
    UIImage *backgroundImage = [bg applyBlurWithRadius:4 tintColor:tintColor saturationDeltaFactor:0.8 maskImage:nil];
    
    UIImageView * iv = [[UIImageView alloc] initWithImage:backgroundImage];
    iv.frame = self.view.frame;
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    [iv setAutoresizesSubviews:YES];
    [self.view insertSubview:iv belowSubview:_feedController];
}

//  The delay is needed in order to see a glimps of the original feeder's frame
//  before it shrinks, in adition this small delay allows the feeder's drawRect function
//  to be drawn before the feeder is activated, it is essential because later on
//  other objects apperance ,currently the activityIndicator, are influenced by the
//  feeder's appearance
    
    [_feedController performSelector:@selector(activate) withObject:nil afterDelay:0.1f];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self finalize];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(id)sender {
    
    [_feedController reload];
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
//    
//    if (nil != _controller.feederView.currentMessage) {
//        
//        _controller.feederView.currentMessage.alpha = 0.0f;
//    }
//    [_controller performSelector:@selector(handleDeviceOrientationChange) withObject:nil afterDelay:duration];
//}

@end
