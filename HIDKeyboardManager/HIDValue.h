//
//  HIDValue.h
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/7/24.
//

#import <Foundation/Foundation.h>
#include <IOKit/hid/IOHIDLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface HIDValue : NSObject

+ (instancetype)createWithValueRef:(IOHIDValueRef)aValueRef;

@property(readonly) NSInteger integerValue;

@end

NS_ASSUME_NONNULL_END
