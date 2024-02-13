#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <UIKit/UIKit.h>
#import <notify.h>
#import "AEFCUBCommonHeader.h"

typedef NS_ENUM(NSInteger, AEFCUBDateTimePickerStyle) {
        AEFCUBDateTimePickerStyleDate,
        AEFCUBDateTimePickerStyleTime,
        AEFCUBDateTimePickerStyleTimeInterval,
        AEFCUBDateTimePickerStyleDateAndTime
};

@interface AEFCUBDateTimePickerView : UIView {
	UIView *_backgroundView;
	UIView *_bodyView;
	UIDatePicker *_dateTimePicker;
	UIButton *_cancelButton;
	UIButton *_submitButton;
	NSTimeInterval _timeIntervalValue;
    NSDate *_dateValue;
	NSString *_key;
    NSString *_defaultValue;
	NSString *_defaults;
	NSString *_postNotification;
    AEFCUBDateTimePickerStyle _dateTimePickerStyle;
}
@property (nonatomic, strong) NSBundle *preferenceBundle;
@property (nonatomic, retain) UIColor *interactionTintColor;
@property (nonatomic, retain) UIColor *themeTintColor;

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *bodyView;
@property (nonatomic, retain) UIDatePicker *dateTimePicker;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *submitButton;

@property (nonatomic, assign) NSTimeInterval timeIntervalValue;
@property (nonatomic, retain) NSDate *dateValue;

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *defaultValue;
@property (nonatomic, retain) NSString *defaults;
@property (nonatomic, retain) NSString *postNotification;

@property (nonatomic, retain) UIColor *dateTimePickerBodyColor;
@property (nonatomic, retain) UIColor *dateTimePickerButtonColor;
@property (nonatomic, assign) CGFloat dateTimePickerBackgroundViewAlpha;

@property (nonatomic) AEFCUBDateTimePickerStyle dateTimePickerStyle;

- (instancetype)initWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor key:(NSString *)key defaults:(NSString *)defaults postNotification:(NSString *)postNotification;
- (instancetype)initWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor key:(NSString *)key defaultValue:(NSString *)defaultValue defaults:(NSString *)defaults postNotification:(NSString *)postNotification dateTimePickerStyle:(AEFCUBDateTimePickerStyle)dateTimePickerStyle;

- (NSString *)localizedStringForKey:(NSString *)key;

- (void)presentDateTimePicker;
- (void)cancelDateTimePicker;
- (void)submitDateTimePicker;

- (BOOL)isDarkModeEnabled;
@end
