#import <sys/types.h>
#import <os/log.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include <unistd.h>
//#include "IntegrityChecker.h"
#include <substrate.h>

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
	if (ISSB_DEBUG) {\
		char* str; \
		asprintf(&str, __VA_ARGS__); \
		os_log(OS_LOG_DEFAULT, "[ISSB_DEBUG] %s", str); \
	}\
})


@interface FBSystemService : NSObject
+ (id)sharedInstance;
- (void)exitAndRelaunch:(BOOL)arg1;
@end

// Global variables
BOOL enabled = TRUE;

@interface ISSBHelper : NSObject
- (id)ISSBReadPreferenceValue:(NSString *)key;
- (id)ISSBReadPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (id)ISSBReadArrayPreferenceValue:(NSString *)key;
- (id)ISSBReadDatePreferenceValue:(NSString *)key;
- (BOOL)ISSBReadBooleanPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (id)ISSBReadColorPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (id)ISSBReadStringPreferenceValue:(NSString *)key fallbackValue:(id)value;
- (void)ISSBWritePreferenceValue:(id)object forKey:(NSString *)key;
- (void)ISSBRemovePreferenceValue:(NSString *)key;
- (void)ISSBRemovePreferenceDomain;
- (BOOL)ISSBDoesPreferenceDomainExist; // Don't believe is working
- (BOOL)ISSBDoesPreferenceValueExist:(NSString *)key;
@end

ISSBHelper *helper;

static BOOL (*orig_amIJailbroken)(void);

BOOL hook_amIJailbroken(void) {
    //NSLog(@"Hooked amIJailbroken()");

    /*
    if (!enabled) {
        NSLog(@"Returning original amIJailbroken()");
        return orig_amIJailbroken();
    } else {
        // Always return NO
        return NO;
    }
    */

    // Always return NO
    return NO;
}

@implementation ISSBHelper
- (id)ISSBReadPreferenceValue:(NSString *)key {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != nil) {
		return [prefsDict objectForKey:key];
	} else {
		return @"0";
	}
}

- (id)ISSBReadPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != nil) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (id)ISSBReadArrayPreferenceValue:(NSString *)key {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return [NSMutableArray array];
	}
}

- (id)ISSBReadDatePreferenceValue:(NSString *)key {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return [NSDate date];
	}
}

- (BOOL)ISSBReadBooleanPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [[prefsDict objectForKey:key] boolValue];
	} else {
		return value;
	}
}

- (id)ISSBReadColorPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (id)ISSBReadStringPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (id)ISSBReadIntegerPreferenceValue:(NSString *)key fallbackValue:(id)value {
    NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];

	if ([prefsDict objectForKey:key] != NULL) {
		return [prefsDict objectForKey:key];
	} else {
		return value;
	}
}

- (void)ISSBWritePreferenceValue:(id)object forKey:(NSString *)key {
	NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"] mutableCopy];

	[prefsDict setObject:object forKey:key];

	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:@"com.dcproducts.iossecuritysuitebypassprefs"];
}

- (void)ISSBRemovePreferenceValue:(NSString *)key {
	NSMutableDictionary *prefsDict = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"] mutableCopy];

	[prefsDict removeObjectForKey:key];

	[[NSUserDefaults standardUserDefaults] setPersistentDomain:prefsDict forName:@"com.dcproducts.iossecuritysuitebypassprefs"];
}

- (void)ISSBRemovePreferenceDomain {
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];
}

- (BOOL)ISSBDoesPreferenceDomainExist {
	NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];
	if (prefsDict) {
		return TRUE;
	} else {
		return FALSE;
	}
}

- (BOOL)ISSBDoesPreferenceValueExist:(NSString *)key {
	NSDictionary *prefsDict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"];
	
	if ([prefsDict objectForKey:key] != NULL) {
		return TRUE;
	} else {
		return FALSE;
	}
}
@end

/*
static void ISSBReloadPrefs() {
	debug_log("ISSBReloadPrefs called!");
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Global toggle
		enabled = [helper ISSBReadBooleanPreferenceValue:@"isEnabled" fallbackValue:@YES];
		debug_log("enabled --> %i", enabled);

		if (ISSB_DEBUG) {
			debug_log("NSUserDefaults dump: %s", [[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.dcproducts.iossecuritysuitebypassprefs"]] UTF8String]);
		}
	});
}

static void ISSBReset() {
	debug_log("ISSBReset called!");
	[helper ISSBWritePreferenceValue:@YES forKey:@"isEnabled"];
}

void ISSBPrefsCheck() {
	debug_log("ISSBPrefsCheck called!");

	if (![helper ISSBDoesPreferenceValueExist:@"isEnabled"]) {
		debug_log("isEnabled = NULL");
		[helper ISSBWritePreferenceValue:@YES forKey:@"isEnabled"];
	}
}

void ISSBRespring() {
	debug_log("ISSBRespring called!");
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}
*/

/*
BOOL isSpringBoard() {
    NSString *processName = [[NSProcessInfo processInfo] processName];
    return [processName isEqualToString:@"SpringBoard"];
}
*/

%ctor {
	//helper = [[ISSBHelper alloc] init];

    //ISSBPrefsCheck();
    //ISSBReloadPrefs();

    //if (isSpringBoard()) {
        // Register for notifications
	//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ISSBRespring, CFSTR("com.dcproducts.iOSSecuritySuiteBypass/Respring"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ISSBReloadPrefs, CFSTR("com.dcproducts.iOSSecuritySuiteBypass/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	//    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ISSBReset, CFSTR("com.dcproducts.iOSSecuritySuiteBypass/Reset"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    //} else {
        // Hook amIJailbroken
        // _$s16IOSSecuritySuiteAAC13amIJailbrokenSbyFZ
        void* amIJailbroken = MSFindSymbol(NULL, "_$s16IOSSecuritySuiteAAC13amIJailbrokenSbyFZ");
        if (amIJailbroken)
            MSHookFunction(amIJailbroken, (void *)hook_amIJailbroken, (void **)&orig_amIJailbroken);
    //}
}
