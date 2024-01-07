//
//  HIDKeyboardManager.m
//  HIDKeyboardManager
//
//  Created by Danil Korotenko on 1/6/24.
//

#import "HIDManager.h"

#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hidsystem/IOHIDLib.h>

#include "HIDDevice.h"

NSString * const kHIDDeviceAddedNotificationName = @"HIDDeviceAddedNotificationName";
NSString * const kHIDDeviceRemovedNotificationName = @"HIDDeviceRemovedNotificationName";

static NSString * const kHIDDeviceManagerErrorDomain = @"HIDDeviceManagerErrorDomain";

typedef enum : NSUInteger
{
    kHIDDeviceManagerErrorCodeSuccess = 0,
    kHIDDeviceManagerErrorCodeAccessDenied,

} HIDKeyboardManagerErrorCode;

static void Handle_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef);
static void Handle_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef);

@interface HIDManager ()

@property(strong) NSMutableArray *allDevicesArray;

@end

@implementation HIDManager
{
    IOHIDManagerRef _ioHIDManagerRef;
}

+ (HIDManager *)sharedManager
{
    static HIDManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        sharedManager = [[HIDManager alloc] init];
    });
    return sharedManager;
}

+ (NSError *)accessDeniedError
{
    return [NSError errorWithDomain:kHIDDeviceManagerErrorDomain code:kHIDDeviceManagerErrorCodeAccessDenied
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
            *anError = [HIDManager accessDeniedError];
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
                *anError = [HIDManager errorForCode:tIOReturn];
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

- (void)deviceAdded:(HIDDevice *)aDevice
{
    [self.allDevicesArray addObject:aDevice];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHIDDeviceAddedNotificationName
        object:aDevice];
}

- (void)deviceRemoved:(HIDDevice *)aDevice
{
    if ([self.allDevicesArray containsObject:aDevice])
    {
        [self.allDevicesArray removeObject:aDevice];
    }
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHIDDeviceRemovedNotificationName
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
    HIDDevice *device = [HIDDevice createWithDeviceRef:inIOHIDDeviceRef];

    if (device)
    {
        NSLog(@"device added: %@", device);

        [(__bridge HIDManager *)inContext deviceAdded:device];
    }
}

//
// this is called once for each disconnected device
//
static void Handle_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender,
    IOHIDDeviceRef inIOHIDDeviceRef)
{
    HIDDevice *device = [HIDDevice createWithDeviceRef:inIOHIDDeviceRef];

    if (device)
    {
        NSLog(@"device removed: %@", device);

        [(__bridge HIDManager *)inContext deviceRemoved:device];
    }
}
