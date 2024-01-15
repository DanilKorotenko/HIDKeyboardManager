//
//  HIDValue.h
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/7/24.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "HIDElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface HIDValue : NSObject

+ (instancetype)createWithValueRef:(IOHIDValueRef)aValueRef;

@property(readonly) NSInteger integerValue;

@property(readonly) HIDElement *hidElement;

@end

NS_ASSUME_NONNULL_END
