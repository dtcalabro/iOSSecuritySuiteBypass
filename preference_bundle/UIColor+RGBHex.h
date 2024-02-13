#import <UIKit/UIKit.h>

@interface UIColor (RGBHex)
+ (UIColor *)colorFromHex:(NSInteger)rgbHexValue;
+ (UIColor *)colorFromHexString:(NSString *)rgbHexStringValue;
@end