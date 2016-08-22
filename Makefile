include $(THEOS)/makefiles/common.mk



TWEAK_NAME = BigShotJb
BigShotJb_FILES = Listener.xm UIWindow+Bigshot.m UIView+Toast.m
BigShotJb_FRAMEWORKS = UIKit
BigShotJb_LIBRARIES = activator objcipc
BigShotJb_PRIVATE_FRAMEWORKS = AppSupport
SHARED_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
