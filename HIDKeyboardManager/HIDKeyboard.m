//
//  HIDKeyboard.m
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/6/24.
//

#import "HIDKeyboard.h"

@interface HIDKeyboard ()

@property (readonly) NSNumber *vendorIDNumber;
@property (readonly) NSNumber *productIDNumber;

@end

@implementation HIDKeyboard
{
    IOHIDDeviceRef _deviceRef;
}

@synthesize displayName;
@synthesize manufacturer;
@synthesize vendorName;
@synthesize vendorIDNumber;
@synthesize product;
@synthesize productName;
@synthesize productIDNumber;

+ (instancetype)createWithDeviceRef:(IOHIDDeviceRef)aDeviceRef
{
    if ([HIDKeyboard isKeyboard:aDeviceRef])
    {
        return [[HIDKeyboard alloc] initWithIOHIDDevice:aDeviceRef];
    }
    return nil;
}

+ (BOOL)isKeyboard:(IOHIDDeviceRef)aDeviceRef
{
    BOOL result = NO;

    if (IOHIDDeviceConformsTo(aDeviceRef,
        kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard))
    {
        result = YES;
    }
    return result;
}

#pragma mark -

+ (NSDictionary *)deviceUsageStrings
{
    static NSDictionary *result = nil;
    if (nil == result)
    {
        NSString *pathToResourceFile = [[NSBundle bundleForClass:[self class]]
            pathForResource:@"HID_device_usage_strings" ofType:@"plist"];
        result = [NSDictionary dictionaryWithContentsOfFile:pathToResourceFile];
    }
    return result;
}

#pragma mark -

- (instancetype)initWithIOHIDDevice:(IOHIDDeviceRef)aDeviceRef
{
    self = [super init];
    if (self)
    {
        if (aDeviceRef == NULL)
        {
            return nil;
        }

        if (CFGetTypeID(aDeviceRef) != IOHIDDeviceGetTypeID())
        {
            return nil;
        }

        _deviceRef = (IOHIDDeviceRef)CFRetain(aDeviceRef);
    }
    return self;
}

- (NSString *)description
{
    return self.displayName;
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
    {
        return YES;
    }
    else
    {
        HIDKeyboard *otherDevice = (HIDKeyboard *)other;
        return _deviceRef == otherDevice->_deviceRef;
    }
}

#pragma mark -

- (NSString *)displayName
{
    if (nil == displayName)
    {
        NSMutableString *result = [NSMutableString string];

        if (self.manufacturer)
        {
            [result appendString:self.manufacturer];
        }

        if (result.length == 0)
        {
            if (self.vendorName)
            {
                [result appendString:self.vendorName];
            }
        }

        if (result.length == 0)
        {
            [result appendFormat:@"vendor %ld", (long)self.vendorID];
        }

        NSString *product = self.product;

        if (product.length == 0)
        {
            product = self.productName;
        }

        if (product.length == 0)
        {
            product = [NSString stringWithFormat:@"- product id: %ld", (long)self.productID];
        }

        [result appendFormat:@" %@", product];

        displayName = result;
    }

    return displayName;
}

- (NSString *)manufacturer
{
    if (nil == manufacturer)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDManufacturerKey));
        if (tCFTypeRef)
        {
            manufacturer = (__bridge NSString *)tCFTypeRef;
            manufacturer = [manufacturer stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }

    return manufacturer;
}

- (NSString *)vendorName
{
    if (nil == vendorName)
    {
        NSString *vendorKey = [NSString stringWithFormat:@"%ld", (long)self.vendorID];
        NSDictionary *vendorDictionary = [[HIDKeyboard deviceUsageStrings] objectForKey:vendorKey];
        if (vendorDictionary)
        {
            vendorName = [vendorDictionary objectForKey:@"Name"];
        }
    }
    return vendorName;
}

- (NSNumber *)vendorIDNumber
{
    if (nil == vendorIDNumber)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDVendorIDKey));
        if (tCFTypeRef)
        {
            vendorIDNumber = (__bridge NSNumber *)tCFTypeRef;
        }
    }
    return vendorIDNumber;
}

- (NSInteger)vendorID
{
    return self.vendorIDNumber.integerValue;
}

- (NSString *)product
{
    if (nil == product)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDProductKey));
        if (tCFTypeRef)
        {
            product = (__bridge NSString *)tCFTypeRef;
        }
    }
    return product;
}

- (NSString *)productName
{
    if (nil == productName)
    {
        NSString *vendorKey = [NSString stringWithFormat:@"%ld", (long)self.vendorID];
        NSDictionary *vendorDictionary = [[HIDKeyboard deviceUsageStrings] objectForKey:vendorKey];
        if (vendorDictionary)
        {
            NSString *productKey = [NSString stringWithFormat:@"%ld", (long)self.productID];
            NSDictionary *productDictionary = [vendorDictionary objectForKey:productKey];
            productName = [productDictionary objectForKey:@"Name"];
        }
    }
    return productName;
}

- (NSNumber *)productIDNumber
{
    if (nil == productIDNumber)
    {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(_deviceRef, CFSTR(kIOHIDProductIDKey));
        if (tCFTypeRef)
        {
            productIDNumber = (__bridge NSNumber *)tCFTypeRef;
        }
    }
    return productIDNumber;
}

- (NSInteger)productID
{
    return self.productIDNumber.integerValue;
}

@end
