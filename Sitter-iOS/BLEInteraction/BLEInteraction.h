//
//  Beacon.h
//  SmartHub
//
//  Copyright (c) 2013 Daher Alfawares. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@class BLEInteraction;

static NSString *STOP_SHOWING_SMART_DISPLAY_NOTIFICATION = @"CLEAR";

/**
 * Delegate to receive callbacks from BLE interactions
 */
@protocol BLEInteractionDelegate

@required
/**
 * Notify the delegate that an email address has been sent over BLE
 *
 * @param beacon    The interaction that is sending the data
 * @param username  The user's id. Most likely an email address.
 * @param deviceID  The UUID for the device
 */
- (void)beacon:(BLEInteraction *)beacon
peripheralDidReceiveUsername:(NSString *)username
     forDevice:(NSUUID*)deviceID;

///**
// * Notify the delegate that we disconnected from a device
// *
// * @param beacon    The interaction that is sending the data
// * @param email     The email corresponding to the UUID of the device we disconnected from
// */
//-(void)beacon:(BLEInteraction *)beacon disconnectedFromDeviceWithEmail:(NSString *)email;
@end

@interface BLEInteraction : NSObject<CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>

/** Handles connecting and disconnecting of peripherals. */
@property CBCentralManager *centralManager;

/**
 * Call init and set the delegate
 *
 * @param delegate Pointer to the delegate to assign
 */
- (id)initWithDelegate:(id<BLEInteractionDelegate>)delegate;
-(void)startAdvertising;

@end
