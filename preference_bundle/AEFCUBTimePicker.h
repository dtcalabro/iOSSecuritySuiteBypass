#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <UIKit/UIKit.h>
#import "AEFCUBDateTimePicker.h"

@interface AEFCUBTimePicker : AEFCUBDateTimePicker {
    AEFCUBDateTimePickerView *_timePickerView;
}

@property (nonatomic, retain) AEFCUBDateTimePickerView *timePickerView;
@end