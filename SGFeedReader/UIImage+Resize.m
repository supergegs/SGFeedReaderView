
#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizedImageWithSize:(CGSize)size
{
	UIGraphicsBeginImageContextWithOptions(size, YES, 0.0f);
	[self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
