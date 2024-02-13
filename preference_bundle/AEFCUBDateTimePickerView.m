#import <Foundation/Foundation.h>
#import "AEFCUBDateTimePickerView.h"

@interface UIView ()
- (UIViewController *)_viewControllerForAncestor;
@end

@implementation AEFCUBDateTimePickerView
@synthesize dateTimePickerStyle = _dateTimePickerStyle; // Associate the ivar w/property

- (id)init {
    return [super init];
}

- (instancetype)initWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor key:(NSString *)key defaults:(NSString *)defaults postNotification:(NSString *)postNotification {
    self = [super initWithFrame:frame];
    self.themeTintColor = tintColor;
    self.key = key;
    self.defaults = defaults;
    self.postNotification = postNotification;

    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:self.defaults];
	if ([prefsDict objectForKey:self.key] != nil) {
        if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
		    self.timeIntervalValue = [[prefsDict objectForKey:self.key] doubleValue];
        } else {
            self.dateValue = [prefsDict objectForKey:self.key];
        }
	} else {
        if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
		    self.timeIntervalValue = 60;
        } else {
            self.dateValue = [NSDate date];
        }
	}

    if ([self isDarkModeEnabled]) {
        self.dateTimePickerBodyColor = [UIColor secondarySystemBackgroundColor];
        self.dateTimePickerButtonColor = [UIColor tertiarySystemBackgroundColor];
        self.dateTimePickerBackgroundViewAlpha = 0.48;
    } else {
        self.dateTimePickerBodyColor = [UIColor secondarySystemBackgroundColor];
        self.dateTimePickerButtonColor = [UIColor systemBackgroundColor];
        self.dateTimePickerBackgroundViewAlpha = 0.2;
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tintColor:(UIColor *)tintColor key:(NSString *)key defaultValue:(NSString *)defaultValue defaults:(NSString *)defaults postNotification:(NSString *)postNotification dateTimePickerStyle:(AEFCUBDateTimePickerStyle)dateTimePickerStyle {
    self = [super initWithFrame:frame];
    self.themeTintColor = tintColor;
    self.key = key;
    self.defaultValue = defaultValue;
    self.defaults = defaults;
    self.postNotification = postNotification;
    self.dateTimePickerStyle = dateTimePickerStyle;

    NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:self.defaults] mutableCopy];
	if ([prefsDict objectForKey:self.key] != nil) {
        if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
		    self.timeIntervalValue = [[prefsDict objectForKey:self.key] doubleValue];
        } else {
            self.dateValue = [prefsDict objectForKey:self.key];
        }
	} else {
        if (self.defaultValue != nil) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
                [dateFormatter setDateFormat:@"HH:mm"];
                NSDate *start = [dateFormatter dateFromString:@"00:00"];
                NSDate *end = [dateFormatter dateFromString:self.defaultValue];
                NSTimeInterval interval = [end timeIntervalSinceDate:start];

                [prefsDict setObject:[NSNumber numberWithDouble:interval] forKey:self.key];
            } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDate) {
                [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                NSDate *dateFromString = [dateFormatter dateFromString:self.defaultValue];

                [prefsDict setObject:dateFromString forKey:self.key];
            } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTime) {
                [dateFormatter setDateFormat:@"hh:mm a"];
                NSDate *dateFromString = [dateFormatter dateFromString:self.defaultValue];

                [prefsDict setObject:dateFromString forKey:self.key];
            } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDateAndTime) {
                [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
                NSDate *dateFromString = [dateFormatter dateFromString:self.defaultValue];

                [prefsDict setObject:dateFromString forKey:self.key];
            }

            [[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:self.defaults];

            notify_post([self.postNotification UTF8String]);
        } else {
            if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
                self.timeIntervalValue = 60;
            } else {
                self.dateValue = [NSDate date];
            }
        }
	}

    if ([self isDarkModeEnabled]) {
        self.dateTimePickerBodyColor = [UIColor secondarySystemBackgroundColor];
        self.dateTimePickerButtonColor = [UIColor tertiarySystemBackgroundColor];
        self.dateTimePickerBackgroundViewAlpha = 0.48;
    } else {
        self.dateTimePickerBodyColor = [UIColor secondarySystemBackgroundColor];
        self.dateTimePickerButtonColor = [UIColor systemBackgroundColor];
        self.dateTimePickerBackgroundViewAlpha = 0.2;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.preferenceBundle = [NSBundle bundleForClass:self.class];

    self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha = self.dateTimePickerBackgroundViewAlpha;

    UITapGestureRecognizer *backgroundTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDateTimePicker)];
    [self.backgroundView addGestureRecognizer:backgroundTapGestureRecognizer];

    [self addSubview:self.backgroundView];

    CGFloat dateTimePickerViewPadding = 30;
	CGFloat dateTimePickerViewWidth = self.frame.size.width - (dateTimePickerViewPadding * 2);
    CGFloat dateTimePickerViewHeight = (dateTimePickerViewWidth / 4) * 3;
    
    self.bodyView = [[UIView alloc] initWithFrame:CGRectMake(dateTimePickerViewPadding,
                                                            ((self.frame.size.height / 2) - (dateTimePickerViewHeight / 2)),
                                                            dateTimePickerViewWidth,
                                                            dateTimePickerViewHeight)];

    [self.bodyView setBackgroundColor:self.dateTimePickerBodyColor];
    self.bodyView.layer.cornerRadius = 10;

    [self addSubview:self.bodyView];

    CGFloat buttonHeight = 40;

    CGFloat dateTimePickerPadding = 10;
    CGFloat dateTimePickerHeight = dateTimePickerViewHeight - (dateTimePickerPadding * 3) - buttonHeight;
    CGFloat dateTimePickerWidth = dateTimePickerViewWidth - (dateTimePickerPadding * 2);

    CGFloat buttonWidth = (dateTimePickerWidth / 2);

    CGRect dateTimePickerFrame = CGRectMake(dateTimePickerPadding,
                                            dateTimePickerPadding,
										    dateTimePickerWidth,
										    dateTimePickerHeight);

    self.dateTimePicker = [[UIDatePicker alloc] initWithFrame:dateTimePickerFrame];
    [self.dateTimePicker setFrame:dateTimePickerFrame];

    if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDate) {
        [self.dateTimePicker setDatePickerMode:UIDatePickerModeDate];
        [self.dateTimePicker setDate:self.dateValue];
    } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
        [self.dateTimePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
        [self.dateTimePicker setCountDownDuration:self.timeIntervalValue];
    } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTime) {
        [self.dateTimePicker setDatePickerMode:UIDatePickerModeTime];
        [self.dateTimePicker setDate:self.dateValue];
    } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDateAndTime) {
        [self.dateTimePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [self.dateTimePicker setDate:self.dateValue];
    } else {
        [self.dateTimePicker setDatePickerMode:UIDatePickerModeDate];
        [self.dateTimePicker setDate:self.dateValue];
    }
    self.dateTimePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    self.dateTimePicker.translatesAutoresizingMaskIntoConstraints = FALSE;

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton addTarget:self action:@selector(cancelDateTimePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:[self localizedStringForKey:@"CANCEL"] forState:UIControlStateNormal];
    
    self.cancelButton.frame = CGRectMake(dateTimePickerPadding,
                                        (self.bodyView.frame.size.height - dateTimePickerPadding - buttonHeight),
                                        (dateTimePickerWidth / 2) - dateTimePickerPadding,
                                        buttonHeight);

    self.cancelButton.layer.cornerRadius = 10;
    self.cancelButton.clipsToBounds = YES;
    [self.cancelButton setBackgroundColor:self.dateTimePickerButtonColor];
    [self.cancelButton setTitleColor:self.themeTintColor forState:UIControlStateNormal];

    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.submitButton addTarget:self action:@selector(submitDateTimePicker) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton setTitle:[self localizedStringForKey:@"SUBMIT"] forState:UIControlStateNormal];
    
    self.submitButton.frame = CGRectMake(dateTimePickerPadding + buttonWidth,
                                        (self.bodyView.frame.size.height - dateTimePickerPadding - buttonHeight),
                                        buttonWidth,
                                        buttonHeight);

    self.submitButton.layer.cornerRadius = 10;
    self.submitButton.clipsToBounds = YES;
    [self.submitButton setBackgroundColor:self.dateTimePickerButtonColor];
    [self.submitButton setTitleColor:self.themeTintColor forState:UIControlStateNormal];

    [self.bodyView addSubview:self.dateTimePicker];
    [self.bodyView addSubview:self.cancelButton];
    [self.bodyView addSubview:self.submitButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.dateTimePicker.widthAnchor constraintEqualToConstant:dateTimePickerWidth],
        [self.dateTimePicker.heightAnchor constraintEqualToConstant:dateTimePickerHeight],

        [self.dateTimePicker.centerXAnchor constraintEqualToAnchor:self.bodyView.centerXAnchor],
        [self.dateTimePicker.topAnchor constraintEqualToAnchor:self.bodyView.topAnchor constant:dateTimePickerPadding],
    ]];

    [super setAlpha:0.0f];
}

