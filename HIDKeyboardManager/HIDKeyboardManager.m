//
//  HIDKeyboardManager.m
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/6/24.
//

#import "HIDKeyboardManager.h"

#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hidsystem/IOHIDLib.h>

#include "HIDKeyboard.h"

NSString * const kHIDKeyboardAddedNotificationName = @"HIDKeyboardAddedNotificationName";
NSString * const kHIDKeyboardRemovedNotificationName = @"HIDKeyboardRemovedNotificationName";

static NSString * const kHIDKeyboardManagerErrorDomain = @"HIDKeyboardManagerErrorDomain";

typedef enum : NSUInteger
{
    kHIDKeyboardManagerErrorCodeSuccess = 0,
    kHIDKeyboardManagerErrorCodeAccessDenied,

} HIDKeyboardManagerErrorCode;

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef);
static void Handle_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef);

@interface HIDKeyboardManager ()

@property(strong) NSMutableArray *allDevicesArray;

@end

@implementation HIDKeyboardManager
{
    IOHIDManagerRef _ioHIDManagerRef;
}

+ (HIDKeyboardManager *)sharedManager
{
    static HIDKeyboardManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedManager = [[HIDKeyboardManager alloc] init];
    });
    return sharedManager;
}

+ (NSError *)accessDeniedError
{
    return [NSError errorWithDomain:kHIDKeyboardManagerErrorDomain code:kHIDKeyboardManagerErrorCodeAccessDenied
        userInfo:@{NSLocalizedDescriptionKey: @"HID Access Denied"}];
}

+ (NSError *)errorForCode:(IOReturn)aCode
{
    NSError *result = nil;

    switch (aCode)
    {

        default:
            break;
    }

    return result;
}

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.allDevicesArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    if (_ioHIDManagerRef != NULL)
    {
        CFRelease(_ioHIDManagerRef);
    }
}

#pragma mark -

- (BOOL)checkAccess:(NSError **)anError
{
    IOHIDAccessType accessType = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent);
    if (accessType != kIOHIDAccessTypeGranted)
    {
        if (anError != NULL)
        {
            *anError = [HIDKeyboardManager accessDeniedError];
        }
        return NO;
    }
    return YES;
}

- (BOOL)requestAccess
{
    return IOHIDRequestAccess(kIOHIDRequestTypeListenEvent);
}

- (BOOL)start:(NSError **)anError
{
    BOOL result = YES;

    do
    {
        IOOptionBits ioOptionBits = kIOHIDManagerOptionNone;
        _ioHIDManagerRef = IOHIDManagerCreate(kCFAllocatorDefault, ioOptionBits);
        if (!_ioHIDManagerRef)
        {
            NSLog(@"%s: Could not create IOHIDManager.\n", __PRETTY_FUNCTION__);
            break;
        }

        // register our matching & removal callbacks
        IOHIDManagerRegisterDeviceMatchingCallback(_ioHIDManagerRef, Handle_DeviceMatchingCallback, (void*)self);
        IOHIDManagerRegisterDeviceRemovalCallback(_ioHIDManagerRef, Handle_DeviceRemovalCallback, (void*)self);

        // schedule us with the run loop
        IOHIDManagerScheduleWithRunLoop(_ioHIDManagerRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

        // setup matching dictionary
        IOHIDManagerSetDeviceMatching(_ioHIDManagerRef, NULL);

        // open it
        IOReturn tIOReturn = IOHIDManagerOpen(_ioHIDManagerRef, kIOHIDOptionsTypeNone);
        if (kIOReturnSuccess != tIOReturn)
        {
            result = NO;
            if (anError != NULL)
            {
                *anError = [HIDKeyboardManager errorForCode:tIOReturn];
            }
            NSLog(@"%s: IOHIDManagerOpen error: 0x%08u",
                    __PRETTY_FUNCTION__,
                    tIOReturn);
            break;
        }

        NSLog(@"IOHIDManager (%p) creaded and opened!", (void *) _ioHIDManagerRef);
    } while (false);

    return result;
}

- (void)stop
{
    if (_ioHIDManagerRef)
    {
        IOHIDManagerClose(_ioHIDManagerRef, kIOHIDOptionsTypeNone);
    }
}

#pragma mark -

- (void)deviceAdded:(HIDKeyboard *)aDevice
{
    [self.allDevicesArray addObject:aDevice];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHIDKeyboardAddedNotificationName
        object:aDevice];
}

- (void)deviceRemoved:(HIDKeyboard *)aDevice
{
    if ([self.allDevicesArray containsObject:aDevice])
    {
        [self.allDevicesArray removeObject:aDevice];
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHIDKeyboardRemovedNotificationName
        object:aDevice];
}

#pragma mark -

- (NSArray *)allDevices
{
    return self.allDevicesArray;
}

@end

//
// this is called once for each connected device
//
static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender,
    IOHIDDeviceRef inIOHIDDeviceRef)
{
    HIDKeyboard *device = [HIDKeyboard createWithDeviceRef:inIOHIDDeviceRef];

    if (device)
    {
        NSLog(@"device added: %@", device);

        [(__bridge HIDKeyboardManager *)inContext deviceAdded:device];
    }
}

//
// this is called once for each disconnected device
//
static void Handle_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender,
    IOHIDDeviceRef inIOHIDDeviceRef)
{
    HIDKeyboard *device = [HIDKeyboard createWithDeviceRef:inIOHIDDeviceRef];

    if (device)
    {
        NSLog(@"device removed: %@", device);

        [(__bridge HIDKeyboardManager *)inContext deviceRemoved:device];
    }
}
