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

#pragma mark -

- (NSUInteger)usagePage
{
    uint32_t result = IOHIDElementGetUsagePage(_elementRef);
    return result;
}

- (NSString *)usagePageString
{
    NSString *result = nil;

    switch (self.usagePage)
    {
        case kHIDPage_Undefined:                result = @"Undefined"; break;
        case kHIDPage_GenericDesktop:           result = @"GenericDesktop"; break;
        case kHIDPage_Simulation:               result = @"Simulation"; break;
        case kHIDPage_VR:                       result = @"VR"; break;
        case kHIDPage_Sport:                    result = @"Sport"; break;
        case kHIDPage_Game:                     result = @"Game"; break;
        case kHIDPage_GenericDeviceControls:    result = @"GenericDeviceControls"; break;
        case kHIDPage_KeyboardOrKeypad:         result = @"KeyboardOrKeypad"; break;
        case kHIDPage_LEDs:                     result = @"LEDs"; break;
        case kHIDPage_Button:                   result = @"Button"; break;
        case kHIDPage_Ordinal:                  result = @"Ordinal"; break;
        case kHIDPage_Telephony:                result = @"Telephony"; break;
        case kHIDPage_Consumer:                 result = @"Consumer"; break;
        case kHIDPage_Digitizer:                result = @"Digitizer"; break;
        case kHIDPage_Haptics:                  result = @"Haptics"; break;
        case kHIDPage_PID:                      result = @"PID"; break;
        case kHIDPage_Unicode:                  result = @"Unicode"; break;
        case kHIDPage_AlphanumericDisplay:      result = @"AlphanumericDisplay"; break;
        case kHIDPage_Sensor:                   result = @"Sensor"; break;
        case kHIDPage_Monitor:                  result = @"Monitor"; break;
        case kHIDPage_MonitorEnumerated:        result = @"MonitorEnumerated"; break;
        case kHIDPage_MonitorVirtual:           result = @"MonitorVirtual"; break;
        case kHIDPage_MonitorReserved:          result = @"MonitorReserved"; break;
        case kHIDPage_PowerDevice:              result = @"PowerDevice"; break;
        case kHIDPage_BatterySystem:            result = @"BatterySystem"; break;
        case kHIDPage_PowerReserved:            result = @"PowerReserved"; break;
        case kHIDPage_PowerReserved2:           result = @"PowerReserved2"; break;
        case kHIDPage_BarCodeScanner:           result = @"BarCodeScanner"; break;
        case kHIDPage_Scale:                    result = @"Weighing or Scale"; break;
        case kHIDPage_MagneticStripeReader:     result = @"MagneticStripeReader"; break;
        case kHIDPage_CameraControl:            result = @"CameraControl"; break;
        case kHIDPage_Arcade:                   result = @"Arcade"; break;
        case kHIDPage_FIDO:                     result = @"FIDO"; break;
        case kHIDPage_VendorDefinedStart:       result = @"VendorDefinedStart"; break;

        default:
            break;
    }

    return result;
}

- (NSUInteger)usage
{
    uint32_t result = IOHIDElementGetUsage(_elementRef);
    return result;
}

- (NSString *)usageString
{
    NSString *result = nil;

    switch (self.usagePage)
    {
        case kHIDPage_KeyboardOrKeypad: result = self.keyboardOrKeypadPageStrings; break;

        default:
            break;
    }

    return result;
}

- (NSString *)keyboardOrKeypadPageStrings
{
    NSString *result = nil;

    return result;
}

@end
