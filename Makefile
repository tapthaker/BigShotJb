include $(THEOS)/makefiles/common.mk



TWEAK_NAME = BigShotJb
BigShotJb_FILES = UIWindow+Bigshot.m UIView+Toast.m
BigShotJb_FRAMEWORKS = UIKit
SHARED_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
