#import <Foundation/Foundation.h>
#import "AEFCUBDangerButton.h"

@implementation AEFCUBDangerButton

- (id)init {
    return [super init];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [[self textLabel] setTextColor:[UIColor systemRedColor]];
    self.interactionTintColor = [UIColor systemRedColor];
    UILabel *label = [self titleLabel];
    label.highlightedTextColor = [UIColor systemRedColor];
}

@end
