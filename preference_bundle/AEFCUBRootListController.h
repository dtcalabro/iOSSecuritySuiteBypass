#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "AEFCUBCommonHeader.h"
#import "AEFCUBBaseListController.h"

@interface AEFCUBRootListController : AEFCUBBaseListController
@property (nonatomic, retain) UIView *optionsButtonView;
@property (nonatomic, retain) UIButton *optionsButton;
@property (nonatomic, retain) UILabel *optionsLabel;
@property (nonatomic, retain) UIBarButtonItem *menuButton;

- (void)setupBetterTitleView;
@end
