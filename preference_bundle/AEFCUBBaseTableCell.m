#import <Foundation/Foundation.h>
#import "AEFCUBBaseTableCell.h"

@implementation AEFCUBBaseTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    self.textLabel.numberOfLines = 1;
    self.textLabel.minimumScaleFactor = 0.5;
    self.textLabel.adjustsFontSizeToFitWidth = YES;

    self.detailTextLabel.numberOfLines = 1;
    self.detailTextLabel.minimumScaleFactor = 0.5;
    self.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    UIColor *tintColor = [specifier propertyForKey:PSTintColorKey];
    self.themeTintColor = tintColor;

    /*
    [[self textLabel] setTextColor:self.themeTintColor];
    self.interactionTintColor = self.themeTintColor;
    UILabel *label = [self titleLabel];
    label.highlightedTextColor = self.themeTintColor;
    */

    return self;
}
@end