// Use for NSString literals or variables
#define ROOT_PATH_NS(path) ([[NSFileManager defaultManager] fileExistsAtPath:path] ? path : [@"/var/jb" stringByAppendingPathComponent:path])

// Use for C string literals
#define ROOT_PATH_C(cPath) (access(cPath, F_OK) == 0) ? cPath : "/var/jb" cPath

// Use for C string variables
// The string returned by this will get freed when your function exits
// If you want to keep it, use strdup
#define ROOT_PATH_C_VAR(cPath) (ROOT_PATH_NS([NSString stringWithUTF8String:cPath]).fileSystemRepresentation)

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

#ifndef kTweakName
#define kTweakName @"AEFCUBypass"
#endif

#ifndef PSDependsKey
#define PSDependsKey @"depends"
#endif

#ifndef PSTintColorKey
#define PSTintColorKey @"tintColor"
#endif

#define BOX(expr) ({ __typeof__(expr) _box_expr = (expr); \
    [NSValue valueWithBytes:&_box_expr objCType:@encode(__typeof__(expr))]; })