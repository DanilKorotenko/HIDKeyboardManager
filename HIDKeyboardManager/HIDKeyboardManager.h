//
//  HIDKeyboardManager.h
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kHIDKeyboardAddedNotificationName;
extern NSString * const kHIDKeyboardRemovedNotificationName;

@interface HIDKeyboardManager : NSObject

+ (HIDKeyboardManager *)sharedManager;

+ (NSError *)accessDeniedError;

- (BOOL)checkAccess:(NSError **)anError;
- (BOOL)requestAccess;

- (BOOL)start:(NSError **)anError;
- (void)stop;

@property (readonly) NSArray *allDevices;

@end

NS_ASSUME_NONNULL_END
