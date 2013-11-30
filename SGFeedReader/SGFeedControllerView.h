//
//  SGFeederController.h
//  SGFeeder
//
//  Created by Guy Lachish on 11/2/13.
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

typedef NS_ENUM(NSInteger, SGFeedViewStyle) {
    
    SGFeedBoundingBoxStyle,
    SGFeedFilledBoxStyle,
    SGFeedFrostedGlassStyle
};

@class SGFeedView;
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  SGFeederController inherits NSObject. This class conforms to the MVC design pattern
 *  and is targeted to control all the views and models in the SGFeedReaderView project.
 */
@interface SGFeedControllerView : UIView

/**
 *  Passing directives for the data request object
 *
 *  @param rootElements An array of all element names(NSString*) in the tree hirarchy leading to the 
 *  root elemnt weach is the direct ancestor of the enumeration elemnt, including the enumeration element
 *  itself.
 *  @param titleElement The title element string
 *  @param dateElement  the date elementstring
 *  @param urlString    The request URL as string
 */
- (void)setXMLRootElements:(NSArray *)rootElements
                     title:(NSString *)titleElement
                      date:(NSString *)dateElement
                    andURL:(NSString *)urlString;
/**
 *  Starts the SGFeeederView
 */
- (void)activate;
/**
 *  Restarts the SGFeederView
 *
 *  This method refreshes the messages held by the controller meaning it gets new messages if such exist.
 *  In conjunction with a timer it may refresh the data at a preset interval.
 */
- (void)reload;

/**
 *  TODO: add documentation
 */
- (void)ready;

//- (void)addFeedView;
/**
 *  An array holding the message strings to show in the SGFeederView
 */
@property (nonatomic, retain)NSArray * dataList;
/**
 *  Pixels per second
 */
@property (nonatomic, assign)CGFloat speed;
/**
 *  A Boolian value representing the language writing direction, YES: left to right languages, e.g. English..., NO: right to let languages, e.g. Hebrew, Arabic...
 */
@property (nonatomic, assign)BOOL isLeftToRight;
/**
 *  The feederView associated with the controller
 */

/**
 *  The address of the XML file as a string
 */
@property (nonatomic, strong)NSString * url;
@property (nonatomic, assign)CGFloat boxRadius;
@property (nonatomic, weak)UIColor * boxColor;
@property (nonatomic, weak)UIColor * backgroundColor;
@property (nonatomic, strong)UIColor * textColor;
@property (nonatomic, assign)SGFeedViewStyle style;

@end
