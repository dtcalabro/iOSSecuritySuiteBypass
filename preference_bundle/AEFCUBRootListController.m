/*
#import <Foundation/Foundation.h>
#import "AEFCUBRootListController.h"
#import "AEFCUBBetterTitleView.h"
#import "AEFCUBTintedButton.h"
#import <notify.h>

@implementation AEFCUBRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0 && self.traitCollection.userInterfaceStyle == 2) {
			_specifiers = [self loadSpecifiersFromPlistName:@"Root-Dark" target:self]; 	// Dark mode
			//self.themeTintColor = [UIColor colorWithRed:253/255.f green:218/255.f blue:22/255.f alpha:1.0f];
			self.themeTintColor = self.view.tintColor;
		} else {
			_specifiers = [self loadSpecifiersFromPlistName:@"Root-Light" target:self]; // Light mode
			//self.themeTintColor = [UIColor colorWithRed:253/255.f green:218/255.f blue:22/255.f alpha:1.0f];
			self.themeTintColor = self.view.tintColor;
		}

		self.preferenceBundle = [NSBundle bundleForClass:self.class];

		for (NSInteger i = 0; i <= _specifiers.count - 1; i++) {
			PSSpecifier *specifier = (PSSpecifier *)_specifiers[i];
			[specifier setProperty:self.themeTintColor forKey:@"tintColor"];

			if (!AEFCUB_DEBUG) {
				NSNumber *developmentOnly = [specifier propertyForKey:@"developmentOnly"];
				
				if ([developmentOnly boolValue] == TRUE) {
					[_specifiers removeObjectAtIndex:i];
					i--;
				}
			}
		}
	}

	[self doTinting];
	[self setupBetterTitleView];

	UINavigationItem* navigationItem = self.navigationItem;
	UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:[self localizedStringForKey:@"RESPRING"] style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	navigationItem.rightBarButtonItem = respringButton;

	return _specifiers;
}

- (void)loadView {
	[super loadView];

	[self doTinting];
	[self setupBetterTitleView];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self doTinting];
	[self setupBetterTitleView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self doTinting];
	[self setupBetterTitleView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self doTinting];
	[self setupBetterTitleView];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	// Revert the tinting when disappearing so it will not continue to stay after exiting our preference pane
	[self reverseTinting];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  	// Send scroll offset updates to view
	if ([self.navigationItem.titleView respondsToSelector:@selector(adjustLabelPositionToScrollOffset:)]) {
		[(AEFCUBBetterTitleView *)self.navigationItem.titleView adjustLabelPositionToScrollOffset:scrollView.contentOffset.y];
	}
}

- (void)doTinting {
	self.view.tintColor = self.themeTintColor;
	UINavigationBar *bar = self.navigationController.navigationController.navigationBar;
	bar.tintColor = self.themeTintColor;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = self.themeTintColor;
	[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = self.themeTintColor;
	[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = self.themeTintColor;
}

- (void)reverseTinting {
	self.view.tintColor = NULL;
	UINavigationBar *bar = self.navigationController.navigationController.navigationBar;
	bar.tintColor = NULL;
	[UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = NULL;
	[UISlider appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = NULL;
	[UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[self.class]].tintColor = NULL;
}

- (void)setupBetterTitleView {
	// Create view and set as titleView of your navigation bar
	// Set the title and the minimum scroll offset before starting the animation
	if (!self.navigationItem.titleView) {
		AEFCUBBetterTitleView *titleView = [[AEFCUBBetterTitleView alloc] initWithTitle:kTweakName minimumScrollOffsetRequired:20];
		self.navigationItem.titleView = titleView;
	}
}

- (NSString *)localizedStringForKey:(NSString *)key {
	return [self.preferenceBundle localizedStringForKey:key value:@"" table:nil];
}

- (void)reset {
	UIAlertController *confirmResetAlert = [UIAlertController alertControllerWithTitle:[self localizedStringForKey:@"RESET_TITLE"] message:[self localizedStringForKey:@"RESET_MESSAGE"] preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"RESET"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		notify_post("com.dcproducts.aefcubypass/Reset");
		notify_post("com.dcproducts.aefcubypass/Respring");
    }];

	UIAlertAction *cancel = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:nil];

    [confirmResetAlert addAction:cancel];
	[confirmResetAlert addAction:confirm];

	[self presentViewController:confirmResetAlert animated:YES completion:nil];
}

- (void)respring {
	UIAlertController *confirmRespringAlert = [UIAlertController alertControllerWithTitle:[self localizedStringForKey:@"RESPRING_TITLE"] message:[self localizedStringForKey:@"RESPRING_MESSAGE"] preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"RESPRING"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		notify_post("com.dcproducts.aefcubypass/Respring");
    }];

	UIAlertAction *cancel = [UIAlertAction actionWithTitle:[self localizedStringForKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:nil];

    [confirmRespringAlert addAction:cancel];
	[confirmRespringAlert addAction:confirm];

	[self presentViewController:confirmRespringAlert animated:YES completion:nil];
}

- (void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/dcalabro3"] options:@{} completionHandler:nil];
}

- (void)paypal {
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/DerekCalabro"] options:@{} completionHandler:nil];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.com/donate/?cmd=_donations&business=dtcalabro@gmail.com&item_name=iOS%20Tweak%20Development"] options:@{} completionHandler:nil];
}

- (void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/dtcalabro"] options:@{} completionHandler:nil];
}

- (void)discord {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://discordapp.com/users/517728575063851014"] options:@{} completionHandler:nil];
}

- (void)bugReport {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:dtcalabro@gmail.com?subject=%5BiOS%20Tweak%20Support%5D%20Bug%20Report&body=Tweak%20name%3A%20AEFCUBypass%0D%0AMessage%3A%20I%20found%20a%20bug%20while%20using%20the%20AEFCUBypass%20tweak.%20The%20following%20explains%20how%20to%20reproduce%20the%20bug%20and%20includes%20any%20additional%20information%20I%20may%20have%20regarding%20the%20issue.%0D%0A%0D%0A"] options:@{} completionHandler:nil];
}

- (void)featureRequest {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:dtcalabro@gmail.com?subject=%5BiOS%20Tweak%20Support%5D%20Feature%20Request&body=Tweak%20name%3A%20AEFCUBypass%0D%0AMessage%3A%20I%20have%20a%20feature%20request%20for%20the%20AEFCUBypass%20tweak.%20The%20following%20explains%20my%20idea%20and%20any%20other%20input%20or%20information%20I%20may%20have%20regarding%20it.%0D%0A%0D%0A"] options:@{} completionHandler:nil];
}

@end
*/

