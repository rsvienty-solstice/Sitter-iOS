

@interface EmailUUIDPair : NSObject

@property (nonatomic,strong) NSUUID *uuid;
@property (nonatomic,strong) NSString *email;

@end

@implementation EmailUUIDPair

+(EmailUUIDPair*) initWithEmail:(NSString*)email andUUID:(NSUUID*)uuid{
    EmailUUIDPair* pair = [[EmailUUIDPair alloc] init];

    pair.uuid = uuid;
    pair.email = email;
    
    return pair;
}

@end

/////////////////////////////////
/////////////////////////////////
/////////////////////////////////

//
//  BLEInteraction.mm
//  SmartOffice
//
//  Copyright (c) 2014 Solstice Mobile, LLC. All rights reserved.
//


#import "BLEInteraction.h"
#include <map>

// Smart Office application listens for this ID
static NSString *BEACON_UUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6F";
static NSString *BEACON_REGION_ID = @"BabySaver";

// For Raspberry Pi
//static NSString *SERVICE_UUID = @"3B1CEB1B-59E8-4E1B-837E-D47CEDE4B230";
//static NSString *EMAIL_CHARACTERISTIC_UUID = @"C29D8BFE-DD80-4D53-806B-8F8B18D79362";

// For Baby Bottom
static NSString *SERVICE_UUID = @"3B1CEB1B-59E8-4E1B-837E-D47CEDE4B230";
static NSString *EMAIL_CHARACTERISTIC_UUID = @"C29D8BFE-DD80-4D53-806B-8F8B18D79362";


static const NSUInteger smartDisplayMajorRegionID = 99;
static const NSUInteger smartDisplayMinorRegionID = 1;

@interface BLEInteraction ()

/** Where we are scanning for listeners */
@property CLBeaconRegion *beaconRegion;
/** Manages BLE connected devices. This device is the central device. Connected ones are peripheral devices. */
@property CBPeripheralManager *peripheralManager;
/** The connected peripheral currently being used by this class. */
@property CBPeripheral *peripheral;
/** BLE power setting */
@property(nonatomic, copy, readonly) NSNumber *defaultPower;
/** Send callbacks holding data that we receive from peripherals. */
@property(nonatomic, weak) id<BLEInteractionDelegate> delegate;

@end

@implementation BLEInteraction

- (id)initWithDelegate:(id<BLEInteractionDelegate>)delegate {
    
    self = [super init];
    if(self) {
        
        // Beacon UUID
        NSUUID *proximityUUID = [[NSUUID alloc]initWithUUIDString:BEACON_UUID];
        
        // Create the peripheral manager.
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                                   options:nil];
        
        // Create the beacon region.
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID
                                                                major:smartDisplayMajorRegionID
                                                                minor:smartDisplayMinorRegionID
                                                           identifier:BEACON_REGION_ID];
        
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        _delegate = delegate;

        [self scanForPeripherals];
        
        _defaultPower = @-59;
        
        //[self initRegion];
    }
    return self;
}

/**
 * Advertise this beacon for connections
 */
- (void)startAdvertising {
    
    //return;
    
    // Create a dictionary of advertisement data.
    NSDictionary *beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:self.defaultPower];

    // Start advertising your beacon's data only if enabled
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL beaconEnabled = [defaults boolForKey:@"beaconAdvertise"];

    if (beaconEnabled) {
       [self.peripheralManager startAdvertising:beaconPeripheralData];
    }
}

/**
 * Stop being a beacon
 */
- (void)stopAdvertising {
    [self.peripheralManager stopAdvertising];
}

/**
 * Have the central manager check for connected devices with the service ID we want
 */
- (void)scanForPeripherals {
    if(self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:SERVICE_UUID]] options:nil];
    }
}

/**
 * Check the peripheral for broadcasting services of a desired UUID
 */
- (void)scanForServices {
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

#pragma mark - Central Manager Delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            [self scanForPeripherals];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
        NSLog(@"Did discover peripheral. peripheral: %@ rssi: %@, UUID: %@ advertisementData: %@ ", peripheral, RSSI, peripheral.identifier, advertisementData);
    
        self.peripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"Connection successfull to peripheral: %@ with UUID: %@",peripheral,peripheral.identifier);
    if (peripheral == self.peripheral) {
        [self.peripheral setDelegate:self];
        [self scanForServices];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self scanForPeripherals];
}

#pragma mark - Peripheral Manager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    std::map<CBPeripheralManagerState, const char*> states;
    
    states[CBPeripheralManagerStateUnknown]         = "The current state of the peripheral manager is unknown; an update is imminent.";
    states[CBPeripheralManagerStateResetting]       = "The connection with the system service was momentarily lost; an update is imminent.";
    states[CBPeripheralManagerStateUnsupported]     = "The platform doesn't support the Bluetooth low energy peripheral/server role.";
    states[CBPeripheralManagerStateUnauthorized]    = "The app is not authorized to use the Bluetooth low energy peripheral/server role.";
    states[CBPeripheralManagerStatePoweredOff]      = "Bluetooth is currently powered off.";
    states[CBPeripheralManagerStatePoweredOn]       = "Bluetooth is currently powered on and is available to use.";
    
    NSLog(@"Peripheral state: %s",states[[peripheral state]]);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SERVICE_UUID]]) {

            [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:EMAIL_CHARACTERISTIC_UUID] ] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    for (CBCharacteristic *characteristic in service.characteristics) {
        [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:EMAIL_CHARACTERISTIC_UUID]]) {
            
            [self.peripheral readValueForCharacteristic:characteristic];
            // Subscripe to updates
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Pull the data from the service's characteristic
    NSData *data = characteristic.value;
    
    if (data && (data.length > 0)) {
        // Send the info back to the display
        NSString *stringValue = [NSString stringWithUTF8String:(const char *)data.bytes];
        if ([stringValue isEqualToString:STOP_SHOWING_SMART_DISPLAY_NOTIFICATION]) {
            // Don't listen now that out of range. Disconnect BLE.
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            [self.centralManager cancelPeripheralConnection:peripheral];
        }
        
        
        [self.delegate beacon:self
 peripheralDidReceiveUsername:stringValue
                    forDevice:peripheral.identifier];
    }
}

- (void)initRegion
{
   // NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACON_UUID];
    //self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:BEACON_REGION_ID];
    [self.locationManager startMonitoringForRegion:_beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:_beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    if (beacon.proximity == CLProximityUnknown) {
       //self.distanceLabel.text = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate)
    {
        //self.distanceLabel.text = @"Immediate";
        
        // Switch to a CB peripheral - start advertising to central manager
        self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
        [self startAdvertising];
    }
    else if (beacon.proximity == CLProximityNear) {
       // self.distanceLabel.text = @"Near";
    } else if (beacon.proximity == CLProximityFar) {
        //self.distanceLabel.text = @"Far";
    }
    //self.rssiLabel.text = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
}


@end