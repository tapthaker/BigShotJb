#import <libactivator/libactivator.h>
#import <libobjcipc/objcipc.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import "UIWindow+BigShot.h"
#import "UIView+Toast.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>


@implementation UIApplication (BigShot)
	
-(void)captureScreenShot {
	NSLog(@"captureScreenShot called !!!");
	UIImage *image = [self.keyWindow takeFullScreenShot];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

 - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
 	if(error == nil) {
 		[self.keyWindow makeToast:@"BigShot saved !!!!"];
 	} else {
 		[self.keyWindow makeToast:error.localizedDescription];
 	}
 }

@end

@interface BigShotListener : NSObject <LAListener>
@end

static SpringBoard *springBoard = nil;

@implementation BigShotListener

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {

	SpringBoard *springBoard = (SpringBoard*) [objc_getClass("SpringBoard") sharedApplication];
	SBApplication *front = (SBApplication*) [springBoard _accessibilityFrontMostApplication];
	[OBJCIPC sendMessageToAppWithIdentifier:front.bundleIdentifier messageName:@"captureScreenShot" dictionary:nil replyHandler:^(NSDictionary *response) {
                event.handled = YES;
	}];
}


- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
	return @"BigShot";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Capture BigShot";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Captures a full-screen screenshot, including the vertical scrollable area";
}
- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"application", nil];
}

@end

%hook UIApplication

static NSArray *blackList = @[ @"MailAppController", @"FBWildeApplication" ];

- (void)_run {
	NSString *classString = NSStringFromClass([self class]);
	if ([@"SpringBoard" isEqualToString:classString]) {
		%log(@"Registering SpringBoard for activator events");
		springBoard = (SpringBoard*) self;
		[LASharedActivator registerListener:[BigShotListener new] forName:@"com.tapthaker.bigshotjb"];
	} else if (![blackList containsObject:classString]) {
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"captureScreenShot" handler:^NSDictionary *(NSDictionary *message) {
			   dispatch_async(dispatch_get_main_queue(), ^{
           		[[UIApplication sharedApplication] captureScreenShot];	
        	});
            return nil;
        }];


	}

 %orig;
}

%end