- (NSString *)localizedStringForKey:(NSString *)key {
	return [self.preferenceBundle localizedStringForKey:key value:@"" table:nil];
}

- (void)presentDateTimePicker {
    NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:self.defaults] mutableCopy];
	if ([prefsDict objectForKey:self.key] == nil) {
        if (self.defaultValue != nil) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
                [dateFormatter setDateFormat:@"HH:mm"];
                NSDate *start = [dateFormatter dateFromString:@"00:00"];
                NSDate *end = [dateFormatter dateFromString:self.defaultValue];
                NSTimeInterval interval = [end timeIntervalSinceDate:start];

                [prefsDict setObject:[NSNumber numberWithDouble:interval] forKey:self.key];
            } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDate) {
                [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                NSDate *dateFromString = [dateFormatter dateFromString:self.defaultValue];

                [prefsDict setObject:dateFromString forKey:self.key];
            } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTime) {
                [dateFormatter setDateFormat:@"hh:mm a"];
                NSDate *dateFromString = [dateFormatter dateFromString:self.defaultValue];

                [prefsDict setObject:dateFromString forKey:self.key];
            } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDateAndTime) {
                [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
                NSDate *dateFromString = [dateFormatter dateFromString:self.defaultValue];

                [prefsDict setObject:dateFromString forKey:self.key];
            }

            [[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:self.defaults];

            notify_post([self.postNotification UTF8String]);
        } else {
            if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
                self.timeIntervalValue = 60;
            } else {
                self.dateValue = [NSDate date];
            }
        }
	}

    if ([prefsDict objectForKey:self.key] != nil) {
        if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
		    self.timeIntervalValue = [[prefsDict objectForKey:self.key] doubleValue];
        } else {
            self.dateValue = [prefsDict objectForKey:self.key];
        }
    } else {
        if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
            self.timeIntervalValue = 60;
        } else {
            self.dateValue = [NSDate date];
        }
    }

    if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
        self.dateTimePicker.countDownDuration = self.timeIntervalValue;
    } else {
        self.dateTimePicker.date = self.dateValue;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                            [super setAlpha:1.0f];
                        }
                     completion:nil];
}

- (void)hideDateTimePicker {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                            [super setAlpha:0.0f];
                        }
                     completion:^(BOOL finished) {
                            [super removeFromSuperview];
                        }];
}

- (void)cancelDateTimePicker {
    [self hideDateTimePicker];
}

- (void)submitDateTimePicker {
    NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:self.defaults] mutableCopy];

    if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
        self.timeIntervalValue = self.dateTimePicker.countDownDuration;

        [prefsDict setObject:[NSNumber numberWithDouble:self.timeIntervalValue] forKey:self.key];
    } else {
        self.dateValue = self.dateTimePicker.date;

        [prefsDict setObject:self.dateValue forKey:self.key];
    }

	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:self.defaults];

    [self hideDateTimePicker];

    notify_post([self.postNotification UTF8String]);
}

- (BOOL)isDarkModeEnabled {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0 && self.traitCollection.userInterfaceStyle == 2)
        return TRUE;
    else
        return FALSE;
}

@end