#import <Foundation/Foundation.h>
#import "AEFCUBRootListController.h"
#import "AEFCUBBetterTitleView.h"

@implementation AEFCUBRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        [super setDarkModePlist:@"Root-Dark" lightModePlist:@"Root-Light"];
    }

    [super specifiers];

    [self setupBetterTitleView];

    UIAction *respringAction = [UIAction actionWithTitle:[self localizedStringForKey:@"RESPRING"] image:[UIImage systemImageNamed:@"arrow.triangle.2.circlepath"] identifier:nil handler:^(UIAction * _Nonnull action) {
        [self respring];
    }];

    UIImage *resetActionImage;
    if (([[[UIDevice currentDevice] systemVersion] compare:@"15.0" options:NSNumericSearch] == NSOrderedSame) || ([[[UIDevice currentDevice] systemVersion] compare:@"15.0" options:NSNumericSearch] == NSOrderedDescending)) {
        //App is running on iOS 15+
        resetActionImage = [UIImage systemImageNamed:@"slider.horizontal.2.rectangle.and.arrow.triangle.2.circlepath"];
    } else {
        resetActionImage = [UIImage systemImageNamed:@"exclamationmark.arrow.triangle.2.circlepath"];
    }

    UIAction *resetAction = [UIAction actionWithTitle:[self localizedStringForKey:@"RESET_ALL_SETTINGS"] image:resetActionImage identifier:nil handler:^(UIAction * _Nonnull action) {
        [self reset];
    }];
    resetAction.attributes = UIMenuElementAttributesDestructive; // Needed to make the text and glyph red for this menu option

    NSMutableArray *menuActions = [NSMutableArray arrayWithObjects:respringAction, resetAction, nil];

    self.optionsButtonView = [[UIView alloc] initWithFrame:CGRectZero];
    self.optionsButtonView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.optionsButtonView.backgroundColor = [UIColor clearColor];

    self.optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.optionsButton sizeToFit];
    self.optionsButton.menu = [UIMenu menuWithChildren:menuActions];
    self.optionsButton.showsMenuAsPrimaryAction = TRUE;
    self.optionsButton.layer.cornerRadius = 10.0;
    self.optionsButton.layer.masksToBounds = FALSE;
    [self.optionsButton setBackgroundColor:[UIColor secondarySystemBackgroundColor]];

    [self.optionsButton setImage:[UIImage systemImageNamed:@"gearshape.fill"] forState:UIControlStateNormal];

    // This is so the button is a square and not a rectange with a height that is slightly larger than the width that shitty iOS does by default
    self.optionsButton.frame = CGRectMake(0.0, 0.0, self.optionsButton.frame.size.height, self.optionsButton.frame.size.height);

    [self.optionsButton setBackgroundColor:self.themeTintColor];
    self.optionsButton.tintColor = [UIColor whiteColor];
    [self.optionsButton setImage:[[UIImage systemImageNamed:@"gearshape.fill"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];

    self.optionsLabel = [[UILabel alloc] init];
    self.optionsLabel.numberOfLines = 1;
    self.optionsLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.optionsLabel.textColor = self.themeTintColor;
    self.optionsLabel.text = [self localizedStringForKey:@"OPTIONS"];
    self.optionsLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightRegular];
    [self.optionsLabel sizeToFit];
    self.optionsLabel.backgroundColor = [UIColor clearColor];
    self.optionsLabel.textAlignment = NSTextAlignmentCenter;

    self.optionsButtonView.frame = CGRectMake(0.0, 0.0, (self.optionsButton.frame.size.width + self.optionsLabel.frame.size.width + 10.0), self.optionsButton.frame.size.height);
    self.optionsLabel.frame = CGRectMake(0.0, ((self.optionsButtonView.frame.size.height / 2) - (self.optionsLabel.frame.size.height / 2)), self.optionsLabel.frame.size.width, self.optionsLabel.frame.size.height);
    self.optionsButton.frame = CGRectMake((self.optionsButtonView.frame.size.width - self.optionsButton.frame.size.width), self.optionsButtonView.frame.origin.y, self.optionsButton.frame.size.width, self.optionsButton.frame.size.height);

    [self.optionsButtonView addSubview:self.optionsLabel];
    [self.optionsButtonView addSubview:self.optionsButton];
    
    self.menuButton = [[UIBarButtonItem alloc] initWithCustomView:self.optionsButtonView];

    self.navigationItem.rightBarButtonItem = self.menuButton;

	return _specifiers;
}

