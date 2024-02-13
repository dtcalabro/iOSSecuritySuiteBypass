BUNDLE_NAME = AEFCUBypassPrefs

$(BUNDLE_NAME)_FILES = AEFCUBRootListController.m $(wildcard *.m) $(wildcard *.xm)
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc

ifeq ($(SIM_BUILD), 1)
	TARGET := simulator:clang::15.0
	ARCHS = arm64
else
	TARGET := iphone:clang:latest:15.0
	SDK_PATH = $(THEOS)/sdks/iPhoneOS14.5.sdk/
	SYSROOT = $(SDK_PATH)
endif

ifeq ($(ROOTLESS), 1)
	THEOS_PACKAGE_SCHEME = rootless
endif

include $(THEOS)/makefiles/common.mk

##################################
##########     NOTE     ##########
################################## \
If the current build is a production build, the AEFCUB_DEBUG variable will be ignored and just overwritten.\
This way production builds won't get built with debug output enabled by accident. \
If the current build is not a production build, the AEFCUB_DEBUG variable will be passed to the compiler.
ifeq ($(FINALPACKAGE), 1)
	$(BUNDLE_NAME)_CFLAGS += -DAEFCUB_DEBUG=0
else
	$(BUNDLE_NAME)_CFLAGS += -DAEFCUB_DEBUG="$(DEBUG)"
endif

ifeq ($(DEBUG), 1)
	ifeq ($(FINALPACKAGE), 0)
		$(BUNDLE_NAME)_CFLAGS += -Wno-unused-variable -Wno-unused-function
	endif
endif

ifeq ($(ROOTLESS), 1)
	ifeq ($(SIM_BUILD), 0)
after-$(BUNDLE_NAME)-stage::
	#@echo "[*] Fixing up framework and library paths which now will use rpath and self-signing again so iOS can fuck off"
	#install_name_tool -change /Library/Frameworks/AltList.framework/AltList "@rpath/AltList.framework/AltList" $(THEOS_STAGING_DIR)$($(THEOS_CURRENT_INSTANCE)_INSTALL_PATH)/$(_LOCAL_BUNDLE_FULL_NAME)/$(BUNDLE_NAME)
	#ldid -S $(THEOS_STAGING_DIR)$($(THEOS_CURRENT_INSTANCE)_INSTALL_PATH)/$(_LOCAL_BUNDLE_FULL_NAME)/$(BUNDLE_NAME)
	endif
endif

include $(THEOS_MAKE_PATH)/bundle.mk
