#import <sys/types.h>
#import <os/log.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <unistd.h>

#import "HBLog.h"

// Use for NSString literals or variables
#define ROOT_PATH_NS(path) ([[NSFileManager defaultManager] fileExistsAtPath:path] ? path : [@"/var/jb" stringByAppendingPathComponent:path])

// Use for C string literals
#define ROOT_PATH_C(cPath) (access(cPath, F_OK) == 0) ? cPath : "/var/jb" cPath

// Use for C string variables
// The string returned by this will get freed when your function exits
// If you want to keep it, use strdup
#define ROOT_PATH_C_VAR(cPath) (ROOT_PATH_NS([NSString stringWithUTF8String:cPath]).fileSystemRepresentation)

#define debug_log(...) ({\
	if (AEFCUB_DEBUG) {\
		char* str; \
		asprintf(&str, __VA_ARGS__); \
		os_log(OS_LOG_DEFAULT, "[AEFCUB_DEBUG] %s", str); \
	}\
})


@interface FBSystemService : NSObject
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;
@end

// Global variables
BOOL enabled = TRUE;

@interface AEFCUBHelper : NSObject
- (id)AEFCUBReadPreferenceValue:(NSString *)key;
- (id)AEFCUBReadPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (id)AEFCUBReadArrayPreferenceValue:(NSString *)key;
- (id)AEFCUBReadDatePreferenceValue:(NSString *)key;
- (BOOL)AEFCUBReadBooleanPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (id)AEFCUBReadColorPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (id)AEFCUBReadStringPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (void)AEFCUBWritePreferenceValue:(id)object forKey:(NSString *)key;
- (void)AEFCUBRemovePreferenceValue:(NSString *)key;
- (void)AEFCUBRemovePreferenceDomain;
- (BOOL)AEFCUBDoesPreferenceDomainExist; // Don't believe is working
- (BOOL)AEFCUBDoesPreferenceValueExist:(NSString *)key;
@end

AEFCUBHelper *helper;

@implementation AEFCUBHelper
- (id)AEFCUBReadPreferenceValue:(NSString *)key {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != nil) {
		return [prefsDict objectForKey:key];
	} else {
		return @"0";
	}
}

- (id)AEFCUBReadPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != nil) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (id)AEFCUBReadArrayPreferenceValue:(NSString *)key {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return [NSMutableArray array];
	}
}

- (id)AEFCUBReadDatePreferenceValue:(NSString *)key {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return [NSDate date];
	}
}

- (BOOL)AEFCUBReadBooleanPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [[prefsDict objectForKey:key] boolValue];
	} else {
		return value;
	}
}

- (id)AEFCUBReadColorPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (id)AEFCUBReadStringPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (id)AEFCUBReadIntegerPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (void)AEFCUBWritePreferenceValue:(id)object forKey:(NSString *)key {
	NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"] mutableCopy];

	[prefsDict setObject:object forKey:key];

	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:@"com.dcproducts.aefcubypassprefs"];
}

- (void)AEFCUBRemovePreferenceValue:(NSString *)key {
	NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"] mutableCopy];

	[prefsDict removeObjectForKey:key];

	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:@"com.dcproducts.aefcubypassprefs"];
}

- (void)AEFCUBRemovePreferenceDomain {
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.dcproducts.aefcubypassprefs"];
}

- (BOOL)AEFCUBDoesPreferenceDomainExist {
	NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];
	if (prefsDict) {
		return TRUE;
	} else {
		return FALSE;
	}
}

- (BOOL)AEFCUBDoesPreferenceValueExist:(NSString *)key {
	NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"];
	
	if ([prefsDict objectForKey:key] != NULL) {
		return TRUE;
	} else {
		return FALSE;
	}
}
@end

static void AEFCUBReloadPrefs() {
	debug_log("AEFCUBReloadPrefs called!");
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Global toggle
		enabled = [helper AEFCUBReadBooleanPreferenceValue:@"isEnabled" fallbackValue:@YES];
		debug_log("enabled --> %i", enabled);

		if (AEFCUB_DEBUG) {
			debug_log("NSUserDefaults dump: %s", [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.aefcubypassprefs"]] UTF8String]);
		}
	});
}

static void AEFCUBReset() {
	debug_log("AEFCUBReset called!");
	[helper AEFCUBWritePreferenceValue:@YES forKey:@"isEnabled"];
}

void AEFCUBPrefsCheck() {
	debug_log("AEFCUBPrefsCheck called!");

	if (![helper AEFCUBDoesPreferenceValueExist:@"isEnabled"]) {
		debug_log("isEnabled = NULL");
		[helper AEFCUBWritePreferenceValue:@YES forKey:@"isEnabled"];
	}
}

void AEFCUBRespring() {
	debug_log("AEFCUBRespring called!");
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor {
	helper = [[AEFCUBHelper alloc] init];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)AEFCUBRespring, CFSTR("com.dcproducts.aefcubypass/Respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)AEFCUBReloadPrefs, CFSTR("com.dcproducts.aefcubypass/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)AEFCUBReset, CFSTR("com.dcproducts.aefcubypass/Reset"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	AEFCUBPrefsCheck();
	AEFCUBReloadPrefs();
}
