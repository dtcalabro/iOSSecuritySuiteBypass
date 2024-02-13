#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, UIViewCorners) {
    UIViewCornersTopLeft = kCALayerMinXMinYCorner,
    UIViewCornersTopRight = kCALayerMaxXMinYCorner,
    UIViewCornersBottomLeft = kCALayerMinXMaxYCorner,
    UIViewCornersBottomRight = kCALayerMaxXMaxYCorner,

    UIViewCornersTop = UIViewCornersTopLeft | UIViewCornersTopRight,
    UIViewCornersBottom = UIViewCornersBottomLeft | UIViewCornersBottomRight,

    UIViewCornersAll = UIViewCornersTop | UIViewCornersBottom,
    
    UIViewCornersAllButTopLeft = UIViewCornersTopRight | UIViewCornersBottomLeft | UIViewCornersBottomRight,
    UIViewCornersAllButTopRight = UIViewCornersTopLeft | UIViewCornersBottomLeft | UIViewCornersBottomRight,
    UIViewCornersAllButBottomLeft = UIViewCornersTopLeft | UIViewCornersTopRight | UIViewCornersBottomRight,
    UIViewCornersAllButBottomRight = UIViewCornersTopLeft | UIViewCornersTopRight | UIViewCornersBottomLeft,
    UIViewCornersLeft = UIViewCornersTopLeft | UIViewCornersBottomLeft,
    UIViewCornersRight = UIViewCornersTopRight | UIViewCornersBottomRight,
    UIViewCornersTopLeftBottomRight = UIViewCornersTopLeft | UIViewCornersBottomRight,
    UIViewCornersTopRightBottomLeft = UIViewCornersTopRight | UIViewCornersBottomLeft
};

@interface UIView (Rounding)
- (void)roundCorners:(UIViewCorners)corners radius:(CGFloat)radius;
@end