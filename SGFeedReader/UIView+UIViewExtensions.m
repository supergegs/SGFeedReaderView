//
//  UIView+UIViewExtensions.m
//  SGFeederView
//
//  Created by Guy Lachish on 10/18/13.
//  Copyright (c) 2013 Guy Lachish. All rights reserved.
//

#import "UIView+UIViewExtensions.h"

@implementation UIView (UIViewExtensions)

-(CGFloat)top{
   
    return self.frame.origin.y;
}

-(CGFloat)bottom {
    
    return self.frame.origin.y + self.frame.size.height;
}

-(CGFloat)left {
    
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
//    CGRect r = CGRectOffset(self.frame,  - self.left + x, 0.0f);
    self.frame = CGRectOffset(self.frame,  - self.left + x, 0.0f);
}

-(CGFloat)right {
    
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)x {
    
//    CGRect r = CGRectOffset(self.frame,  - self.right + x, 0.0f);
    self.frame = CGRectOffset(self.frame,  - self.right + x, 0.0f);
}

-(CGFloat)height {
    
    return self.bounds.size.height;
}

-(CGFloat)width {
    
    return self.bounds.size.width;
}

@end
