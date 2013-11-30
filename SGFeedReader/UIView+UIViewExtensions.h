//
//  UIView+UIViewExtensions.h
//  SGFeederView
//
//  Created by Guy Lachish on 10/18/13.
//  Copyright (c) 2013 Guy Lachish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIView (UIViewExtensions)

- (CGFloat)top;
- (CGFloat)bottom;
- (CGFloat)left;
- (CGFloat)right;
- (void)setRight:(CGFloat)value;
- (void)setLeft:(CGFloat)value;
- (CGFloat)height;
- (CGFloat)width;

@end
