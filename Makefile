TWEAK_NAME = AEFCUBypass

$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

ifeq ($(SIM_BUILD), 1)
	SIM_BUILD = 1
	TARGET := simulator:clang::15.0
	ARCHS = arm64
else
	SIM_BUILD = 0
	TARGET := iphone:clang:latest:15.0
#INSTALL_TARGET_PROCESSES = SpringBoard

	ifeq ($(ROOTLESS), 1)
		THEOS_PACKAGE_SCHEME = rootless
	endif
endif

export SIM_BUILD
export DEBUG
export FINALPACKAGE
export ROOTLESS

include $(THEOS)/makefiles/common.mk

##################################
##########     NOTE     ##########
################################## \
If the current build is a production build, the AEFCUB_DEBUG variable will be ignored and just overwritten.\
This way production builds won't get built with debug output enabled by accident. \
If the current build is not a production build, the AEFCUB_DEBUG variable will be passed to the compiler.
ifeq ($(FINALPACKAGE), 1)
	$(TWEAK_NAME)_CFLAGS += -DAEFCUB_DEBUG=0
else
	$(TWEAK_NAME)_CFLAGS += -DAEFCUB_DEBUG="$(DEBUG)"
endif

ifeq ($(DEBUG), 1) 
	ifeq ($(FINALPACKAGE), 0)
		$(TWEAK_NAME)_CFLAGS += -Wno-unused-variable -Wno-unused-function
	endif
endif

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preference_bundle
include $(THEOS_MAKE_PATH)/aggregate.mk

ifeq ($(ROOTLESS), 1)
	ifeq ($(SIM_BUILD), 0)
after-$(TWEAK_NAME)-stage::
#@echo "[*] Fixing up framework and library paths which now will use rpath and self-signing again so iOS can fuck off"
#install_name_tool -change /usr/lib/libcolorpicker.dylib "@rpath/libcolorpicker.dylib" $(THEOS_STAGING_DIR)$(LOCAL_INSTALL_PATH)/$(TWEAK_NAME).dylib
#ldid -S $(THEOS_STAGING_DIR)$(LOCAL_INSTALL_PATH)/$(TWEAK_NAME).dylib
	endif
endif

# sudo rm -rf /opt/simject/AEFCUBypass.dylib && resim && sudo cp .theos/obj/iphone_simulator/debug/arm64/AEFCUBypass.dylib /opt/simject && resim
# sudo rm -rf /opt/simject-prefs/AEFCUBypassPrefs.bundle && sudo cp -r .theos/obj/iphone_simulator/debug/AEFCUBypassPrefs.bundle /opt/simject-prefs && sudo cp .theos/obj/iphone_simulator/debug/arm64/AEFCUBypassPrefs.bundle/AEFCUBypassPrefs /opt/simject-prefs/AEFCUBypassPrefs.bundle && resim