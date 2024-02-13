#import <Foundation/Foundation.h>
#import "AEFCUBDateTimePicker.h"

void updateValueLabelCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (observer != nil)
        [(__bridge AEFCUBDateTimePicker *)observer updateValueLabel];
}

@implementation AEFCUBDateTimePicker

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier withPickerStyle:(AEFCUBDateTimePickerStyle)pickerStyle {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    if (self.themeTintColor == nil) {
        UIColor *tintColor = [specifier propertyForKey:PSTintColorKey];
        self.themeTintColor = tintColor;
    }

    UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject;
    self.rootViewController = windowScene.windows.firstObject.rootViewController;

    NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:[specifier propertyForKey:@"defaults"]] mutableCopy];

    if ([prefsDict objectForKey:[specifier propertyForKey:@"key"]] == nil) {
        if ([specifier propertyForKey:@"default"] != nil) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            if (pickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
                [dateFormatter setDateFormat:@"HH:mm"];
                NSDate *start = [dateFormatter dateFromString:@"00:00"];
                NSDate *end = [dateFormatter dateFromString:[specifier propertyForKey:@"default"]];
                NSTimeInterval interval = [end timeIntervalSinceDate:start];

                [prefsDict setObject:[NSNumber numberWithDouble:interval] forKey:[specifier propertyForKey:@"key"]];
            } else if (pickerStyle == AEFCUBDateTimePickerStyleDate) {
                [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                NSDate *dateFromString = [dateFormatter dateFromString:[specifier propertyForKey:@"default"]];

                [prefsDict setObject:dateFromString forKey:[specifier propertyForKey:@"key"]];
            } else if (pickerStyle == AEFCUBDateTimePickerStyleTime) {
                [dateFormatter setDateFormat:@"hh:mm a"];
                NSDate *dateFromString = [dateFormatter dateFromString:[specifier propertyForKey:@"default"]];

                [prefsDict setObject:dateFromString forKey:[specifier propertyForKey:@"key"]];
            } else if (pickerStyle == AEFCUBDateTimePickerStyleDateAndTime) {
                [dateFormatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
                NSDate *dateFromString = [dateFormatter dateFromString:[specifier propertyForKey:@"default"]];

                [prefsDict setObject:dateFromString forKey:[specifier propertyForKey:@"key"]];
            }

            [[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:[specifier propertyForKey:@"defaults"]];
        }
    }

    if ([specifier propertyForKey:@"default"] != nil) {
        self.dateTimePickerView = [[AEFCUBDateTimePickerView alloc] initWithFrame:self.rootViewController.view.frame tintColor:self.themeTintColor key:[specifier propertyForKey:@"key"] defaultValue:[specifier propertyForKey:@"default"] defaults:[specifier propertyForKey:@"defaults"] postNotification:[specifier propertyForKey:@"PostNotification"] dateTimePickerStyle:pickerStyle];
    } else {
        self.dateTimePickerView = [[AEFCUBDateTimePickerView alloc] initWithFrame:self.rootViewController.view.frame tintColor:self.themeTintColor key:[specifier propertyForKey:@"key"] defaults:[specifier propertyForKey:@"defaults"] postNotification:[specifier propertyForKey:@"PostNotification"]];
    }

    [[self specifier] setTarget:self];
    [[self specifier] setButtonAction:@selector(presentDateTimePicker)];

    [self.rootViewController.view addSubview:self.dateTimePickerView];

    [self setDateTimePickerStyle:pickerStyle];

    self.specifier = specifier; // Need to set specifier before calling updateValueLabel because it has not been set yet and will crash
    [self updateValueLabel];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), updateValueLabelCallback, (__bridge CFStringRef)[specifier propertyForKey:@"PostNotification"], NULL, CFNotificationSuspensionBehaviorCoalesce);

    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];

    // Remove the old observer to prevent crashes when comming back after leaving view
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), (__bridge CFStringRef)[self.specifier propertyForKey:@"PostNotification"], NULL);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [[self specifier] setTarget:self];
    [[self specifier] setButtonAction:@selector(presentDateTimePicker)];

    if (self.themeTintColor == nil) {
        PSSpecifier* specifier = [self specifier];

        UIColor *tintColor = [specifier propertyForKey:@"tintColor"];
        self.themeTintColor = tintColor;
    } else {
        [[self textLabel] setTextColor:self.themeTintColor];
        self.interactionTintColor = self.themeTintColor;
        UILabel *label = [self titleLabel];
        label.highlightedTextColor = self.themeTintColor;
    }
}

- (void)presentDateTimePicker {
    [self.rootViewController.view addSubview:self.dateTimePickerView];
    [self.dateTimePickerView presentDateTimePicker];
}

- (void)setDateTimePickerStyle:(AEFCUBDateTimePickerStyle)style {
    _dateTimePickerStyle = style;
    [self.dateTimePickerView setDateTimePickerStyle:style];
}

- (AEFCUBDateTimePickerStyle)dateTimePickerStyle {
    return _dateTimePickerStyle;
}

- (void)updateValueLabel {
    PSSpecifier *specifier = [self specifier];
    if (!specifier) return;
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[specifier propertyForKey:@"defaults"]];

    NSString *valueString;

    if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTimeInterval) {
        NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
        formatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute;
        formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;

        NSTimeInterval interval;

        if ([prefsDict objectForKey:[specifier propertyForKey:@"key"]] != nil) {
            interval = [[prefsDict objectForKey:[specifier propertyForKey:@"key"]] doubleValue];
        } else {
            if ([specifier propertyForKey:@"default"] != nil) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"HH:mm"];
                NSDate *start = [dateFormatter dateFromString:@"00:00"];
                NSDate *end = [dateFormatter dateFromString:[specifier propertyForKey:@"default"]];
                interval = [end timeIntervalSinceDate:start];
            } else {
                interval = 60;
            }
        }

        valueString = [formatter stringFromTimeInterval:interval];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDate) {
            [formatter setDateFormat:@"MMMM d yyyy"]; // This is just a date
        } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleTime) {
            [formatter setDateFormat:@"hh:mm a"]; // This is 12-hour format
        } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDateAndTime) {
            [formatter setDateFormat:@"EEE MMM d hh:mm a"]; // This is a date with 12-hour formatted time
        }

        NSDate *date;

        if ([prefsDict objectForKey:[specifier propertyForKey:@"key"]] != nil) {
            date = [prefsDict objectForKey:[specifier propertyForKey:@"key"]];
        } else {
            if ([specifier propertyForKey:@"default"] != nil) {
                if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDate) {
                    [formatter setDateFormat:@"MM-dd-yyyy"];
                    date = [formatter dateFromString:[specifier propertyForKey:@"default"]];
                    [formatter setDateFormat:@"MMMM d yyyy"]; // This is just a date
                } else if (self.dateTimePickerStyle == AEFCUBDateTimePickerStyleDateAndTime) {
                    [formatter setDateFormat:@"MM-dd-yyyy hh:mm a"];
                    date = [formatter dateFromString:[specifier propertyForKey:@"default"]];
                    [formatter setDateFormat:@"EEE MMM d hh:mm a"]; // This is a date with 12-hour formatted time
                } else {
                    date = [formatter dateFromString:[specifier propertyForKey:@"default"]];
                }
            } else {
                date = [NSDate date];
            }
        }

        valueString = [formatter stringFromDate:date];
    }
    
    self.detailTextLabel.text = valueString;
}

@end
