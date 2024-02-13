#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "AEFCUBCommonHeader.h"

// These are used to match the depends operator string to an integer value for easier differentiation
typedef NS_ENUM(NSInteger, AEFCUBDependsSpecifierOperatorType) {
    AEFCUBEqualToOperatorType,
    AEFCUBNotEqualToOperatorType,
    AEFCUBGreaterThanOperatorType,
    AEFCUBLessThanOperatorType,
    AEFCUBGreaterThanOrEqualToOperatorType,
    AEFCUBLessThanOrEqualToOperatorType,
    AEFCUBBlankOperatorType,
};

@interface AEFCUBBaseListController : PSListController {
    NSMutableDictionary *_cells;
}
@property (nonatomic, strong) NSBundle *preferenceBundle;
@property (nonatomic, retain) UIColor *themeTintColor;

@property (nonatomic, retain) NSString *darkModePlist;
@property (nonatomic, retain) NSString *lightModePlist;

@property (nonatomic, assign) BOOL hasSpecifiersWithDependencies;
@property (nonatomic, retain) NSMutableDictionary *specifiersWithDependencies;

// Dark mode and light mode helper functions
- (BOOL)isDarkModeEnabled;
- (void)setDarkModePlist:(NSString *)darkModePlist lightModePlist:(NSString *)lightModePlist;
- (NSString *)getDarkModePlist;
- (NSString *)getLightModePlist;

// This section is for specifiers with dependencies
- (void)collectSpecifiersWithDependenciesFromArray:(NSArray *)array;
- (BOOL)shouldHideSpecifier:(PSSpecifier *)specifier;
- (PSSpecifier *)specifierForKey:(NSString *)key;
- (AEFCUBDependsSpecifierOperatorType)operatorTypeForString:(NSString *)string;

// These are the helper functions that handle all the tinting
- (void)doTinting;
- (void)reverseTinting;

// These are the helper functions for common button actions
- (void)reset;
- (void)respring;
- (void)twitter;
- (void)paypal;
- (void)github;
- (void)discord;
- (void)bugReport;
- (void)featureRequest;

// Other helper functions
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)pathOfResourceWithName:(NSString *)name type:(NSString *)ext;
- (id)readPreferenceValue:(PSSpecifier *)specifier;

@end
