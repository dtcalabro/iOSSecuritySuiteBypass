#import <Foundation/Foundation.h>
#import "AEFCUBSubListController.h"

@implementation AEFCUBSubListController

- (NSArray *)specifiers {
	return _specifiers;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {
    NSString* sub = [specifier propertyForKey:@"AEFCUBSub"];

    _specifiers = [self loadSpecifiersFromPlistName:sub target:self];
}

- (void)setSpecifier:(PSSpecifier *)specifier {
    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];
}

- (BOOL)shouldReloadSpecifiersOnResume {
    return FALSE;
}

@end
