#include <substrate.h>

// Prototype of the original function
static BOOL (*orig_amIJailbroken)(void);

// Our hooked function implementation
BOOL hook_amIJailbroken(void) {
    // Always return NO
    return NO;
}

%ctor {
    // Find the original function and hook it, it's that simple
    void* amIJailbroken = MSFindSymbol(NULL, "_$s16IOSSecuritySuiteAAC13amIJailbrokenSbyFZ");
    if (amIJailbroken)
        MSHookFunction(amIJailbroken, (void *)hook_amIJailbroken, (void **)&orig_amIJailbroken); // Technically, we don't need to store the original function pointer, but it's good practice
}
