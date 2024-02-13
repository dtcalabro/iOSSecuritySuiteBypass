#import "UIColor+RGBHex.h"

@implementation UIColor (RGBHex)

+ (UIColor *)colorFromHex:(NSInteger)rgbHexValue {
    return [UIColor colorWithRed:((float)((rgbHexValue & 0xFF0000) >> 16))/255.0 
                    green:((float)((rgbHexValue & 0xFF00) >> 8))/255.0 
                    blue:((float)(rgbHexValue & 0xFF))/255.0 
                    alpha:1.0];
}

+ (UIColor *)colorFromHexString:(NSString *)rgbHexStringValue {
    unsigned int rgbHexValue = 0x000000;

    if ([rgbHexStringValue hasPrefix:@"0x"]) {
        NSString *plainRGBHexStringValue = [rgbHexStringValue stringByReplacingOccurrencesOfString:@"0x" withString:@""];

        [[NSScanner scannerWithString:plainRGBHexStringValue] scanHexInt:&rgbHexValue];
    } else if ([rgbHexStringValue hasPrefix:@"#"]) {
        NSString *plainRGBHexStringValue = [rgbHexStringValue stringByReplacingOccurrencesOfString:@"#" withString:@""];

        [[NSScanner scannerWithString:plainRGBHexStringValue] scanHexInt:&rgbHexValue];
    }

    return [UIColor colorWithRed:((float)((rgbHexValue & 0xFF0000) >> 16))/255.0 
                    green:((float)((rgbHexValue & 0xFF00) >> 8))/255.0 
                    blue:((float)(rgbHexValue & 0xFF))/255.0 
                    alpha:1.0];    
}

@end