- (void)setupTableHeader {
    if (self.table.frame.size.width != 0.0f) {
        int imageSize = 58;

        CGRect frame;
        UIColor *tintColor = self.themeTintColor;

        UILabel *headerText = [[UILabel alloc] init];
        headerText.numberOfLines = 1;
        headerText.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        headerText.font = [UIFont systemFontOfSize:32.0f];
        headerText.textColor = tintColor;
        headerText.text = kTweakName;
        [headerText sizeToFit];
        headerText.backgroundColor = [UIColor clearColor];
        headerText.textAlignment = NSTextAlignmentCenter;

        int leadingPaddingSize = 20;
        int otherPaddingSize = 10;
        int labelHeight = headerText.frame.size.height;
        int neededTotalHeight = (leadingPaddingSize + imageSize + otherPaddingSize + labelHeight);

        frame = CGRectMake(0.0f, (neededTotalHeight - labelHeight), self.table.frame.size.width, labelHeight);
        headerText.frame = frame;

        headerText.layer.shadowColor = tintColor.CGColor;
        headerText.layer.shadowOffset = CGSizeZero;
        headerText.layer.shadowRadius = 25;
        headerText.layer.shadowOpacity = 1.0f;
        headerText.layer.masksToBounds = FALSE;
        
        UIImage *headerImage = [UIImage imageWithContentsOfFile:[self pathOfResourceWithName:[NSString stringWithFormat:@"%@-fullsize", kTweakName] type:@".png"]];

        UIImageView *headerImageView = [[UIImageView alloc] initWithImage:headerImage];
        headerImageView.frame = CGRectMake(((self.table.frame.size.width / 2) - (imageSize / 2)), leadingPaddingSize, imageSize, imageSize);

        headerImageView.layer.shadowOffset = CGSizeZero;
        headerImageView.layer.shadowColor = tintColor.CGColor;
        headerImageView.layer.shadowRadius = 25;
        headerImageView.layer.shadowOpacity = 1.0f;
        headerText.layer.masksToBounds = FALSE;

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];

        animation.duration = 4.0;
        animation.fromValue = @(5);
        animation.toValue = @(headerImageView.layer.shadowRadius);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.autoreverses = TRUE;
        animation.repeatCount = FLT_MAX;
        animation.removedOnCompletion = FALSE;
        [headerImageView.layer addAnimation:animation forKey:@"shadowRadius"];

        animation.duration = 4.0;
        animation.fromValue = @(5);
        animation.toValue = @(headerText.layer.shadowRadius);
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.autoreverses = TRUE;
        animation.repeatCount = FLT_MAX;
        animation.removedOnCompletion = FALSE;
        [headerText.layer addAnimation:animation forKey:@"shadowRadius"];

        frame = CGRectMake(0.0f, 0.0f, self.table.frame.size.width, neededTotalHeight);

        UIView *headerView = [[UIView alloc] initWithFrame:frame];
        headerView.backgroundColor = [UIColor clearColor];
        self.table.tableHeaderView = headerView;

        [self.table.tableHeaderView addSubview:headerImageView];
        [self.table.tableHeaderView addSubview:headerText];
    }
}

