//
//  HIDKeyboard.h
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/6/24.
//

#import <Foundation/Foundation.h>

#include <IOKit/hid/IOHIDLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface HIDDevice : NSObject

+ (instancetype)createKeyboardWithDeviceRef:(IOHIDDeviceRef)aDeviceRef;

+ (BOOL)isKeyboard:(IOHIDDeviceRef)aDeviceRef;

@property(readonly) NSString *displayName;

@property(readonly) NSString *manufacturer;

@property(readonly) NSString *vendorName;
@property(readonly) NSInteger vendorID;
@property(readonly) NSString *product;
@property(readonly) NSString *productName;
@property(readonly) NSInteger productID;

@end

NS_ASSUME_NONNULL_END
