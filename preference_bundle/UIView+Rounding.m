#import "UIView+Rounding.h"

@implementation UIView (Rounding)

- (void)roundCorners:(UIViewCorners)corners radius:(CGFloat)radius {
    self.clipsToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.maskedCorners = (CACornerMask)corners;
}

@end