// This is needed to update the specifiers to match the new light/dark mode appearance since it just changed
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    if ([self.navigationItem.titleView respondsToSelector:@selector(updateTitleColorBasedOnCurrentInterfaceStyle)]) {
		[(AEFCUBBetterTitleView *)self.navigationItem.titleView updateTitleColorBasedOnCurrentInterfaceStyle];
	}
}

- (void)loadView {
    [super loadView];

	[self setupBetterTitleView];
    [self setupTableHeader];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setupBetterTitleView];
    [self setupTableHeader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[self setupBetterTitleView];
    [self setupTableHeader];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	[self setupBetterTitleView];
    [self setupTableHeader];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  	// Send scroll offset updates to view
	if ([self.navigationItem.titleView respondsToSelector:@selector(adjustLabelPositionToScrollOffset:)]) {
		[(AEFCUBBetterTitleView *)self.navigationItem.titleView adjustLabelPositionToScrollOffset:scrollView.contentOffset.y];
	}
}

- (void)setupBetterTitleView {
	// Create view and set as titleView of your navigation bar
	// Set the title and the minimum scroll offset before starting the animation
	if (!self.navigationItem.titleView) {
		AEFCUBBetterTitleView *titleView = [[AEFCUBBetterTitleView alloc] initWithTitle:kTweakName minimumScrollOffsetRequired:0];
		self.navigationItem.titleView = titleView;
	}
}

@end
