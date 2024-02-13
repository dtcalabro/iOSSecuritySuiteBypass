#import "AEFCUBDateAndTimePicker.h"

@implementation AEFCUBDateAndTimePicker

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier withPickerStyle:AEFCUBDateTimePickerStyleDateAndTime];

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)presentDateAndTimePicker {
    [super presentDateTimePicker];
}

@end