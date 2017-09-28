export TARGET=iphone:clang
ARCHS = armv7 arm64
DEBUG = 1
PACKAGE_VERSION = 2.0-beta3-TlMs

THEOS=/opt/theos

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Translucency
$(TWEAK_NAME)_FILES = Tweak.xm Common/DDCustomInteraction.m Common/DDCustomAnimator.m Common/DDTMColours.m
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_LDFLAGS += -F./ -F./Common/
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -F./Common/

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
