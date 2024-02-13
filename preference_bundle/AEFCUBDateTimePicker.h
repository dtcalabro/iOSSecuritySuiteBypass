#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <UIKit/UIKit.h>
#import "AEFCUBDateTimePickerView.h"
#import "AEFCUBBaseTableCell.h"

@interface AEFCUBDateTimePicker : AEFCUBBaseTableCell {
	AEFCUBDateTimePickerView *_dateTimePickerView;
	UIViewController *_rootViewController;
    AEFCUBDateTimePickerStyle _dateTimePickerStyle;
}
@property (nonatomic, retain) AEFCUBDateTimePickerView *dateTimePickerView;
@property (nonatomic, retain) UIViewController *rootViewController;
//@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
//@property (nonatomic, retain) UIView *dimBackgroundView;

@property (nonatomic) AEFCUBDateTimePickerStyle dateTimePickerStyle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier withPickerStyle:(AEFCUBDateTimePickerStyle)pickerStyle;

- (void)presentDateTimePicker;
- (void)setDateTimePickerStyle:(AEFCUBDateTimePickerStyle)style;
- (AEFCUBDateTimePickerStyle)dateTimePickerStyle;
- (void)updateValueLabel;
@end
