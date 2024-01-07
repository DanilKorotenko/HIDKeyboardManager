//
//  HIDKeyboardManager.h
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/6/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kHIDDeviceAddedNotificationName;
extern NSString * const kHIDDeviceRemovedNotificationName;

@interface HIDManager : NSObject

+ (HIDManager *)sharedManager;

+ (NSError *)accessDeniedError;

- (BOOL)checkAccess:(NSError **)anError;
- (BOOL)requestAccess;

- (BOOL)start:(NSError **)anError;
- (void)stop;

@property (readonly) NSArray *allDevices;

@end

NS_ASSUME_NONNULL_END
