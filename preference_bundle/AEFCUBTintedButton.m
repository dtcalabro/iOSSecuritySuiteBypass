#import <Foundation/Foundation.h>
#import "AEFCUBTintedButton.h"

@implementation AEFCUBTintedButton
@dynamic interactionTintColor;
@dynamic themeTintColor;

- (id)init {
    return [super init];
}

- (void)layoutSubviews {
    [super layoutSubviews];

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
@end
