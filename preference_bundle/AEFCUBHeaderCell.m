#import "AEFCUBHeaderCell.h"

@implementation AEFCUBHeaderCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Banner" specifier:specifier];

  UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 320.0f)];
  self.frame = cellView.frame;
	
  if (self) {
    int imageSize = 58;

    CGRect frame = CGRectMake(0.0f, (imageSize - 40.0f), (self.frame.size.width - 30.0f), self.frame.size.height);

		UILabel *headerText = [[UILabel alloc] initWithFrame:frame];
		headerText.numberOfLines = 1;
		headerText.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    headerText.font = [UIFont systemFontOfSize:32.0f];

    UIColor *tintColor = [specifier propertyForKey:@"tintColor"];
    headerText.textColor = tintColor;
		headerText.text = kTweakName;
		headerText.backgroundColor = [UIColor clearColor];
		headerText.textAlignment = NSTextAlignmentCenter;

    UIImage *headerImage = [UIImage imageWithContentsOfFile:ROOT_PATH_NS(@"/Library/PreferenceBundles/AEFCUBypassPrefs.bundle/AEFCUBypass-fullsize.png")];
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:headerImage];
    headerImageView.frame = CGRectMake(((self.frame.size.width / 2) - (imageSize / 2)), -20.0f, imageSize, imageSize);

    [self addSubview:headerImageView];
		[self addSubview:headerText];
	}

  return self;
}

- (void)layoutSubviews {

}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
    //return isiOS6 ? 90.0f : 70.0f;
    return 90.0f;
}

@end