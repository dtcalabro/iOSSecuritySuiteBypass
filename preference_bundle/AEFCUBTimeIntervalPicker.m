#import "AEFCUBTimeIntervalPicker.h"

@implementation AEFCUBTimeIntervalPicker

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier withPickerStyle:AEFCUBDateTimePickerStyleTimeInterval];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)presentTimeIntervalPicker {
    [super presentDateTimePicker];
}

@end