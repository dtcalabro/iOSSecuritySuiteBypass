#import <UIKit/UIKit.h>
#import "AEFCUBCommonHeader.h"

@interface AEFCUBBetterTitleView : UIView
- (instancetype)initWithTitle:(NSString *)title minimumScrollOffsetRequired:(CGFloat)minimumOffset;
- (void)adjustLabelPositionToScrollOffset:(CGFloat)offset;
- (void)updateTitleColorBasedOnCurrentInterfaceStyle;
@end