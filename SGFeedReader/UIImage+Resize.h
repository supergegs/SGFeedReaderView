
#import <UIKit/UIKit.h>

// Handy category on UIImage to resize an image. It ignores the aspect-ratio
// of the image (same effect as UIViewContentModeScaleToFill).
//
@interface UIImage (Resize)

- (UIImage *)resizedImageWithSize:(CGSize)size;

@end
