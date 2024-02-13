#import <Foundation/Foundation.h>
#import "AEFCUBIntegerSliderCellController.h"

@implementation AEFCUBIntegerSliderCellController
    - (id)init {
        return [super init];
    }
    
    - (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

        return self;
    }

    - (void)controlChanged:(id)arg1 {
        PSSegmentableSlider *slider = (PSSegmentableSlider *)arg1;

        slider.value = lroundf(slider.value);

        [super controlChanged:slider];
    }

    - (void)setControl:(UIControl *)arg1 {
        [super setControl:arg1];
    }

    - (id)titleLabel {
        id orig = [super titleLabel];

        return orig;
    }

    - (void)setValue:(id)value {
        // Call the original setValue: method
        [super setValue:value];

        // Round the float to a whole number aka integer
        float fValue = lroundf([value floatValue]);
        NSNumber *numValue = [NSNumber numberWithFloat:fValue];
        [super setValue:numValue];
    }
@end