//
//  AppDelegate.m
//  HIDKeyboardManagerApp
//
//  Created by Danil Korotenko on 1/6/24.
//

#import "AppDelegate.h"
#import "HIDKeyboardManager.h"
#import "HIDKeyboard.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTableView *keyboardTable;

@property (strong) NSArray *keyboardInfoData;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSError *error = nil;

    if (![[HIDKeyboardManager sharedManager] checkAccess:&error])
    {
        if ([[HIDKeyboardManager sharedManager] requestAccess])
        {
            if (![[HIDKeyboardManager sharedManager] start:&error])
            {
                [NSApp presentError:error];
                [NSApp terminate:self];
            }
        }
        else
        {
            [NSApp presentError:[HIDKeyboardManager accessDeniedError]];
            [NSApp terminate:self];
        }
    }
    else
    {
        if (![[HIDKeyboardManager sharedManager] start:&error])
        {
            [NSApp presentError:error];
            [NSApp terminate:self];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAdded:)
        name:kHIDKeyboardAddedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemoved:)
        name:kHIDKeyboardRemovedNotificationName object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[HIDKeyboardManager sharedManager] stop];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark -

- (void)deviceAdded:(NSNotification *)aNotification
{
//    HIDKeyboard *device = [aNotification object];
    [self updateUI];
}

- (void)deviceRemoved:(NSNotification *)aNotification
{
//    HIDKeyboard *device = [aNotification object];
    [self updateUI];
}

#pragma mark -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.keyboardInfoData.count;
}

- (nullable id)tableView:(NSTableView *)tableView
    objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *result = nil;

    NSDictionary *info = [self.keyboardInfoData objectAtIndex:row];

    if (info)
    {
        if ([tableColumn.identifier isEqualToString:@"displayName"])
        {
            result = [info objectForKey:@"displayName"];
        }
    }

    return result;
}


#pragma mark -

- (void)updateUI
{
    NSMutableArray *displayInfo = [NSMutableArray array];
    for (HIDKeyboard *device in [HIDKeyboardManager sharedManager].allDevices)
    {
        [displayInfo addObject:
            @{
                @"displayName": device.displayName
            }];
    }
    self.keyboardInfoData = displayInfo;
    [self.keyboardTable reloadData];
}

@end
