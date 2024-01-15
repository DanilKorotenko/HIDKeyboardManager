//
//  HIDValue.m
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/7/24.
//

#import "HIDValue.h"

@implementation HIDValue
{
    IOHIDValueRef _valueRef;
}

+ (instancetype)createWithValueRef:(IOHIDValueRef)aValueRef
{
    return [[HIDValue alloc] initWithHidValueRef:aValueRef];
}

- (instancetype)initWithHidValueRef:(IOHIDValueRef)aValueRef
{
    self = [super init];
    if (self)
    {
        if (aValueRef == NULL)
        {
            return nil;
        }
        if (CFGetTypeID(aValueRef) != IOHIDValueGetTypeID())
        {
            return nil;
        }
        _valueRef = (IOHIDValueRef)CFRetain(aValueRef);
    }
    return self;
}

- (void)dealloc
{
    if (_valueRef)
    {
        CFRelease(_valueRef);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, integerValue: %ld, usage: %@",
        [super description], (long)self.integerValue, self.hidElement.usageString];
}

#pragma mark -

- (NSInteger)integerValue
{
    return IOHIDValueGetIntegerValue(_valueRef);
}

- (HIDElement *)hidElement
{
    IOHIDElementRef tIOHIDElementRef = IOHIDValueGetElement(_valueRef);
    HIDElement *element = [HIDElement createWithElementRef:tIOHIDElementRef];
    return element;
}

@end
