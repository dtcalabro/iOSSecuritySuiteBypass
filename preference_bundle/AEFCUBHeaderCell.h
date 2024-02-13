#import <UIKit/UIKit.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import "AEFCUBCommonHeader.h"

@interface AEFCUBHeaderCell : PSTableCell
- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (void)layoutSubviews;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
@end