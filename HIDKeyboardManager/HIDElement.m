//
//  HIDElement.m
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/7/24.
//

#import "HIDElement.h"

@implementation HIDElement
{
    IOHIDElementRef _elementRef;
}

+ (instancetype)createWithElementRef:(IOHIDElementRef)anElementRef
{
    return [[HIDElement alloc] initWithElementRef:anElementRef];
}

- (instancetype)initWithElementRef:(IOHIDElementRef)anElementRef
{
    self = [super init];
    if (self)
    {
        if (anElementRef == NULL)
        {
            return nil;
        }
        if (CFGetTypeID(anElementRef) != IOHIDElementGetTypeID())
        {
            return nil;
        }
        _elementRef = (IOHIDElementRef)CFRetain(anElementRef);
    }
    return self;
}

- (void)dealloc
{
    if (_elementRef)
    {
        CFRelease(_elementRef);
    }
}



@end
