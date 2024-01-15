//
//  HIDElement.h
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/7/24.
//

#import <Foundation/Foundation.h>
#include <IOKit/hid/IOHIDLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface HIDElement : NSObject

+ (instancetype)createWithElementRef:(IOHIDElementRef)anElementRef;

@property (readonly) NSUInteger usagePage;
@property (readonly) NSString* usagePageString;

@property (readonly) NSUInteger usage;
@property (readonly) NSString* usageString;

@end

NS_ASSUME_NONNULL_END
